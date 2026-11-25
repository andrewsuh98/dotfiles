#!/bin/bash
# Provision a fresh Ubuntu server, once, before install.sh. Run as root (or with
# sudo) from an interactive SSH session:
#
#   curl -fsSLo /tmp/server.sh https://raw.githubusercontent.com/andrewsuh98/dotfiles/main/provision/server.sh
#   sudo bash /tmp/server.sh
#
# It updates packages, turns on automatic security updates, creates your user,
# sets the hostname, joins Tailscale, and then, after you confirm you can log in
# over Tailscale, turns off password and root SSH logins and firewalls everything
# but Tailscale. Safe to rerun. Optional environment variables:
#
#   NEW_USER         user to create (prompted, default andrewsuh)
#   SERVER_HOSTNAME  hostname, also the Tailscale machine name (prompted)
#   TS_AUTHKEY       Tailscale auth key; without one, tailscale prints a login URL
set -euo pipefail

# ── Helpers ───────────────────────────────────
say()  { printf '\n==> %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

# Prompts read /dev/tty so they work however the script was started.
ask() {
  local reply
  read -r -p "$1${2:+ [$2]}: " reply </dev/tty
  printf '%s' "${reply:-${2:-}}"
}

# ── Preflight ─────────────────────────────────
[ "$(id -u)" -eq 0 ] || die "run as root, e.g. sudo bash $0"
(: </dev/tty) 2>/dev/null || die "needs an interactive terminal (prompts for a password and a login check)"

. /etc/os-release
case "${ID:-}" in
  ubuntu) ;;
  debian) warn "Debian is untested; continuing" ;;
  *) die "unsupported OS '${ID:-unknown}'; this script targets Ubuntu" ;;
esac

user="${NEW_USER:-$(ask "Username" andrewsuh)}"
[[ "$user" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]] || die "invalid username '$user'"
[ "$user" != root ] || die "pick a user other than root"

host="${SERVER_HOSTNAME:-$(ask "Hostname" "$(hostname -s)")}"
[[ "$host" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]] \
  || die "invalid hostname '$host' (lowercase letters, digits, hyphens)"

# ── Packages ──────────────────────────────────
say "Updating packages"
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=l  # list services needing a restart instead of prompting
apt_opts=(-y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold)
apt-get update
# full-upgrade, not upgrade: kernel updates arrive as new packages, which upgrade keeps back.
apt-get "${apt_opts[@]}" full-upgrade
# Minimal images can lack any of these.
apt-get "${apt_opts[@]}" install sudo curl ca-certificates openssh-server ufw unattended-upgrades

# ── Automatic security updates ────────────────
# The stock 50unattended-upgrades config installs only security updates and
# never reboots on its own; this file just switches the daily run on.
say "Enabling unattended-upgrades"
cat >/etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
systemctl enable --now apt-daily.timer apt-daily-upgrade.timer \
  || warn "could not enable the apt timers; check 'systemctl status apt-daily-upgrade.timer'"

# ── User ──────────────────────────────────────
say "Setting up user $user"
if id "$user" &>/dev/null; then
  usermod -aG sudo "$user"
else
  # bash for now; chezmoi's first apply switches the login shell to zsh.
  useradd --create-home --shell /bin/bash --groups sudo "$user"
fi

# sudo and the provider's web console both need a password.
if [ "$(passwd -S "$user" | awk '{print $2}')" != P ]; then
  echo "Set a password for $user (used for sudo and console login):"
  until passwd "$user" </dev/tty; do echo "Try again."; done
fi

# ── SSH keys ──────────────────────────────────
# Copy the keys that got you onto this box: root's on providers that hand out
# root (Contabo, Hetzner, DigitalOcean), or the sudo user's on those that hand
# out a default user (AWS, GCP, Multipass). Appends, so reruns change nothing.
home="$(getent passwd "$user" | cut -d: -f6)"
group="$(id -gn "$user")"
src_user="${SUDO_USER:-root}"
src_keys="$(getent passwd "$src_user" | cut -d: -f6)/.ssh/authorized_keys"
dst_keys="$home/.ssh/authorized_keys"

install -d -m 700 -o "$user" -g "$group" "$home/.ssh"
touch "$dst_keys"
if [ "$src_user" != "$user" ] && [ -f "$src_keys" ]; then
  say "Copying SSH keys from $src_user to $user"
  while IFS= read -r key; do
    # Skip blanks, comments, and forced-command entries like AWS's root
    # "Please login as the user ubuntu" line.
    case "$key" in ''|'#'*|*command=*) continue ;; esac
    grep -qxF "$key" "$dst_keys" || printf '%s\n' "$key" >>"$dst_keys"
  done <"$src_keys"
fi
chown "$user:$group" "$dst_keys"
chmod 600 "$dst_keys"
grep -qvE '^[[:space:]]*(#|$)' "$dst_keys" \
  || die "$dst_keys has no keys; add yours, then rerun (lockdown would lock you out)"

# ── Hostname ──────────────────────────────────
say "Setting hostname to $host"
old_host="$(hostname -s)"
hostnamectl set-hostname "$host"
sed -i '/^127\.0\.1\.1[[:space:]]/d' /etc/hosts
printf '127.0.1.1\t%s\n' "$host" >>/etc/hosts
if [ "$old_host" != "$host" ] && grep -qwF -- "$old_host" /etc/hosts; then
  warn "/etc/hosts still mentions the old hostname '$old_host'; review it"
fi

# Stop cloud-init from resetting the hostname or rewriting /etc/hosts at boot.
if [ -d /etc/cloud/cloud.cfg.d ]; then
  cat >/etc/cloud/cloud.cfg.d/99-provision.cfg <<'EOF'
preserve_hostname: true
manage_etc_hosts: false
EOF
fi

# ── Tailscale ─────────────────────────────────
# Capture first: piping into grep -q under pipefail can fail on SIGPIPE.
tailscale_running() {
  local status
  status="$(tailscale status --json 2>/dev/null || true)"
  grep -q '"BackendState": *"Running"' <<<"$status"
}

if ! command -v tailscale &>/dev/null; then
  say "Installing Tailscale"
  curl -fsSL https://tailscale.com/install.sh | sh
fi
systemctl enable --now tailscaled

if ! tailscale_running; then
  say "Joining the tailnet as $host"
  if [ -n "${TS_AUTHKEY:-}" ]; then
    tailscale up --hostname="$host" --auth-key="$TS_AUTHKEY"
  else
    echo "No TS_AUTHKEY set; open the URL tailscale prints to log in."
    tailscale up --hostname="$host"
  fi
fi
unset TS_AUTHKEY
tailscale_running || die "Tailscale is not connected; fix that and rerun before locking down"
tailscale set --auto-update || warn "could not turn on Tailscale auto-update"
ts_ip="$(tailscale ip -4)"
ts_ip="${ts_ip%%$'\n'*}"

# ── Login check ───────────────────────────────
hardening=/etc/ssh/sshd_config.d/00-hardening.conf
if [ ! -f "$hardening" ]; then
  say "Check your login before lockdown"
  cat <<EOF
Keep this session open. From your own computer, in a new terminal, run:

  ssh $user@$host      (or ssh $user@$ts_ip)

then 'sudo -v' there to check the password works. Lockdown turns off root and
password logins and blocks SSH except over Tailscale.
EOF
  [ "$(ask "Did that work? Type yes to lock down")" = yes ] \
    || die "stopped before lockdown; fix the login and rerun"
fi

# ── Lockdown: SSH ─────────────────────────────
say "Hardening sshd"
grep -qE '^[[:space:]]*Include[[:space:]]+/etc/ssh/sshd_config\.d/\*\.conf' /etc/ssh/sshd_config \
  || die "/etc/ssh/sshd_config does not include sshd_config.d; add the hardening by hand"
# sshd keeps the first value it reads, so 00- wins over a provider's
# 50-cloud-init.conf that turns password logins back on.
cat >"$hardening" <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
EOF
mkdir -p /run/sshd  # sshd -t needs it when sshd is socket-activated and idle
if ! sshd -t; then
  rm -f "$hardening"
  die "sshd rejected the config; removed $hardening"
fi
effective="$(sshd -T)"
for setting in 'passwordauthentication no' 'kbdinteractiveauthentication no' 'permitrootlogin no'; do
  grep -qx "$setting" <<<"$effective" || warn "sshd's effective config lacks '$setting'"
done
# Existing sessions survive a reload or restart.
systemctl reload-or-restart ssh

# ── Lockdown: firewall ────────────────────────
# Established connections, like this session, survive enabling ufw. mosh's UDP
# arrives on tailscale0, so it needs no rule of its own.
say "Configuring ufw"
ufw default deny incoming
ufw default allow outgoing
ufw allow in on tailscale0
ufw allow 41641/udp comment 'Tailscale direct connections'
ufw --force enable

# ── Done ──────────────────────────────────────
say "Provisioned $host"
cat <<EOF
Next steps:

1. Turn off Tailscale key expiry, or $host drops off the tailnet in 180 days:
   https://login.tailscale.com/admin/machines > $host > ... > Disable key expiry
2. Log in as $user over Tailscale and bootstrap the dotfiles:
   sh -c "\$(curl -fsSL https://raw.githubusercontent.com/andrewsuh98/dotfiles/main/install.sh)"
EOF
if [ -f /var/run/reboot-required ]; then
  echo "3. Reboot when convenient; package updates asked for it."
fi

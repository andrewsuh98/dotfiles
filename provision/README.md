# provision

Root-level setup for a fresh Linux server, run once before the dotfiles bootstrap.
chezmoi ignores this folder.

## server.sh

On a fresh Ubuntu server, logged in as root or as the provider's default sudo user:

```bash
curl -fsSLo /tmp/server.sh https://raw.githubusercontent.com/andrewsuh98/dotfiles/main/provision/server.sh
sudo bash /tmp/server.sh
```

It asks for a username and hostname, sets a password, copies your SSH keys from the
account you logged in with, joins Tailscale, then pauses until you confirm a login over
Tailscale before it turns off root and password logins and firewalls everything else.
Pass `TS_AUTHKEY=tskey-...` (after `sudo`) to join without the browser login; without it,
`tailscale up` prints a URL to open.

Afterwards:

- Disable key expiry for the machine in the Tailscale admin console (Machines, the
  machine's menu, Disable key expiry). The script prints this reminder too.
- Log in as your user over Tailscale and run the bootstrap command from the main README.

## Testing in a local VM

[Multipass](https://canonical.com/multipass) (`brew install --cask multipass`) runs the
same Ubuntu cloud images VPS providers use. It starts with an `ubuntu` sudo user, which
tests the sudo path; the root path gets tested on a real provider.

1. Create an ephemeral, reusable auth key in the Tailscale admin console (Settings, Keys),
   so the test machine leaves the tailnet on its own once it is gone.
2. Launch a VM with your Mac's key on the `ubuntu` user (`multipass find` lists images):

   ```bash
   multipass launch 26.04 --name prov-test --cloud-init - <<EOF
   #cloud-config
   ssh_authorized_keys:
     - $(cat ~/.ssh/id_ed25519.pub)
   EOF
   ```

3. Copy the script in and run it (this tests the working tree, before pushing):

   ```bash
   multipass transfer provision/server.sh prov-test:/tmp/server.sh
   multipass shell prov-test
   read -rs TS_AUTHKEY  # paste the ephemeral key
   sudo TS_AUTHKEY="$TS_AUTHKEY" bash /tmp/server.sh
   ```

4. At the login check, run `ssh <user>@<hostname>` and `sudo -v` from a Mac terminal,
   then answer yes.
5. Check the lockdown from the Mac:
   - `ssh <user>@<hostname>` still works (over Tailscale).
   - `ssh ubuntu@<VM IP>` times out (`multipass info prov-test` shows the IP). Expect
     `multipass shell` to stop working too, since it uses the same blocked route.
   - `ssh root@<hostname>` is refused.
6. Rerun `sudo bash /tmp/server.sh` from the Tailscale session: it should skip the
   password prompt and login check and finish without changes.
7. `multipass delete --purge prov-test`.

# dotfiles

Personal dotfiles for macOS (Apple Silicon), managed with [chezmoi](https://www.chezmoi.io/).
A lean CLI subset also runs on headless Linux servers (via Homebrew on Linux).

## Bootstrap

Same command on macOS and Linux:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/andrewsuh98/dotfiles/main/install.sh)"
```

Installs chezmoi (plus Xcode CLI tools on macOS), then bootstraps the environment with
`chezmoi init --apply`. On first run you pick a machine **role** (`personal`, `work`, or `vm`)
that decides what gets installed; on Linux the `server` role is auto-selected. A Linux box
needs `sudo` for the Homebrew build prerequisites installed during apply.

---

Ported from a git bare dotfiles repo, archived at https://github.com/andrewsuh98/dotfiles-bare.

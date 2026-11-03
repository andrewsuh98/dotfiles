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

If you enable Mac App Store apps, sign into the App Store first. Otherwise those apps are
skipped with a warning that prints the `mas install` command to run later. Rerunning the
bootstrap command pulls the latest dotfiles and applies them.

## After bootstrap

A few steps stay manual. macOS prompts for most of them the first time each app starts.

- GitHub CLI authenticated with `gh auth login`, so git can use the GitHub credentials.
- AeroSpace allowed under Accessibility (personal and work).
- Karabiner-Elements driver extension and Input Monitoring approved (personal and work).
- SketchyBar allowed to control Things, for the to-do item (personal and work).
- A logout and login done, so settings like key repeat take effect.

---

Ported from a git bare dotfiles repo, archived at https://github.com/andrewsuh98/dotfiles-bare.

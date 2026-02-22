# dotfiles

Personal dotfiles for macOS (Apple Silicon), managed with [chezmoi](https://www.chezmoi.io/).

## Bootstrap

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/andrewsuh98/dotfiles/main/install.sh)"
```

Installs Xcode CLI tools and chezmoi, then bootstraps the full environment with `chezmoi init --apply`.

---

Ported from a git bare dotfiles repo, archived at https://github.com/andrewsuh98/dotfiles-bare.

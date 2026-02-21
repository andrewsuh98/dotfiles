# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **chezmoi** dotfiles repository for macOS (Apple Silicon). It manages configuration for zsh, neovim (LazyVim-based), tmux, kitty/iTerm2, karabiner, oh-my-posh, btop, fastfetch, and various CLI tools.

## Working with Chezmoi

For chezmoi documentation or questions, use Context7 to look up the latest docs.

**Always edit the source files in this repo**, not the target files in `~`. After editing:

```bash
chezmoi diff       # preview what changes would be applied to ~/
chezmoi apply      # apply changes to ~/
```

Other useful commands:

```bash
chezmoi managed    # list all files chezmoi manages
chezmoi unmanaged  # list files in ~/ config dirs that chezmoi does NOT manage
chezmoi add ~/.config/some/file   # start managing a new file
chezmoi edit ~/.config/some/file  # open the source file for a managed target
chezmoi init       # re-run config prompts
chezmoi execute-template < some_file.tmpl  # test template rendering
```

## Repository Structure

- **`dot_*`** files/dirs map to `~/.*` targets (chezmoi naming convention)
- **`private_*`** prefix sets restrictive permissions on the target
- **`.tmpl`** suffix means the file is a Go template, rendered using data from `.chezmoi.toml.tmpl`
- **`.chezmoi.toml.tmpl`** -- config template that prompts for: git name/email, install profile (`full` or `lean`), VM flag, Mac App Store toggle
- **`.chezmoiignore`** -- excludes `install.sh` from being copied to home
- **`.chezmoiscripts/`** -- ordered setup scripts that run during `chezmoi apply`:
  1. `run_once_01-install-homebrew.sh.tmpl` -- installs Homebrew
  2. `run_once_02-install-ohmyzsh.sh.tmpl` -- installs oh-my-zsh
  3. `run_onchange_03-install-packages.sh.tmpl` -- Brewfile (runs on change, not just once)
  4. `run_once_04-configure-macos.sh.tmpl` -- macOS defaults (Finder, Dock, keyboard, trackpad)
  5. `run_once_05-setup-ssh.sh` -- SSH key placeholder

## Template Data

Templates use `.chezmoi.toml` data accessed via Go template syntax (e.g., `{{ .name }}`):

| Variable           | Type   | Purpose                                |
|--------------------|--------|----------------------------------------|
| `.name`            | string | Git user name                          |
| `.email`           | string | Git email                              |
| `.install_profile` | string | `"full"` or `"lean"` package set       |
| `.is_vm`           | bool   | VM mode (uses iTerm2 instead of kitty) |
| `.install_mas`     | bool   | Whether to install Mac App Store apps  |

## Conventions

- Script numbering (`01-`, `02-`, etc.) controls execution order
- `run_once_` scripts execute only on first apply; `run_onchange_` scripts re-run when file content changes
- All scripts are darwin-only (guarded by `{{ if eq .chezmoi.os "darwin" }}`)
- The `install.sh` at the root is a bootstrap script for fresh machines (not managed by chezmoi itself)
- Neovim config under `dot_config/nvim/` follows LazyVim structure: `lua/config/` for core settings, `lua/plugins/` for plugin specs

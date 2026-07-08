# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **chezmoi** dotfiles repository, primarily for macOS (Apple Silicon) with lean headless Linux support. It manages configuration for zsh, neovim (LazyVim-based), tmux, kitty/iTerm2, karabiner, oh-my-posh, btop, fastfetch, and various CLI tools.

Machines are described by a single `role` prompt, which derives a set of capability flags (see Template Data). The four roles are `personal`, `work`, and `vm` (all macOS) plus `server` (headless Linux, auto-selected off macOS).

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
- **`.chezmoi.toml.tmpl`** -- config template that prompts for: git name/email, machine `role` (macOS only), Mac App Store toggle (personal only). Derives the capability flags below.
- **`.chezmoiignore`** -- excludes repo docs (`install.sh`, `CLAUDE.md`, `README.md`), and skips GUI/mac-only configs (aerospace, sketchybar, karabiner, kitty/iterm2) on machines that won't use them
- **`.chezmoiscripts/`** -- ordered setup scripts that run during `chezmoi apply`:
  1. `run_once_01-install-homebrew.sh.tmpl` -- installs Homebrew (macOS + Linux; installs build prereqs on Linux)
  2. `run_once_02-install-ohmyzsh.sh.tmpl` -- installs oh-my-zsh (macOS + Linux)
  3. `run_onchange_03-install-packages.sh.tmpl` -- Brewfile (runs on change, not just once); layered by capability flag
  4. `run_once_04-configure-macos.sh.tmpl` -- macOS defaults (Finder, Dock, keyboard, trackpad); macOS only
  5. `run_once_05-setup-ssh.sh` -- SSH key placeholder

## Template Data

Templates use `.chezmoi.toml` data accessed via Go template syntax (e.g., `{{ .name }}`):

| Variable        | Type   | Purpose                                                             |
|-----------------|--------|---------------------------------------------------------------------|
| `.name`         | string | Git user name                                                       |
| `.email`        | string | Git email                                                           |
| `.role`         | string | `personal`, `work`, `vm` (macOS) or `server` (Linux) -- the source of truth |
| `.gui`          | bool   | Install desktop apps + terminal (derived: role != server)           |
| `.rice`         | bool   | Install window manager / bar / borders / karabiner (derived: personal or work) |
| `.cli_extras`   | bool   | Install extended CLI tools (derived: true)                          |
| `.terminal`     | string | `kitty` (personal/work) or `iterm2` (vm)                            |
| `.is_work`      | bool   | Work machine -- drives aerospace app routing (derived: role == work) |
| `.is_personal`  | bool   | Personal machine -- gates personal-only apps (derived: role == personal) |
| `.install_mas`  | bool   | Install Mac App Store apps (prompted, personal only)                |

Capability flags are derived from `.role` but overridable per machine: add a `[data.overrides]`
table to `~/.config/chezmoi/chezmoi.toml` (e.g. `rice = false`) to pin any of `gui`, `rice`,
`cli_extras`, `terminal`.

## Conventions

- Script numbering (`01-`, `02-`, etc.) controls execution order
- `run_once_` scripts execute only on first apply; `run_onchange_` scripts re-run when file content changes
- Scripts 01/02/03 run on macOS **and** Linux; 04 (macOS defaults) is darwin-only. All are guarded by an `{{ if ... .chezmoi.os ... }}` check
- Package script layers: Core CLI (always) → CLI extras (`cli_extras`) → Rice (`rice`, macOS) → Terminal + Common GUI apps (`gui`, macOS) → Personal apps (`is_personal`) → MAS (`is_personal` && `install_mas`). On Linux only the Core + CLI-extras layers emit
- The `install.sh` at the root is a bootstrap script for fresh machines (not managed by chezmoi itself)
- Neovim config under `dot_config/nvim/` follows LazyVim structure: `lua/config/` for core settings, `lua/plugins/` for plugin specs

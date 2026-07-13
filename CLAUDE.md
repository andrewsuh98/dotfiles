# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **chezmoi** dotfiles repository, primarily for macOS (Apple Silicon) with lean headless Linux support. It manages configuration for zsh, neovim (LazyVim-based), tmux, kitty/iTerm2, karabiner, oh-my-posh, btop, fastfetch, and various CLI tools.

Machines are described by a single `role` prompt, which derives a set of capability flags (see Template Data). The four roles are `personal`, `work`, and `vm` (all macOS) plus `server` (headless Linux, auto-selected off macOS).

## Working with Chezmoi

When chezmoi behavior is uncertain, consult the current official chezmoi documentation.

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
  5. `run_once_05-setup-ssh.sh` -- intentionally empty SSH key placeholder for future setup

## Template Data

Templates use `.chezmoi.toml` data accessed via Go template syntax (e.g., `{{ .name }}`):

| Variable        | Type   | Purpose                                                             |
|-----------------|--------|---------------------------------------------------------------------|
| `.name`         | string | Git user name                                                       |
| `.email`        | string | Git email                                                           |
| `.role`         | string | `personal`, `work`, `vm` (macOS) or `server` (Linux) -- the source of truth |
| `.gui`          | bool   | Install and deploy the selected terminal emulator (derived: role != server) |
| `.rice`         | bool   | Install window manager / bar / borders / karabiner (derived: personal or work) |
| `.cli_extras`   | bool   | Install extended CLI tools (derived: true)                          |
| `.terminal`     | string | Defaults to `kitty` (personal/work) or `iterm2` (vm); overridable per machine |
| `.is_work`      | bool   | Work machine -- drives aerospace app routing (derived: role == work) |
| `.is_personal`  | bool   | Personal machine -- gates personal-only apps (derived: role == personal) |
| `.install_mas`  | bool   | Install Mac App Store apps (prompted, personal only)                |

Capability flags are derived from `.role` but overridable per machine: add a `[data.overrides]`
table to `~/.config/chezmoi/chezmoi.toml` (e.g. `rice = false`) to pin any of `gui`, `rice`,
`cli_extras`, `terminal`.

## Conventions

- Script numbering (`01-`, `02-`, etc.) controls execution order
- `run_once_` scripts run once per rendered-content version; changing their contents can cause them to execute again. `run_onchange_` scripts re-run when their rendered contents change.
- Scripts 01/02/03 run on macOS **and** Linux; 04 (macOS defaults) is darwin-only. Scripts 01-04 are templates guarded by an `{{ if ... .chezmoi.os ... }}` check; the empty SSH placeholder is an unguarded shell script.
- Package script layers: Core CLI (always) → CLI extras (`cli_extras`) → macOS fonts → Rice (`rice`, macOS) → Terminal (`gui`, macOS) → Common GUI apps (`is_personal` or `is_work`) → Personal apps (`is_personal`) → MAS (`is_personal` && `install_mas`). On Linux only the Core + CLI-extras layers emit.
- Homebrew package changes belong in `.chezmoiscripts/run_onchange_03-install-packages.sh.tmpl`. It uses `brew bundle --no-upgrade`, so applying a package-list change installs missing packages without upgrading existing ones.
- JetBrains Mono and its Nerd Font variant are installed for every macOS role because the terminal configurations and SketchyBar depend on them.
- Chrome, Outlook, and Slack are intentionally not installed on work machines; they are expected to be managed externally even though AeroSpace contains routing rules for them.
- The `install.sh` at the root is a bootstrap script for fresh machines (not managed by chezmoi itself)
- Neovim config under `dot_config/nvim/` follows LazyVim structure: `lua/config/` for core settings, `lua/plugins/` for plugin specs

## Validation

After changing templates or managed files:

```bash
chezmoi diff                                      # inspect changes to target files
chezmoi execute-template < path/to/file.tmpl     # test template rendering
git diff --check                                 # catch whitespace errors
```

When changing conditional templates, test the relevant role and capability combinations rather than validating only the current machine's rendered data.

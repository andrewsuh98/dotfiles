#!/bin/sh
set -eu

# ── Xcode Command Line Tools (macOS only) ────
if [ "$(uname)" = "Darwin" ]; then
  if ! xcode-select -p >/dev/null 2>&1; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Waiting for installation to complete..."
    until xcode-select -p >/dev/null 2>&1; do
      sleep 5
    done
  fi
fi

# ── Chezmoi ───────────────────────────────────
if ! command -v chezmoi >/dev/null 2>&1; then
  bin_dir="$HOME/.local/bin"
  if command -v curl >/dev/null 2>&1; then
    sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "$bin_dir"
  elif command -v wget >/dev/null 2>&1; then
    sh -c "$(wget -qO- https://get.chezmoi.io)" -- -b "$bin_dir"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
  chezmoi="$bin_dir/chezmoi"
else
  chezmoi=chezmoi
fi

# On a rerun, init reuses the existing clone without pulling, so update instead
# (--init regenerates the config from the latest template).
if [ -d "$("$chezmoi" source-path)/.git" ]; then
  exec "$chezmoi" update --init
fi
exec "$chezmoi" init --apply andrewsuh98

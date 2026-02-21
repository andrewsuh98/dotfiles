#!/bin/bash
set -euo pipefail

# ── Xcode Command Line Tools ─────────────────
if ! xcode-select -p &>/dev/null; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "Waiting for installation to complete..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
fi

# ── Chezmoi ───────────────────────────────────
if ! command -v chezmoi &>/dev/null; then
  bin_dir="$HOME/.local/bin"
  if command -v curl &>/dev/null; then
    sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "$bin_dir"
  elif command -v wget &>/dev/null; then
    sh -c "$(wget -qO- https://get.chezmoi.io)" -- -b "$bin_dir"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
  chezmoi="$bin_dir/chezmoi"
else
  chezmoi=chezmoi
fi

exec "$chezmoi" init --apply andrewsuh98

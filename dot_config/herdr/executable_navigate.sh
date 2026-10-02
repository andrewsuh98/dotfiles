#!/bin/bash
# Vim-aware pane navigation for herdr, bound to ctrl+h/j/k/l in config.toml.
# Adapted from https://github.com/paulbkim-dev/vim-herdr-navigation (MIT).
#
# If Vim/Neovim or tmux is in the focused pane's foreground, forward the chord
# so it moves between its own splits (Vim also hands back to herdr at an edge).
# Otherwise move herdr's pane focus.
set -euo pipefail

dir="${1:?usage: navigate.sh <left|down|up|right>}"
herdr="${HERDR_BIN_PATH:-herdr}"
pane="${HERDR_ACTIVE_PANE_ID:-}"

case "$dir" in
  left)  key="ctrl+h" ;;
  down)  key="ctrl+j" ;;
  up)    key="ctrl+k" ;;
  right) key="ctrl+l" ;;
  *) echo "navigate.sh: unknown direction: $dir" >&2; exit 2 ;;
esac

# Same process matcher vim-tmux-navigator uses (vi, vim, nvim, view, *diff, ...),
# plus tmux so vim-tmux-navigator keeps working in a tmux session inside herdr
vim_re='^g?(view|l?n?vim?x?)(diff)?$|^tmux'

if [ -z "$pane" ]; then
  exec "$herdr" pane focus --direction "$dir" --current
fi

if "$herdr" pane process-info --pane "$pane" 2>/dev/null \
  | jq -e --arg re "$vim_re" \
      '.result.process_info.foreground_processes[]?.name | ascii_downcase | select(test($re))' \
      >/dev/null 2>&1; then
  exec "$herdr" pane send-keys "$pane" "$key"
fi

exec "$herdr" pane focus --direction "$dir" --pane "$pane"

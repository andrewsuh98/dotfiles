#!/bin/bash
# Focus the dedicated yazi window (bound to alt-f), launching it if none exists.
#
# The window is a separate kitty instance titled "yazi". AeroSpace routes it to
# workspace F by matching that title (see aerospace.toml), so it never lands on
# the terminal workspace T with the regular kitty windows.

AEROSPACE=/opt/homebrew/bin/aerospace

id=$("$AEROSPACE" list-windows --all --format '%{window-id}|%{app-bundle-id}|%{window-title}' \
  | awk -F'|' '$2 == "net.kovidgoyal.kitty" && $3 == "yazi" { print $1; exit }')

if [ -n "$id" ]; then
  "$AEROSPACE" focus --window-id "$id"
else
  # --title pins the window title so AeroSpace can match it.
  # macos_quit_when_last_window_closed lets this instance exit when yazi quits.
  # zsh -lic loads the full shell env (Homebrew PATH, EDITOR) that yazi's
  # previewers and openers rely on.
  open -na kitty --args \
    --title yazi \
    -o macos_quit_when_last_window_closed=yes \
    --directory "$HOME" \
    /bin/zsh -lic 'exec yazi'
fi

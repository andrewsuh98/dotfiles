#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Fast path: workspace switch event provides both variables,
# so we only update the 2 affected spaces instead of all 30.
if [ -n "$FOCUSED_WORKSPACE" ] && [ -n "$PREV_WORKSPACE" ]; then
  # Highlight the newly focused workspace
  sketchybar --set space."$FOCUSED_WORKSPACE" \
    icon.color=$BG \
    background.color=$BLUE \
    background.drawing=on \
    drawing=on

  # Check if the previous workspace still has windows
  PREV_WINDOWS=$(aerospace list-windows --workspace "$PREV_WORKSPACE" 2>/dev/null | head -1)
  if [ -n "$PREV_WINDOWS" ]; then
    sketchybar --set space."$PREV_WORKSPACE" \
      icon.color=$FG \
      background.color=$BG_LIGHT \
      background.drawing=on \
      drawing=on
  else
    sketchybar --set space."$PREV_WORKSPACE" \
      drawing=off
  fi
  exit 0
fi

# Full refresh: runs on initial load (sketchybar --update)
FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null)
OCCUPIED=$(aerospace list-windows --all --format "%{workspace}" 2>/dev/null | sort -u)

WORKSPACES=(1 2 3 4 5 6 7 8 9 A B C D E F G I M N O P Q R S T U V W X Y Z)

for SID in "${WORKSPACES[@]}"; do
  if [ "$SID" = "$FOCUSED" ]; then
    sketchybar --set space."$SID" \
      icon.color=$BG \
      background.color=$BLUE \
      background.drawing=on \
      drawing=on
  elif printf '%s\n' $OCCUPIED | grep -qx "$SID"; then
    sketchybar --set space."$SID" \
      icon.color=$FG \
      background.color=$BG_LIGHT \
      background.drawing=on \
      drawing=on
  else
    sketchybar --set space."$SID" \
      drawing=off
  fi
done

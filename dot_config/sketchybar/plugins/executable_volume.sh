#!/bin/bash

source "$CONFIG_DIR/icons.sh"

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"
else
  VOLUME=$(osascript -e 'output volume of (get volume settings)')
fi

if [ "$VOLUME" -eq 0 ] 2>/dev/null; then
  ICON=$ICON_VOLUME_MUTE
elif [ "$VOLUME" -lt 30 ] 2>/dev/null; then
  ICON=$ICON_VOLUME_LOW
elif [ "$VOLUME" -lt 70 ] 2>/dev/null; then
  ICON=$ICON_VOLUME_MED
else
  ICON=$ICON_VOLUME_HIGH
fi

sketchybar --set "$NAME" icon="$ICON" label="${VOLUME}%"

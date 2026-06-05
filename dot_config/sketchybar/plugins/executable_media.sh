#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

STATE=$(nowplaying-cli get playbackRate 2>/dev/null)
TITLE=$(nowplaying-cli get title 2>/dev/null)
ARTIST=$(nowplaying-cli get artist 2>/dev/null)

if [ -z "$TITLE" ] || [ "$TITLE" = "null" ] || [ "$STATE" = "0" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ -n "$ARTIST" ] && [ "$ARTIST" != "null" ]; then
  LABEL="$ARTIST: $TITLE"
else
  LABEL="$TITLE"
fi

if [ "$STATE" = "0" ]; then
  ICON=$ICON_MEDIA_PAUSE
else
  ICON=$ICON_MEDIA
fi

sketchybar --set "$NAME" drawing=on icon="$ICON" label="$LABEL"

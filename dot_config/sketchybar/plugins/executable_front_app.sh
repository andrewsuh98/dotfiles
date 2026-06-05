#!/bin/bash

source "$CONFIG_DIR/icons.sh"

if [ -z "$INFO" ]; then
  INFO=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
fi

ICON=$(app_icon "$INFO")
sketchybar --set "$NAME" icon="$ICON" label="$INFO"

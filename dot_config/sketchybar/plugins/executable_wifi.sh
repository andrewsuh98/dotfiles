#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

IP=$(ipconfig getifaddr en0 2>/dev/null)

if [ -z "$IP" ]; then
  sketchybar --set "$NAME" icon=$ICON_WIFI_OFF icon.color=$RED label.drawing=off drawing=on
else
  sketchybar --set "$NAME" drawing=off
fi

#!/bin/bash

TODO=$(osascript -e 'tell application "Things3" to get name of first to do of list "Today"' 2>/dev/null)

if [ -z "$TODO" ]; then
  sketchybar --set "$NAME" drawing=off
else
  sketchybar --set "$NAME" drawing=on label="$TODO"
fi

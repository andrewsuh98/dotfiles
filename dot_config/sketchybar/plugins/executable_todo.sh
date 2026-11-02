#!/bin/bash

# Only ask Things when it's already running: a "tell" would launch it. The
# timeout keeps a busy or hung Things from stacking up osascript processes.
if pgrep -xq Things3; then
  TODO=$(osascript -e 'with timeout of 5 seconds
    tell application "Things3" to get name of first to do of list "Today"
  end timeout' 2>/dev/null)
fi

if [ -z "$TODO" ]; then
  sketchybar --set "$NAME" drawing=off
else
  sketchybar --set "$NAME" drawing=on label="$TODO"
fi

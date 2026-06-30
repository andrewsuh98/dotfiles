#!/bin/bash

sketchybar --add item memory right \
           --set memory \
                 icon=$ICON_MEMORY \
                 icon.font="$FONT:Bold:16.0" \
                 icon.color=$YELLOW \
                 label.font="$FONT:SemiBold:13.0" \
                 label.color=$FG \
                 update_freq=10 \
                 script="$PLUGIN_DIR/memory.sh"

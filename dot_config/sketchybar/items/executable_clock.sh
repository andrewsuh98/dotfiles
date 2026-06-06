#!/bin/bash

sketchybar --add item clock right \
           --set clock \
                 icon=$ICON_CLOCK \
                 icon.font="$FONT:Bold:16.0" \
                 icon.color=$BLUE \
                 label.font="$FONT:SemiBold:13.0" \
                 label.color=$FG \
                 update_freq=30 \
                 script="$PLUGIN_DIR/clock.sh"

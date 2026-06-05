#!/bin/bash

sketchybar --add item clock right \
           --set clock \
                 icon=$ICON_CLOCK \
                 icon.font="$FONT:Bold:16.0" \
                 icon.color=$BLUE \
                 label.font="$FONT:SemiBold:13.0" \
                 label.color=$FG \
                 update_freq=30 \
                 script="$PLUGIN_DIR/clock.sh" \
                 click_script="$PLUGIN_DIR/clock_popup.sh"

sketchybar --add item clock.popup popup.clock \
           --set clock.popup \
                 icon.drawing=off \
                 label.font="$FONT:Regular:12.0" \
                 label.color=$FG \
                 background.padding_left=10 \
                 background.padding_right=10

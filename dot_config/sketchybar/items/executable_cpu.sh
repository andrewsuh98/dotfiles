#!/bin/bash

sketchybar --add item cpu right \
           --set cpu \
                 icon=$ICON_CPU \
                 icon.font="$FONT:Bold:16.0" \
                 icon.color=$ORANGE \
                 label.font="$FONT:SemiBold:13.0" \
                 label.color=$FG \
                 update_freq=5 \
                 script="$PLUGIN_DIR/cpu.sh"

#!/bin/bash

sketchybar --add item battery right \
           --set battery \
                 icon=$ICON_BATTERY_100 \
                 icon.font="$FONT:Bold:16.0" \
                 icon.color=$GREEN \
                 label.font="$FONT:SemiBold:13.0" \
                 label.color=$FG \
                 update_freq=120 \
                 script="$PLUGIN_DIR/battery.sh" \
           --subscribe battery power_source_change system_woke

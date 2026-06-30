#!/bin/bash

sketchybar --add item wifi right \
           --set wifi \
                 icon=$ICON_WIFI_OFF \
                 icon.font="$FONT:Bold:16.0" \
                 icon.color=$RED \
                 label.drawing=off \
                 drawing=on \
                 update_freq=10 \
                 script="$PLUGIN_DIR/wifi.sh" \
           --subscribe wifi wifi_change

#!/bin/bash

sketchybar --add item front_app left \
           --set front_app \
                 icon.font="$FONT:Bold:16.0" \
                 icon.color=$CYAN \
                 label.font="$FONT:SemiBold:13.0" \
                 label.color=$FG \
                 icon.padding_left=8 \
                 label.padding_right=8 \
                 script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched

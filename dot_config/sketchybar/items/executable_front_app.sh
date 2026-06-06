#!/bin/bash

sketchybar --add item front_app left \
           --set front_app \
                 label.font="$FONT:SemiBold:13.0" \
                 label.color=$FG \
                 icon.drawing=off \
                 label.padding_left=8 \
                 label.padding_right=8 \
                 script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched aerospace_workspace_change

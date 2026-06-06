#!/bin/bash

sketchybar --add item todo right \
           --set todo \
                 icon=$ICON_TODO \
                 icon.font="$FONT:Bold:16.0" \
                 icon.color=$GREEN \
                 label.font="$FONT:SemiBold:13.0" \
                 label.color=$FG \
                 label.max_chars=30 \
                 update_freq=30 \
                 script="$PLUGIN_DIR/todo.sh"

#!/bin/bash

sketchybar --add item volume right \
           --set volume \
                 icon=$ICON_VOLUME_HIGH \
                 icon.font="$FONT:Bold:16.0" \
                 icon.color=$MAGENTA \
                 label.font="$FONT:SemiBold:13.0" \
                 label.color=$FG \
                 script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume volume_change

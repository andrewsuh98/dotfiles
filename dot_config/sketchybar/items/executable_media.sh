#!/bin/bash

sketchybar --add item media center \
           --set media \
                 icon=$ICON_MEDIA \
                 icon.font="$FONT:Bold:16.0" \
                 icon.color=$CYAN \
                 icon.padding_left=8 \
                 label.font="$FONT:Regular:13.0" \
                 label.color=$FG \
                 label.max_chars=40 \
                 label.padding_right=8 \
                 drawing=off \
                 update_freq=5 \
                 script="$PLUGIN_DIR/media.sh" \
           --subscribe media media_change

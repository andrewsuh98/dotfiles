#!/bin/bash

sketchybar --add event aerospace_workspace_change

WORKSPACES=(1 2 3 4 5 6 7 8 9 A B C D E F G I M N O P Q R S T U V W X Y Z)

for SID in "${WORKSPACES[@]}"; do
  sketchybar --add item space."$SID" left \
             --set space."$SID" \
                   icon="$SID" \
                   icon.font="$FONT:Bold:13.0" \
                   icon.padding_left=8 \
                   icon.padding_right=8 \
                   icon.color=$FG_DIM \
                   label.drawing=off \
                   background.color=$TRANSPARENT \
                   background.corner_radius=3 \
                   background.height=24 \
                   background.drawing=off \
                   click_script="aerospace workspace $SID"
done

sketchybar --add item space_updater left \
           --set space_updater \
                 drawing=off \
                 script="$PLUGIN_DIR/aerospace.sh" \
           --subscribe space_updater aerospace_workspace_change

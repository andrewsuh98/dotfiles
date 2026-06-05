#!/bin/bash

DRAWING=$(sketchybar --query clock | jq -r '.popup.drawing')

if [ "$DRAWING" = "on" ]; then
  sketchybar --set clock popup.drawing=off
else
  CAL=$(cal)
  sketchybar --set clock.popup label="$CAL"
  sketchybar --set clock popup.drawing=on
fi

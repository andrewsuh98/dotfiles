#!/bin/bash

if [ -z "$INFO" ]; then
  INFO=$(aerospace list-windows --focused --format "%{app-name}" 2>/dev/null)
fi

sketchybar --set "$NAME" label="$INFO"

#!/bin/bash

CORES=$(sysctl -n hw.logicalcpu)
CPU=$(ps -A -o %cpu | awk -v cores="$CORES" '{s+=$1} END {printf "%.0f", s/cores}')
sketchybar --set "$NAME" label="${CPU}%"

#!/bin/bash

MEMORY_PRESSURE=$(memory_pressure 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')

if [ -n "$MEMORY_PRESSURE" ]; then
  USED=$((100 - MEMORY_PRESSURE))
  sketchybar --set "$NAME" label="${USED}%"
else
  read PAGES_FREE PAGES_INACTIVE PAGES_SPECULATIVE <<< "$(vm_stat | awk '
    /Pages free/        {gsub(/\./, "", $3); free=$3}
    /Pages inactive/    {gsub(/\./, "", $3); inact=$3}
    /Pages speculative/ {gsub(/\./, "", $3); spec=$3}
    END {print free, inact, spec}
  ')"
  TOTAL=$(sysctl -n hw.memsize)
  FREE_BYTES=$(( (PAGES_FREE + PAGES_INACTIVE + PAGES_SPECULATIVE) * 4096 ))
  USED_PERCENT=$(( 100 - (FREE_BYTES * 100 / TOTAL) ))
  sketchybar --set "$NAME" label="${USED_PERCENT}%"
fi

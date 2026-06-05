#!/bin/bash

MEMORY_PRESSURE=$(memory_pressure 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')

if [ -n "$MEMORY_PRESSURE" ]; then
  USED=$((100 - MEMORY_PRESSURE))
  sketchybar --set "$NAME" label="${USED}%"
else
  PAGES_FREE=$(vm_stat | awk '/Pages free/ {gsub(/\./, "", $3); print $3}')
  PAGES_INACTIVE=$(vm_stat | awk '/Pages inactive/ {gsub(/\./, "", $3); print $3}')
  PAGES_SPECULATIVE=$(vm_stat | awk '/Pages speculative/ {gsub(/\./, "", $3); print $3}')
  TOTAL=$(sysctl -n hw.memsize)
  FREE_BYTES=$(( (PAGES_FREE + PAGES_INACTIVE + PAGES_SPECULATIVE) * 4096 ))
  USED_PERCENT=$(( 100 - (FREE_BYTES * 100 / TOTAL) ))
  sketchybar --set "$NAME" label="${USED_PERCENT}%"
fi

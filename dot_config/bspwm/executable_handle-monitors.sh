#!/bin/bash

# Configuration
PREFERRED_RESOLUTION="2560x1440"
PREFERRED_RATE="144.00"
LOG_DIR="$HOME/.log"
LOG_FILE="$LOG_DIR/monitor_switch.log"
STATE_FILE="$LOG_DIR/monitor_mode.state"

mkdir -p "$LOG_DIR"

# Detect monitors
INTERNAL_MONITOR=$(xrandr | awk '/ connected/{print $1}' | grep -E "^(eDP|LVDS)" | head -n 1)
IS_LAPTOP=false

if [ -n "$INTERNAL_MONITOR" ]; then
  IS_LAPTOP=true
else
  INTERNAL_MONITOR=$(xrandr | awk '/ connected/{print $1}' | head -n 1)
fi

CONNECTED_MONITORS=($(xrandr | awk '/ connected/{print $1}'))
MONITOR_COUNT=${#CONNECTED_MONITORS[@]}

echo "$(date '+%Y-%m-%d %H:%M:%S') - Internal monitor: $INTERNAL_MONITOR (laptop: $IS_LAPTOP)" >> "$LOG_FILE"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Connected monitors: ${CONNECTED_MONITORS[*]}" >> "$LOG_FILE"

MODE="unknown"

if [ "$MONITOR_COUNT" -eq 1 ]; then
  MODE="single"
else
  MODE="multi"
fi

if $IS_LAPTOP && [ "$MODE" = "single" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Laptop with internal screen only. Switching to laptop mode." >> "$LOG_FILE"
  xrandr --output "$INTERNAL_MONITOR" --auto --primary

  bspc config top_padding 20
  bspc monitor "$INTERNAL_MONITOR" -d terminal chrome chat camera

  ~/.config/polybar/launch.sh "$INTERNAL_MONITOR"

elif $IS_LAPTOP && [ "$MODE" = "multi" ]; then
  EXTERNAL_MONITOR=$(xrandr | awk '/ connected/{print $1}' | grep -v "^$INTERNAL_MONITOR" | head -n 1)
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Laptop docked with external monitor: $EXTERNAL_MONITOR. Switching to docked mode." >> "$LOG_FILE"

  xrandr --output "$INTERNAL_MONITOR" --auto \
         --output "$EXTERNAL_MONITOR" --mode "$PREFERRED_RESOLUTION" --rate "$PREFERRED_RATE" --right-of "$INTERNAL_MONITOR" --primary

  bspc config top_padding 40
  bspc monitor "$INTERNAL_MONITOR" -d chat camera
  bspc monitor "$EXTERNAL_MONITOR" -d terminal chrome

  ~/.config/polybar/launch.sh "$EXTERNAL_MONITOR"

elif ! $IS_LAPTOP && [ "$MODE" = "multi" ]; then
  PRIMARY_MONITOR="${CONNECTED_MONITORS[0]}"
  SECONDARY_MONITOR="${CONNECTED_MONITORS[1]}"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Desktop with dual monitors: $PRIMARY_MONITOR + $SECONDARY_MONITOR" >> "$LOG_FILE"

  xrandr --output "$PRIMARY_MONITOR" --mode "$PREFERRED_RESOLUTION" --rate "$PREFERRED_RATE" --primary \
         --output "$SECONDARY_MONITOR" --auto --right-of "$PRIMARY_MONITOR"

  bspc config top_padding 40
  bspc monitor "$PRIMARY_MONITOR" -d terminal chrome
  bspc monitor "$SECONDARY_MONITOR" -d chat camera

  ~/.config/polybar/launch.sh "$PRIMARY_MONITOR"

else
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Desktop with one monitor: $INTERNAL_MONITOR" >> "$LOG_FILE"
  xrandr --output "$INTERNAL_MONITOR" --auto --primary

  bspc config top_padding 20
  bspc monitor "$INTERNAL_MONITOR" -d terminal chrome chat camera

  ~/.config/polybar/launch.sh "$INTERNAL_MONITOR"
fi

echo "$MODE" > "$STATE_FILE"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Switched to $MODE mode. Cleaning up." >> "$LOG_FILE"
exit 0

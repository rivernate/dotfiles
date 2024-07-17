#!/bin/bash

# Detect internal monitor
INTERNAL_MONITOR=$(xrandr | grep " connected" | grep -E "eDP|eDP-1" | cut -d' ' -f1)

# Detect external monitor
EXTERNAL_MONITOR=$(xrandr | grep " connected" | grep -v "$INTERNAL_MONITOR" | cut -d' ' -f1)

# Configure monitors
if [ -n "$EXTERNAL_MONITOR" ]; then
  # External monitor is connected
  xrandr --output $INTERNAL_MONITOR --auto --output $EXTERNAL_MONITOR --auto --right-of $INTERNAL_MONITOR --primary
  bspc monitor $INTERNAL_MONITOR -d chat camera
  bspc monitor $EXTERNAL_MONITOR -d terminal chrome
else
  # Only internal monitor is connected
  xrandr --output $INTERNAL_MONITOR --auto
  bspc monitor $INTERNAL_MONITOR -d chat camera terminal chrome
fi

# Launch polybar
~/.config/polybar/launch.sh

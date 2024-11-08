#!/bin/bash

# Preferred DisplayPort and configuration
PREFERRED_PORT="DisplayPort-10"
PREFERRED_RESOLUTION="3840x2160"
PREFERRED_RATE="60.00"

# Initialize flag for configuration mode
MODE=""

# Function to configure monitors and Polybar
configure_monitors() {
  # Detect internal monitor
  INTERNAL_MONITOR=$(xrandr | awk '/ connected/{print $1}' | grep -E "^eDP|^LVDS")

  # Detect external monitor (prefer the preferred port)
  EXTERNAL_MONITOR=$(xrandr | awk '/ connected/{print $1}' | grep "$PREFERRED_PORT")

  # If preferred port is not connected, check for any other external monitor
  if [ -z "$EXTERNAL_MONITOR" ]; then
    EXTERNAL_MONITOR=$(xrandr | awk '/ connected/{print $1}' | grep -v "^$INTERNAL_MONITOR" | head -n 1)
  fi

  if [ -n "$EXTERNAL_MONITOR" ] && xrandr | grep "^$EXTERNAL_MONITOR connected" &> /dev/null; then
    # External monitor is connected
    if [ "$MODE" != "docked" ]; then
      xrandr --output "$INTERNAL_MONITOR" --auto \
             --output "$EXTERNAL_MONITOR" --mode "$PREFERRED_RESOLUTION" --rate "$PREFERRED_RATE" --right-of "$INTERNAL_MONITOR" --primary

      # Set top padding and assign workspaces for docked mode
      bspc config top_padding 40
      bspc monitor "$INTERNAL_MONITOR" -d chat camera
      bspc monitor "$EXTERNAL_MONITOR" -d terminal chrome

      # Restart Polybar with docked configuration
      ~/.config/polybar/launch.sh docked

      # Update mode
      MODE="docked"
      echo "Switched to docked mode."
    fi
  else
    # Only internal monitor is connected
    if [ "$MODE" != "laptop" ]; then
      xrandr --output "$INTERNAL_MONITOR" --auto --primary
      xrandr --output "$EXTERNAL_MONITOR" --off

      # Set top padding and assign workspaces for laptop mode
      bspc config top_padding 20
      bspc monitor "$INTERNAL_MONITOR" -d terminal chrome chat camera

      # Restart Polybar with laptop configuration
      ~/.config/polybar/launch.sh laptop

      # Update mode
      MODE="laptop"
      echo "Switched to laptop mode."
    fi
  fi
}

# Ensure background loop exits cleanly on script termination
trap "cleanup" INT TERM EXIT

cleanup() {
  echo "Cleaning up and exiting..."
  exit 0
}

# Initial configuration
configure_monitors

# Persistent check for monitor changes every 5 seconds
while true; do
  CURRENT_EXTERNAL=$(xrandr | awk '/ connected/{print $1}' | grep "$PREFERRED_PORT")
  if [ -z "$CURRENT_EXTERNAL" ]; then
    CURRENT_EXTERNAL=$(xrandr | awk '/ connected/{print $1}' | grep -v "^$INTERNAL_MONITOR" | head -n 1)
  fi

  if [ -n "$CURRENT_EXTERNAL" ] && [ "$MODE" != "docked" ]; then
    configure_monitors
  elif [ -z "$CURRENT_EXTERNAL" ] && [ "$MODE" != "laptop" ]; then
    configure_monitors
  fi
  sleep 5
done

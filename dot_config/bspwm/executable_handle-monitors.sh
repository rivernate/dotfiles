#!/bin/bash

# Function to configure monitors and Polybar
configure_monitors() {
  # Detect internal monitor
  INTERNAL_MONITOR=$(xrandr | grep " connected" | grep -E "eDP|eDP-1" | cut -d' ' -f1)

  # Detect external monitor
  EXTERNAL_MONITOR=$(xrandr | grep " connected" | grep -v "$INTERNAL_MONITOR" | cut -d' ' -f1)

  if [ -n "$EXTERNAL_MONITOR" ]; then
    # External monitor is connected
    xrandr --output $INTERNAL_MONITOR --auto --output $EXTERNAL_MONITOR --auto --right-of $INTERNAL_MONITOR --primary

    # Set top padding and assign workspaces for docked mode
    bspc config top_padding 40
    bspc monitor $INTERNAL_MONITOR -d chat camera
    bspc monitor $EXTERNAL_MONITOR -d terminal chrome

    # Restart Polybar with docked configuration
    ~/.config/polybar/launch.sh docked
  else
    # Only internal monitor is connected
    xrandr --output $INTERNAL_MONITOR --auto

    # Set top padding and assign workspaces for laptop mode
    bspc config top_padding 20
    bspc monitor $INTERNAL_MONITOR -d terminal chrome chat camera

    # Restart Polybar with laptop configuration
    ~/.config/polybar/launch.sh laptop
  fi
}

# Initial configuration
configure_monitors

# Listen for monitor changes and reconfigure when a change is detected
bspc subscribe monitor | while read -r _; do
  configure_monitors
done

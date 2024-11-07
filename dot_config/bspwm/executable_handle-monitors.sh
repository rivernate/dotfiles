#!/bin/bash

# Preferred DisplayPort and configuration
PREFERRED_PORT="DisplayPort-10"
PREFERRED_RESOLUTION="3840x2160"
PREFERRED_RATE="60.00"

# Function to configure monitors and Polybar
configure_monitors() {
  # Detect internal monitor
  INTERNAL_MONITOR=$(xrandr | grep " connected" | grep -E "eDP|eDP-1" | cut -d' ' -f1)

  # Detect external monitor (prefer the preferred port)
  EXTERNAL_MONITOR=$(xrandr | grep "$PREFERRED_PORT connected" | cut -d' ' -f1)

  if [ -n "$EXTERNAL_MONITOR" ]; then
    # External monitor is connected on preferred port
    xrandr --output $INTERNAL_MONITOR --auto \
           --output $EXTERNAL_MONITOR --mode $PREFERRED_RESOLUTION --rate $PREFERRED_RATE --right-of $INTERNAL_MONITOR --primary

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

# Persistent check for preferred DisplayPort every 5 seconds
while true; do
  xrandr | grep "$PREFERRED_PORT connected" &> /dev/null
  if [ $? -eq 0 ]; then
    # If the preferred port is connected, ensure configuration
    configure_monitors
  else
    echo "Preferred DisplayPort ($PREFERRED_PORT) disconnected. Waiting for reconnection..."
  fi
  sleep 5
done &

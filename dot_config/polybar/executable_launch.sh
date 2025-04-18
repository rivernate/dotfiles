#!/usr/bin/env bash
export FC_DEBUG=0
export PRIMARY_MONITOR=$(xrandr -q | grep primary | awk '{print $1;}')
export SECONDARY_MONITOR=$(xrandr -q | grep " connected" | grep -v "$PRIMARY_MONITOR" | awk '{print $1;}')

echo "Primary monitor: $PRIMARY_MONITOR"

# Terminate already running polybar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Determine the Polybar configuration based on the monitor setup
if [ "$1" == "docked" ]; then
  echo "Launching Polybar for docked mode"
  polybar main &
  polybar secondary & # Adjust this line if you want another bar for docked mode
elif [ "$1" == "laptop" ]; then
  echo "Launching Polybar for laptop mode"
  polybar main &
else
    echo "Fallback to one monitor"
    polybar main &
fi

# Set a random wallpaper
feh --bg-fill --randomize ~/.wallpaper/*

#!/bin/bash

# Preferred DisplayPort and configuration
PREFERRED_PORT="DisplayPort-10"
PREFERRED_RESOLUTION="3840x2160"
PREFERRED_RATE="60.00"

# Log file location
LOG_DIR="$HOME/.log"
LOG_FILE="$LOG_DIR/monitor_switch.log"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

# Initialize flag for configuration mode
MODE=""

# Function to configure monitors and Polybar
configure_monitors() {
  # Log the time of execution
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Running configure_monitors" >> "$LOG_FILE"

  # Detect internal monitor
  INTERNAL_MONITOR=$(xrandr | awk '/ connected/{print $1}' | grep -E "^eDP|^LVDS")
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Detected internal monitor: $INTERNAL_MONITOR" >> "$LOG_FILE"


  # Detect external monitor (prefer the preferred port)
  EXTERNAL_MONITOR=$(xrandr | awk '/ connected/{print $1}' | grep "$PREFERRED_PORT")
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Detected preferred external monitor: $EXTERNAL_MONITOR" >> "$LOG_FILE"


  # If preferred port is not connected, check for any other external monitor
  if [ -z "$EXTERNAL_MONITOR" ]; then
    EXTERNAL_MONITOR=$(xrandr | awk '/ connected/{print $1}' | grep -v "^$INTERNAL_MONITOR" | grep -v "disconnected" | head -n 1)
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Fallback external monitor: $EXTERNAL_MONITOR" >> "$LOG_FILE"
  fi

  if [ -n "$EXTERNAL_MONITOR" ]; then
    # External monitor is connected
    echo "$(date '+%Y-%m-%d %H:%M:%S') - External monitor connected: $EXTERNAL_MONITOR" >> "$LOG_FILE"
    if [ "$MODE" != "docked" ]; then
       echo "$(date '+%Y-%m-%d %H:%M:%S') - Switching to docked mode." >> "$LOG_FILE"
      {
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
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Switched to docked mode."
      } >> "$LOG_FILE" 2>&1
    fi
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - No external monitor connected." >> "$LOG_FILE"
    # Only internal monitor is connected
    if [ "$MODE" != "laptop" ]; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') - Switching to laptop mode." >> "$LOG_FILE"
      {
        xrandr --output "$INTERNAL_MONITOR" --auto --primary

        # Turn off all disconnected monitors
        DISCONNECTED_MONITORS=$(xrandr | awk '/disconnected/ {print $1}')
        for MONITOR in $DISCONNECTED_MONITORS; do
          echo "$(date '+%Y-%m-%d %H:%M:%S') - Turning off disconnected monitor: $MONITOR" >> "$LOG_FILE"
          xrandr --output "$MONITOR" --off
        done

        # Set top padding and assign workspaces for laptop mode
        bspc config top_padding 20
        bspc monitor "$INTERNAL_MONITOR" -d terminal chrome chat camera

        # Restart Polybar with laptop configuration
        ~/.config/polybar/launch.sh laptop

        # Update mode
        MODE="laptop"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Switched to laptop mode."
      } >> "$LOG_FILE" 2>&1
    fi
  fi
}

# Ensure background loop exits cleanly on script termination
cleanup() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Cleaning up and exiting..." >> "$LOG_FILE"
  exit 0
}
trap "cleanup" INT TERM EXIT

# Initial configuration
configure_monitors

# Persistent check for monitor changes every 5 seconds
while true; do
  # Update internal monitor inside the loop
  INTERNAL_MONITOR=$(xrandr | awk '/ connected/{print $1}' | grep -E "^eDP|^LVDS")

  # Detect current external monitor
  CURRENT_EXTERNAL=$(xrandr | awk '/ connected /{print $1}' | grep "$PREFERRED_PORT")
  if [ -z "$CURRENT_EXTERNAL" ]; then
    CURRENT_EXTERNAL=$(xrandr | awk '/ connected /{print $1}' | grep -v "disconnected" | grep -v "^$INTERNAL_MONITOR" | head -n 1)
  fi

  # Determine if reconfiguration is needed
  if [ -n "$CURRENT_EXTERNAL" ] && [ "$MODE" != "docked" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - External monitor detected. Switching to docked mode." >> "$LOG_FILE"
    configure_monitors
  elif [ -z "$CURRENT_EXTERNAL" ] && [ "$MODE" != "laptop" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - No external monitor detected. Switching to laptop mode." >> "$LOG_FILE"
    configure_monitors
  fi

  sleep 5
done

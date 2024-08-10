#!/usr/bin/env bash
export FC_DEBUG=0
export PRIMARY_MONITOR=$(xrandr -q | grep primary | awk '{print $1;}')

# Terminate already running polybar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch polybar
if [ $PRIMARY_MONITOR == "eDP1" ] || [ $PRIMARY_MONITOR == "eDP" ] || [ $PRIMARY_MONITOR == "eDP-1" ];
then
  echo Laptop primary
else
  echo "Laptop not primary"
  polybar laptop &
fi

echo $PRIMARY_MONITOR
polybar main &
feh --bg-center --randomize ~/.wallpaper/*

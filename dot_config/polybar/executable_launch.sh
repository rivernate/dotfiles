#!/usr/bin/env bash
export FC_DEBUG=0
export PRIMARY_MONITOR=$(xrandr -q | grep primary | awk '{print $1;}')
if [ $PRIMARY_MONITOR == "eDP1" ] || [ $PRIMARY_MONITOR == "eDP" ]
then
  echo Laptop primary
else
  echo Laptop not Primary
  polybar laptop &
fi
echo $PRIMARY_MONITOR
polybar main &
feh --bg-center --randomize ~/.wallpaper/*

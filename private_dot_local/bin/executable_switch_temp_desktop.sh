#!/bin/bash

# Store original input for error messages
KEY=$2

# Get the action (focus or move) from the second argument
ACTION=$1

# Debug output
#notify-send "Debug" "Key: $KEY, Action: $ACTION" -t 2000

# Convert input number (5-9,0) to desktop number (0-5) and corresponding temp number (1-6)
case "$KEY" in
    5) N=0; TEMP_NUM=1 ;;  # super + 5 -> temp_1
    6) N=1; TEMP_NUM=2 ;;  # super + 6 -> temp_2
    7) N=2; TEMP_NUM=3 ;;  # super + 7 -> temp_3
    8) N=3; TEMP_NUM=4 ;;  # super + 8 -> temp_4
    9) N=4; TEMP_NUM=5 ;;  # super + 9 -> temp_5
    0) N=5; TEMP_NUM=6 ;;  # super + 0 -> temp_6
    *) N=$KEY; TEMP_NUM=$KEY ;;
esac

# List all temp desktops and get the Nth one
TEMP_DESKTOPS=($(bspc query -D --names | grep '^temp_' | sort -V))
if [ "$N" -lt ${#TEMP_DESKTOPS[@]} ]; then
    D="${TEMP_DESKTOPS[$N]}"
    if [ "$ACTION" = "move" ]; then
        # Check if there's a focused window to move
        FOCUSED_NODE=$(bspc query -N -n focused)
        if [ ! -z "$FOCUSED_NODE" ]; then
            bspc node "$FOCUSED_NODE" -d "$D"
        else
            notify-send "Error" "No window to move" -t 2000
        fi
    else
        bspc desktop -f "$D"
    fi
else
    notify-send "Error" "No temporary desktop temp_$TEMP_NUM exists" -t 2000
fi

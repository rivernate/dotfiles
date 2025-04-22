#!/usr/bin/env bash
set -euo pipefail

export FC_DEBUG=0

# Get monitor info
xrandr_output=$(xrandr -q)
readarray -t CONNECTED_MONITORS < <(echo "$xrandr_output" | awk '/ connected/ {print $1}')
PRIMARY_MONITOR=$(echo "$xrandr_output" | awk '/ primary/ {print $1; exit}')
export PRIMARY_MONITOR

SECONDARY_MONITORS=()
for mon in "${CONNECTED_MONITORS[@]}"; do
  if [[ "$mon" != "$PRIMARY_MONITOR" ]]; then
    SECONDARY_MONITORS+=("$mon")
  fi
done

echo "Primary monitor: $PRIMARY_MONITOR"
echo "Secondary monitors: ${SECONDARY_MONITORS[*]:-None}"

# Kill previous polybar
killall -q polybar || true
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.5; done

# Launch bars
MONITOR="$PRIMARY_MONITOR" polybar --reload main &

for mon in "${SECONDARY_MONITORS[@]}"; do
  MONITOR="$mon" polybar --reload secondary &
done

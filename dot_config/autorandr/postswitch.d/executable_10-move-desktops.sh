#!/usr/bin/env bash
set -euo pipefail

echo "Current desktops: $(bspc query -D --names | xargs)"

# Get monitors
PRIMARY_MONITOR=$(xrandr --listmonitors | awk '/\*/ {print $NF}')
mapfile -t ALL_MONITORS < <(bspc query -M --names)

SECONDARY_MONITOR=""
for m in "${ALL_MONITORS[@]}"; do
  if [[ "$m" != "$PRIMARY_MONITOR" ]]; then
    SECONDARY_MONITOR="$m"
    break
  fi
done

echo "Primary:   $PRIMARY_MONITOR"
echo "Secondary: $SECONDARY_MONITOR"

# Desktop assignments
PRIMARY_DESKTOPS=(terminal chrome)
SECONDARY_DESKTOPS=(chat camera)

create_and_move_desktop() {
  local desktop=$1
  local target_monitor=$2
  if bspc query -D --names | grep -qx "$desktop"; then
    echo "→ Moving '$desktop' to '$target_monitor'"
    bspc desktop "$desktop" -m "$target_monitor" || echo "⚠️  Could not move '$desktop'"
  else
    echo "➕ Creating '$desktop' on '$target_monitor'"
    bspc monitor "$target_monitor" -a "$desktop" || echo "⚠️  Could not create '$desktop'"
  fi
}

# Move primary
for d in "${PRIMARY_DESKTOPS[@]}"; do
  create_and_move_desktop "$d" "$PRIMARY_MONITOR"
done

# Move secondary — this was probably missing in your current version
for d in "${SECONDARY_DESKTOPS[@]}"; do
  create_and_move_desktop "$d" "$SECONDARY_MONITOR"
done

# Remove unamed desktops
for d in $(bspc query -D --names | grep -Fx Desktop); do
  echo "🗑️  Removing unnamed desktop: $d"
  bspc desktop "$d" -r
done

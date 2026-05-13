#!/bin/bash

MONITOR="eDP-1"
RES="1920x1080"

# Get current refresh rate (rounded to nearest integer)
CURRENT_RATE=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$MONITOR\") | .refreshRate | floor")

if [ "$CURRENT_RATE" -ge 140 ]; then
  hyprctl eval "hl.monitor({ output = '$MONITOR', mode = '${RES}@60', position = 'auto', scale = 1 })"
  notify-send -e \
    -h string:x-canonical-private-synchronous:refresh_notif \
    -u low \
    -a "refresh-script" \
    -t 3500 \
    "Display" "Switched to 60Hz (Battery Saver)"
else
  hyprctl eval "hl.monitor({ output = '$MONITOR', mode = '${RES}@144', position = 'auto', scale = 1 })"
  notify-send -e \
    -h string:x-canonical-private-synchronous:refresh_notif \
    -u low \
    -a "refresh-script" \
    -t 3500 \
    "Display" "Switched to 144Hz (High Performance)"
fi

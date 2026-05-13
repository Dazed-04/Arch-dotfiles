#!/bin/bash
# Script for changing blurs on the fly with persistence

notif="$HOME/.config/swaync/images/bell.png"
PERSIST_FILE="$HOME/.config/hypr/scripts/blur_state"

# Determine current state based on the file existence rather than hyprctl
if [ -f "$PERSIST_FILE" ]; then
  # Switch to NORMAL blur
  hyprctl eval "hl.config({ decoration = { blur = { size = 5, passes = 2 } } })"
  hyprctl dispatch "hl.dsp.exec_raw('forcerendererreload')"
  rm "$PERSIST_FILE"
  notify-send -e -u low -i "$notif" "Normal blur"
else
  # Switch to LESS blur
  hyprctl eval "hl.config({ decoration = { blur = { size = 2, passes = 1 } } })"
  hyprctl dispatch "hl.dsp.exec_raw('forcerendererreload')"
  touch "$PERSIST_FILE"
  notify-send -e -u low -i "$notif" "Less blur"
fi

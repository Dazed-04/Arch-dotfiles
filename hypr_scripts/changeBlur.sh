#!/bin/bash
# Script for changing blurs on the fly with persistence

notif="$HOME/.config/swaync/images/bell.png"
PERSIST_FILE="$HOME/.config/hypr/scripts/blur_state"

# Determine current state based on the file existence rather than hyprctl
if [ -f "$PERSIST_FILE" ]; then
  # Switch to NORMAL blur
  hyprctl keyword decoration:blur:size 5
  hyprctl keyword decoration:blur:passes 2
  rm "$PERSIST_FILE"
  notify-send -e -u low -i "$notif" "Normal blur"
else
  # Switch to LESS blur
  hyprctl keyword decoration:blur:size 2
  hyprctl keyword decoration:blur:passes 1
  touch "$PERSIST_FILE"
  notify-send -e -u low -i "$notif" "Less blur"
fi

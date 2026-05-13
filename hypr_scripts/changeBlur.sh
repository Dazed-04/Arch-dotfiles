#!/bin/bash
notif="$HOME/.config/swaync/images/bell.png"
PERSIST_FILE="$HOME/.config/hypr/scripts/term_blur_state"

if [ -f "$PERSIST_FILE" ]; then
  hyprctl eval "hl.config({ decoration = { blur = { enabled = true } } })"
  sleep 0.1
  hyprctl dispatch 'hl.dsp.exec_raw("forcerendererreload")'
  rm "$PERSIST_FILE"
  notify-send -e -u low -i "$notif" "Blur on"
else
  hyprctl eval "hl.config({ decoration = { blur = { enabled = false } } })"
  touch "$PERSIST_FILE"
  notify-send -e -u low -i "$notif" "Blur off"
fi

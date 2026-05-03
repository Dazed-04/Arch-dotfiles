#!/usr/bin/env bash

iDIR="$HOME/.config/swaync/icons"

if pgrep seanime >/dev/null; then
  pkill seanime
  notify-send -e -u low -i "$iDIR/seanime-off.png" "Seanime Stopped"
else
  seanime &
  notify-send -e -u low -i "$iDIR/seanime-on.png" "Seanime Started"
fi

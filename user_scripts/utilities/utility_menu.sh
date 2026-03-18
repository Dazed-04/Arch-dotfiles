#!/bin/bash
if pgrep -x rofi >/dev/null; then
  pkill -x rofi
  exit 0
fi

rofi \
  -show Network \
  -theme "$HOME/.config/rofi/launcher-themes/utility-menu.rasi"

#!/bin/bash
if pgrep -x rofi >/dev/null; then
  pkill -x rofi
  exit 0
fi

rofimoji --selector-args="-theme $HOME/.config/rofi/launcher-themes/emoji-picker.rasi"

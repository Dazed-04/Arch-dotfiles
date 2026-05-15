#!/bin/bash
if pgrep -x rofi >/dev/null; then
  pkill -x rofi
  exit 0
fi

OBS_PASS=$(cat "${HOME}/.config/hypr/.obs-secret" | tr -d '[:space:]')

START_MODI="Network"
if pgrep -x obs >/dev/null; then
  rec_status=$(obs-cmd --websocket "obsws://localhost:4455/${OBS_PASS}" recording status 2>/dev/null)
  if echo "$rec_status" | grep -q "active\|true\|recording"; then
    START_MODI="Media"
  fi
fi

rofi \
  -show "$START_MODI" \
  -theme "$HOME/.config/rofi/launcher-themes/utility-menu.rasi"

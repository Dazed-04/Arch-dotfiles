#!/usr/bin/env bash
# toggle-qbit.sh
iDIR="$HOME/.config/swaync/icons"

if pgrep qbittorrent-nox >/dev/null; then
  pkill qbittorrent-nox
  notify-send -e -u low -i "$iDIR/qbittorrent-off.png" "Torrent Stopped"
else
  qbittorrent-nox &
  notify-send -e -u low -i "$iDIR/qbittorrent-on.png" "Torrent Started"
fi

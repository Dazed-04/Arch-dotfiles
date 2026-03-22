#!/usr/bin/env bash
# toggle-qbit.sh
if pgrep qbittorrent-nox >/dev/null; then
  pkill qbittorrent-nox
else
  qbittorrent-nox &
fi

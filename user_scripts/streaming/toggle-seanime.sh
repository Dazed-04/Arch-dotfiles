#!/usr/bin/env bash
# toggle-seanime.sh
if pgrep seanime >/dev/null; then
  pkill seanime
else
  seanime &
fi

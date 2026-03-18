#!/bin/bash

title=$(mpc current -f "%title%")
artist=$(mpc current -f "%artist%")

status=$(mpc status | awk 'NR==2 {print $1}')

if [ "$status" == "[paused]" ]; then
  icon="[Paused]"
else
  icon="[Playing]"
fi

case "$1" in
--title)
  echo "$title"
  ;;
--artist)
  echo "$artist"
  ;;
--status)
  echo "$icon"
  ;;
esac

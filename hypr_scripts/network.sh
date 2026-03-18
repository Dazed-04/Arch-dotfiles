#!/bin/bash
status="$(nmcli general status | grep -oh "\w*connect\w*")"

if [[ "$status" = "disconnected" ]]; then
  printf "Disconnected 󰤮⠀"
elif [[ "$status" = "connecting" ]]; then
  printf "Connecting 󱍸⠀"
elif [[ "$status" = "connected" ]]; then
  wow="$(nmcli con show --active | awk 'NR==2 {print $5}')"
  if [[ "$wow" = "ethernet" ]]; then
    printf "󰈀⠀\n"
  else
    if [[ -f /proc/net/wireless ]]; then
      if strength=$(awk 'NR==3 {print $3}' /proc/net/wireless | sed 's/\.//g'); then
        if [ "$strength" -eq 0 ]; then
          printf "󰤯⠀\n"
        elif [ "$strength" -le 25 ]; then
          printf "󰤟⠀\n"
        elif [ "$strength" -le 50 ]; then
          printf "󰤢⠀\n"
        elif [ "$strength" -le 75 ]; then
          printf "󰤥⠀\n"
        else
          printf "󰤨⠀\n"
        fi
      else
        printf "Error reading strength\n"
      fi
    else
      printf "Wi-Fi not detected\n"
    fi
  fi
fi

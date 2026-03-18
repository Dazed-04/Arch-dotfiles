#!/bin/bash

pkill -f "sleep 1.2 && hyprctl keyword animation"

DURATION=8

# 1. Opening Animation (The "Push Down")
hyprctl keyword animation "workspacesOut, 1, $DURATION, default, slidevert top"
hyprctl keyword animation "workspacesIn, 1, $DURATION, default, slidevert top"
hyprctl keyword animation "specialWorkspace, 1, $DURATION, default, slidevert top"

# 2. Toggle Logic
ACTIVE_ID=$(hyprctl activeworkspace -j | jq '.id')

if [[ "$ACTIVE_ID" -eq 9 ]]; then
  # 3. Returning Animation (The "Pull Up")
  hyprctl keyword animation "workspacesOut, 1, $DURATION, default, slidevert bottom"
  hyprctl keyword animation "workspacesIn, 1, $DURATION, default, slidevert bottom"
  hyprctl keyword animation "specialWorkspace, 1, $DURATION, default, slidevert bottom"

  hyprctl dispatch togglespecialworkspace music
  sleep 0.05
  hyprctl dispatch workspace previous

else
  # Check if rmpc is running
  IS_RUNNING=$(hyprctl clients -j | jq 'any(.[]; .class == "rmpc")')
  if [ "$IS_RUNNING" = "false" ]; then
    hyprctl dispatch exec "[workspace special:music] kitty --class rmpc -e rmpc"
    sleep 0.4
  fi

  hyprctl dispatch workspace 9
  sleep 0.1
  hyprctl dispatch togglespecialworkspace music
fi

# 4. Reset to your system defaults (Wait 1s for the slower 6-speed animation)
(sleep 1.5 &&
  hyprctl keyword animation "workspacesOut, 1, $DURATION, default, slide" &&
  hyprctl keyword animation "workspacesIn, 1, $DURATION, default, slide" &&
  hyprctl keyword animation "specialWorkspace, 1, $DURATION, default, slidevert top") &

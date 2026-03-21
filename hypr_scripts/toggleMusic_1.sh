#!/bin/bash
# Prevent concurrent runs
LOCKFILE="/tmp/rmpc-toggle.lock"
if [ -f "$LOCKFILE" ]; then
  exit 0
fi
touch "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

pkill -f "sleep 1.5 && hyprctl keyword animation"

DURATION=8

set_anim() {
  hyprctl keyword animation "workspacesOut, 1, $DURATION, default, $1"
  hyprctl keyword animation "workspacesIn, 1, $DURATION, default, $1"
  hyprctl keyword animation "specialWorkspace, 1, $DURATION, default, $1"
}

ACTIVE_ID=$(hyprctl activeworkspace -j | jq '.id')

if [[ "$ACTIVE_ID" -eq 9 ]]; then
  set_anim "slidevert bottom"
  hyprctl dispatch togglespecialworkspace music
  sleep 0.05
  hyprctl dispatch workspace previous
else
  set_anim "slidevert top"
  IS_RUNNING=$(hyprctl clients -j | jq 'any(.[]; .class == "rmpc")')
  if [[ "$IS_RUNNING" != "true" ]]; then
    hyprctl dispatch exec "[workspace special:music silent] kitty --class rmpc -e rmpc"
    sleep 0.4
  fi
  hyprctl dispatch workspace 9
  sleep 0.1
  hyprctl dispatch togglespecialworkspace music
fi

(sleep 1.5 &&
  hyprctl keyword animation "workspacesOut, 1, $DURATION, default, slide" &&
  hyprctl keyword animation "workspacesIn, 1, $DURATION, default, slide" &&
  hyprctl keyword animation "specialWorkspace, 1, $DURATION, default, slidevert top") &

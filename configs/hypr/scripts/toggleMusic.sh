#!/bin/bash
LOCKFILE="/tmp/rmpc-toggle.lock"
if [ -f "$LOCKFILE" ]; then
  exit 0
fi
touch "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

pkill -f "sleep 1.5 && hyprctl eval"

DURATION=8

set_anim_in() {
  local STYLE="$1"
  hyprctl eval "hl.animation({ leaf = 'workspacesIn',        enabled = true, speed = $DURATION, bezier = 'Default', style = '$STYLE' })"
  hyprctl eval "hl.animation({ leaf = 'specialWorkspaceIn',  enabled = true, speed = $DURATION, bezier = 'Default', style = '$STYLE' })"
}

set_anim_out() {
  local STYLE="$1"
  hyprctl eval "hl.animation({ leaf = 'workspacesOut',       enabled = true, speed = $DURATION, bezier = 'Default', style = '$STYLE' })"
  hyprctl eval "hl.animation({ leaf = 'specialWorkspaceOut', enabled = true, speed = $DURATION, bezier = 'Default', style = '$STYLE' })"
}

ACTIVE_ID=$(hyprctl activeworkspace -j | jq '.id')

if [[ "$ACTIVE_ID" -eq 9 ]]; then
  set_anim_out "slidevert bottom"
  set_anim_in "slivert top"
  hyprctl dispatch "hl.dsp.workspace.toggle_special('music')"
  sleep 0.05
  hyprctl dispatch "hl.dsp.workspace.focus({ workspace = 'previous' })"
else
  set_anim_out "slidevert bottom"
  set_anim_in "slivert top"
  IS_RUNNING=$(hyprctl clients -j | jq 'any(.[]; .class == "rmpc")')
  if [[ "$IS_RUNNING" != "true" ]]; then
    # exec_raw needed here for window rule syntax
    hyprctl dispatch "hl.dsp.exec_raw('[workspace special:music silent] uwsm app -- kitty --class rmpc -e rmpc')"
    sleep 0.4
  fi
  hyprctl dispatch "hl.dsp.workspace.focus({ workspace = '9' })"
  sleep 0.1
  hyprctl dispatch "hl.dsp.workspace.toggle_special('music')"
fi

(sleep 1.5 &&
  hyprctl eval "hl.animation({ leaf = 'workspacesIn',        enabled = true, speed = $DURATION, bezier = 'Default', style = 'slide' })" &&
  hyprctl eval "hl.animation({ leaf = 'workspacesOut',       enabled = true, speed = $DURATION, bezier = 'Default', style = 'slide' })" &&
  hyprctl eval "hl.animation({ leaf = 'specialWorkspaceIn',  enabled = true, speed = $DURATION, bezier = 'Default', style = 'slidevert top' })" &&
  hyprctl eval "hl.animation({ leaf = 'specialWorkspaceOut', enabled = true, speed = $DURATION, bezier = 'Default', style = 'slidevert top' })") &

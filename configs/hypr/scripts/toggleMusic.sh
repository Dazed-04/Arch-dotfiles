#!/bin/bash
LOCKFILE="/tmp/rmpc-toggle.lock"
if [ -f "$LOCKFILE" ]; then
  exit 0
fi
touch "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

pkill -f "sleep 1.5 && hyprctl eval"

DURATION=8

set_anim() {
  local IN="$1" OUT="$2"
  hyprctl --batch \
    "eval hl.animation({ leaf = 'workspacesIn',        enabled = true, speed = $DURATION, bezier = 'Default', style = '$IN' }) ; \
     eval hl.animation({ leaf = 'specialWorkspaceIn',  enabled = true, speed = $DURATION, bezier = 'Default', style = '$IN' }) ; \
     eval hl.animation({ leaf = 'workspacesOut',       enabled = true, speed = $DURATION, bezier = 'Default', style = '$OUT' }) ; \
     eval hl.animation({ leaf = 'specialWorkspaceOut', enabled = true, speed = $DURATION, bezier = 'Default', style = '$OUT' })"
}

ACTIVE_WS=$(hyprctl activeworkspace -j | jq '.name')

if echo "$ACTIVE_WS" | grep -q "special:music"; then
  set_anim "slidevert top" "slidevert bottom"
  hyprctl dispatch "hl.dsp.workspace.toggle_special('music')"
else
  IS_RUNNING=$(hyprctl clients -j | jq 'any(.[]; .class == "rmpc")')
  if [[ "$IS_RUNNING" != "true" ]]; then
    # exec_raw needed here for window rule syntax
    hyprctl dispatch "hl.dsp.exec_cmd('uwsm app -- kitty --class rmpc -e rmpc', { workspace = 'special:music silent' })"
    sleep 0.4
  fi
  set_anim "slidevert top" "slidevert bottom"
  hyprctl dispatch "hl.dsp.workspace.toggle_special('music')"
fi

(sleep 1.5 && hyprctl --batch \
  "eval hl.animation({ leaf = 'workspacesIn',        enabled = true, speed = $DURATION, bezier = 'Default', style = 'slide' }) ; \
   eval hl.animation({ leaf = 'workspacesOut',       enabled = true, speed = $DURATION, bezier = 'Default', style = 'slide' }) ; \
   eval hl.animation({ leaf = 'specialWorkspaceIn',  enabled = true, speed = $DURATION, bezier = 'Default', style = 'slidevert top' }) ; \
   eval hl.animation({ leaf = 'specialWorkspaceOut', enabled = true, speed = $DURATION, bezier = 'Default', style = 'slidevert top' })") &

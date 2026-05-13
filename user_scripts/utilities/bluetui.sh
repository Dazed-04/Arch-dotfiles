#!/usr/bin/env bash

if hyprctl clients | grep -q 'class: bluetui'; then
  hyprctl dispatch "hl.dsp.window.close({ window = 'class:bluetui' })"
else
  rfkill unblock bluetooth
  hyprctl dispatch "hl.dsp.exec_raw('kitty --class bluetui bluetui')"
fi

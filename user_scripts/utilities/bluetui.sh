#!/usr/bin/env bash

if hyprctl clients | grep -q 'class: bluetui'; then
  hyprctl dispatch closewindow class:bluetui
else
  kitty --class bluetui bluetui
fi

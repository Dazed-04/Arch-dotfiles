#!/usr/bin/env bash

if hyprctl clients | grep -q 'class: wlctl'; then
  hyprctl dispatch closewindow class:wlctl
else
  kitty --class wlctl wlctl
fi

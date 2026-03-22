#!/usr/bin/env bash

if hyprctl clients | grep -q 'class: btop'; then
  hyprctl dispatch closewindow class:btop
else
  kitty --class btop btop
fi

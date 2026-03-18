#!/bin/bash
# Optimized Refresh for Matugen + Waybar

# Kill processes
pkill waybar
pkill swaync

sleep 0.3

# Restart Waybar with your specific config
# Adjust the path below to your preferred config file
waybar -c ~/.config/waybar/config &

# Relaunch SwayNC
swaync >/dev/null 2>&1 &

# Restart mpDris2 if it gets stuck
pkill mpDris2 && mpDris2 &

# Optional: Refresh Hyprland borders/active colors if Matugen handles them
hyprctl reload

exit 0

#!/bin/bash

USER_NAME="Dazed"
USER_ID=$(id -u "$USER_NAME")

export XDG_RUNTIME_DIR="/run/user/$USER_ID"

# Find the Hyprland socket
HYPR_DIR=$(find "$XDG_RUNTIME_DIR/hypr/" -maxdepth 2 -type s -name ".socket.sock" -printf "%h\n" | head -n 1)
SIG="${HYPR_DIR##*/}"

# The $4 variable from acpid event tells us the state (00000001 = plugged, 00000000 = unplugged)
case "$4" in
*1)
  sudo -u "$USER_NAME" \
    HYPRLAND_INSTANCE_SIGNATURE="$SIG" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    /usr/bin/hyprctl eval "hl.monitor({ output = 'eDP-1', mode = '1920x1080@144', position = 'auto', scale = 1 })"
  sudo -u "$USER_NAME" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" \
    /usr/bin/notify-send -e -a "refresh-script" \
    -h string:x-canonical-private-synchronous:refresh_notif \
    -u low -a "refresh-script" \
    -t 3500 \
    "Display" "Switched to 144Hz (High Performance)"
  ;;
*0)
  sudo -u "$USER_NAME" \
    HYPRLAND_INSTANCE_SIGNATURE="$SIG" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    /usr/bin/hyprctl eval "hl.monitor({ output = 'eDP-1', mode = '1920x1080@60', position = 'auto', scale = 1 })"
  sudo -u "$USER_NAME" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" \
    /usr/bin/notify-send -e -a "refresh-script" \
    -h string:x-canonical-private-synchronous:refresh_notif \
    -u low -a "refresh-script" \
    -t 3500 \
    "Display" "Switched to 60Hz (Battery Saver)"
  ;;
esac

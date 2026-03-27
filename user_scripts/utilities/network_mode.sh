#!/bin/bash
source "$HOME/.local/bin/myScripts/utilities/utility_submenus.sh"
OBS_PASS=$(cat "$HOME/.config/hypr/.obs-secret")

# Get dynamic labels
wifi_status=$(nmcli radio wifi)
bt_status=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

wifi_toggle="󰤭  Turn Off WiFi"
[[ "$wifi_status" != "enabled" ]] && wifi_toggle="󰤨  Turn On WiFi"

bt_toggle="󰂲  Turn Off Bluetooth"
[[ "$bt_status" != "yes" ]] && bt_toggle="󰂯  Turn On Bluetooth"

if [[ -z "$@" ]]; then
  printf "%s\n" \
    "$wifi_toggle" \
    "󰤨  Open WiFi Manager" \
    "󰂱  Open Bluetooth Manager" \
    "$bt_toggle"
  exit 0
fi

case "$1" in
*"Turn Off WiFi")
  nmcli radio wifi off
  notify-send "WiFi" "Disabled"
  pkill rofi
  ;;
*"Turn On WiFi")
  nmcli radio wifi on
  notify-send "WiFi" "Enabled"
  pkill rofi
  ;;
*"Open WiFi Manager")
  pkill rofi
  "$HOME/.local/bin/myScripts/utilities/wlctl.sh"
  ;;
*"Turn Off Bluetooth")
  bluetoothctl power off >/dev/null 2>&1
  notify-send "Bluetooth" "Disabled"
  pkill rofi
  ;;
*"Turn On Bluetooth")
  bluetoothctl power on >/dev/null 2>&1
  notify-send "Bluetooth" "Enabled"
  pkill rofi
  ;;
*"Open Bluetooth Manager")
  pkill rofi
  if [[ "$bt_status" != "yes" ]]; then
    bluetoothctl power on
    sleep 0.2
  fi
  "$HOME/.local/bin/myScripts/utilities/bluetui.sh"
  ;;
esac

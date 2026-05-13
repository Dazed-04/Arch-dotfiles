#!/bin/bash
OBS_PASS=$(cat "$HOME/.config/hypr/.obs-secret" | tr -d '[:space:]')

start_recording() {
  local scene="$1"
  if ! pgrep -x obs >/dev/null; then
    hyprctl dispatch 'hl.dsp.exec_cmd("obs", { rules = "[workspace 8 silent]" })'
    notify-send "OBS" "Starting OBS, please wait..."
    sleep 5
    local retries=0
    while ! obs-cmd --websocket "obsws://localhost:4455/${OBS_PASS}" scene list &>/dev/null; do
      sleep 1
      ((retries++))
      if [[ $retries -ge 10 ]]; then
        notify-send "OBS" "Failed to connect to OBS WebSocket"
        return 1
      fi
    done
  fi
  obs-cmd --websocket "obsws://localhost:4455/${OBS_PASS}" scene switch "$scene"
  obs-cmd --websocket "obsws://localhost:4455/${OBS_PASS}" recording start
  notify-send "OBS" "Recording started: $scene"
}

if [[ "$1" == "--exec" ]]; then
  case "$2" in
  "Screen Record") start_recording "Screen Record" ;;
  "Recording and Camera") start_recording "Recording and Camera" ;;
  "Camera & Mic") start_recording "Camera & Mic" ;;
  "Stop Recording")
    obs-cmd --websocket "obsws://localhost:4455/${OBS_PASS}" recording stop >/dev/null 2>&1
    notify-send "OBS" "Recording stopped"
    ;;
  "Close OBS")
    if pgrep -x obs >/dev/null; then
      rec_status=$(obs-cmd --websocket "obsws://localhost:4455/${OBS_PASS}" recording status 2>&1)
      if echo "$rec_status" | grep -q "active\|true\|recording"; then
        obs-cmd --websocket "obsws://localhost:4455/${OBS_PASS}" recording stop
        sleep 0.5
      fi
    fi
    pkill obs
    notify-send "OBS" "Closed"
    ;;
  esac
  exit 0
fi

if [[ -z "$@" ]]; then
  if pgrep -x obs >/dev/null; then
    rec_status=$(obs-cmd --websocket "obsws://localhost:4455/${OBS_PASS}" recording status 2>/dev/null)
    if echo "$rec_status" | grep -q "active\|true\|recording"; then
      printf "%s\n" \
        "󰓛  Stop Recording" \
        "󰹅  Close OBS"
      exit 0
    fi
    printf "%s\n" \
      "󰑋  Screen Record" \
      "󰑋  Recording and Camera" \
      "󰑋  Camera & Mic" \
      "󰹅  Close OBS"
  else
    printf "%s\n" \
      "󰑋  Screen Record" \
      "󰑋  Recording and Camera" \
      "󰑋  Camera & Mic"
  fi
  exit 0
fi

case "$1" in
*"Screen Record")
  nohup bash "$HOME/.local/bin/myScripts/utilities/media_mode.sh" --exec "Screen Record" >/dev/null 2>&1 &
  disown
  ;;
*"Recording and Camera")
  nohup bash "$HOME/.local/bin/myScripts/utilities/media_mode.sh" --exec "Recording and Camera" >/dev/null 2>&1 &
  disown
  ;;
*"Camera & Mic")
  nohup bash "$HOME/.local/bin/myScripts/utilities/media_mode.sh" --exec "Camera & Mic" >/dev/null 2>&1 &
  disown
  ;;
*"Stop Recording")
  nohup bash "$HOME/.local/bin/myScripts/utilities/media_mode.sh" --exec "Stop Recording" >/dev/null 2>&1 &
  disown
  ;;
*"Close OBS")
  nohup bash "$HOME/.local/bin/myScripts/utilities/media_mode.sh" --exec "Close OBS" >/dev/null 2>&1 &
  disown
  ;;
esac

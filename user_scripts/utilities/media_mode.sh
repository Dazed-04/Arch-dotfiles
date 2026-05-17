#!/bin/bash
OBS_PASS=$(cat "${HOME}/.config/hypr/.obs-secret" | tr -d '[:space:]')
WEBSOCKET="obsws://localhost:4455/${OBS_PASS}"

open_preview() {
  if hyprctl clients -j | jq -e '.[].title | select(contains("Projector.*"))' &>/dev/null; then
    return 0
  fi
  obs-cmd --websocket "$WEBSOCKET" \
    source-projector "Video Capture Device (V4L2)" --monitor-index '0'
}

get_obs_status() {
  obs-cmd --websocket "$WEBSOCKET" recording status 2>/dev/null
}

start_recording() {
  local scene="$1"
  if ! pgrep -x obs >/dev/null; then
    hyprctl dispatch 'hl.dsp.exec_cmd("obs", { workspace = "8 silent" })'
    notify-send "OBS" "Starting OBS, please wait..."
    sleep 2
    local retries=0
    while ! obs-cmd --websocket "$WEBSOCKET" scene list &>/dev/null; do
      sleep 2
      ((retries++))
      if [[ $retries -ge 10 ]]; then
        notify-send "OBS" "Failed to connect to OBS WebSocket"
        return 1
      fi
    done
  fi

  # Don't restart recording if already recording
  local status
  status=$(get_obs_status)
  if echo "$status" | grep -q "Active: true"; then
    notify-send "OBS" "Already recording"
    return 0
  fi

  obs-cmd --websocket "$WEBSOCKET" scene switch "$scene"
  obs-cmd --websocket "$WEBSOCKET" recording start
  notify-send "OBS" "Recording started: $scene"

  # Only open preview for Camera & Mic scene
  if [[ "$scene" == "Camera & Mic" ]]; then
    (
      sleep 1
      open_preview
    ) &
  fi
}

if [[ "$1" == "--exec" ]]; then
  case "$2" in
  "Screen Record") start_recording "Screen Record" ;;
  "Recording and Camera") start_recording "Recording and Camera" ;;
  "Camera & Mic") start_recording "Camera & Mic" ;;
  "Pause Recording")
    obs-cmd --websocket "$WEBSOCKET" recording pause
    notify-send "OBS" "Recording Paused"
    ;;
  "Resume Recording")
    obs-cmd --websocket "$WEBSOCKET" recording resume
    notify-send "OBS" "Recording Resumed"
    ;;
  "Stop Recording")
    obs-cmd --websocket "$WEBSOCKET" recording stop >/dev/null 2>&1
    hyprctl dispatch 'hl.dsp.window.close({ window = "title:Projector.*" })'
    notify-send "OBS" "Recording Stopped & Saved"
    ;;
  "Close OBS")
    obs-cmd --websocket "$WEBSOCKET" recording stop >/dev/null 2>&1
    hyprctl dispatch 'hl.dsp.window.close({ window = "title:Projector.*" })'
    sleep 0.5
    pkill obs
    notify-send "OBS" "Closed"
    ;;
  esac
  exit 0
fi

if [[ -z "$@" ]]; then
  if pgrep -x obs >/dev/null; then
    STATUS=$(get_obs_status)
    if echo "$STATUS" | grep -q "Active: true"; then
      if echo "$STATUS" | grep -q "Paused: true"; then
        # Recording Paused
        printf "%s\n" \
          "󰐊 Resume Recording" \
          "󰓛 Stop Recording" \
          "󰹅 Close OBS"
      else
        # Currently Recording
        printf "%s\n" \
          "󰏤 Pause Recording" \
          "󰓛 Stop Recording" \
          "󰹅 Close OBS"
      fi
    else
      # OBS Idle
      printf "%s\n" \
        "󰑋 Screen Record" \
        "󰑋 Recording and Camera" \
        "󰑋 Camera & Mic" \
        "󰹅 Close OBS"
    fi
  else
    # OBS Closed
    printf "%s\n" \
      "󰑋  Screen Record" \
      "󰑋  Recording and Camera" \
      "󰑋  Camera & Mic"
  fi
  exit 0
fi

case "$1" in
*"Screen Record"*) CMD="Screen Record" ;;
*"Recording and Camera"*) CMD="Recording and Camera" ;;
*"Camera & Mic"*) CMD="Camera & Mic" ;;
*"Pause Recording"*) CMD="Pause Recording" ;;
*"Resume Recording"*) CMD="Resume Recording" ;;
*"Stop Recording"*) CMD="Stop Recording" ;;
*"Close OBS"*) CMD="Close OBS" ;;
esac

if [[ -n "$CMD" ]]; then
  nohup bash "$0" --exec "$CMD" >/dev/null 2>&1 &
  disown
fi

#!/usr/bin/env bash

set -Eeuo pipefail

get_thumb_path() {
  local pic="$1"
  local base_name="${pic%.*}"
  echo "${thumbDir}/${base_name//\//_}.png"
}

# For Hyprland + awww

# === CONFIGURATION ===
# Directories
wallpaperDir="$HOME/Pictures/Wallpapers"
themesDir="$HOME/.config/rofi/launcher-themes"
cacheDir="$HOME/.cache/wallpaper-selector"
listCache="$cacheDir/wallpaper_list.txt"
thumbDir="$cacheDir/thumbnails"
currentLink="$cacheDir/current_wallpaper"

mkdir -p "$thumbDir"

for cmd in rofi awww magick matugen; do
  command -v "$cmd" >/dev/null || {
    notify-send -u critical "Missing dependency: $cmd"
    exit 1
  }
done

# Transition settings
FPS=60
TYPE="any"
DURATION=1
BEZIER="0.4,0.2,0.4,1.0"
AWWW_PARAMS=(--transition-fps "${FPS}" --transition-type "${TYPE}" --transition-duration "${DURATION}" --transition-bezier "${BEZIER}")

# Thumbnail generation
generate_thumbnail() {

  export thumbDir
  <"$listCache" xargs -P "$(nproc)" -I{} bash -c '
  pic="{}"
  base_name="${pic%.*}"
  # Pure bash replace: ${variable//search/replace}
  thumb="${thumbDir}/${base_name//\//_}.png"

  [[ -f "$thumb" ]] && exit 0
  
  if [[ "$pic" == *.gif ]]; then
    magick "$pic[0]" -thumbnail "400x500^" -gravity center -extent 400x500 "$thumb" 2>/dev/null
  else
    magick "$pic" -thumbnail "400x500^" -gravity center -extent 400x500 "$thumb" 2>/dev/null
  fi
  '
}

# === COLLECT WALLPAPERS ===
if [[ ! -f "$listCache" || "$wallpaperDir" -nt "$listCache" ]]; then
  find -L "$wallpaperDir" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) |
    sort >"$listCache"

  # Clean up Logic
  # 1. Get current thumbnails (filenames only)
  # 2. Get expected thumbnails (transform listCache paths to filenames)
  # 3. 'comm -23' shows files that exist but shouldn't.
  comm -23 <(find "$thumbDir" -maxdepth 1 -name "*.png" -printf "%f\n" | sort) \
    <(sed 's|/|_|g' "$listCache" | sed 's/$/.png/' | sort) |
    while read -r trash; do
      rm "${thumbDir}/${trash}"
    done
  # End of cleanup logic

  generate_thumbnail
fi

mapfile -t PICS <"$listCache"

if [[ ${#PICS[@]} -eq 0 ]]; then
  notify-send -u critical "No wallpapers found in $wallpaperDir"
  exit 1
fi

# Random wallpaper logic
randomPreviewImage="$HOME/Pictures/black-hole.png"
randomNumber=$((RANDOM % ${#PICS[@]}))
randomPicture="${PICS[$randomNumber]}"
randomChoice="[${#PICS[@]}] Random"

# Rofi command
rofiCommand=(
  rofi
  -show
  -dmenu
  -theme "${themesDir}/wallpaper-select.rasi"
  -format i
)

# === DISPLAY ROFI MENU ===
menu() {
  # Generate menu entries
  printf "%s\x00icon\x1f%s\n" "$randomChoice" "$randomPreviewImage"
  for pic in "${PICS[@]}"; do
    filename="$(basename "$pic")"
    name="${filename%.*}"

    thumb="$(get_thumb_path "$pic")"
    printf "%s\x00icon\x1f%s\x00info\x1f%s\n" "$name" "$thumb" "$pic"
  done
}

# === WALLPAPER SETTER ===
executeCommand() {
  local wp="$1"

  # Set wallpaper
  awww img "$wp" "${AWWW_PARAMS[@]}"
  ln -sf "$wp" "$currentLink"
  ln -sf "$wp" "$HOME/.config/rofi/.current_wallpaper"
  ln -sf "$wp" "$HOME/.config/hypr/.current_wallpaper"

  if ! MATUGEN_OUTPUT=$(matugen --quiet --mode dark --fallback-color "#fa94c3" --source-color-index 0 image "$wp" 2>&1); then
    CLEAN_ERROR=$(echo "$MATUGEN_OUTPUT" | sed 's/\x1b\[[0-9;]*m//g')
    echo "[$(date)] $CLEAN_ERROR" >>"$cacheDir/matugen_error.log"
    notify-send -u critical -t 0 "⚠️ Matugen Error" "$CLEAN_ERROR"
  fi

  sleep 0.1

  # Refresh Waybar and other components
  if [[ -f "$HOME/.config/hypr/scripts/refresh.sh" ]]; then
    "$HOME/.config/hypr/scripts/refresh.sh"
  else
    # Fallback if Refresh.sh is missing
    pkill waybar
    uwsm-app -- waybar &
    swaync-client -R -rs
    if command -v swaync-client &>/dev/null; then
      swaync-client -R -rs
    fi
  fi
}

# === MAIN FUNCTION ===
openMenu() {

  # === KILL RUNNING ROFI IF OPEN ===
  if pidof rofi 2>/dev/null; then
    pkill rofi
    exit 0
  fi

  choice_index=$(menu | "${rofiCommand[@]}")

  # Check if choice is empty (ESC pressed)
  [[ -z "$choice_index" ]] && exit 0

  # The random entry is the first item printed (index 0)
  # The wallpapers start at index 1
  if [[ "$choice_index" -eq 0 ]]; then
    executeCommand "$randomPicture"
    exit 0
  fi

  # The real array index is (rofi_index - 1) because "Random" took spot #0
  real_index="$((choice_index - 1))"

  # Fetch the file directly from the array using the Index.
  # No searching, no loops, no ambiguity.
  selected_file="${PICS[$real_index]}"

  if [[ -f "$selected_file" ]]; then
    executeCommand "$selected_file"
  else
    notify-send -u critical "Error: Image not found."
    exit 1
  fi
}

# === START SCRIPT ===
case "${1:---menu}" in
--set)
  shift
  # Safety Check
  if [[ -z "${1:-}" ]]; then
    echo "Error: usage $0 --set <file>"
    exit 1
  fi
  executeCommand "$1"
  ;;
--menu)
  openMenu
  ;;
--random)
  executeCommand "$randomPicture"
  exit 0
  ;;
*)
  echo "Usage: "
  echo " $0 --menu  #Open wallpaper menu"
  echo " $0 --set FILE  #Set wallpaper"
  exit 1
  ;;
esac

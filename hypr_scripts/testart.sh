#!/bin/bash

# Config
CACHE_DIR="$HOME/.cache/albumart"
MUSIC_DIR="$HOME/Music" # Change to your MPD music root
mkdir -p "$CACHE_DIR"

# Get current song metadata and file path
artist=$(mpc --format "%artist%" current)
album=$(mpc --format "%album%" current)
relative_file=$(mpc --format "%file%" current)

# Exit if nothing is playing
if [ -z "$artist" ] || [ -z "$album" ] || [ -z "$relative_file" ]; then
  exit
fi

# Sanitize filename for caching
metadata=$(printf "%s - %s" "$artist" "$album" | tr '/: ' '_')
CACHE_FILE="$CACHE_DIR/$metadata.png"
TEMP_FILE="$CACHE_DIR/$metadata.tmp"

# Return cached image if exists
if [ -f "$CACHE_FILE" ]; then
  printf "%s" "$CACHE_FILE"
  exit
fi

# Full path to the song file
FULL_PATH="$MUSIC_DIR/$relative_file"
EXT="${relative_file##*.}"

# Extract embedded album art
case "$EXT" in
mp3 | m4a | mp4)
  # Extract first attached picture stream
  ffmpeg -y -i "$FULL_PATH" -an -map 0:v:0 "$TEMP_FILE" 2>/dev/null
  ;;
flac)
  metaflac --export-picture-to="$TEMP_FILE" "$FULL_PATH" 2>/dev/null
  ;;
*)
  echo "Unsupported file type"
  exit
  ;;
esac

# Convert to proper PNG for Hyprlock
if [ -f "$TEMP_FILE" ]; then
  magick "$TEMP_FILE" "$CACHE_FILE"
  rm "$TEMP_FILE"
  printf "%s" "$CACHE_FILE"
else
  echo "No album art found"
fi

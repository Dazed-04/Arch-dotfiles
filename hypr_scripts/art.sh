#!/bin/bash

# Config
CACHE_DIR="$HOME/.cache/albumart"
MUSIC_DIR="$HOME/Music" # Change to your MPD music root
mkdir -p "$CACHE_DIR"

# Get current song metadata and file path
relative_file=$(mpc -f "%file%" current)

# Exit if nothing is playing
if [ -z "$relative_file" ]; then
  exit
fi

# Sanitize filename for caching
metadata=$(basename "$relative_file" | tr '/:() ' '_')
CACHE_FILE="$CACHE_DIR/$metadata.png"

# Return cached image if exists
if [ -f "$CACHE_FILE" ]; then
  echo "$CACHE_FILE"
  exit
fi

# Full path to the song file
FULL_PATH="$MUSIC_DIR/$relative_file"
TEMP_FILE="$CACHE_FILE.tmp.png"

# Extract embedded album art
EXT=$(echo "${relative_file##*.}" | tr '[:upper:]' '[:lower:]')
case "$EXT" in
m4a | mp4 | mp3 | aac)
  ffmpeg -y -i "$FULL_PATH" -map 0:v:0 "$TEMP_FILE"
  ;;
flac)
  metaflac --export-picture-to="$TEMP_FILE" "$FULL_PATH"
  ;;
*)
  echo "Unsupported file type"
  exit
  ;;
esac

# Convert to proper png and check if exists
if [ -f "$TEMP_FILE" ]; then
  magick "$TEMP_FILE" -resize 256x256\> "$CACHE_FILE"
  rm "$TEMP_FILE"
  printf "%s" "$CACHE_FILE"
else
  echo "No album art found"
fi

#!/bin/bash
MUSIC_DIR="$HOME/Music"
LYRICS_DIR="$HOME/Music/lyrics"
mkdir -p "$LYRICS_DIR"
EXCLUDE_FILE="$HOME/Music/scripts/lyrics_exclude.txt"

is_excluded() {
  local path="$1"
  local rel="${path#$MUSIC_DIR/}"
  [ -f "$EXCLUDE_FILE" ] || return 1
  while IFS= read -r pattern; do
    [ -z "$pattern" ] && continue
    [[ "$rel" == "$pattern"* ]] && return 0
  done <"$EXCLUDE_FILE"
  return 1
}

get_tag() {
  ffprobe -v quiet -show_entries format_tags="$1" -of default=noprint_wrappers=1:nokey=1 "$2" 2>/dev/null | head -1
}

clean_lrc() {
  local lrc="$1"
  local artist="$2"
  local title="$3"
  local temp=$(mktemp)

  echo "[ar:$artist]" >"$temp"
  echo "[ti:$title]" >>"$temp"

  local first_ts=$(grep -m1 '^\[[0-9]' "$lrc" | grep -o '^\[[0-9][0-9]:[0-9][0-9]\.[0-9][0-9]\]')
  local first_sec=$(echo "$first_ts" | grep -o '[0-9][0-9]:[0-9][0-9]' | awk -F: '{print $1*60+$2}')

  if [ -n "$first_sec" ] && [ "$first_sec" -gt 5 ]; then
    echo "[00:00.00] 🎵" >>"$temp"
  fi

  grep '^\[[0-9]' "$lrc" | grep -v '^\[00:00\.00\]' >>"$temp"

  mv "$temp" "$lrc"
  echo "✨ Cleaned: $artist - $title"
}

process_file() {
  local song_path="$1"
  is_excluded "$song_path" && return
  local rel_path="${song_path#$MUSIC_DIR/}"
  local lrc_path="$LYRICS_DIR/${rel_path%.*}.lrc"
  mkdir -p "$(dirname "$lrc_path")"
  local filename=$(basename "${song_path%.*}")

  [ -f "$lrc_path" ] && return

  local artist=$(get_tag artist "$song_path")
  local title=$(get_tag title "$song_path")

  if [ -z "$artist" ] || [ -z "$title" ]; then
    local clean=$(echo "$filename" | sed '
            s/\[[^]]*\]//g
            s/([^)]*)//g
            s/[[:space:]]\(Official\|Lyric\|Video\|Music\|4K\|1080p\|HD\|HQ\|Audio\|Visualizer\)[[:space:]]*//gi
            s/  */ /g
            s/^ //; s/ $//
        ')
    search_query="$clean"
  else
    search_query="$artist $title"
  fi

  local raw_query=$(echo "$search_query" | fzf \
    --print-query \
    --header "Confirm search for: $filename" \
    --height 10% \
    --layout=reverse \
    --query="$search_query" | tail -n 1)

  [ $? -eq 130 ] && echo "🛑 Terminating..." && exit 1
  [ -z "$(echo "$raw_query" | xargs)" ] && return

  search_query=$(echo "$raw_query" | xargs)

  if syncedlyrics "$search_query" -o "$lrc_path" --synced-only -p lrclib musixmatch >/dev/null 2>&1; then
    if [ -s "$lrc_path" ]; then
      echo "✅ Downloaded: $filename"
      clean_lrc "$lrc_path" "${artist:-Unknown}" "${title:-$filename}"
    else
      rm -f "$lrc_path"
      echo "❌ Empty file: $search_query"
    fi
  else
    echo "❌ Not found: $search_query"
  fi
}

CLEAN_ONLY=false
[ "$1" = "--clean-only" ] && CLEAN_ONLY=true

find "$MUSIC_DIR" -type f \( -name "*.mp3" -o -name "*.flac" \) | while read -r song_path; do
  is_excluded "$song_path" && continue
  if $CLEAN_ONLY; then
    rel_path="${song_path#$MUSIC_DIR/}"
    lrc_path="$LYRICS_DIR/${rel_path%.*}.lrc"
    if [ -f "$lrc_path" ]; then
      artist=$(get_tag artist "$song_path")
      title=$(get_tag title "$song_path")
      clean_lrc "$lrc_path" "${artist:-Unknown}" "${title:-$(basename "${song_path%.*}")}"
    fi
  else
    process_file "$song_path"
  fi
done

echo -e "\n🏁 Done!"

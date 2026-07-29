#!/usr/bin/env bash
# ~/.cache/fastfetch/pkgcount.sh

CACHE_FILE="$HOME/.cache/fastfetch/pkgcount.txt"
PACMAN_DB="/var/lib/pacman/local"

# Regenerate cache only if it's missing or older than the pacman db (i.e. a package changed)
if [[ ! -f "$CACHE_FILE" ]] || [[ "$PACMAN_DB" -nt "$CACHE_FILE" ]]; then
  pacman_count=$(pacman -Qn | wc -l)
  aur_count=$(pacman -Qm | wc -l)
  printf '%s (Pacman)  %s (Aur)' "$pacman_count" "$aur_count" >"$CACHE_FILE"
fi

cat "$CACHE_FILE"

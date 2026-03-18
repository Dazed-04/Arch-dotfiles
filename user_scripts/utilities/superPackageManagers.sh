#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Choose one package manager."
  echo "Usage: $0 [ --pacman | --paru ]"
  exit 1
fi

case "$1" in
--pacman)
  package_manager=pacman
  fzf_args=(
    --preview-label='alt-p: toggle description, alt-j/k: scroll, tab: multi-select'
  )
  ;;
--paru)
  package_manager=paru
  fzf_args=(
    --preview-label='alt-p: toggle description, alt-j/k: scroll,alt-b/B:toggle PKGBUILD, tab: multi-select'
    --bind 'alt-b:change-preview:paru -Gpa {1}'
    --bind 'alt-B:change-preview:paru -Sii {1}'
  )
  ;;
*)
  echo "Unknown tag '$1'"
  echo "Available tags: --pacman, --paru"
  exit 1
  ;;
esac

fzf_args+=(
  --multi
  --preview "$package_manager -Sii {1} | bat --color=always --theme='base16' -l help"
  --preview-label-pos='bottom'
  --preview-window 'down:65%:wrap'
  --bind "alt-e:execute(nvim -R -c 'set ft=man' <($package_manager -Sii {1}))"
  --bind 'alt-p:toggle-preview'
  --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up'
  --bind 'alt-k:preview-up,alt-j:preview-down'
  --color 'pointer:green,marker:green'
)

pkg_names=$("$package_manager" -Slq | fzf "${fzf_args[@]}")

if [[ -n "$pkg_names" ]]; then
  echo "$pkg_names"
fi

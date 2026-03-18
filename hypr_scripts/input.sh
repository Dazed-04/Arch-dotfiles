layout=$(hyprctl devices -j | jq -r '.keyboards[]?.active_keymap')

if [[ "$layout" == *"English"* ]]; then
  echo "EN ⠀⠀"
else
  echo "??? ⠀⠀"
fi

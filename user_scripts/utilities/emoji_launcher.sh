#!/bin/bash

if pgrep -x rofimoji >/dev/null; then
  pkill -x rofimoji
  exit 0
fi

rofimoji

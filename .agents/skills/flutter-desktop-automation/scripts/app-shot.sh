#!/bin/zsh
# Capture an app window by title regex without stealing focus.
# Usage: app-shot.sh <window-title-regex> <output.png>
#   app-shot.sh "^Unyo$" shots/01-home.png
set -e
SCRIPT_DIR=${0:A:h}
ID=$(kdotool search --name "$1" | head -1)
if [ -z "$ID" ]; then
  echo "no window matching '$1'" >&2
  exit 1
fi
python3 "$SCRIPT_DIR/kwin-shot.py" "$ID" "$2"

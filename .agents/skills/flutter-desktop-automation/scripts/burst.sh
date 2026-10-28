#!/bin/zsh
# Capture <count> window frames as fast as KWin allows (~170ms apart).
# Use to catch transient loading/skeleton states right after a navigation tap.
#
# Usage: burst.sh <window-title-regex> <output-prefix> <count>
#   burst.sh '^Unyo$' /path/shots/05-anime-loading 8
# Produces <prefix>-f01.png .. <prefix>-fNN.png
set -eu
REGEX=$1; PREFIX=$2; COUNT=$3
HERE=$(cd "$(dirname "$0")" && pwd)
for i in $(seq 1 "$COUNT"); do
  "$HERE/app-shot.sh" "$REGEX" "${PREFIX}-f$(printf %02d "$i").png" >/dev/null 2>&1 || true
done
echo "burst: $COUNT frames -> ${PREFIX}-fNN.png"

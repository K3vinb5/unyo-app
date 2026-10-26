#!/usr/bin/env bash
# Copy the custom JRE that ships with unyo_lib into a Flutter release bundle.
#
# Usage:
#   scripts/copy_jre.sh <linux|macos|windows>
#   scripts/copy_jre.sh --unyo-lib-dir     # print the resolved unyo_lib root
#
# unyo_lib root resolution order:
#   1. $UNYO_LIB_DIR, if set
#   2. ../unyo-lib (local sibling checkout — what dev machines use)
#   3. the unyo_lib entry of .dart_tool/package_config.json (the pub git
#      dependency checkout, which is what CI has after `flutter pub get`)
#
# $UNYO_JRE_SRC may point directly at a customjre directory to copy instead of
# unyo_lib/jre/<platform>/customjre. Windows uses this: unyo_lib ships no
# prebuilt Windows JRE, so CI jlinks one and then runs this script over it.
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

# Prints the unyo_lib package root, or fails with a clear message.
resolve_unyo_lib_dir() {
  if [ -n "${UNYO_LIB_DIR:-}" ]; then
    if [ ! -d "$UNYO_LIB_DIR" ]; then
      echo "Error: UNYO_LIB_DIR is set but not a directory: $UNYO_LIB_DIR" >&2
      return 1
    fi
    printf '%s\n' "$UNYO_LIB_DIR"
    return 0
  fi

  if [ -d "$PROJECT_DIR/../unyo-lib" ]; then
    printf '%s\n' "$(cd "$PROJECT_DIR/../unyo-lib" && pwd)"
    return 0
  fi

  local config="$PROJECT_DIR/.dart_tool/package_config.json"
  if [ ! -f "$config" ]; then
    echo "Error: cannot locate the unyo_lib package." >&2
    echo "  - ../unyo-lib does not exist, and" >&2
    echo "  - $config is missing (run 'flutter pub get' first)." >&2
    return 1
  fi

  local root
  root=$(python3 - "$config" <<'PY'
import json, os, sys

config = sys.argv[1]
base = os.path.dirname(os.path.abspath(config))
with open(config, encoding="utf-8") as handle:
    packages = json.load(handle).get("packages", [])

for package in packages:
    if package.get("name") != "unyo_lib":
        continue
    uri = package["rootUri"]
    if uri.startswith("file://"):
        path = uri[len("file://"):]
        # Windows file URIs look like file:///C:/...
        if len(path) > 2 and path[0] == "/" and path[2] == ":":
            path = path[1:]
    else:
        path = os.path.normpath(os.path.join(base, uri))
    print(path)
    break
else:
    sys.exit("unyo_lib not found in package_config.json")
PY
  ) || {
    echo "Error: failed to read the unyo_lib entry from $config" >&2
    return 1
  }

  if [ -z "$root" ] || [ ! -d "$root" ]; then
    echo "Error: unyo_lib root from $config is not a directory: '$root'" >&2
    return 1
  fi
  printf '%s\n' "$root"
}

PLATFORM="${1:-}"

if [ "$PLATFORM" = "--unyo-lib-dir" ] || [ "$PLATFORM" = "-h" ] || [ "$PLATFORM" = "--help" ]; then
  if [ "$PLATFORM" = "--unyo-lib-dir" ]; then
    resolve_unyo_lib_dir
  else
    sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  fi
  exit 0
fi

if [ -z "$PLATFORM" ]; then
  echo "Usage: $0 <platform: linux|macos|windows>" >&2
  exit 1
fi

case "$PLATFORM" in
  linux)
    DEST="$PROJECT_DIR/build/linux/x64/release/bundle/jre/customjre"
    BUNDLE_MARKER="$PROJECT_DIR/build/linux/x64/release/bundle/unyo"
    ;;
  macos)
    DEST="$PROJECT_DIR/build/macos/Build/Products/Release/unyo.app/Contents/Resources/jre/customjre"
    BUNDLE_MARKER="$PROJECT_DIR/build/macos/Build/Products/Release/unyo.app"
    ;;
  windows)
    # Note: unyo_lib/lib/aniyomi_bridge.dart resolves the dylib dir as
    # "<exe dir>/../jre/customjre/lib/server" on Windows, i.e.
    # build/windows/x64/runner/jre. Tracked separately — see the release
    # workflow notes.
    DEST="$PROJECT_DIR/build/windows/x64/runner/Release/jre/customjre"
    BUNDLE_MARKER="$PROJECT_DIR/build/windows/x64/runner/Release/unyo.exe"
    ;;
  *)
    echo "Error: unsupported platform '$PLATFORM' (expected linux, macos or windows)" >&2
    exit 1
    ;;
esac

if [ ! -e "$BUNDLE_MARKER" ]; then
  echo "Error: no $PLATFORM release bundle at $(dirname "$BUNDLE_MARKER")." >&2
  echo "  Run 'flutter build $PLATFORM --release' first." >&2
  exit 1
fi

if [ -n "${UNYO_JRE_SRC:-}" ]; then
  SRC="$UNYO_JRE_SRC"
else
  UNYO_LIB_DIR=$(resolve_unyo_lib_dir)
  SRC="$UNYO_LIB_DIR/jre/$PLATFORM/customjre"
  if [ ! -d "$SRC" ]; then
    echo "Error: no custom JRE for $PLATFORM at $SRC" >&2
    echo "  unyo_lib ships prebuilt JREs for linux and macos only; on Windows" >&2
    echo "  build one with jlink and pass it as UNYO_JRE_SRC." >&2
    exit 1
  fi
fi

if [ ! -d "$SRC" ]; then
  echo "Error: JRE source folder not found: $SRC" >&2
  exit 1
fi

# Idempotent: drop any previous copy (or the debug-build symlink) first.
rm -rf "$DEST"
mkdir -p "$(dirname "$DEST")"
cp -R "$SRC" "$DEST"

SERVER_DIR="$DEST/lib/server"
echo "Copied custom JRE: $SRC -> $DEST"
for lib in libdartjni.so libdartjni.dylib dartjni.dll jni.jar libjvm.so libjvm.dylib jvm.dll; do
  if [ -f "$SERVER_DIR/$lib" ]; then
    echo "  $SERVER_DIR/$lib"
  fi
done

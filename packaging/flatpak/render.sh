#!/usr/bin/env bash
# Render the flatpak manifest skeleton for a release.
#
# Usage:
#   [APPIMAGE_SIZE=<bytes>] ./render.sh <version> [path/to/SHA256SUMS]
#
#   <version>              release version WITHOUT the leading v (e.g. 0.7.0)
#   [path/to/SHA256SUMS]   the SHA256SUMS asset from that GitHub release.
#                          When omitted it is downloaded from the release, so
#                          "no argument" needs network access and a local file
#                          does not.
#
# Fills the extra-data url/sha256/size in dev.unyo.Unyo.yml and the <release>
# version/date in dev.unyo.Unyo.metainfo.xml (in place).
#
# size is the only field SHA256SUMS cannot supply: it comes from
# $APPIMAGE_SIZE, else the GitHub release API. Offline without $APPIMAGE_SIZE it
# stays the __APPIMAGE_SIZE__ placeholder with a warning (flatpak-builder then
# refuses to download until it is set).
#
# Flathub submission itself is WP 71 section B; this only prepares the files.
set -euo pipefail

REPO="K3vinb5/unyo-app"
ASSET_SUFFIX="linux.AppImage"

usage() {
  awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' \
    "${BASH_SOURCE[0]}"
}

die() {
  printf 'render.sh: %s\n' "$*" >&2
  exit 1
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage >&2
  exit 2
fi
case "$1" in
  -h|--help) usage; exit 0 ;;
esac

here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
version="${1#v}"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+([-+][0-9A-Za-z.+-]+)?$ ]] \
  || die "not a release version: $1"
tag="v${version}"
asset="Unyo-${tag}-${ASSET_SUFFIX}"
url="https://github.com/${REPO}/releases/download/${tag}/${asset}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# --- SHA256SUMS ------------------------------------------------------------
sums="${2:-}"
if [[ -z "$sums" ]]; then
  echo "render.sh: downloading SHA256SUMS for ${tag} from GitHub" >&2
  curl -fsSL --retry 3 --connect-timeout 15 \
    "https://github.com/${REPO}/releases/download/${tag}/SHA256SUMS" \
    -o "$tmp/SHA256SUMS" \
    || die "could not download SHA256SUMS for ${tag}"
  sums="$tmp/SHA256SUMS"
fi
[[ -r "$sums" ]] || die "cannot read SHA256SUMS: $sums"

# sha256sum lines are "<hash>  <name>"; tolerate "*" (binary) and "./" noise.
sha256="$(awk -v want="$asset" '
  {
    name = $2
    sub(/^\*/, "", name)
    sub(/^\.\//, "", name)
    if (name == want) { print $1; exit }
  }' "$sums")"
[[ -n "$sha256" ]] || die "${asset} is not listed in ${sums}"
[[ "$sha256" =~ ^[0-9a-f]{64}$ ]] || die "malformed sha256 for ${asset}: ${sha256}"

# --- AppImage size (extra-data requires it) --------------------------------
size="${APPIMAGE_SIZE:-}"
if [[ -z "$size" ]]; then
  size="$(curl -fsSL --retry 2 --connect-timeout 10 \
    "https://api.github.com/repos/${REPO}/releases/tags/${tag}" 2>/dev/null \
    | awk -v want="$asset" '
        /"name"[[:space:]]*:/ { name = $0; sub(/.*"name"[[:space:]]*:[[:space:]]*"/, "", name); sub(/".*/, "", name) }
        /"size"[[:space:]]*:/ && name == want {
          size = $0; sub(/.*"size"[[:space:]]*:[[:space:]]*/, "", size); sub(/[^0-9].*/, "", size); print size; exit
        }' || true)"
fi
if [[ -z "$size" ]]; then
  size="__APPIMAGE_SIZE__"
  echo "render.sh: WARNING: AppImage size unknown; set APPIMAGE_SIZE=<bytes> to fill it" >&2
fi
[[ "$size" =~ ^[0-9]+$ ]] || [[ "$size" == "__APPIMAGE_SIZE__" ]] \
  || die "bad APPIMAGE_SIZE (expected a byte count): ${size}"

# --- release date for the AppStream release entry --------------------------
release_date="${RELEASE_DATE:-}"
if [[ -z "$release_date" ]]; then
  release_date="$(curl -fsSL --retry 2 --connect-timeout 10 \
    "https://api.github.com/repos/${REPO}/releases/tags/${tag}" 2>/dev/null \
    | awk 'match($0, /"published_at"[[:space:]]*:[[:space:]]*"[0-9-]+/) {
             s = substr($0, RSTART, RLENGTH); sub(/.*"/, "", s); print s; exit
           }' || true)"
fi
[[ -n "$release_date" ]] || release_date="$(date -u +%F)"
[[ "$release_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] \
  || die "bad release date (expected YYYY-MM-DD): ${release_date}"

# --- in-place substitution -------------------------------------------------
set_field() {
  local file="$1" pattern="$2" value="$3" hits
  [[ -f "$file" ]] || die "missing file: $file"
  hits="$(grep -cE -- "$pattern" "$file" || true)"
  [[ "$hits" == "1" ]] \
    || die "$(basename "$file"): expected 1 line matching /${pattern}/, found ${hits}"
  awk -v pat="$pattern" -v val="$value" \
    '$0 ~ pat { print val; next } { print }' "$file" > "$tmp/set_field.tmp"
  cat "$tmp/set_field.tmp" > "$file"
  rm -f "$tmp/set_field.tmp"
}

set_field "$here/dev.unyo.Unyo.yml" '^        url: ' "        url: ${url}"
set_field "$here/dev.unyo.Unyo.yml" '^        sha256: ' "        sha256: ${sha256}"
set_field "$here/dev.unyo.Unyo.yml" '^        size: ' "        size: ${size}"

set_field "$here/dev.unyo.Unyo.metainfo.xml" '^    <release version=' \
  "    <release version=\"${version}\" date=\"${release_date}\"/>"

printf 'rendered flatpak skeleton for %s\n' "$tag"
printf '  url   : %s\n' "$url"
printf '  sha256: %s\n' "$sha256"
printf '  size  : %s\n' "$size"
printf '  release: %s (%s)\n' "$version" "$release_date"

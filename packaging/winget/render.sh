#!/usr/bin/env bash
# Render the winget manifest set for a release.
#
# Usage:
#   ./render.sh <version> [path/to/SHA256SUMS]
#
#   <version>              release version WITHOUT the leading v (e.g. 0.7.0)
#   [path/to/SHA256SUMS]   the SHA256SUMS asset from that GitHub release.
#                          When omitted it is downloaded from the release, so
#                          "no argument" needs network access and a local file
#                          does not.
#
# Fills PackageVersion, ReleaseDate, InstallerUrl and InstallerSha256 in the
# three manifests next to this script (in place). ReleaseDate comes from
# $RELEASE_DATE, else the GitHub release's published_at, else today (UTC).
#
# The committed manifests are placeholders (0.0.0 / 1970-01-01 / all-zero
# digest): always re-render before opening a winget-pkgs PR.
set -euo pipefail

REPO="K3vinb5/unyo-app"
ASSET_SUFFIX="windows-setup.exe"

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

# --- ReleaseDate -----------------------------------------------------------
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
  || die "bad ReleaseDate (expected YYYY-MM-DD): ${release_date}"

# --- in-place substitution -------------------------------------------------
# Replaces exactly one line per pattern and fails loudly if the template no
# longer matches, so a renamed field cannot silently render the old value.
set_field() {
  local file="$1" pattern="$2" value="$3" hits
  [[ -f "$file" ]] || die "missing manifest: $file"
  hits="$(grep -cE -- "$pattern" "$file" || true)"
  [[ "$hits" == "1" ]] \
    || die "$(basename "$file"): expected 1 line matching /${pattern}/, found ${hits}"
  awk -v pat="$pattern" -v val="$value" \
    '$0 ~ pat { print val; next } { print }' "$file" > "$tmp/set_field.tmp"
  cat "$tmp/set_field.tmp" > "$file"
  rm -f "$tmp/set_field.tmp"
}

set_field "$here/K3vinb5.Unyo.yaml" \
  '^PackageVersion: ' "PackageVersion: ${version}"

set_field "$here/K3vinb5.Unyo.installer.yaml" \
  '^PackageVersion: ' "PackageVersion: ${version}"
set_field "$here/K3vinb5.Unyo.installer.yaml" \
  '^ReleaseDate: ' "ReleaseDate: ${release_date}"
set_field "$here/K3vinb5.Unyo.installer.yaml" \
  '^    InstallerUrl: ' "    InstallerUrl: ${url}"
set_field "$here/K3vinb5.Unyo.installer.yaml" \
  '^    InstallerSha256: ' "    InstallerSha256: ${sha256}"
set_field "$here/K3vinb5.Unyo.installer.yaml" \
  '^        DisplayVersion: ' "        DisplayVersion: ${version}"

set_field "$here/K3vinb5.Unyo.locale.en-US.yaml" \
  '^PackageVersion: ' "PackageVersion: ${version}"
set_field "$here/K3vinb5.Unyo.locale.en-US.yaml" \
  '^ReleaseNotesUrl: ' "ReleaseNotesUrl: https://github.com/${REPO}/releases/tag/${tag}"

printf 'rendered winget manifests for %s\n' "$tag"
printf '  PackageVersion     : %s\n' "$version"
printf '  ReleaseDate        : %s\n' "$release_date"
printf '  InstallerUrl       : %s\n' "$url"
printf '  InstallerSha256    : %s\n' "$sha256"

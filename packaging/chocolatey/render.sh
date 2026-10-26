#!/usr/bin/env bash
# Render the Chocolatey package for a release.
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
# Fills <version> and <releaseNotes> in unyo.nuspec, url64bit/checksum64 in
# tools/chocolateyinstall.ps1 and the version/URL/digest block in
# tools/VERIFICATION.txt (all in place).
#
# The committed files are placeholders (0.0.0 / all-zero digest): always
# re-render before `choco pack` / pushing.
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

set_field "$here/unyo.nuspec" '^    <version>' "    <version>${version}</version>"
set_field "$here/unyo.nuspec" '^    <releaseNotes>' \
  "    <releaseNotes>https://github.com/${REPO}/releases/tag/${tag}</releaseNotes>"

set_field "$here/tools/chocolateyinstall.ps1" '^  url64bit' \
  "  url64bit       = '${url}'"
set_field "$here/tools/chocolateyinstall.ps1" '^  checksum64' \
  "  checksum64     = '${sha256}'"

set_field "$here/tools/VERIFICATION.txt" '^Version: ' "Version: ${version}"
set_field "$here/tools/VERIFICATION.txt" '^  https://github[.]com/K3vinb5/unyo-app/releases/download/v' "  ${url}"
set_field "$here/tools/VERIFICATION.txt" '^  [0-9a-f]{64}$' "  ${sha256}"

printf 'rendered chocolatey package for %s\n' "$tag"
printf '  version   : %s\n' "$version"
printf '  url64bit  : %s\n' "$url"
printf '  checksum64: %s\n' "$sha256"

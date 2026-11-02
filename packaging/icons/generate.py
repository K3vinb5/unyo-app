#!/usr/bin/env python3
"""Derive every shipped brand-icon file from one canonical master (WP #84).

Before this script the repo carried three generations of exports: the old flat
octopus at 100x100 in `assets/logo.png`, `linux-appimage/`, `packaging/flatpak/`
and the deb packaging step, and the glossy 3D mark in macOS/Windows/snap. The
Windows `.ico` was a single 256px frame, the Linux window icon pointed at a file
that did not exist, and nothing compared a platform icon against the brand.

The master lives at `packaging/icons/source/unyo_1024.png` (the largest new-logo
export that exists in any repo today — the macOS appiconset 1024px frame).
Every Linux-packaging and in-app output is derived from it here:

    assets/logo.png                                 256px  in-app brand mark
    linux-appimage/logo.png                         512px  AppImage header icon
    linux-appimage/Unyo.AppDir/logo.png              512px  AppDir icon
    linux-appimage/Unyo.AppDir/.DirIcon              512px  AppDir icon (launchers)
    packaging/flatpak/logo.png                      512px  flatpak icon
    packaging/icons/linux/hicolor/<N>x<N>/apps/logo.png      deb/installed theme

`linux/runner/CMakeLists.txt` compiles the 512px hicolor export into the binary
as a GResource (GTK window/taskbar icon), and the CMake install tree ships the
whole hicolor set, so no path in the packaging assembly is hand-maintained.

macOS/Windows icons are already the new mark and are out of scope here; when
they are regenerated, extend `TARGETS` rather than checking in new exports.

Usage:
    python3 packaging/icons/generate.py           # write every output
    python3 packaging/icons/generate.py --check   # fail on drift (CI)
"""

from __future__ import annotations

import argparse
import filecmp
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ICONS_DIR = Path(__file__).resolve().parent
REPO_ROOT = ICONS_DIR.parents[1]
MASTER = ICONS_DIR / "source" / "unyo_1024.png"

# Sizes the hicolor theme is shipped at. 512 is what flatpak/Flathub want and
# what the largest desktop consumers pick; 16..256 cover the taskbar/dock.
HICOLOR_SIZES = (16, 24, 32, 48, 64, 128, 256, 512)


def _targets() -> list[tuple[Path, int]]:
    targets: list[tuple[Path, int]] = [
        (REPO_ROOT / "assets/logo.png", 256),
        (REPO_ROOT / "linux-appimage/logo.png", 512),
        (REPO_ROOT / "linux-appimage/Unyo.AppDir/logo.png", 512),
        (REPO_ROOT / "linux-appimage/Unyo.AppDir/.DirIcon", 512),
        (REPO_ROOT / "packaging/flatpak/logo.png", 512),
    ]
    for size in HICOLOR_SIZES:
        targets.append(
            (
                REPO_ROOT / f"packaging/icons/linux/hicolor/{size}x{size}/apps/logo.png",
                size,
            )
        )
    return targets


def _im_convert() -> list[str]:
    """CLI prefix for image writes: IMv7 `magick`, else IMv6 `convert`.

    Ubuntu apt (noble) ships ImageMagick 6.9 without a `magick` binary, which
    is what GitHub's ubuntu runners install, so both CLIs must work.
    """
    if shutil.which("magick"):
        return ["magick"]
    if shutil.which("convert"):
        return ["convert"]
    sys.exit("ImageMagick is required: `magick` (v7) or `convert` (v6)")


def _flat_rgb(path: Path) -> bytes:
    """8-bit RGB pixels of `path` composited on white.

    Compositing matters: transparent pixels carry whatever RGB the encoder
    left there, and IM6/IM7 disagree about it — comparing raw RGBA reported
    worst=255 for two renders of the *same* picture. On white, the same pair
    measures worst<=11, mean<=0.54 (IM 6.9.12 vs IM 7, all 13 outputs).
    """
    proc = subprocess.run(
        [
            *_im_convert(),
            str(path),
            "-background",
            "white",
            "-alpha",
            "remove",
            "-depth",
            "8",
            "rgb:-",
        ],
        capture_output=True,
        check=True,
    )
    return proc.stdout


def _same_icon(fresh: Path, committed: Path) -> bool:
    """True when the committed icon is what the master renders to.

    Fast path: byte equality (holds between runs with the same encoder).
    Cross-path: ImageMagick 6 (Ubuntu apt) and 7 (dev machine) encode PNGs
    differently, so bytes never match across them even when the picture does.
    Compare white-composited pixels instead, with a tolerance that absorbs
    resampler rounding between IM versions but not a human-visible change.

    Measured (IM 6.9.12-98 fresh vs committed IM 7): same picture worst<=11,
    mean<=0.54; real drift — old logo export worst=228 mean=36.9, wrong
    picture worst=255 mean=160. The bounds below sit in that gap.
    """
    if filecmp.cmp(fresh, committed, shallow=False):
        return True
    a = _flat_rgb(fresh)
    b = _flat_rgb(committed)
    if len(a) != len(b) or not a:
        return False
    total = 0
    worst = 0
    for x, y in zip(a, b):
        d = x - y if x > y else y - x
        total += d
        if d > worst:
            worst = d
    return worst <= 32 and total / len(a) <= 2.0


def render(size: int, destination: Path) -> None:
    """Resize the master to `size` and write it to `destination`."""
    destination.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            *_im_convert(),
            str(MASTER),
            "-filter",
            "Lanczos",
            "-resize",
            f"{size}x{size}",
            "-strip",
            # Keep the PNG byte-stable between runs with the SAME encoder so
            # same-machine --check is an exact byte compare. Across ImageMagick
            # builds (v6 CI vs v7 dev) the encoder output differs no matter what
            # the pixels look like, so --check falls back to a pixel compare.
            "-define",
            "png:exclude-chunks=date,time",
            f"PNG32:{destination}",
        ],
        check=True,
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="verify the committed outputs match the master instead of writing",
    )
    args = parser.parse_args()

    if not MASTER.is_file():
        sys.exit(f"master icon missing: {MASTER}")

    if not args.check:
        for path, size in _targets():
            render(size, path)
            print(f"wrote {path.relative_to(REPO_ROOT)} ({size}x{size})")
        return 0

    drift: list[str] = []
    with tempfile.TemporaryDirectory() as tmp:
        for path, size in _targets():
            fresh = Path(tmp) / path.name
            render(size, fresh)
            if not path.is_file():
                drift.append(f"missing: {path.relative_to(REPO_ROOT)}")
            elif not _same_icon(fresh, path):
                drift.append(f"stale:   {path.relative_to(REPO_ROOT)}")

    if drift:
        print("Brand icons do not match packaging/icons/source/unyo_1024.png:")
        for line in drift:
            print(f"  {line}")
        print("Run `python3 packaging/icons/generate.py` and commit the result.")
        return 1

    print(f"{len(_targets())} generated icons match the master.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

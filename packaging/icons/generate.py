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


def render(size: int, destination: Path) -> None:
    """Resize the master to `size` and write it to `destination`."""
    if shutil.which("magick") is None:
        sys.exit("ImageMagick 7 (`magick`) is required to generate the icons")
    destination.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            "magick",
            str(MASTER),
            "-filter",
            "Lanczos",
            "-resize",
            f"{size}x{size}",
            "-strip",
            # Keep the PNG byte-identical between runs so --check compares
            # pixels+encoder output, not timestamps.
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
            elif not filecmp.cmp(fresh, path, shallow=False):
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

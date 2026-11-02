# Brand icons

One master, every output.

`source/unyo_1024.png` is the canonical brand mark (the glossy 3D octopus,
1024x1024 — the largest export that exists; it is the same artwork as the macOS
`AppIcon.appiconset` and `snap/gui/app_icon.png`). Nothing else in this tree is
hand-edited: `generate.py` derives the shipped files with ImageMagick and CI
(`.github/workflows/ci.yml`, job `icons`) fails if any of them drifts.

```sh
python3 packaging/icons/generate.py           # rewrite every generated icon
python3 packaging/icons/generate.py --check   # exit 1 on drift (what CI runs)
```

Generated outputs:

| Path | Size | Used by |
|---|---|---|
| `assets/logo.png` | 256 | in-app brand mark (`BrandMark`, login screen) |
| `linux-appimage/logo.png`, `Unyo.AppDir/logo.png`, `Unyo.AppDir/.DirIcon` | 512 | AppImage header + desktop icon |
| `packaging/flatpak/logo.png` | 512 | flatpak `hicolor/512x512/apps/dev.unyo.Unyo.png` |
| `linux/hicolor/<N>x<N>/apps/logo.png` (16, 24, 32, 48, 64, 128, 256, 512) | N | deb (`Icon=logo`), the CMake install tree, and the GResource window icon |

The GTK window/taskbar icon is compiled into the runner as a GResource from
`linux/hicolor/512x512/apps/logo.png` (`linux/runner/resources/unyo.gresource.xml`),
so it no longer depends on the working directory.

Replacing the brand artwork: overwrite `source/unyo_1024.png`, run the generator,
commit the master + every output together.

macOS (`macos/Runner/Assets.xcassets/AppIcon.appiconset`) and Windows
(`windows/runner/resources/app_icon.ico`) are already the new mark and are not
generated here yet — extend `TARGETS` in `generate.py` when they are refreshed.

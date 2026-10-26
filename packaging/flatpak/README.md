# Flatpak skeleton (`dev.unyo.Unyo`)

Starting point for a Flathub submission. **Nothing here is wired into CI or
submitted yet** — submission is WP 71 section B; this only prepares the files.

| File | Purpose |
| --- | --- |
| `dev.unyo.Unyo.metainfo.xml` | AppStream metadata (id, description, releases) |
| `dev.unyo.Unyo.yml` | flatpak manifest skeleton |
| `dev.unyo.Unyo.desktop` | flatpak-flavoured desktop entry (icon renamed to the app-id) |
| `logo.png` | 100x100 icon copied from `linux-appimage/logo.png`; replace with a 512x512 export before submitting |
| `render.sh` | fills the extra-data URL/digest/size and the AppStream release entry |

The committed files hold placeholders (`0.0.0`, `1970-01-01`, all-zero digest,
`__APPIMAGE_SIZE__`) — always render before building.

## How the app is packaged

`dev.unyo.Unyo.yml` uses an `extra-data` source pointing at the release's
`Unyo-v<version>-linux.AppImage`. FUSE is not available inside the sandbox, so
`/app/bin/unyo` runs it with `--appimage-extract-and-run`:

```
exec /app/extra/Unyo.AppImage --appimage-extract-and-run "$@"
```

That is a bridging strategy, not the end state: a Flutter SDK module that builds
the bundle natively should replace this module wholesale before the real
submission, because `--appimage-extract-and-run` costs an unpack on every launch
and the AppImage runtime is not sandbox-aware.

`extra-data` needs the exact byte size of the AppImage, which `SHA256SUMS`
cannot provide:

```sh
# online: size is read from the GitHub release API
./render.sh 0.7.0

# offline: pass it explicitly
APPIMAGE_SIZE=104857600 ./render.sh 0.7.0 /path/to/SHA256SUMS
```

Without either, `size` keeps the `__APPIMAGE_SIZE__` placeholder (with a
warning) and `flatpak-builder` refuses to download until it is filled.

## Build / lint

```sh
flatpak-builder --force-clean --repo=repo build-dir dev.unyo.Unyo.yml
flatpak-builder --run build-dir dev.unyo.Unyo.yml unyo
flatpak install --user repo dev.unyo.Unyo

# AppStream validation (what Flathub runs)
appstreamcli validate --pedantic dev.unyo.Unyo.metainfo.xml
```

Screenshots are required by Flathub and are commented out in the metainfo until
real ones exist.

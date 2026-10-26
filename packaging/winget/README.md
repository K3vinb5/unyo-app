# winget manifest (`K3vinb5.Unyo`)

Three-file winget manifest for [Unyo](https://unyo.dev), ready to be rendered per
release and submitted to [`microsoft/winget-pkgs`](https://github.com/microsoft/winget-pkgs).

| File | Purpose |
| --- | --- |
| `K3vinb5.Unyo.yaml` | version manifest |
| `K3vinb5.Unyo.installer.yaml` | installer manifest |
| `K3vinb5.Unyo.locale.en-US.yaml` | en-US default locale |
| `render.sh` | fills version, release date, URL and SHA256 for a release |

The committed manifests hold placeholders (`0.0.0`, `1970-01-01`, all-zero
digest) — always render before submitting.

## Installer choice: the Inno `.exe`, not the zip

The Windows release publishes two artifacts:

- `Unyo-v<version>-windows-setup.exe` — Inno Setup 6 installer
  (`windows-inno-script.iss`)
- `Unyo-v<version>-windows.zip` — the raw `Release/` bundle

The `.exe` is what the manifest points at:

- winget understands Inno natively (`InstallerType: inno`), so it discovers the
  uninstall entry and the upgrade behaviour without extra scripting;
- it creates Start-menu/desktop shortcuts and registers the uninstaller, which
  a portable zip install cannot;
- it ships the VC++ 2015-2022 redistributable check that the Flutter runner
  needs.

Consequences encoded in the manifest:

- `Scope: machine` + `ElevationRequirement: elevationRequired` — the `.iss`
  installs into `{autopf}\Unyo` and elevates for the redistributable
  (`PrivilegesRequired=admin` is deliberately not lowered);
- `ProductCode` is the `AppId` from `windows-inno-script.iss`; do not change it,
  existing installs identify themselves by that GUID;
- silent switches are the ones documented in the `.iss` header:
  `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-`.

The zip is not packaged separately: shipping both would create two winget
entries managing the same `%ProgramFiles%\Unyo` directory.

## Render

```sh
# online: pulls SHA256SUMS and the release date from GitHub
./render.sh 0.7.0

# offline: use a local copy of the release's SHA256SUMS
./render.sh 0.7.0 /path/to/SHA256SUMS
```

Fill anything the checksums cannot supply through the environment:
`RELEASE_DATE=2026-10-26 ./render.sh 0.7.0 sums.txt`.

The script edits the three manifests in place and fails if the asset is missing
from `SHA256SUMS` or a template line no longer matches.

## Submit

```sh
winget validate --manifest packaging/winget
winget install --manifest packaging/winget        # local smoke test

# place them at manifests/k/K3vinb5/Unyo/<version>/ and open the PR:
wingetcreate submit --token <github-pat> packaging/winget
```

URLs follow the release asset naming produced by `.github/workflows/release.yml`
(`Unyo-v<tag>-windows-setup.exe`), so a renamed asset breaks the render — check
`render.sh` output against the release before submitting.

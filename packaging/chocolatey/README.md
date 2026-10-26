# Chocolatey package (`unyo`)

| File | Purpose |
| --- | --- |
| `unyo.nuspec` | package definition (id `unyo`) |
| `tools/chocolateyinstall.ps1` | silent install of the Inno Setup `.exe` from the GitHub release |
| `tools/VERIFICATION.txt` | moderator-facing verification steps + digest |
| `render.sh` | fills version, release notes URL, download URL and checksum |

The committed files hold placeholders (`0.0.0`, all-zero digest) — always
render before `choco pack`.

## Installer choice

`tools/chocolateyinstall.ps1` downloads `Unyo-v<version>-windows-setup.exe` (the
Inno Setup 6 build from `windows-inno-script.iss`) and installs it silently via
`Install-ChocolateyPackage`:

```
/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
```

Those are the switches documented in the `.iss` header. The installer elevates
on its own (it installs to `%ProgramFiles%\Unyo` and runs the VC++ 2015-2022
redistributable), so no `Install-ChocolateyPackage -UseOnlyPackageSilentArguments`
tricks are needed. The `.zip` asset is deliberately not used: it has no
uninstaller and no shortcut handling.

## Render

```sh
# online: pulls SHA256SUMS from GitHub
./render.sh 0.7.0

# offline: use a local copy of the release's SHA256SUMS
./render.sh 0.7.0 /path/to/SHA256SUMS
```

The script edits `unyo.nuspec`, `tools/chocolateyinstall.ps1` and
`tools/VERIFICATION.txt` in place, and fails when the asset is missing from
`SHA256SUMS` or a template line no longer matches.

## Pack and push

```sh
choco pack unyo.nuspec
choco install unyo -s . -y                          # local smoke test

choco apikey --key <api-key> --source https://push.chocolatey.org/
choco push unyo.<version>.nupkg --source https://push.chocolatey.org/
```

The package id is `unyo` (lowercase, as Chocolatey requires) and is permanent —
do not rename it after the first push.

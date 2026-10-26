$ErrorActionPreference = 'Stop'

# Rendered by ../render.sh <version> [path/to/SHA256SUMS]; do not edit by hand.
#
# Unyo ships an Inno Setup 6 installer (Unyo-<tag>-windows-setup.exe), so the
# package installs it silently through Install-ChocolateyPackage. Silent
# switches are the ones documented in windows-inno-script.iss.

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

$packageArgs = @{
  packageName    = 'unyo'
  fileType       = 'exe'
  url64bit       = 'https://github.com/K3vinb5/unyo-app/releases/download/v0.0.0/Unyo-v0.0.0-windows-setup.exe'
  checksum64     = '0000000000000000000000000000000000000000000000000000000000000000'
  checksumType64 = 'sha256'
  silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
  validExitCodes = @(0)
}

Install-ChocolateyPackage @packageArgs

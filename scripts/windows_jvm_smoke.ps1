# Runtime smoke test for the bundled Windows JVM.
#
# CI used to only check that the Windows JRE bundle contained the right files,
# which proves nothing about whether the JVM can actually boot: jvm.dll is
# linked into dartjni.dll with /DELAYLOAD:jvm.dll (see package:jni's
# src/CMakeLists.txt), and a missing or broken delay-load target only explodes
# at call time, inside the shipped app.
#
# This script replays the exact loader sequence the app performs:
#   1. preload the bundled jvm.dll by absolute path, like AniyomiBridge's
#      _preloadWindowsJvm (Windows' DLL search path never includes the
#      directory of the DLL being loaded, so the delay-load stub would not
#      find jvm.dll on its own);
#   2. LoadLibrary dartjni.dll by absolute path;
#   3. GetProcAddress "SpawnJvm" to prove the export is reachable through the
#      delay-loaded wrapper;
#   4. boot a real VM from scripts/windows_jvm_smoke_boot.dart — a Dart host
#      replaying the app's own path (Jni.spawnIfNotExists -> SpawnJvm on a
#      spawned isolate, like unyo-lib's "Aniyomi-JNI-Isolate").
#
# The boot must not run inside this script's process: pwsh.exe is a CoreCLR
# process, and calling SpawnJvm through a managed->native delegate fail-fasts
# it (0xC0000409) within ~300ms — even on a 64MB-stack thread — so no JNI
# status ever returns (verified on windows-latest, 2026-10-27, hs_err absent).
# A native Dart host boots the same VM fine. The loader checks above stay in
# pwsh: they are plain LoadLibrary/GetProcAddress calls and behave the same in
# any host.
#
# The checks run in a child pwsh process, because a JVM/VM fatal error or a
# fail-fast (0xC0000409, abort / stack-cookie) kills the whole process and
# would take the diagnostics with it. The parent survives to print the child's
# exit code and any hs_err*.log the VM left behind.
#
# Exit 0 and "SMOKE OK" means the delay-load resolution worked and the VM
# actually booted on this machine's loader.

param([switch]$Child)

$ErrorActionPreference = 'Stop'

function Fail([string]$Message) {
    Write-Host "::error::$Message"
    exit 1
}

# Both paths hang off the staged JRE so the layout stays in one place.
$jreDir = 'build\windows\x64\runner\Release\jre\customjre'
$serverDir = Join-Path $jreDir 'lib\server'
# jlink puts jvm.dll in bin\server, and that is where the app loads it from.
$jvmDll = Join-Path $jreDir 'bin\server\jvm.dll'
$jniDll = Join-Path $serverDir 'dartjni.dll'

if (-not $Child) {
    # Parent: run the loader sequence in a child so a fail-fast cannot erase
    # the evidence, then report the exit code decoded.
    Write-Host "smoke parent pid $PID -> child pwsh -File $PSCommandPath -Child"
    $p = Start-Process pwsh -ArgumentList '-NoProfile', '-File', $PSCommandPath, '-Child' `
        -NoNewWindow -Wait -PassThru
    $code = $p.ExitCode

    # Dump the VM's fatal-error log FIRST: a PowerShell conversion or format
    # bug below must never be able to hide the evidence.
    foreach ($log in Get-ChildItem -Path . -Filter 'hs_err*.log' -ErrorAction SilentlyContinue) {
        Write-Host "==== $($log.FullName) ===="
        Get-Content -Path $log.FullName | Select-Object -First 60
    }

    # [uint32]$code throws on negative NTSTATUS values (e.g. -1073740791);
    # reinterpret the int32 bits instead.
    $unsigned = [BitConverter]::ToUInt32([BitConverter]::GetBytes([int]$code), 0)
    Write-Host ("child exit: {0} (0x{1:X8})" -f $code, $unsigned)

    if ($code -ne 0) {
        if ($unsigned -eq 0xC0000409) {
            Fail ('child died with STATUS_STACK_BUFFER_OVERRUN (0xC0000409): fail-fast from ' +
                'abort() or a stack-cookie check inside the VM boot or the SpawnJvm call')
        }
        Fail "child smoke process exited $code (0x$($unsigned.ToString('X8')))"
    }
    exit 0
}

foreach ($path in @($jvmDll, $jniDll)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Fail "missing $path"
    }
    Write-Host "found: $(Resolve-Path -LiteralPath $path)"
}

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class Win32 {
    [DllImport("kernel32", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern IntPtr LoadLibraryW(string lpFileName);

    [DllImport("kernel32", SetLastError = true, CharSet = CharSet.Ansi)]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);
}
'@

# 1. Preload the bundled JVM by absolute path, as the app does.
$jvmHandle = [Win32]::LoadLibraryW((Resolve-Path -LiteralPath $jvmDll).Path)
if ($jvmHandle -eq [IntPtr]::Zero) {
    Fail "LoadLibrary failed for $jvmDll (Win32 error $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error()))"
}
Write-Host "loaded: $jvmDll"

# 2. Load the JNI wrapper. Its delay-load stub now resolves jvm.dll by name
#    against the module loaded above.
$jniHandle = [Win32]::LoadLibraryW((Resolve-Path -LiteralPath $jniDll).Path)
if ($jniHandle -eq [IntPtr]::Zero) {
    Fail "LoadLibrary failed for $jniDll (Win32 error $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error()))"
}
Write-Host "loaded: $jniDll"

# 3. Resolve SpawnJvm: the export must be reachable through the delay-loaded
#    wrapper. The call itself happens in the Dart host below.
$proc = [Win32]::GetProcAddress($jniHandle, 'SpawnJvm')
if ($proc -eq [IntPtr]::Zero) {
    Fail "GetProcAddress failed for SpawnJvm in $jniDll"
}
Write-Host "resolved: SpawnJvm export"

# 4. Boot a real VM from a Dart host: this is the app's real path (unyo-lib's
#    Jni.spawnIfNotExists -> SpawnJvm on a spawned isolate).
#    Windows SDKs shim bin\dart.bat; the real VM is in the Flutter tool cache.
$dart = Join-Path $env:FLUTTER_ROOT 'bin\cache\dart-sdk\bin\dart.exe'
if (-not (Test-Path -LiteralPath $dart -PathType Leaf)) {
    Fail "missing $dart"
}
$boot = Join-Path $PSScriptRoot 'windows_jvm_smoke_boot.dart'
if (-not (Test-Path -LiteralPath $boot -PathType Leaf)) {
    Fail "missing $boot"
}
& $dart $boot (Resolve-Path -LiteralPath $jvmDll).Path (Resolve-Path -LiteralPath $jniDll).Path
if ($LASTEXITCODE -ne 0) {
    Fail "Dart-host VM boot smoke failed (dart exit $LASTEXITCODE)"
}

Write-Host "SMOKE OK: Dart-host VM boot returned JNI_OK"
exit 0

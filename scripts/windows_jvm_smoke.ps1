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
#   3. GetProcAddress "SpawnJvm" and call it with a NULL JavaVMInitArgs, which
#      dartjni.c turns into default JNI_VERSION_1_6 args with classpath ".".
#
# Exit 0 and "SMOKE OK" means the delay-load resolution worked and the VM
# actually booted on this machine's loader.

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

// SpawnJvm is plain C compiled into a DLL, so it uses the cdecl convention.
[UnmanagedFunctionPointer(CallingConvention.Cdecl)]
public delegate int SpawnJvmDelegate(IntPtr initArgs);
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

# 3. Resolve and call SpawnJvm with NULL init args.
$proc = [Win32]::GetProcAddress($jniHandle, 'SpawnJvm')
if ($proc -eq [IntPtr]::Zero) {
    Fail "GetProcAddress failed for SpawnJvm in $jniDll"
}

$spawn = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    $proc, [SpawnJvmDelegate])
$rc = $spawn([IntPtr]::Zero)

# 0 is JNI_OK (jni_constants.h); anything else is a JNI error code.
if ($rc -ne 0) {
    Fail "SpawnJvm returned $rc (expected 0 = JNI_OK)"
}

Write-Host "SMOKE OK: SpawnJvm returned JNI_OK"
exit 0

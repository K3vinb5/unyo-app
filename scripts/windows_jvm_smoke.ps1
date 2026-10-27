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
# The spawn runs in a child pwsh process, because a JVM/VM fatal error or a
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
    $unsigned = [uint32]$code
    Write-Host ("child exit: {0} (0x{1:X8})" -f $code, $unsigned)

    # A JVM fatal error writes hs_err_pid*.log to the CWD before aborting.
    foreach ($log in Get-ChildItem -Path . -Filter 'hs_err*.log' -ErrorAction SilentlyContinue) {
        Write-Host "==== $($log.FullName) ===="
        Get-Content -Path $log.FullName | Select-Object -First 60
    }

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

// SpawnJvm is plain C compiled into a DLL, so it uses the cdecl convention.
[UnmanagedFunctionPointer(CallingConvention.Cdecl)]
public delegate int SpawnJvmDelegate(IntPtr initArgs);

public static class SpawnRunner {
    // The VM initializes on the calling thread and wants real stack headroom;
    // a default ~1MB pipeline thread is marginal and shows up as a fail-fast
    // (0xC0000409) instead of a clean JNI error. Run the call on a 64MB thread.
    public static int Run(SpawnJvmDelegate spawn) {
        int rc = int.MinValue;
        Exception err = null;
        var t = new System.Threading.Thread(() => {
            try { rc = spawn.Invoke(IntPtr.Zero); }
            catch (Exception e) { err = e; }
        }, 64 * 1024 * 1024);
        t.IsBackground = true;
        t.Start();
        t.Join();
        if (err != null) {
            throw new Exception("SpawnJvm delegate threw: " + err, err);
        }
        return rc;
    }
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

# 3. Resolve and call SpawnJvm with NULL init args.
$proc = [Win32]::GetProcAddress($jniHandle, 'SpawnJvm')
if ($proc -eq [IntPtr]::Zero) {
    Fail "GetProcAddress failed for SpawnJvm in $jniDll"
}

$spawn = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    $proc, [SpawnJvmDelegate])
# PowerShell has no $del(args) call syntax — that is a parse error ("Unexpected
# token '('"). Delegates are invoked through their .Invoke() method.
Write-Host 'calling SpawnJvm(NULL) on a 64MB-stack thread...'
$rc = [SpawnRunner]::Run($spawn)
Write-Host "SpawnJvm returned $rc"

# 0 is JNI_OK (jni_constants.h); anything else is a JNI error code.
if ($rc -ne 0) {
    Fail "SpawnJvm returned $rc (expected 0 = JNI_OK)"
}

Write-Host "SMOKE OK: SpawnJvm returned JNI_OK"
exit 0

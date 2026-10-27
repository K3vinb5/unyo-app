// External dependencies
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the Windows JVM runtime smoke wiring: CI used to only check that the
/// bundled JRE contained the right files and printed a `::warning::` admitting
/// that delay-loaded `jvm.dll` loading was never verified. These tests fail if
/// that blind spot comes back or if the smoke script loses the steps that make
/// it meaningful.
void main() {
  final File workflow = File('.github/workflows/release.yml');
  final File script = File('scripts/windows_jvm_smoke.ps1');

  group('Windows JVM runtime smoke', () {
    test('release workflow runs the smoke script instead of warning', () {
      final String yaml = workflow.readAsStringSync();

      expect(
        yaml,
        isNot(contains('is not verified by this workflow')),
        reason: 'the blind-spot warning must not come back',
      );
      expect(yaml, contains('./scripts/windows_jvm_smoke.ps1'));
      expect(yaml, contains('shell: pwsh'));

      // The presence checks stay; they run before the smoke.
      final int presence = yaml.indexOf('Verify Windows JRE bundle');
      final int smoke = yaml.indexOf('./scripts/windows_jvm_smoke.ps1');
      expect(presence, greaterThanOrEqualTo(0));
      expect(smoke, greaterThan(presence));
    });

    test('smoke script loads the bundled jvm.dll and calls SpawnJvm', () {
      final String ps1 = script.readAsStringSync();

      // Both DLLs are derived from one staged-JRE base, so the layout lives in
      // a single place.
      expect(ps1, contains(r"$jreDir = 'build\windows\x64\runner\Release\jre\customjre'"));
      expect(ps1, contains(r"$serverDir = Join-Path $jreDir 'lib\server'"));
      // dartjni.dll is /DELAYLOAD:jvm.dll, so jvm.dll has to be preloaded by
      // absolute path before the wrapper is loaded.
      expect(ps1, contains(r"$jvmDll = Join-Path $jreDir 'bin\server\jvm.dll'"));
      expect(ps1, contains(r"$jniDll = Join-Path $serverDir 'dartjni.dll'"));
      expect(ps1, contains('dartjni.dll'));
      expect(ps1, contains('LoadLibraryW'));
      expect(ps1, contains('GetProcAddress'));
      expect(ps1, contains("'SpawnJvm'"));

      // dartjni.c is plain C, so the export is cdecl.
      expect(ps1, contains('CallingConvention.Cdecl'));

      // A NULL JavaVMInitArgs lets dartjni.c build the default args itself.
      // PowerShell has no $del(args) call syntax (parse error: "Unexpected
      // token '('"); delegates are invoked through their .Invoke() method.
      expect(ps1, contains('spawn.Invoke(IntPtr.Zero)'));
      expect(
        RegExp(r'''\$spawn\s*\(''').allMatches(ps1).toList(),
        isEmpty,
        reason: r'$spawn(...) is a PowerShell parse error — use $spawn.Invoke(...)',
      );

      // Non-zero JNI codes fail the step, JNI_OK exits 0 loudly.
      expect(ps1, contains(r'if ($rc -ne 0)'));
      expect(ps1, contains('SMOKE OK: SpawnJvm returned JNI_OK'));
    });

    test('spawn runs on a big-stack thread and survives fail-fast', () {
      final String ps1 = script.readAsStringSync();

      // The VM initializes on the calling thread and wants stack headroom;
      // a default ~1MB thread died as STATUS_STACK_BUFFER_OVERRUN (0xC0000409).
      expect(ps1, contains('64 * 1024 * 1024'));
      expect(ps1, contains('new System.Threading.Thread'));

      // A fail-fast kills the process, so the loader sequence runs in a child
      // pwsh and the parent decodes the exit code and dumps hs_err*.log.
      expect(ps1, contains(r'param([switch]$Child)'));
      expect(ps1, contains('-Child'));
      expect(ps1, contains('hs_err'));
      expect(ps1, contains('0xC0000409'));
    });

    // Join-Path needs both -Path and -ChildPath; a single argument is a
    // parameter-binding error, which under $ErrorActionPreference = 'Stop'
    // kills the step before it can ever pass. There is no pwsh on this host,
    // so pin it here.
    for (final String oneArg in <String>[
      r"""Join-Path\s+('[^']*'|"[^"]*"|\$\w+)\s*\)""",
      r"""Join-Path\s+('[^']*'|"[^"]*"|\$\w+)\s*$""",
    ]) {
      test('smoke script has no one-argument Join-Path: $oneArg', () {
        final String ps1 = script.readAsStringSync();
        final RegExp pattern = RegExp(oneArg, multiLine: true);
        final Iterable<RegExpMatch> bad = pattern.allMatches(ps1);
        expect(
          bad.map((RegExpMatch m) => m.group(0)).toList(),
          isEmpty,
          reason: 'every Join-Path call needs a base and a child path',
        );
      });
    }
  });
}

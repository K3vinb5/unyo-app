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

      // A managed-host boot (delegate call from pwsh) fail-fasts the CLR
      // (0xC0000409) and must not come back: the VM boot lives in a Dart host.
      expect(ps1, isNot(contains('GetDelegateForFunctionPointer')));
      expect(ps1, isNot(contains('SpawnRunner')));

      // The Dart host does the boot and the JNI status check.
      expect(ps1, contains(r'if ($LASTEXITCODE -ne 0)'));
      expect(ps1, contains('SMOKE OK: Dart-host VM boot returned JNI_OK'));
    });

    test('loader checks run in a child pwsh and survive fail-fast', () {
      final String ps1 = script.readAsStringSync();

      // A fail-fast kills the process, so the loader sequence runs in a child
      // pwsh and the parent decodes the exit code and dumps hs_err*.log.
      // (A managed-host VM boot was tried here too: delegate calls fail-fast
      // the CoreCLR process 0xC0000409 within ~300ms even on a 64MB-stack
      // thread — the boot lives in the Dart host instead.)
      expect(ps1, contains(r'param([switch]$Child)'));
      expect(ps1, contains('-Child'));
      expect(ps1, contains('hs_err'));
      expect(ps1, contains('0xC0000409'));
    });

    test('a Dart host also boots the VM on the app\'s isolate path', () {
      final String ps1 = script.readAsStringSync();
      final String boot = File(
        'scripts/windows_jvm_smoke_boot.dart',
      ).readAsStringSync();

      expect(ps1, contains('windows_jvm_smoke_boot.dart'));
      // Windows SDKs ship bin\dart.bat; the real VM is in the Flutter cache.
      expect(ps1, contains(r"'bin\cache\dart-sdk\bin\dart.exe'"));

      // unyo-lib boots the JVM inside a spawned isolate; the smoke must too.
      expect(boot, contains('Isolate.spawn'));
      expect(boot, contains('DynamicLibrary.open'));
      expect(boot, contains("'SpawnJvm'"));
      expect(boot, contains('rc == 0'));
      expect(boot, contains('SMOKE OK: Dart-host'));
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

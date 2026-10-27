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

      // dartjni.dll is /DELAYLOAD:jvm.dll, so jvm.dll has to be preloaded by
      // absolute path before the wrapper is loaded.
      expect(
        ps1,
        contains(
          r'jre\customjre\bin\server',
        ),
      );
      expect(ps1, contains(r'jre\customjre\lib\server'));
      expect(ps1, contains('dartjni.dll'));
      expect(ps1, contains('LoadLibraryW'));
      expect(ps1, contains('GetProcAddress'));
      expect(ps1, contains("'SpawnJvm'"));

      // dartjni.c is plain C, so the export is cdecl.
      expect(ps1, contains('CallingConvention.Cdecl'));

      // A NULL JavaVMInitArgs lets dartjni.c build the default args itself.
      expect(ps1, contains(r'$spawn([IntPtr]::Zero)'));

      // Non-zero JNI codes fail the step, JNI_OK exits 0 loudly.
      expect(ps1, contains(r'if ($rc -ne 0)'));
      expect(ps1, contains('SMOKE OK: SpawnJvm returned JNI_OK'));
    });
  });
}

// External dependencies
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
// Internal dependencies
import 'package:unyo/core/di/app_support_dir.dart';

void main() {
  late Directory tempRoot;

  setUp(() {
    tempRoot = Directory.systemTemp.createTempSync('unyo_app_support_dir_test');
  });

  tearDown(() {
    if (tempRoot.existsSync()) {
      tempRoot.deleteSync(recursive: true);
    }
  });

  group('resolveAppSupportDir', () {
    test('uses UNYO_DATA_DIR and creates it when it does not exist', () async {
      // Nested path on purpose: createSync(recursive: true) must build parents.
      final String overridePath = '${tempRoot.path}/data/nested';
      expect(Directory(overridePath).existsSync(), isFalse);
      bool fallbackCalled = false;

      final Directory resolved = await resolveAppSupportDir(
        environment: <String, String>{unyoDataDirEnvVar: overridePath},
        fallback: () async {
          fallbackCalled = true;
          return tempRoot;
        },
      );

      expect(resolved.path, overridePath);
      expect(resolved.existsSync(), isTrue);
      expect(fallbackCalled, isFalse);
    });

    test('falls back when UNYO_DATA_DIR is absent', () async {
      final Directory fallbackDir = Directory('${tempRoot.path}/fallback');
      bool fallbackCalled = false;

      final Directory resolved = await resolveAppSupportDir(
        environment: const <String, String>{},
        fallback: () async {
          fallbackCalled = true;
          return fallbackDir;
        },
      );

      expect(resolved, fallbackDir);
      expect(fallbackCalled, isTrue);
    });

    test('falls back when UNYO_DATA_DIR is empty', () async {
      final Directory fallbackDir = Directory('${tempRoot.path}/fallback');
      bool fallbackCalled = false;

      final Directory resolved = await resolveAppSupportDir(
        environment: const <String, String>{unyoDataDirEnvVar: ''},
        fallback: () async {
          fallbackCalled = true;
          return fallbackDir;
        },
      );

      expect(resolved, fallbackDir);
      expect(fallbackCalled, isTrue);
    });
  });
}

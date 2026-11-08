// External dependencies
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression guard for WP #128.
///
/// The 2026-11 report of "9 of 81 files never run" was a reporter artifact: the
/// expanded reporter only prints a line while exactly one test is active, so a
/// parallel run's log is an incomplete ledger. Tests themselves always ran
/// (`--reporter json` shows every suite). The fix keeps the run serial so the
/// log is complete, and this guard keeps both halves honest:
///
/// - `dart_test.yaml` must pin the concurrency, otherwise a suite can vanish
///   from the printed output again;
/// - every `*_test.dart` under `test/` must be counted, so a file that silently
///   stops being discovered (moved, renamed, filtered) fails here.
///
/// When adding a test file, bump [kExpectedTestFiles] with it.
const int kExpectedTestFiles = 98;

void main() {
  test('the serial reporter configuration is still in place', () {
    final String config = File('dart_test.yaml').readAsStringSync();
    expect(config, contains('concurrency: 1'));
  });

  test('every test file is discovered and has an entry point', () {
    final List<File> files = Directory('test')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('_test.dart'))
        .toList()
      ..sort((File a, File b) => a.path.compareTo(b.path));

    expect(
      files,
      hasLength(kExpectedTestFiles),
      reason:
          'Bump kExpectedTestFiles when adding a test. A decreasing count means '
          'a file is no longer discovered (WP #128 regression).',
    );
    for (final File file in files) {
      expect(
        file.readAsStringSync(),
        contains('void main('),
        reason: '${file.path} has no main() and would never run',
      );
    }
  });
}

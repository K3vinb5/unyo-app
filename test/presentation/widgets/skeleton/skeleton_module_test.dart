import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the skeleton module's ground rules: no `flutter/material.dart`
/// imports and no hardcoded colours (everything comes from `ColorScheme`).
void main() {
  final Directory module = Directory('lib/presentation/widgets/skeleton');

  List<File> moduleFiles() => module
      .listSync(recursive: true)
      .whereType<File>()
      .where((File file) => file.path.endsWith('.dart'))
      .toList();

  test('skeleton module imports material_ui only', () {
    expect(moduleFiles(), isNotEmpty);
    for (final File file in moduleFiles()) {
      expect(
        file.readAsStringSync(),
        isNot(contains('flutter/material.dart')),
        reason: '${file.path} must use package:material_ui/material_ui.dart',
      );
    }
  });

  test('skeleton module takes its colours from the ColorScheme', () {
    for (final File file in moduleFiles()) {
      final String source = file.readAsStringSync();
      expect(
        source,
        isNot(contains('Colors.grey')),
        reason: '${file.path} must not hardcode greys',
      );
      for (final RegExpMatch match
          in RegExp(r'Color\(0x[0-9A-Fa-f]{8}\)').allMatches(source)) {
        fail('${file.path} hardcodes a colour: ${match.group(0)}');
      }
    }
  });
}

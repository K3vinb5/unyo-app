// External dependencies
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the test-injection helper contract: adding a cubit must never mean
/// editing `test/support/test_deps.dart`, and every cubit must be reachable
/// through the production registration list.
void main() {
  test('the test helper carries no concrete cubit knowledge', () {
    final String source =
        File('test/support/test_deps.dart').readAsStringSync();

    expect(
      source.contains('application/cubits/'),
      isFalse,
      reason:
          'test_deps.dart must stay generic; construct cubits through '
          'registerApplicationCubits instead of listing them here',
    );
  });

  test('every cubit is registered by the production registration function', () {
    final String locator = File('lib/core/di/locator.dart').readAsStringSync();
    final List<File> cubitFiles = Directory('lib/application/cubits')
        .listSync()
        .whereType<File>()
        .where((File file) => file.path.endsWith('_cubit.dart'))
        .toList();

    expect(cubitFiles, isNotEmpty);
    for (final File file in cubitFiles) {
      expect(
        locator,
        contains('registerFactory<${CubitFileName.classNameOf(file)}>'),
        reason:
            '${CubitFileName.classNameOf(file)} must be constructible through '
            'registerApplicationCubits so tests get it for free',
      );
    }
  });
}

/// Maps `anime_details_cubit.dart` to its `AnimeDetailsCubit` class name.
class CubitFileName {
  static String classNameOf(File file) {
    final String base = file.path
        .split(Platform.pathSeparator)
        .last
        .replaceAll('_cubit.dart', '');
    final String pascal = base
        .split('_')
        .map((String part) => part[0].toUpperCase() + part.substring(1))
        .join();
    return '${pascal}Cubit';
  }
}

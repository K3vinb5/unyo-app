// External dependencies
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/log/logger.dart';

void main() {
  late Directory tempRoot;

  setUp(() {
    tempRoot = Directory.systemTemp.createTempSync('unyo_logger_test');
  });

  tearDown(() {
    sl.reset();
    if (tempRoot.existsSync()) {
      tempRoot.deleteSync(recursive: true);
    }
  });

  tearDownAll(() {
    if (GetIt.instance.isRegistered<Directory>(instanceName: config.applicationSupportDirectory)) {
      GetIt.instance.unregister<Directory>(instanceName: config.applicationSupportDirectory);
    }
  });

  group('getLogger', () {
    test('creates the logs directory and the log file on a brand-new support dir', () {
      // A brand-new app-support directory has no `logs/` subdirectory yet. This is
      // the exact precondition that made the first flush throw
      // PathNotFoundException: getLogger() used to fire-and-forget
      // `File.create(recursive: true)`, so FileOutput could open/flush before the
      // directory existed. Under test kDebugMode is true, so FileOutput is not the
      // active output; the contract under test is "after getLogger() returns the
      // log file exists on disk", which is what makes any later flush safe.
      expect(Directory('${tempRoot.path}/logs').existsSync(), isFalse);
      sl.registerSingleton<Directory>(
        tempRoot,
        instanceName: config.applicationSupportDirectory,
      );

      expect(getLogger, returnsNormally);

      final Directory logsDir = Directory('${tempRoot.path}/logs');
      expect(logsDir.existsSync(), isTrue);

      final List<File> logFiles = logsDir
          .listSync()
          .whereType<File>()
          .where((File file) => file.path.endsWith('.log'))
          .toList();
      expect(logFiles, hasLength(1));
      expect(logFiles.single.existsSync(), isTrue);
    });

    test('succeeds on a support dir whose logs directory already exists', () {
      Directory('${tempRoot.path}/logs').createSync(recursive: true);
      sl.registerSingleton<Directory>(
        tempRoot,
        instanceName: config.applicationSupportDirectory,
      );

      expect(getLogger, returnsNormally);

      final List<FileSystemEntity> logFiles = Directory('${tempRoot.path}/logs')
          .listSync()
          .where((FileSystemEntity file) => file.path.endsWith('.log'))
          .toList();
      expect(logFiles, hasLength(1));
    });
  });
}

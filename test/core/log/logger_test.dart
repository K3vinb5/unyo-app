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

    test('prunes old logs inside <appSupport>/logs, keeping the newest 20', () {
      // Regression for WP #85: rotation used to list the app-support ROOT while
      // the log file lives in `<appSupport>/logs/`, so the `.log` filter matched
      // nothing and `<appSupport>/logs` grew unbounded.
      final Directory logsDir = Directory('${tempRoot.path}/logs')..createSync(recursive: true);
      final DateTime base = DateTime(2026, 1, 1);
      for (int i = 0; i < 25; i++) {
        File('${logsDir.path}/log_$i.log')
          ..createSync()
          ..setLastModifiedSync(base.add(Duration(minutes: i)));
      }

      LogFilePruner.prune(logsDir);

      final List<File> remaining = logsDir
          .listSync()
          .whereType<File>()
          .where((File file) => file.path.endsWith('.log'))
          .toList();
      expect(remaining, hasLength(LogFilePruner.maxRetained));
      // The newest 20 (indices 5..24) survive; the 5 oldest are gone.
      for (int i = 0; i < 25; i++) {
        final bool shouldExist = i >= 5;
        expect(
          File('${logsDir.path}/log_$i.log').existsSync(),
          shouldExist,
          reason: 'log_$i.log existence',
        );
      }
    });

    test('rotation via getLogger() prunes the logs subdirectory, not the root', () {
      final Directory logsDir = Directory('${tempRoot.path}/logs')..createSync(recursive: true);
      final DateTime base = DateTime(2026, 1, 1);
      for (int i = 0; i < 25; i++) {
        File('${logsDir.path}/old_$i.log')
          ..createSync()
          ..setLastModifiedSync(base.add(Duration(minutes: i)));
      }
      sl.registerSingleton<Directory>(
        tempRoot,
        instanceName: config.applicationSupportDirectory,
      );

      expect(getLogger, returnsNormally);

      // 25 pre-existing + the 1 freshly created file = 26 -> 6 pruned back to 20.
      final List<File> remaining = logsDir
          .listSync()
          .whereType<File>()
          .where((File file) => file.path.endsWith('.log'))
          .toList();
      expect(remaining, hasLength(LogFilePruner.maxRetained));
      // Oldest files are the ones dropped.
      for (int i = 0; i < 6; i++) {
        expect(File('${logsDir.path}/old_$i.log').existsSync(), isFalse, reason: 'old_$i.log');
      }
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

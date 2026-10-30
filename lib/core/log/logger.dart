// External dependencies
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'dart:io';
// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';

/// Keeps the `<appSupport>/logs` directory bounded.
class LogFilePruner {
  const LogFilePruner._();

  /// How many `<timestamp>.log` files `<appSupport>/logs` retains.
  static const int maxRetained = 20;

  /// Deletes the oldest `*.log` files in [logsDirectory] until at most [keep]
  /// remain, keeping the [keep] most recently modified ones.
  ///
  /// Rotation must target the `logs/` subdirectory, not the app-support root:
  /// [getLogger] writes its output to `<appSupport>/logs/<timestamp>.log`, so
  /// listing the root matched nothing and rotation never fired.
  static void prune(Directory logsDirectory, {int keep = maxRetained}) {
    if (keep < 0) {
      throw ArgumentError.value(keep, 'keep', 'must not be negative');
    }
    if (!logsDirectory.existsSync()) {
      return;
    }
    final List<File> logFiles = logsDirectory
        .listSync()
        .whereType<File>()
        .where((File file) => file.path.endsWith('.log'))
        .toList();
    if (logFiles.length <= keep) {
      return;
    }
    logFiles.sort((File a, File b) => a.statSync().modified.compareTo(b.statSync().modified));
    final int excess = logFiles.length - keep;
    for (int i = 0; i < excess; i++) {
      logFiles[i].deleteSync();
    }
  }
}

Logger getLogger() {
  Directory supportDirectory = sl<Directory>(instanceName: config.applicationSupportDirectory);
  String newLogPrettyName =
      "${DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-')}.log";
  File newLogFile = File('${supportDirectory.path}/logs/$newLogPrettyName');
  newLogFile.createSync(recursive: true);
  LogFilePruner.prune(Directory('${supportDirectory.path}/logs'));
  return Logger(
    printer: PrettyPrinter(methodCount: 15),
    level: Level.debug,
    output: kDebugMode
        ? ConsoleOutput()
        : FileOutput(file: newLogFile, overrideExisting: true),
    filter: ProductionFilter(),
  );
}

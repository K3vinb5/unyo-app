// External dependencies
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'dart:io';
// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';

Logger getLogger() {
  Directory supportDirectory = sl<Directory>(instanceName: config.applicationSupportDirectory);
  String newLogPrettyName =
      "${DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-')}.log";
  File newLogFile = File('${supportDirectory.path}/logs/$newLogPrettyName');
  newLogFile.createSync(recursive: true);
  List<FileSystemEntity> logFiles = supportDirectory.listSync().where((file) => file.path.endsWith('.log')).toList();
  if (logFiles.length > 20) {
    logFiles.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
    for (int i = 0; i < logFiles.length - 20; i++) {
      logFiles[i].deleteSync();
    }
  }
  return Logger(
    printer: PrettyPrinter(methodCount: 15),
    level: Level.debug,
    output: kDebugMode
        ? ConsoleOutput()
        : FileOutput(file: newLogFile, overrideExisting: true),
    filter: ProductionFilter(),
  );
}

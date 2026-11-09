// External dependencies
import 'package:logger/logger.dart';

/// A [Logger] that keeps the DEBUG lines in memory so a test can assert the
/// "request delayed by N ms" trail without capturing the console.
class RecordingLogger extends Logger {
  RecordingLogger() : super(filter: ProductionFilter());

  final List<String> debugLines = <String>[];
  final List<String> warningLines = <String>[];

  @override
  void d(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    debugLines.add(message.toString());
  }

  @override
  void w(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    warningLines.add(message.toString());
  }
}

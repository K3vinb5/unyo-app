// External dependencies
import 'dart:io';

import 'package:hive_ce/hive.dart';

/// Hive boxes for repository/user-storage tests, never the real app database.
///
/// Opens Hive against a throwaway temp directory and deletes it on teardown, so
/// a test that forgets a box cannot leak state into the next one.
class TestHive {
  static Future<Directory> setUp() async {
    final Directory dir = Directory.systemTemp.createTempSync('unyo_hive_test');
    Hive.init(dir.path);
    return dir;
  }

  static Future<void> tearDown(Directory dir) async {
    await Hive.close();
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }
}

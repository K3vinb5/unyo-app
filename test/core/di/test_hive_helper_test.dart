// External dependencies
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

// Internal dependencies
import '../../support/test_hive.dart';

void main() {
  test('TestHive gives each test a scratch box and removes it afterwards', () async {
    final Directory dir = await TestHive.setUp();
    final Box<int> box = await Hive.openBox<int>('probe');
    await box.put('value', 42);

    expect(box.get('value'), 42);

    await TestHive.tearDown(dir);
    expect(dir.existsSync(), isFalse);
  });
}

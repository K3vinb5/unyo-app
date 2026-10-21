// Automation-only entrypoint for agent-driven runs (flutter_driver + custom extension).
// NEVER use for release builds — the driver extension disables real keyboard input.
// Usage: flutter run -d linux -t lib/driver_main.dart
//
// Custom VM service extensions (bypass flutter_driver finders, which hang on
// details screens for unknown reasons):
//   ext.unyo.tapAt  {x, y}            — inject a real tap at logical coordinates
//   ext.unyo.tapKey {key}             — find first widget with ValueKey(key), tap its center
//   ext.unyo.findKey {key}            — like tapKey but only reports position/size
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages -- dev-only automation entrypoint
import 'package:flutter_driver/driver_extension.dart';
import 'package:unyo/main.dart' as app;

void main() {
  // Must run before app.main() — it creates its own binding.
  enableFlutterDriverExtension();
  _registerUnyoAutomation();
  app.main();
}

void _registerUnyoAutomation() {
  developer.registerExtension('ext.unyo.tapAt', (method, params) async {
    final x = double.parse(params['x']!);
    final y = double.parse(params['y']!);
    await _tapAt(Offset(x, y));
    return _json({'ok': true});
  });

  developer.registerExtension('ext.unyo.tapKey', (method, params) async {
    final found = _findByKey(params['key']!);
    if (found == null) return _json({'ok': false, 'error': 'not found'});
    final box = found.renderObject! as RenderBox;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    await _tapAt(center);
    return _json({'ok': true, 'x': center.dx, 'y': center.dy});
  });

  developer.registerExtension('ext.unyo.findKey', (method, params) async {
    final found = _findByKey(params['key']!);
    if (found == null) return _json({'ok': false, 'error': 'not found'});
    final box = found.renderObject! as RenderBox;
    final origin = box.localToGlobal(Offset.zero);
    return _json({
      'ok': true,
      'x': origin.dx,
      'y': origin.dy,
      'w': box.size.width,
      'h': box.size.height,
    });
  });
}

Element? _findByKey(String key) {
  Element? found;
  void visitor(Element e) {
    if (found != null) return;
    final k = e.widget.key;
    if (k is ValueKey && k.value.toString() == key) {
      found = e;
      return;
    }
    e.visitChildren(visitor);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visitor);
  return found;
}

Future<void> _tapAt(Offset global) async {
  final gesture = TestGesture(
    dispatcher: (event) async =>
        GestureBinding.instance.handlePointerEvent(event),
    kind: PointerDeviceKind.mouse,
  );
  await gesture.down(global);
  await gesture.up();
}

developer.ServiceExtensionResponse _json(Map<String, dynamic> data) =>
    developer.ServiceExtensionResponse.result(jsonEncode(data));

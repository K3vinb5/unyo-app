// Automation-only entrypoint for agent-driven runs (flutter_driver + custom
// pointer-injection extensions). NEVER use for release builds — the driver
// extension disables real keyboard input. Debug/profile only.
//
// Usage: flutter run -d linux -t lib/driver_main.dart
//
// Custom VM service extensions — an escape hatch for screens where
// flutter_driver finders hang (observed on heavily-nested "details" screens):
//   ext.myapp.tapAt   {x, y}   — inject a real tap at logical coordinates
//   ext.myapp.tapKey  {key}    — tap center of first widget with ValueKey(key)
//   ext.myapp.findKey {key}    — report position/size of that widget
// Rename the "myapp" prefix to your app. Call them with vm-call.sh.
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages -- dev-only automation entrypoint
import 'package:flutter_driver/driver_extension.dart';
import 'package:myapp/main.dart' as app; // <-- adjust package name

void main() {
  // Must run BEFORE app.main() — it creates its own binding; calling it after
  // WidgetsFlutterBinding.ensureInitialized() crashes.
  enableFlutterDriverExtension();
  _registerAutomationExtensions();
  app.main();
}

void _registerAutomationExtensions() {
  developer.registerExtension('ext.myapp.tapAt', (method, params) async {
    final x = double.parse(params['x']!);
    final y = double.parse(params['y']!);
    await _tapAt(Offset(x, y));
    return _json({'ok': true});
  });

  developer.registerExtension('ext.myapp.tapKey', (method, params) async {
    final found = _findByKey(params['key']!);
    if (found == null) return _json({'ok': false, 'error': 'not found'});
    final box = found.renderObject! as RenderBox;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    await _tapAt(center);
    return _json({'ok': true, 'x': center.dx, 'y': center.dy});
  });

  developer.registerExtension('ext.myapp.findKey', (method, params) async {
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

// TestGesture emits the full pointer sequence the gesture arena needs
// (added/hover/down/up). Raw PointerDownEvent+PointerUpEvent injection does
// NOT trigger taps — do not "simplify" this.
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

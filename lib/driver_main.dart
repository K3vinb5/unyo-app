// Automation-only entrypoint for agent-driven runs (flutter_driver + custom extension).
// NEVER use for release builds — the driver extension disables real keyboard input.
// Usage: flutter run -d linux -t lib/driver_main.dart
//
// Custom VM service extensions (bypass flutter_driver finders, which hang on
// details screens for unknown reasons):
//   ext.unyo.tapAt  {x, y}            — inject a real tap at logical coordinates
//   ext.unyo.tapKey {key}             — find first widget with ValueKey(key), tap its center
//   ext.unyo.findKey {key}            — like tapKey but only reports position/size
//   ext.unyo.sendKey {key, shift}     — inject a real key press through the key
//                                       pipeline (Shortcuts/Actions see it)
//   ext.unyo.debugTypes {names}       — count widgets by runtimeType name
//   ext.unyo.debugRects {names,limit} — live rect of each such widget, in tree
//                                       order (what a frame is really made of)
//
// The driver also writes the live VM-service URI (auth token included) to
// <system temp>/unyo-vm-service.txt: the app's stdout is block-buffered when it
// is not attached to a terminal, so the printed URI is not reliable to scrape.
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'dart:ui' show KeyData, KeyEventType;
import 'package:flutter/services.dart' show LogicalKeyboardKey, PhysicalKeyboardKey;

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages -- dev-only automation entrypoint
import 'package:flutter_driver/driver_extension.dart';
import 'package:unyo/main.dart' as app;
import 'package:unyo/presentation/shortcuts/video_shortcut_scope.dart';

void main() {
  // Must run before app.main() — it creates its own binding.
  enableFlutterDriverExtension();
  _registerUnyoAutomation();
  app.main();
  _publishVmServiceUri();
}

/// Writes the VM-service URI (with auth token) somewhere the drive script can
/// read it, independent of stdout buffering.
Future<void> _publishVmServiceUri() async {
  for (var attempt = 0; attempt < 240; attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    try {
      final info = await developer.Service.getInfo();
      final uri = info.serverUri;
      if (uri == null || uri.toString().isEmpty) continue;
      final file = File('${Directory.systemTemp.path}/unyo-vm-service.txt');
      file.writeAsStringSync(uri.toString());
      return;
    } catch (_) {
      // Service not up yet.
    }
  }
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

  developer.registerExtension('ext.unyo.hoverAt', (method, params) async {
    final x = double.parse(params['x']!);
    final y = double.parse(params['y']!);
    await _hoverAt(Offset(x, y));
    return _json({'ok': true});
  });

  developer.registerExtension('ext.unyo.focus', (method, params) async {
    final node = FocusManager.instance.primaryFocus;
    return _json({
      'ok': true,
      'hasFocus': node != null,
      'widget': node?.context?.widget.runtimeType.toString(),
      'debugLabel': node?.debugLabel,
      'inScope': node?.context?.findAncestorWidgetOfExactType<VideoShortcutScope>() != null,
    });
  });

  // Numeric player state, read straight off the video screen's command layer —
  // the same object the shortcut handler mutates, so a before/after pair is
  // direct proof that a key did what it claims.
  developer.registerExtension('ext.unyo.player', (method, params) async {
    final scope = _findVideoShortcutScope();
    if (scope == null) return _json({'ok': false, 'error': 'no video shortcut scope'});
    final commands = scope.handler.commands;
    return _json({
      'ok': true,
      'isPlaying': commands.isPlaying,
      'volume': commands.volume,
      'speed': commands.playbackSpeed,
      'position': commands.position.inMilliseconds,
      'duration': commands.duration.inMilliseconds,
      'isFullscreen': commands.isFullscreen,
      'subtitles': commands.subtitlesEnabled,
      'feedback': scope.handler.feedback.value?.toString(),
    });
  });

  developer.registerExtension('ext.unyo.sendKey', (method, params) async {
    final name = params['key'];
    final spec = name == null ? null : _keySpecs[name];
    if (spec == null) return _json({'ok': false, 'error': 'unknown key "$name"'});
    final shift = params['shift'] == 'true';
    final shiftSpec = _keySpecs['shift']!;
    if (shift) await _sendKey(shiftSpec, KeyEventType.down);
    final handledDown = await _sendKey(spec, KeyEventType.down);
    final handledUp = await _sendKey(spec, KeyEventType.up);
    if (shift) await _sendKey(shiftSpec, KeyEventType.up);
    return _json({'ok': true, 'handledDown': handledDown, 'handledUp': handledUp});
  });

  // Which widgets a frame is made of, and where each one sits: a drive can
  // compare a skeleton frame against a loaded frame on the live tree instead of
  // re-deriving the geometry from the source.
  developer.registerExtension('ext.unyo.debugTypes', (method, params) async {
    final names = _nameParam(params['names']);
    final counts = <String, int>{for (final name in names) name: 0};
    void visit(Element element) {
      final type = element.widget.runtimeType.toString();
      if (counts.containsKey(type)) counts[type] = counts[type]! + 1;
      element.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
    return _json({'ok': true, 'counts': counts});
  });

  developer.registerExtension('ext.unyo.debugRects', (method, params) async {
    final names = _nameParam(params['names']);
    final limit = int.tryParse(params['limit'] ?? '') ?? 200;
    final rects = <Map<String, dynamic>>[];
    void visit(Element element) {
      if (rects.length >= limit) return;
      final type = element.widget.runtimeType.toString();
      final box = element.renderObject;
      if (names.contains(type) && box is RenderBox) {
        final rect = _rectOf(type, box);
        if (rect != null) rects.add(rect);
      }
      element.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
    return _json({'ok': true, 'rects': rects});
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

/// `"A,B,C"` as `{A, B, C}`: the widget-type names a debug extension reports on.
Set<String> _nameParam(String? value) => (value ?? '')
    .split(',')
    .map((String name) => name.trim())
    .where((String name) => name.isNotEmpty)
    .toSet();

/// `{"t", "x", "y", "w", "h"}` for [box]: its global origin and size, or `null`
/// when the box has no size yet or sits at a non-finite coordinate (such a
/// number cannot be JSON-encoded back to the drive).
Map<String, dynamic>? _rectOf(String type, RenderBox box) {
  if (!box.hasSize) return null;
  final Offset origin = box.localToGlobal(Offset.zero);
  final List<double> values = <double>[
    origin.dx,
    origin.dy,
    box.size.width,
    box.size.height,
  ];
  if (!values.every((double value) => value.isFinite)) return null;
  return <String, dynamic>{
    't': type,
    'x': _round(origin.dx),
    'y': _round(origin.dy),
    'w': _round(box.size.width),
    'h': _round(box.size.height),
  };
}

/// Two decimals: a live rect is read as a measurement, not as a float dump.
double _round(double value) => double.parse(value.toStringAsFixed(2));

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
  // Mouse pointers need the hover event to establish the pointer position
  // before the click: without it InkWell-style targets still fire, but
  // text-field-style ones (e.g. the DropdownMenu field) never see a tap.
  await gesture.moveTo(global);
  await gesture.down(global);
  await gesture.up();
}

Future<void> _hoverAt(Offset global) async {
  final gesture = TestGesture(
    dispatcher: (event) async =>
        GestureBinding.instance.handlePointerEvent(event),
    kind: PointerDeviceKind.mouse,
  );
  // Hover only: moves the mouse pointer to [global] without clicking, so the
  // hover state (and cursor) of what is underneath can be inspected.
  await gesture.moveTo(global);
}

developer.ServiceExtensionResponse _json(Map<String, dynamic> data) =>
    developer.ServiceExtensionResponse.result(jsonEncode(data));


/// Physical + logical key ids for the keys the WP #98 shortcut checklist sends.
class _KeySpec {
  const _KeySpec(this.logical, this.physical, [this.character]);

  final int logical;
  final int physical;
  final String? character;
}

_KeySpec _spec(LogicalKeyboardKey logical, PhysicalKeyboardKey physical, [String? character]) =>
    _KeySpec(logical.keyId, physical.usbHidUsage, character);

final Map<String, _KeySpec> _keySpecs = () {
  final specs = <String, _KeySpec>{
    'shift': _spec(LogicalKeyboardKey.shiftLeft, PhysicalKeyboardKey.shiftLeft),
    'space': _spec(LogicalKeyboardKey.space, PhysicalKeyboardKey.space, ' '),
    'escape': _spec(LogicalKeyboardKey.escape, PhysicalKeyboardKey.escape),
    'arrowLeft': _spec(LogicalKeyboardKey.arrowLeft, PhysicalKeyboardKey.arrowLeft),
    'arrowRight': _spec(LogicalKeyboardKey.arrowRight, PhysicalKeyboardKey.arrowRight),
    'arrowUp': _spec(LogicalKeyboardKey.arrowUp, PhysicalKeyboardKey.arrowUp),
    'arrowDown': _spec(LogicalKeyboardKey.arrowDown, PhysicalKeyboardKey.arrowDown),
    'comma': _spec(LogicalKeyboardKey.comma, PhysicalKeyboardKey.comma, ','),
    'period': _spec(LogicalKeyboardKey.period, PhysicalKeyboardKey.period, '.'),
    'less': _spec(LogicalKeyboardKey.less, PhysicalKeyboardKey.comma, '<'),
    'greater': _spec(LogicalKeyboardKey.greater, PhysicalKeyboardKey.period, '>'),
    'k': _spec(LogicalKeyboardKey.keyK, PhysicalKeyboardKey.keyK, 'k'),
    'j': _spec(LogicalKeyboardKey.keyJ, PhysicalKeyboardKey.keyJ, 'j'),
    'l': _spec(LogicalKeyboardKey.keyL, PhysicalKeyboardKey.keyL, 'l'),
    'm': _spec(LogicalKeyboardKey.keyM, PhysicalKeyboardKey.keyM, 'm'),
    'f': _spec(LogicalKeyboardKey.keyF, PhysicalKeyboardKey.keyF, 'f'),
    'c': _spec(LogicalKeyboardKey.keyC, PhysicalKeyboardKey.keyC, 'c'),
    'n': _spec(LogicalKeyboardKey.keyN, PhysicalKeyboardKey.keyN, 'n'),
  };
  const digitLogical = <LogicalKeyboardKey>[
    LogicalKeyboardKey.digit0,
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6,
    LogicalKeyboardKey.digit7,
    LogicalKeyboardKey.digit8,
    LogicalKeyboardKey.digit9,
  ];
  const digitPhysical = <PhysicalKeyboardKey>[
    PhysicalKeyboardKey.digit0,
    PhysicalKeyboardKey.digit1,
    PhysicalKeyboardKey.digit2,
    PhysicalKeyboardKey.digit3,
    PhysicalKeyboardKey.digit4,
    PhysicalKeyboardKey.digit5,
    PhysicalKeyboardKey.digit6,
    PhysicalKeyboardKey.digit7,
    PhysicalKeyboardKey.digit8,
    PhysicalKeyboardKey.digit9,
  ];
  for (var i = 0; i < digitLogical.length; i++) {
    specs['$i'] = _spec(digitLogical[i], digitPhysical[i], '$i');
  }
  return specs;
}();

/// Walks the live element tree for the video screen's shortcut scope.
VideoShortcutScope? _findVideoShortcutScope() {
  VideoShortcutScope? found;
  void visit(Element element) {
    if (found != null) return;
    final widget = element.widget;
    if (widget is VideoShortcutScope) {
      found = widget;
      return;
    }
    element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  return found;
}

Future<bool> _sendKey(_KeySpec spec, KeyEventType type) async {
  final onKeyData = WidgetsBinding.instance.platformDispatcher.onKeyData;
  if (onKeyData == null) return false;
  return onKeyData(
    KeyData(
      timeStamp: Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
      type: type,
      physical: spec.physical,
      logical: spec.logical,
      character: type == KeyEventType.down ? spec.character : null,
      synthesized: true,
    ),
  );
}

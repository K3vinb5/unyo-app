import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unyo/presentation/shortcuts/video_shortcuts.dart';

/// WP #98 Phase B: the key table is the contract. These tests keep it honest —
/// every documented YouTube shortcut exists, no activator is registered twice
/// (a duplicate would silently shadow one of the intents), and every row is
/// dispatchable through the generated action map.
void main() {
  group('video key table', () {
    test('every documented YouTube shortcut has a binding', () {
      const documented = <String>[
        'Space', 'K', // play / pause
        'J', 'L', // -10s / +10s
        'ArrowLeft', 'ArrowRight', // -5s / +5s
        'ArrowUp', 'ArrowDown', // volume +/-5%
        'M', 'F', 'C', // mute, fullscreen, captions
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
        'Shift+,', 'Shift+.', // speed -/+ 0.25
        'N', 'Shift+N', // next / previous episode
        'Esc', // exit fullscreen
      ];

      final labels = videoShortcutBindings.map((binding) => binding.label).toSet();
      for (final label in documented) {
        expect(labels, contains(label), reason: 'missing binding for "$label"');
      }
      expect(labels.difference(documented.toSet()), isEmpty, reason: 'undocumented binding in the table');
    });

    test('no activator is registered twice', () {
      final seen = <String, String>{};
      for (final binding in videoShortcutBindings) {
        final key = _activatorKey(binding.keys);
        expect(
          seen.containsKey(key),
          isFalse,
          reason: '${binding.label} re-registers $key (already used by ${seen[key]})',
        );
        seen[key] = binding.label;
      }
    });

    test('Shift+, and Shift+. accept both the comma/period and the shifted symbol', () {
      // XKB delivers `<`/`>` as the logical key for Shift+, / Shift+., so the
      // table has to map both spellings onto the same speed step.
      final speedDown = videoShortcutBindings.where((b) => b.label == 'Shift+,').toList();
      final speedUp = videoShortcutBindings.where((b) => b.label == 'Shift+.').toList();
      expect(speedDown, hasLength(2));
      expect(speedUp, hasLength(2));
      expect(speedDown.map((b) => (b.intent as AdjustSpeedIntent).delta).toSet(), {-0.25});
      expect(speedUp.map((b) => (b.intent as AdjustSpeedIntent).delta).toSet(), {0.25});
    });

    test('Esc only exits fullscreen', () {
      final escapeBindings = videoShortcutBindings
          .where((binding) => _activatorKey(binding.keys) == _activatorKey(const SingleActivator(LogicalKeyboardKey.escape)))
          .toList();
      expect(escapeBindings, hasLength(1));
      expect(escapeBindings.single.intent, isA<ExitFullscreenIntent>());
    });

    test('digits map to 0%-90%', () {
      final percentByDigit = <String, double>{
        for (final binding in videoShortcutBindings)
          if (binding.intent is SeekToPercentIntent) binding.label: (binding.intent as SeekToPercentIntent).percent,
      };
      expect(percentByDigit, {
        '0': 0.0,
        '1': 0.1,
        '2': 0.2,
        '3': 0.3,
        '4': 0.4,
        '5': 0.5,
        '6': 0.6,
        '7': 0.7,
        '8': 0.8,
        '9': 0.9,
      });
    });

    test('the Shortcuts map keeps every distinct intent reachable', () {
      final shortcuts = videoShortcutMap();
      expect(shortcuts, hasLength(videoShortcutBindings.length));
      final actionTypes = videoShortcutActions((_) => true).keys.toSet();
      for (final intent in shortcuts.values) {
        expect(actionTypes, contains(intent.runtimeType), reason: 'no action for ${intent.runtimeType}');
      }
    });

    test('each activator is a reasonable YouTube binding (no ctrl/meta required)', () {
      for (final binding in videoShortcutBindings) {
        final activator = binding.keys;
        if (activator is SingleActivator) {
          expect(activator.control, isFalse, reason: '${binding.label} should not need Ctrl');
          expect(activator.meta, isFalse, reason: '${binding.label} should not need Meta');
          expect(activator.alt, isFalse, reason: '${binding.label} should not need Alt');
        }
      }
    });
  });
}

String _activatorKey(ShortcutActivator activator) {
  if (activator is SingleActivator) {
    return '${activator.trigger.keyId}|ctrl=${activator.control}|shift=${activator.shift}'
        '|alt=${activator.alt}|meta=${activator.meta}';
  }
  if (activator is CharacterActivator) {
    return 'char:${activator.character}|ctrl=${activator.control}|alt=${activator.alt}|meta=${activator.meta}';
  }
  return activator.toString();
}

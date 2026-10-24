// External dependencies
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';

class MockBuildContext extends Mock implements BuildContext {}

class _FakeEffect extends AppEffect {}

class _CountingHandler extends AppEffectHandler {
  int handled = 0;

  @override
  void handle(AppEffect effect, BuildContext context) {
    handled++;
  }
}

void main() {
  setUpAll(() {
    if (!sl.isRegistered<Logger>()) {
      sl.registerSingleton<Logger>(Logger(level: Level.off));
    }
  });

  group('AppEffectHandler.handleEffects', () {
    late _CountingHandler handler;
    late MockBuildContext context;
    late int clears;

    setUp(() {
      handler = _CountingHandler();
      context = MockBuildContext();
      clears = 0;
    });

    void clearEffects() => clears++;

    test('runs each effect instance exactly once across state snapshots', () {
      // A cubit that emits again before the BlocListener drained the effects
      // hands the listener several state snapshots carrying the SAME effect
      // instances; every one of them must not re-run the effect.
      final effect = _FakeEffect();
      handler.handleEffects(context, [effect], clearEffects);
      handler.handleEffects(context, [effect], clearEffects);
      expect(handler.handled, 1);
      expect(clears, 2);
    });

    test('runs distinct effect instances in one snapshot', () {
      handler.handleEffects(context, [_FakeEffect(), _FakeEffect()], clearEffects);
      expect(handler.handled, 2);
    });

    test('runs a re-added effect when it is a fresh instance', () {
      handler.handleEffects(context, [_FakeEffect()], clearEffects);
      handler.handleEffects(context, [_FakeEffect()], clearEffects);
      expect(handler.handled, 2);
    });
  });
}

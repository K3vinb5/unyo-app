// External dependencies
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';

import '../../../support/localized_app.dart';

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

  group('AppEffectHandler banner notifications', () {
    late AppEffectHandler handler;

    setUp(() {
      handler = AppEffectHandler();
    });

    ShowSnackbarEffect failure(String messageKey) => ShowSnackbarEffect(
          'error_generic_title',
          messageKey: messageKey,
          contentType: ContentType.failure,
        );

    Future<BuildContext> pumpHarness(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(localizedApp(home: const Scaffold(body: SizedBox.expand())));
      // `localizedApp` resolves its bundle one microtask after the first frame.
      await tester.pump();
      return tester.element(find.byType(Scaffold));
    }

    // The banner carries no tappable dismiss control: the one added by #157
    // floated below the ribbon instead of sitting in it. Auto-hide is the only
    // way out, so the actions slot must stay inert.
    testWidgets('the banner exposes no tappable dismiss action', (WidgetTester tester) async {
      final BuildContext context = await pumpHarness(tester);
      handler.handle(failure('first'), context);
      await tester.pumpAndSettle();
      expect(find.byType(MaterialBanner), findsOneWidget);

      expect(find.byKey(const ValueKey<String>('notification-dismiss')), findsNothing);
      expect(
        find.descendant(
          of: find.byType(MaterialBanner),
          matching: find.byWidgetPredicate((Widget widget) => widget is TextButton || widget is IconButton),
        ),
        findsNothing,
        reason: 'the ribbon must not carry an action button; auto-hide removes it',
      );

      // The banner is still gone once its own countdown expires.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialBanner), findsNothing);
    });

    testWidgets('a replacement notification does not renew the previous lifetime', (WidgetTester tester) async {
      final BuildContext context = await pumpHarness(tester);
      handler.handle(failure('first'), context);
      await tester.pump();

      // The first banner's 3 s deadline would expire at t=3.
      await tester.pump(const Duration(seconds: 2));
      handler.handle(failure('second'), context);
      await tester.pump();
      expect(find.byType(MaterialBanner), findsOneWidget);

      // Still inside the second banner's own 3 s window (t=4).
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialBanner), findsOneWidget,
          reason: 'the replaced banner timer must not hide the replacing banner');

      // The second banner keeps its own deadline (t=5).
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialBanner), findsNothing);
    });

    // WP #124: cubits carry translation keys and the banner resolves them here,
    // which is the only layer holding a `BuildContext` (and therefore a locale).
    testWidgets('resolves the effect keys at the presentation boundary', (WidgetTester tester) async {
      final BuildContext context = await pumpHarness(tester);
      handler.handle(
        ShowSnackbarEffect(
          'common_home_welcome',
          titleArgs: <String, String>{'name': 'K3vinb5'},
          messageKey: 'common_cancel',
          contentType: ContentType.failure,
        ),
        context,
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome back K3vinb5, enjoy your journey!'), findsOneWidget,
          reason: 'the title key must be translated with its named args');
      expect(find.text('Cancel'), findsOneWidget,
          reason: 'the message key must be translated too, not rendered as the key');
      expect(find.text('common_home_welcome'), findsNothing);
      expect(find.text('common_cancel'), findsNothing);

      // Flush the banner's own auto-hide timer, or the test binding complains
      // about a timer outliving the widget tree.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    // The diagnosis could not tell whether the shared 3 s timer ever hid the
    // banner. This is the probe: flush the notification's own timer and assert
    // the banner is gone.
    testWidgets('the banner auto-hides after its duration', (WidgetTester tester) async {
      final BuildContext context = await pumpHarness(tester);
      handler.handle(failure('auto'), context);
      await tester.pump();
      expect(find.byType(MaterialBanner), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(MaterialBanner), findsNothing,
          reason: 'hideCurrentMaterialBanner from the delayed callback must remove the banner');
    });
  });
}

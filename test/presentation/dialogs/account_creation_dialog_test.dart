// External dependencies
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/enums/login_card_type.dart';
import 'package:unyo/presentation/dialogs/account_creation_dialog.dart';
import 'package:unyo/presentation/widgets/styled/login_card.dart';

import '../../support/localized_app.dart';

/// WP #111: four 224.w cards against a 0.6.sw body used to overflow the dialog,
/// clip the last card and push the action row under the spill. These tests pin
/// the layout at the sizes the app actually runs at and prove the selector is
/// reachable by wheel, mouse drag and keyboard.
void main() {
  /// One desktop window, in logical pixels: the 1200x675 minimum the window
  /// manager enforces, an ordinary ~1000px window and a large one.
  const Map<String, Size> windows = <String, Size>{
    'minimum window': Size(1200, 675),
    '1000px window': Size(1000, 600),
    '1440px window': Size(1440, 810),
  };

  Future<void> openDialog(
    WidgetTester tester, {
    required Size window,
    LoginCardType selectedType = LoginCardType.anilist,
    ValueChanged<LoginCardType>? onSelect,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
  }) async {
    tester.view.physicalSize = window;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1280, 720),
        minTextAdapt: true,
        splitScreenMode: true,
        // Pumped straight into the page: these tests pin the dialog's layout,
        // so a pushed route would only add indirection.
        child: localizedApp(
          home: Scaffold(
            body: AccountCreationDialog(
              selectedType: selectedType,
              onSelect: onSelect ?? (LoginCardType _) {},
              onCancel: onCancel ?? () {},
              onConfirm: onConfirm ?? () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The carousel's scroll position (the dialog holds exactly one Scrollable).
  /// The carousel's scroll position. `skipOffstage: false` because the
  /// scroll view lives under the dialog's Offstage wrapper.
  ScrollPosition selectorPosition(WidgetTester tester) => tester
      .state<ScrollableState>(find.byType(Scrollable, skipOffstage: false))
      .position;

  testWidgets('nothing overflows or leaves the dialog at any supported width', (WidgetTester tester) async {
    // One dialog, resized like a user dragging the window; each size is checked
    // on the same live tree.
    await openDialog(tester, window: windows.values.first);

    for (final MapEntry<String, Size> window in windows.entries) {
      tester.view.physicalSize = window.value;
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: '${window.key} must not report a layout overflow');

      final Rect dialog = tester.getRect(find.byType(Dialog));
      final Rect selector = tester.getRect(find.byKey(AccountCreationDialog.selectorKey));
      final Rect actions = tester.getRect(find.byKey(AccountCreationDialog.confirmKey));

      // Cards are clipped by the carousel viewport, so the selector bound is
      // what keeps them inside the dialog.
      expect(dialog.contains(selector.topLeft), isTrue, reason: '${window.key}: selector starts inside the dialog');
      expect(dialog.contains(selector.bottomRight - const Offset(0.01, 0.01)), isTrue,
          reason: '${window.key}: selector ends inside the dialog');

      // The action row is visible and never under the selector.
      expect(dialog.contains(actions.topLeft), isTrue, reason: '${window.key}: confirm is visible');
      expect(dialog.contains(actions.bottomRight - const Offset(0.01, 0.01)), isTrue,
          reason: '${window.key}: confirm is not clipped');
      expect(actions.top >= selector.bottom, isTrue, reason: '${window.key}: the selector never paints over the actions');

      // Labels stay inside their own card.
      for (final LoginCardType type in LoginCardType.values) {
        final Rect card = tester.getRect(find.byKey(AccountCreationDialog.cardKey(type)));
        final Rect title = tester.getRect(
          find.descendant(
            of: find.byKey(AccountCreationDialog.cardKey(type)),
            matching: find.byType(Text),
          ).first,
        );
        final Rect inner = card.deflate(6);
        expect(inner.contains(title.topLeft), isTrue, reason: '${window.key}/${type.name}: title starts inside the card border');
        expect(inner.contains(title.bottomRight - const Offset(0.01, 0.01)), isTrue,
            reason: '${window.key}/${type.name}: title ends inside the card border');
      }
    }
  });

  testWidgets('the selector tells the user there is more content', (WidgetTester tester) async {
    await openDialog(tester, window: windows['1000px window']!);

    final ScrollPosition position = selectorPosition(tester);
    expect(position.maxScrollExtent, greaterThan(0), reason: 'four cards do not fit a 0.6.sw dialog');

    // Visible affordance: the scrollbar thumb is painted for the overflowing axis.
    final Scrollbar scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));
    expect(scrollbar.thumbVisibility, isTrue);
    expect(scrollbar.scrollbarOrientation, ScrollbarOrientation.bottom);
  });

  testWidgets('wheel, mouse drag and keyboard all scroll the selector', (WidgetTester tester) async {
    await openDialog(tester, window: windows['1000px window']!);

    final ScrollPosition position = selectorPosition(tester);
    final Offset start = tester.getCenter(find.byKey(AccountCreationDialog.selectorKey));

    // Vertical wheel over a horizontal list.
    final TestPointer wheel = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(wheel.hover(start));
    await tester.sendEventToBinding(wheel.scroll(const Offset(0, 40)));
    await tester.pumpAndSettle();
    expect(position.pixels, 40, reason: 'a vertical wheel scrolls the carousel');

    // Mouse drag (not a scroll gesture on desktop by default).
    await tester.dragFrom(start, const Offset(-150, 0), kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();
    expect(position.pixels, greaterThan(40), reason: 'dragging with the mouse scrolls the carousel');

    // Keyboard.
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(position.pixels, position.maxScrollExtent, reason: 'End reaches the last card');

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(position.pixels, 0, reason: 'Home returns to the first card');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(position.pixels, greaterThan(0), reason: 'the right arrow nudges the carousel');
  });

  testWidgets('selecting a card, confirm and cancel keep their callbacks', (WidgetTester tester) async {
    final List<LoginCardType> selected = <LoginCardType>[];
    bool cancelled = false;
    bool confirmed = false;

    await openDialog(
      tester,
      window: windows['1000px window']!,
      onSelect: selected.add,
      onCancel: () => cancelled = true,
      onConfirm: () => confirmed = true,
    );

    await tester.tap(find.byKey(AccountCreationDialog.cardKey(LoginCardType.anilist)));
    await tester.pumpAndSettle();
    expect(selected, <LoginCardType>[LoginCardType.anilist]);

    // The last card is only reachable after scrolling.
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(AccountCreationDialog.cardKey(LoginCardType.local)));
    await tester.pumpAndSettle();
    expect(selected, <LoginCardType>[LoginCardType.anilist, LoginCardType.local]);

    await tester.tap(find.byKey(AccountCreationDialog.cancelKey));
    await tester.pumpAndSettle();
    expect(cancelled, isTrue);

    await tester.tap(find.byKey(AccountCreationDialog.confirmKey));
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
  });

  testWidgets('the selected card is the only one drawn with the active border', (WidgetTester tester) async {
    await openDialog(tester, window: windows['1440px window']!, selectedType: LoginCardType.shikimori);

    Color borderOf(LoginCardType type) {
      final Container body = tester.widget<Container>(
        find.descendant(
          of: find.byKey(AccountCreationDialog.cardKey(type)),
          matching: find.byType(Container),
        ).first,
      );
      return (body.decoration! as BoxDecoration).border!.top.color;
    }

    expect(borderOf(LoginCardType.shikimori), Colors.white);
    expect(borderOf(LoginCardType.anilist), isNot(Colors.white));
    expect(find.byType(LoginCard), findsNWidgets(LoginCardType.values.length));
  });
}

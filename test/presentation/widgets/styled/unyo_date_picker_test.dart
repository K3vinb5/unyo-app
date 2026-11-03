import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/styled/unyo_date_picker.dart';

import '../../../support/localized_app.dart';

void main() {
  Future<void> openPicker(WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        child: localizedApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed:
                        () => showUnyoDatePicker(
                          context: context,
                          initialDate: DateTime(2026, 10, 13),
                        ),
                    child: const Text('open'),
                  ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('date picker action buttons use a clickable mouse cursor', (tester) async {
    await openPicker(tester);

    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse, pointer: 1);
    addTearDown(gesture.removePointer);

    await gesture.moveTo(tester.getCenter(find.text('OK')));
    await tester.pump();
    expect(
      tester.binding.mouseTracker.debugDeviceActiveCursor(1),
      SystemMouseCursors.click,
      reason: 'the OK button must show a clickable cursor on desktop',
    );

    await gesture.moveTo(tester.getCenter(find.text('Cancel')));
    await tester.pump();
    expect(
      tester.binding.mouseTracker.debugDeviceActiveCursor(1),
      SystemMouseCursors.click,
      reason: 'the Cancel button must show a clickable cursor on desktop',
    );
  });

  testWidgets('the month header shrinks instead of overflowing a long month name', (tester) async {
    tester.view.physicalSize = const Size(1920, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        child: localizedApp(
          // A 2x text scale stands in for a locale whose month name is far
          // longer than "September": before the header wrapped its label in
          // `Expanded`, the 420px dialog's Row overflowed by 55px.
          home: Builder(
            builder:
                (BuildContext context) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2.0)),
                  child: Scaffold(
                    body: Center(
                      child: UnyoDatePicker(
                        initialDate: DateTime(2026, 9, 15),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      tester.takeException(),
      isNull,
      reason: 'a longer month name must be ellipsized, not overflow the dialog header',
    );
    expect(
      tester.widget<Text>(find.text('September 2026')).overflow,
      TextOverflow.ellipsis,
      reason: 'the month label must be allowed to shrink to the available width',
    );
  });

  testWidgets('date picker day cells use a clickable mouse cursor', (tester) async {
    await openPicker(tester);

    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse, pointer: 1);
    addTearDown(gesture.removePointer);

    // A day cell inside the visible month grid (15 is never in the first row).
    await gesture.moveTo(tester.getCenter(find.text('15').first));
    await tester.pump();
    expect(
      tester.binding.mouseTracker.debugDeviceActiveCursor(1),
      SystemMouseCursors.click,
      reason: 'day cells must show a clickable cursor on desktop',
    );
  });
}

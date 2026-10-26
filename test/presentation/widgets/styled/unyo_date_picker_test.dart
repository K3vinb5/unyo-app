import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/styled/unyo_date_picker.dart';

void main() {
  Future<void> openPicker(WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        child: MaterialApp(
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

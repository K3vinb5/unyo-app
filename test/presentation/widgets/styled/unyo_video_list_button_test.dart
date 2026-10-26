import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/styled/unyo_video_list_button.dart';

void main() {
  Future<void> pumpButton(WidgetTester tester, {VoidCallback? onPressed}) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        child: MaterialApp(
          home: Scaffold(
            body: UnyoVideoListButton(
              tooltip: 'Open Episode List',
              onPressed: onPressed ?? () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  BorderRadius? paintedRadius(WidgetTester tester) {
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(UnyoVideoListButton),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration;
    if (decoration is BoxDecoration && decoration.borderRadius is BorderRadius) {
      return decoration.borderRadius! as BorderRadius;
    }
    return null;
  }

  group('halfPillRadius', () {
    test('is non-degenerate for every clamped button size', () {
      for (final double width in [40, 45, 50]) {
        for (final double height in [90, 95, 105]) {
          final double r = UnyoVideoListButton.halfPillRadius(width, height);
          expect(r, greaterThanOrEqualTo(0), reason: '$width x $height');
          expect(r, lessThanOrEqualTo(width), reason: 'radius must fit the width');
          expect(2 * r, lessThanOrEqualTo(height), reason: 'corner arcs must fit the height');
        }
      }
    });

    test('uses the full width when the height allows a half-pill', () {
      expect(UnyoVideoListButton.halfPillRadius(45, 95), 45);
    });

    test('falls back to half the height for a squat box', () {
      expect(UnyoVideoListButton.halfPillRadius(60, 90), 45);
    });
  });

  group('HalfPillClipper', () {
    test('cuts the left corners off and keeps the right edge flush', () {
      const double r = 45.0;
      final Path clip = const HalfPillClipper(r).getClip(const Size(45, 95));

      // Full box is covered on the right side (flush with the screen edge).
      expect(clip.contains(const Offset(45, 95)), isTrue);
      expect(clip.contains(const Offset(44, 10)), isTrue);

      // Left corners are rounded off, left edge is the arc + straight segment.
      expect(clip.contains(const Offset(0, 0)), isFalse, reason: 'top-left must be cut');
      expect(clip.contains(const Offset(0, 95)), isFalse, reason: 'bottom-left must be cut');
      expect(clip.contains(const Offset(0, 47.5)), isTrue, reason: 'left middle is inside');
      expect(clip.contains(const Offset(2, 2)), isFalse);
    });

    test('matches the Skia silhouette: 45px wide at the vertical middle', () {
      const double r = 45.0;
      final Path clip = const HalfPillClipper(r).getClip(const Size(45, 95));
      final Rect bounds = clip.getBounds();
      expect(bounds.left, 0);
      expect(bounds.right, 45);
      expect(bounds.top, 0);
      expect(bounds.bottom, 95);
    });
  });

  group('UnyoVideoListButton', () {
    testWidgets('paints a non-degenerate half-pill radius on both left corners', (tester) async {
      await pumpButton(tester);
      final BorderRadius? radius = paintedRadius(tester);
      expect(radius, isNotNull);

      final Size size = tester.getSize(find.byType(UnyoVideoListButton));
      final double expected = UnyoVideoListButton.halfPillRadius(size.width, size.height);

      expect(radius!.topLeft.x, expected);
      expect(radius.bottomLeft.x, expected);
      // OP #57: oversized radii (50 on a 45-wide box) tessellate into a
      // squared silhouette under Impeller. The painted radii must fit.
      expect(radius.topLeft.x, lessThanOrEqualTo(size.width));
      expect(radius.topLeft.y + radius.bottomLeft.y, lessThanOrEqualTo(size.height));
      // Right side stays flush with the screen edge: no rounding there.
      expect(radius.topRight, Radius.zero);
      expect(radius.bottomRight, Radius.zero);
    });

    testWidgets('renders the chevron icon and fires onPressed', (tester) async {
      int taps = 0;
      await pumpButton(tester, onPressed: () => taps++);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == Icons.arrow_back_ios_new_rounded,
        ),
        findsOneWidget,
      );
      await tester.tap(find.byType(UnyoVideoListButton));
      expect(taps, 1);
    });
  });
}

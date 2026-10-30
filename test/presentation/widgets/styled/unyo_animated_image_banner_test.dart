import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/styled/unyo_animated_image_banner.dart';

import '../skeleton/support/fake_image_http.dart';

Widget _banner({
  required double width,
  required double height,
  Duration segmentDuration = const Duration(seconds: 1),
  int randomSeed = 7,
  bool disableAnimations = false,
}) {
  final Widget banner = SizedBox(
    width: width,
    height: height,
    child: UnyoAnimatedImageBanner(
      imageUrl: 'https://example.test/banner.jpg',
      segmentDuration: segmentDuration,
      random: math.Random(randomSeed),
    ),
  );
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: disableAnimations
            ? MediaQuery(
                data: const MediaQueryData(disableAnimations: true),
                child: banner,
              )
            : banner,
      ),
    ),
  );
}

void main() {
  testWidgets('camera never jumps at a segment join', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_banner(width: 800, height: 300));

      final Finder transformFinder = find.descendant(
        of: find.byType(UnyoAnimatedImageBanner),
        matching: find.byType(Transform),
      );

      Matrix4 readTransform() {
        final Iterable<Element> elements = transformFinder.evaluate();
        for (final Element element in elements) {
          final Matrix4 matrix = (element.widget as Transform).transform;
          if ((matrix.getMaxScaleOnAxis() - 1).abs() > 1e-9) {
            return matrix;
          }
        }
        throw StateError('no scale transform found');
      }
      Offset previousCenter = tester.getCenter(find.byType(Image));
      double previousScale = readTransform().getMaxScaleOnAxis();
      double maxJump = 0;
      double minScale = previousScale;
      double maxScale = previousScale;
      bool zoomedIn = false;
      bool zoomedOut = false;

      // 16 ms frames over ~3 s: two segment joins at 1 s and 2 s.
      for (int frame = 0; frame < 190; frame++) {
        await tester.pump(const Duration(milliseconds: 16));

        final Offset center = tester.getCenter(find.byType(Image));
        final double scale = readTransform().getMaxScaleOnAxis();
        maxJump = math.max(maxJump, (center - previousCenter).distance);
        minScale = math.min(minScale, scale);
        maxScale = math.max(maxScale, scale);
        zoomedIn = zoomedIn || scale > 1.5;
        zoomedOut = zoomedOut || scale < 1.25;

        previousCenter = center;
        previousScale = scale;
      }

      // The camera keeps moving (it is not frozen) and breathes through both
      // zoom targets, so it really crossed at least two joins...
      expect(maxScale, greaterThan(1.5));
      expect(minScale, lessThan(1.25));
      expect(zoomedIn && zoomedOut, isTrue);
      expect(previousScale, greaterThanOrEqualTo(1.2));
      // ...without a discontinuity: a jump would be tens of pixels while the
      // fastest legitimate frame moves ~2 px.
      expect(maxJump, lessThan(5));
    });
  });

  testWidgets('disableAnimations freezes the camera on a static pose', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _banner(width: 800, height: 300, disableAnimations: true),
      );

      final Finder transformFinder = find.descendant(
        of: find.byType(UnyoAnimatedImageBanner),
        matching: find.byType(Transform),
      );
      Matrix4 readTransform() {
        final Iterable<Element> elements = transformFinder.evaluate();
        for (final Element element in elements) {
          final Matrix4 matrix = (element.widget as Transform).transform;
          if ((matrix.getMaxScaleOnAxis() - 1).abs() > 1e-9) {
            return matrix;
          }
        }
        throw StateError('no scale transform found');
      }
      final Matrix4 initial = readTransform().clone();
      final Offset initialCenter = tester.getCenter(find.byType(Image));

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 2));

      expect(readTransform(), initial);
      expect(tester.getCenter(find.byType(Image)), initialCenter);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });
}

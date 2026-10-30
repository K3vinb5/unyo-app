import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/styled/banner_camera.dart';

void main() {
  group('BannerCamera', () {
    test('starts on a real pose instead of the top-left corner', () {
      final BannerCamera camera = BannerCamera(random: math.Random(1))..start();

      expect(camera.begin.scale, 1.2);
      expect(camera.end.scale, 1.55);
      expect(camera.begin.pan, isNot(Offset.zero));
      expect(camera.frameAt(0).pan, camera.begin.pan);
    });

    test('each segment begins exactly where the previous one ended', () {
      final BannerCamera camera = BannerCamera(random: math.Random(7))..start();

      for (int segment = 0; segment < 20; segment++) {
        final BannerPose last = camera.frameAt(1);
        expect(last.scale, camera.end.scale);
        expect(last.pan, camera.end.pan);

        camera.advanceSegment();
        final BannerPose first = camera.frameAt(0);

        expect(first.scale, closeTo(last.scale, 1e-12));
        expect(first.pan.dx, closeTo(last.pan.dx, 1e-12));
        expect(first.pan.dy, closeTo(last.pan.dy, 1e-12));
      }
    });

    test('zoom targets alternate between the band edges', () {
      final BannerCamera camera = BannerCamera(random: math.Random(3))..start();

      for (int segment = 0; segment < 6; segment++) {
        final bool zoomingIn = camera.end.scale > camera.begin.scale;
        expect(camera.begin.scale, zoomingIn ? 1.2 : 1.55);
        expect(camera.end.scale, zoomingIn ? 1.55 : 1.2);
        camera.advanceSegment();
      }
    });

    test('pan progress is monotonic inside a segment', () {
      final BannerCamera camera = BannerCamera(random: math.Random(11))..start();

      for (int segment = 0; segment < 5; segment++) {
        final Offset start = camera.frameAt(0).pan;
        double previousDistance = 0;
        for (int step = 0; step <= 20; step++) {
          final Offset pan = camera.frameAt(step / 20).pan;
          final double distance = (pan - start).distance;
          expect(distance, greaterThanOrEqualTo(previousDistance - 1e-12));
          previousDistance = distance;
        }
        expect(previousDistance, greaterThan(0));
        camera.advanceSegment();
      }
    });

    test('random pan never leaves the available travel', () {
      final BannerCamera camera = BannerCamera(random: math.Random(5))..start();

      for (int segment = 0; segment < 50; segment++) {
        expect(camera.begin.pan.dx.abs(), lessThanOrEqualTo(1));
        expect(camera.begin.pan.dy.abs(), lessThanOrEqualTo(1));
        expect(camera.end.pan.dx.abs(), lessThanOrEqualTo(1));
        expect(camera.end.pan.dy.abs(), lessThanOrEqualTo(1));
        camera.advanceSegment();
      }
    });

    test('pan travel is anchored to the tightest zoom, not the live one', () {
      const BannerPose pose = BannerPose(scale: 1.55, pan: Offset(1, 1));
      final Offset pixels = pose.panInPixels(const Size(800, 300), 1.2);

      expect(pixels.dx, closeTo(80, 1e-12));
      expect(pixels.dy, closeTo(30, 1e-12));
    });
  });
}

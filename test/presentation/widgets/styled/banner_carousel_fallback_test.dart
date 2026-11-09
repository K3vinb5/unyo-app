import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/banner_carousel_skeleton.dart';
import 'package:unyo/presentation/widgets/styled/banner_carousel_fallback.dart';

import '../skeleton/support/widget_harness.dart';

/// WP #166 live evidence §1 3a: MAL/Jikan v4 exposes no banner asset, so the
/// browse screens emitted `banners: []` and the banner slot shimmered forever.
/// The slot must fall back once the first load settled, and must never fake a
/// banner out of an empty `bannerImage`.
void main() {
  group('bannerHeaderMode', () {
    test('first load without art keeps the skeleton (it is still loading)', () {
      expect(
        bannerHeaderMode(isLoading: true, hasBanners: false),
        BannerHeaderMode.skeleton,
      );
    });

    test('art shows the carousel, loading or not', () {
      expect(
        bannerHeaderMode(isLoading: false, hasBanners: true),
        BannerHeaderMode.carousel,
      );
      expect(
        bannerHeaderMode(isLoading: true, hasBanners: true),
        BannerHeaderMode.carousel,
      );
    });

    test('loaded without art falls back instead of shimmering forever', () {
      expect(
        bannerHeaderMode(isLoading: false, hasBanners: false),
        BannerHeaderMode.fallback,
      );
    });
  });

  group('BannerCarouselFallback', () {
    testWidgets('paints the themed band in the carousel footprint', (
      tester,
    ) async {
      await pumpSkeletonHarness(tester, const BannerCarouselFallback());

      final Finder fallback = find.byKey(
        const ValueKey<String>('banner-carousel-fallback'),
      );
      expect(fallback, findsOneWidget);
      expect(
        find.byType(BannerCarouselSkeleton),
        findsNothing,
        reason: 'a loaded provider without banner art must not keep the skeleton',
      );
      expect(
        tester.getSize(fallback).height,
        520,
        reason: 'same height as the carousel, so the rows below do not jump',
      );
    });
  });
}

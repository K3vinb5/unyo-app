import 'package:flutter_test/flutter_test.dart';
import 'package:unyo/presentation/widgets/styled/unyo_banner_carousel.dart';

/// The browse banner slot's three states, resolved from the cubits' flags.
///
/// WP #166 live evidence §1 3a: MAL/Jikan v4 exposes no banner asset, so the
/// slot shimmered forever for that provider. It now counts a card's cover as
/// hero art (the cubits keep `banner OR cover`), so the only two outcomes once
/// the first load settled are the carousel and — when the provider gave no art
/// at all — a collapsed slot. The old translucent 520-high fallback band is
/// gone with `BannerCarouselFallback`; reserving that space with no content in
/// it was the user-reported defect.
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

    test('loaded without any art collapses the slot instead of a band', () {
      expect(
        bannerHeaderMode(isLoading: false, hasBanners: false),
        BannerHeaderMode.hidden,
        reason: 'no art means no slot: the page starts at the button row',
      );
    });
  });
}

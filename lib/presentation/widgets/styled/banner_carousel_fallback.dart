import 'package:material_ui/material_ui.dart';

/// What the browse screens' banner slot shows (WP #166).
///
/// `UnyoBannerCarousel` needs banner art, and MAL/Jikan v4 has **no banner
/// asset**: `MalAnimeModel.fromNode` sets `bannerImage: ''`, the cubits keep
/// only cards with a banner, so `state.banners` is empty for that provider and
/// the slot used to render [BannerCarouselSkeleton] forever — a shimmering
/// 520-high block that never resolves (live evidence:
/// `research/unyo-166-mal-metadata-proof/EVIDENCE.md` §1 3a).
///
/// The slot therefore has three states: the carousel when the provider has
/// banner art, the skeleton **only** while the first load is still running, and
/// a quiet themed panel otherwise. AniList/Shikimori titles whose banner is
/// null take the same path — the state is derived from the loaded data, not
/// from the provider name.
enum BannerHeaderMode {
  /// First load in flight and no banner art yet.
  skeleton,

  /// The loaded provider has banner art.
  carousel,

  /// Loaded, and the provider exposes no banner art.
  fallback,
}

/// Resolves the banner slot state from the cubit's flags. Pulled out of the two
/// screens so the rule is one place and directly testable.
///
/// [isLoading] is the cubits' first-load flag (false once the first refresh
/// settled, success or failure); a provider switch clears the lists without
/// flipping it back, so a switch shows the fallback rather than a shimmer.
BannerHeaderMode bannerHeaderMode({
  required bool isLoading,
  required bool hasBanners,
}) {
  if (hasBanners) return BannerHeaderMode.carousel;
  return isLoading ? BannerHeaderMode.skeleton : BannerHeaderMode.fallback;
}

/// The no-art banner slot: the carousel's own 520-high box (350 banner + text
/// block) so the button row underneath does not jump between providers, painted
/// with the theme's tones instead of a shimmer.
///
/// Nothing is faked here — no borrowed cover stretched into a banner and no
/// scaffold text: MAL exposes no banner asset, so the honest state is a themed
/// band that reads as "this provider has no hero art".
class BannerCarouselFallback extends StatelessWidget {
  const BannerCarouselFallback({
    super.key,
    this.carouselHeight = 520,
    this.horizontalPadding = 50,
  });

  /// Mirrors `BannerCarouselSkeleton.carouselHeight` / `UnyoBannerCarousel`.
  final double carouselHeight;

  /// Mirrors the carousel's `EdgeInsets.symmetric(horizontal: 50.0.r)`.
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = ColorScheme.of(context);
    return Container(
      key: const ValueKey<String>('banner-carousel-fallback'),
      height: carouselHeight,
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.secondary.withValues(alpha: 0.3),
          width: 2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colors.secondary.withValues(alpha: 0.18),
            colors.primary.withValues(alpha: 0.10),
          ],
        ),
      ),
    );
  }
}

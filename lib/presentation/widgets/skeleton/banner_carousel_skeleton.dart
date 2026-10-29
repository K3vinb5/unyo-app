import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';

/// Mirrors `widgets/styled/unyo_banner_carousel.dart` ([UnyoBannerCarousel]):
/// the 520-high carousel box (350-high banner + text block) and the page
/// indicators underneath.
///
/// The text block follows `_buildCurrentPageText`: the title row with the score
/// pill at the far right, then the description lines (the real text shows up to
/// six, two or three in practice).
class BannerCarouselSkeleton extends StatelessWidget {
  const BannerCarouselSkeleton({
    super.key,
    this.bannerHeight = 350,
    this.carouselHeight = 520,
    this.titleAndLines = 3,
    this.indicatorCount = 5,
    this.horizontalPadding = 50,
  });

  final double bannerHeight;
  final double carouselHeight;

  /// Description lines under the title (the real widget shows up to 6).
  final int titleAndLines;
  final int indicatorCount;

  /// `unyo_banner_carousel.dart` - `EdgeInsets.symmetric(horizontal: 50.0.r)`
  /// around both the banner page and the text block.
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: carouselHeight,
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: SkeletonBlock(height: bannerHeight, borderRadius: 20),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          SkeletonBlock(width: 260, height: 18),
                          Spacer(),
                          SkeletonBlock(width: 50, height: 25, borderRadius: 8),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...List<Widget>.generate(
                        titleAndLines,
                        (int index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: index == titleAndLines - 1
                              // The last line of a paragraph is a short one.
                              ? const SkeletonBlock(width: 420, height: 12)
                              : const SkeletonBlock(height: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(
            indicatorCount,
            // The real widget draws the active indicator 8x8 (6x6 inactive);
            // reserve the larger box so the swap cannot shift the layout.
            (int index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: SkeletonBlock(width: 8, height: 8, borderRadius: 4),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';

/// Mirrors `widgets/styled/unyo_banner_carousel.dart` ([UnyoBannerCarousel]):
/// the 520-high carousel box (350-high banner + text block) and the page
/// indicators underneath.
class BannerCarouselSkeleton extends StatelessWidget {
  const BannerCarouselSkeleton({
    super.key,
    this.bannerHeight = 350,
    this.carouselHeight = 520,
    this.titleAndLines = 3,
    this.indicatorCount = 5,
  });

  final double bannerHeight;
  final double carouselHeight;

  /// Description lines under the title (the real widget shows up to 6).
  final int titleAndLines;
  final int indicatorCount;

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
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: SkeletonBlock(
                  height: bannerHeight,
                  borderRadius: 20,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
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
                      const SizedBox(height: 12),
                      ...List.generate(
                        titleAndLines,
                        (index) => const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: SkeletonBlock(height: 12),
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
          children: List.generate(
            indicatorCount,
            (index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: SkeletonBlock(width: 6, height: 6, borderRadius: 3),
            ),
          ),
        ),
      ],
    );
  }
}

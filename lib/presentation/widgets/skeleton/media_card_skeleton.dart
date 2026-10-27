import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_metrics.dart';

/// Mirrors `widgets/styled/media_card.dart` ([MediaCard]): cover, title row and
/// meta row, sized with the constants the real card uses.
class MediaCardSkeleton extends StatelessWidget {
  const MediaCardSkeleton({
    super.key,
    this.width = MediaCardMetrics.width,
    this.height = MediaCardMetrics.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SkeletonBlock(
            width: MediaCardMetrics.coverWidth,
            height: MediaCardMetrics.coverHeight,
            borderRadius: MediaCardMetrics.coverRadius,
          ),
          SkeletonBlock(
            width: MediaCardMetrics.coverWidth,
            height: MediaCardMetrics.titleRowHeight,
            borderRadius: 6,
          ),
          SkeletonBlock(
            width: MediaCardMetrics.coverWidth,
            height: MediaCardMetrics.metaRowHeight,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}

/// Mirrors `widgets/styled/anime_card_list.dart` / `manga_card_list.dart`:
/// a section header plus a horizontal row of cards.
///
/// Used for every `(loaded, list)` section tuple on the browse and details
/// screens, and for the character row (same header + 260-high strip).
class CardRowSkeleton extends StatelessWidget {
  const CardRowSkeleton({
    super.key,
    this.cardCount = 6,
    this.showHeader = true,
    this.rowHeight = CardRowMetrics.rowHeight,
  });

  final int cardCount;
  final bool showHeader;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          const Row(
            children: [
              SkeletonBlock(width: 220, height: 22),
              SizedBox(width: 10),
              SkeletonBlock(width: 60, height: 13),
            ],
          ),
          const SizedBox(height: CardRowMetrics.headerGap),
        ],
        SizedBox(
          height: rowHeight,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cardCount,
            itemBuilder:
                (context, index) => const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: MediaCardSkeleton(),
                ),
          ),
        ),
      ],
    );
  }
}

/// Mirrors the vertical card grids of `screens/media_list_screen.dart` and
/// `screens/calendar_screen.dart`.
///
/// Both screens use [mediaGridDelegate] as well, so the placeholder and the
/// real grid can never disagree about cell size.
class MediaGridSkeleton extends StatelessWidget {
  const MediaGridSkeleton({super.key, this.itemCount = 12});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: mediaGridDelegate,
      itemCount: itemCount,
      itemBuilder:
          (context, index) => const SizedBox(
            width: 165,
            child: MediaCardSkeleton(),
          ),
    );
  }
}

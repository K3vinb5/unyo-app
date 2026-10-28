import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_metrics.dart';

/// Mirrors `widgets/styled/media_card.dart` ([MediaCard]): cover, the score
/// badge on its bottom-right corner, title row and meta row, sized with the
/// constants the real card uses.
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
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              SkeletonBlock(
                width: MediaCardMetrics.coverWidth,
                height: MediaCardMetrics.coverHeight,
                borderRadius: MediaCardMetrics.coverRadius,
              ),
              SkeletonBlock(
                width: MediaCardMetrics.badgeWidth,
                height: MediaCardMetrics.badgeHeight,
                borderRadius: MediaCardMetrics.badgeRadius,
              ),
            ],
          ),
          SizedBox(
            width: MediaCardMetrics.coverWidth,
            height: MediaCardMetrics.titleRowHeight,
            child: Center(
              child: SkeletonBlock(
                width: MediaCardMetrics.titlePillWidth,
                height: MediaCardMetrics.titlePillHeight,
                borderRadius: 6,
              ),
            ),
          ),
          SizedBox(
            width: MediaCardMetrics.coverWidth,
            height: MediaCardMetrics.metaRowHeight,
            child: Center(
              child: SkeletonBlock(
                width: MediaCardMetrics.metaPillWidth,
                height: MediaCardMetrics.metaPillHeight,
                borderRadius: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The two `‹ ›` chevrons that close every card row header
/// (`widgets/styled/media_list_arrows.dart`).
class _RowHeaderArrows extends StatelessWidget {
  const _RowHeaderArrows();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonBlock(
          width: CardRowMetrics.arrowSize,
          height: CardRowMetrics.arrowSize,
          borderRadius: 6,
        ),
        SizedBox(width: CardRowMetrics.arrowGap),
        SkeletonBlock(
          width: CardRowMetrics.arrowSize,
          height: CardRowMetrics.arrowSize,
          borderRadius: 6,
        ),
      ],
    );
  }
}

/// Mirrors `widgets/styled/anime_card_list.dart` / `manga_card_list.dart`:
/// a section header (title + entry count inline at the left, the row arrows at
/// the right) plus a horizontal strip of cards.
///
/// Used for every `(loaded, list)` section tuple on the browse and details
/// screens, and for the character row (same header + 260-high strip).
class CardRowSkeleton extends StatelessWidget {
  const CardRowSkeleton({
    super.key,
    this.cardCount = 8,
    this.showHeader = true,
    this.showArrows = true,
    this.rowHeight = CardRowMetrics.rowHeight,
  });

  /// The loaded strip fits eight 152.5-wide cards on a desktop window, so the
  /// placeholder does too - six wide cards used to drift away from it.
  final int cardCount;
  final bool showHeader;

  /// The real header only paints its arrows once the list is wider than the
  /// viewport; callers mirroring an always-scrollable row keep them.
  final bool showArrows;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          SizedBox(
            height: CardRowMetrics.headerHeight,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SkeletonBlock(width: 220, height: 22),
                const SizedBox(width: 10),
                const SkeletonBlock(width: 60, height: 13),
                const Spacer(),
                if (showArrows) const _RowHeaderArrows(),
              ],
            ),
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
            // No gap between the cards: the real strip butts them together and
            // lets each card's own 152.5 width provide the 12.5 gutter.
            itemBuilder: (BuildContext context, int index) =>
                const MediaCardSkeleton(),
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
  const MediaGridSkeleton({super.key, this.itemCount = 16});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: mediaGridDelegate,
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) =>
          const SizedBox(width: 165, child: MediaCardSkeleton()),
    );
  }
}

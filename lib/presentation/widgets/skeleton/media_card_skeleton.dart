import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_metrics.dart';
import 'package:unyo/presentation/widgets/styled/media_cover_silhouette.dart';

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
          // The same single silhouette the loaded card uses: nothing in the
          // placeholder may paint outside the cover's rounded rectangle (the
          // score badge used to poke past its corner).
          MediaCoverSilhouette(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                // Square on purpose: the silhouette above is the shape. A
                // second rounded block inside it would antialias the same
                // edge twice (the #103/#119 drift guard).
                SkeletonBlock(
                  width: MediaCardMetrics.coverWidth,
                  height: MediaCardMetrics.coverHeight,
                  borderRadius: 0,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  // The same flush leaf as the loaded card's pill, in one block:
                  // the shared `MediaBadgeClipper` fillet merges an opaque badge
                  // into the cover's arc, but on a flat placeholder it carves a
                  // notch out of the cover's own outline. The silhouette above
                  // is the only shape the placeholder needs (WP #119).
                  child: Padding(
                    padding: EdgeInsets.all(MediaCardMetrics.badgeInset),
                    child: SkeletonBlock(
                      width: MediaCardMetrics.badgeWidth,
                      height: MediaCardMetrics.badgeHeight,
                      shape: MediaCardMetrics.badgeBorderRadius,
                    ),
                  ),
                ),
              ],
            ),
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
    this.cardCount,
    this.showHeader = true,
    this.showArrows = true,
    this.rowHeight = CardRowMetrics.rowHeight,
  });

  /// Explicit override for a caller that needs a fixed amount of placeholders;
  /// `null` (the default) derives the count from the strip width, so the
  /// placeholder follows the viewport instead of a hard-coded eight cards.
  final int? cardCount;

  /// How many cards fit when the width is unknown (an unbounded strip). The
  /// historical value: eight 152.5-wide cards, the design-size desktop strip
  /// only fits seven, so the eighth is the one that runs past the edge.
  static const int fallbackCardCount = 8;

  /// Guards against an absurd window size creating thousands of widgets: a
  /// skeleton must stay cheaper than the content it replaces.
  static const int minCardCount = 2;
  static const int maxCardCount = 24;

  /// `(width / card width).ceil() + 1` - the same arithmetic the loaded
  /// horizontally scrollable strip answers with, plus one card so the
  /// placeholder runs past the right edge exactly like the real row.
  static int cardsForWidth(double maxWidth) {
    if (!maxWidth.isFinite) {
      return fallbackCardCount;
    }
    return ((maxWidth / MediaCardMetrics.width).ceil() + 1).clamp(
      minCardCount,
      maxCardCount,
    );
  }

  final bool showHeader;

  /// The real header only paints its arrows once the list is wider than the
  /// viewport; callers mirroring an always-scrollable row keep them.
  final bool showArrows;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Inside `CardRowFrame` the strip width is the content width, so the
        // count follows the frame instead of the screen size.
        final int count = cardCount ?? cardsForWidth(constraints.maxWidth);
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
                itemCount: count,
                // No gap between the cards: the real strip butts them together
                // and lets each card's own 152.5 width provide the 12.5 gutter.
                itemBuilder: (BuildContext context, int index) =>
                    const MediaCardSkeleton(),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Mirrors the vertical card grids of `screens/media_list_screen.dart` and
/// `screens/calendar_screen.dart`.
///
/// Both screens use [mediaGridDelegate] as well, so the placeholder and the
/// real grid can never disagree about cell size.
class MediaGridSkeleton extends StatelessWidget {
  const MediaGridSkeleton({super.key, this.itemCount});

  /// Explicit override; `null` (the default) derives the cell count from the
  /// viewport so the placeholder fills the grid instead of always painting 16.
  final int? itemCount;

  /// How many cells a viewport of unknown size gets. Both hosts of this
  /// skeleton are inside a `1.sh - 135` box, so the fallback is defensive.
  static const int fallbackCellCount = 16;

  /// Clamp: a 4000x4000 window must not paint hundreds of cells.
  static const int minCellCount = 1;
  static const int maxCellCount = 40;

  /// Mirrors `SliverGridDelegateWithMaxCrossAxisExtent.getLayout`
  /// (`crossAxisCount = (extent / (maxCrossAxisExtent + crossAxisSpacing))
  /// .ceil()`); the row count divides the height by the cell pitch the same
  /// way, so `ceil` always paints the partially visible last row.
  static int cellsForSize(
    Size size, {
    SliverGridDelegateWithMaxCrossAxisExtent delegate = mediaGridDelegate,
  }) {
    final double maxCrossAxisExtent = delegate.maxCrossAxisExtent;
    final double? mainAxisExtent = delegate.mainAxisExtent;
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        mainAxisExtent == null) {
      return fallbackCellCount;
    }
    final int columns =
        (size.width / (maxCrossAxisExtent + delegate.crossAxisSpacing)).ceil();
    final int rows = (size.height / (mainAxisExtent + delegate.mainAxisSpacing))
        .ceil();
    return (columns * rows).clamp(minCellCount, maxCellCount);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int count =
            itemCount ??
            cellsForSize(Size(constraints.maxWidth, constraints.maxHeight));
        return GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: mediaGridDelegate,
          itemCount: count,
          itemBuilder: (BuildContext context, int index) =>
              const SizedBox(width: 165, child: MediaCardSkeleton()),
        );
      },
    );
  }
}

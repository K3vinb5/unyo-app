import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';

import 'support/widget_harness.dart';

void main() {
  /// The harness gives every root widget a 1200-wide box.
  const double harnessWidth = 1200;

  Finder block({
    double? width,
    double? height,
    bool nullWidth = false,
  }) => find.byWidgetPredicate(
    (Widget widget) =>
        widget is SkeletonBlock &&
        (width == null || widget.width == width) &&
        (height == null || widget.height == height) &&
        (!nullWidth || widget.width == null),
  );

  group('MediaCardSkeleton', () {
    testWidgets('mirrors the card: cover, score badge and two text lines', (
      tester,
    ) async {
      await pumpSkeletonHarness(tester, const MediaCardSkeleton());

      expect(
        tester.getSize(find.byType(MediaCardSkeleton)),
        const Size(MediaCardMetrics.width, MediaCardMetrics.height),
      );
      // cover + badge + title line + meta line
      expect(find.byType(SkeletonBlock), findsNWidgets(4));
      expect(
        tester.getSize(find.byType(SkeletonBlock).first),
        const Size(MediaCardMetrics.coverWidth, MediaCardMetrics.coverHeight),
      );

      final Finder badge = block(
        width: MediaCardMetrics.badgeWidth,
        height: MediaCardMetrics.badgeHeight,
      );
      expect(badge, findsOneWidget);
      final Rect coverRect = tester.getRect(find.byType(SkeletonBlock).first);
      final Rect badgeRect = tester.getRect(badge);
      expect(badgeRect.right, coverRect.right);
      expect(badgeRect.bottom, coverRect.bottom);

      // The text placeholders are lines, not full-width slabs.
      expect(
        tester.getSize(
          block(
            width: MediaCardMetrics.titlePillWidth,
            height: MediaCardMetrics.titlePillHeight,
          ),
        ),
        const Size(
          MediaCardMetrics.titlePillWidth,
          MediaCardMetrics.titlePillHeight,
        ),
      );
      expect(
        tester.getSize(
          block(
            width: MediaCardMetrics.metaPillWidth,
            height: MediaCardMetrics.metaPillHeight,
          ),
        ),
        const Size(
          MediaCardMetrics.metaPillWidth,
          MediaCardMetrics.metaPillHeight,
        ),
      );
    });
  });

  group('CardRowSkeleton', () {
    testWidgets('header mirrors the loaded one: title, count, arrows right', (
      tester,
    ) async {
      await pumpSkeletonHarness(tester, const CardRowSkeleton(cardCount: 3));

      final Rect title = tester.getRect(block(width: 220, height: 22));
      final Rect count = tester.getRect(block(width: 60, height: 13));
      final Finder arrows = block(
        width: CardRowMetrics.arrowSize,
        height: CardRowMetrics.arrowSize,
      );

      expect(count.left, greaterThan(title.right), reason: 'count is inline');
      expect(count.bottom, title.bottom, reason: 'title and count share a baseline');
      expect(arrows, findsNWidgets(2));
      final Rect firstArrow = tester.getRect(arrows.first);
      final Rect lastArrow = tester.getRect(arrows.last);
      expect(firstArrow.left, greaterThan(count.right));
      expect(lastArrow.left, greaterThan(firstArrow.right));
      expect(
        tester.getRect(arrows.last).right,
        harnessWidth,
        reason: 'the arrows close the header, as in the loaded row',
      );

      expect(
        tester.getSize(find.byType(CardRowSkeleton)).height,
        CardRowMetrics.headerHeight +
            CardRowMetrics.headerGap +
            CardRowMetrics.rowHeight,
      );
    });

    testWidgets('defaults to the eight cards the loaded strip fits', (
      tester,
    ) async {
      await pumpSkeletonHarness(tester, const CardRowSkeleton());

      final SliverChildBuilderDelegate delegate =
          tester.widget<ListView>(find.byType(ListView)).childrenDelegate
              as SliverChildBuilderDelegate;
      expect(delegate.childCount, 8);

      // Cards butt together: the pitch is exactly the real card width.
      final List<MediaCardSkeleton> cards = tester
          .widgetList<MediaCardSkeleton>(find.byType(MediaCardSkeleton))
          .toList();
      expect(cards.length, greaterThan(1));
      final Rect first = tester.getRect(find.byType(MediaCardSkeleton).first);
      final Rect second = tester.getRect(find.byType(MediaCardSkeleton).at(1));
      expect(second.left - first.left, MediaCardMetrics.width);
    });

    testWidgets('can drop the header, the arrows and the extra cards', (
      tester,
    ) async {
      await pumpSkeletonHarness(
        tester,
        const CardRowSkeleton(cardCount: 2, showHeader: false),
      );

      expect(find.byType(MediaCardSkeleton), findsNWidgets(2));
      expect(
        tester.getSize(find.byType(CardRowSkeleton)).height,
        CardRowMetrics.rowHeight,
      );
    });
  });

  group('MediaGridSkeleton', () {
    testWidgets('uses the same grid delegate and paints a poster per cell', (
      tester,
    ) async {
      await pumpSkeletonHarness(
        tester,
        const SizedBox(height: 700, child: MediaGridSkeleton(itemCount: 6)),
      );

      final GridView grid = tester.widget<GridView>(find.byType(GridView));
      expect(identical(grid.gridDelegate, mediaGridDelegate), isTrue);
      expect(find.byType(MediaCardSkeleton), findsWidgets);

      // The regression: the poster block must be there, at poster size.
      final Finder poster = find.descendant(
        of: find.byType(MediaCardSkeleton).first,
        matching: block(
          width: MediaCardMetrics.coverWidth,
          height: MediaCardMetrics.coverHeight,
        ),
      );
      expect(poster, findsOneWidget);
      expect(
        tester.getSize(poster),
        const Size(MediaCardMetrics.coverWidth, MediaCardMetrics.coverHeight),
      );
      expect(
        tester.getSize(poster).height,
        greaterThan(tester.getSize(poster).width),
        reason: 'a poster is portrait, never a square or a text slab',
      );
    });
  });

  group('BannerCarouselSkeleton', () {
    testWidgets('paints the banner and the full-width description lines', (
      tester,
    ) async {
      await pumpSkeletonHarness(tester, const BannerCarouselSkeleton());

      // 520-high carousel box + one 8-high indicator row.
      expect(tester.getSize(find.byType(BannerCarouselSkeleton)).height, 528);

      final Finder banner = block(height: 350);
      expect(banner, findsOneWidget);
      expect(
        tester.getSize(banner).width,
        harnessWidth - 2 * 50,
        reason: 'the banner fills the carousel between its 50px gutters',
      );

      // Quote: two full description lines plus a shorter last one.
      final Finder fullLines = block(height: 12);
      expect(fullLines, findsNWidgets(3));
      expect(tester.getSize(fullLines.at(0)).width, greaterThan(400));
      expect(tester.getSize(fullLines.at(1)).width, greaterThan(400));
      expect(tester.getSize(fullLines.at(2)).width, 420);
    });
  });

  group('DetailHeaderSkeleton', () {
    testWidgets('mirrors the details banner and its 140x200.5 cover', (
      tester,
    ) async {
      await pumpSkeletonHarness(tester, const DetailHeaderSkeleton());

      expect(tester.getSize(find.byType(DetailHeaderSkeleton)).height, 300);
      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is SkeletonBlock &&
              widget.width == 140 &&
              widget.height == 200.5,
        ),
        findsOneWidget,
      );
      expect(
        tester.getSize(block(height: 300)).width,
        greaterThan(0),
        reason: 'the banner block used to collapse to zero width',
      );
    });
  });

  group('EpisodeRowSkeleton', () {
    testWidgets('keeps the landscape 16:9 thumbnail and the row divider', (
      tester,
    ) async {
      await pumpSkeletonHarness(
        tester,
        const Column(children: [EpisodeRowSkeleton(showDivider: true)]),
      );

      // divider (1) + 12 top + 70 row + 12 bottom
      expect(tester.getSize(find.byType(EpisodeRowSkeleton)).height, 95);

      final Finder divider = block(height: 1);
      expect(divider, findsOneWidget);
      expect(
        tester.getSize(divider).width,
        harnessWidth - 2 * 40,
        reason: 'the divider is inset by 40 on both sides, like the real one',
      );

      final Size thumb = tester.getSize(
        block(width: EpisodeRowSkeleton.thumbnailWidth),
      );
      expect(thumb.width / thumb.height, closeTo(16 / 9, 0.01));
    });

    testWidgets('drops the divider on the first row', (tester) async {
      await pumpSkeletonHarness(
        tester,
        const Column(children: [EpisodeRowSkeleton()]),
      );

      expect(block(height: 1), findsNothing);
      expect(tester.getSize(find.byType(EpisodeRowSkeleton)).height, 82);
    });
  });

  group('ExtensionRowSkeleton', () {
    testWidgets('paints no leading circle and keeps the icon slot width', (
      tester,
    ) async {
      await pumpSkeletonHarness(
        tester,
        const Column(children: [ExtensionRowSkeleton()]),
      );

      // 70-high row + 8px bottom padding from the real button.
      expect(tester.getSize(find.byType(ExtensionRowSkeleton)).height, 78);
      expect(
        block(width: ExtensionRowSkeleton.iconSlotSize),
        findsNothing,
        reason: 'the loaded row has no icon to mirror',
      );

      // The pills still start where the loaded name/badges block starts.
      final Rect namePill = tester.getRect(block(width: 160, height: 16));
      expect(
        namePill.left,
        16 + 20 + ExtensionRowSkeleton.iconSlotSize + 14,
        reason: 'the reserved icon slot keeps the text at the loaded offset',
      );
      expect(block(width: 45, height: 45), findsOneWidget);
    });
  });

  group('MenuBarSkeleton', () {
    testWidgets('mirrors the rail, its avatar and its five icons', (
      tester,
    ) async {
      await pumpSkeletonHarness(tester, const MenuBarSkeleton());

      expect(
        tester.getSize(find.byType(MenuBarSkeleton)),
        const Size(
          MenuBarSkeleton.railWidth + 20,
          MenuBarSkeleton.railHeight + 15,
        ),
      );
      expect(block(width: MenuBarSkeleton.avatarSize), findsOneWidget);
      expect(block(width: MenuBarSkeleton.iconSize), findsNWidgets(5));
    });
  });

  group('DateTabRowSkeleton', () {
    testWidgets('mirrors the calendar date tabs above the grid', (
      tester,
    ) async {
      await pumpSkeletonHarness(tester, const DateTabRowSkeleton());

      expect(
        tester.getSize(find.byType(DateTabRowSkeleton)).height,
        DateTabRowSkeleton.barHeight,
      );
      expect(
        block(width: DateTabRowSkeleton.labelWidth),
        findsNWidgets(5),
        reason: 'the loaded bar shows five dates',
      );
      expect(
        block(height: DateTabRowSkeleton.indicatorHeight),
        findsOneWidget,
        reason: 'only the active tab is underlined',
      );
      expect(
        tester.getSize(block(height: DateTabRowSkeleton.dividerHeight)).width,
        harnessWidth,
        reason: 'the bar divider spans the full width',
      );
    });
  });

  group('ListTileSkeleton', () {
    testWidgets('lays out horizontally by default', (tester) async {
      await pumpSkeletonHarness(tester, const ListTileSkeleton());

      expect(tester.getSize(find.byType(ListTileSkeleton)).height, 64);
    });

    testWidgets('supports the vertical avatar layout of the login screen', (
      tester,
    ) async {
      await pumpSkeletonHarness(
        tester,
        const ListTileSkeleton(
          height: 200,
          leadingSize: 160,
          titleWidth: 120,
          vertical: true,
        ),
      );

      expect(tester.getSize(find.byType(ListTileSkeleton)).height, 200);
      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is SkeletonBlock &&
              widget.width == 160 &&
              widget.height == 160,
        ),
        findsOneWidget,
      );
    });
  });
}

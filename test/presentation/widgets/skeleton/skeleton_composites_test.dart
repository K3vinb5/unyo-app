import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';

import 'support/widget_harness.dart';

void main() {
  group('MediaCardSkeleton', () {
    testWidgets('mirrors the MediaCard box and its three text bars', (
      tester,
    ) async {
      await pumpSkeletonHarness(tester, const MediaCardSkeleton());

      expect(
        tester.getSize(find.byType(MediaCardSkeleton)),
        const Size(MediaCardMetrics.width, MediaCardMetrics.height),
      );
      expect(find.byType(SkeletonBlock), findsNWidgets(3));
      expect(
        tester.getSize(find.byType(SkeletonBlock).first),
        const Size(MediaCardMetrics.coverWidth, MediaCardMetrics.coverHeight),
      );
    });
  });

  group('CardRowSkeleton', () {
    testWidgets('renders a header plus the requested number of cards', (
      tester,
    ) async {
      await pumpSkeletonHarness(tester, const CardRowSkeleton(cardCount: 3));

      expect(find.byType(MediaCardSkeleton), findsNWidgets(3));
      // header (22) + gap (10) + card strip (260)
      expect(
        tester.getSize(find.byType(CardRowSkeleton)).height,
        22 + CardRowMetrics.headerGap + CardRowMetrics.rowHeight,
      );
    });

    testWidgets('can drop the header and keeps the 260-high strip', (
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
    testWidgets('uses the same grid delegate as the real grid screens', (
      tester,
    ) async {
      await pumpSkeletonHarness(
        tester,
        const SizedBox(height: 700, child: MediaGridSkeleton(itemCount: 6)),
      );

      final GridView grid = tester.widget<GridView>(find.byType(GridView));
      expect(identical(grid.gridDelegate, mediaGridDelegate), isTrue);
      expect(find.byType(MediaCardSkeleton), findsWidgets);
    });
  });

  group('BannerCarouselSkeleton', () {
    testWidgets('keeps the carousel height and shows page indicators', (
      tester,
    ) async {
      await pumpSkeletonHarness(tester, const BannerCarouselSkeleton());

      // 520-high carousel box + one 8-high indicator row.
      expect(tester.getSize(find.byType(BannerCarouselSkeleton)).height, 528);
      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is SkeletonBlock && widget.height == 350,
        ),
        findsOneWidget,
      );
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
    });
  });

  group('EpisodeRowSkeleton', () {
    testWidgets('mirrors the 70-high episode row', (tester) async {
      await pumpSkeletonHarness(
        tester,
        const Column(children: [EpisodeRowSkeleton()]),
      );

      // 70-high row + 12px bottom padding from the real button.
      expect(tester.getSize(find.byType(EpisodeRowSkeleton)).height, 82);
      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is SkeletonBlock &&
              widget.width == EpisodeRowSkeleton.thumbnailWidth,
        ),
        findsOneWidget,
      );
    });
  });

  group('ExtensionRowSkeleton', () {
    testWidgets('mirrors the 70-high extension row with its 52px icon', (
      tester,
    ) async {
      await pumpSkeletonHarness(
        tester,
        const Column(children: [ExtensionRowSkeleton()]),
      );

      // 70-high row + 8px bottom padding from the real button.
      expect(tester.getSize(find.byType(ExtensionRowSkeleton)).height, 78);
      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is SkeletonBlock && widget.width == 52 && widget.height == 52,
        ),
        findsOneWidget,
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

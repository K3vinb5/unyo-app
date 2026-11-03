import 'dart:math' as math;
import 'dart:ui' show PathMetric, Tangent;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/media_badge_clipper.dart';
import 'package:unyo/presentation/widgets/skeleton/media_card_skeleton.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_metrics.dart';
import 'package:unyo/presentation/widgets/styled/media_card.dart';

import '../skeleton/support/widget_harness.dart';

/// WP #109 / #119: the loaded card must present one continuous rounded
/// silhouette, and the score badge must be the original flush leaf — with its
/// right end handed over to the cover's corner arc instead of ending in a
/// square step.
void main() {
  MediaCard card({int score = 87}) => MediaCard(
    title: 'Cowboy Bebop',
    score: score,
    coverImage: '',
    onPressed: () {},
    status: 'FINISHED',
    year: '1998/04/03',
    format: 'TV',
    tag: 'media-card-109',
  );

  /// The badge is the only box in the card painted inside [MediaBadgeClipper].
  bool isBadgeClip(Widget widget) =>
      widget is ClipPath && widget.clipper is MediaBadgeClipper;

  /// The badge's own clip (the box painted with the theme's primary).
  final Finder badgeClip = find.byWidgetPredicate(isBadgeClip);

  final Finder coverClip = find.byWidgetPredicate(
    (Widget widget) =>
        widget is ClipRRect &&
        widget.borderRadius == MediaCardMetrics.coverBorderRadius,
  );

  group('cover silhouette', () {
    testWidgets('clips the cover stack, badge included', (tester) async {
      await pumpSkeletonHarness(tester, card());

      expect(
        badgeClip,
        findsOneWidget,
        reason: 'a scored card paints its badge',
      );
      expect(
        find.ancestor(of: badgeClip, matching: find.byType(ClipRRect)),
        findsOneWidget,
        reason: 'the badge must be painted inside the clipped cover stack',
      );

      final Rect coverRect = tester.getRect(coverClip);
      final Rect badgeRect = tester.getRect(badgeClip);
      expect(coverRect.width, MediaCardMetrics.coverWidth);
      expect(coverRect.height, MediaCardMetrics.coverHeight);
      // Width and height are text-driven (the badge hugs its score + star), so
      // they are not fixed metrics: the harness's Ahem glyphs are wider and
      // taller than the runtime font. What must hold is the placement.
      expect(badgeRect.width, lessThanOrEqualTo(MediaCardMetrics.coverWidth));
      expect(
        coverRect.contains(badgeRect.bottomRight - const Offset(0.01, 0.01)),
        isTrue,
        reason: 'the badge may not spill out of the cover silhouette',
      );

      // Flush, like the original leaf: the badge's bottom edge is the cover's
      // bottom edge and its right edge is the cover's right edge. The corner
      // merge happens in the badge's own outline, not by floating it inward.
      expect(MediaCardMetrics.badgeInset, 0);
      expect(coverRect.right - badgeRect.right, 0);
      expect(coverRect.bottom - badgeRect.bottom, 0);
    });

    testWidgets('paints no badge for an unrated card, silhouette unchanged', (
      tester,
    ) async {
      await pumpSkeletonHarness(tester, card(score: 0));

      expect(badgeClip, findsNothing);
      expect(
        coverClip,
        findsWidgets,
        reason: 'the silhouette does not depend on the score',
      );
    });

    testWidgets('the cover is clipped exactly once', (tester) async {
      await pumpSkeletonHarness(tester, card());

      // Nested clips at the same radius antialias the arc twice and soften it
      // into "straight, then a bend" — one silhouette, one clip (WP #119).
      expect(
        find.descendant(of: coverClip, matching: coverClip),
        findsNothing,
        reason: 'the cover stack must not clip itself a second time',
      );
    });

    testWidgets('skeleton and card agree on the silhouette', (tester) async {
      await pumpSkeletonHarness(tester, card(score: 0));
      final BorderRadiusGeometry cardRadius = tester
          .widget<ClipRRect>(coverClip.first)
          .borderRadius;

      await pumpSkeletonHarness(tester, const MediaCardSkeleton());
      expect(
        coverClip,
        findsOneWidget,
        reason: 'the skeleton clips its cover with the shared constant',
      );
      expect(tester.widget<ClipRRect>(coverClip).borderRadius, cardRadius);
    });
  });

  group('score badge outline', () {
    test('is the original leaf, not a stadium capsule', () {
      // Restored pre-#119 geometry: 50-radius top-left and bottom-right, square
      // bottom-left. Half-height corners (the round-3 capsule) are gone.
      const Radius radius = Radius.circular(50);
      expect(MediaCardMetrics.badgeCornerRadius, 50);
      expect(MediaCardMetrics.badgeBorderRadius.topLeft, radius);
      expect(MediaCardMetrics.badgeBorderRadius.bottomRight, radius);
      expect(MediaCardMetrics.badgeBorderRadius.topRight, Radius.zero);
      expect(MediaCardMetrics.badgeBorderRadius.bottomLeft, Radius.zero);
      // Far bigger than the box on purpose: the renderer clamps it, which is
      // what turns the top-left into a sweep that reaches the bottom-left point.
      expect(
        MediaCardMetrics.badgeCornerRadius,
        greaterThan(MediaCardMetrics.badgeHeight),
      );
    });

    test('the fillet is tangent to the top edge and to the cover arc', () {
      const double width = MediaCardMetrics.badgeWidth;
      const double height = MediaCardMetrics.badgeHeight;
      const double coverRadius = MediaCardMetrics.coverRadius;
      const double merge = MediaCardMetrics.badgeMergeRadius;
      final Offset arcCentre = const Offset(
        width - coverRadius,
        height - coverRadius,
      );
      final double reach =
          (coverRadius - merge) * (coverRadius - merge) -
          (merge - arcCentre.dy) * (merge - arcCentre.dy);
      expect(reach, greaterThan(0), reason: 'a fillet has to fit the corner');

      // Centre of the fillet: `merge` below the top edge and
      // `coverRadius - merge` from the arc centre — tangent to both.
      final Offset filletCentre = Offset(
        arcCentre.dx + math.sqrt(reach),
        merge,
      );
      expect(filletCentre.dy, merge);
      expect(
        (filletCentre - arcCentre).distance,
        closeTo(coverRadius - merge, 1e-9),
      );
      // It starts inside the badge, so the top edge really is handed over.
      expect(filletCentre.dx, lessThan(width));
      expect(filletCentre.dx, greaterThan(width - coverRadius));
    });

    test('the outline has no square top-right and hugs the cover arc', () {
      const Size size = Size(
        MediaCardMetrics.badgeWidth,
        MediaCardMetrics.badgeHeight,
      );
      final Path path = const MediaBadgeClipper().getClip(size);

      // The old glitch: a square corner at the badge's top-right, where the
      // flat top edge ran into the near-vertical cover arc.
      expect(
        path.contains(const Offset(45.9, 0.5)),
        isFalse,
        reason: 'the top-right must not reach the card edge as a square corner',
      );
      expect(
        path.contains(const Offset(46, 0.5)),
        isFalse,
        reason: 'nothing may be painted past the cover edge',
      );

      // Paint still exists on the top edge left of the fillet, on the bottom
      // edge and in the middle of the leaf.
      expect(path.contains(const Offset(20, 0.5)), isTrue);
      expect(path.contains(const Offset(10, 17.5)), isTrue);
      expect(path.contains(const Offset(23, 9)), isTrue);

      // Bottom-right is the cover's arc, not the badge's own smaller corner:
      // the point just inside the square corner lies outside the outline.
      expect(path.contains(const Offset(45.5, 17.5)), isFalse);
      expect(path.contains(const Offset(30, 17.5)), isTrue);
    });

    testWidgets('the skeleton placeholder paints the pill through the clipper', (
      tester,
    ) async {
      await pumpSkeletonHarness(tester, const MediaCardSkeleton());

      // Same treatment as the loaded card: the placeholder block is painted
      // inside `MediaBadgeClipper`, so the skeleton cannot show a shape the
      // loaded pill does not have (WP #119 — the plain leaf left a square
      // bottom-left corner on the loading card).
      expect(
        badgeClip,
        findsOneWidget,
        reason: 'the placeholder badge uses the shared clipper',
      );
      expect(
        find.ancestor(of: badgeClip, matching: find.byType(ClipRRect)),
        findsOneWidget,
        reason: 'the badge is painted inside the clipped cover stack',
      );
      final Finder badge = find.byWidgetPredicate(
        (Widget widget) =>
            widget is SkeletonBlock &&
            widget.width == MediaCardMetrics.badgeWidth &&
            widget.height == MediaCardMetrics.badgeHeight,
      );
      expect(
        find.descendant(of: badgeClip, matching: badge),
        findsOneWidget,
        reason: 'the placeholder block is what the clipper shapes',
      );
      // The block itself is square: the clipper is the single shape source, a
      // second rounded corner in the same box would antialias twice.
      expect(tester.widget<SkeletonBlock>(badge).shape, isNull);
      expect(tester.widget<SkeletonBlock>(badge).borderRadius, 0);

      final Rect skeletonBadge = tester.getRect(badge);
      expect(skeletonBadge.width, MediaCardMetrics.badgeWidth);
      expect(skeletonBadge.height, MediaCardMetrics.badgeHeight);
      final Rect coverRect = tester.getRect(coverClip);
      expect(coverRect.right - skeletonBadge.right, 0);
      expect(coverRect.bottom - skeletonBadge.bottom, 0);
    });

    testWidgets('card and skeleton badges paint the exact same outline', (
      tester,
    ) async {
      // The clipper is the one definition of the badge outline, so the loaded
      // pill and its placeholder resolve the identical path for the same box —
      // no square corner on one side and a merged corner on the other (WP #119).
      await pumpSkeletonHarness(tester, card());
      final MediaBadgeClipper cardClipper =
          tester.widget<ClipPath>(badgeClip).clipper! as MediaBadgeClipper;

      await pumpSkeletonHarness(tester, const MediaCardSkeleton());
      final MediaBadgeClipper skeletonClipper =
          tester.widget<ClipPath>(badgeClip).clipper! as MediaBadgeClipper;

      expect(skeletonClipper.shouldReclip(cardClipper), isFalse);
      expect(skeletonClipper.cornerRadius, cardClipper.cornerRadius);
      expect(skeletonClipper.coverRadius, cardClipper.coverRadius);
      expect(skeletonClipper.mergeRadius, cardClipper.mergeRadius);

      const Size box = Size(
        MediaCardMetrics.badgeWidth,
        MediaCardMetrics.badgeHeight,
      );
      final List<Offset> cardOutline = _sample(cardClipper.getClip(box));
      final List<Offset> skeletonOutline = _sample(
        skeletonClipper.getClip(box),
      );
      expect(skeletonOutline.length, cardOutline.length);
      for (int i = 0; i < cardOutline.length; i++) {
        expect(
          (skeletonOutline[i] - cardOutline[i]).distance,
          lessThan(0.01),
          reason: 'the two outlines diverge at sample $i',
        );
      }

      // And that shared outline is the cover's corner, not a square step: the
      // bottom-right of the badge box lies outside it, the top edge stops
      // before the right edge for the fillet.
      final Path outline = skeletonClipper.getClip(box);
      expect(outline.contains(const Offset(45.5, 17.5)), isFalse);
      expect(
        outline.contains(const Offset(45.5, 0.5)),
        isFalse,
        reason: 'the top edge hands over to the cover arc, no square top-right',
      );
      expect(outline.contains(const Offset(20, 0.5)), isTrue);
    });
  });
}

/// Samples a path outline every half pixel so two paths can be compared
/// geometrically instead of by the widget tree alone.
List<Offset> _sample(Path path) {
  final List<Offset> points = <Offset>[];
  for (final PathMetric metric in path.computeMetrics()) {
    for (double d = 0; d <= metric.length; d += 0.5) {
      final Tangent? tangent = metric.getTangentForOffset(d);
      if (tangent != null) {
        points.add(tangent.position);
      }
    }
  }
  return points;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/media_card_skeleton.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_metrics.dart';
import 'package:unyo/presentation/widgets/styled/media_card.dart';

import '../skeleton/support/widget_harness.dart';

/// WP #109: the loaded card must present one continuous rounded silhouette.
/// The score badge is anchored inside the cover stack, so the cover stack has
/// to carry the clip - otherwise the badge's square-ish corners paint over the
/// 20-radius corner the cover cuts away.
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

  /// The badge is the only box in the card painted with the leaf radius.
  bool isBadge(Widget widget) {
    if (widget is! Container) return false;
    final Decoration? decoration = widget.decoration;
    return decoration is BoxDecoration &&
        decoration.borderRadius == MediaCardMetrics.badgeBorderRadius;
  }

  final Finder badge = find.byWidgetPredicate(isBadge);
  final Finder coverClip = find.byWidgetPredicate(
    (Widget widget) =>
        widget is ClipRRect &&
        widget.borderRadius == MediaCardMetrics.coverBorderRadius,
  );

  testWidgets('clips the cover stack to the cover silhouette', (tester) async {
    await pumpSkeletonHarness(tester, card());

    expect(badge, findsOneWidget, reason: 'a scored card paints its badge');

    final Finder clip = find.ancestor(
      of: badge,
      matching: find.byType(ClipRRect),
    );
    expect(
      clip,
      findsOneWidget,
      reason: 'the badge must be painted inside the clipped cover stack',
    );
    expect(
      tester.widget<ClipRRect>(clip).borderRadius,
      MediaCardMetrics.coverBorderRadius,
    );

    // The clip is the cover itself, not a smaller inner box: the badge stays
    // flush with the cover's bottom-right edge and is cut by the same corner.
    final Rect coverRect = tester.getRect(clip);
    expect(coverRect.width, MediaCardMetrics.coverWidth);
    expect(coverRect.height, MediaCardMetrics.coverHeight);
    final Rect badgeRect = tester.getRect(badge);
    expect(badgeRect.right, coverRect.right);
    expect(badgeRect.bottom, coverRect.bottom);
  });

  testWidgets('paints no badge for an unrated card, silhouette unchanged', (
    tester,
  ) async {
    await pumpSkeletonHarness(tester, card(score: 0));

    expect(badge, findsNothing);
    expect(
      coverClip,
      findsWidgets,
      reason: 'the silhouette does not depend on the score',
    );
  });

  testWidgets('the badge brings no corner of its own into the silhouette', (
    tester,
  ) async {
    await pumpSkeletonHarness(tester, card());

    // The badge's bottom-right edge IS the cover's 20-radius arc. A radius of
    // its own can never line up with it, and the two antialiased edges left a
    // visible step in the corner of every rated card (WP #119).
    final BoxDecoration decoration =
        tester.widget<Container>(badge).decoration! as BoxDecoration;
    final BorderRadius radius = decoration.borderRadius! as BorderRadius;
    expect(radius.bottomRight, Radius.zero);
    expect(MediaCardMetrics.badgeBorderRadius.bottomRight, Radius.zero);
    // Its own scoop is still there, unchanged, on the top-left only.
    expect(radius.topLeft, const Radius.circular(MediaCardMetrics.badgeCornerRadius));
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
}

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_metrics.dart';

/// The one outline the score badge is painted inside — loaded card and skeleton
/// placeholder alike.
///
/// The badge is a leaf, not a capsule: it sits flush in the cover's
/// bottom-right corner, its left end is a single sweep from the top edge down to
/// the bottom-left point, and its right end is handed over to the cover's own
/// 20-radius arc by a fillet (WP #119 round 4). Without that fillet the flat top
/// edge runs into the near-vertical arc and ends in a square step; that step is
/// the glitch the reference image shows and this shape removes.
///
/// Both sides reference the same metrics, so the card and its loading
/// placeholder cannot drift apart.
class MediaBadgeClipper extends CustomClipper<Path> {
  const MediaBadgeClipper({
    this.cornerRadius = MediaCardMetrics.badgeCornerRadius,
    this.coverRadius = MediaCardMetrics.coverRadius,
    this.mergeRadius = MediaCardMetrics.badgeMergeRadius,
  });

  /// Radius of the leaf's left sweep (clamped to the badge height by the
  /// renderer, which is what makes it a sweep instead of a corner).
  final double cornerRadius;

  /// Radius of the cover's bottom-right corner the badge has to merge into.
  final double coverRadius;

  /// Radius of the fillet joining the top edge to [coverRadius].
  final double mergeRadius;

  @override
  Path getClip(Size size) {
    final double width = size.width;
    final double height = size.height;
    final double sweep = math.min(cornerRadius, height);

    // Centre of the cover's bottom-right arc, in badge-local coordinates: the
    // badge's bottom-right point is the cover's corner.
    final Offset arcCentre = Offset(width - coverRadius, height - coverRadius);

    final Path path = Path()..moveTo(0, height);

    // Left end: one sweep from the bottom-left point up to the top edge.
    path.arcToPoint(
      Offset(sweep, 0),
      radius: Radius.circular(sweep),
      clockwise: true,
    );

    // Fillet tangent to the top edge (from below) and internally tangent to
    // the cover arc: its centre sits mergeRadius under the top edge and
    // coverRadius - mergeRadius away from the arc centre.
    final double gap = coverRadius - mergeRadius;
    final double reach =
        gap * gap - (mergeRadius - arcCentre.dy) * (mergeRadius - arcCentre.dy);
    if (gap <= 0 || mergeRadius <= 0 || reach <= 0) {
      // No room for the fillet (a badge taller than the corner): fall back to
      // the plain leaf. The cover silhouette still holds the shape.
      path
        ..lineTo(width, 0)
        ..lineTo(width, height)
        ..close();
      return path;
    }

    final Offset filletCentre = Offset(
      arcCentre.dx + math.sqrt(reach),
      mergeRadius,
    );
    path.lineTo(filletCentre.dx, 0);

    // Tangency point on the cover arc: on the ray out of the arc centre.
    final Offset handOver =
        arcCentre + (filletCentre - arcCentre) * (coverRadius / gap);
    path.arcToPoint(
      handOver,
      radius: Radius.circular(mergeRadius),
      clockwise: true,
    );

    // Then follow the cover's own corner down to the badge's bottom edge.
    path.arcToPoint(
      Offset(arcCentre.dx, height),
      radius: Radius.circular(coverRadius),
      clockwise: true,
    );

    path
      ..lineTo(0, height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant MediaBadgeClipper oldClipper) =>
      cornerRadius != oldClipper.cornerRadius ||
      coverRadius != oldClipper.coverRadius ||
      mergeRadius != oldClipper.mergeRadius;
}

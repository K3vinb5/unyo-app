import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

class UnyoVideoListButton extends StatefulWidget {
  final String? tooltip;
  final void Function() onPressed;

  const UnyoVideoListButton({super.key, required this.onPressed, this.tooltip});

  /// Left-corner radius of the half-pill silhouette.
  ///
  /// The shape must stay a *non-degenerate* RRect: each corner radius has to
  /// fit inside its side (`r <= width`, `2r <= height`). Skia silently scales
  /// oversized radii down (`SkRRect::scaleRadii`), Impeller does not and
  /// tessellates the broken outline into a squared-off silhouette (OP #57).
  /// Sizing it from the live box keeps the D-shape identical on every
  /// renderer and at every clamped window size.
  static double halfPillRadius(double width, double height) {
    final double r = width < height / 2 ? width : height / 2;
    return r < 0 ? 0 : r;
  }

  @override
  State<UnyoVideoListButton> createState() => _UnyoVideoListButtonState();
}

class _UnyoVideoListButtonState extends State<UnyoVideoListButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double width = 45.w.clamp(40, 50);
    final double height = 95.h.clamp(90, 105);
    final BorderRadius shape = BorderRadius.only(
      topLeft: Radius.circular(UnyoVideoListButton.halfPillRadius(width, height)),
      bottomLeft: Radius.circular(UnyoVideoListButton.halfPillRadius(width, height)),
    );
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        // The D-silhouette is cut with an explicit path: an RRect with rounded
        // left corners and square right corners is tessellated into a
        // squared-off outline by Impeller regardless of how the radii are
        // scaled (verified: radius 50 and radius 45 paint the same wrong
        // shape), so the outline has to be spelled out. The clip wraps the
        // InkWell too, so the hover ink cannot leak outside the pill.
        child: ClipPath(
          clipper: HalfPillClipper(UnyoVideoListButton.halfPillRadius(width, height)),
          child: UnyoInkWell(
            onTap: widget.onPressed,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: shape,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: ColorScheme.of(context).primary.withValues(alpha: 0.3),
                borderRadius: shape,
              ),
              child: AnimatedScale(
                scale: isHovered ? 1.03 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isHovered ? Colors.white.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.7),
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outline of the episode-list button: two quarter-circles of [radius] on the
/// left, a straight segment between them when the box is taller than the
/// arcs, and a flush right edge that sits against the screen border.
///
/// This is the silhouette Skia produced for the original oversized
/// `BorderRadius.circular(50)` (radii scaled down to the box), reproduced
/// here explicitly so Impeller renders the same shape (OP #57).
class HalfPillClipper extends CustomClipper<Path> {
  const HalfPillClipper(this.radius);

  final double radius;

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    final double r = radius.clamp(0.0, math.min(w, h / 2));
    return Path()
      ..moveTo(w, 0)
      ..lineTo(r, 0)
      ..arcTo(Rect.fromCircle(center: Offset(r, r), radius: r), -math.pi / 2, -math.pi / 2, false)
      ..lineTo(0, h - r)
      ..arcTo(Rect.fromCircle(center: Offset(r, h - r), radius: r), math.pi, -math.pi / 2, false)
      ..lineTo(w, h)
      ..close();
  }

  @override
  bool shouldReclip(HalfPillClipper oldClipper) => oldClipper.radius != radius;
}

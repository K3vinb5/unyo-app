import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_scope.dart';

/// The single skeleton primitive: a rounded block painted with the skeleton
/// colour and, when a [SkeletonScope] is animating, a gradient sweep.
///
/// Colours are derived from the ambient [ColorScheme] (never hardcoded greys),
/// so skeletons follow whatever theme [ThemeService] built from the user's
/// colours.
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  /// Width of the block; `null` fills the available width.
  ///
  /// A childless [DecoratedBox] collapses to the smallest allowed size, so the
  /// null case has to ask for `double.infinity` explicitly - otherwise every
  /// full-width block (the carousel banner, the description lines, the episode
  /// dividers) paints nothing at all.
  final double? width;
  final double height;
  final double borderRadius;

  /// Base fill: `onSurface` at 6% - the resting skeleton colour.
  static Color baseColor(BuildContext context) =>
      ColorScheme.of(context).onSurface.withValues(alpha: 0.06);

  /// Highlight fill: `onSurface` at 12% - the tip of the sweep.
  static Color highlightColor(BuildContext context) =>
      ColorScheme.of(context).onSurface.withValues(alpha: 0.12);

  @override
  Widget build(BuildContext context) {
    final Widget block = SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: baseColor(context),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );

    final Animation<double>? animation = SkeletonScope.animationOf(context);
    if (animation == null) {
      // Accessibility: no animation requested, so no shader layer and no
      // ticker - just the resting block.
      return block;
    }

    final Color base = baseColor(context);
    final Color highlight = highlightColor(context);
    return AnimatedBuilder(
      animation: animation,
      child: block,
      builder: (context, child) {
        final double progress = animation.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) => LinearGradient(
            begin: Alignment(-2.5 + 3.0 * progress, -0.4),
            end: Alignment(-1.5 + 3.0 * progress, 0.4),
            colors: <Color>[base, highlight, base],
            stops: const <double>[0.35, 0.5, 0.65],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

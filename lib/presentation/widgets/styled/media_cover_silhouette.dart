import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_metrics.dart';

/// The one outline every media cover is painted inside — loaded card and
/// loading skeleton alike.
///
/// [MediaCard] (image, score badge, release-status dot) and
/// [MediaCardSkeleton] (placeholder, badge placeholder) both wrap their cover
/// stack in this widget, so the two can never disagree about the corner, and
/// no layer inside brings a corner of its own.
///
/// One clip only: nested [ClipRRect]s at the same radius each antialias the
/// edge again, and the resulting softened arc is what read as a straight edge
/// followed by a sudden bend instead of a single smooth curve (WP #119).
class MediaCoverSilhouette extends StatelessWidget {
  const MediaCoverSilhouette({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: MediaCardMetrics.coverBorderRadius,
      child: child,
    );
  }
}

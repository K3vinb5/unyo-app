import 'package:material_ui/material_ui.dart';

/// Geometry shared between a real component and the skeleton that mirrors it.
///
/// The drift guard: both sides reference these constants, so a resized card
/// cannot silently drift away from its loading placeholder. Every number here
/// is copied from the widget named in the doc comment.
abstract final class MediaCardMetrics {
  /// `widgets/styled/media_card.dart` - outer [SizedBox] of [MediaCard].
  static const double width = 152.5;
  static const double height = 256;

  /// `widgets/styled/media_card.dart` - the cover [HoverAnimatedContainer].
  static const double coverWidth = 140.0;
  static const double coverHeight = 200.5;
  static const double coverRadius = 20;

  /// `widgets/styled/media_card.dart` - title and meta rows under the cover.
  static const double titleRowHeight = 24;
  static const double metaRowHeight = 18;
}

/// Geometry shared between the horizontal card rows and their skeletons.
abstract final class CardRowMetrics {
  /// `widgets/styled/anime_card_list.dart` / `manga_card_list.dart` - the
  /// `SizedBox` that holds the horizontal [ListView] of [MediaCard]s.
  static const double rowHeight = 260;

  /// Gap between the row title and the cards.
  static const double headerGap = 10;
}

/// Geometry shared between the grid screens and [MediaGridSkeleton].
///
/// Used by `screens/media_list_screen.dart`, `screens/calendar_screen.dart`
/// and the skeleton that replaces them while loading.
const SliverGridDelegateWithMaxCrossAxisExtent mediaGridDelegate =
    SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 165,
      mainAxisExtent: 260,
      crossAxisSpacing: 5,
      mainAxisSpacing: 15,
    );

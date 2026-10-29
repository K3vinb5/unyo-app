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

  /// [coverRadius] as a [BorderRadius], so a skeleton can clip its cover stack
  /// in a `const` tree.
  static const BorderRadius coverBorderRadius = BorderRadius.all(
    Radius.circular(coverRadius),
  );

  /// `widgets/styled/media_card.dart` - title and meta rows under the cover.
  static const double titleRowHeight = 24;
  static const double metaRowHeight = 18;

  /// `widgets/styled/media_card.dart` - the score badge overlay in the
  /// bottom-right corner of the cover (`6 + text + 15px star` wide, 18 high).
  static const double badgeWidth = 46;
  static const double badgeHeight = 18;

  /// `widgets/styled/media_card.dart` - the badge is a leaf, not a pill: its
  /// bottom-right corner (50) follows the cover and its top-left corner (50)
  /// is cut away, so no single uniform radius describes it.
  static const BorderRadius badgeBorderRadius = BorderRadius.only(
    bottomRight: Radius.circular(50),
    topLeft: Radius.circular(50),
  );

  /// `widgets/styled/media_card.dart` - the single text line painted inside
  /// [titleRowHeight] and [metaRowHeight]; a pill the size of the whole row
  /// reads as a block, not as a line of text.
  static const double titlePillWidth = 110;
  static const double titlePillHeight = 14;
  static const double metaPillWidth = 96;
  static const double metaPillHeight = 12;
}

/// Geometry shared between the horizontal card rows and their skeletons.
abstract final class CardRowMetrics {
  /// `widgets/styled/anime_card_list.dart` / `manga_card_list.dart` - the
  /// `SizedBox` that holds the horizontal [ListView] of [MediaCard]s.
  static const double rowHeight = 260;

  /// Gap between the row title and the cards.
  static const double headerGap = 10;

  /// Height of the header row: the real one ends in two [MediaListArrows]
  /// `IconButton`s, which are 40 high in Material 3.
  static const double headerHeight = 40;

  /// [MediaListArrows] - `Icon(Icons.arrow_left, size: 24)` inside its button.
  static const double arrowSize = 24;
  static const double arrowGap = 16;
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

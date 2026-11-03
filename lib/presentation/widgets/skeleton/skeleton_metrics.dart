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

  /// [coverRadius] as a [BorderRadius] — the value
  /// `MediaCoverSilhouette` (the one clip shared by the loaded card and its
  /// skeleton) is built from.
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

  /// Radius of the badge's leaf corners — the original pre-#119 value.
  ///
  /// Far larger than [badgeHeight] on purpose: the renderer clamps it to the
  /// box, so the top-left corner becomes one generous sweep from the top edge
  /// down to the bottom-left point. The bottom-right corner is the same radius,
  /// i.e. big enough to follow the cover's own corner arc.
  static const double badgeCornerRadius = 50;

  /// The leaf: [badgeCornerRadius] top-left and bottom-right, square
  /// bottom-left. The top-right is deliberately *not* stated here — it has to
  /// line up with the cover's arc, which depends on where the badge sits, so
  /// `MediaBadgeClipper` builds the whole outline instead.
  static const BorderRadius badgeBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(badgeCornerRadius),
    bottomRight: Radius.circular(badgeCornerRadius),
  );

  /// Radius of the fillet that hands the badge's top edge over to the cover's
  /// [coverRadius] bottom-right arc.
  ///
  /// The badge is flush in the corner (no inset) so it reads as part of the
  /// card, but a square top-right then ends in a step where the flat top edge
  /// meets the near-vertical arc — the pre-#119 glitch. The fillet is tangent
  /// to both the top edge and the arc, so the outline is one continuous curve
  /// ending on the cover's corner.
  static const double badgeMergeRadius = 4;

  /// The badge sits flush at the cover's bottom-right corner: the original
  /// leaf placement, restored after the round-3 floating capsule.
  static const double badgeInset = 0;

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

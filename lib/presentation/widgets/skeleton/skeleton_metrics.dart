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

  /// Radius of the badge's four corners — half of [badgeHeight], so each end is
  /// a full semicircle (a stadium capsule, the look of the pre-#119 badge).
  ///
  /// Both ends must be mirror images: a square right end (the #119 follow-up)
  /// was not a stylistic choice, it read as a clipped/glitched pill next to the
  /// round left cap.
  static const double badgeCornerRadius = badgeHeight / 2;

  /// One continuous stadium capsule: every corner at [badgeCornerRadius], so
  /// the left and right ends are identical semicircles. Loaded card and
  /// skeleton both paint the badge with this, so they cannot diverge.
  static const BorderRadius badgeBorderRadius = BorderRadius.all(
    Radius.circular(badgeCornerRadius),
  );

  /// How far the badge floats from the cover's right and bottom edges.
  ///
  /// The pill no longer butts into the cover's 20-radius corner: a capsule
  /// touching both edges would be carved by the cover silhouette and read as a
  /// square step on its right end. At 6 the whole capsule sits inside the arc
  /// (its right end centre is 16.07 < 20 from the corner's centre).
  static const double badgeInset = 6;

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

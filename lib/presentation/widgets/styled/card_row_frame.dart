import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

/// The inset a card row is laid out with.
///
/// - [browse] the browse/home strips: a `1.sw - 140` box centered by the
///   parent column.
/// - [details] the details screens: the strip fills a `35.w` horizontal
///   padding.
enum CardRowInset { browse, details }

/// The container geometry of a horizontal card row, shared by the real row
/// (`widgets/styled/anime_card_list.dart`, `manga_card_list.dart`,
/// `unyo_character_list.dart`, `*_recommendations_card_list.dart`) and its
/// loading placeholder (`CardRowSkeleton`).
///
/// Both states are wrapped in the same frame, so the strip is structurally
/// identical while loading and the placeholder cannot drift away from the
/// content it replaces: the inner `double.infinity` resolves to the same
/// width in both.
class CardRowFrame extends StatelessWidget {
  const CardRowFrame.browse({super.key, required this.child})
    : inset = CardRowInset.browse;

  const CardRowFrame.details({super.key, required this.child})
    : inset = CardRowInset.details;

  /// `AnimeCardList` / `MangaCardList` - the strip was a `SizedBox` of this
  /// many screen-util points narrower than the screen.
  static const double stripInset = 140;

  /// `UnyoCharacterList` / `*_RecommendationsCardList` - the `.w` padding
  /// around the details strips.
  static const double detailsInset = 35;

  final Widget child;
  final CardRowInset inset;

  /// The strip width the [browse] frame gives its child.
  static double browseStripWidth() => 1.sw - stripInset;

  @override
  Widget build(BuildContext context) {
    switch (inset) {
      case CardRowInset.browse:
        return SizedBox(width: browseStripWidth(), child: child);
      case CardRowInset.details:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: detailsInset.w),
          child: child,
        );
    }
  }
}

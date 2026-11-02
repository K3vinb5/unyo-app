import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';

/// Mirrors the metadata block the details screens paint under the banner
/// (`anime_details_screen.dart` / `manga_details_screen.dart`): a row of
/// [UnyoBannerIcon] pills (plus the media-list entry button on anime), a gap,
/// then the description lines.
///
/// Without it the loaded description pushed the genre row and everything below
/// it down by the height of the text it added, while the header skeleton had
/// already been replaced.
class DetailMetaBlockSkeleton extends StatelessWidget {
  const DetailMetaBlockSkeleton({
    super.key,
    this.iconCount = 3,
    this.descriptionLines = 3,
    this.showEntryButton = true,
  });

  /// `unyo_banner_icon.dart` - `Container(width: 85, height: 30)` +
  /// `EdgeInsets.only(right: 16.w)`.
  static const double iconWidth = 85;
  static const double iconHeight = 30;
  static const double iconGap = 16;

  /// `anime_details_screen.dart` - the media list entry button is
  /// `Container(width: 120.w, height: 40)`.
  static const double entryButtonWidth = 120;
  static const double entryButtonHeight = 40;

  /// `text_body_medium.dart` at the default style - one 14px line, 1.43 line
  /// height, and the 6px gap between two placeholder lines.
  static const double lineHeight = 14;
  static const double lineGap = 6;

  final int iconCount;
  final int descriptionLines;
  final bool showEntryButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The pills row shares its height with the entry button on the right.
        SizedBox(
          height: entryButtonHeight,
          child: Row(
            children: [
              for (int i = 0; i < iconCount; i++)
                Padding(
                  padding: EdgeInsets.only(right: iconGap.w),
                  child: const Align(
                    alignment: Alignment.center,
                    child: SkeletonBlock(
                      width: iconWidth,
                      height: iconHeight,
                      borderRadius: 8,
                    ),
                  ),
                ),
              const Spacer(),
              if (showEntryButton)
                SkeletonBlock(
                  width: entryButtonWidth.w,
                  height: entryButtonHeight,
                  borderRadius: 8,
                ),
            ],
          ),
        ),
        SizedBox(height: 13.h),
        for (int i = 0; i < descriptionLines; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == descriptionLines - 1 ? 0 : lineGap),
            child: const SkeletonBlock(height: lineHeight, borderRadius: 4),
          ),
      ],
    );
  }
}

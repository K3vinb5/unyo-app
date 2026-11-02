import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';

/// Mirrors `widgets/styled/unyo_extension_button.dart`
/// ([UnyoExtensionButton]): 70-high row, the name + pill block at the left and
/// the trailing action button. Screen-util units follow the real widget.
///
/// The real row reserves `20.w + 52 + 14.w` for its rounded-square icon
/// ([UnyoExtensionButton.iconSize], radius [UnyoExtensionButton.iconBorderRadius]).
/// The placeholder keeps that slot width so the pills land where the loaded
/// text lands, and paints no icon shape at all.
class ExtensionRowSkeleton extends StatelessWidget {
  const ExtensionRowSkeleton({super.key, this.showActionButton = true});

  final bool showActionButton;

  /// `unyo_extension_button.dart` - `Container(height: 70)`.
  static const double rowHeight = 70;

  /// `unyo_extension_button.dart` - rounded-square icon slot edge (52px).
  static const double iconSlotSize = 52;

  /// `unyo_extension_button.dart` - the row is 78 high in the list: the
  /// 70-high body plus its 8 bottom padding.
  static const double rowPitch = rowHeight + 8;

  /// How many rows fill [maxHeight]: the skeleton mirrors the list, so it
  /// covers the viewport instead of guessing a fixed eight. Clamped so a tiny
  /// or huge window still reads as a list.
  static int rowsForHeight(
    double maxHeight, {
    int minRows = 4,
    int maxRows = 25,
  }) {
    if (!maxHeight.isFinite) {
      return minRows;
    }
    return (maxHeight / rowPitch.h).ceil().clamp(minRows, maxRows);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 8.h),
      child: SizedBox(
        height: rowHeight,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(width: 20.w),
                // Reserved icon slot, deliberately left unpainted.
                const SizedBox(width: iconSlotSize),
                SizedBox(width: 14.w),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBlock(width: 160, height: 16),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        SkeletonBlock(width: 40, height: 16),
                        SizedBox(width: 4),
                        SkeletonBlock(width: 48, height: 16),
                        SizedBox(width: 4),
                        SkeletonBlock(width: 60, height: 16),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (showActionButton)
              const SkeletonBlock(width: 45, height: 45, borderRadius: 10),
          ],
        ),
      ),
    );
  }
}

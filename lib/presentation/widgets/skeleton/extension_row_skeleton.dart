import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';

/// Mirrors `widgets/styled/unyo_extension_button.dart`
/// ([UnyoExtensionButton]): 70-high row, 52px round icon, name + pill row and
/// the trailing action button. Screen-util units follow the real widget.
class ExtensionRowSkeleton extends StatelessWidget {
  const ExtensionRowSkeleton({super.key, this.showActionButton = true});

  final bool showActionButton;

  /// `unyo_extension_button.dart` - `Container(height: 70)`.
  static const double rowHeight = 70;

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
                const SkeletonBlock(width: 52, height: 52, borderRadius: 26),
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

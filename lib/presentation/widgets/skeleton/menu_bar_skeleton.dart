import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';

/// Mirrors `widgets/styled/unyo_menu_bar.dart` ([UnyoMenuBar]): the 80x440
/// glass rail with its 27px avatar and its 50x50 icon buttons.
///
/// The shell only paints the rail once `HomeCubit` has finished loading the
/// user (`MenuBarNotifier.showMenuBar(true)`), so on the app's first paint the
/// whole rail used to be missing while the rest of the screen already showed
/// its placeholders.
class MenuBarSkeleton extends StatelessWidget {
  const MenuBarSkeleton({super.key, this.iconCount = 5});

  final int iconCount;

  /// `unyo_menu_bar.dart` - `Container(width: 80, height: 440)`.
  static const double railWidth = 80;
  static const double railHeight = 440;

  /// `unyo_menu_bar.dart` - `CircleAvatar(radius: 27)`.
  static const double avatarSize = 54;

  /// `unyo_menu_bar.dart` - the `Divider(height: 40)` under the avatar.
  static const double dividerHeight = 40;

  /// `unyo_menu_icon.dart` - `AnimatedContainer(width: 50, height: 50)` with a
  /// 10-high bottom padding.
  static const double iconSize = 50;
  static const double iconGap = 10;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0.w, top: 15.0.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40.0),
        child: SizedBox(
          width: railWidth,
          height: railHeight,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const SkeletonBlock(
                width: avatarSize,
                height: avatarSize,
                borderRadius: avatarSize / 2,
              ),
              const SizedBox(height: dividerHeight),
              ...List<Widget>.generate(
                iconCount,
                (int index) => const Padding(
                  padding: EdgeInsets.only(bottom: iconGap),
                  child: SkeletonBlock(
                    width: iconSize,
                    height: iconSize,
                    borderRadius: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

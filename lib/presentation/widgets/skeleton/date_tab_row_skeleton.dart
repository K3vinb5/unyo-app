import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';

/// Mirrors the date tab bar of `screens/calendar_screen.dart`: a 50-high
/// [TabBar] of fixed 170-wide tabs, the active one underlined by a 2px
/// indicator, over the bar's divider line.
///
/// The real tabs are built from `state.animeCalendarReleases`, which is empty
/// while the screen loads, so the bar rendered as nothing at all and the grid
/// started right under the header.
class DateTabRowSkeleton extends StatelessWidget {
  const DateTabRowSkeleton({super.key, this.tabCount = 5});

  final int tabCount;

  /// `calendar_screen.dart` - the 50-high `SizedBox` around the [TabBar].
  static const double barHeight = 50;

  /// `calendar_screen.dart` - `SizedBox(width: 170, child: Tab(...))`.
  static const double tabWidth = 170;

  /// The tab label line and the indicator under the active tab.
  static const double labelWidth = 120;
  static const double labelHeight = 14;
  static const double indicatorWidth = 60;
  static const double indicatorHeight = 2;
  static const double dividerHeight = 1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: barHeight,
      width: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: List<Widget>.generate(
                tabCount,
                (int index) => SizedBox(
                  width: tabWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SkeletonBlock(
                        width: labelWidth,
                        height: labelHeight,
                        borderRadius: 6,
                      ),
                      const SizedBox(height: 8),
                      if (index == 0)
                        const SkeletonBlock(
                          width: indicatorWidth,
                          height: indicatorHeight,
                          borderRadius: 1,
                        )
                      else
                        const SizedBox(height: indicatorHeight),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SkeletonBlock(height: dividerHeight, borderRadius: 0),
        ],
      ),
    );
  }
}

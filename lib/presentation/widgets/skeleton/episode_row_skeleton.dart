import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';

/// Mirrors one row of `widgets/styled/unyo_episode_button.dart`
/// ([UnyoEpisodeButton]): 16:9 thumbnail, two title lines and the release
/// state on the right.
///
/// Used by the details screens' episode column and by the episode drawer while
/// episode metadata is still loading.
class EpisodeRowSkeleton extends StatelessWidget {
  const EpisodeRowSkeleton({super.key, this.showDivider = false});

  /// `unyo_episode_button.dart` - `SizedBox(height: 70.h)` inside padding.
  static const double rowHeight = 70;

  /// `unyo_episode_button.dart` - `SizedBox(width: 105.w.clamp(105, 200))`
  /// holding a 16:9 thumbnail.
  static const double thumbnailWidth = 105;

  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: SkeletonBlock(height: 1, borderRadius: 0),
          ),
        Padding(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            bottom: 12,
            top: showDivider ? 12 : 0,
          ),
          child: const SizedBox(
            height: rowHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SkeletonBlock(
                      width: thumbnailWidth,
                      height: thumbnailWidth * 9 / 16,
                      borderRadius: 10,
                    ),
                    SizedBox(width: 20),
                    SizedBox(
                      width: 120,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBlock(width: 120, height: 13),
                          SizedBox(height: 6),
                          SkeletonBlock(width: 90, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 12),
                    SkeletonBlock(width: 70, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';

/// Mirrors the details header (`widgets/styled/unyo_media_banner.dart` +
/// `widgets/styled/image_card.dart`): banner, 140x200.5 cover, title and meta
/// block.
///
/// Shown on the details screens while the selected media has not arrived yet.
class DetailHeaderSkeleton extends StatelessWidget {
  const DetailHeaderSkeleton({
    super.key,
    this.height = 300,
    this.coverWidth = 140,
    this.coverHeight = 200.5,
  });

  final double height;
  final double coverWidth;
  final double coverHeight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SkeletonBlock(height: height, borderRadius: 20),
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 16),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SkeletonBlock(
                      width: coverWidth,
                      height: coverHeight,
                      borderRadius: 20,
                    ),
                    const SizedBox(width: 20),
                    const SizedBox(
                      height: 120,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBlock(width: 350, height: 20),
                          SizedBox(height: 8),
                          SkeletonBlock(width: 200, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

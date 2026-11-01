import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_block.dart';

/// Mirrors the details header (`widgets/styled/unyo_media_banner.dart` +
/// `widgets/styled/image_card.dart`): banner, 140x200.5 cover, title and meta
/// block. The `.h` / `.w` units are the banner's own, so the band keeps its
/// height when the window is not at the design size.
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
        height: height.h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SkeletonBlock(height: height.h, borderRadius: 20),
            Padding(
              padding: EdgeInsets.only(left: 24.w, bottom: 16.h),
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
                    SizedBox(
                      height: 120,
                      width: 350.w,
                      child: const Column(
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

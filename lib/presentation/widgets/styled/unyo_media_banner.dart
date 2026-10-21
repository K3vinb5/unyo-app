import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/styled.dart';
import 'package:unyo/presentation/widgets/styled/unyo_animated_image_banner.dart';

class UnyoMediaBanner extends StatelessWidget {
  final String imageUrl;
  final String coverImage;
  final String title;
  final String status;
  final String tag;

  const UnyoMediaBanner({
    super.key,
    required this.imageUrl,
    required this.coverImage,
    required this.title,
    required this.status,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 800.w,
            height: 300.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                imageUrl != ""
                    ?
                    UnyoAnimatedImageBanner(imageUrl: imageUrl)
                    : const SizedBox.shrink(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h, left: 24.w),
                  child: ImageCard(
                    coverImage: coverImage,
                    title: title,
                    status: status,
                    tag: tag,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

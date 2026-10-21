import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageCard extends StatelessWidget {
  final String coverImage;
  final String title;
  final String status;
  final String tag;

  const ImageCard({
    super.key,
    required this.coverImage,
    required this.title,
    required this.status,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 140.0,
          height: 200.5,
          child: Hero(
            tag: tag,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(coverImage),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          height: 120,
          width: 350.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.fade,
                ),
                maxLines: 2,
              ),
              Text(
                status.replaceAll("_", " "),
                style: TextStyle(
                  color: ColorScheme.of(context).primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

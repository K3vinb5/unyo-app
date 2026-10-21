import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/text/text_label_large.dart';

class UnyoBannerIcon extends StatelessWidget {
  final String text;
  final IconData? iconData;
  const UnyoBannerIcon({super.key, required this.text, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16.0.w),
      child: Container(
        width: 85,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconData != null ? Icon(iconData, color: ColorScheme.of(context).tertiary, size: 17) : const SizedBox.shrink(),
            const SizedBox(width: 4),
            TextLabelLarge(
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              text: text,
            ),
          ],
        ),
      ),
    );
  }
}

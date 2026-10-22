import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/styled.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

class MediaButton extends StatelessWidget {
  final void Function()? onPressed;
  final String image;
  final String text;
  final double width;
  final double height;
  const MediaButton({super.key, required this.onPressed, required this.image, required this.text, this.width = 300, this.height = 80});

  @override
  Widget build(BuildContext context) {
        return UnyoInkWell(
            onTap: onPressed,
            child: HoverAnimatedContainer(
              duration: const Duration(milliseconds: 130),
              alignment: Alignment.center,
              width: width.w.clamp(width - 50, width + 10),
              hoverWidth: (width + 10).w.clamp(width - 40, width + 20),
              height: height.h.clamp(height - 10, height + 10),
              hoverHeight: (height + 5).h.clamp(height - 5, height + 15),
              hoverCursor: SystemMouseCursors.click,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(
                    color: ColorScheme.of(context).secondary.withValues(alpha: 0.4), width: 2),
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  opacity: 0.35,
                  colorFilter:
                      ColorFilter.mode(ColorScheme.of(context).secondary, BlendMode.modulate),
                  image: NetworkImage(
                    image,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              hoverDecoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(
                    color: ColorScheme.of(context).secondary.withValues(alpha: 0.4), width: 2),
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  opacity: 0.35,
                  colorFilter:
                      ColorFilter.mode(ColorScheme.of(context).primary, BlendMode.modulate),
                  image: NetworkImage(
                    image,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 2,
                    color: ColorScheme.of(context).primary,
                  ),
                ],
              ),
            ),
          );
  }
}

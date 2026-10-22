import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

class UnyoVideoListButton extends StatefulWidget {
  final String? tooltip;
  final void Function() onPressed;

  const UnyoVideoListButton({super.key, required this.onPressed, this.tooltip});

  @override
  State<UnyoVideoListButton> createState() => _UnyoVideoListButtonState();
}

class _UnyoVideoListButtonState extends State<UnyoVideoListButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: UnyoInkWell(
          onTap: widget.onPressed,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(50), bottomLeft: Radius.circular(50)),
          child: Container(
            width: 45.w.clamp(40, 50),
            height: 95.h.clamp(90, 105),
            decoration: BoxDecoration(
              color: ColorScheme.of(context).primary.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(50), bottomLeft: Radius.circular(50))
            ),
            child: AnimatedScale(
              scale: isHovered ? 1.03 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isHovered ? Colors.white.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.7),
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

class LightUnyoButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final Color color;
  final Color textColor;
  final bool isEnabled;
  final double? maxWidth;
  final double? maxHeight;
  final double? minWidth;
  final double? minHeight;
  final double? width;
  final double? height;
  final void Function() onPressed;

  const LightUnyoButton({
    super.key,
    this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.child,
    this.color = const Color.fromARGB(190, 200, 200, 200),
    this.textColor = const Color.fromARGB(255, 37, 37, 37),
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: UnyoInkWell(
        onTap: isEnabled ? onPressed : null,
        highlightColor: Color.lerp(Colors.white, color, 0.5),
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: width ?? 80.w.clamp(minWidth ?? 0, maxWidth ?? math.max(minWidth ?? 0, 80.w)),
          height: height ?? 45.h.clamp(minHeight ?? 0, maxHeight ?? math.max(minHeight ?? 0, 45.h)),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: (Color.lerp(Colors.white, color, 0.65) ?? color).withValues(alpha: 0.9)),
          child: Center(
            child: Text(text ?? "", style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

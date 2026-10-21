import 'package:material_ui/material_ui.dart';

class UnyoFadeOverlay extends StatelessWidget {
  final bool isTop;
  final double height;
  final double opacity;
  final Color color;

  const UnyoFadeOverlay({
    super.key,
    required this.isTop,
    this.height = 100,
    this.opacity = 0.6,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
              end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
              colors: [
                color.withValues(alpha: opacity),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

class UnyoPill extends StatelessWidget {
  final String text;
  final Color color;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final double horizontalPadding;

  const UnyoPill({
    super.key,
    required this.text,
    required this.color,
    this.height = 22,
    this.fontSize = 11,
    this.fontWeight = FontWeight.bold,
    this.horizontalPadding = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.3),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

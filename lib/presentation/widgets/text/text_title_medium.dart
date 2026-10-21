import 'package:material_ui/material_ui.dart';

class TextTitleMedium extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  const TextTitleMedium({
    super.key,
    required this.text,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.titleMedium;
    return Text(
      text,
      style: style != null ? baseStyle!.merge(style) : baseStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
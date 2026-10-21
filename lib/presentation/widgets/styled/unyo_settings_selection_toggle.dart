import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/unyo_toggle.dart';

class UnyoSettingsSelectionToggle extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? imageUrl;
  final bool initiallySelected;
  final void Function(bool) onPressed;

  /// UnyoSettingsSelectionToggle counts as 2 Settings Elements
  const UnyoSettingsSelectionToggle({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.question_mark_rounded,
    this.imageUrl,
    required this.initiallySelected,
    required this.onPressed,
  });

  @override
  State<UnyoSettingsSelectionToggle> createState() => _UnyoSettingsSelectionToggleState();
}

class _UnyoSettingsSelectionToggleState extends State<UnyoSettingsSelectionToggle> {
  late bool _isSelected;

  @override
  void initState() {
    _isSelected = widget.initiallySelected;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant UnyoSettingsSelectionToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallySelected != widget.initiallySelected) {
      setState(() {
        _isSelected = widget.initiallySelected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: double.infinity,
      height: 75,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 47,
                  height: 47,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ColorScheme.of(context).primary.withValues(alpha: 0.2),
                  ),
                  child:
                      widget.imageUrl == null
                          ? Icon(widget.icon, color: ColorScheme.of(context).tertiary)
                          : Image.network(widget.imageUrl!),
                ),
                const SizedBox(width: 18.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      widget.description,
                      style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            UnyoToggle(
              value: _isSelected,
              onChanged: (value) {
                setState(() {
                  _isSelected = value;
                });
                widget.onPressed(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/unyo_dropdown.dart';

class UnyoSettingsSelectionDropdown extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? imageUrl;
  final String? label;
  final String defaultValue;
  final List<String> children;
  final void Function(String?) onPressed;

  const UnyoSettingsSelectionDropdown({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.imageUrl,
    this.label,
    required this.defaultValue,
    required this.children,
    required this.onPressed,
  });

  @override
  State<UnyoSettingsSelectionDropdown> createState() => _UnyoSettingsSelectionDropdownState();
}

class _UnyoSettingsSelectionDropdownState extends State<UnyoSettingsSelectionDropdown> {

  late String defaultValue;

  @override
  void initState() {
    super.initState();
    defaultValue = widget.defaultValue;
  }

  @override
  void didUpdateWidget(covariant UnyoSettingsSelectionDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultValue != widget.defaultValue) {
      setState(() {
        defaultValue = widget.defaultValue;
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
            SizedBox(
              width: 170.w,
              child: UnyoDropdown(
                children: widget.children,
                label: widget.label,
                selectedValue: widget.defaultValue,
                onPressed: (value) {
                  widget.onPressed(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

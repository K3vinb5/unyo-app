import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnyoSettingsSelectionSlider extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? imageUrl;
  final String labelSuffix;
  final int initialValue;
  final int minValue;
  final int maxValue;
  final void Function(double) onChanged;

  /// UnyoSettingsSelectionSlider counts as 2 Settings Elements
  const UnyoSettingsSelectionSlider({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.question_mark_rounded,
    this.imageUrl,
    this.labelSuffix = "",
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  State<UnyoSettingsSelectionSlider> createState() => _UnyoSettingsSelectionSliderState();
}

class _UnyoSettingsSelectionSliderState extends State<UnyoSettingsSelectionSlider> {
  late double _currentValue;

  @override
  void initState() {
    _currentValue = widget.initialValue.toDouble();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant UnyoSettingsSelectionSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _currentValue = widget.initialValue.toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: double.infinity,
      height: 150,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                    Text(widget.description, style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(width: 10,),
                SizedBox(
                  width: 35,
                  child: Text(
                    "${_currentValue.toInt()}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Slider(
                      value: _currentValue,
                      min: widget.minValue.toDouble(),
                      max: widget.maxValue.toDouble(),
                      divisions: widget.maxValue - widget.minValue,
                      activeColor: ColorScheme.of(context).tertiary,
                      inactiveColor: ColorScheme.of(context).secondary.withValues(alpha: 0.4),
                      onChanged: (value) {
                        setState(() {
                          _currentValue = value;
                        });
                        widget.onChanged(value);
                      }
                  ),
                ),
                const SizedBox(width: 10,),
                Text(
                  widget.maxValue.toString(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(width: 10,),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

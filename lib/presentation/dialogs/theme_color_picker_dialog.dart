import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:material_ui/material_ui.dart';

import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/light_unyo_button.dart';

/// Surface the picker dialog paints itself on.
///
/// Pinned (instead of inherited) because the dialog deliberately opts out of the
/// user theme: the picker area is drawn with fixed art (an HSV square), so the
/// panel around it has to stay one colour. Every colour that sits on this
/// surface is pinned against [themeColorPickerDialogSurface] below.
const Color themeColorPickerDialogSurface = Color(0xFF1E1E1E);

/// Surface the label-mode dropdown menu paints on. Slightly lifted from the
/// dialog surface so the menu reads as a layer above the panel.
const Color themeColorPickerMenuSurface = Color(0xFF2B2B2B);

/// Fixed width of the picker frame. The frame never follows the picker's
/// intrinsic size, so switching the label mode cannot resize the dialog.
const double themeColorPickerDialogWidth = 420;

/// Fixed height of the picker frame (clamped by
/// [themeColorPickerDialogMaxHeightFraction] on short windows).
const double themeColorPickerDialogContentHeight = 580;

/// Share of the window height the picker frame may occupy at most.
const double themeColorPickerDialogMaxHeightFraction = 0.8;

/// Colour picker with a fixed geometry frame and a theme that cannot invert.
///
/// `flutter_colorpicker` draws its label row with the Flutter SDK's own
/// material widgets. A `material_ui` app tree provides neither an SDK
/// `Material` nor an SDK `Theme`, so that row used to render with
/// `ThemeData.fallback()` (light) on the dialog's dark surface and its
/// `DropdownButton` asserts "No Material widget found" in debug builds. The
/// label row is therefore disabled (`labelTypes: []`) and the mode switch plus
/// the value read-out live here, drawn with the app's own widgets and theme.
class ThemeColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onConfirmed;

  const ThemeColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.onConfirmed,
  });

  @override
  State<ThemeColorPickerDialog> createState() => _ThemeColorPickerDialogState();
}

class _ThemeColorPickerDialogState extends State<ThemeColorPickerDialog> {
  static const List<String> _labelModes = <String>['RGB', 'HSV', 'HSL'];

  late Color _selectedColor;
  String _labelMode = _labelModes.first;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  /// One line of colour values, one line in every mode, so the read-out can
  /// never change the dialog height.
  String _valueLabel(Color color) {
    switch (_labelMode) {
      case 'HSV':
        final HSVColor hsv = HSVColor.fromColor(color);
        return 'H ${hsv.hue.round()}°   S ${(hsv.saturation * 100).round()}%   V ${(hsv.value * 100).round()}%';
      case 'HSL':
        final HSLColor hsl = HSLColor.fromColor(color);
        return 'H ${hsl.hue.round()}°   S ${(hsl.saturation * 100).round()}%   L ${(hsl.lightness * 100).round()}%';
      default:
        return 'R ${(color.r * 255).round()}   G ${(color.g * 255).round()}   B ${(color.b * 255).round()}';
    }
  }

  /// Pins every colour the picker widgets read from the ambient theme, so the
  /// menu, the items and the selected value stay legible on
  /// [themeColorPickerDialogSurface] whatever the user theme resolves to.
  ThemeData _pickerTheme(ThemeData base) {
    final TextTheme text = base.textTheme;
    return base.copyWith(
      canvasColor: themeColorPickerMenuSurface,
      hintColor: Colors.white70,
      textTheme: text.copyWith(
        titleMedium: (text.titleMedium ?? const TextStyle()).copyWith(color: Colors.white),
        bodyLarge: (text.bodyLarge ?? const TextStyle()).copyWith(color: Colors.white),
        bodyMedium: (text.bodyMedium ?? const TextStyle()).copyWith(color: Colors.white),
        labelLarge: (text.labelLarge ?? const TextStyle()).copyWith(color: Colors.white70),
      ),
    );
  }

  /// Label-mode switch. Built from `DropdownButton` rather than `UnyoDropdown`
  /// because the menu is painted in the navigator overlay, outside this
  /// dialog's pinned theme — so the item colour and the menu surface have to be
  /// carried by the widget itself to stay legible on any user theme.
  Widget _labelModeSelector() {
    return SizedBox(
      height: 48,
      child: DropdownButton<String>(
        key: const ValueKey('theme-color-picker-label-mode'),
        value: _labelMode,
        dropdownColor: themeColorPickerMenuSurface,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        iconEnabledColor: Colors.white70,
        underline: Container(height: 1, color: Colors.white24),
        items: <DropdownMenuItem<String>>[
          for (final String mode in _labelModes)
            DropdownMenuItem<String>(value: mode, child: Text(mode)),
        ],
        onChanged: (value) {
          if (value == null) {
            return;
          }
          setState(() => _labelMode = value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxContentHeight =
        MediaQuery.sizeOf(context).height * themeColorPickerDialogMaxHeightFraction;
    return Theme(
      data: _pickerTheme(Theme.of(context)),
      child: AlertDialog(
        key: const ValueKey('theme-color-picker-dialog'),
        backgroundColor: themeColorPickerDialogSurface,
        titlePadding: const EdgeInsetsDirectional.only(start: 24.0, top: 20.0),
        title: const Text(
          "Pick a color to get a theme based on that color",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: themeColorPickerDialogWidth,
            maxHeight: maxContentHeight,
          ),
          child: SizedBox(
            width: themeColorPickerDialogWidth,
            height: themeColorPickerDialogContentHeight,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _labelModeSelector(),
                  SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(
                        _valueLabel(_selectedColor),
                        key: const ValueKey('theme-color-picker-values'),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  ColorPicker(
                    enableAlpha: false,
                    portraitOnly: true,
                    colorPickerWidth: 300,
                    labelTypes: const [],
                    pickerColor: _selectedColor,
                    pickerAreaBorderRadius: BorderRadius.circular(40.0),
                    onColorChanged: (color) => setState(() => _selectedColor = color),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      DarkUnyoButton(
                        text: "Cancel",
                        maxHeight: 50,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 25.0),
                      LightUnyoButton(
                        text: "Confirm",
                        maxHeight: 50,
                        onPressed: () {
                          widget.onConfirmed(_selectedColor);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

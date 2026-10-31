import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:material_ui/material_ui.dart';

import 'package:unyo/presentation/dialogs/unyo_dialog_theme.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/light_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

/// Fixed width of the card. The content never follows the picker's intrinsic
/// size, so switching the label mode cannot resize the dialog.
const double themeColorPickerDialogWidth = 420;

/// Height cap of the card. The card hugs its content, and this is the tallest
/// it may get before the content scrolls (the artboard draws it at 620; the
/// system font reflows the title, so the natural height sits just above that).
const double themeColorPickerDialogHeight = 660;

/// Share of the window height the card may occupy at most.
const double themeColorPickerDialogMaxHeightFraction = 0.84;

/// Side of the square picker field.
const double themeColorPickerFieldSize = 288;

/// Colour picker with a fixed geometry frame and a theme that cannot invert.
///
/// `flutter_colorpicker` draws its own label row with the Flutter SDK's
/// material widgets; a `material_ui` app tree provides neither an SDK
/// `Material` nor an SDK `Theme`, so that row used to render with
/// `ThemeData.fallback()` (light) on the dialog's dark surface and its label
/// switcher asserted in debug builds. The label row is therefore never used:
/// the mode switch is the inline `RGB · HSV · HSL` text row below, drawn with
/// the app's own widgets and pinned colours.
///
/// Restyled to the "Minimal mono stack" artboard (WP #108 / PR #161 D5): eyebrow,
/// inline mode links with a 2px accent underline, a wide-tracked read-out, a
/// 288-wide radius-18 picker field, an 8px hue bar, and outline/filled pills.
class ThemeColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onConfirmed;

  const ThemeColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.onConfirmed,
  });

  /// The card itself, so tests can prove the geometry stays put across modes.
  static const Key cardKey = ValueKey('theme-color-picker-dialog');
  static const Key readOutKey = ValueKey('theme-color-picker-values');
  static const Key titleKey = ValueKey('theme-color-picker-title');
  static const Key eyebrowKey = ValueKey('theme-color-picker-eyebrow');

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

  HSVColor get _hsv => HSVColor.fromColor(_selectedColor);

  void _selectColor(HSVColor color) {
    setState(() => _selectedColor = color.toColor());
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

  /// Inline text mode switch: never a dropdown and never an overlay, so the
  /// card keeps one size whatever mode is showing.
  Widget _labelModeSelector(ColorScheme scheme) {
    final List<Widget> children = <Widget>[];
    for (final String mode in _labelModes) {
      if (children.isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '·',
              style: TextStyle(color: scheme.dialogDim, fontSize: 13),
            ),
          ),
        );
      }
      children.add(_modeLink(mode, scheme));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _modeLink(String mode, ColorScheme scheme) {
    final bool active = _labelMode == mode;
    return UnyoInkWell(
      key: ValueKey('theme-color-picker-mode-$mode'),
      onTap: () => setState(() => _labelMode = mode),
      borderRadius: BorderRadius.circular(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            mode,
            style: TextStyle(
              color: active ? scheme.dialogText : scheme.dialogDim,
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.78,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 26,
            height: 2,
            color: active ? scheme.dialogAccent : Colors.transparent,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.of(context);
    final double maxHeight =
        MediaQuery.sizeOf(context).height * themeColorPickerDialogMaxHeightFraction;
    final double height =
        themeColorPickerDialogHeight < maxHeight ? themeColorPickerDialogHeight : maxHeight;

    return Dialog(
      backgroundColor: scheme.dialogSurface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(unyoDialogCardRadius)),
      child: SizedBox(
        key: ThemeColorPickerDialog.cardKey,
        width: themeColorPickerDialogWidth,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height),
          child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(36, 32, 36, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'THEME COLOR',
                key: ThemeColorPickerDialog.eyebrowKey,
                style: TextStyle(
                  color: scheme.dialogDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.99,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                "Pick a color to get a theme based on that color",
                key: ThemeColorPickerDialog.titleKey,
                style: TextStyle(
                  color: scheme.dialogText,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.32,
                ),
              ),
              const SizedBox(height: 14),
              _labelModeSelector(scheme),
              const SizedBox(height: 18),
              Text(
                _valueLabel(_selectedColor),
                key: ThemeColorPickerDialog.readOutKey,
                style: TextStyle(
                  color: scheme.dialogText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.12,
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: themeColorPickerFieldSize,
                  height: themeColorPickerFieldSize,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: ColorPickerArea(_hsv, _selectColor, PaletteType.hsv),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ColorPickerSlider(TrackType.hue, _hsv, _selectColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // The app-standard pair, exactly as the calendar picker draws
              // it: filled dark Cancel + light Confirm, same height and gap
              // (WP #117). No bespoke outline/filled pill variants.
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  DarkUnyoButton(
                    text: 'Cancel',
                    maxHeight: 50,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 16),
                  LightUnyoButton(
                    text: 'Confirm',
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
    );
  }
}

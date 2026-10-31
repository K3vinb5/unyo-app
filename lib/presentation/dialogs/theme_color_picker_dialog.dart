import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:material_ui/material_ui.dart';

import 'package:unyo/presentation/dialogs/unyo_dialog_theme.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

/// Surface the picker dialog paints itself on.
///
/// Pinned (instead of inherited) because the dialog deliberately opts out of the
/// user theme: the picker area is drawn with fixed art (an HSV square), so the
/// panel around it has to stay one colour. Every colour that sits on this
/// surface is pinned against [themeColorPickerDialogSurface] below.
const Color themeColorPickerDialogSurface = Color(0xFF171717);

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
  Widget _labelModeSelector() {
    final List<Widget> children = <Widget>[];
    for (final String mode in _labelModes) {
      if (children.isNotEmpty) {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('·', style: TextStyle(color: unyoDialogDim, fontSize: 13)),
          ),
        );
      }
      children.add(_modeLink(mode));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _modeLink(String mode) {
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
              color: active ? unyoDialogText : unyoDialogDim,
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.78,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 26,
            height: 2,
            color: active ? unyoDialogAccent : Colors.transparent,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight =
        MediaQuery.sizeOf(context).height * themeColorPickerDialogMaxHeightFraction;
    final double height =
        themeColorPickerDialogHeight < maxHeight ? themeColorPickerDialogHeight : maxHeight;

    return Dialog(
      backgroundColor: themeColorPickerDialogSurface,
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
              const Text(
                'THEME COLOR',
                key: ThemeColorPickerDialog.eyebrowKey,
                style: TextStyle(
                  color: unyoDialogDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.99,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                "Pick a color to get a theme based on that color",
                key: ThemeColorPickerDialog.titleKey,
                style: TextStyle(
                  color: unyoDialogText,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.32,
                ),
              ),
              const SizedBox(height: 14),
              _labelModeSelector(),
              const SizedBox(height: 18),
              Text(
                _valueLabel(_selectedColor),
                key: ThemeColorPickerDialog.readOutKey,
                style: const TextStyle(
                  color: unyoDialogText,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  _OutlinePill(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  _FilledPill(
                    label: 'Confirm',
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

/// Secondary action: 1px outline pill of the family language.
class _OutlinePill extends StatelessWidget {
  const _OutlinePill({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return UnyoInkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 44,
        constraints: const BoxConstraints(minWidth: 104),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(color: unyoDialogText, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

/// Primary action: filled accent pill of the family language.
class _FilledPill extends StatelessWidget {
  const _FilledPill({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return UnyoInkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 44,
        constraints: const BoxConstraints(minWidth: 120),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: unyoDialogAccent,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

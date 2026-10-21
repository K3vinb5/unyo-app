import 'package:material_ui/material_ui.dart';

class UnyoToggle extends StatelessWidget {
  final bool value;
  final void Function(bool)? onChanged;

  const UnyoToggle({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      trackOutlineWidth: const WidgetStatePropertyAll(0.5),
      activeTrackColor: ColorScheme.of(context).primary,
      inactiveTrackColor: Colors.black45,
      trackOutlineColor: WidgetStatePropertyAll(Colors.white.withValues(alpha: 0.4)),
      inactiveThumbColor: Colors.white.withValues(alpha: 0.7),
      thumbColor: WidgetStateMapper({WidgetState.selected: ColorScheme.of(context).tertiary}),
      hoverColor: ColorScheme.of(context).tertiary.withValues(alpha: 0.1),
      onChanged: onChanged,
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';

/// Read-only settings row used by Settings → About: shows an icon, a title, a
/// description and an optional call-to-action button.
class UnyoSettingsVersionRow extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final void Function()? onAction;

  const UnyoSettingsVersionRow({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.info_rounded,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final showAction = actionLabel != null && onAction != null;
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
                  child: Icon(icon, color: ColorScheme.of(context).tertiary),
                ),
                const SizedBox(width: 18.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            if (showAction)
              DarkUnyoButton(
                text: actionLabel,
                height: 40,
                minWidth: 160,
                onPressed: onAction!,
              ),
          ],
        ),
      ),
    );
  }
}

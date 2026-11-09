import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/light_unyo_button.dart';

/// Two-button confirmation card (WP #167).
///
/// The same shape as `WarningDialog` — the app has one dark card family, not a
/// widget per question — plus a message line and a cancel/confirm pair, which
/// is what a destructive action needs before it runs. The caller shows it with
/// `showDialog` and does the work in [onConfirm]; this widget only pops.
class ConfirmDialog extends StatelessWidget {
  static const Key dialogKey = ValueKey('confirm-dialog');

  final String title;
  final String message;
  final void Function() onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: dialogKey,
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 24.0.h),
        child: SizedBox(
          width: 520,
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DarkUnyoButton(
                    text: context.tr('common_cancel'),
                    maxHeight: 45,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 20.0.w),
                  LightUnyoButton(
                    text: context.tr('common_confirm'),
                    maxHeight: 45,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

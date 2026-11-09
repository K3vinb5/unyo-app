import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

class UserOptionDrawerSelection extends StatelessWidget {
  const UserOptionDrawerSelection({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.destructive = false,
  });

  final String text;
  final IconData icon;
  final void Function() onPressed;

  /// Paints the row in the scheme's error colour so a removal reads as one
  /// without leaving the drawer's existing item shape (WP #151).
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final Color foreground = destructive ? ColorScheme.of(context).error : Colors.white;
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: foreground.withValues(alpha: 0.22))
      ),
      child: UnyoInkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 20.w,),
            Icon (
              icon,
              color: foreground,
              size: 22,
            ),
            SizedBox(width: 10.w,),
            Text(
              text,
              style: TextStyle(
                  color: foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w500
              ),
            )
          ],
        ),
      ),
    );
  }
}

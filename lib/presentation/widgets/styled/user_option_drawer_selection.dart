import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

class UserOptionDrawerSelection extends StatelessWidget {
  const UserOptionDrawerSelection({super.key, required this.text, required this.icon, required this.onPressed});

  final String text;
  final IconData icon;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1))
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
              color: Colors.white,
              size: 22,
            ),
            SizedBox(width: 10.w,),
            Text(
              text,
              style: const TextStyle(
                  color: Colors.white,
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

// External dependencies
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Internal dependencies
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/widgets/styled/hover_animated_container.dart';
import 'package:unyo/presentation/widgets/text/text_headline_large.dart';

class UserAvatar extends StatelessWidget {
  final User user;
  final void Function() onPressed;

  const UserAvatar({super.key, required this.user, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0.w),
      child: Column(
        children: [
          HoverAnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 160.h,
            height: 160.h,
            hoverWidth: 165.h,
            hoverHeight: 165.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(250),
              border: Border.all(color: Colors.white, width: 3),
            ),
            hoverDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(250),
              border: Border.all(color: Colors.white, width: 5),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(140.r),
              onTap: onPressed,
              child: CircleAvatar(
                radius: 90.h,
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(user.avatarImage),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerLeft,
            child: TextHeadlineLarge(text: user.name),
          ),
        ],
      ),
    );
  }
}

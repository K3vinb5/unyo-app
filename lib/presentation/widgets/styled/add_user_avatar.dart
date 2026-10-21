// External dependencies
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/presentation/widgets/styled/hover_animated_container.dart';
import 'package:unyo/presentation/widgets/text/text_headline_large.dart';

class AddUserAvatar extends StatelessWidget {
  final void Function() onPressed;

  const AddUserAvatar({super.key, required this.onPressed});

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
                backgroundImage: const NetworkImage(config.plusImageUrl),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerLeft,
            child: TextHeadlineLarge(text: context.tr("add_account")),
          ),
        ],
      ),
    );
  }
}

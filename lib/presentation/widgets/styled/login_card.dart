// External dependencies
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unyo/presentation/widgets/text/text_headline_medium.dart';
import 'package:unyo/presentation/widgets/text/text_label_medium.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

class LoginCard extends StatelessWidget {
  final String title;
  final String description;
  final SvgPicture svgPicture;
  final bool isSelected;
  final void Function() onTap;

  const LoginCard({super.key, required this.svgPicture, required this.title, required this.description, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0.w),
      child: UnyoInkWell(
        borderRadius: BorderRadius.circular(20.0.r),
        onTap: onTap,
        child: Container(
          width: 200.w,
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0.r),
            border: Border.all(width: 2.w, color: isSelected ? Colors.white : const Color.fromARGB(255, 37, 37, 37)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(icon, size: 100.r,),
              svgPicture,
              SizedBox(height: 10.h,),
              TextHeadlineMedium(text: title),
              TextLabelMedium(text: description)
            ],
          ),
        ),
      ),
    );
  }
}

// External dependencies
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/text/text_headline_medium.dart';
import 'package:unyo/presentation/widgets/text/text_label_medium.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

/// One selectable account service.
///
/// The card is a fixed 200x200 box, so everything inside it is constrained to
/// the card: the logo scales down when the box is tighter than the artwork, the
/// title shrinks to fit the width, and a long description ellipsises instead of
/// painting over the border (WP #111).
class LoginCard extends StatelessWidget {
  /// Design-pixel size of the card body.
  static const double extent = 200;

  /// Horizontal padding between the card body and the next card.
  static const double horizontalGap = 12;

  final String title;
  final String description;
  final Widget logo;
  final bool isSelected;
  final void Function() onTap;

  const LoginCard({super.key, required this.logo, required this.title, required this.description, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalGap.w),
      child: UnyoInkWell(
        borderRadius: BorderRadius.circular(20.0.r),
        onTap: onTap,
        child: Container(
          width: extent.w,
          height: extent.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0.r),
            border: Border.all(width: 2.w, color: isSelected ? Colors.white : const Color.fromARGB(255, 37, 37, 37)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Only ever shrinks: artwork keeps its designed size when the box
              // is generous (scaleDown, not contain).
              Flexible(
                flex: 5,
                child: FittedBox(fit: BoxFit.scaleDown, child: logo),
              ),
              SizedBox(height: 10.h,),
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TextHeadlineMedium(text: title, maxLines: 1),
                ),
              ),
              Flexible(
                flex: 2,
                child: TextLabelMedium(
                  text: description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

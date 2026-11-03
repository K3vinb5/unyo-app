// External dependencies
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/config/assets.dart';
import 'package:unyo/presentation/widgets/styled/hover_animated_container.dart';
import 'package:unyo/presentation/widgets/text/text_headline_large.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

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
            child: UnyoInkWell(
              borderRadius: BorderRadius.circular(140.r),
              onTap: onPressed,
              child: SizedBox(
                width: 180.h,
                height: 180.h,
                child: AddUserAvatarGlyph(borderRadius: 90.h),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerLeft,
            child: TextHeadlineLarge(text: context.tr("dialog_add_account")),
          ),
        ],
      ),
    );
  }
}

/// The "+" artwork of the add-user tile, bundled with the binary (WP #102).
///
/// A bitmap rather than `Icons.add_rounded`: the ticket keeps the tile's look
/// identical to the remote artwork it replaces, and only the image source
/// changes. Split out from [AddUserAvatar] so it can be tested without the
/// localization/DI the tile itself pulls in.
class AddUserAvatarGlyph extends StatelessWidget {
  const AddUserAvatarGlyph({super.key, this.borderRadius = 0, this.size});

  final double borderRadius;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(AppAssets.addUserIcon, fit: BoxFit.cover),
      ),
    );
  }
}

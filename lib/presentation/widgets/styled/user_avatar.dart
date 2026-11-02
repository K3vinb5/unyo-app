// External dependencies
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Internal dependencies
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/widgets/styled/hover_animated_container.dart';
import 'package:unyo/presentation/widgets/styled/service_badge.dart';
import 'package:unyo/presentation/widgets/text/text_headline_large.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';
import 'package:unyo/presentation/widgets/styled/user_avatar_image.dart';

/// One account tile on the "Who's watching?" screen: the avatar circle, the
/// service badge in its bottom-right, and the display name.
class UserAvatar extends StatelessWidget {
  /// Distance from the avatar circle's bounding-box edges to the badge's box.
  ///
  /// Keeps the badge inside the circle (not just inside the square): its centre
  /// then sits ~63.6px from the avatar centre, and the 15px plate radius ends
  /// ~1.4px short of the 80px circle.
  static const double badgeInset = 20;

  final User user;
  final void Function() onPressed;

  const UserAvatar({super.key, required this.user, required this.onPressed});

  /// Key of this tile's badge, so a driven run can target one account's mark.
  static Key badgeKeyFor(User user) =>
      ValueKey<String>('user-avatar-badge-${user.id}-${user.name}');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0.w),
      child: Column(
        children: [
          Stack(
            // The hovered container grows past the resting 160.h box.
            clipBehavior: Clip.none,
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
                    // The resolver decides the source (bundled default for
                    // empty/legacy values, Image.asset for bundled paths,
                    // UnyoNetworkImage for real URLs) — WP #102.
                    child: UserAvatarImage(
                      avatarImage: user.avatarImage,
                      fit: BoxFit.cover,
                      borderRadius: 90.h,
                    ),
                  ),
                ),
              ),
              // Overlay, not part of the column: the badge never changes the
              // tile's layout, and the resting box keeps it inside the circle
              // while the container grows on hover.
              Positioned(
                right: badgeInset.h,
                bottom: badgeInset.h,
                child: ServiceBadgeView(
                  key: badgeKeyFor(user),
                  badge: ServiceBadge.of(user),
                ),
              ),
            ],
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

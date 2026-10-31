import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

/// One labelled line in the profile card.
class UserProfileField {
  const UserProfileField({required this.label, required this.value});

  final String label;
  final String value;
}

/// The account card behind the drawer's "View Profile": who is signed in and
/// with which provider, built only from the [User] every provider model
/// already implements.
///
/// No provider offers a profile/stats query yet, so the card is identity only —
/// banner, avatar, display name, provider label and the account id. Slots an
/// account does not have are dropped by [visibleFields] rather than
/// special-cased per provider: a local account has no remote id, so that row
/// simply does not render. Adding a field later is one more entry in
/// [fieldsOf].
class UserProfileDialog extends StatelessWidget {
  const UserProfileDialog({super.key, required this.user});

  /// The avatar slot, so tests (and the driven run) can tell it apart from the
  /// banner backdrop without depending on the image loading.
  static const Key avatarKey = ValueKey<String>('profile-dialog-avatar');

  /// The banner backdrop. Absent when the account has no banner.
  static const Key bannerKey = ValueKey<String>('profile-dialog-banner');

  final User user;

  /// The rows under the identity block, in display order.
  static List<UserProfileField> fieldsOf(User user) => <UserProfileField>[
    UserProfileField(label: 'Account ID', value: user.id),
  ];

  /// The empty-slot rule: a row whose value is empty renders nothing at all.
  static List<UserProfileField> visibleFields(List<UserProfileField> fields) =>
      fields.where((UserProfileField field) => field.value.trim().isNotEmpty).toList();

  /// Provider wording, the same the drawer's subtitle already uses.
  static String providerLabel(Service service) => '${TextUtils.capitalize(service.name)} account';

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = ColorScheme.of(context);
    return Dialog(
      backgroundColor: colors.secondary,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: SizedBox(
        width: 460.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, colors),
            _buildBody(context, colors),
          ],
        ),
      ),
    );
  }

  /// Identity over the banner: the banner is the backdrop when the account has
  /// one, and the header colour stands in for it otherwise.
  Widget _buildHeader(BuildContext context, ColorScheme colors) {
    final bool hasBanner = user.bannerImage.isNotEmpty;
    return SizedBox(
      height: 200.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: colors.primary),
          if (hasBanner) ...[
            UnyoNetworkImage(key: bannerKey, url: user.bannerImage),
            // Scrim: the identity block has to stay readable on top of whatever
            // artwork the provider serves, so the banner fades into the header
            // colour it sits on.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    colors.primary.withValues(alpha: 0.0),
                    colors.primary,
                  ],
                  stops: const <double>[0.35, 1.0],
                ),
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.fromLTRB(28.w, 0, 28.w, 22.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UnyoNetworkImage(
                  key: avatarKey,
                  url: user.avatarImage,
                  width: 96.w,
                  height: 96.w,
                  borderRadius: 48.w,
                ),
                SizedBox(height: 12.h),
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  providerLabel(user.settings.userService),
                  style: TextStyle(
                    color: colors.onPrimary.withValues(alpha: 0.75),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme colors) {
    final List<UserProfileField> fields = visibleFields(fieldsOf(user));
    return Padding(
      padding: EdgeInsets.fromLTRB(28.w, 20.h, 28.w, 22.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final UserProfileField field in fields)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130.w,
                    child: Text(
                      field.label,
                      style: TextStyle(
                        color: colors.onSecondary.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      field.value,
                      style: TextStyle(
                        color: colors.onSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (fields.isNotEmpty) SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DarkUnyoButton(
                text: 'Close',
                color: colors.primary,
                textColor: colors.onPrimary,
                maxHeight: 44,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

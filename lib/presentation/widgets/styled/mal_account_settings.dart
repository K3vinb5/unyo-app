import 'package:material_ui/material_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';
import 'package:unyo/presentation/widgets/text/text_body_large.dart';
import 'package:unyo/presentation/widgets/text/text_label_medium.dart';

/// The "MyAnimeList" account pane of the settings screen (WP #156).
///
/// Mirrors [ShikimoriAccountSettings] (WP #64 subpart (c)): the pane renders
/// whatever the existing `SettingsCubit` state already holds — it takes the
/// logged user as a parameter instead of opening a second bloc — and logout
/// goes through the injected callback, which the settings screen wires to the
/// app-wide `TabsCubit.logoutUser` used by the user drawer.
///
/// A MAL access token is refreshed invisibly by the repositories before it
/// expires, so the pane shows the account, not the token.
class MalAccountSettings extends StatelessWidget {
  final User loggedUser;
  final VoidCallback onLogout;

  const MalAccountSettings({
    super.key,
    required this.loggedUser,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final User user = loggedUser;
    if (user is! MalUserModel) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 15.0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextBodyLarge(
              text: context.tr("settings_myanimelist_no_account"),
              style: const TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 6.h),
            TextLabelMedium(
              text: context.tr("settings_myanimelist_no_account_hint"),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 15.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: UnyoNetworkImage(
              url: user.avatarImage,
              fit: BoxFit.cover,
              borderRadius: 27,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextBodyLarge(
                  text: user.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                TextLabelMedium(
                  text: user.profileUrl.isEmpty ? context.tr("common_myanimelist_account") : user.profileUrl,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          DarkUnyoButton(text: context.tr("common_logout"), maxHeight: 40, onPressed: onLogout),
        ],
      ),
    );
  }
}

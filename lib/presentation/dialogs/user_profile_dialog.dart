import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/dialogs/unyo_dialog_theme.dart';
import 'package:unyo/presentation/widgets/styled/light_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

/// Width of the profile card, matching the "Centered monogram" artboard.
const double userProfileDialogWidth = 460;

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
/// avatar, display name, provider label and the account id. Slots an account
/// does not have are dropped by [visibleFields] rather than special-cased per
/// provider: a local account has no remote id, so that row (and the whole
/// ACCOUNT block under its divider) simply does not render. Adding a field
/// later is one more entry in [fieldsOf].
///
/// Restyled to the "Centered monogram" artboard (WP #108 / PR #158 D2): wash,
/// radial halo behind an 80px avatar, everything centred on a 24-top / 42-bottom
/// stack, and a full-width pill as the only action. The avatar sits straight on
/// the card surface (WP #117) — the opaque white ring used to show as a bright
/// disc behind transparent PNGs — and every colour now comes from the active
/// [ColorScheme] so a theme swap recolours the card.
class UserProfileDialog extends StatelessWidget {
  const UserProfileDialog({super.key, required this.user});

  /// The avatar slot, so tests (and the driven run) can tell it apart from the
  /// banner backdrop without depending on the image loading.
  static const Key avatarKey = ValueKey<String>('profile-dialog-avatar');

  /// The banner backdrop. Absent when the account has no banner.
  static const Key bannerKey = ValueKey<String>('profile-dialog-banner');

  /// The full-width primary action.
  static const Key closeKey = ValueKey<String>('profile-dialog-close');

  /// Diameter of the avatar the halo sits behind.
  static const double avatarSize = 80;

  final User user;

  /// The rows under the identity block, in display order.
  static List<UserProfileField> fieldsOf(User user) => <UserProfileField>[
    UserProfileField(label: 'Account ID', value: user.id),
  ];

  /// The empty-slot rule: a row whose value is empty renders nothing at all.
  static List<UserProfileField> visibleFields(List<UserProfileField> fields) =>
      fields.where((UserProfileField field) => field.value.trim().isNotEmpty).toList();

  /// Provider wording, the same the drawer's subtitle already uses. A local
  /// account has no provider behind it, so it says so instead of repeating the
  /// service its settings happen to carry.
  static String providerLabel(User user) => user is LocalUserModel
      ? 'Local account'
      : '${TextUtils.capitalize(user.settings.userService.name)} account';

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.of(context);
    final List<UserProfileField> fields = visibleFields(fieldsOf(user));
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(unyoDialogCardRadius)),
      child: SizedBox(
        width: userProfileDialogWidth,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[scheme.dialogWashTop, scheme.dialogSurface],
            ),
          ),
          child: Stack(
            children: <Widget>[
              if (user.bannerImage.isNotEmpty)
                Positioned.fill(
                  child: UnyoNetworkImage(key: bannerKey, url: user.bannerImage),
                ),
              // The wash is repainted over the banner so the artwork reads as a
              // texture under the card instead of competing with the avatar.
              if (user.bannerImage.isNotEmpty)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          scheme.dialogWashTop.withValues(alpha: 0.8),
                          scheme.dialogSurface.withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 0,
                left: (userProfileDialogWidth - 220) / 2,
                width: 220,
                height: 220,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        scheme.dialogAccent.withValues(alpha: 0.20),
                        scheme.dialogAccent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 42),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _AvatarHalo(size: avatarSize, url: user.avatarImage, scheme: scheme),
                    const SizedBox(height: 28),
                    Text(
                      user.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.dialogText,
                        fontSize: 26,
                        height: 1.18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      providerLabel(user),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.dialogDim, fontSize: 13),
                    ),
                    if (fields.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 28),
                      Center(
                        child: Container(
                          width: 280,
                          height: 1,
                          color: scheme.dialogRule,
                        ),
                      ),
                      const SizedBox(height: 11),
                      Text(
                        'ACCOUNT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: scheme.dialogDim,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      for (final UserProfileField field in fields)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Column(
                            children: <Widget>[
                              Text(
                                field.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: scheme.dialogDim, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                field.value,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: scheme.dialogText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    const SizedBox(height: 33),
                    // The family's primary action is the app-standard light
                    // button, not a bespoke accent pill (WP #117).
                    LightUnyoButton(
                      key: UserProfileDialog.closeKey,
                      text: 'Close',
                      width: double.infinity,
                      height: 44,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 80px avatar with the soft radial halo behind it.
///
/// No plate, ring or fill behind the image (WP #117): the avatar sits straight
/// on the card surface, so a transparent PNG shows the themed wash through its
/// empty pixels instead of a bright white disc. The halo is the only separation
/// a photo avatar needs.
class _AvatarHalo extends StatelessWidget {
  const _AvatarHalo({required this.size, required this.url, required this.scheme});

  final double size;
  final String url;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size + 28,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: size + 28,
              height: size + 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    scheme.dialogAccent.withValues(alpha: 0.7),
                    scheme.dialogAccent.withValues(alpha: 0.2),
                    scheme.dialogAccent.withValues(alpha: 0.0),
                  ],
                  stops: const <double>[0.0, 0.55, 1.0],
                ),
              ),
            ),
            UnyoNetworkImage(
              key: UserProfileDialog.avatarKey,
              url: url,
              width: size,
              height: size,
              borderRadius: size / 2,
            ),
          ],
        ),
      ),
    );
  }
}

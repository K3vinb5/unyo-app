import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/dialogs/unyo_dialog_theme.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

/// Card surface at the bottom of the profile wash.
const Color userProfileDialogSurface = Color(0xFF1E1E1E);

/// Violet the card wash starts from (top edge, behind the avatar).
const Color userProfileDialogWashTop = Color(0xFF2A2135);

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
/// Restyled to the "Centered monogram" artboard (WP #108 / PR #158 D2): violet
/// to #1E1E1E wash, radial halo behind an 80px avatar, everything centred on a
/// 24-top / 42-bottom stack, and a full-width accent pill as the only action.
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
    final List<UserProfileField> fields = visibleFields(fieldsOf(user));
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(unyoDialogCardRadius)),
      child: SizedBox(
        width: userProfileDialogWidth,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[userProfileDialogWashTop, userProfileDialogSurface],
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
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Color(0xCC2A2135),
                          Color(0xF21E1E1E),
                        ],
                      ),
                    ),
                  ),
                ),
              const Positioned(
                top: 0,
                left: (userProfileDialogWidth - 220) / 2,
                width: 220,
                height: 220,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        Color(0x339266A8),
                        Color(0x009266A8),
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
                    _AvatarHalo(size: avatarSize, url: user.avatarImage),
                    const SizedBox(height: 28),
                    Text(
                      user.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: unyoDialogText,
                        fontSize: 26,
                        height: 1.18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      providerLabel(user),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: unyoDialogDim, fontSize: 13),
                    ),
                    if (fields.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 28),
                      Center(
                        child: Container(
                          width: 280,
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      const SizedBox(height: 11),
                      const Text(
                        'ACCOUNT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: unyoDialogDim,
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
                                style: const TextStyle(color: unyoDialogDim, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                field.value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: unyoDialogText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    const SizedBox(height: 33),
                    _DialogPill(
                      key: UserProfileDialog.closeKey,
                      label: 'Close',
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

/// The 80px avatar with a 2px ring and the soft radial halo behind it.
class _AvatarHalo extends StatelessWidget {
  const _AvatarHalo({required this.size, required this.url});

  final double size;
  final String url;

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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    Color(0xB39266A8),
                    Color(0x339266A8),
                    Color(0x009266A8),
                  ],
                  stops: <double>[0.0, 0.55, 1.0],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: UnyoNetworkImage(
                key: UserProfileDialog.avatarKey,
                url: url,
                width: size,
                height: size,
                borderRadius: size / 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The family's primary action: a filled accent pill.
class _DialogPill extends StatelessWidget {
  const _DialogPill({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return UnyoInkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: unyoDialogAccent,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

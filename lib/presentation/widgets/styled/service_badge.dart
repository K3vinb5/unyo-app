// External dependencies
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/domain/entities/user/user.dart';

/// The account service an avatar belongs to, as one small mark (WP #112).
///
/// This is the only place that knows how a service looks: the avatar tile reads
/// [ServiceBadge.of] and paints it, so adding a provider means adding an enum
/// value, a case in [ServiceBadge.fromService] and — when a brand mark lands —
/// one more const. Brand artwork is the same set the account picker's
/// `LoginCard`s already ship, so no new assets are introduced.
@immutable
class ServiceBadge {
  const ServiceBadge._({this.asset, this.glyph, required this.labelKey})
    : assert(asset != null || glyph != null, 'a badge needs an asset or a glyph');

  /// Brand mark asset, drawn on the plate.
  final String? asset;

  /// Fallback glyph for providers that ship no brand mark.
  final IconData? glyph;

  /// Human description, used for the semantics label. Kept as an i18n key so
  /// the badges stay `const`; [ServiceBadgeView] resolves it with `context.tr`.
  final String labelKey;

  static const ServiceBadge anilist = ServiceBadge._(
    asset: 'assets/images/anilist.svg',
    labelKey: 'common_anilist_account',
  );

  static const ServiceBadge shikimori = ServiceBadge._(
    asset: 'assets/images/shikimori.svg',
    labelKey: 'settings_shikimori_account',
  );

  static const ServiceBadge myanimelist = ServiceBadge._(
    asset: 'assets/images/myanimelist.svg',
    labelKey: 'common_myanimelist_account',
  );

  /// Offline accounts. Deliberately not a provider: a local account is its own
  /// kind, not an unknown one.
  static const ServiceBadge local = ServiceBadge._(
    asset: 'assets/images/local_account.svg',
    labelKey: 'common_local_account',
  );

  /// A provider without a brand mark yet (Kitsu, Simkl) — visibly different
  /// from [local].
  static const ServiceBadge generic = ServiceBadge._(
    glyph: Icons.public_rounded,
    labelKey: 'common_unknown_account_service',
  );

  /// The single service → mark mapping. The switch is exhaustive on purpose:
  /// adding a [Service] fails to compile until it is mapped here.
  static ServiceBadge fromService(Service service) => switch (service) {
    Service.anilist => anilist,
    Service.shikimori => shikimori,
    Service.mal => myanimelist,
    Service.kitsu || Service.simkl => generic,
  };

  /// The badge for [user]. Local accounts are offline: their settings carry the
  /// default `userService` (AniList) which is not where the account lives, so
  /// they are resolved by type first.
  static ServiceBadge of(User user) =>
      user is LocalUserModel ? local : fromService(user.settings.userService);
}

/// [ServiceBadge] painted as a dark plate with the brand glyph, sized to sit in
/// the bottom-right corner of a 160.h avatar without a layout shift.
///
/// The dark plate (plus its light rim) is what keeps the glyph readable on both
/// light and dark avatars; artwork that already carries its own coloured disc
/// (AniList, MAL) simply covers the plate.
class ServiceBadgeView extends StatelessWidget {
  const ServiceBadgeView({super.key, required this.badge});

  /// Plate diameter in design pixels.
  static const double plateDiameter = 30;

  /// Plate colour: darker than any avatar artwork the app shows.
  static const Color plateColor = Color(0xFF14121A);

  final ServiceBadge badge;

  @override
  Widget build(BuildContext context) {
    final double size = plateDiameter.h;
    final Widget glyph = badge.asset != null
        ? SvgPicture.asset(
            badge.asset!,
            width: size * 0.78,
            height: size * 0.78,
            fit: BoxFit.contain,
          )
        : Icon(badge.glyph, size: size * 0.58, color: Colors.white);

    return Semantics(
      label: context.tr(badge.labelKey),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: plateColor,
          border: Border.all(color: const Color(0xE6FFFFFF), width: 1.w),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 1)),
          ],
        ),
        // Brand marks are square artwork with their own chrome; the oval keeps
        // every one of them inside the plate.
        child: ClipOval(child: Center(child: glyph)),
      ),
    );
  }
}

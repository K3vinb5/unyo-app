// External dependencies
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/config/assets.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';

/// Renders a persisted `avatarImage` value (WP #102).
///
/// `User.avatarImage` comes from three different places — the AniList/Shikimori
/// APIs (absolute URL), the bundled placeholder, and Hive, where local accounts
/// created before this ticket still carry the third-party URL that
/// `UserModel.empty()` used to hardcode. Every avatar call site goes through
/// this widget so the cases can never diverge:
///
/// * empty → the bundled [AppAssets.defaultAvatar],
/// * the legacy persisted placeholder (matched by file name, see
///   [legacyDefaultAvatarFileName]) → the bundled default too (a
///   migration: no Hive rewrite, no network request, no blank slot offline),
/// * `assets/…` → `Image.asset`,
/// * `http(s)://…` → [UnyoNetworkImage] (remote AniList/Shikimori avatars keep
///   the skeleton + fade).
///
/// Assets deliberately bypass [UnyoNetworkImage]: its skeleton and 250ms fade
/// exist to cover a download, which a bundled file does not have.
class UserAvatarImage extends StatelessWidget {
  const UserAvatarImage({
    super.key,
    required this.avatarImage,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  /// Bundled placeholder used for local accounts and for the legacy value.
  static const String defaultAvatarAsset = AppAssets.defaultAvatar;

  /// File name of the placeholder the pre-#102 build persisted for every local
  /// account (`UserModel.empty()`). Matched by file name only so this file — and
  /// therefore the app bundle — carries no third-party image host.
  static const String legacyDefaultAvatarFileName = 'EKtChtm.png';

  final String avatarImage;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  /// The bundled asset that should be shown for [avatarImage], or `null` when
  /// the value is a real remote URL that must be fetched.
  static String? bundledAssetFor(String avatarImage) {
    final String value = avatarImage.trim();
    if (value.isEmpty) return defaultAvatarAsset;
    if (value.startsWith('assets/')) return value;

    final Uri? uri = Uri.tryParse(value);
    if (uri == null) return null;
    final bool remote = uri.scheme == 'http' || uri.scheme == 'https';
    // The legacy placeholder is the only image `UserModel.empty()` ever wrote;
    // older local accounts still hold it in Hive.
    final bool legacyDefault =
        remote &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments.last == legacyDefaultAvatarFileName;
    return legacyDefault ? defaultAvatarAsset : null;
  }

  @override
  Widget build(BuildContext context) {
    final String? asset = bundledAssetFor(avatarImage);
    if (asset == null) {
      return UnyoNetworkImage(
        url: avatarImage,
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(asset, fit: fit),
      ),
    );
  }
}

// External dependencies
import 'package:package_info_plus/package_info_plus.dart';

/// Reads the version the app was built with.
///
/// `package_info_plus` reports the version baked in at build time (from
/// pubspec.yaml), so it can never drift from what the release workflow stamps.
class AppVersionProvider {
  const AppVersionProvider();

  /// Returns the current version without a leading `v` or `+build` metadata,
  /// or `null` when the platform cannot report it.
  Future<String?> currentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version.trim();
      if (version.isEmpty) return null;
      return version.startsWith('v') || version.startsWith('V') ? version.substring(1) : version;
    } catch (_) {
      return null;
    }
  }
}

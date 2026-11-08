// External dependencies
import 'package:package_info_plus/package_info_plus.dart';

/// What the running build was stamped with: the version the release workflow
/// took from `pubspec.yaml` and the build number next to it.
///
/// [buildNumber] is empty when the platform reports none, so the About dialog
/// can drop the "build" half of its version line instead of printing a blank
/// separator.
class AppBuildInfo {
  const AppBuildInfo({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  bool get hasBuildNumber => buildNumber.trim().isNotEmpty;
}

/// Reads the version the app was built with.
///
/// `package_info_plus` reports the version baked in at build time (from
/// pubspec.yaml), so it can never drift from what the release workflow stamps.
class AppVersionProvider {
  const AppVersionProvider();

  /// Returns the current version without a leading `v` or `+build` metadata,
  /// or `null` when the platform cannot report it.
  Future<String?> currentVersion() async => (await readBuildInfo())?.version;

  /// Version plus build number, or `null` when the platform cannot report the
  /// version at all. The About dialog (WP #150) is the multi-field caller;
  /// the update check keeps using [currentVersion].
  Future<AppBuildInfo?> readBuildInfo() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      final String version = _withoutTagPrefix(info.version.trim());
      if (version.isEmpty) return null;
      return AppBuildInfo(
        version: version,
        buildNumber: info.buildNumber.trim(),
      );
    } catch (_) {
      return null;
    }
  }

  static String _withoutTagPrefix(String version) =>
      version.startsWith('v') || version.startsWith('V')
          ? version.substring(1)
          : version;
}

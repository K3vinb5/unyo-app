import 'dart:io';

import 'package:unyo/core/services/api/dto/github/github_release_entity.dart';

/// The desktop platforms Unyo ships installers for, as far as the update notice
/// is concerned. Kept as a value so tests can drive every branch without
/// running on that OS.
enum UpdatePlatform { windows, macOS, linux }

extension UpdatePlatformInfo on UpdatePlatform {
  /// The platform the app is running on right now.
  static UpdatePlatform get current {
    if (Platform.isWindows) return UpdatePlatform.windows;
    if (Platform.isMacOS) return UpdatePlatform.macOS;
    return UpdatePlatform.linux;
  }

  /// Human name used in the dialog button ("Download for macOS").
  String get label => switch (this) {
    UpdatePlatform.windows => 'Windows',
    UpdatePlatform.macOS => 'macOS',
    UpdatePlatform.linux => 'Linux',
  };
}

/// Picks the release asset that installs Unyo on a given platform, following
/// the installer naming the release workflow publishes:
///
/// * Windows -> the Inno Setup installer (`*-windows-setup.exe`)
/// * macOS   -> the disk image (`*.dmg`)
/// * Linux   -> the AppImage (`*.AppImage`)
///
/// Stateless, so the member is static: call sites read
/// `ReleaseAssetSelector.urlFor(...)`.
class ReleaseAssetSelector {
  /// Returns the asset download URL for [platform], or null when the release
  /// carries no matching asset (for example a best-effort release where one
  /// platform's build failed), which hides the download action and leaves the
  /// release page as the only way forward.
  static String? urlFor(
    Iterable<GithubReleaseAssets> assets,
    UpdatePlatform platform,
  ) {
    for (final asset in assets) {
      final name = asset.name.trim().toLowerCase();
      final url = asset.browserDownloadUrl.trim();
      if (name.isEmpty || url.isEmpty) continue;
      if (_matchesPlatform(name, platform)) return url;
    }
    return null;
  }

  static bool _matchesPlatform(String name, UpdatePlatform platform) {
    return switch (platform) {
      UpdatePlatform.windows =>
        name.endsWith('-windows-setup.exe') ||
            name.contains('setup.exe') ||
            name.contains('-windows-'),
      UpdatePlatform.macOS => name.endsWith('.dmg'),
      UpdatePlatform.linux => name.endsWith('.appimage'),
    };
  }
}

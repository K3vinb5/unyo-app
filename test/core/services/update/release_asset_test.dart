// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/github/github_release_entity.dart';
import 'package:unyo/core/services/update/release_asset_selector.dart';

GithubReleaseAssets asset(String name, [String? url]) => GithubReleaseAssets()
  ..name = name
  ..browserDownloadUrl =
      url ?? 'https://github.com/K3vinb5/Unyo/releases/download/v0.9.0/$name';

/// The asset names `.github/workflows/release.yml` publishes, plus the zips and
/// the non-installer extras a release may also carry.
final List<GithubReleaseAssets> releaseAssets = [
  asset('Unyo-v0.9.0-linux.zip'),
  asset('Unyo-v0.9.0-linux.AppImage'),
  asset('Unyo-v0.9.0-windows.zip'),
  asset('Unyo-v0.9.0-windows-setup.exe'),
  asset('Unyo-v0.9.0-macos.zip'),
  asset('Unyo-v0.9.0-macos.dmg'),
];

void main() {
  group('ReleaseAssetSelector.urlFor', () {
    test('picks the Inno installer for Windows', () {
      expect(
        ReleaseAssetSelector.urlFor(releaseAssets, UpdatePlatform.windows),
        endsWith('Unyo-v0.9.0-windows-setup.exe'),
      );
    });

    test('picks the dmg for macOS', () {
      expect(
        ReleaseAssetSelector.urlFor(releaseAssets, UpdatePlatform.macOS),
        endsWith('Unyo-v0.9.0-macos.dmg'),
      );
    });

    test('picks the AppImage for Linux', () {
      expect(
        ReleaseAssetSelector.urlFor(releaseAssets, UpdatePlatform.linux),
        endsWith('Unyo-v0.9.0-linux.AppImage'),
      );
    });

    test('returns null when the release has no asset for the platform', () {
      final List<GithubReleaseAssets> windowsOnly = [asset('Unyo-v0.9.0-windows-setup.exe')];

      expect(ReleaseAssetSelector.urlFor(windowsOnly, UpdatePlatform.macOS), isNull);
      expect(ReleaseAssetSelector.urlFor(windowsOnly, UpdatePlatform.linux), isNull);
      expect(ReleaseAssetSelector.urlFor(const [], UpdatePlatform.windows), isNull);
    });

    test('accepts the other Windows installer spellings', () {
      for (final name in [
        'Unyo-windows-setup.exe',
        'Unyo-0.9.0-Windows-Setup.EXE',
        'Unyo-0.9.0-windows-x64.exe',
      ]) {
        expect(
          ReleaseAssetSelector.urlFor([asset(name)], UpdatePlatform.windows),
          isNotNull,
          reason: name,
        );
      }
    });

    test('skips assets without a download url', () {
      final List<GithubReleaseAssets> incomplete = [
        asset('Unyo-v0.9.0-linux.AppImage', '   '),
        asset('Unyo-v0.9.0-linux-x86_64.AppImage'),
      ];

      expect(
        ReleaseAssetSelector.urlFor(incomplete, UpdatePlatform.linux),
        endsWith('Unyo-v0.9.0-linux-x86_64.AppImage'),
      );
    });

    test('labels each platform the way the button shows it', () {
      expect(UpdatePlatform.windows.label, 'Windows');
      expect(UpdatePlatform.macOS.label, 'macOS');
      expect(UpdatePlatform.linux.label, 'Linux');
    });
  });
}

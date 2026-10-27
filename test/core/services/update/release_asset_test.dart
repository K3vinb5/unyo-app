// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/github/github_release_entity.dart';
import 'package:unyo/core/services/update/release_asset.dart';

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
  group('releaseAssetUrl', () {
    test('picks the Inno installer for Windows', () {
      expect(
        releaseAssetUrl(releaseAssets, UpdatePlatform.windows),
        endsWith('Unyo-v0.9.0-windows-setup.exe'),
      );
    });

    test('picks the dmg for macOS', () {
      expect(
        releaseAssetUrl(releaseAssets, UpdatePlatform.macOS),
        endsWith('Unyo-v0.9.0-macos.dmg'),
      );
    });

    test('picks the AppImage for Linux', () {
      expect(
        releaseAssetUrl(releaseAssets, UpdatePlatform.linux),
        endsWith('Unyo-v0.9.0-linux.AppImage'),
      );
    });

    test('returns null when the release has no asset for the platform', () {
      final windowsOnly = [asset('Unyo-v0.9.0-windows-setup.exe')];

      expect(releaseAssetUrl(windowsOnly, UpdatePlatform.macOS), isNull);
      expect(releaseAssetUrl(windowsOnly, UpdatePlatform.linux), isNull);
      expect(releaseAssetUrl(const [], UpdatePlatform.windows), isNull);
    });

    test('accepts the other Windows installer spellings', () {
      for (final name in [
        'Unyo-windows-setup.exe',
        'Unyo-0.9.0-Windows-Setup.EXE',
        'Unyo-0.9.0-windows-x64.exe',
      ]) {
        expect(
          releaseAssetUrl([asset(name)], UpdatePlatform.windows),
          isNotNull,
          reason: name,
        );
      }
    });

    test('skips assets without a download url', () {
      final incomplete = [
        asset('Unyo-v0.9.0-linux.AppImage', '   '),
        asset('Unyo-v0.9.0-linux-x86_64.AppImage'),
      ];

      expect(
        releaseAssetUrl(incomplete, UpdatePlatform.linux),
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

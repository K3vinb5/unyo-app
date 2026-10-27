// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/services/update/release_page_launcher.dart';

void main() {
  group('ReleasePageLauncher.pageUri', () {
    test('uses the API release url when it is a valid absolute uri', () {
      expect(
        ReleasePageLauncher.pageUri(
          'https://github.com/K3vinb5/Unyo/releases/tag/v1.2.3',
        ).toString(),
        'https://github.com/K3vinb5/Unyo/releases/tag/v1.2.3',
      );
    });

    test(
      'falls back to the generic releases page for null, empty or relative values',
      () {
        expect(
          ReleasePageLauncher.pageUri(null).toString(),
          config.unyoReleasesFallbackUrl,
        );
        expect(
          ReleasePageLauncher.pageUri('').toString(),
          config.unyoReleasesFallbackUrl,
        );
        expect(
          ReleasePageLauncher.pageUri('releases/tag/v1.2.3').toString(),
          config.unyoReleasesFallbackUrl,
        );
      },
    );
  });

  group('ReleasePageLauncher.openAsset', () {
    // No browser is touched: an unusable URL is rejected before `url_launcher`
    // is asked to open anything.
    test('refuses to open empty or malformed asset urls', () async {
      expect(await ReleasePageLauncher.openAsset(null), isFalse);
      expect(await ReleasePageLauncher.openAsset('   '), isFalse);
      expect(await ReleasePageLauncher.openAsset('Unyo-v0.9.0.AppImage'), isFalse);
    });
  });
}

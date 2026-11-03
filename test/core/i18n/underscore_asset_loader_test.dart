import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:unyo/core/i18n/underscore_asset_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const UnderscoreAssetLoader loader = UnderscoreAssetLoader();

  group('UnderscoreAssetLoader', () {
    test('builds underscore filenames, not the package default hyphen ones', () {
      expect(
        loader.getLocalePath('assets/i18n', const Locale('en', 'GB')),
        'assets/i18n/en_GB.json',
      );
      expect(
        loader.getLocalePath('assets/i18n', const Locale('es', '419')),
        'assets/i18n/es_419.json',
      );
      expect(
        loader.getLocalePath('assets/i18n', const Locale('zh', 'TW')),
        'assets/i18n/zh_TW.json',
      );
    });

    test('loads the locale file that exists', () async {
      final Map<String, dynamic>? en = await loader.load('assets/i18n', const Locale('en', 'GB'));
      expect(en, isNotNull);
      expect(en!['settings_language_title'], 'Language');

      final Map<String, dynamic>? es = await loader.load('assets/i18n', const Locale('es', 'ES'));
      expect(es, isNotNull);
      expect(es!['settings_language_title'], 'Idioma');
    });

    test('a missing locale file falls back to en_GB instead of throwing', () async {
      // es_419 is a shipped locale whose bundle lands in Wave 3. Until then —
      // and forever after, if a file is ever lost — the UI must stay up in
      // English rather than red-screening on `Unable to load asset`.
      final Map<String, dynamic>? data =
          await loader.load('assets/i18n', const Locale('es', '419'));
      expect(data, isNotNull, reason: 'missing locale must not throw');
      expect(data!['settings_language_title'], 'Language');
      expect(data['common_cancel'], 'Cancel');
    });
  });
}

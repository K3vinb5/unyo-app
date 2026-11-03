import 'dart:convert' show json;
import 'dart:ui' show Locale;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

/// `easy_localization`'s stock [RootBundleAssetLoader] joins the locale with a
/// **hyphen** (`en-GB.json`), even though `Locale.toString()` uses an
/// underscore. WP #124 names the shipped files after the persisted
/// `Settings.language` codes — `en_GB.json`, `es_419.json`, `zh_TW.json` — so
/// this subclass swaps the separator back to `_`.
///
/// It also degrades gracefully: a missing (or unparsable) locale file must not
/// brick the app. `easy_localization`'s `loadTranslations` has no recovery once
/// `loadTranslationData` throws — `_translations` stays null and every
/// `context.tr` blows up into the red ErrorWidget. Serving `en_GB.json`
/// instead keeps the UI up in English. The parity test
/// (`test/presentation/i18n/locale_parity_test.dart`) is what guarantees all 29
/// files exist at build time; this is the runtime safety net, not the check.
class UnderscoreAssetLoader extends RootBundleAssetLoader {
  const UnderscoreAssetLoader();

  static const String _fallbackPath = 'assets/i18n/en_GB.json';

  @override
  String getLocalePath(String basePath, Locale locale) =>
      '$basePath/${locale.toStringWithSeparator(separator: "_")}.json';

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final String localePath = getLocalePath(path, locale);
    try {
      final String raw = await rootBundle.loadString(localePath);
      return _decode(localePath, raw);
    } catch (e) {
      if (localePath == _fallbackPath) rethrow;
      EasyLocalization.logger.warning(
        'Missing or unreadable translation asset "$localePath" ($e); '
        'falling back to en_GB. The parity test should have caught this.',
      );
      final String raw = await rootBundle.loadString(_fallbackPath);
      return _decode(_fallbackPath, raw);
    }
  }

  Map<String, dynamic> _decode(String localePath, String raw) {
    final Object? decoded = json.decode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    throw FormatException('Translation asset "$localePath" is not a JSON object');
  }
}

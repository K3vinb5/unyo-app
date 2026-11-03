import 'dart:ui' show Locale;

import 'package:easy_localization/easy_localization.dart';

/// `easy_localization`'s stock [RootBundleAssetLoader] joins the locale with a
/// **hyphen** (`en-GB.json`), even though `Locale.toString()` uses an
/// underscore. WP #124 names the shipped files after the persisted
/// `Settings.language` codes — `en_GB.json`, `es_419.json`, `zh_TW.json` — so
/// this subclass swaps the separator back to `_`.
///
/// Nothing else changes: same `path`, same `.json` suffix, same lookup order.
class UnderscoreAssetLoader extends RootBundleAssetLoader {
  const UnderscoreAssetLoader();

  @override
  String getLocalePath(String basePath, Locale locale) =>
      '$basePath/${locale.toStringWithSeparator(separator: "_")}.json';
}

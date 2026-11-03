// External dependencies
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/i18n/app_locales.dart';

/// Serves the real `assets/i18n/<code>.json` synchronously, from disk.
///
/// The shipped [RootBundleAssetLoader] resolves through a Future that schedules
/// no frame, which makes the *second* widget test in a file flaky: the dialog is
/// never built and every finder comes back empty. Reading the same file
/// synchronously keeps the copy real and the test deterministic.
///
/// Filename convention matches `lib/core/i18n/underscore_asset_loader.dart`:
/// `en_GB.json`, not the package's default `en-GB.json`.
class FakeAssetLoader extends AssetLoader {
  const FakeAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final File file = File('assets/i18n/${locale.toStringWithSeparator(separator: "_")}.json');
    return json.decode(file.readAsStringSync()) as Map<String, dynamic>;
  }
}

/// [home] under the same localization setup the app runs with, so widgets that
/// call `context.tr` render their real copy in a widget test.
///
/// [theme] is passed straight through to the [MaterialApp] for the tests that
/// assert on colours resolved from the theme.
Widget localizedApp({required Widget home, ThemeData? theme}) => EasyLocalization(
  supportedLocales: kSupportedLocales,
  path: 'assets/i18n',
  assetLoader: const FakeAssetLoader(),
  startLocale: enGb.locale,
  fallbackLocale: enGb.locale,
  saveLocale: false,
  useOnlyLangCode: false,
  child: Builder(
    builder: (BuildContext context) => MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: theme,
      home: home,
    ),
  ),
);

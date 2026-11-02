// External dependencies
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';

/// Serves the real `assets/i18n/<lang>.json` synchronously, from disk.
///
/// The shipped [RootBundleAssetLoader] resolves through a Future that schedules
/// no frame, which makes the *second* widget test in a file flaky: the dialog is
/// never built and every finder comes back empty. Reading the same file
/// synchronously keeps the copy real and the test deterministic.
class FakeAssetLoader extends AssetLoader {
  const FakeAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final File file = File('assets/i18n/${locale.languageCode}.json');
    return json.decode(file.readAsStringSync()) as Map<String, dynamic>;
  }
}

/// [home] under the same localization setup the app runs with, so widgets that
/// call `context.tr` render their real copy in a widget test.
Widget localizedApp({required Widget home}) => EasyLocalization(
  supportedLocales: const <Locale>[Locale('en', 'GB')],
  path: 'assets/i18n',
  assetLoader: const FakeAssetLoader(),
  startLocale: const Locale('en', 'GB'),
  fallbackLocale: const Locale('en', 'GB'),
  saveLocale: false,
  useOnlyLangCode: true,
  child: Builder(
    builder: (BuildContext context) => MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: home,
    ),
  ),
);

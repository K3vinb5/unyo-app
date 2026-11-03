import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unyo/core/i18n/app_locales.dart';
import 'package:unyo/core/i18n/underscore_asset_loader.dart';

/// WP #124 regression: switching the app to a non-English locale left the tree
/// with no `MaterialLocalizations`, so every `DropdownMenu` in Settings threw
/// "No MaterialLocalizations found" and rendered as a red ErrorWidget.
/// Evidence and mechanism: `research/unyo-124-i18n-proof/DIAGNOSIS.md`.
///
/// This pumps the exact delegate list `main.dart` hands to `MaterialApp`, at
/// every shipped locale.
Widget _probeApp({required Locale locale, required Widget home}) {
  return EasyLocalization(
    // Keyed so each locale gets a fresh EasyLocalization State: without it,
    // `pumpWidget` reuses the Element and the first locale sticks.
    key: ValueKey<String>(locale.toString()),
    supportedLocales: kSupportedLocales,
    path: 'assets/i18n',
    startLocale: locale,
    fallbackLocale: enGb.locale,
    saveLocale: false,
    useOnlyLangCode: false,
    assetLoader: const UnderscoreAssetLoader(),
    child: Builder(
      builder: (BuildContext context) => MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: home,
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('MaterialLocalizations is available at every shipped locale', (WidgetTester tester) async {
    for (final AppLocale appLocale in kAppLocales) {
      late BuildContext probe;
      await tester.pumpWidget(
        _probeApp(
          locale: appLocale.locale,
          home: Builder(builder: (BuildContext c) {
            probe = c;
            return const Scaffold(body: SizedBox.shrink());
          }),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        probe.locale.toString(),
        appLocale.locale.toString(),
        reason: 'EasyLocalization should have settled on ${appLocale.code}',
      );
      final MaterialLocalizations? material = MaterialLocalizations.of(probe);
      expect(
        material,
        isNotNull,
        reason: 'MaterialLocalizations missing at ${appLocale.code} — DropdownMenu will red-screen',
      );
      expect(material!.okButtonLabel, isNotEmpty, reason: 'empty Material strings at ${appLocale.code}');
      expect(material.closeButtonTooltip, isNotEmpty);
      // `tr` and `MaterialLocalizations` must work together: the defect this
      // suite guards against was translated copy rendering while the Material
      // layer red-screened (research/unyo-124-i18n-proof/shots/04).
      expect(probe.tr('settings_language_title'), isNotEmpty);
      if (appLocale.code == 'es_ES') {
        expect(probe.tr('settings_language_title'), 'Idioma');
        expect(probe.tr('settings_language_description'), 'Selecciona el idioma de la aplicación');
      }
    }
  });
}

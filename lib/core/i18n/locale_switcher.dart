import 'package:material_ui/material_ui.dart';
import 'package:easy_localization/easy_localization.dart';

// Internal dependencies
import 'package:unyo/core/i18n/app_locales.dart';

/// Applies a persisted `Settings.language` value to the running app, with no
/// restart (WP #124 Wave 0).
///
/// [code] is the raw `Settings.language` string. `''` ([kSystemLanguage])
/// hands the locale back to the OS; anything else must be one of
/// [kAppLocales]. Unknown values fall back to `en_GB`.
///
/// Called from the presentation layer only — cubits persist the code, widgets
/// call this. See `unyo-docs/conventions/i18n.md`.
Future<void> applyUiLanguage(BuildContext context, String? code) async {
  final String normalized = normalizeLanguageCode(code ?? kSystemLanguage);
  if (normalized == kSystemLanguage) {
    await context.resetLocale();
    return;
  }
  await context.setLocale(localeForSetting(normalized));
}

/// The 29 UI locales shipped by WP #124, plus the "System default" sentinel.
///
/// [AppLocale.code] is exactly what is persisted in `Settings.language` and
/// exactly what names the asset file (`assets/i18n/<code>.json`), so
/// `es_419` is both the stored value and `assets/i18n/es_419.json`.
///
/// [AppLocale.nativeName] is the primary label in the language dropdown and
/// [AppLocale.englishName] the secondary one. Every locale except [enGb] is
/// AI-translated and carries the badge in the UI — see `unyo_language_dropdown`.
library;

import 'package:material_ui/material_ui.dart';

/// Stored in `Settings.language` to mean "follow the OS locale".
const String kSystemLanguage = '';

/// The source locale. Never badged, never AI translated.
const AppLocale enGb = AppLocale._(
  code: 'en_GB',
  locale: Locale('en', 'GB'),
  nativeName: 'English (United Kingdom)',
  englishName: 'English (United Kingdom)',
);

/// Every shipped UI locale, `en_GB` first. Order here is the dropdown order.
const List<AppLocale> kAppLocales = <AppLocale>[
  enGb,
  AppLocale._(
    code: 'es_ES',
    locale: Locale('es', 'ES'),
    nativeName: 'Español (España)',
    englishName: 'Spanish (Spain)',
  ),
  AppLocale._(
    code: 'es_419',
    locale: Locale('es', '419'),
    nativeName: 'Español (Latinoamérica)',
    englishName: 'Spanish (Latin America)',
  ),
  AppLocale._(
    code: 'pt_PT',
    locale: Locale('pt', 'PT'),
    nativeName: 'Português (Portugal)',
    englishName: 'Portuguese (Portugal)',
  ),
  AppLocale._(
    code: 'pt_BR',
    locale: Locale('pt', 'BR'),
    nativeName: 'Português (Brasil)',
    englishName: 'Portuguese (Brazil)',
  ),
  AppLocale._(
    code: 'fr_FR',
    locale: Locale('fr', 'FR'),
    nativeName: 'Français (France)',
    englishName: 'French (France)',
  ),
  AppLocale._(
    code: 'de_DE',
    locale: Locale('de', 'DE'),
    nativeName: 'Deutsch (Deutschland)',
    englishName: 'German (Germany)',
  ),
  AppLocale._(
    code: 'it_IT',
    locale: Locale('it', 'IT'),
    nativeName: 'Italiano (Italia)',
    englishName: 'Italian (Italy)',
  ),
  AppLocale._(
    code: 'ru_RU',
    locale: Locale('ru', 'RU'),
    nativeName: 'Русский (Россия)',
    englishName: 'Russian (Russia)',
  ),
  AppLocale._(
    code: 'pl_PL',
    locale: Locale('pl', 'PL'),
    nativeName: 'Polski (Polska)',
    englishName: 'Polish (Poland)',
  ),
  AppLocale._(
    code: 'tr_TR',
    locale: Locale('tr', 'TR'),
    nativeName: 'Türkçe (Türkiye)',
    englishName: 'Turkish (Turkey)',
  ),
  AppLocale._(
    code: 'id_ID',
    locale: Locale('id', 'ID'),
    nativeName: 'Bahasa Indonesia (Indonesia)',
    englishName: 'Indonesian (Indonesia)',
  ),
  AppLocale._(
    code: 'hi_IN',
    locale: Locale('hi', 'IN'),
    nativeName: 'हिन्दी (भारत)',
    englishName: 'Hindi (India)',
  ),
  AppLocale._(
    code: 'vi_VN',
    locale: Locale('vi', 'VN'),
    nativeName: 'Tiếng Việt (Việt Nam)',
    englishName: 'Vietnamese (Vietnam)',
  ),
  AppLocale._(
    code: 'th_TH',
    locale: Locale('th', 'TH'),
    nativeName: 'ไทย (ประเทศไทย)',
    englishName: 'Thai (Thailand)',
  ),
  AppLocale._(
    code: 'fil_PH',
    locale: Locale('fil', 'PH'),
    nativeName: 'Filipino (Pilipinas)',
    englishName: 'Filipino (Philippines)',
  ),
  AppLocale._(
    code: 'ms_MY',
    locale: Locale('ms', 'MY'),
    nativeName: 'Bahasa Melayu (Malaysia)',
    englishName: 'Malay (Malaysia)',
  ),
  AppLocale._(
    code: 'ko_KR',
    locale: Locale('ko', 'KR'),
    nativeName: '한국어 (대한민국)',
    englishName: 'Korean (South Korea)',
  ),
  AppLocale._(
    code: 'zh_CN',
    locale: Locale('zh', 'CN'),
    nativeName: '简体中文 (中国)',
    englishName: 'Chinese (Simplified, China)',
  ),
  AppLocale._(
    code: 'zh_TW',
    locale: Locale('zh', 'TW'),
    nativeName: '繁體中文 (台灣)',
    englishName: 'Chinese (Traditional, Taiwan)',
  ),
  AppLocale._(
    code: 'nl_NL',
    locale: Locale('nl', 'NL'),
    nativeName: 'Nederlands (Nederland)',
    englishName: 'Dutch (Netherlands)',
  ),
  AppLocale._(
    code: 'sv_SE',
    locale: Locale('sv', 'SE'),
    nativeName: 'Svenska (Sverige)',
    englishName: 'Swedish (Sweden)',
  ),
  AppLocale._(
    code: 'nb_NO',
    locale: Locale('nb', 'NO'),
    nativeName: 'Norsk bokmål (Norge)',
    englishName: 'Norwegian Bokmål (Norway)',
  ),
  AppLocale._(
    code: 'da_DK',
    locale: Locale('da', 'DK'),
    nativeName: 'Dansk (Danmark)',
    englishName: 'Danish (Denmark)',
  ),
  AppLocale._(
    code: 'fi_FI',
    locale: Locale('fi', 'FI'),
    nativeName: 'Suomi (Suomi)',
    englishName: 'Finnish (Finland)',
  ),
  AppLocale._(
    code: 'cs_CZ',
    locale: Locale('cs', 'CZ'),
    nativeName: 'Čeština (Česko)',
    englishName: 'Czech (Czechia)',
  ),
  AppLocale._(
    code: 'uk_UA',
    locale: Locale('uk', 'UA'),
    nativeName: 'Українська (Україна)',
    englishName: 'Ukrainian (Ukraine)',
  ),
  AppLocale._(
    code: 'ro_RO',
    locale: Locale('ro', 'RO'),
    nativeName: 'Română (România)',
    englishName: 'Romanian (Romania)',
  ),
  AppLocale._(
    code: 'el_GR',
    locale: Locale('el', 'GR'),
    nativeName: 'Ελληνικά (Ελλάδα)',
    englishName: 'Greek (Greece)',
  ),
];

/// `supportedLocales` for `EasyLocalization` / `MaterialApp`.
final List<Locale> kSupportedLocales =
    kAppLocales.map((AppLocale l) => l.locale).toList(growable: false);

/// Look up a persisted `Settings.language` value.
///
/// Returns null for [kSystemLanguage] ("follow the OS") and for anything not in
/// the shipped set — the caller then leaves the locale on the system value.
AppLocale? appLocaleForCode(String? code) {
  if (code == null || code == kSystemLanguage) return null;
  for (final AppLocale l in kAppLocales) {
    if (l.code == code) return l;
  }
  return null;
}

/// The locale actually rendered for a stored `Settings.language` value:
/// the matching entry, or `en_GB` when the value means "system" or is unknown.
Locale localeForSetting(String? code) =>
    appLocaleForCode(code)?.locale ?? enGb.locale;

/// `Settings.language` values written before WP #124 used the bare language
/// code `en`. Decision 3 migrates it to `en_GB`; every read path funnels
/// through here so no stale `en` escapes into the UI or `DateFormat`.
String normalizeLanguageCode(String code) => code == 'en' ? 'en_GB' : code;

/// One shipped UI locale.
class AppLocale {
  const AppLocale._({
    required this.code,
    required this.locale,
    required this.nativeName,
    required this.englishName,
  });

  /// Persisted `Settings.language` value and `assets/i18n/<code>.json` stem.
  final String code;
  final Locale locale;

  /// Primary dropdown label — always in the locale's own language.
  final String nativeName;

  /// Secondary dropdown label — always English.
  final String englishName;

  /// WP #124 decision 8: only `en_GB` is authored English; every other locale
  /// is machine translated and must carry the "AI translated" badge.
  bool get isAiTranslated => code != enGb.code;
}

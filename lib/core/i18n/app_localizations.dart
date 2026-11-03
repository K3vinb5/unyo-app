// External dependencies
import 'package:material_ui/material_ui.dart';

/// Localization wiring shared by every app-level `MaterialApp`.
///
/// This is about **two independent layers**, and confusing them is what caused
/// "No MaterialLocalizations found" at every non-English locale.
///
/// 1. **The translation engine — `easy_localization`.** It owns
///    `context.tr()`, `context.plural()`, `context.setLocale()`, the 29
///    `assets/i18n/*.json` bundles and the per-user `Settings.language`. Its
///    `Localization` delegate is in `EasyLocalization.of(context)!.delegates`.
///    This layer is *not* the problem and is not touched here.
///
/// 2. **Material's own strings** — "OK", "Cancel", "Search", the
///    `DropdownMenu` hint text, the `TabBar` semantics, the `Tooltip` labels.
///    Every one of `material_ui`'s `DropdownMenu`, `TabBar`, `SearchBar`,
///    `UserAccountsDrawerHeader` and `Tooltip` calls
///    `MaterialLocalizations.of(context)`, which is a **required** lookup: if
///    it is missing the widget throws and Flutter paints a red ErrorWidget.
///
/// Layer 2 is where it broke. `material_ui` is not a thin skin over Flutter's
/// Material — it vendors its own copy (`lib/src/material_localizations.dart`,
/// `lib/src/app.dart`) and therefore declares **its own** `MaterialLocalizations`
/// class. A Dart type is identity-based, so the `GlobalMaterialLocalizations`
/// that `easy_localization` wires in (from `flutter_localizations`) supplies
/// `flutter_localizations.MaterialLocalizations` and does **not** satisfy
/// `material_ui.MaterialLocalizations`. Only `material_ui`'s own
/// [GlobalMaterialLocalizations.delegates] does.
///
/// Without that list, `material_ui`'s `MaterialApp` falls back to its
/// `DefaultMaterialLocalizations`, which is `en`-only
/// (`isSupported => locale.languageCode == 'en'`). That is the whole signature
/// of the bug: **English is the only language that works**, everything else
/// red-screens the moment a Material widget asks for its own strings.
///
/// Order matters: `Localizations` keeps the **first** delegate per `type`, so
/// `material_ui`'s list goes first to guarantee its `MaterialLocalizations`
/// wins over the identically-named `flutter_localizations` one that
/// `easy_localization` also brings along.
///
/// A pure function of [easyLocalizationDelegates] on purpose: it can be tested
/// without pumping a second `EasyLocalization` into a test process (which
/// caches a loaded locale and silently never rebuilds a later one).
///
/// See `research/unyo-124-i18n-proof/DIAGNOSIS.md` and work package 126.
List<LocalizationsDelegate<dynamic>> appLocalizationDelegates(
  List<LocalizationsDelegate<dynamic>> easyLocalizationDelegates,
) {
  return <LocalizationsDelegate<dynamic>>[
    // material_ui's Material/Cupertino/Widgets strings. Must be first.
    ...GlobalMaterialLocalizations.delegates,
    // easy_localization's translation engine, plus the flutter_localizations
    // delegates it bundles. Harmless duplicates: same Dart types, and the
    // first (material_ui) wins.
    ...easyLocalizationDelegates,
  ];
}

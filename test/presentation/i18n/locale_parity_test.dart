// Locale parity gate for WP #124.
//
// `assets/i18n/` ships one file per `kAppLocales` entry, and `en_GB.json` is the
// authored source of truth. A missing file, a drifted key set, a lost
// `{placeholder}` or a translated brand name all show up at runtime as a raw
// key name or a red ErrorWidget — never as a compile error. This test is the
// build-time guarantee that the 28 AI translations stay structurally identical
// to the English master.
//
// Reads the files straight off disk with `dart:io` (same style as
// `raw_string_guard_test.dart`) — no widget pumping, no asset bundle needed.
//
// The locale list is never hardcoded here: it comes from `kAppLocales`, so
// adding a locale to the registry without a file (or the reverse) fails this
// test instead of sneaking into a release.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:unyo/core/i18n/app_locales.dart';

/// Directory holding `assets/i18n/<code>.json`, keyed by `AppLocale.code`.
const String _i18nDir = 'assets/i18n';

/// The authored master locale. Every other locale is checked against it.
const String _sourceCode = 'en_GB';

/// Brand names that the i18n convention says are never translated
/// (`unyo-docs/conventions/i18n.md`). They must appear verbatim in every
/// translation of a key that mentions them.
const List<String> _brandNames = <String>[
  'Unyo',
  'AniList',
  'MyAnimeList',
  'Shikimori',
  'GitHub',
  'OpenSubtitles.org',
  'Aniyomi',
  'Tachiyomi',
];

/// Accepted non-Latin renderings of a brand, per locale code, for languages
/// that genuinely write the name in their own script.
///
/// Listed explicitly rather than loosening the check: a locale that is not
/// listed here must keep the Latin spelling (or a translation-containing
/// variant added below after review). Deliberately empty — no shipped locale
/// transliterates a brand today, so nothing is grandfathered in. Add rows only
/// with the exact string the locale uses, e.g.
///
///     'zh_CN': <String>['优尼欧'],
const Map<String, List<String>> _brandVariants = <String, List<String>>{};

final RegExp _placeholder = RegExp(r'\{(\w+)\}');

void main() {
  group('locale parity', () {
    final Map<String, dynamic> source = _load(_sourceCode);
    final List<String> sourceKeys = source.keys.toList();

    test('every locale in kAppLocales has an asset file', () {
      final List<String> missing = <String>[];
      for (final AppLocale locale in kAppLocales) {
        final File file = File('$_i18nDir/${locale.code}.json');
        if (!file.existsSync()) missing.add('${locale.code}.json');
      }
      expect(
        missing,
        isEmpty,
        reason:
            'kAppLocales declares locales with no `$_i18nDir/` file. The app '
            'would red-screen or silently fall back to en_GB for: '
            '${missing.join(', ')}',
      );
    });

    test('every locale has exactly the en_GB key set', () {
      final List<String> problems = <String>[];
      for (final AppLocale locale in kAppLocales) {
        if (locale.code == _sourceCode) continue;
        final Set<String> keys = _load(locale.code).keys.toSet();
        final List<String> missing =
            sourceKeys.where((String k) => !keys.contains(k)).toList()..sort();
        final List<String> extra = keys
            .where((String k) => !source.containsKey(k))
            .toList()
          ..sort();
        if (missing.isEmpty && extra.isEmpty) continue;
        problems.add(
          '${locale.code}.json\n'
          '  missing (${missing.length}): ${missing.join(', ')}\n'
          '  extra (${extra.length}): ${extra.join(', ')}',
        );
      }
      expect(
        problems,
        isEmpty,
        reason:
            'Key drift versus $_sourceCode.json. A missing key renders as the '
            'raw key name at runtime; an extra key is dead weight.\n\n'
            '${problems.join('\n\n')}',
      );
    });

    test('every locale preserves the en_GB {placeholders}', () {
      final List<String> problems = <String>[];
      for (final AppLocale locale in kAppLocales) {
        if (locale.code == _sourceCode) continue;
        final Map<String, dynamic> translation = _load(locale.code);
        for (final String key in sourceKeys) {
          final Object? value = translation[key];
          if (value is! String) continue; // reported by the type/empty tests
          final Set<String> expected =
              _placeholder.allMatches(source[key] as String).map((RegExpMatch m) => m.group(1)!).toSet();
          final Set<String> actual =
              _placeholder.allMatches(value).map((RegExpMatch m) => m.group(1)!).toSet();
          if (expected.length == actual.length && expected.containsAll(actual)) continue;
          problems.add(
            '${locale.code} $key: expected {${expected.join(', ')}}, '
            'got {${actual.join(', ')}}',
          );
        }
      }
      expect(
        problems,
        isEmpty,
        reason:
            'Placeholder drift. A dropped or renamed {name} throws at runtime '
            'when the message is formatted.\n\n${problems.take(50).join('\n')}',
      );
    });

    test('no locale has an empty or whitespace-only value', () {
      final List<String> problems = <String>[];
      for (final AppLocale locale in kAppLocales) {
        final Map<String, dynamic> translation = _load(locale.code);
        for (final MapEntry<String, dynamic> e in translation.entries) {
          final Object? value = e.value;
          if (value is! String) {
            problems.add('${locale.code} ${e.key}: not a string ($value)');
            continue;
          }
          if (value.trim().isEmpty) problems.add('${locale.code} ${e.key}: ""');
        }
      }
      expect(
        problems,
        isEmpty,
        reason: 'Empty translation values render as blank UI.\n\n'
            '${problems.take(50).join('\n')}',
      );
    });

    test('brand names survive translation', () {
      final List<String> problems = <String>[];
      for (final AppLocale locale in kAppLocales) {
        if (locale.code == _sourceCode) continue;
        final Map<String, dynamic> translation = _load(locale.code);
        final List<String> variants = _brandVariants[locale.code] ?? const <String>[];
        for (final String brand in _brandNames) {
          for (final String key in sourceKeys) {
            final Object? sourceValue = source[key];
            final Object? value = translation[key];
            if (sourceValue is! String || value is! String) continue;
            if (!sourceValue.contains(brand)) continue;
            if (value.contains(brand)) continue;
            if (variants.any((String v) => value.contains(v))) continue;
            problems.add('${locale.code} $key: "$brand" lost — got "$value"');
          }
        }
      }
      expect(
        problems,
        isEmpty,
        reason:
            'Brand names must not be translated. If a locale legitimately '
            'writes one in its own script, add the exact accepted spelling to '
            '_brandVariants at the top of this file.\n\n'
            '${problems.take(50).join('\n')}',
      );
    });

    test('registry and assets/i18n agree in both directions', () {
      final Set<String> declared =
          kAppLocales.map((AppLocale l) => l.code).toSet();
      final List<String> undeclared = Directory(_i18nDir)
          .listSync()
          .whereType<File>()
          .map((File f) => f.uri.pathSegments.last)
          .where((String name) => name.endsWith('.json'))
          .map((String name) => name.substring(0, name.length - '.json'.length))
          .where((String stem) => !declared.contains(stem))
          .toList()
        ..sort();
      final List<String> unbacked = declared
          .where((String code) => !File('$_i18nDir/$code.json').existsSync())
          .toList()
        ..sort();

      expect(
        undeclared,
        isEmpty,
        reason: 'Translation files with no kAppLocales entry are dead weight: '
            '${undeclared.join(', ')}',
      );
      expect(
        unbacked,
        isEmpty,
        reason: 'kAppLocales entries with no translation file would red-screen: '
            '${unbacked.join(', ')}',
      );
      expect(
        declared.length,
        kAppLocales.length,
        reason: 'kAppLocales contains duplicate codes',
      );
    });

    test('plural pairs (.one / .other) are complete in every locale', () {
      final List<String> problems = <String>[];
      for (final AppLocale locale in kAppLocales) {
        final Set<String> keys = _load(locale.code).keys.toSet();
        for (final String key in keys) {
          if (key.endsWith('.one')) {
            final String other = '${key.substring(0, key.length - '.one'.length)}.other';
            if (!keys.contains(other)) {
              problems.add('${locale.code}: "$key" has no "$other"');
            }
          } else if (key.endsWith('.other')) {
            final String one = '${key.substring(0, key.length - '.other'.length)}.one';
            if (!keys.contains(one)) {
              problems.add('${locale.code}: "$key" has no "$one"');
            }
          }
        }
      }
      expect(
        problems,
        isEmpty,
        reason:
            'easy_localization plural lookups need both forms. A missing half '
            'renders the raw key.\n\n${problems.join('\n')}',
      );
    });
  });

  test('en_GB.json is well formed', () {
    final File file = File('$_i18nDir/$_sourceCode.json');
    expect(file.existsSync(), isTrue, reason: 'master locale file is missing');

    // Valid UTF-8 (throws on malformed bytes).
    final String raw = utf8.decode(file.readAsBytesSync());
    expect(raw.endsWith('\n'), isTrue, reason: 'master must end with a newline');
    expect(raw.contains('\r'), isFalse, reason: 'master must use LF newlines');

    final Object? decoded = json.decode(raw);
    expect(decoded, isA<Map<String, dynamic>>(),
        reason: 'master must be a JSON object');
    final Map<String, dynamic> master = decoded! as Map<String, dynamic>;
    expect(master, isNotEmpty);

    for (final MapEntry<String, dynamic> e in master.entries) {
      expect(e.key.trim(), e.key, reason: 'padded key "${e.key}"');
      expect(e.value, isA<String>(), reason: '"${e.key}" must be a string');
    }

    final List<String> keys = master.keys.toList();
    expect(
      keys,
      equals(List<String>.of(keys)..sort()),
      reason: 'master keys must be sorted so diffs stay reviewable',
    );

    // 2-space indent, no duplicate keys, stable key order: re-encoding must
    // reproduce the file byte for byte (the decoded map drops duplicate keys).
    final String reencoded =
        '${const JsonEncoder.withIndent('  ').convert(master)}\n';
    expect(
      reencoded,
      raw,
      reason: 'master must be exactly 2-space-indented JSON with no duplicate '
          'keys (re-encoded form differs)',
    );
  });
}

Map<String, dynamic> _load(String code) {
  final File file = File('$_i18nDir/$code.json');
  if (!file.existsSync()) {
    fail('missing translation asset: ${file.path}');
  }
  final Object? decoded = json.decode(utf8.decode(file.readAsBytesSync()));
  if (decoded is! Map<String, dynamic>) {
    fail('${file.path} is not a JSON object');
  }
  return decoded;
}

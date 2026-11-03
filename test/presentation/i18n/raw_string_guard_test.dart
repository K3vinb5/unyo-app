// Raw-string ratchet for WP #124.
//
// The i18n extraction (Waves 1-2) moves user-facing literals in
// `lib/presentation` behind `context.tr`. Zero-tolerance would be unusable on a
// codebase that starts with ~200 offenders, so this guard is a *ratchet*:
//
//   * every offender found today is recorded in `raw_string_baseline.json`;
//   * a literal that is NOT in the baseline fails the build (a regression);
//   * a baseline row that no longer matches also fails the build (so the
//     baseline can only shrink, and only deliberately).
//
// Regenerate the baseline with:
//     UPDATE_I18N_BASELINE=1 flutter test test/presentation/i18n/raw_string_guard_test.dart
// then review the diff. Never let the baseline grow without reading every
// added row.
//
// What counts as an offender is documented in
// `unyo-docs/conventions/i18n.md` ("Raw-string guard"). The detector is
// deliberately simple and slightly over-inclusive: false positives live in the
// baseline and disappear as the file gets touched.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String _presentationRoot = 'lib/presentation';
const String _baselinePath = 'test/presentation/i18n/raw_string_baseline.json';

/// Relative POSIX path -> set of literal keys recorded for it.
typedef _Snapshot = Map<String, Set<String>>;

void main() {
  group('raw-string ratchet', () {
    test('no new user-facing literals in lib/presentation', () {
      final _Snapshot current = _scanPresentation();

      if (Platform.environment.containsKey('UPDATE_I18N_BASELINE')) {
        _writeBaseline(current);
        // ignore: avoid_print
        print('baseline rewritten: ${_rows(current)} rows');
        return;
      }

      final _Snapshot baseline = _loadBaseline();
      final List<String> added = _diff(current, baseline);
      final List<String> removed = _diff(baseline, current);

      expect(
        added,
        isEmpty,
        reason:
            'New user-facing string literals in lib/presentation. Extract them '
            'with context.tr (see unyo-docs/conventions/i18n.md) instead of '
            'adding them to the baseline.\n\n${added.join('\n')}',
      );
      expect(
        removed,
        isEmpty,
        reason:
            'raw_string_baseline.json is stale: these rows no longer match. '
            'That is good news — regenerate the baseline with '
            'UPDATE_I18N_BASELINE=1 and commit the shrink.\n\n'
            '${removed.join('\n')}',
      );
    });

    test('baseline is sorted and well formed', () {
      final File file = File(_baselinePath);
      expect(file.existsSync(), isTrue, reason: '$_baselinePath is missing');
      final List<dynamic> rows = json.decode(file.readAsStringSync()) as List<dynamic>;
      final List<String> keys = rows
          .map((dynamic r) => _key((r as Map<String, dynamic>)['file']! as String, r['text']! as String))
          .toList();
      expect(
        keys,
        equals(List<String>.of(keys)..sort()),
        reason: 'baseline rows must be sorted so diffs stay reviewable',
      );
      expect(keys.toSet().length, keys.length, reason: 'duplicate baseline rows');
    });
  });
}

String _key(String file, String text) => '$file\t$text';

int _rows(_Snapshot s) => s.values.fold<int>(0, (int a, Set<String> b) => a + b.length);

_Snapshot _loadBaseline() {
  final File file = File(_baselinePath);
  if (!file.existsSync()) return <String, Set<String>>{};
  final List<dynamic> rows = json.decode(file.readAsStringSync()) as List<dynamic>;
  final _Snapshot out = <String, Set<String>>{};
  for (final dynamic row in rows) {
    final Map<String, dynamic> r = row as Map<String, dynamic>;
    out.putIfAbsent(r['file']! as String, () => <String>{}).add(r['text']! as String);
  }
  return out;
}

void _writeBaseline(_Snapshot snapshot) {
  final List<Map<String, String>> rows = <Map<String, String>>[];
  for (final MapEntry<String, Set<String>> e in snapshot.entries) {
    for (final String text in e.value) {
      rows.add(<String, String>{'file': e.key, 'text': text});
    }
  }
  rows.sort((Map<String, String> a, Map<String, String> b) =>
      _key(a['file']!, a['text']!).compareTo(_key(b['file']!, b['text']!)));
  File(_baselinePath).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(rows)}\n');
}

List<String> _diff(_Snapshot a, _Snapshot b) {
  final List<String> out = <String>[];
  for (final MapEntry<String, Set<String>> e in a.entries) {
    for (final String text in e.value) {
      if (!(b[e.key]?.contains(text) ?? false)) out.add(_key(e.key, text));
    }
  }
  out.sort();
  return out;
}

// ---------------------------------------------------------------------------
// Detector
// ---------------------------------------------------------------------------

_Snapshot _scanPresentation() {
  final _Snapshot out = <String, Set<String>>{};
  final Directory root = Directory(_presentationRoot);
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.dart')) continue;
    if (entity.path.endsWith('.g.dart') || entity.path.endsWith('.freezed.dart')) continue;
    final String rel = entity.path.replaceAll('\\', '/');
    final String source = _stripComments(entity.readAsStringSync());
    for (final String literal in _candidateLiterals(source)) {
      out.putIfAbsent(rel, () => <String>{}).add(literal);
    }
  }
  return out;
}

/// Removes `//` line comments and `/* */` block comments, preserving string
/// literals and line structure. Not a parser — good enough for a lint guard.
String _stripComments(String source) {
  final StringBuffer out = StringBuffer();
  int i = 0;
  final int n = source.length;
  while (i < n) {
    final String c = source[i];
    if (c == "'" || c == '"') {
      final int start = i;
      i = _skipString(source, i);
      out.write(source.substring(start, i));
      continue;
    }
    if (c == '/' && i + 1 < n && source[i + 1] == '/') {
      while (i < n && source[i] != '\n') {
        i++;
      }
      continue;
    }
    if (c == '/' && i + 1 < n && source[i + 1] == '*') {
      i += 2;
      while (i + 1 < n && !(source[i] == '*' && source[i + 1] == '/')) {
        if (source[i] == '\n') out.write('\n');
        i++;
      }
      i = (i + 2).clamp(0, n);
      continue;
    }
    out.write(c);
    i++;
  }
  return out.toString();
}

/// Index just past the string literal starting at [start].
///
/// Handles `'...'`, `"..."`, `'''...'''`, `"""..."""` and, crucially, `${...}`
/// interpolation regions (which may contain nested strings and nested braces).
int _skipString(String source, int start) {
  final int n = source.length;
  final String quote = source[start];
  final bool triple = start + 2 < n && source[start + 1] == quote && source[start + 2] == quote;
  int i = triple ? start + 3 : start + 1;
  while (i < n) {
    final String c = source[i];
    if (c == r'\') {
      i += 2;
      continue;
    }
    if (c == r'$' && i + 1 < n && source[i + 1] == '{') {
      i = _skipInterpolation(source, i + 1);
      continue;
    }
    if (triple) {
      if (i + 2 < n && source[i] == quote && source[i + 1] == quote && source[i + 2] == quote) {
        return i + 3;
      }
    } else if (c == quote) {
      return i + 1;
    }
    if (!triple && c == '\n') return i;
    i++;
  }
  return n;
}

/// Index just past the `{...}` interpolation region starting at [openBrace].
int _skipInterpolation(String source, int openBrace) {
  final int n = source.length;
  int depth = 0;
  int i = openBrace;
  while (i < n) {
    final String c = source[i];
    if (c == "'" || c == '"') {
      i = _skipString(source, i);
      continue;
    }
    if (c == '{') {
      depth++;
    } else if (c == '}') {
      depth--;
      if (depth == 0) return i + 1;
    }
    i++;
  }
  return n;
}

final RegExp _trCall = RegExp(r"""(?:tr|plural|trGender)\(\s*$""");
final RegExp _localeCall = RegExp(r"""Locale(?:\.fromSubtags)?\(\s*$""");
final RegExp _uriPrefix = RegExp(r"""(?:import|export|part(?: of)?)\s*$""");

List<String> _candidateLiterals(String source) {
  final List<String> found = <String>[];
  final int n = source.length;
  int i = 0;
  while (i < n) {
    final String c = source[i];
    if (c != "'" && c != '"') {
      i++;
      continue;
    }
    // Raw strings: r'...' / r"..." — regexes, paths, not UI copy.
    if (i > 0 && source[i - 1] == 'r') {
      i = _skipString(source, i);
      continue;
    }
    final int start = i;
    final int end = _skipString(source, i);
    i = end;
    final _Literal lit = _parseLiteral(source.substring(start, end));
    if (lit == _Literal.none) continue;
    if (!_looksUserFacing(lit.staticText)) continue;

    final String before = source.substring(0, start);
    final String tail = before.length < 80 ? before : before.substring(before.length - 80);
    if (_trCall.hasMatch(tail)) continue;
    if (_localeCall.hasMatch(tail)) continue;
    if (_uriPrefix.hasMatch(tail)) continue;
    found.add(lit.key);
  }
  return found;
}

class _Literal {
  const _Literal(this.key, this.staticText);
  static const _Literal none = _Literal('', '');

  /// Stable identity for the baseline: the literal's text with every `${...}`
  /// region collapsed to `${}`, so refactoring an interpolation does not churn
  /// the baseline.
  final String key;

  /// The literal's text with every `${...}` region removed — the only part that
  /// is actually hardcoded copy.
  final String staticText;
}

_Literal _parseLiteral(String raw) {
  if (raw.length < 2) return _Literal.none;
  final String quote = raw[0];
  final bool triple = raw.length >= 6 && raw[1] == quote && raw[2] == quote;
  final String body = triple ? raw.substring(3, raw.length - 3) : raw.substring(1, raw.length - 1);
  if (body.isEmpty) return _Literal.none;
  if (body.contains('\n')) return _Literal.none;

  final StringBuffer key = StringBuffer();
  final StringBuffer staticText = StringBuffer();
  int i = 0;
  while (i < body.length) {
    final String c = body[i];
    if (c == r'\' && i + 1 < body.length) {
      final String next = body[i + 1];
      final String decoded = switch (next) {
        'n' || 't' => ' ',
        r'\' => r'\',
        "'" => "'",
        '"' => '"',
        r'$' => r'$',
        _ => next,
      };
      key.write(decoded);
      staticText.write(decoded);
      i += 2;
      continue;
    }
    if (c == r'$' && i + 1 < body.length && body[i + 1] == '{') {
      int depth = 0;
      int j = i + 1;
      while (j < body.length) {
        if (body[j] == '{') {
          depth++;
        } else if (body[j] == '}') {
          depth--;
          if (depth == 0) {
            j++;
            break;
          }
        }
        j++;
      }
      key.write(r'${}');
      i = j;
      continue;
    }
    key.write(c);
    staticText.write(c);
    i++;
  }
  return _Literal(key.toString(), staticText.toString());
}

/// The single place the "is this user-facing?" policy lives. Documented in
/// `unyo-docs/conventions/i18n.md`.
bool _looksUserFacing(String text) {
  if (text.length < 2) return false;
  final bool hasLetter = RegExp(r'[A-Za-z\u00C0-\u024F\u0370-\u1FFF\u3040-\u9FFF]').hasMatch(text);
  if (!hasLetter) return false;
  // Hostnames, paths and bare identifiers: no spaces, all lowercase-ish.
  if (!text.contains(' ') && RegExp(r'^[a-z0-9._:/\-]+$').hasMatch(text)) return false;
  final bool sentenceLike = text.contains(' ') ||
      RegExp(r'^[A-Z]').hasMatch(text) ||
      text.contains(RegExp(r'[!?.:%]'));
  return sentenceLike;
}

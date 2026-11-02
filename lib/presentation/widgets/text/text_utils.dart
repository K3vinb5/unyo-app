
class TextUtils {
  /// Provider descriptions arrive in three markup dialects and this is the one
  /// place that turns them into display-ready prose:
  ///
  /// - HTML (`<br>`, `<i>`, entities) — AniList characters, some sources;
  /// - Markdown (`**bold**`, `[text](url)`, `![img](url)`, headings, lists) —
  ///   AniList media descriptions;
  /// - BBCode-ish Shikimori markup (`[b]`, `[spoiler]`, `[url=…]`, `[[Name]]`,
  ///   `[character:1]`).
  ///
  /// Shared by both details screens, the banner carousel and the character
  /// dialog, so no surface renders raw markers. Malformed input never throws:
  /// unmatched markers are dropped as far as they can be recognised and the
  /// rest of the text (punctuation, newlines, Cyrillic/Japanese) is preserved.
  ///
  /// The name is historical — it handled only HTML before WP #105.
  static String parseHtmlToPlainText(String input) {
    if (input.isEmpty) {
      return '';
    }
    String text = input;

    // --- HTML -----------------------------------------------------------------
    // Block-level tags become line breaks so paragraphs do not run together.
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<p[^>]*>', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
    text = text.replaceAll(RegExp(r'<div[^>]*>', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'</div>', caseSensitive: false), '\n');
    // Inline formatting tags are simply dropped, keeping their contents.
    text = text.replaceAll(RegExp(r'<b>|</b>|<strong>|</strong>', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'<i>|</i>|<em>|</em>', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'<u>|</u>', caseSensitive: false), '');
    // Any other HTML tag (links, lists, stray autolinks).
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    // Decode HTML entities, named and numeric.
    text = _decodeHtmlEntities(text);

    // --- Markdown media -------------------------------------------------------
    // Images: keep the alt text when the provider supplied one.
    text = text.replaceAllMapped(
      RegExp(r'!\[([^\]\n]*)\]\([^)\n]*\)'),
      (Match match) => match[1] ?? '',
    );
    // Inline links: keep the label, drop the target.
    text = text.replaceAllMapped(
      RegExp(r'\[([^\]\n]+)\]\(\s*[^)\s]*(?:\s+"[^"\n]*")?\s*\)'),
      (Match match) => match[1] ?? '',
    );
    // Reference-style link definitions (the link itself is unwrapped below,
    // after BBCode tags, so `[center][b]` is not mistaken for `[text][ref]`).
    text = text.replaceAll(RegExp(r'^[ \t]*\[[^\]\n]+\]:[ \t]*\S+.*$', multiLine: true), '');

    // --- BBCode-ish (Shikimori) -----------------------------------------------
    // `[img]…[/img]` is an image marker, not prose.
    text = text.replaceAll(
      RegExp(r'\[img[^\]\n]*\].*?\[/img\]', caseSensitive: false, dotAll: true),
      '',
    );
    // `[url=…]label[/url]` / `[url]label[/url]` become the label.
    text = text.replaceAllMapped(
      RegExp(r'\[url(?:=[^\]\n]*)?\](.*?)\[/url\]', caseSensitive: false, dotAll: true),
      (Match match) => match[1] ?? '',
    );
    // Linked entity names are wrapped in a second bracket pair: `[[Shinigami]]`.
    text = text.replaceAllMapped(
      RegExp(r'\[\[([^\[\]\n]+)\]\]'),
      (Match match) => match[1] ?? '',
    );
    // Shikimori annotates names with their Japanese reading in bare brackets
    // (`Рюк [リューク]`): a reading, not prose, so it is dropped.
    text = text.replaceAll(
      RegExp(r'\[[ \t\u3000]*[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff\u3005\u30fc・]+[ \t\u3000]*\]'),
      '',
    );
    // Provider entity references carry no prose of their own: `[character:1]`.
    text = text.replaceAll(
      RegExp(
        r'\[\s*(?:character|char|person|staff|anime|manga|user|entry|comment)\s*:\s*-?\d+\s*\]',
        caseSensitive: false,
      ),
      '',
    );
    // Trailing credit notes such as `[Written by MAL Rewrite]`.
    text = text.replaceAll(
      RegExp(
        r'\[\s*(?:written|source|scanned|scanlated|translated|licensed|published)\b[^\]\n]*\]',
        caseSensitive: false,
      ),
      '',
    );
    // Shikimori writes explicit line breaks as `[br]`, which would otherwise
    // render literally (the base helper only knew the HTML `<br>`).
    text = text.replaceAll(RegExp(r'\[br\s*/?\]', caseSensitive: false), '\n');
    // Rule tags.
    text = text.replaceAll(RegExp(r'\[hr\s*/?\]', caseSensitive: false), '\n');
    // BBCode list items become their own bulleted lines.
    text = text.replaceAll(RegExp(r'\[\*\]'), '\n• ');
    // Remaining BBCode tags (opening, closing, or with an attribute).
    text = text.replaceAll(
      RegExp(
        r'\[/?(?:b|i|u|s|spoiler|quote|center|left|right|color|size|font|list|code|url|img|character|person|anime|manga|staff|user|entry|comment|table|tr|td)(?:=[^\]\n]*)?\]',
        caseSensitive: false,
      ),
      '',
    );
    // An unmatched opening tag left at the end of a line (`[url=x`).
    text = text.replaceAll(
      RegExp(
        r'\[/?[a-zA-Z][a-zA-Z0-9]*(?:=[^\]\n]*)?$',
        caseSensitive: false,
        multiLine: true,
      ),
      '',
    );
    // Empty bracket pairs left behind by the passes above.
    text = text.replaceAll(RegExp(r'\[\s*\]'), '');

    // --- Leftover bracket debris ---------------------------------------------
    // Bracket pairs with no words in them (`[/]`, `[**]`, `[::]`) are markup,
    // never prose, and runs of brackets are leftovers of malformed input.
    text = text.replaceAll(RegExp(r'\[\s*[^\w\s]{0,5}\s*\]'), '');
    text = text.replaceAll(RegExp(r'\[{2,}'), '');

    // --- Markdown reference links --------------------------------------------
    // `[label][ref]` keeps the label; the definition line went above.
    text = text.replaceAllMapped(
      RegExp(r'\[([^\]\n]+)\]\[[^\]\n]*\]'),
      (Match match) => match[1] ?? '',
    );

    // --- Markdown block structure --------------------------------------------
    // Headings: drop the `#` markers, keep the text.
    text = text.replaceAll(RegExp(r'^[ \t]{0,3}#{1,6}[ \t]*', multiLine: true), '');
    // Block quotes.
    text = text.replaceAll(RegExp(r'^[ \t]*>[ \t]?', multiLine: true), '');
    // Unordered list bullets become a real bullet character.
    text = text.replaceAll(RegExp(r'^[ \t]*[-*+][ \t]+', multiLine: true), '• ');
    // Trailing heading closers (`## Title ##`).
    text = text.replaceAll(RegExp(r'[ \t]+#+[ \t]*$', multiLine: true), '');

    // --- Markdown emphasis ----------------------------------------------------
    // Triple, then double, then single markers — unwrap, never keep the marker.
    text = text.replaceAllMapped(RegExp(r'\*\*\*([^*\n]+)\*\*\*'), (Match match) => match[1] ?? '');
    text = text.replaceAllMapped(RegExp(r'\*\*([^*\n]+)\*\*'), (Match match) => match[1] ?? '');
    text = text.replaceAllMapped(
      RegExp(r'(?<![\w])__([^_\n]+)__(?![\w])'),
      (Match match) => match[1] ?? '',
    );
    text = text.replaceAllMapped(
      RegExp(r'(?<![\w])_([^_\n]+)_(?![\w])'),
      (Match match) => match[1] ?? '',
    );
    text = text.replaceAllMapped(RegExp(r'\*([^*\n]+)\*'), (Match match) => match[1] ?? '');
    text = text.replaceAllMapped(RegExp(r'~~([^~\n]+)~~'), (Match match) => match[1] ?? '');
    text = text.replaceAllMapped(RegExp(r'`{1,3}([^`\n]+)`{1,3}'), (Match match) => match[1] ?? '');
    // Unbalanced emphasis markers are left over by malformed input.
    text = text.replaceAll(RegExp(r'\*{2,}'), '');
    text = text.replaceAll('~~', '');

    // --- Whitespace -----------------------------------------------------------
    text = text.replaceAll('\r\n', '\n');
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    text = text.replaceAll(RegExp(r' *\n *'), '\n');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text.trim();
  }

  static const Map<String, String> _htmlEntities = <String, String>{
    'nbsp': ' ',
    'amp': '&',
    'lt': '<',
    'gt': '>',
    'quot': '"',
    'apos': "'",
    'mdash': '—',
    'ndash': '–',
    'hellip': '…',
    'laquo': '«',
    'raquo': '»',
    'rsquo': '’',
    'lsquo': '‘',
    'ldquo': '“',
    'rdquo': '”',
  };

  static String _decodeHtmlEntities(String text) {
    String decoded = text;
    _htmlEntities.forEach((String name, String value) {
      decoded = decoded.replaceAll(RegExp('&$name;', caseSensitive: false), value);
    });
    decoded = decoded.replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (Match match) => String.fromCharCode(int.parse(match[1]!)),
    );
    decoded = decoded.replaceAllMapped(
      RegExp(r'&#x([0-9a-fA-F]+);'),
      (Match match) => String.fromCharCode(int.parse(match[1]!, radix: 16)),
    );
    return decoded;
  }

  /// Year out of a provider `startDate` string (`d/m/yyyy`). Every provider we
  /// render stores the year in that slot; anything else degrades to an empty
  /// string instead of throwing.
  static String extractYearFromStartDate(String startDate) {
    final List<String> parts = startDate.split("/");
    final int? year = parts.length < 3 ? null : int.tryParse(parts[2]);
    return year == null ? "" : "$year";
  }

  static List<String> formatISO8601DateTime(String isoDateTime) {
    if (isoDateTime.isEmpty) {
      return ["~", "~", "~"];
    }
    final dateTime = DateTime.parse(isoDateTime);
    return [
      "${dateTime.day != 0 ? dateTime.day : "~"}",
      "${dateTime.month != 0 ? dateTime.month : "~"}",
      "${dateTime.year != 0 ? dateTime.year : "~"}",
    ];
  }

  static String formatMilliseconds(int milliseconds) {
    final totalSeconds = milliseconds ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static List<String> capitalizeList(List<String> list) {
    return list.map(capitalize).toList();
  }

  static String extractRepoName(String repoUrl) {
    try {
      final uri = Uri.parse(repoUrl);
      final hostname = uri.host.toLowerCase();

      final paths = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (hostname == 'raw.githubusercontent.com' || hostname == 'gist.githubusercontent.com') {
        return paths.isNotEmpty ? capitalize(paths.first) : 'GitHub Repo';
      }

      if (hostname.contains('github.io') || hostname.contains('gitlab.io')) {
        final username = hostname.split('.').first;
        return capitalize(username.replaceAll('-', ' '));
      }

      final domainParts = hostname.replaceFirst('www.', '').split('.');
      if (domainParts.length >= 2) {
        final mainDomain = domainParts[domainParts.length - 2];
        return capitalize(mainDomain);
      }
      return 'Custom Repo';
    } catch (e) {
      // Fallback if the URL is completely malformed or unparseable
      return 'Unknown Repo';
    }
  }

  static String capitalize(String str) {
    return str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : str;
  }
}

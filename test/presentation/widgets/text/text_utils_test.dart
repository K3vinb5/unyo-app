// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/presentation/widgets/text/text_utils.dart';

/// Table-driven coverage of the one helper every description surface renders
/// through (both details screens, the banner carousel, the character dialog).
///
/// Each case is a string the providers actually ship — AniList Markdown,
/// Shikimori BBCode, the `[[Name]] [character:1]` pairing, plain prose in
/// Cyrillic/Japanese, and malformed markup — so a regression in any dialect
/// fails here rather than in a screenshot review.
void main() {
  group('parseHtmlToPlainText — provider markup', () {
    final List<(String name, String input, String expected)> cases =
        <(String, String, String)>[
      // --- HTML (pre-WP #105 behaviour, kept as regression) -------------------
      (
        'HTML inline tags are dropped, <br> becomes a newline',
        '<i>Black Swordsman</i><br>Always <b>solo</b>.',
        'Black Swordsman\nAlways solo.',
      ),
      (
        'HTML paragraphs and entities',
        '<p>Tom &amp; Jerry&nbsp;&mdash; friends</p>',
        'Tom & Jerry — friends',
      ),
      (
        'numeric HTML entities',
        'Caf&#233; &#x2665;',
        'Café ♥',
      ),
      // --- AniList Markdown ---------------------------------------------------
      (
        'bold labels with <br> separated lines',
        '**Occupation**: Middle School Student<br>**Grade**: 3rd year',
        'Occupation: Middle School Student\nGrade: 3rd year',
      ),
      (
        'bold labels around a Japanese title',
        '**Japanese**: デスノート<br>**Romaji**: Death Note',
        'Japanese: デスノート\nRomaji: Death Note',
      ),
      (
        'inline link keeps its label and drops the target',
        'See the [official site](https://deathnote.jp) for more.',
        'See the official site for more.',
      ),
      (
        'image markers collapse to their alt text',
        '![cover](https://img.example/cover.png)**Death Note**',
        'coverDeath Note',
      ),
      (
        'reference link and its definition',
        'Read [the manga][mal].\n[mal]: https://myanimelist.net/manga/21',
        'Read the manga.',
      ),
      (
        'headings and unordered list bullets',
        '# Death Note\n- Light Yagami\n- L Lawliet',
        'Death Note\n• Light Yagami\n• L Lawliet',
      ),
      (
        'ordered lists and block quotes keep their prose',
        '> quoted line\n1. first\n2. second',
        'quoted line\n1. first\n2. second',
      ),
      (
        'emphasis, strike and inline code are unwrapped',
        '~~old~~ *new* __bold__ _italic_ `code`',
        'old new bold italic code',
      ),
      (
        'the MAL credit footer is dropped',
        'A shinigami story. [Written by MAL Rewrite]',
        'A shinigami story.',
      ),
      // --- Shikimori BBCode ---------------------------------------------------
      (
        'double-bracket entity link and a character marker',
        '[[Shinigami]] Рюк [character:1]',
        'Shinigami Рюк',
      ),
      (
        'BBCode formatting, spoiler, url and image tags',
        '[b]Описание[/b] [spoiler]Спойлер[/spoiler] '
            '[url=https://shikimori.one]сайт[/url] [img]https://i.example/a.png[/img]',
        'Описание Спойлер сайт',
      ),
      (
        'Shikimori Death Note description keeps prose and drops markers',
        'Изнывающий от скуки [[Синигами]] Рюк [リューク] бросает тетрадь.[br][br]'
            'За поимку Киры [character=71]L[/character] берётся детектив.',
        'Изнывающий от скуки Синигами Рюк бросает тетрадь.\n\n'
            'За поимку Киры L берётся детектив.',
      ),
      (
        'BBCode quote and centered block',
        '[quote]Цитата[/quote]\n[center][b]Заголовок[/b][/center]',
        'Цитата\nЗаголовок',
      ),
      (
        'BBCode list items become bullets',
        '[list][*]первый[*]второй[/list]',
        '• первый\n• второй',
      ),
      (
        'a bare url open tag is unwrapped',
        '[url]https://shikimori.one/animes[/url]',
        'https://shikimori.one/animes',
      ),
      // --- Plain text / non-ASCII --------------------------------------------
      (
        'plain prose keeps punctuation, slashes and both alphabets',
        'Атака титанов / 進撃の巨人 (2024) — 1/2',
        'Атака титанов / 進撃の巨人 (2024) — 1/2',
      ),
      (
        'underscores inside identifiers are not emphasis',
        'user_name and snake_case stay',
        'user_name and snake_case stay',
      ),
      // --- Empty and malformed -----------------------------------------------
      ('empty string', '', ''),
      ('whitespace only', '   \n\t  ', ''),
      ('unbalanced bold marker', '**bold', 'bold'),
      (
        'unclosed BBCode and emphasis',
        '[b]unclosed **bold [url=x',
        'unclosed bold',
      ),
      ('truncated HTML tag', '<i>truncated', 'truncated'),
      ('unclosed image tag', '[img]left open', 'left open'),
      ('markers with no prose collapse to punctuation', '[]()[/][**][::]', '()'),
    ];

    for (final (String name, String input, String expected) in cases) {
      test(name, () {
        expect(TextUtils.parseHtmlToPlainText(input), expected);
      });
    }
  });

  group('parseHtmlToPlainText — safety', () {
    test('long marker runs neither throw nor hang', () {
      final String soup = '${'*' * 500}${'[' * 200}${'<b>' * 100}';
      final String result = TextUtils.parseHtmlToPlainText(soup);

      expect(result, isEmpty);
    });

    test('a realistic full description survives as prose', () {
      const String description =
          '**Japanese**: デスノート<br>**Romaji**: Death Note<br>'
          '**English**: Death Note<br><br>'
          'Light Yagami finds a notebook. See [the wiki](https://example.test/dn).'
          '<br>[Written by MAL Rewrite]';

      expect(
        TextUtils.parseHtmlToPlainText(description),
        'Japanese: デスノート\nRomaji: Death Note\nEnglish: Death Note\n\n'
        'Light Yagami finds a notebook. See the wiki.',
      );
    });
  });
}

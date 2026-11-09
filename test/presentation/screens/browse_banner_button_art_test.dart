// Art ratchet for WP #166.
//
// With metadataService=mal, Jikan v4 returns no banner asset, so `bannerImage`
// is ''. The browse screens used to pass it straight into MediaButton while
// the hero carousel right above painted the cover — same card, two different
// answers to "what art do I show". Both screens must go through `heroArt`
// (`media_hero_art.dart`), which falls back to the cover.
//
// This guard stops the raw field coming back: `.bannerImage` in either browse
// screen means a button (or a future one) paints a blank hero for MAL.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const List<String> _browseScreens = [
  'lib/presentation/screens/anime_screen.dart',
  'lib/presentation/screens/manga_screen.dart',
];

void main() {
  test('browse screens resolve button art through heroArt, not bannerImage', () {
    final List<String> offenders = <String>[];

    for (final path in _browseScreens) {
      final String source = File(path).readAsStringSync();
      if (source.contains('.bannerImage')) offenders.add(path);
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'The browse screens\' Calendar / Advanced Search buttons must use '
          '`heroArt` (banner when present, else cover): MAL/Jikan v4 has no '
          'banner, so a raw `.bannerImage` paints a gradient-only button next '
          'to a cover-art hero carousel (WP #166).\n'
          '${offenders.join('\n')}',
    );
  });
}

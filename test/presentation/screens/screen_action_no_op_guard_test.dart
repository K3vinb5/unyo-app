// Dead-affordance ratchet for WP #169.
//
// The manga browse screen shipped a "Calendar" button wired to
// `onPressed: () {}` (manga_screen.dart), so it looked alive (gradient, hover,
// pointer cursor) and did nothing. The calendar tab is anime-only by data model
// — the schedule feed is `AnimeRepository.getCalendarReleases` (MAL: Jikan
// `/schedules`; AniList: `nextAiringEpisode`; Shikimori: `/api/calendar`
// `next_episode_at`) and `MangaRepository` has no calendar method — so the
// button was dropped instead of pointed at anime data.
//
// This guard keeps the class of defect out of `lib/presentation/screens`: a
// screen must not render an action handler that does nothing. Known offenders
// outside this scope are tracked, not silently allowed here:
//   * lib/presentation/dialogs/anime_details_media_entry_dialog.dart — delete
//     icon in the list editor (`onPressed: () {}`);
//   * lib/presentation/widgets/styled/unyo_server_button.dart — favourite star
//     on a video server row (`onPressed: () {}`).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String _screensRoot = 'lib/presentation/screens';

/// `onPressed: () {}` / `onTap:(){}` — an empty closure body, whitespace only.
final RegExp _noOpHandler = RegExp(r'on(?:Pressed|Tap)\s*:\s*\(\s*\)\s*\{\s*\}');

void main() {
  group('screen action buttons', () {
    test('no screen renders an inert onPressed/onTap handler', () {
      final List<String> offenders = <String>[];

      for (final FileSystemEntity entity in Directory(_screensRoot).listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final List<String> lines = entity.readAsLinesSync();
        for (int index = 0; index < lines.length; index++) {
          if (_noOpHandler.hasMatch(lines[index])) {
            offenders.add('${entity.path}:${index + 1}');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'A screen must not render a button whose handler is empty: it looks '
            'clickable and does nothing (WP #169 hid the manga Calendar button '
            'for exactly this). Either wire the action or remove the button.\n'
            '${offenders.join('\n')}',
      );
    });

    test('manga browse offers Advanced Search and no Calendar', () {
      final String source = File('$_screensRoot/manga_screen.dart').readAsStringSync();

      expect(
        source,
        contains("context.tr('common_advanced_search')"),
        reason: 'advanced search is the manga browse\'s only real action button',
      );
      expect(
        source,
        isNot(contains("context.tr('common_calendar')")),
        reason: 'the calendar tab is anime-only by data model (WP #169)',
      );
    });
  });
}

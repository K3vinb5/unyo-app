// External dependencies
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
// Internal dependencies
import 'package:unyo/application/states/episode_count.dart';
import 'package:unyo/domain/entities/media/airing_episode.dart';

void main() {
  group('EpisodeCount.resolve', () {
    test('renders the provider total even when the extension answered with fewer rows', () {
      expect(
        EpisodeCount.resolve(extensionResults: 4, episodesInfo: 0, metadataTotal: 12),
        12,
        reason: 'a 4-episode extension answer must not delete rows 5-12 of a 12-episode series (WP #115)',
      );
      expect(
        EpisodeCount.resolve(extensionResults: 4, episodesInfo: 12, metadataTotal: 12),
        12,
      );
    });

    test('keeps every extra episode the extension returned', () {
      expect(
        EpisodeCount.resolve(extensionResults: 24, episodesInfo: 0, metadataTotal: 12),
        24,
        reason: 'the list shows everything the metadata knows about *plus* any extra the extension returns',
      );
      expect(
        EpisodeCount.resolve(extensionResults: 0, episodesInfo: 9, metadataTotal: 24),
        24,
        reason: 'episode metadata never caps the provider total either',
      );
    });

    test('falls back to the extension count when the provider total is unknown', () {
      expect(
        EpisodeCount.resolve(extensionResults: 8, episodesInfo: 0, metadataTotal: 0),
        8,
        reason: 'an unknown provider total (0) must not cap the extension list',
      );
      expect(EpisodeCount.resolve(extensionResults: 8, episodesInfo: 0, metadataTotal: -1), 8);
    });

    test('equality yields one row per episode, not a duplicate set', () {
      expect(EpisodeCount.resolve(extensionResults: 12, episodesInfo: 12, metadataTotal: 12), 12);
    });

    test('returns 0 when every source is empty, so the caller keeps its empty state', () {
      expect(EpisodeCount.resolve(extensionResults: 0, episodesInfo: 0, metadataTotal: 0), 0);
      expect(EpisodeCount.resolve(extensionResults: 0, episodesInfo: 0, metadataTotal: -1), 0);
    });
  });

  group('EpisodeCount.progressForControl', () {
    test('renders the "no progress yet" sentinel as 0', () {
      expect(EpisodeCount.progressForControl(progress: -1, episodeCount: 12), 0);
    });

    test('keeps an in-range progress untouched', () {
      expect(EpisodeCount.progressForControl(progress: 5, episodeCount: 12), 5);
      expect(EpisodeCount.progressForControl(progress: 12, episodeCount: 12), 12);
    });

    test('clamps a progress past the resolved count into the slider range', () {
      expect(
        EpisodeCount.progressForControl(progress: 40, episodeCount: 12),
        12,
        reason: 'the initial slider value must never sit outside [min, max]',
      );
    });

    test('renders 0 when no count is resolvable', () {
      expect(EpisodeCount.progressForControl(progress: 5, episodeCount: 0), 0);
    });
  });

  group('EpisodeCount.progressForSave', () {
    test('persists the clamped progress the control displayed', () {
      expect(
        EpisodeCount.progressForSave(progress: 40, episodeCount: 12),
        12,
        reason: 'the slider showed 12, so saving 40 would write a value the user never saw',
      );
    });

    test('keeps an in-range progress untouched', () {
      expect(EpisodeCount.progressForSave(progress: 5, episodeCount: 12), 5);
      expect(EpisodeCount.progressForSave(progress: 12, episodeCount: 12), 12);
    });

    test('preserves valid progress when the resolved count is not authoritative', () {
      expect(
        EpisodeCount.progressForSave(progress: 5, episodeCount: 0),
        5,
        reason: 'an unknown total must not zero a real progress',
      );
      expect(EpisodeCount.progressForSave(progress: 5, episodeCount: -1), 5);
    });

    test('persists the "no progress yet" sentinel as 0', () {
      expect(EpisodeCount.progressForSave(progress: -1, episodeCount: 12), 0);
      expect(EpisodeCount.progressForSave(progress: -1, episodeCount: 0), 0);
    });
  });

  group('EpisodeCount.episodeNumbers', () {
    test('uses the episode numbers the extension returned', () {
      expect(
        EpisodeCount.episodeNumbers(extensionEpisodeNumbers: <int>[13, 14], count: 2),
        <int>[13, 14],
        reason: 'a list starting at 13 must not be relabelled 1 and 2',
      );
      expect(
        EpisodeCount.episodeNumbers(extensionEpisodeNumbers: <int>[3, 7, 11], count: 3),
        <int>[3, 7, 11],
        reason: 'skipped numbers have to survive as labels',
      );
    });

    test('counts from 1 when the rows come from the metadata total', () {
      expect(EpisodeCount.episodeNumbers(extensionEpisodeNumbers: const <int>[], count: 3), <int>[1, 2, 3]);
    });

    test('continues the numbering after the extension answer so metadata rows survive', () {
      expect(
        EpisodeCount.episodeNumbers(extensionEpisodeNumbers: <int>[1, 2, 3, 4], count: 12),
        <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        reason: 'the 8 unreleased rows of a 12-episode series keep their numbers (WP #115)',
      );
      expect(
        EpisodeCount.episodeNumbers(extensionEpisodeNumbers: <int>[13, 14], count: 2),
        <int>[13, 14],
        reason: 'a continuation-season list is not renumbered to 1 and 2',
      );
    });

    test('always returns exactly `count` numbers so the render loop cannot miss a row', () {
      for (final List<int> extensionNumbers in <List<int>>[
        const <int>[],
        const <int>[1, 2, 3, 4],
        const <int>[3, 7, 11],
        const <int>[13, 14],
        const <int>[1, 1, 2],
      ]) {
        final List<int> numbers = EpisodeCount.episodeNumbers(extensionEpisodeNumbers: extensionNumbers, count: 12);
        expect(numbers, hasLength(12), reason: 'extension numbers $extensionNumbers must still yield 12 rows');
        expect(numbers.toSet(), hasLength(12), reason: 'labels must not repeat');
      }
    });

    test('returns nothing when no row is rendered', () {
      expect(EpisodeCount.episodeNumbers(extensionEpisodeNumbers: const <int>[], count: 0), isEmpty);
      expect(EpisodeCount.episodeNumbers(extensionEpisodeNumbers: const <int>[1, 2], count: 0), isEmpty);
    });
  });

  group('EpisodeRelease.releasedThrough', () {
    AiringEpisode airing({required int episode}) => AiringEpisodeModel(episode: episode, airingAt: '1700000000');

    test('a finished series with the -1 "no upcoming episode" sentinel releases every row', () {
      expect(
        EpisodeRelease.releasedThrough(
          nextAiringEpisode: AiringEpisodeModel.empty(),
          airingStatus: 'FINISHED',
          episodeCount: 12,
        ),
        12,
        reason: 'the absent sentinel is -1: decrementing it produced -2 and disabled every Shikimori row',
      );
      expect(AiringEpisodeModel.empty().episode, -1, reason: 'the sentinel this test guards must stay -1');
    });

    test('a finished series with episode 0 or absent airing data releases every row', () {
      for (final AiringEpisode next in <AiringEpisode>[
        airing(episode: 0),
        const AiringEpisodeModel(episode: -1, airingAt: ''),
        AiringEpisodeModel.empty(),
      ]) {
        expect(
          EpisodeRelease.releasedThrough(nextAiringEpisode: next, airingStatus: 'FINISHED', episodeCount: 26),
          26,
          reason: 'the sentinel (${next.episode}) must never be decremented',
        );
      }
    });

    test('a releasing series releases the episodes up to the upcoming one', () {
      expect(
        EpisodeRelease.releasedThrough(
          nextAiringEpisode: airing(episode: 5),
          airingStatus: 'RELEASING',
          episodeCount: 12,
        ),
        4,
        reason: 'episode 5 is about to air, so 1-4 are out and 5-12 stay "Not yet released"',
      );
      expect(
        EpisodeRelease.releasedThrough(
          nextAiringEpisode: airing(episode: 40),
          airingStatus: 'RELEASING',
          episodeCount: 12,
        ),
        12,
        reason: 'the boundary is clamped into the rendered range',
      );
    });

    test('a not-yet-released title has aired nothing', () {
      expect(
        EpisodeRelease.releasedThrough(
          nextAiringEpisode: AiringEpisodeModel.empty(),
          airingStatus: 'NOT_YET_RELEASED',
          episodeCount: 12,
        ),
        0,
      );
    });

    test('the raw provider spellings are normalized, not branched on', () {
      expect(EpisodeRelease.normalizeAiringStatus('released'), EpisodeRelease.finished);
      expect(EpisodeRelease.normalizeAiringStatus('FINISHED'), EpisodeRelease.finished);
      expect(EpisodeRelease.normalizeAiringStatus('ongoing'), EpisodeRelease.releasing);
      expect(EpisodeRelease.normalizeAiringStatus('anons'), EpisodeRelease.notYetReleased);
      expect(
        EpisodeRelease.releasedThrough(
          nextAiringEpisode: AiringEpisodeModel.empty(),
          airingStatus: 'released',
          episodeCount: 12,
        ),
        12,
        reason: 'a Shikimori status that skipped the mapper still releases every row',
      );
    });

    test('an unknown total claims nothing', () {
      expect(
        EpisodeRelease.releasedThrough(
          nextAiringEpisode: AiringEpisodeModel.empty(),
          airingStatus: 'FINISHED',
          episodeCount: 0,
        ),
        0,
      );
    });
  });

  group('episode release rule is shared', () {
    test('the details screen and the drawer call the helper instead of an inline sentinel comparison', () async {
      const List<String> sources = <String>[
        'lib/presentation/screens/anime_details_screen.dart',
        'lib/presentation/drawers/episode_list_drawer.dart',
      ];
      for (final String path in sources) {
        final String source = await File(path).readAsString();
        expect(
          source.contains('EpisodeRelease.releasedThrough'),
          isTrue,
          reason: '$path must derive the release boundary from the shared helper',
        );
        expect(
          RegExp(r'nextAiringEpisode\.episode\s*!=\s*0').hasMatch(source),
          isFalse,
          reason: '$path must not compare the airing-episode sentinel inline any more (WP #115 amendment)',
        );
      }
    });
  });
}


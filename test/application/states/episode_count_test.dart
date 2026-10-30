// External dependencies
import 'package:flutter_test/flutter_test.dart';
// Internal dependencies
import 'package:unyo/application/states/episode_count.dart';

void main() {
  group('EpisodeCount.resolve', () {
    test('uses the extension results over every metadata count', () {
      expect(
        EpisodeCount.resolve(extensionResults: 12, episodesInfo: 11, metadataTotal: 24),
        12,
        reason: 'the extension list is the only proof of episodes that really exist',
      );
      expect(
        EpisodeCount.resolve(extensionResults: 12, episodesInfo: 0, metadataTotal: 0),
        12,
        reason: 'an unknown provider total must not cap the extension list',
      );
    });

    test('falls back to the episode metadata when the extension returned nothing', () {
      expect(
        EpisodeCount.resolve(extensionResults: 0, episodesInfo: 9, metadataTotal: 24),
        9,
      );
      expect(
        EpisodeCount.resolve(extensionResults: 0, episodesInfo: 9, metadataTotal: 0),
        9,
        reason: 'episode metadata alone still proves the count when the provider omits it',
      );
    });

    test('falls back to the provider total when nothing else is known', () {
      expect(
        EpisodeCount.resolve(extensionResults: 0, episodesInfo: 0, metadataTotal: 24),
        24,
      );
    });

    test('returns 0 when every source is empty, so the caller keeps its empty state', () {
      expect(EpisodeCount.resolve(extensionResults: 0, episodesInfo: 0, metadataTotal: 0), 0);
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

    test('returns nothing when no row is rendered', () {
      expect(EpisodeCount.episodeNumbers(extensionEpisodeNumbers: const <int>[], count: 0), isEmpty);
    });
  });
}

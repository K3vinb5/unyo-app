// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unyo_lib/jmodels/jsepisode.dart';
// Internal dependencies
import 'package:unyo/domain/utils/episode_index.dart';

class MockJSEpisode extends Mock implements JSEpisode {}

JSEpisode _episodeWithNumber(int number) {
  final JSEpisode episode = MockJSEpisode();
  when(() => episode.getEpisode_number()).thenReturn(number.toDouble());
  return episode;
}

void main() {
  group('resolveEpisodeIndexFromNumbers', () {
    test('returns the position of the exact episode number when index != number', () {
      // List starts at 1 but skips 4, so episode 5 lives at index 3 (not 4).
      expect(EpisodeIndex.resolveEpisodeIndexFromNumbers([1, 2, 3, 5, 6], 5), 3);
    });

    test('falls back to episodeNumber - 1 when the exact number is missing', () {
      expect(EpisodeIndex.resolveEpisodeIndexFromNumbers([0, 1, 2], 3), 2);
    });

    test('returns -1 when the episode is out of range', () {
      expect(EpisodeIndex.resolveEpisodeIndexFromNumbers([1, 2, 3], 9), -1);
      expect(EpisodeIndex.resolveEpisodeIndexFromNumbers([], 1), -1);
    });
  });

  group('resolveExtensionEpisodeIndex', () {
    test('resolves the episode number against the extension episode list', () {
      final List<JSEpisode> episodes = [
        _episodeWithNumber(1),
        _episodeWithNumber(2),
        _episodeWithNumber(3),
        _episodeWithNumber(5),
        _episodeWithNumber(6),
      ];

      expect(EpisodeIndex.resolveExtensionEpisodeIndex(episodes, 5), 3);
      expect(EpisodeIndex.resolveExtensionEpisodeIndex(episodes, 6), 4);
    });

    test('falls back to the legacy index behavior when no exact match exists', () {
      final List<JSEpisode> episodes = [
        _episodeWithNumber(0),
        _episodeWithNumber(1),
        _episodeWithNumber(2),
      ];

      expect(EpisodeIndex.resolveExtensionEpisodeIndex(episodes, 3), 2);
    });

    test('returns -1 when the episode is not part of the extension list', () {
      final List<JSEpisode> episodes = [_episodeWithNumber(1), _episodeWithNumber(2)];

      expect(EpisodeIndex.resolveExtensionEpisodeIndex(episodes, 7), -1);
    });
  });
}

// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/aniskip/aniskip_times_entity.dart';
import 'package:unyo/core/services/video/skip_window.dart';
import 'package:unyo/core/services/video/up_next_window.dart';

AniskipTimesResults _window(double start, double end) => AniskipTimesResults()
  ..interval = (AniskipTimesResultsInterval()
    ..startTime = start
    ..endTime = end);

void main() {
  group('up-next trigger window', () {
    test('short episode (10 min) uses the 90 s floor', () {
      expect(upNextWindow(const Duration(minutes: 10)), const Duration(seconds: 90));
    });

    test('24 min episode also sits under the floor', () {
      expect(upNextWindow(const Duration(minutes: 24)), const Duration(seconds: 90));
    });

    test('45 min episode uses 4%', () {
      expect(upNextWindow(const Duration(minutes: 45)), const Duration(seconds: 108));
    });

    test('two hour movie is capped at 180 s', () {
      expect(upNextWindow(const Duration(hours: 2)), upNextWindowCap);
    });

    test('no duration yet never opens the window', () {
      expect(upNextWindow(Duration.zero), Duration.zero);
      expect(
        isUpNextWindowOpen(position: Duration.zero, duration: Duration.zero, hasNextEpisode: true),
        isFalse,
      );
    });

    test('opens exactly at the boundary, not before', () {
      const duration = Duration(minutes: 45); // window = 108 s
      expect(
        isUpNextWindowOpen(
          position: duration - const Duration(seconds: 109),
          duration: duration,
          hasNextEpisode: true,
        ),
        isFalse,
      );
      expect(
        isUpNextWindowOpen(
          position: duration - const Duration(seconds: 108),
          duration: duration,
          hasNextEpisode: true,
        ),
        isTrue,
      );
    });

    test('never opens without a next episode', () {
      const duration = Duration(minutes: 24);
      expect(
        isUpNextWindowOpen(
          position: duration - const Duration(seconds: 5),
          duration: duration,
          hasNextEpisode: false,
        ),
        isFalse,
      );
    });

    test('the cap keeps a 2 h movie from offering "up next" 5 minutes early', () {
      const duration = Duration(hours: 2);
      expect(
        isUpNextWindowOpen(
          position: duration - const Duration(seconds: 200),
          duration: duration,
          hasNextEpisode: true,
        ),
        isFalse,
      );
      expect(
        isUpNextWindowOpen(
          position: duration - const Duration(seconds: 180),
          duration: duration,
          hasNextEpisode: true,
        ),
        isTrue,
      );
    });
  });

  group('playlist gating', () {
    test('last item of the playlist has no next episode', () {
      expect(hasNextPlaylistEpisode(playlistIndex: 11, episodeCount: 12), isFalse);
      expect(hasNextPlaylistEpisode(playlistIndex: 10, episodeCount: 12), isTrue);
    });

    test('an empty episode list has no next episode', () {
      expect(hasNextPlaylistEpisode(playlistIndex: 0, episodeCount: 0), isFalse);
      expect(hasNextPlaylistEpisode(playlistIndex: -1, episodeCount: 12), isFalse);
    });
  });

  group('dismissal scoping', () {
    const duration = Duration(minutes: 24);
    final position = duration - const Duration(seconds: 20);

    bool visible({required int playlistIndex, int? dismissed}) => shouldShowUpNextCard(
          position: position,
          duration: duration,
          playlistIndex: playlistIndex,
          episodeCount: 12,
          dismissedPlaylistIndex: dismissed,
        );

    test('dismissed on this episode hides the card', () {
      expect(visible(playlistIndex: 3, dismissed: 3), isFalse);
    });

    test('moving to the next episode re-arms it', () {
      expect(visible(playlistIndex: 4, dismissed: 3), isTrue);
    });

    test('a fresh open of the same episode (no dismissal) shows it again', () {
      expect(visible(playlistIndex: 3, dismissed: null), isTrue);
    });

    test('no dismissal recorded anywhere: card shows inside the window', () {
      expect(visible(playlistIndex: 3), isTrue);
    });
  });

  group('episode label', () {
    test('title and number', () {
      expect(upNextEpisodeLabel(episodeTitle: 'A Storm', episodeNumber: 4), 'A Storm (E4)');
    });

    test('season when known', () {
      expect(
        upNextEpisodeLabel(episodeTitle: 'A Storm', seasonNumber: 2, episodeNumber: 4),
        'A Storm (S2E4)',
      );
    });

    test('number only', () {
      expect(upNextEpisodeLabel(episodeNumber: 4), '(E4)');
    });

    test('title only, nothing invented', () {
      expect(upNextEpisodeLabel(episodeTitle: 'A Storm'), 'A Storm');
    });

    test('blank title is treated as unknown', () {
      expect(upNextEpisodeLabel(episodeTitle: '   ', episodeNumber: 7), '(E7)');
    });

    test('nothing known renders empty, never dangling parentheses', () {
      expect(upNextEpisodeLabel(), '');
    });
  });

  group('skip window', () {
    AniskipTimesResults none() => AniskipTimesResults();

    test('opening window is detected', () {
      expect(
        activeSkipWindow(
          position: const Duration(seconds: 30),
          opening: _window(10, 100),
          ending: none(),
        ),
        SkipWindowKind.opening,
      );
    });

    test('ending window wins only when the opening one is over', () {
      expect(
        activeSkipWindow(
          position: const Duration(seconds: 1200),
          opening: _window(10, 100),
          ending: _window(1300, 1380),
        ),
        SkipWindowKind.none,
      );
      expect(
        activeSkipWindow(
          position: const Duration(seconds: 1340),
          opening: _window(10, 100),
          ending: _window(1300, 1380),
        ),
        SkipWindowKind.ending,
      );
    });

    test('a window ends exactly at its end time', () {
      expect(
        activeSkipWindow(
          position: const Duration(seconds: 100),
          opening: _window(10, 100),
          ending: none(),
        ),
        SkipWindowKind.none,
      );
    });

    test('missing aniskip data is not a window', () {
      expect(
        activeSkipWindow(position: Duration.zero, opening: none(), ending: none()),
        SkipWindowKind.none,
      );
    });
  });
}

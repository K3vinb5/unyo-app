import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unyo/core/services/video/video_service.dart';
import 'package:unyo/presentation/shortcuts/video_shortcut_handler.dart';
import 'package:unyo/presentation/shortcuts/video_shortcuts.dart';

class _MockVideoService extends Mock implements VideoService {}

/// WP #98 Phase B: every intent must land on the same VideoService/VideoCubit
/// call the on-screen buttons make, with the documented clamps.
void main() {
  late _MockVideoService service;
  late VideoShortcutHandler handler;
  late int nextEpisodeCalls;
  late int previousEpisodeCalls;

  setUpAll(() {
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    service = _MockVideoService();
    nextEpisodeCalls = 0;
    previousEpisodeCalls = 0;
    when(() => service.isPlaying).thenReturn(true);
    when(() => service.volume).thenReturn(0.5);
    when(() => service.playbackSpeed).thenReturn(1.0);
    when(() => service.position).thenReturn(const Duration(seconds: 30));
    when(() => service.duration).thenReturn(const Duration(seconds: 100));
    when(() => service.isFullscreen).thenReturn(false);
    when(() => service.subtitlesEnabled).thenReturn(true);
    when(() => service.play()).thenReturn(true);
    when(() => service.pause()).thenReturn(true);
    when(() => service.togglePlay()).thenReturn(true);
    when(() => service.seekTo(any())).thenReturn(true);
    when(() => service.setVolume(any())).thenReturn(true);
    when(() => service.setPlaybackSpeed(any())).thenReturn(true);
    when(() => service.setFullscreen(any())).thenReturn(true);
    when(() => service.toggleSubtitles()).thenReturn(true);
    handler = VideoShortcutHandler(
      commands: service,
      onNextEpisode: () => nextEpisodeCalls++,
      onPreviousEpisode: () => previousEpisodeCalls++,
    );
  });

  tearDown(() => handler.dispose());

  group('play / pause', () {
    test('Space and K both toggle play', () {
      expect(handler.handle(const TogglePlayIntent()), isTrue);
      expect(handler.handle(const TogglePlayIntent()), isTrue);
      verify(() => service.togglePlay()).called(2);
    });
  });

  group('seek', () {
    test('J rewinds 10s from the current position', () {
      handler.handle(const SeekByIntent(Duration(seconds: -10)));
      verify(() => service.seekTo(const Duration(seconds: 20))).called(1);
    });

    test('J clamps at 0 when less than 10s in', () {
      when(() => service.position).thenReturn(const Duration(seconds: 4));
      handler.handle(const SeekByIntent(Duration(seconds: -10)));
      verify(() => service.seekTo(Duration.zero)).called(1);
    });

    test('L forwards 10s', () {
      handler.handle(const SeekByIntent(Duration(seconds: 10)));
      verify(() => service.seekTo(const Duration(seconds: 40))).called(1);
    });

    test('L clamps at the episode duration', () {
      when(() => service.position).thenReturn(const Duration(seconds: 96));
      handler.handle(const SeekByIntent(Duration(seconds: 10)));
      verify(() => service.seekTo(const Duration(seconds: 100))).called(1);
    });

    test('arrows seek 5s in both directions', () {
      handler.handle(const SeekByIntent(Duration(seconds: -5)));
      handler.handle(const SeekByIntent(Duration(seconds: 5)));
      verify(() => service.seekTo(const Duration(seconds: 25))).called(1);
      verify(() => service.seekTo(const Duration(seconds: 35))).called(1);
    });

    test('digit 5 seeks to 50% and digit 9 to 90%', () {
      handler.handle(const SeekToPercentIntent(0.5));
      handler.handle(const SeekToPercentIntent(0.9));
      verify(() => service.seekTo(const Duration(seconds: 50))).called(1);
      verify(() => service.seekTo(const Duration(seconds: 90))).called(1);
    });

    test('digit 0 seeks to the start', () {
      handler.handle(const SeekToPercentIntent(0));
      verify(() => service.seekTo(Duration.zero)).called(1);
    });

    test('seek feedback shows the delta', () {
      handler.handle(const SeekByIntent(Duration(seconds: -10)));
      expect(handler.feedback.value?.kind, VideoShortcutFeedbackKind.seek);
      expect(handler.feedback.value?.text, '-10s');
    });
  });

  group('volume', () {
    test('ArrowUp raises by 5% of full scale', () {
      handler.handle(const AdjustVolumeIntent(0.05));
      verify(() => service.setVolume(0.55)).called(1);
      expect(handler.feedback.value?.text, '55%');
    });

    test('ArrowUp clamps at 1.0', () {
      when(() => service.volume).thenReturn(0.98);
      handler.handle(const AdjustVolumeIntent(0.05));
      verify(() => service.setVolume(1.0)).called(1);
    });

    test('ArrowDown clamps at 0.0', () {
      when(() => service.volume).thenReturn(0.02);
      handler.handle(const AdjustVolumeIntent(-0.05));
      verify(() => service.setVolume(0.0)).called(1);
    });

    test('M mutes, then restores the previous level', () {
      handler.handle(const ToggleMuteIntent());
      verify(() => service.setVolume(0.0)).called(1);

      when(() => service.volume).thenReturn(0.0);
      handler.handle(const ToggleMuteIntent());
      verify(() => service.setVolume(0.5)).called(1);
    });

    test('M restores full volume when muted from silence', () {
      when(() => service.volume).thenReturn(0.0);
      handler.handle(const ToggleMuteIntent());
      verify(() => service.setVolume(1.0)).called(1);
    });
  });

  group('speed', () {
    test('Shift+. raises speed by 0.25', () {
      handler.handle(const AdjustSpeedIntent(0.25));
      verify(() => service.setPlaybackSpeed(1.25)).called(1);
      expect(handler.feedback.value?.text, '1.25x');
    });

    test('Shift+, lowers speed by 0.25', () {
      handler.handle(const AdjustSpeedIntent(-0.25));
      verify(() => service.setPlaybackSpeed(0.75)).called(1);
    });

    test('speed clamps to 0.25 at the bottom', () {
      when(() => service.playbackSpeed).thenReturn(0.25);
      handler.handle(const AdjustSpeedIntent(-0.25));
      verify(() => service.setPlaybackSpeed(0.25)).called(1);
    });

    test('speed clamps to 2.0 at the top', () {
      when(() => service.playbackSpeed).thenReturn(2.0);
      handler.handle(const AdjustSpeedIntent(0.25));
      verify(() => service.setPlaybackSpeed(2.0)).called(1);
    });

    test('speed snaps the menu values onto the 0.25 grid', () {
      when(() => service.playbackSpeed).thenReturn(1.5);
      handler.handle(const AdjustSpeedIntent(0.25));
      verify(() => service.setPlaybackSpeed(1.75)).called(1);
    });
  });

  group('fullscreen / captions', () {
    test('F toggles fullscreen on and off', () {
      handler.handle(const ToggleFullscreenIntent());
      verify(() => service.setFullscreen(true)).called(1);

      when(() => service.isFullscreen).thenReturn(true);
      handler.handle(const ToggleFullscreenIntent());
      verify(() => service.setFullscreen(false)).called(1);
    });

    test('Esc leaves fullscreen and does nothing otherwise', () {
      expect(handler.handle(const ExitFullscreenIntent()), isFalse);
      verifyNever(() => service.setFullscreen(any()));

      when(() => service.isFullscreen).thenReturn(true);
      expect(handler.handle(const ExitFullscreenIntent()), isTrue);
      verify(() => service.setFullscreen(false)).called(1);
    });

    test('C toggles captions through the same call the menu uses', () {
      handler.handle(const ToggleCaptionsIntent());
      verify(() => service.toggleSubtitles()).called(1);
    });

    test('C is a no-op result when there are no subtitle tracks', () {
      when(() => service.toggleSubtitles()).thenReturn(false);
      expect(handler.handle(const ToggleCaptionsIntent()), isFalse);
    });
  });

  group('episodes', () {
    test('N advances the episode list, Shift+N goes back', () {
      handler.handle(const NextEpisodeIntent());
      handler.handle(const PreviousEpisodeIntent());
      expect(nextEpisodeCalls, 1);
      expect(previousEpisodeCalls, 1);
      // Episode navigation must never go through the player.
      verifyNever(() => service.seekTo(any()));
    });
  });
}

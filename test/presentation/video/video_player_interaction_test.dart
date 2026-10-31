// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/services/video/video_playback_commands.dart';
import 'package:unyo/presentation/shortcuts/video_shortcut_handler.dart';
import 'package:unyo/presentation/shortcuts/video_shortcuts.dart';
import 'package:unyo/presentation/video/video_player_interaction.dart';

/// Minimal [VideoPlaybackCommands] stand-in: records calls, lets the test flip
/// the playback state.
class FakePlaybackCommands implements VideoPlaybackCommands {
  bool playing = true;
  int playCalls = 0;
  int pauseCalls = 0;
  int togglePlayCalls = 0;
  int seekCalls = 0;
  int fullscreenCalls = 0;
  Duration lastSeek = Duration.zero;

  @override
  bool get isPlaying => playing;

  @override
  double get volume => 0.5;

  @override
  double get playbackSpeed => 1.0;

  @override
  Duration get position => const Duration(seconds: 30);

  @override
  Duration get duration => const Duration(seconds: 100);

  @override
  bool get isFullscreen => false;

  @override
  bool get subtitlesEnabled => true;

  @override
  void play() {
    playCalls++;
    playing = true;
  }

  @override
  void pause() {
    pauseCalls++;
    playing = false;
  }

  @override
  void togglePlay() {
    togglePlayCalls++;
    playing = !playing;
  }

  @override
  void seekTo(Duration position) {
    seekCalls++;
    lastSeek = position;
  }

  @override
  void setVolume(double volume) {}

  @override
  void setPlaybackSpeed(double speed) {}

  @override
  void setFullscreen(bool fullscreen) {
    fullscreenCalls++;
  }

  @override
  bool toggleSubtitles() => true;
}

/// WP #116: the fade + 4 s hide behaviour a keyboard shortcut and an on-screen
/// button must share, because both dispatch onto the same interaction object.
void main() {
  late FakePlaybackCommands commands;

  /// Built inside the test body on purpose: the interaction arms a real timer
  /// at construction, and timers created in `setUp` land outside the
  /// `testWidgets` fake-async zone, so `tester.pump(duration)` could never
  /// advance them.
  VideoPlayerInteraction start() {
    commands = FakePlaybackCommands();
    return VideoPlayerInteraction(commands: commands);
  }

  /// Cancels the pending hide timer so `testWidgets` does not complain about
  /// timers left over at the end of a test body.
  void stopTimer(VideoPlayerInteraction interaction) => interaction.hide();

  testWidgets('starts visible and hides after the 4 s countdown while playing', (tester) async {
    final interaction = start();
    expect(interaction.controlsVisible, isTrue);

    await tester.pump(VideoPlayerInteraction.hideDelay - const Duration(milliseconds: 1));
    expect(interaction.controlsVisible, isTrue);

    await tester.pump(const Duration(milliseconds: 2));
    expect(interaction.controlsVisible, isFalse);
  });

  testWidgets('paused playback never auto-hides', (tester) async {
    final interaction = start();
    commands.playing = false;
    interaction.reveal();
    await tester.pump(VideoPlayerInteraction.hideDelay * 2);
    expect(interaction.controlsVisible, isTrue);
    stopTimer(interaction);
  });

  group('shortcut path == button path', () {
    testWidgets('a Space press through the handler reveals hidden controls and toggles once', (tester) async {
      final interaction = start();
      final handler = VideoShortcutHandler(
        commands: interaction,
        onNextEpisode: () {},
        onPreviousEpisode: () {},
      );
      addTearDown(handler.dispose);

      // Hide the bar first, exactly like 4 s of no interaction.
      interaction.hide();
      await tester.pump(VideoPlayerInteraction.hideDelay);
      expect(interaction.controlsVisible, isFalse);

      expect(handler.handle(const TogglePlayIntent()), isTrue);

      // Controls are revealed immediately; the fade is an AnimatedOpacity
      // concern, the state flip is synchronous.
      expect(interaction.controlsVisible, isTrue);
      expect(commands.togglePlayCalls, 1);
      expect(commands.playCalls + commands.pauseCalls, 0, reason: 'exactly one toggle');
      stopTimer(interaction);
    });

    testWidgets('the hide timer is re-armed from the shortcut moment', (tester) async {
      final interaction = start();
      final handler = VideoShortcutHandler(
        commands: interaction,
        onNextEpisode: () {},
        onPreviousEpisode: () {},
      );
      addTearDown(handler.dispose);

      // Burn 3.9 s of the original countdown, then press the key.
      await tester.pump(const Duration(milliseconds: 3900));
      handler.handle(const TogglePlayIntent());
      // The fake flips playback state on toggle; keep it playing so the
      // auto-hide countdown is the thing under test.
      commands.playing = true;
      expect(interaction.controlsVisible, isTrue);

      // The old timer would have fired 100 ms later; the re-armed one not yet.
      await tester.pump(const Duration(milliseconds: 200));
      expect(interaction.controlsVisible, isTrue);

      await tester.pump(VideoPlayerInteraction.hideDelay);
      expect(interaction.controlsVisible, isFalse);
    });

    testWidgets('a button press goes through the very same state transitions', (tester) async {
      final interaction = start();
      interaction.hide();
      await tester.pump(VideoPlayerInteraction.hideDelay);

      interaction.togglePlay();

      expect(interaction.controlsVisible, isTrue);
      expect(commands.togglePlayCalls, 1);

      // The toggle paused playback: a paused player keeps the bar up.
      await tester.pump(VideoPlayerInteraction.hideDelay * 2);
      expect(interaction.controlsVisible, isTrue);

      // Resuming re-arms the countdown through the same path.
      commands.playing = true;
      interaction.reveal();
      await tester.pump(VideoPlayerInteraction.hideDelay + const Duration(milliseconds: 1));
      expect(interaction.controlsVisible, isFalse);
    });

    testWidgets('shortcut seek and fullscreen also reveal the bar', (tester) async {
      final interaction = start();
      final handler = VideoShortcutHandler(
        commands: interaction,
        onNextEpisode: () {},
        onPreviousEpisode: () {},
      );
      addTearDown(handler.dispose);

      interaction.hide();
      handler.handle(const SeekByIntent(Duration(seconds: 10)));
      expect(commands.seekCalls, 1);
      expect(interaction.controlsVisible, isTrue);

      interaction.hide();
      handler.handle(const ToggleFullscreenIntent());
      expect(commands.fullscreenCalls, 1);
      expect(interaction.controlsVisible, isTrue);
      stopTimer(interaction);
    });

    testWidgets('episode navigation through the handler also counts as activity', (tester) async {
      final interaction = start();
      var nextCalls = 0;
      final handler = VideoShortcutHandler(
        commands: interaction,
        onNextEpisode: () => interaction.act(() => nextCalls++),
        onPreviousEpisode: () => interaction.act(() {}),
      );
      addTearDown(handler.dispose);

      interaction.hide();
      handler.handle(const NextEpisodeIntent());

      expect(nextCalls, 1);
      expect(interaction.controlsVisible, isTrue);
      stopTimer(interaction);
    });
  });

  group('auto-repeat', () {
    test('holding Space coalesces into one toggle inside the repeat guard', () {
      final interaction = start();
      addTearDown(interaction.dispose);
      var now = DateTime(2026, 10, 31, 12);
      final handler = VideoShortcutHandler(
        commands: interaction,
        onNextEpisode: () {},
        onPreviousEpisode: () {},
        clock: () => now,
      );
      addTearDown(handler.dispose);

      // Auto-repeat fires every ~30 ms.
      for (var i = 0; i < 8; i++) {
        handler.handle(const TogglePlayIntent());
        now = now.add(const Duration(milliseconds: 30));
      }

      expect(commands.togglePlayCalls, 1);

      // A deliberate second press after the guard window works again.
      now = now.add(VideoShortcutHandler.repeatGuard);
      handler.handle(const TogglePlayIntent());
      expect(commands.togglePlayCalls, 2);
    });

    test('directional intents still repeat', () {
      final interaction = start();
      addTearDown(interaction.dispose);
      var now = DateTime(2026, 10, 31, 12);
      final handler = VideoShortcutHandler(
        commands: interaction,
        onNextEpisode: () {},
        onPreviousEpisode: () {},
        clock: () => now,
      );
      addTearDown(handler.dispose);

      for (var i = 0; i < 3; i++) {
        handler.handle(const SeekByIntent(Duration(seconds: 5)));
        now = now.add(const Duration(milliseconds: 30));
      }

      expect(commands.seekCalls, 3);
    });
  });

  testWidgets('the bar is wired to the shared 300 ms fade, driven by the shortcut path', (tester) async {
    final interaction = start();
    final handler = VideoShortcutHandler(
      commands: interaction,
      onNextEpisode: () {},
      onPreviousEpisode: () {},
    );
    addTearDown(handler.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ListenableBuilder(
          listenable: interaction,
          builder: (context, _) => AnimatedOpacity(
            duration: VideoPlayerInteraction.fadeDuration,
            opacity: interaction.controlsVisible ? 1 : 0,
            child: const ColoredBox(color: Colors.white),
          ),
        ),
      ),
    );

    interaction.hide();
    await tester.pump(VideoPlayerInteraction.fadeDuration);
    expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity, 0);
    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).duration,
      const Duration(milliseconds: 300),
    );

    handler.handle(const TogglePlayIntent());
    await tester.pump();

    // The shortcut flips the very same state the button path flips, and the
    // bar is painted through a 300 ms fade.
    expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity, 1);

    await tester.pump(VideoPlayerInteraction.fadeDuration);
    expect(interaction.controlsVisible, isTrue);
    stopTimer(interaction);
  });
}

// External dependencies
import 'dart:async';

import 'package:flutter/foundation.dart';

// Internal dependencies
import 'package:unyo/core/services/video/video_playback_commands.dart';

/// The single path every player-affecting input goes through.
///
/// Both the on-screen controls and the keyboard shortcuts dispatch onto this
/// object (WP #116), so a key press and a button click cannot diverge: the
/// command runs on the player, the controls fade back in over [fadeDuration]
/// and the [hideDelay] auto-hide countdown is re-armed from that moment.
///
/// The hide timer lives here and nowhere else — `UnyoVideoControls` is a pure
/// listener, which is what makes the shortcut path and the button path
/// identical by construction instead of by copy-pasted timers.
///
/// Playback state is *observed*, never owned: [playing] is the player's own
/// [ValueListenable], so a pause that arrives from a mouse click, a keyboard
/// shortcut, MPRIS/audio_service or the end of the media all look the same to
/// the UI and all animate the pause glyph (WP #119).
class VideoPlayerInteraction extends ChangeNotifier implements VideoPlaybackCommands {
  VideoPlayerInteraction({required VideoPlaybackCommands commands, required ValueListenable<bool> playing})
      : _commands = commands,
        _playing = playing {
    // The bar starts visible, exactly like #116's predecessor: the countdown is
    // already running when the player opens.
    _armHideTimer();
    // A pause is an interaction, whoever raised it: MPRIS/audio_service and the
    // end of the media never go through a widget, and pre-#169's `pauseVideo()`
    // was the only thing that put the bar back up. Observing the state keeps
    // that behaviour for every path, and a resume re-arms the countdown.
    _playing.addListener(_onPlayingChanged);
  }

  /// How long the bar stays up after the last interaction.
  static const Duration hideDelay = Duration(seconds: 4);

  /// Fade in/out of the controls bar (the pre-#116 `AnimatedOpacity` timing).
  static const Duration fadeDuration = Duration(milliseconds: 300);

  final VideoPlaybackCommands _commands;

  /// The player's playback state, forwarded from the service.
  final ValueListenable<bool> _playing;

  Timer? _hideTimer;
  bool _controlsVisible = true;
  bool _held = false;

  bool get controlsVisible => _controlsVisible;

  /// The player's live playback state. Same value as [playing], read without
  /// subscribing.
  @override
  bool get isPlaying => _playing.value;

  /// Changes whenever the player starts or stops — from any trigger path.
  ValueListenable<bool> get playing => _playing;

  /// Reveals the bar and restarts the auto-hide countdown.
  ///
  /// Idempotent: while the bar is already up only the timer is re-armed, so an
  /// in-flight fade is never restarted. That is what keeps keyboard auto-repeat
  /// from making the animation stutter.
  void reveal() {
    _hideTimer?.cancel();
    if (!_controlsVisible) {
      _controlsVisible = true;
      notifyListeners();
    }
    _armHideTimer();
  }

  /// Hides the bar immediately (episode-list drawer, auto-hide).
  void hide() {
    _hideTimer?.cancel();
    if (_controlsVisible) {
      _controlsVisible = false;
      notifyListeners();
    }
  }

  /// Whether a click on the picture would do anything: it pauses while the
  /// player is running and is inert while paused, because resuming is reserved
  /// for the centre glyph and the play button (WP #119).
  ///
  /// This is the behaviour only — the surface cursor does NOT follow it: the
  /// video canvas never advertises a click (design choice, WP #119).
  bool get surfaceTapActs => isPlaying;

  /// A click on the video picture.
  ///
  /// While playing it pauses and reveals the bar in the same click; while
  /// paused it does nothing at all — resuming is reserved for the centre
  /// glyph and the play button, so a stray click on a paused frame can never
  /// start playback (WP #119).
  void handleSurfaceTap() {
    if (!surfaceTapActs) return;
    pause();
  }

  /// Keeps the bar up and stops the countdown while the pointer is on it or the
  /// seek slider is being dragged.
  void hold() {
    _held = true;
    _hideTimer?.cancel();
    if (!_controlsVisible) {
      _controlsVisible = true;
      notifyListeners();
    }
  }

  /// Ends a [hold] and restarts the countdown.
  void release() {
    _held = false;
    reveal();
  }

  /// Runs any player-affecting action (including episode navigation, which
  /// lives on the cubit) through the shared reveal + hide-timer path.
  void act(VoidCallback action) {
    action();
    _afterInteraction();
  }

  /// Bar visibility for a state change the screen did not raise (MPRIS, end of
  /// media). Idempotent through [reveal], so it cannot fight a click.
  void _onPlayingChanged() => reveal();

  /// Every player command ends here: same reveal + countdown as a pointer or
  /// keyboard interaction, because it is literally [reveal].
  void _afterInteraction() => reveal();

  void _armHideTimer() {
    _hideTimer?.cancel();
    if (_held) return;
    _hideTimer = Timer(hideDelay, () {
      // Paused playback never hides the bar: there is nothing on screen to
      // watch, so the controls stay reachable.
      if (isPlaying) hide();
    });
  }

  // VideoPlaybackCommands — every player command goes through the same reveal.

  @override
  double get volume => _commands.volume;

  @override
  bool get isFullscreen => _commands.isFullscreen;

  @override
  bool get subtitlesEnabled => _commands.subtitlesEnabled;

  @override
  Duration get position => _commands.position;

  @override
  Duration get duration => _commands.duration;

  @override
  double get playbackSpeed => _commands.playbackSpeed;

  @override
  void play() {
    _commands.play();
    _afterInteraction();
  }

  @override
  void pause() {
    _commands.pause();
    _afterInteraction();
  }

  @override
  void togglePlay() {
    _commands.togglePlay();
    _afterInteraction();
  }

  @override
  void seekTo(Duration position) {
    _commands.seekTo(position);
    _afterInteraction();
  }

  @override
  void setVolume(double volume) {
    _commands.setVolume(volume);
    _afterInteraction();
  }

  @override
  void setPlaybackSpeed(double speed) {
    _commands.setPlaybackSpeed(speed);
    _afterInteraction();
  }

  @override
  void setFullscreen(bool fullscreen) {
    _commands.setFullscreen(fullscreen);
    _afterInteraction();
  }

  @override
  bool toggleSubtitles() {
    final handled = _commands.toggleSubtitles();
    _afterInteraction();
    return handled;
  }

  @override
  void dispose() {
    _playing.removeListener(_onPlayingChanged);
    _hideTimer?.cancel();
    super.dispose();
  }
}

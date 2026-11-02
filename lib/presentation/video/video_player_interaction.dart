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
class VideoPlayerInteraction extends ChangeNotifier implements VideoPlaybackCommands {
  VideoPlayerInteraction({required VideoPlaybackCommands commands}) : _commands = commands {
    // The bar starts visible, exactly like #116's predecessor: the countdown is
    // already running when the player opens.
    _armHideTimer();
  }

  /// How long the bar stays up after the last interaction.
  static const Duration hideDelay = Duration(seconds: 4);

  /// Fade in/out of the controls bar (the pre-#116 `AnimatedOpacity` timing).
  static const Duration fadeDuration = Duration(milliseconds: 300);

  final VideoPlaybackCommands _commands;

  Timer? _hideTimer;
  bool _controlsVisible = true;
  bool _held = false;

  bool get controlsVisible => _controlsVisible;

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

  /// Hides the bar immediately (episode-list drawer, surface tap).
  void hide() {
    _hideTimer?.cancel();
    if (_controlsVisible) {
      _controlsVisible = false;
      notifyListeners();
    }
  }

  /// Surface tap: the bar toggles instead of jumping to a hidden state.
  void toggleControls() => _controlsVisible ? hide() : reveal();

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

  void _afterInteraction() {
    _hideTimer?.cancel();
    if (!_controlsVisible) {
      _controlsVisible = true;
      notifyListeners();
    }
    _armHideTimer();
  }

  void _armHideTimer() {
    _hideTimer?.cancel();
    if (_held) return;
    _hideTimer = Timer(hideDelay, () {
      // Paused playback never hides the bar: there is nothing on screen to
      // watch, so the controls stay reachable.
      if (_commands.isPlaying) hide();
    });
  }

  // VideoPlaybackCommands — every player command goes through the same reveal.

  @override
  bool get isPlaying => _commands.isPlaying;

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
    _hideTimer?.cancel();
    super.dispose();
  }
}

// External dependencies
import 'package:flutter/foundation.dart';

// Internal dependencies
import 'package:unyo/core/services/video/video_playback_commands.dart';
import 'package:unyo/presentation/shortcuts/video_shortcuts.dart';

/// Which transient indicator the video screen should flash, mirroring where
/// YouTube shows one (volume, speed, seek delta). No indicator for
/// play/pause/fullscreen/captions — YouTube shows none there either.
enum VideoShortcutFeedbackKind { volume, speed, seek }

class VideoShortcutFeedback {
  const VideoShortcutFeedback(this.kind, this.text);

  final VideoShortcutFeedbackKind kind;
  final String text;

  @override
  String toString() => '$kind: $text';
}

/// Turns [VideoIntent]s into [VideoPlaybackCommands] calls.
///
/// Pure Dart (no widgets) so the whole map — including clamps — is unit
/// testable. This is the same command layer the on-screen controls use: every
/// branch below calls a `VideoService` method, nothing else.
class VideoShortcutHandler {
  VideoShortcutHandler({
    required this.commands,
    required this.onNextEpisode,
    required this.onPreviousEpisode,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  static const double volumeStep = 0.05;
  static const double speedStep = 0.25;
  static const double minSpeed = 0.25;
  static const double maxSpeed = 2.0;

  /// Minimum spacing between two dispatches of the same *toggle* intent.
  ///
  /// A held key auto-repeats every ~30 ms (WP #116). Without this, holding
  /// Space would flip playback — and the controls fade — dozens of times a
  /// second. Directional intents (seek / volume / speed) are deliberately not
  /// guarded: repeating those is the expected behaviour.
  static const Duration repeatGuard = Duration(milliseconds: 250);

  final VideoPlaybackCommands commands;

  final DateTime Function() _now;
  final Map<Type, DateTime> _lastGuardedDispatch = {};

  /// Episode navigation lives on `VideoCubit`, not on the player: these advance
  /// the episode list, they do not touch the streaming server.
  final VoidCallback onNextEpisode;
  final VoidCallback onPreviousEpisode;

  /// Latest transient indicator, for the screen to render.
  final ValueNotifier<VideoShortcutFeedback?> feedback = ValueNotifier<VideoShortcutFeedback?>(null);

  double _lastAudibleVolume = 1.0;

  /// Dispatches [intent]; returns true when it did something.
  bool handle(VideoIntent intent) {
    switch (intent) {
      case TogglePlayIntent():
        if (!_acceptFirstInRepeatWindow(intent)) return false;
        commands.togglePlay();
        return true;
      case SeekByIntent(:final offset):
        _seekTo(commands.position + offset);
        _notify(VideoShortcutFeedbackKind.seek, _formatDelta(offset));
        return true;
      case SeekToPercentIntent(:final percent):
        _seekTo(commands.duration * percent);
        _notify(VideoShortcutFeedbackKind.seek, '${(percent * 100).round()}%');
        return true;
      case AdjustVolumeIntent(:final delta):
        _setVolume(commands.volume + delta);
        return true;
      case ToggleMuteIntent():
        if (!_acceptFirstInRepeatWindow(intent)) return false;
        if (commands.volume > 0) {
          _lastAudibleVolume = commands.volume;
          _setVolume(0);
        } else {
          _setVolume(_lastAudibleVolume > 0 ? _lastAudibleVolume : 1.0);
        }
        return true;
      case ToggleFullscreenIntent():
        if (!_acceptFirstInRepeatWindow(intent)) return false;
        commands.setFullscreen(!commands.isFullscreen);
        return true;
      case ExitFullscreenIntent():
        if (!commands.isFullscreen) return false;
        commands.setFullscreen(false);
        return true;
      case ToggleCaptionsIntent():
        if (!_acceptFirstInRepeatWindow(intent)) return false;
        return commands.toggleSubtitles();
      case AdjustSpeedIntent(:final delta):
        _setSpeed(commands.playbackSpeed + delta);
        return true;
      case NextEpisodeIntent():
        if (!_acceptFirstInRepeatWindow(intent)) return false;
        onNextEpisode();
        return true;
      case PreviousEpisodeIntent():
        if (!_acceptFirstInRepeatWindow(intent)) return false;
        onPreviousEpisode();
        return true;
    }
  }

  /// Coalesces keyboard auto-repeat for toggle intents: the first event in a
  /// [repeatGuard] window wins, later repeats of the same intent are dropped.
  bool _acceptFirstInRepeatWindow(VideoIntent intent) {
    final now = _now();
    final last = _lastGuardedDispatch[intent.runtimeType];
    if (last != null && now.difference(last) < repeatGuard) return false;
    _lastGuardedDispatch[intent.runtimeType] = now;
    return true;
  }

  void _seekTo(Duration target) {
    final duration = commands.duration;
    final max = duration > Duration.zero ? duration.inMilliseconds : target.inMilliseconds;
    final clamped = Duration(milliseconds: target.inMilliseconds.clamp(0, max));
    commands.seekTo(clamped);
  }

  void _setVolume(double volume) {
    final clamped = volume.clamp(0.0, 1.0);
    commands.setVolume(clamped);
    _notify(VideoShortcutFeedbackKind.volume, '${(clamped * 100).round()}%');
  }

  void _setSpeed(double speed) {
    final quantized = (speed / speedStep).round() * speedStep;
    final clamped = quantized.clamp(minSpeed, maxSpeed);
    commands.setPlaybackSpeed(clamped);
    _notify(VideoShortcutFeedbackKind.speed, '${clamped.toStringAsFixed(2)}x');
  }

  void _notify(VideoShortcutFeedbackKind kind, String text) {
    feedback.value = VideoShortcutFeedback(kind, text);
  }

  void dispose() {
    feedback.dispose();
  }

  static String _formatDelta(Duration offset) {
    final seconds = offset.inSeconds;
    return seconds >= 0 ? '+${seconds}s' : '${seconds}s';
  }
}

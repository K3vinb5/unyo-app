// External dependencies
import 'dart:io';

// Internal dependencies
import 'package:unyo/core/services/media/audio_service_playback_session.dart';

/// What the player is doing, as far as the OS media controls are concerned.
///
/// Deliberately coarse: MPRIS clients only distinguish Playing/Paused/Stopped,
/// and audio_service's `AudioProcessingState` covers the rest. Position is
/// *projected* by the client from `position` + `speed`, so the app never has to
/// broadcast per tick.
enum PlaybackStatus { playing, paused, buffering, stopped }

/// One immutable snapshot of the player, emitted by `VideoService` on
/// play/pause/buffer/seek/speed transitions — never per tick.
class PlaybackSnapshot {
  const PlaybackSnapshot({
    required this.status,
    required this.position,
    this.speed = 1.0,
  });

  final PlaybackStatus status;
  final Duration position;
  final double speed;

  @override
  String toString() => 'PlaybackSnapshot(status: $status, position: $position, speed: $speed)';
}

/// The track metadata the OS media controls display.
class PlaybackMetadata {
  const PlaybackMetadata({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.artUri,
    this.duration,
  });

  /// Stable identity of the playing item (changes with the episode, so clients
  /// can tell a track change from a property change).
  final String id;

  /// e.g. `Episode 3`.
  final String title;

  /// Anime title.
  final String artist;

  /// Anime title again — MPRIS exposes `xesam:album`, and there is no album.
  final String? album;

  /// Cover image, published as `mpris:artUrl`.
  final Uri? artUri;

  /// Episode duration, published as `mpris:length`. Null until the player knows.
  final Duration? duration;

  PlaybackMetadata copyWithDuration(Duration? duration) => PlaybackMetadata(
    id: id,
    title: title,
    artist: artist,
    album: album,
    artUri: artUri,
    duration: duration,
  );
}

/// Commands the OS media controls (MPRIS on Linux, Now Playing on macOS, SMTC
/// on Windows once WP-98B lands) can send back into the app.
abstract class PlaybackCommandHandler {
  Future<void> onPlay();
  Future<void> onPause();
  Future<void> onTogglePlayPause();
  Future<void> onSeek(Duration position);
  Future<void> onStop();
  Future<void> onNext();
  Future<void> onPrevious();
}

/// The single seam between the app and the OS media integration.
///
/// `VideoCubit` owns one instance for the lifetime of the video screen and
/// talks only to this interface, so no package type (audio_service, MPRIS,
/// SMTC) leaks into widgets or `VideoService`.
abstract class PlaybackSession {
  /// Registers the command sink and makes the session visible to the OS.
  Future<void> activate(PlaybackCommandHandler commands);

  /// Publishes title/episode/cover/duration. Called on media load and on
  /// episode change (and once more when the duration becomes known).
  Future<void> publishMetadata(PlaybackMetadata metadata);

  /// Publishes a state transition. Must not be called per tick.
  Future<void> publishState({
    required PlaybackStatus status,
    required Duration position,
    double speed = 1.0,
  });

  /// Tears the session down; the player disappears from the OS media controls.
  Future<void> deactivate();

  bool get isActive;
}

/// Session used on platforms with no OS media integration wired up yet
/// (Windows: `smtc_windows` is a follow-up WP, see WP #98).
class NoopPlaybackSession implements PlaybackSession {
  bool _active = false;

  @override
  bool get isActive => _active;

  @override
  Future<void> activate(PlaybackCommandHandler commands) async {
    _active = true;
  }

  @override
  Future<void> publishMetadata(PlaybackMetadata metadata) async {}

  @override
  Future<void> publishState({
    required PlaybackStatus status,
    required Duration position,
    double speed = 1.0,
  }) async {}

  @override
  Future<void> deactivate() async {
    _active = false;
  }
}

/// Builds the platform-appropriate session.
///
/// Linux gets audio_service with the D-Bus MPRIS backend (registered in
/// `main.dart` before `runApp`), macOS gets plain audio_service Now Playing,
/// Windows has none yet.
PlaybackSession createPlaybackSession() {
  if (Platform.isLinux || Platform.isMacOS) {
    return AudioServicePlaybackSession();
  }
  return NoopPlaybackSession();
}

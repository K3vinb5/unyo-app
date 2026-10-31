// External dependencies
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_service_platform_interface/audio_service_platform_interface.dart'
    show AudioServicePlatform, StopServiceRequest;

// Internal dependencies
import 'package:unyo/core/services/media/playback_session.dart';

/// `audio_service` adapter: MPRIS on Linux (the `audio_service_mpris` platform
/// implementation registered in `main.dart`) and Now Playing on macOS.
///
/// This is the only file allowed to know about audio_service types.
class AudioServicePlaybackSession implements PlaybackSession {
  static UnyoMediaHandler? _handler;

  bool _active = false;

  @override
  bool get isActive => _active;

  @override
  Future<void> activate(PlaybackCommandHandler commands) async {
    _active = true;
    // AudioService.init can only run once per process: it owns a single
    // platform session. The video screen comes and goes, so the handler is
    // created on first activation and reused for later episodes/screens.
    _handler ??= await AudioService.init(
      builder: UnyoMediaHandler.new,
      config: const AudioServiceConfig(
        // On Linux this doubles as the MPRIS bus-name element
        // (`org.mpris.MediaPlayer2.unyo.instance<pid>`) and, via the name
        // below, the Identity. `playerctl -p unyo` matches the bus name by
        // suffix, so this must stay exactly "unyo".
        androidNotificationChannelId: 'unyo',
        androidNotificationChannelName: 'Unyo',
        androidNotificationOngoing: true,
        fastForwardInterval: Duration(seconds: 10),
        rewindInterval: Duration(seconds: 10),
      ),
    );
    _handler!.commands = commands;
  }

  @override
  Future<void> publishMetadata(PlaybackMetadata metadata) async {
    final handler = _handler;
    if (!_active || handler == null) return;
    handler.mediaItem.add(
      MediaItem(
        id: metadata.id,
        title: metadata.title,
        artist: metadata.artist,
        album: metadata.album,
        artUri: metadata.artUri,
        duration: metadata.duration,
      ),
    );
  }

  @override
  Future<void> publishState({
    required PlaybackStatus status,
    required Duration position,
    double speed = 1.0,
  }) async {
    final handler = _handler;
    if (!_active || handler == null) return;
    final playing = status == PlaybackStatus.playing;
    handler.playbackState.add(
      handler.playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: const [0, 1, 2],
        // MPRIS has no `Seek` equivalent in audio_service (documented gap), but
        // `SetPosition` works and maps to this action.
        systemActions: const {MediaAction.seek},
        processingState: switch (status) {
          PlaybackStatus.buffering => AudioProcessingState.buffering,
          PlaybackStatus.stopped => AudioProcessingState.idle,
          PlaybackStatus.playing || PlaybackStatus.paused => AudioProcessingState.ready,
        },
        playing: playing,
        updatePosition: position,
        speed: speed,
      ),
    );
  }

  @override
  Future<void> deactivate() async {
    _active = false;
    _handler?.commands = null;
    _handler?.mediaItem.add(null);
    // audio_service only calls `stopService` when an Android service dies, so
    // on Linux the MPRIS object would stay "Paused" forever after leaving the
    // video screen. Ask the platform directly: it flips PlaybackStatus to
    // `Stopped`, which is what makes the player drop out of media widgets.
    if (Platform.isLinux) {
      await AudioServicePlatform.instance.stopService(const StopServiceRequest());
    }
  }
}

/// AudioHandler the platform layer drives. Every method forwards to the active
/// [PlaybackCommandHandler]; with no video screen open the commands are null
/// and the calls are ignored.
class UnyoMediaHandler extends BaseAudioHandler {
  PlaybackCommandHandler? commands;

  @override
  Future<void> play() async => commands?.onPlay();

  @override
  Future<void> pause() async => commands?.onPause();

  @override
  Future<void> seek(Duration position) async => commands?.onSeek(position);

  @override
  Future<void> skipToNext() async => commands?.onNext();

  @override
  Future<void> skipToPrevious() async => commands?.onPrevious();

  @override
  Future<void> stop() async => commands?.onStop();
}

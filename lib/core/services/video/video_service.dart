// External dependencies
import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:fvp/mdk.dart' as mdk;
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/domain/entities/extension/headers.dart' as ext;
import 'package:unyo/domain/entities/extension/track.dart' as ext;
import 'package:unyo/domain/entities/extension/video.dart' as ext;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/media/playback_session.dart';
import 'package:unyo/core/services/torrent/torrent_service.dart';
import 'package:unyo/core/services/video/video_playback_commands.dart';
import 'package:unyo/domain/entities/torrent/torrent_file_stat.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';

class VideoService implements VideoPlaybackCommands {
  // Services
  final Logger _logger = sl<Logger>();
  final TorrentService _torrentService = sl<TorrentService>();
  final Set<String> _torrentHashes = {};

  ext.Video _video;
  List<ext.Video> _alternativeVideos;
  int _videoIndex;
  int _episodeIndex; // This will be used for getting the correct video out of a playlist from a magnet / torrent
  final void Function(String) _onErrorCallback;

  late final mdk.Player _player;
  final List<ext.Track> subtitleTracks = [];
  final List<ext.Track> audioTracks = [];
  ext.Track? _currentSubtitleTrack;
  ext.Track? _currentAudioTrack;
  int _lastSubtitleIndex = 0;

  late bool _initialFullscreen;
  late bool _isFullscreen;
  bool _isVideoReady = false;
  bool _isBuffering = true;
  bool _isLoading = false;
  bool _isDisposed = false;
  StreamSubscription<({mdk.MediaStatus oldValue, mdk.MediaStatus newValue})>?
  _mediaStatusSubscription;
  /// Playback transitions for the OS media session. Broadcasts on
  /// play/pause/seek/speed/buffer changes only — never per tick.
  final StreamController<PlaybackSnapshot> _playbackEvents =
      StreamController<PlaybackSnapshot>.broadcast();
  static const mdk.SeekFlag _seekFlags = mdk.SeekFlag(
    mdk.SeekFlag.fromStart | mdk.SeekFlag.inCache | mdk.SeekFlag.fast,
  );

  VideoService({
    required ext.Video video,
    required List<ext.Video> alternativeVideos,
    required int videoIndex,
    required int episodeIndex,
    required void Function(String) onErrorCallback,
  }) : _episodeIndex = episodeIndex,
       _videoIndex = videoIndex,
       _video = video,
       _alternativeVideos = alternativeVideos,
       _onErrorCallback = onErrorCallback {
    _player = mdk.Player();
    _configureDecoder();
    _configurePlayer();
    _setPlayerHttpHeaders(_video.headers);
    _initAsync();
  }

  /// Inits asynchronous properties and sets player media
  Future<void> _initAsync() async {
    _initialFullscreen = await windowManager.isFullScreen();
    _isFullscreen = _initialFullscreen;
    _mediaStatusSubscription = _player.onMediaStatus.listen(
      (event) => _onMediaStatusInit(event.oldValue, event.newValue),
    );
    try {
      final resolvedUrl = await _resolveVideoUrl(_video.videoUrl);
      _player.media = resolvedUrl;
      await _player.prepare();
    } catch (e, st) {
      _logger.e("Failed to resolve video URL in _initAsync", error: e, stackTrace: st);
      _onErrorCallback(e.toString());
    }
    _player.loop = 0;
  }

  Future<void> changeVideo({
    required ext.Video video,
    required List<ext.Video> alternativeVideos,
    required int videoIndex,
    required int episodeIndex,
  }) async {
    _attemptDisposeTorrent();
    _video = video;
    _alternativeVideos = alternativeVideos;
    _videoIndex = videoIndex;
    _episodeIndex = episodeIndex;
    _isVideoReady = false;
    _isBuffering = true;
    _emitPlaybackState();
    try {
      final resolvedUrl = await _resolveVideoUrl(_video.videoUrl);
      _player.media = resolvedUrl;
      await _player.prepare();
    } catch (e, st) {
      _logger.e("Failed to resolve video URL on change", error: e, stackTrace: st);
      _onErrorCallback(e.toString());
    }
  }

  // Getters
  @override
  Duration get position => Duration(milliseconds: _player.position);

  String get formattedPosition => TextUtils.formatMilliseconds(position.inMilliseconds);

  ValueNotifier<int?> get textureId => _player.textureId;

  @override
  Duration get duration => Duration(milliseconds: _player.mediaInfo.duration);

  double get percentagePlayed => (position.inMilliseconds / duration.inMilliseconds);

  @override
  double get volume => _player.volume;

  @override
  bool get isPlaying => _player.state == mdk.PlaybackState.playing;

  bool get isBuffering => _isBuffering;

  bool get isLoading => _isLoading;

  @override
  bool get isFullscreen => _isFullscreen;

  bool get isVideoReady => _isVideoReady;

  Stream<PlaybackSnapshot> get playbackEvents => _playbackEvents.stream;

  @override
  double get playbackSpeed => _player.playbackRate;

  @override
  bool get subtitlesEnabled => _currentSubtitleTrack != null;

  double get aspectRatio {
    final streams = _player.mediaInfo.video;
    if (streams != null && streams.isNotEmpty) {
      final codec = streams.first.codec;
      return codec.width / codec.height;
    }
    return -1;
  }

  List<ext.Track> get subtitles => subtitleTracks;

  List<ext.Track> get audios => audioTracks;

  int get videoIndex => _videoIndex;

  // Setters
  @override
  bool play() {
    if (_isBuffering) return false;
    _player.state = mdk.PlaybackState.playing;
    _emitPlaybackState();
    return true;
  }

  @override
  bool pause() {
    if (_isBuffering) return false;
    _player.state = mdk.PlaybackState.paused;
    _emitPlaybackState();
    return true;
  }

  @override
  bool togglePlay() {
    if (_isBuffering) return false;
    if (isPlaying) {
      pause();
    } else {
      play();
    }
    return true;
  }

  bool setLooping(bool loop) {
    loop ? _player.loop = -1 : _player.loop = 0;
    return true;
  }

  @override
  bool setVolume(double volume) {
    _player.volume = volume;
    return true;
  }

  @override
  bool setPlaybackSpeed(double newPlayBackSpeed) {
    _player.playbackRate = newPlayBackSpeed;
    _emitPlaybackState();
    return true;
  }

  @override
  bool seekTo(Duration newPosition) {
    final clamped = Duration(
      milliseconds: newPosition.inMilliseconds.clamp(0, duration.inMilliseconds),
    );
    _player.seek(position: clamped.inMilliseconds, flags: _seekFlags);
    _emitPlaybackState(position: clamped);
    return true;
  }

  bool reverse(Duration reverseDuration) {
    return seekTo(Duration(milliseconds: position.inMilliseconds - reverseDuration.inMilliseconds));
  }

  bool forward(Duration forwardDuration) {
    return seekTo(Duration(milliseconds: position.inMilliseconds + forwardDuration.inMilliseconds));
  }

  bool setSubtitleOffset(Duration duration) {
    return false;
  }

  bool resetService() {
    _player.state = mdk.PlaybackState.paused;
    _isBuffering = true;
    _isVideoReady = false;
    _isBuffering = true;
    _isLoading = false;
    _emitPlaybackState();
    return true;
  }

  Future<void> swapVideoUrl(int index) async {
    if (index < 0 || index >= _alternativeVideos.length) {
      return;
    }
    pause();
    ext.Video video = _alternativeVideos[index];
    _videoIndex = index;
    _video = video;
    final position = this.position;
    _isVideoReady = false;
    _isBuffering = true;
    try {
      final resolvedUrl = await _resolveVideoUrl(video.videoUrl);
      _player.media = resolvedUrl;
      await _player.prepare();
    } catch (e, st) {
      _logger.e("Failed to resolve video URL on swap", error: e, stackTrace: st);
      _onErrorCallback(e.toString());
      return;
    }
    await _player.seek(position: position.inMilliseconds, flags: _seekFlags);
    play();
  }

  bool setSubtitle(int subtitleIndex) {
    if (subtitleIndex < 0 || subtitleIndex >= subtitleTracks.length) {
      _currentSubtitleTrack = null;
      return false;
    }
    _lastSubtitleIndex = subtitleIndex;
    _currentSubtitleTrack = subtitleTracks[subtitleIndex];
    if (_currentSubtitleTrack != null && _currentSubtitleTrack!.embedded) {
      _player.activeSubtitleTracks = [_currentSubtitleTrack!.embeddedIndex];
    } else {
      _player.setMedia(_currentSubtitleTrack!.url, mdk.MediaType.subtitle);
    }
    return true;
  }

  /// Captions toggle (`C`): off when a track is active, back to the last
  /// picked track otherwise (first track when nothing was picked yet).
  @override
  bool toggleSubtitles() {
    if (subtitleTracks.isEmpty) return false;
    if (subtitlesEnabled) return setSubtitle(-1);
    return setSubtitle(_lastSubtitleIndex.clamp(0, subtitleTracks.length - 1));
  }

  bool setAudioTrack(int audioTrackIndex) {
    if (audioTrackIndex < 0 || audioTrackIndex >= audioTracks.length) {
      _currentAudioTrack = null;
      return false;
    }
    _currentAudioTrack = audioTracks[audioTrackIndex];
    if (_currentAudioTrack != null && _currentAudioTrack!.embedded) {
      _player.activeAudioTracks = [_currentAudioTrack!.embeddedIndex];
    } else {
      _player.setMedia(_currentAudioTrack!.url, mdk.MediaType.audio);
    }
    return true;
  }

  @override
  bool setFullscreen(bool fullscreen) {
    _isFullscreen = fullscreen;
    windowManager.setFullScreen(fullscreen);
    return true;
  }

  bool setPreventSleep(bool preventSleep) {
    WakelockPlus.toggle(enable: preventSleep);
    return true;
  }

  bool updateTexture() {
    _player.updateTexture();
    return true;
  }

  void dispose() {
    _isDisposed = true;
    _emitPlaybackState();
    _playbackEvents.close();
    _mediaStatusSubscription?.cancel();
    setFullscreen(_initialFullscreen);
    _player.dispose();
    _attemptDisposeTorrent();
  }

  // Magnet / Torrent resolution
  Future<String> _resolveVideoUrl(String url) async {
    if (!url.toLowerCase().startsWith("magnet:")) {
      return url;
    }
    final cleanMagnet = _cleanMagnetUrl(url);
    final hash = _extractHashFromMagnet(cleanMagnet);
    final status = await _torrentService.addTorrent(cleanMagnet);
    _torrentHashes.add(status.hash);
    if (status.stat >= 2 && status.fileStats.isNotEmpty) {
      final fileIndex = _selectFileIndex(status.fileStats, _episodeIndex);
      return _torrentService.getStreamUrl(hash, fileIndex);
    }
    _logger.w("No metadata available, streaming with fallback index $_episodeIndex");
    return _torrentService.getStreamUrl(hash, _episodeIndex);
  }

  int _selectFileIndex(List<TorrentFileStat> files, int episodeIndex) {
    if (files.isEmpty) return 0;
    if (files.length == 1) return files.first.id;

    // Strategy 1: Fuzzy match filename against episode patterns
    final patterns = [
      "episode $episodeIndex",
      "e$episodeIndex",
      "ep$episodeIndex",
      episodeIndex.toString().padLeft(2, '0'),
    ];
    final List<(int, TorrentFileStat)> allScores = [];
    for (final pattern in patterns) {
      for (final file in files) {
        final fileName = file.path.toLowerCase();
        final score = tokenSortRatio(pattern, fileName);
        allScores.add((score, file));
      }
    }
    allScores.sort((a, b) => b.$1.compareTo(a.$1));
    if (allScores.isNotEmpty && allScores.first.$1 > 60) {
      return allScores.first.$2.id;
    }

    // Strategy 2: Direct id match with episode index
    final directMatch = files.firstWhereOrNull((f) => f.id == episodeIndex);
    if (directMatch != null) return directMatch.id;

    // Strategy 3: Fallback to first file
    return files.first.id;
  }

  /// Removes non-standard query parameters
  String _cleanMagnetUrl(String magnet) {
    try {
      final uri = Uri.parse(magnet);
      final standardParams = ['xt', 'dn', 'tr', 'ws', 'xs', 'as', 'mt', 'kt'];
      final cleanedQuery = Map<String, List<String>>.fromEntries(
        uri.queryParametersAll.entries.where((e) => standardParams.contains(e.key.toLowerCase())),
      );
      final cleanedUri = uri.replace(queryParameters: cleanedQuery.isEmpty ? null : cleanedQuery);
      return cleanedUri.toString();
    } catch (e) {
      return magnet;
    }
  }

  String _extractHashFromMagnet(String magnet) {
    try {
      final uri = Uri.parse(magnet);
      final xt = uri.queryParameters['xt'];
      if (xt != null && xt.startsWith("urn:btih:")) {
        return xt.substring("urn:btih:".length).toLowerCase();
      }
    } catch (e) {
      _logger.w("Failed to parse magnet URI: $e");
    }
    // Fallback: try to extract 40-char hex hash from the string
    final hexHashMatch = RegExp(r'([0-9a-fA-F]{40})').firstMatch(magnet);
    if (hexHashMatch != null) {
      return hexHashMatch.group(1)!.toLowerCase();
    }
    _logger.e("Could not extract infohash from magnet URI");
    throw Exception("Could not extract infohash from magnet URI");
  }

  void _attemptDisposeTorrent() {
    for (final hash in _torrentHashes) {
      _torrentService.removeTorrent(hash);
    }
    _torrentHashes.clear();
  }

  void _configureDecoder() {
    final vd = {
      'windows': ['MFT:d3d=11', "D3D11", "DXVA", 'CUDA', 'hap', 'FFmpeg', 'dav1d'],
      'macos': ['VT', 'hap', 'FFmpeg', 'dav1d'],
      'linux': ['VAAPI', 'CUDA', 'VDPAU', 'hap', 'FFmpeg', 'dav1d'],
    };
    _player.setDecoders(mdk.MediaType.video, vd[Platform.operatingSystem]!);
  }

  void _configurePlayer() {
    _player.setProperty(
      'avio.protocol_whitelist',
      'file,ftp,rtmp,http,https,tls,rtp,tcp,udp,crypto,httpproxy,data,concatf,concat,subfile',
    );
    // Not sure about this flags, if I ever detect an issue I'll consider enabling them
    // _player.setProperty('video.decoder', 'shader_resource=0');
    // _player.setProperty('sub.ass.font_fallback', '1');
    _player.setProperty('avformat.strict', 'experimental');
    _player.setProperty('avformat.safe', '0');
    _player.setProperty('avio.reconnect', '1');
    _player.setProperty('avio.reconnect_delay_max', '7');
    _player.setProperty('avformat.rtsp_transport', 'tcp');
    _player.setProperty('avformat.extension_picky', '0');
    _player.setProperty('avformat.allowed_segment_extensions', 'ALL');
    _player.setBufferRange(min: 3500, max: 15000, drop: false);
  }

  void _setPlayerHttpHeaders(ext.Headers? headers) {
    if (headers == null || headers.headersMap.isEmpty) return;
    final userAgent = headers.headersMap.entries
        .firstWhere((e) => e.key.toLowerCase() == 'user-agent', orElse: () => const MapEntry('', ''))
        .value;

    if (userAgent.isNotEmpty) {
      _player.setProperty('user_agent', userAgent);
    }
    final formattedHeaders = headers.headersMap.entries
        .map((e) {
          // Fix cookie separator logic (HTTP spec requires '; ' not ',')
          final value = e.key.toLowerCase() == 'cookie' ? e.value.replaceAll(',', '; ') : e.value;
          return '${e.key}: $value';
        })
        .join('\r\n'); // Join with CRLF

    if (formattedHeaders.isNotEmpty) {
      _player.setProperty('headers', formattedHeaders);
      _player.setProperty('avio.headers', formattedHeaders);
    }
  }

  void _setPlayerLogsHandler() {
    mdk.setLogHandler((mdk.LogLevel level, String message) {
      if (!message.contains("unloaded media's position")) {
        switch (level) {
          case mdk.LogLevel.debug:
          // _logger.d("MDK Log: $message");
          case mdk.LogLevel.info:
          // _logger.i("MDK Log: $message");
          case mdk.LogLevel.warning:
          // _logger.w("MDK Log: $message");
          case mdk.LogLevel.error:
            _logger.e("MDK Log: $message");
          case mdk.LogLevel.off:
            break;
          case mdk.LogLevel.all:
            break;
        }
      }
    });
  }

  bool _onMediaStatusInit(mdk.MediaStatus oldStatus, mdk.MediaStatus newStatus) {
    if (_isDisposed) return false;

    if (newStatus.test(mdk.MediaStatus.loaded) && !_isVideoReady) {
      _initSubtitlesAndAudiotracks();
      _player.state = mdk.PlaybackState.playing;
      setVolume(1.0);
      _isVideoReady = true;
    }
    if (newStatus.test(mdk.MediaStatus.loaded) && _isVideoReady) {
      _isLoading = false;
    }
    if (newStatus.test(mdk.MediaStatus.loading)) {
      _isLoading = true;
    }
    if (newStatus.test(mdk.MediaStatus.buffering)) {
      _isBuffering = true;
    }
    if (newStatus.test(mdk.MediaStatus.buffered)) {
      _isBuffering = false;
    }
    if (newStatus.test(mdk.MediaStatus.invalid)) {
      if (!_isDisposed) {
        _onErrorCallback("Failed to load media. Please try again later.");
      }
      return false;
    }
    _emitPlaybackState();
    return true;
  }

  PlaybackStatus get _playbackStatus {
    if (_isDisposed) return PlaybackStatus.stopped;
    if (!_isVideoReady || _isBuffering) return PlaybackStatus.buffering;
    return isPlaying ? PlaybackStatus.playing : PlaybackStatus.paused;
  }

  void _emitPlaybackState({Duration? position}) {
    if (_playbackEvents.isClosed) return;
    _playbackEvents.add(
      PlaybackSnapshot(
        status: _playbackStatus,
        position: position ?? this.position,
        speed: _player.playbackRate,
      ),
    );
  }

  void _initSubtitlesAndAudiotracks() {
    subtitleTracks.clear();
    audioTracks.clear();
    int index = 0;
    if (_player.mediaInfo.subtitle != null && _player.mediaInfo.subtitle!.isNotEmpty) {
      for (mdk.SubtitleStreamInfo subtitleStreamInfo in _player.mediaInfo.subtitle!) {
        subtitleTracks.add(
          ext.Track(
            url: "",
            lang:
                "${subtitleStreamInfo.metadata["title"] ?? ""} (${subtitleStreamInfo.metadata["language"]} - Embedded)",
            embedded: true,
            embeddedIndex: index++,
          ),
        );
      }
    }
    subtitleTracks.addAll(_video.subtitleTracks);
    if (subtitleTracks.isNotEmpty) {
      setSubtitle(0);
    }
    index = 0;
    if (_player.mediaInfo.audio != null && _player.mediaInfo.audio!.length > 1) {
      for (mdk.AudioStreamInfo audioStreamInfo in _player.mediaInfo.audio!) {
        audioTracks.add(
          ext.Track(
            url: "",
            lang:
                "${audioStreamInfo.metadata["title"] ?? ""} (${audioStreamInfo.metadata["language"]} - Embedded)",
            embedded: true,
            embeddedIndex: index++,
          ),
        );
      }
    }
    audioTracks.addAll(_video.audioTracks);
    if (audioTracks.isNotEmpty) {
      setAudioTrack(0);
    }
  }
}

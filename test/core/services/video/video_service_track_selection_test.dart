// External dependencies
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fvp/mdk.dart' as mdk;
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/services/torrent/torrent_service.dart';
import 'package:unyo/core/services/video/video_service.dart';
import 'package:unyo/domain/entities/extension/track.dart' as track;
import 'package:unyo/domain/entities/extension/video.dart' as video;

class FakeTorrentService implements TorrentService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Records everything [VideoService] pushes into the player instead of talking
/// to libmdk. Unimplemented members are forwarded to [noSuchMethod] and return
/// null, which is enough for this test surface.
class FakePlayer implements mdk.Player {
  final List<List<int>> subtitleTrackWrites = [];
  final List<List<int>> audioTrackWrites = [];
  final List<({String uri, mdk.MediaType type})> externalMedia = [];
  final Map<String, String> properties = {};
  /// Ordered trace of the subtitle-affecting player writes, e.g. `sid=no`
  /// followed by `activeSubtitleTracks=[]`.
  final List<String> subtitleWrites = [];
  final StreamController<({mdk.MediaStatus oldValue, mdk.MediaStatus newValue})>
  mediaStatusController = StreamController<
    ({mdk.MediaStatus oldValue, mdk.MediaStatus newValue})
  >.broadcast();

  @override
  mdk.MediaInfo mediaInfo = mdk.MediaInfo();

  List<int> _activeSubtitleTracks = [];
  List<int> _activeAudioTracks = [];

  @override
  List<int> get activeSubtitleTracks => _activeSubtitleTracks;

  @override
  set activeSubtitleTracks(List<int> value) {
    _activeSubtitleTracks = value;
    subtitleTrackWrites.add(value);
    subtitleWrites.add('activeSubtitleTracks=$value');
  }

  @override
  void setProperty(String name, String value) {
    properties[name] = value;
    if (name == 'sid' || name == 'subtitle') {
      subtitleWrites.add('$name=$value');
    }
  }

  @override
  String? getProperty(String name) => properties[name];

  @override
  List<int> get activeAudioTracks => _activeAudioTracks;

  @override
  set activeAudioTracks(List<int> value) {
    _activeAudioTracks = value;
    audioTrackWrites.add(value);
  }

  @override
  void setMedia(String uri, mdk.MediaType type) {
    externalMedia.add((uri: uri, type: type));
  }

  @override
  Stream<({mdk.MediaStatus oldValue, mdk.MediaStatus newValue})>
  get onMediaStatus => mediaStatusController.stream;

  @override
  set media(String value) {}

  @override
  int position = 0;

  @override
  Future<int> seek({
    required int position,
    mdk.SeekFlag flags = const mdk.SeekFlag(mdk.SeekFlag.defaultFlags),
  }) async => 0;

  @override
  Future<int> prepare({
    int position = 0,
    mdk.SeekFlag flags = const mdk.SeekFlag(mdk.SeekFlag.defaultFlags),
    Future<bool> Function()? callback,
    bool reply = false,
  }) async => 1;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  /// Emits the "media loaded" status [VideoService] reacts to.
  void emitLoaded() {
    mediaStatusController.add((
      oldValue: const mdk.MediaStatus(mdk.MediaStatus.loading),
      newValue: const mdk.MediaStatus(mdk.MediaStatus.loaded),
    ));
  }
}

video.Video testVideo({
  List<track.Track> subtitleTracks = const [],
  List<track.Track> audioTracks = const [],
}) {
  return video.Video(
    url: 'test',
    title: 'Test',
    quality: '1080p',
    videoUrl: 'https://example.com/video.m3u8',
    headers: null,
    initialized: true,
    audioTracks: audioTracks,
    subtitleTracks: subtitleTracks,
    bitrate: null,
    resolution: null,
  );
}

void main() {
  late FakePlayer player;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<Logger>()) {
      getIt.registerSingleton<Logger>(Logger(level: Level.off));
    }
    if (!getIt.isRegistered<TorrentService>()) {
      getIt.registerSingleton<TorrentService>(FakeTorrentService());
    }
  });

  setUp(() {
    player = FakePlayer();
  });

  tearDown(() async {
    await player.mediaStatusController.close();
  });

  VideoService buildService(video.Video media, {int alternatives = 1}) =>
      VideoService(
        video: media,
        alternativeVideos: List.filled(alternatives, media),
        videoIndex: 0,
        episodeIndex: 0,
        onErrorCallback: (_) {},
        player: player,
      );

  Future<VideoService> buildLoadedService(
    video.Video media, {
    int alternatives = 1,
  }) async {
    final service = buildService(media, alternatives: alternatives);
    player.emitLoaded();
    await Future<void>.delayed(Duration.zero);
    return service;
  }

  void twoEmbeddedSubtitles() {
    player.mediaInfo.subtitle = [
      mdk.SubtitleStreamInfo()..metadata = {'title': 'English', 'language': 'eng'},
      mdk.SubtitleStreamInfo()..metadata = {'title': 'French', 'language': 'fra'},
    ];
  }

  void twoEmbeddedAudios() {
    player.mediaInfo.audio = [
      mdk.AudioStreamInfo()..metadata = {'title': 'Japanese', 'language': 'jpn'},
      mdk.AudioStreamInfo()..metadata = {'title': 'English', 'language': 'eng'},
    ];
  }

  group('subtitle selection', () {
    test('load auto-selects the first track', () async {
      twoEmbeddedSubtitles();
      final VideoService service = await buildLoadedService(testVideo());

      expect(service.subtitles, hasLength(2));
      expect(service.subtitleIndex, 0);
      expect(service.areSubtitlesDisabled, isFalse);
      expect(player.activeSubtitleTracks, [0]);
    });

    test('an embedded index activates that track', () async {
      twoEmbeddedSubtitles();
      final VideoService service = await buildLoadedService(testVideo());

      expect(service.setSubtitle(1), isTrue);
      expect(service.subtitleIndex, 1);
      expect(player.activeSubtitleTracks, [1]);
    });

    test('-1 disables subtitles and reports the disabled state', () async {
      twoEmbeddedSubtitles();
      final VideoService service = await buildLoadedService(testVideo());

      player.subtitleWrites.clear();
      expect(service.setSubtitle(-1), isTrue);
      expect(service.areSubtitlesDisabled, isTrue);
      expect(service.subtitleIndex, -1);
      // `subtitle=0` is what actually stops the rendering on the real player:
      // neither an empty active track set nor `sid=no` alone cleared an attached
      // .vtt (both verified live, text kept drawing on a paused frame).
      expect(player.properties['subtitle'], '0');
      expect(player.properties['sid'], 'no');
      expect(player.subtitleWrites, [
        'subtitle=0',
        'sid=no',
        'activeSubtitleTracks=[]',
      ]);
      expect(player.activeSubtitleTracks, isEmpty);
    });

    test('selecting a track again after "No subtitles" re-enables it', () async {
      twoEmbeddedSubtitles();
      final VideoService service = await buildLoadedService(testVideo());

      expect(service.setSubtitle(-1), isTrue);
      expect(player.activeSubtitleTracks, isEmpty);

      expect(service.setSubtitle(1), isTrue);
      expect(service.areSubtitlesDisabled, isFalse);
      expect(service.subtitleIndex, 1);
      expect(player.activeSubtitleTracks, [1]);
      // Rendering must be turned back on, otherwise the track decodes invisibly.
      expect(player.properties['subtitle'], '1');
    });

    test('-1 works with no subtitle tracks at all', () async {
      final VideoService service = await buildLoadedService(testVideo());

      expect(service.subtitles, isEmpty);
      expect(service.setSubtitle(-1), isTrue);
      expect(service.areSubtitlesDisabled, isTrue);
      expect(player.properties['subtitle'], '0');
      expect(player.properties['sid'], 'no');
    });

    test('an out of range index is rejected and keeps the selection', () async {
      twoEmbeddedSubtitles();
      final VideoService service = await buildLoadedService(testVideo());

      expect(service.setSubtitle(5), isFalse);
      expect(service.subtitleIndex, 0);
    });

    test('a re-init keeps the user\'s "No subtitles" choice', () async {
      twoEmbeddedSubtitles();
      final VideoService service = await buildLoadedService(testVideo(), alternatives: 2);
      service.setSubtitle(-1);

      // Swapping the server reloads the media without a new changeVideo: the
      // explicit "No subtitles" choice must survive the reload.
      await service.swapVideoUrl(1);
      player.emitLoaded();
      await Future<void>.delayed(Duration.zero);

      expect(service.subtitles, hasLength(2));
      expect(service.areSubtitlesDisabled, isTrue);
      expect(player.activeSubtitleTracks, isEmpty);
      expect(player.properties['subtitle'], '0');
      expect(player.properties['sid'], 'no');
    });

    test('a media change resets the disabled state and auto-selects again', () async {
      twoEmbeddedSubtitles();
      final VideoService service = await buildLoadedService(testVideo());
      service.setSubtitle(-1);

      await service.changeVideo(
        video: testVideo(),
        alternativeVideos: [testVideo()],
        videoIndex: 0,
        episodeIndex: 1,
      );

      player.emitLoaded();
      await Future<void>.delayed(Duration.zero);

      expect(service.areSubtitlesDisabled, isFalse);
      expect(service.subtitleIndex, 0);
      expect(player.activeSubtitleTracks, [0]);
    });
  });

  group('audio selection', () {
    test('2+ tracks auto-select the first one', () async {
      twoEmbeddedAudios();
      final VideoService service = await buildLoadedService(testVideo());

      expect(service.audios, hasLength(2));
      expect(service.audioIndex, 0);
      expect(player.activeAudioTracks, [0]);
    });

    test('-1 restores the default track instead of muting', () async {
      twoEmbeddedAudios();
      final VideoService service = await buildLoadedService(testVideo());
      service.setAudioTrack(1);
      expect(player.activeAudioTracks, [1]);

      expect(service.setAudioTrack(-1), isTrue);
      expect(service.audioIndex, -1);
      // An empty active audio set would DISABLE all audio tracks in MDK, so the
      // default must resolve to the track auto-selection would pick.
      expect(player.activeAudioTracks, isNot(isEmpty));
      expect(player.activeAudioTracks, [0]);
    });

    test('a single external audio source is still attached on load', () async {
      final VideoService service = await buildLoadedService(
        testVideo(
          audioTracks: const [
            track.Track(url: 'https://example.com/audio.m4a', lang: 'Japanese', embedded: false, embeddedIndex: -1),
          ],
        ),
      );

      expect(service.audios, hasLength(1));
      // The menu collapses this into "Default audio", but initialization still
      // attaches the only available source.
      expect(service.audioIndex, 0);
      expect(
        player.externalMedia.where((m) => m.type == mdk.MediaType.audio).map((m) => m.uri),
        contains('https://example.com/audio.m4a'),
      );
    });

    test('an explicit index activates that track', () async {
      twoEmbeddedAudios();
      final VideoService service = await buildLoadedService(testVideo());

      expect(service.setAudioTrack(1), isTrue);
      expect(service.audioIndex, 1);
      expect(player.activeAudioTracks, [1]);
    });

    test('an out of range index is rejected', () async {
      twoEmbeddedAudios();
      final VideoService service = await buildLoadedService(testVideo());

      expect(service.setAudioTrack(7), isFalse);
      expect(service.audioIndex, 0);
    });

    test('a media change resets the override to the default', () async {
      twoEmbeddedAudios();
      final VideoService service = await buildLoadedService(testVideo());
      service.setAudioTrack(1);

      await service.changeVideo(
        video: testVideo(),
        alternativeVideos: [testVideo()],
        videoIndex: 0,
        episodeIndex: 1,
      );

      expect(service.audioIndex, -1);
    });
  });

  group('media swap re-init', () {
    test('swapping to a media with fewer tracks drops the stale selections', () async {
      twoEmbeddedSubtitles();
      twoEmbeddedAudios();
      final VideoService service = await buildLoadedService(testVideo(), alternatives: 2);
      expect(service.setSubtitle(1), isTrue);
      expect(service.setAudioTrack(1), isTrue);
      expect(service.audioIndex, 1);

      // The server swapped to has a single audio source, which the menu collapses
      // into "Default audio", and no subtitle tracks at all.
      player.mediaInfo.subtitle = [];
      player.mediaInfo.audio = [
        mdk.AudioStreamInfo()..metadata = {'title': 'Japanese', 'language': 'jpn'},
      ];

      // A swap reloads the media without changeVideo, so the indexes of the
      // previous media must not survive into the new track lists.
      await service.swapVideoUrl(1);
      player.emitLoaded();
      await Future<void>.delayed(Duration.zero);

      expect(service.subtitles, isEmpty);
      expect(service.subtitleIndex, -1);
      expect(service.areSubtitlesDisabled, isTrue);
      expect(service.audios, isEmpty);
      expect(service.audioIndex, -1);
    });
  });

  test('an external (non embedded) subtitle activates through setMedia', () async {
    final VideoService service = await buildLoadedService(
      testVideo(
        subtitleTracks: const [
          track.Track(url: 'https://example.com/sub.vtt', lang: 'Spanish', embedded: false, embeddedIndex: -1),
        ],
      ),
    );

    expect(service.subtitles, hasLength(1));
    expect(player.externalMedia.last.uri, 'https://example.com/sub.vtt');
    expect(player.externalMedia.last.type, mdk.MediaType.subtitle);
  });
}

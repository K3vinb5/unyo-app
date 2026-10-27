// External dependencies
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cast/cast.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unyo_lib/jmodels/jsepisode.dart';
import 'package:unyo_lib/jmodels/jvideo.dart';
import 'package:logger/logger.dart';
import 'dart:async';

// Internal dependencies
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/video_state.dart';

import 'package:unyo/core/notification/anime_notifier.dart';
import 'package:unyo/core/notification/episode_info_notifier.dart';
import 'package:unyo/core/notification/episodes_notifier.dart';
import 'package:unyo/core/notification/extension_notifier.dart';
import 'package:unyo/core/notification/media_list_entry_notifier.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/notification/video_info_notifier.dart';
import 'package:unyo/core/services/api/dto/aniskip/aniskip_times_entity.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/video/video_service.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/data/repositories/extension_repository_aniyomi.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/episode_info.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/extension/video.dart' as ext;
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/domain/entities/media/video_info.dart';
import 'package:unyo/presentation/dialogs/warning_dialog.dart';

class VideoCubit extends Cubit<VideoState> with EffectMixin<VideoState> {

  // Repositories
  final ExtensionRepositoryAniyomi _extensionRepositoryAniyomi;
  final AnimeRepository _animeRepository;

  // Notifiers / Subscriptions
  final UserNotifier _loggedUserNotifier;
  final VideoInfoNotifier _videoInfoNotifier;
  final AnimeNotifier _selectedAnimeNotifier;
  final EpisodesInfoNotifier _episodesInfoNotifier;
  final MediaListEntryNotifier _mediaListEntryNotifier;
  final ExtensionNotifier _selectedExtensionNotifier;
  final EpisodesNotifier _selectedEpisodesNotifier;
  final ReloadNotifier _reloadNotifier;
  late StreamSubscription<User> _loggedUserSubscription;
  late StreamSubscription<VideoInfo> _videoInfoSubscription;
  late StreamSubscription<Anime> _selectedAnimeSubscription;
  late StreamSubscription<List<EpisodeInfo>> _episodeInfoSubscription;
  late StreamSubscription<MediaListEntry> _mediaListEntrySubscription;
  late StreamSubscription<Extension> _selectedExtensionSubscription;
  late StreamSubscription<List<JSEpisode>> _selectedEpisodesSubscription;

  // Services
  late VideoService _videoService;
  final Logger _logger = sl<Logger>();
  final HttpService _httpService = sl<HttpService>();

  // Others
  bool _videoServiceInitialized = false;
  Timer? _videoReadyTimer;
  Timer? _updateMediaEntryTimer;

  VideoCubit(
    this._loggedUserNotifier,
    this._videoInfoNotifier,
    this._selectedAnimeNotifier,
    this._episodesInfoNotifier,
    this._mediaListEntryNotifier,
    this._selectedExtensionNotifier,
    this._selectedEpisodesNotifier,
    this._extensionRepositoryAniyomi,
    this._animeRepository,
    this._reloadNotifier,
  ) : super(
        VideoState(
          loggedUser: UserModel.empty(),
          videoInfo: VideoInfoModel.empty(),
          selectedAnime: AnimeModel.empty(),
          selectedExtension: ExtensionModel.empty(),
          extensionEpisodeResults: [],
          episodesInfo: [],
          episodesLoaded: false,
          mediaListEntry: MediaListEntryModel.empty(),
          availableCastDevices: [],
          openingSkipTimes: AniskipTimesResults(),
          endingSkipTimes: AniskipTimesResults(),
          isLoading: true,
        ),
      ) {
    _init();
  }

  @override
  VideoState copyStateWithEffects(VideoState state, List<AppEffect> effects) {
    return state.copyWith(effects: effects);
  }

  @override
  Logger get logger => _logger;

  VideoService get videoService => _videoService;

  @override
  Future<void> close() {
    if (_videoServiceInitialized) {
      _videoService.setPreventSleep(false);
      _videoService.dispose();
    }
    _loggedUserSubscription.cancel();
    _selectedAnimeSubscription.cancel();
    _episodeInfoSubscription.cancel();
    _mediaListEntrySubscription.cancel();
    _selectedExtensionSubscription.cancel();
    _selectedEpisodesSubscription.cancel();
    _videoReadyTimer?.cancel();
    _updateMediaEntryTimer?.cancel();
    _logger.d("VideoCubit closed and subscriptions cancelled.");
    return super.close();
  }

  void _init() {
    _loggedUserSubscription = _loggedUserNotifier.userStream.listen((loggedUser) {
      emit(state.copyWith(loggedUser: loggedUser));
    });
    _videoInfoSubscription = _videoInfoNotifier.videoInfoStream.listen((videoInfo) {
      _initializeVideoService(videoInfo);
      _videoInfoSubscription.cancel();
      _initVideoMetadata(videoInfo);
    });
    _selectedAnimeSubscription = _selectedAnimeNotifier.animeStream.listen((selectedAnime) {
      emit(state.copyWith(selectedAnime: selectedAnime));
    });
    _episodeInfoSubscription = _episodesInfoNotifier.episodeInfoStream.listen((episodesInfo) {
      emit(state.copyWith(episodesInfo: episodesInfo, episodesLoaded: true));
    });
    _mediaListEntrySubscription = _mediaListEntryNotifier.mediaListEntryStream.listen((mediaListEntry) {
      emit(state.copyWith(mediaListEntry: mediaListEntry));
    });
    _selectedExtensionSubscription = _selectedExtensionNotifier.extensionStream.listen((selectedExtension) {
      emit(state.copyWith(selectedExtension: selectedExtension));
    });
    _selectedEpisodesSubscription = _selectedEpisodesNotifier.episodesStream.listen((
      extensionEpisodeResults,
    ) {
      emit(state.copyWith(extensionEpisodeResults: extensionEpisodeResults));
    });
    _getAvailableCastDevices();
  }

  void _initVideoMetadata(VideoInfo videoInfo) {
    Future.delayed(const Duration(seconds: 1), () => _getAniskipSkipTimes(state.selectedAnime, videoInfo));
    _triggerUserMediaEntryUpdate();
  }

  void _initializeVideoService(VideoInfo videoInfo) {
    if (_videoServiceInitialized) {
      _videoService.dispose();
      _logger.d("Previous VideoService disposed.");
    }
    _videoService = VideoService(
      video: videoInfo.currentVideo,
      alternativeVideos: videoInfo.alternativeVideos,
      videoIndex: videoInfo.videoIndex,
      episodeIndex: videoInfo.playlistIndex,
      onErrorCallback: _handleVideoError,
    );
    _videoService.setPreventSleep(true);
    _videoServiceInitialized = true;
    emit(state.copyWith(videoInfo: videoInfo, isLoading: false));
  }

  Future<void> _selectNewEpisode(VideoInfo videoInfo) async {
    _logger.i("Selecting new episode: Index ${videoInfo.playlistIndex}");
    await _videoService.changeVideo(
      video: videoInfo.currentVideo,
      alternativeVideos: videoInfo.alternativeVideos,
      videoIndex: videoInfo.videoIndex,
      episodeIndex: videoInfo.playlistIndex,
    );
    emit(state.copyWith(videoInfo: videoInfo));
    _initVideoMetadata(videoInfo);
    _logger.i("VideoService updated for new episode.");
  }

  Future<void> _getAniskipSkipTimes(Anime selectedAnime, VideoInfo videoInfo) async {
    double formattedDuration = selectedAnime.duration > 0 ? selectedAnime.duration * 60 : 24 * 60;
    ApiResponse<AniskipTimesEntity> aniskipResponse =
      await _httpService.get(
          "${config.aniskiBaseEndpoint}/v2/skip-times/${selectedAnime.idMal}/${videoInfo.playlistIndex + 1}?types=op&types=ed&episodeLength=$formattedDuration",
          fromJson: AniskipTimesEntity.fromJson
      );
    if (aniskipResponse.statusCode > 299 || aniskipResponse.data.statusCode > 299) {
    _logger.e("Failed to fetch Aniskip times for malId: ${selectedAnime.idMal}. Status code: ${aniskipResponse.data.statusCode}. Message: ${aniskipResponse.data.message}");
      return;
    }
    final openingSkipTimes = aniskipResponse.data.results.where((skip) => skip.skipType == "op").firstOrNull;
    final endingSkipTimes = aniskipResponse.data.results.where((skip) => skip.skipType == "ed").firstOrNull;
    emit(state.copyWith(openingSkipTimes: openingSkipTimes ?? AniskipTimesResults(), endingSkipTimes: endingSkipTimes ?? AniskipTimesResults()));
  }

  String getSkipTimeText() {
    if (state.openingSkipTimes.interval.endTime > 0 &&
        _videoService.position.inSeconds > state.openingSkipTimes.interval.startTime &&
        state.openingSkipTimes.interval.endTime > _videoService.position.inSeconds) {
      return "Skip Opening";
    } else if (state.endingSkipTimes.interval.endTime > 0 &&
        _videoService.position.inSeconds > state.endingSkipTimes.interval.startTime &&
        state.endingSkipTimes.interval.endTime > _videoService.position.inSeconds) {
      return "Skip Ending";
    } else {
      return "+ ${state.loggedUser.settings.manualSkipTime.toString()}s";
    }
  }


  void performSkipActin() {
    if (state.openingSkipTimes.interval.endTime > 0 &&
        _videoService.position.inSeconds > state.openingSkipTimes.interval.startTime &&
        state.openingSkipTimes.interval.endTime > _videoService.position.inSeconds) {
      _videoService.seekTo(Duration(seconds: state.openingSkipTimes.interval.endTime.toInt()));
    } else if (state.endingSkipTimes.interval.endTime > 0 &&
        _videoService.position.inSeconds > state.endingSkipTimes.interval.startTime &&
        state.endingSkipTimes.interval.endTime > _videoService.position.inSeconds) {
      _videoService.seekTo(Duration(seconds: state.endingSkipTimes.interval.endTime.toInt()));
    } else {
      _videoService.forward(Duration(seconds: state.loggedUser.settings.manualSkipTime));
    }
  }


  Future<void> _getAvailableCastDevices() async {
    List<CastDevice> availableCastDevices = await CastDiscoveryService().search();
    emit(state.copyWith(availableCastDevices: availableCastDevices));
  }

  Future<void> _connectAndPlayMediaOnCastDevice(CastDevice device) async {
    final session = await CastSessionManager().startSession(device);

    session.stateStream.listen((castState) {
      if (castState == CastSessionState.connected) {
        _logger.d("Connected to Cast device: ${device.name}");
        showSnackBarEffect(
          "Cast Connected",
          message: "Connected to ${device.name}",
          contentType: ContentType.success,
        );
      }
    });

    var messageIndex = 0;
    session.messageStream.listen((message) {
      messageIndex += 1;
      _logger.d("Cast message received ($messageIndex): $message");

      // After receiving the initial messages, send the media load command
      if (messageIndex == 2) {
        Future.delayed(const Duration(seconds: 2)).then((_) {
          _sendMediaToCastSession(session);
        });
      }
    });

    // Launch the default media receiver app
    session.sendMessage(CastSession.kNamespaceReceiver, {
      'type': 'LAUNCH',
      'appId': 'CC1AD845', // Google's default media receiver app ID
    });
  }

  void _sendMediaToCastSession(CastSession session) {
    final video = state.videoInfo.currentVideo;
    final anime = state.selectedAnime;
    final episodeNumber = state.videoInfo.playlistIndex + 1;

    // Determine the content type based on the video URL
    final contentType = _getContentType(video.videoUrl);
    final streamType = _getStreamType(video.videoUrl);

    _logger.d("Casting video: ${video.videoUrl} with contentType: $contentType, streamType: $streamType");

    // Build the media message
    final Map<String, dynamic> message = {
      'contentId': video.videoUrl,
      'contentType': contentType,
      'streamType': streamType,
      'metadata': {
        'type': 0,
        'metadataType': 0,
        'title': "${anime.title.userPreferred} - Episode $episodeNumber",
        'images': [
          {'url': anime.coverImage},
        ],
      },
    };

    // Add custom headers if available (for custom receivers that support it)
    // Note: The default media receiver (CC1AD845) has limited header support.
    // For full header support, a custom receiver app may be needed.
    if (video.headers != null && video.headers!.headersMap.isNotEmpty) {
      final headers = video.headers!.headersMap;
      _logger.d("Including custom headers for cast: $headers");

      // Add headers via customData (requires custom receiver support)
      message['customData'] = {'headers': headers};
    }

    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'LOAD',
      'autoPlay': true,
      'currentTime': _videoService.position.inSeconds,
      'media': message,
    });

    // Pause local playback when casting
    _videoService.pause();
  }

  String _getContentType(String videoUrl) {
    final lowerUrl = videoUrl.toLowerCase();

    if (lowerUrl.contains('.m3u8') || lowerUrl.contains('m3u8')) {
      return 'application/x-mpegurl';
    } else if (lowerUrl.contains('.mpd')) {
      return 'application/dash+xml';
    } else if (lowerUrl.endsWith('.webm')) {
      return 'video/webm';
    } else if (lowerUrl.endsWith('.mkv')) {
      return 'video/x-matroska';
    } else if (lowerUrl.endsWith('.avi')) {
      return 'video/x-msvideo';
    } else if (lowerUrl.endsWith('.mov')) {
      return 'video/quicktime';
    } else if (lowerUrl.endsWith('.ts')) {
      return 'video/mp2t';
    } else if (lowerUrl.endsWith('.flv')) {
      return 'video/x-flv';
    } else if (lowerUrl.endsWith('.mp3')) {
      return 'audio/mpeg';
    } else if (lowerUrl.endsWith('.aac')) {
      return 'audio/aac';
    } else {
      // Default to mp4 for most video streams
      return 'video/mp4';
    }
  }

  String _getStreamType(String videoUrl) {
    final lowerUrl = videoUrl.toLowerCase();

    // HLS and DASH are typically live/buffered streams
    if (lowerUrl.contains('.m3u8') || lowerUrl.contains('m3u8') || lowerUrl.contains('.mpd')) {
      // Could be LIVE or BUFFERED depending on the stream
      // For VOD content, BUFFERED is more appropriate
      return 'BUFFERED';
    }

    // Regular file-based content
    return 'BUFFERED';
  }

  void navigateBackToAnimeDetailsPage(BuildContext context) {
    _logger.d("Returning to Anime Details Page");
    popRouteEffect(context);
    // The BlocProvider will dispose/close this cubit when the route is popped.
  }

  void castToDevice(CastDevice device) {
    _logger.d("Casting to device: ${device.name}");
    _connectAndPlayMediaOnCastDevice(device);
  }

  void _handleVideoError(String errorTitle) {
    showWidgetDialogEffect(dialog: WarningDialog(width: 500, height: 200, title: errorTitle));
  }

  Future<void> navigateToEpisode(int episodeIndex) async {
    try {
      _logger.i("Navigating to episode index: $episodeIndex");
      _videoService.resetService();
      VideoInfo currentVideoInfo = state.videoInfo;
      List<ext.Video> alternativeVideos = await _getVideosFromSelectedExtension(
        state.selectedExtension,
        state.extensionEpisodeResults[episodeIndex],
      );
      VideoInfo videoInfo = VideoInfoModel(
        currentVideo: alternativeVideos[currentVideoInfo.videoIndex],
        alternativeVideos: alternativeVideos,
        videoIndex: currentVideoInfo.videoIndex,
        playlistIndex: episodeIndex,
      );
      await _selectNewEpisode(videoInfo);
    } catch (e, stackTrace) {
      logger.e("Error navigating to episode $e", stackTrace: stackTrace);
      handleError("Error navigating to episode", stackTrace: stackTrace);
    }
  }

  Future<List<ext.Video>> _getVideosFromSelectedExtension(
    Extension? selectedExtension,
    JSEpisode? selectedJSEpisode,
  ) async {
    if (selectedExtension == null) {
      _logger.w("No extension selected to fetch videos.");
      showSnackBarEffect(
        "No Extension Selected",
        message: "Select an extension to fetch videos.",
        contentType: ContentType.warning,
      );
      return [];
    } else if (selectedJSEpisode == null) {
      _logger.w("No JSEpisode selected to fetch videos.");
      showSnackBarEffect(
        "No Episode Selected",
        message: "Select an episode to fetch videos.",
        contentType: ContentType.warning,
      );
      return [];
    }
    try {
      _logger.i(
        "Fetching Videos Info from extension ${selectedExtension.name} for ${state.selectedAnime.title.userPreferred}",
      );
      List<JVideo> videoResults = await _extensionRepositoryAniyomi.getAnimeVideoList(
        selectedJSEpisode,
        selectedExtension,
      );
      if (videoResults.isNotEmpty) {
        return videoResults.map((jVideo) => ext.Video.fromJVideo(jVideo)).toList();
      } else {
        showSnackBarEffect(
          selectedExtension.name,
          message:
              "No video links found in ${selectedExtension.name} for ${state.selectedAnime.title.userPreferred}",
          contentType: ContentType.warning,
        );
        return [];
      }
    } catch (e, stackTrace) {
      handleError("Error fetching Videos Info from selected extension: $e", stackTrace: stackTrace);
      return [];
    }
  }

  void _triggerUserMediaEntryUpdate() {
    _videoReadyTimer?.cancel();
    _updateMediaEntryTimer?.cancel();

    const timeout = Duration(minutes: 1);
    const pollInterval = Duration(milliseconds: 100);
    final startTime = DateTime.now();

    _videoReadyTimer = Timer.periodic(pollInterval, (timer){
      if (_videoService.isVideoReady) {
        _logger.d("Video is ready, triggering media entry update timer.");
        timer.cancel();
        // TODO add a setting for this percentage value
        final updateMediaEntryTriggerDuration = Duration(seconds: (_videoService.duration.inSeconds * 0.8).toInt());
        _updateMediaEntryTimer = Timer.periodic(const Duration(seconds: 30), (updateTimer) async {
          if (_videoService.position >= updateMediaEntryTriggerDuration) {
            _markEpisodeAsWatched();
            updateTimer.cancel();
          }
        });
        return;
      }
      if (DateTime.now().difference(startTime) > timeout) {
        timer.cancel();
        _logger.w("Video ready timeout after 1 minute");
      }
    });
  }

  Future<void> _markEpisodeAsWatched() async {
    if (state.mediaListEntry.progress >= state.videoInfo.playlistIndex + 1) {
      _logger.d("Episode ${state.videoInfo.playlistIndex + 1} is already marked as watched. No update needed.");
      return;
    }
    _logger.i("Marking episode ${state.videoInfo.playlistIndex + 1} as watched in media list.");
    try {
      MediaListEntry desiredMediaListEntry = (state.mediaListEntry as MediaListEntryModel).copyWith(
        progress: state.videoInfo.playlistIndex + 1,
        status: "Current",
      );
      _logger.i("Updating Media List Entry to $desiredMediaListEntry");
      MediaListEntry savedMediaListEntry = await _animeRepository.updateMediaListEntry(
        desiredMediaListEntry,
        state.selectedAnime,
        state.loggedUser,
      );
      emit(state.copyWith(mediaListEntry: savedMediaListEntry));
      _reloadNotifier.emitReload(ReloadType.videoMediaListEntryUpdated);
    } on HttpServerException catch (e, stackTrace) {
      handleError("Error updating Anime Entry:", responseBody: e.message, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      handleError("Error updating Anime Entry: $e", stackTrace: stackTrace);
    }
    showSnackBarEffect("Episode marked as complete!", message: "This episode has been marked as completed", contentType: ContentType.success);
  }
}

import 'dart:async';
import 'dart:math';
import 'package:auto_route/auto_route.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:unyo_lib/jmodels/jsanime.dart';
import 'package:unyo_lib/jmodels/jsepisode.dart';
import 'package:unyo_lib/jmodels/jvideo.dart';
import 'package:logger/logger.dart';
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/anime_details_state.dart';
import 'package:bloc/bloc.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/notification/anime_genres_notifier.dart';
import 'package:unyo/core/notification/anime_notifier.dart';
import 'package:unyo/core/notification/episode_info_notifier.dart';
import 'package:unyo/core/notification/episodes_notifier.dart';
import 'package:unyo/core/notification/extension_notifier.dart';
import 'package:unyo/core/notification/media_list_entry_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/notification/video_info_notifier.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/media/media_provenance.dart';
import 'package:unyo/data/models/anilist/media/anilist_anime_model.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/domain/repositories/user_repository.dart';
import 'package:unyo/domain/repositories/episode_repository.dart';
import 'package:unyo/data/repositories/extension_repository_aniyomi.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/media/episode_info.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/extension/video.dart' as ext;
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/entities/media/video_info.dart';
import 'package:unyo/domain/services/id_mapping.dart';
import 'package:unyo/domain/services/media_id_resolver.dart';
import 'package:unyo/domain/services/media_link_proposal.dart';
import 'package:unyo/domain/utils/episode_index.dart';
import 'package:unyo/presentation/dialogs/anime_details_media_entry_dialog.dart';
import 'package:unyo/presentation/drawers/anime_server_selection_drawer.dart';
import 'package:unyo/presentation/widgets/media_link_dialog.dart';
import 'package:unyo/presentation/widgets/styled/unyo_date_picker.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

class AnimeDetailsCubit extends Cubit<AnimeDetailsState> with EffectMixin<AnimeDetailsState> {
  // Repositories
  final AnimeRepository _animeRepository;
  final EpisodeRepository _episodeRepository;
  final ExtensionRepositoryAniyomi _extensionRepositoryAniyomi;
  final UserRepository _userRepository;

  final MediaIdResolver? _providedMediaIdResolver;

  /// Resolved on first use so a cubit can be built before the mapping layer is
  /// registered (and in tests that inject their own resolver).
  MediaIdResolver? _mediaIdResolverCache;
  MediaIdResolver get _mediaIdResolver => _mediaIdResolverCache ??= _providedMediaIdResolver ?? sl<MediaIdResolver>();

  /// Entries already prompted in this app session (static so reopening the
  /// details page does not ask again). Never a nag, but the details page keeps
  /// the manual relink action.
  static final Set<String> _promptedLinks = <String>{};

  /// Test hook: the session memory is static so it survives a cubit rebuild.
  @visibleForTesting
  static void resetPromptedMediaLinks() => _promptedLinks.clear();

  // Notifiers / Subscriptions
  final UserNotifier _loggedUserNotifier;
  final AnimeNotifier _selectedAnimeNotifier;
  final AnimeGenresNotifier _selectedAnimeAdvancedSearchGenresFilters;
  final MediaListNotifier _selectedMediaListNotifier;
  final VideoInfoNotifier _videoInfoNotifier;
  final EpisodesInfoNotifier _episodesInfoNotifier;
  final MediaListEntryNotifier _mediaListEntryNotifier;
  final ExtensionNotifier _selectedExtensionNotifier;
  final EpisodesNotifier _selectedEpisodesNotifier;
  final ReloadNotifier _reloadNotifier;
  late StreamSubscription<Anime> _selectedAnimeSubscription;
  late StreamSubscription<User> _loggedUserSubscription;
  late StreamSubscription<MediaList> _selectedMediaListSubscription;
  late StreamSubscription<ReloadType> _reloadSubscription;

  // Logger
  final Logger _logger = sl<Logger>();

  AnimeDetailsCubit(
    this._animeRepository,
    this._episodeRepository,
    this._loggedUserNotifier,
    this._selectedAnimeNotifier,
    this._selectedAnimeAdvancedSearchGenresFilters,
    this._selectedMediaListNotifier,
    this._videoInfoNotifier,
    this._extensionRepositoryAniyomi,
    this._userRepository,
    this._episodesInfoNotifier,
    this._mediaListEntryNotifier,
    this._selectedExtensionNotifier,
    this._selectedEpisodesNotifier,
    this._reloadNotifier, {
    MediaIdResolver? mediaIdResolver,
  })  : _providedMediaIdResolver = mediaIdResolver,
        super(
        AnimeDetailsState(
          loggedUser: UserModel.empty(),
          selectedMediaList: MediaListModel.empty(),
          selectedAnime: AnimeModel.empty(),
          mediaListEntry: MediaListEntryModel.empty(),
          newMediaListEntry: MediaListEntryModel.empty(),
          characters: (false, []),
          recommendations: (false, []),
          episodesInfo: [],
          banners: [],
          alternateImage: '',
          installedExtensions: {},
          selectedExtension: null,
          userLoaded: false,
          animeServerDialogReady: false,
          animeServerDialogLoading: false,
          extensionAnimeResults: [],
          selectedAnimeResultIndex: 0,
          extensionEpisodeResults: [],
          extensionVideoResults: [],
        ),
      ) {
    _init();
  }

  @override
  AnimeDetailsState copyStateWithEffects(AnimeDetailsState state, List<AppEffect> effects) {
    return state.copyWith(effects: effects);
  }

  @override
  Future<void> close() {
    _loggedUserSubscription.cancel();
    _selectedAnimeSubscription.cancel();
    _selectedMediaListSubscription.cancel();
    _reloadSubscription.cancel();
    return super.close();
  }

  @override
  Logger get logger => _logger;

  void _init() {
    _loggedUserSubscription = _loggedUserNotifier.userStream.listen((loggedUser) {
      emit(state.copyWith(loggedUser: loggedUser));
      if (!state.userLoaded) {
        _getAnimeBanners(loggedUser);
        emit(state.copyWith(userLoaded: true));
      }
    });
    _selectedAnimeSubscription = _selectedAnimeNotifier.animeStream.listen((anime) {
      _getAnimeDetails(state.loggedUser, anime);
      _getEpisodesDetails(state.loggedUser, anime);
      emit(state.copyWith(selectedAnime: anime));
    });
    _selectedMediaListSubscription = _selectedMediaListNotifier.mediaListStream.listen((mediaList) {
      emit(state.copyWith(selectedMediaList: mediaList));
    });
    _reloadSubscription = _reloadNotifier.reloadStream.listen((reloadType) {
      if (reloadType == ReloadType.videoMediaListEntryUpdated) {
        _logger.i("Reloading Anime Details due to video media list entry update");
        _getUserMediaListEntry(state.loggedUser, state.selectedAnime, ignoreCache: true);
      }
      if (reloadType == ReloadType.animeMediaListEntryUpdated) {
        _logger.i("Reloading Anime Details due to anime media list entry update");
        _getUserMediaListEntry(state.loggedUser, state.selectedAnime, ignoreCache: true);
      }
    });
    _loadInstalledExtensions();
  }

  void navigateBackToAnimePage(BuildContext context) {
    _logger.d("Returning to Anime Page");
    popRouteEffect(context);
    // close();
  }

  void navigateToAnimeDetails(Anime anime, MediaList mediaList) {
    _logger.i("Navigating to Anime Details of ${anime.title.userPreferred}");
    _selectedAnimeNotifier.updateSelectedAnime(anime);
    _selectedMediaListNotifier.updateSelectedMediaList(mediaList);
  }

  void navigateToAnimeAdvancedSearchScreenWithFilters(BuildContext context, String newAnimeGenre) {
    _logger.i("Navigating to Anime Advanced Search Filters");
    bool hasAnimeSearchInStack = AutoRouter.of(
      context,
    ).stackData.any((route) => route.name == "AnimeAdvancedSearchRoute");
    if (hasAnimeSearchInStack) {
      _selectedAnimeAdvancedSearchGenresFilters.updateSelectedAnimeGenre(newAnimeGenre);
      popRouteEffect(context);
    } else {
      _selectedAnimeAdvancedSearchGenresFilters.updateSelectedAnimeGenre(newAnimeGenre);
      pushRouteEffect(path: "/animesearch");
    }
  }

  Future<void> navigateToVideoPlayer(ext.Video selectedVideo, int episodeIndex, int videoIndex) async {
    _logger.i("Navigating to Video Player with selected video from ${state.selectedExtension?.name}");
    _mediaListEntryNotifier.updateSelectedMediaListEntry(state.mediaListEntry);
    _videoInfoNotifier.updateVideoInfo(
        VideoInfoModel(
          currentVideo: selectedVideo,
          alternativeVideos: state.extensionVideoResults,
          videoIndex: videoIndex,
          playlistIndex: episodeIndex,
       )
    );
    pushRouteEffect(path: "/video");
  }

  Future<void> selectAnimeExtension(String? selectedAnimeExtensionName) async {
    Extension? selectedExtension =
        state.installedExtensions
            .where((extension) => selectedAnimeExtensionName == extension.name)
            .firstOrNull;
    if (selectedExtension != null) {
      emit(state.copyWith(selectedExtension: selectedExtension));
      _selectedExtensionNotifier.updateSelectedExtension(selectedExtension);
      switch (state.loggedUser) {
        case AnilistUserModel anilistUserModel:
          // Persisting the choice must never block fetching from the extension.
          try {
            SettingsModel userSettings = anilistUserModel.settings as SettingsModel;
            Map<String, Extension> mediaExtensionsConfigUpdated = Map.from(userSettings.mediaExtensionConfigs);
            mediaExtensionsConfigUpdated.addAll({state.selectedAnime.id.toString(): selectedExtension});
            await _userRepository.updateUserInfo(
              anilistUserModel.copyWith(
                settings: userSettings.copyWith(mediaExtensionConfigs: mediaExtensionsConfigUpdated),
              ),
            );
          } catch (e, stackTrace) {
            _logger.w("Failed to persist the selected extension: $e", stackTrace: stackTrace);
          }
        case LocalUserModel localUserModel:
      }
      if (isClosed) return;
      await _getAnimeInfoFromSelectedExtension(selectedExtension);
    } else {
      _logger.w("Selected extension $selectedAnimeExtensionName not found among installed extensions.");
      showSnackBarEffect(
        "Extension Not Found",
        message: "The selected extension is not installed.",
        contentType: ContentType.warning,
      );
    }
  }

  void openAnimeDetailsMediaEntryDialog(BuildContext context) {
    showWidgetDialogEffect(dialog: AnimeDetailsMediaEntryDialog(cubit: this));
  }

  Future<void> openAnimeServerSelectionDrawer(BuildContext context, int episodeIndex) async {
    if (state.animeServerDialogLoading) return;
    Extension? selectedExtension = state.selectedExtension;
    if (selectedExtension == null) {
      _logger.w("No extension selected to open the server selection drawer.");
      showSnackBarEffect(
        "No Extension Selected",
        message: "Select an extension to fetch episodes.",
        contentType: ContentType.warning,
      );
      return;
    }
    if (state.extensionAnimeResults.isEmpty || state.selectedAnimeResultIndex >= state.extensionAnimeResults.length) {
      _logger.w("Cannot open server selection: no extension anime results available.");
      showSnackBarEffect(
        "${selectedExtension.name} Error",
        message: "No results from the extension. Try again.",
        contentType: ContentType.warning,
      );
      return;
    }
    // The loading flag is only held while this method is processing, every exit
    // path (including the drawer callback failing) has to release it.
    emit(state.copyWith(animeServerDialogReady: false, animeServerDialogLoading: true, extensionVideoResults: []));
    try {
      // TODO - You may not want to select the found index (selectedAnimeResultIndex) on extensionAnimeResults
      bool canOpenDrawer = await _getEpisodesFromSelectedExtension(
        selectedExtension,
        state.extensionAnimeResults[state.selectedAnimeResultIndex],
      );
      if (!canOpenDrawer) return;
      // Episode buttons pass the 0-based button index, the episode number is +1.
      // The drawer indexes the extension episode list, which does not have to
      // match the anime metadata episode list.
      int resolvedEpisodeIndex = EpisodeIndex.resolveExtensionEpisodeIndex(state.extensionEpisodeResults, episodeIndex + 1);
      if (resolvedEpisodeIndex < 0) {
        _logger.w("Episode ${episodeIndex + 1} is not part of the extension episode results.");
        showSnackBarEffect(
          "${selectedExtension.name} Error",
          message: "Only ${state.extensionEpisodeResults.length} episodes were found",
          contentType: ContentType.warning,
        );
        return;
      }
      showDrawerDialogEffect(
          drawerDialog: AnimeServerSelectionDrawer(
            cubit: this,
            episodeIndex: resolvedEpisodeIndex,
            onOpen: () async {
              try {
                if (resolvedEpisodeIndex >= state.extensionEpisodeResults.length) {
                  _logger.w("Episode index $resolvedEpisodeIndex is out of bounds for extension episode results.");
                  showSnackBarEffect(
                    "${state.selectedExtension?.name} Error",
                    message: "Only ${state.extensionEpisodeResults.length} episodes were found",
                    contentType: ContentType.warning,
                  );
                  return false;
                }
                bool shouldKeepDialog = await _getVideosFromSelectedExtension(
                  state.selectedExtension,
                  state.extensionEpisodeResults[resolvedEpisodeIndex],
                );
                if (!shouldKeepDialog) {
                  if (!isClosed) emit(state.copyWith(animeServerDialogReady: false));
                  return false;
                }
                if (!isClosed) emit(state.copyWith(animeServerDialogReady: true));
                return true;
              } finally {
                if (!isClosed) emit(state.copyWith(animeServerDialogLoading: false));
              }
            },
          ),
          backgroundColor: Colors.black.withValues(alpha: 0.55),
          startPosition: AxisDirection.down
      );
    } finally {
      if (!isClosed) emit(state.copyWith(animeServerDialogLoading: false));
    }
  }

  Future<void> updateMediaListEntry(BuildContext context) async {
    MediaListEntry desiredMediaListEntry = state.newMediaListEntry;
    MediaListEntry beforeUpdateMediaListEntry = state.mediaListEntry;
    try {
      _logger.i("Updating Media List Entry to $desiredMediaListEntry");
      await _animeRepository.updateMediaListEntry(
        desiredMediaListEntry,
        state.selectedAnime,
        state.loggedUser,
      );
      _reloadNotifier.emitReload(ReloadType.animeMediaListEntryUpdated);
      if (desiredMediaListEntry.status != beforeUpdateMediaListEntry.status) {
        _reloadNotifier.emitReload(ReloadType.homeMediaListEntryUpdated);
      }
    } on HttpServerException catch (e, stackTrace) {
      handleError("Error updating Anime Entry:", responseBody: e.message, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      handleError("Error updating Anime Entry: $e", stackTrace: stackTrace);
    }
    if (!context.mounted) return;
    popRouteEffect(context);
  }

  Future<void> updateMediaListEntryStatus(String? newStatus) async {
    if (newStatus == null) return;
    try {
      MediaListEntry updatedMediaListEntry = (state.newMediaListEntry as MediaListEntryModel).copyWith(
        status: newStatus,
      );
      emit(state.copyWith(newMediaListEntry: updatedMediaListEntry));
    } catch (e, stackTrace) {
      handleError("Error updating Anime Entry status: $e", stackTrace: stackTrace);
    }
  }

  Future<void> updateMediaListEntryProgress(int? newProgress) async {
    if (newProgress == null) return;
    try {
      MediaListEntry updatedMediaListEntry = (state.newMediaListEntry as MediaListEntryModel).copyWith(
        progress: newProgress,
      );
      emit(state.copyWith(newMediaListEntry: updatedMediaListEntry));
    } catch (e, stackTrace) {
      handleError("Error updating Anime Entry progress: $e", stackTrace: stackTrace);
    }
  }

  Future<void> updateMediaListEntryScore(double? newScore) async {
    if (newScore == null) return;
    try {
      MediaListEntry updatedMediaListEntry = (state.newMediaListEntry as MediaListEntryModel).copyWith(
        score: newScore,
      );
      emit(state.copyWith(newMediaListEntry: updatedMediaListEntry));
    } catch (e, stackTrace) {
      handleError("Error updating Anime Entry score: $e", stackTrace: stackTrace);
    }
  }

  Future<void> updateMediaListEntryRepeat(int? newRepeat) async {
    if (newRepeat == null) return;
    try {
      MediaListEntry updatedMediaListEntry = (state.newMediaListEntry as MediaListEntryModel).copyWith(
        repeat: newRepeat,
      );
      emit(state.copyWith(newMediaListEntry: updatedMediaListEntry));
    } catch (e, stackTrace) {
      handleError("Error updating Anime Entry repeat: $e", stackTrace: stackTrace);
    }
  }

  Future<void> updateMediaListEntryStartedAt(BuildContext context) async {
    DateTime? selectedDateTime = await showUnyoDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selectedDateTime == null) return;
    try {
      MediaListEntry updatedMediaListEntry = (state.newMediaListEntry as MediaListEntryModel).copyWith(
        startedAt: [
          selectedDateTime.day.toString(),
          selectedDateTime.month.toString(),
          selectedDateTime.year.toString(),
        ],
      );
      emit(state.copyWith(newMediaListEntry: updatedMediaListEntry));
    } catch (e, stackTrace) {
      handleError("Error updating Anime Entry started at: $e", stackTrace: stackTrace);
    }
  }

  Future<void> updateMediaListEntryCompletedAt(BuildContext context) async {
    DateTime? selectedDateTime = await showUnyoDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selectedDateTime == null) return;
    try {
      MediaListEntry updatedMediaListEntry = (state.newMediaListEntry as MediaListEntryModel).copyWith(
        completedAt: [
          selectedDateTime.day.toString(),
          selectedDateTime.month.toString(),
          selectedDateTime.year.toString(),
        ],
      );
      emit(state.copyWith(newMediaListEntry: updatedMediaListEntry));
    } catch (e, stackTrace) {
      handleError("Error updating Anime Entry completed at: $e", stackTrace: stackTrace);
    }
  }

  Future<void> _getUserMediaListEntry(User loggedUser, Anime selectedAnime, {bool ignoreCache = false}) async {
   try {
      _logger.i("Fetching User Media List Entry for ${state.selectedAnime.title.userPreferred}");
      MediaListEntry mediaListEntry = await _animeRepository.getMediaListEntry(
        selectedAnime,
        loggedUser,
        ignoreCache: ignoreCache,
      );
      emit(state.copyWith(mediaListEntry: mediaListEntry, newMediaListEntry: mediaListEntry));
      _mediaListEntryNotifier.updateSelectedMediaListEntry(mediaListEntry);
    } on HttpServerException catch (e, stackTrace) {
      handleError("Error fetching User Media List entry:", responseBody: e.message, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      handleError("Error fetching User Media List Entry: $e", stackTrace: stackTrace);
    }
  }

  Future<void> _getAnimeDetails(User loggedUser, Anime selectedAnime) async {
    try {
      final Service provenance = serviceOfAnime(selectedAnime);
      final Service metadataService = loggedUser.settings.metadataService;
      Anime detailsRecord = selectedAnime;
      Service detailsService = provenance;
      if (metadataService != provenance) {
        final MediaIdResolution resolution = await _resolveMetadataRecord(
          loggedUser,
          selectedAnime,
          provenance,
          metadataService,
        );
        final IdMapping? mapping = resolution.mapping;
        if (resolution.isResolved && mapping != null && mapping.service == metadataService) {
          detailsRecord = _withNativeId(selectedAnime, int.tryParse(mapping.nativeId) ?? selectedAnime.id);
          detailsService = metadataService;
        }
      }
      _logger.i(
        "Fetching Anime Details for ${state.selectedAnime.title.userPreferred} from ${detailsService.name}",
      );
      (bool, AnimeDetails) animeDetails = await _animeRepository.getAnimeDetails(
        detailsRecord,
        loggedUser,
        service: detailsService,
      );
      emit(
        state.copyWith(
          characters: (animeDetails.$2.characters.isNotEmpty, animeDetails.$2.characters),
          mediaListEntry: animeDetails.$2.mediaListEntry,
          newMediaListEntry: animeDetails.$2.mediaListEntry,
          recommendations: (
            animeDetails.$2.recommendedAnimes.isNotEmpty,
            animeDetails.$2.recommendedAnimes,
          ),
        ),
      );
      if (animeDetails.$2.recommendedAnimes.isEmpty) {
        (bool, List<Anime>) trendingAnimes = await _animeRepository.getTrendingAnimes(
          1,
          loggedUser,
        );
        emit(state.copyWith(recommendations: (trendingAnimes.$1, trendingAnimes.$2.shuffled(Random()))));
      }
      _getAlternativeImage(loggedUser, selectedAnime);
    } on HttpServerException catch (e, stackTrace) {
      handleError("Error fetching Anime details:", responseBody: e.message, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      handleError("Error fetching Anime Details: $e", stackTrace: stackTrace);
    }
  }

  /// Translates the opened record to the metadata provider through the MAL
  /// pivot. When the chain can only propose title-search hits, the proposal is
  /// surfaced (state + dialog) once per entry per session; the caller then
  /// falls back to the record's own provider details.
  Future<MediaIdResolution> _resolveMetadataRecord(
    User loggedUser,
    Anime selectedAnime,
    Service provenance,
    Service metadataService,
  ) async {
    final MediaIdResolution resolution = await _mediaIdResolver.resolveTarget(
      source: provenance,
      nativeId: '${selectedAnime.id}',
      target: metadataService,
      query: MediaLinkQuery(
        title: selectedAnime.title.userPreferred.isNotEmpty
            ? selectedAnime.title.userPreferred
            : selectedAnime.title.romaji,
        alternativeTitles: <String>[
          selectedAnime.title.english,
          selectedAnime.title.romaji,
          selectedAnime.title.nativeTitle,
        ].where((title) => title.isNotEmpty).toList(),
        year: int.tryParse(TextUtils.extractYearFromStartDate(selectedAnime.startDate, loggedUser)),
        isAnime: true,
      ),
      knownMalId: selectedAnime.idMal,
    );

    if (resolution.needsConfirmation) {
      final MediaLinkProposal proposal = MediaLinkProposal(
        userService: loggedUser.settings.userService,
        metadataService: metadataService,
        sourceService: provenance,
        sourceNativeId: '${selectedAnime.id}',
        candidates: resolution.candidates,
      );
      if (isClosed) return resolution;
      if (_promptedLinks.add(proposal.entryKey)) {
        emit(state.copyWith(mediaLinkProposal: proposal, mediaLinkUnresolved: true));
        _openMediaLinkDialog(proposal);
      } else {
        // Already asked once this session: stay quiet and keep the fallback.
        emit(state.copyWith(mediaLinkProposal: null, mediaLinkUnresolved: true));
      }
      return resolution;
    }

    if (!isClosed) {
      emit(state.copyWith(mediaLinkUnresolved: resolution.isUnresolved, mediaLinkProposal: null));
    }
    return resolution;
  }

  void _openMediaLinkDialog(MediaLinkProposal proposal) {
    showWidgetDialogEffect(
      dialog: MediaLinkDialog(
        proposal: proposal,
        onLink: confirmMediaLink,
        onNoneOfThese: declineMediaLink,
        onDismiss: dismissMediaLink,
      ),
    );
  }

  /// Copies the record with a different provider-native id, so the metadata
  /// repository queries the right entry (the domain entity keeps its own id).
  Anime _withNativeId(Anime anime, int nativeId) {
    if (anime is AnimeModel) return anime.copyWith(id: nativeId);
    if (anime is ShikimoriAnimeModel) return anime.copyWith(id: nativeId);
    if (anime is AnilistAnimeModel) return anime.copyWith(id: nativeId);
    return anime;
  }

  /// "Link" in the link-confirmation dialog: cache the user's choice and
  /// re-render the details page from the freshly linked metadata entry.
  Future<void> confirmMediaLink(MediaLinkCandidate candidate) async {
    final MediaLinkProposal? proposal = state.mediaLinkProposal;
    if (proposal == null) return;
    if (!isClosed) emit(state.copyWith(mediaLinkProposal: null, mediaLinkUnresolved: false));
    await _mediaIdResolver.confirmLink(
      source: proposal.sourceService,
      nativeId: proposal.sourceNativeId,
      candidate: candidate,
    );
    await _getAnimeDetails(state.loggedUser, state.selectedAnime);
  }

  /// "None of these": the entry stays unresolved, nothing is linked.
  Future<void> declineMediaLink() async {
    final MediaLinkProposal? proposal = state.mediaLinkProposal;
    if (proposal == null) return;
    if (!isClosed) emit(state.copyWith(mediaLinkProposal: null, mediaLinkUnresolved: true));
    await _mediaIdResolver.declineLink(
      source: proposal.sourceService,
      nativeId: proposal.sourceNativeId,
    );
  }

  /// Dialog dismissed without choosing: quietly keep the user-provider
  /// fallback, no mapping is cached.
  void dismissMediaLink() {
    if (state.mediaLinkProposal == null) return;
    if (isClosed) return;
    emit(state.copyWith(mediaLinkProposal: null, mediaLinkUnresolved: true));
  }

  /// Manual "Link metadata entry…" action on an unresolved details page: drop
  /// the remembered miss and run the resolution chain (and its dialog) again.
  Future<void> requestMediaLink() async {
    final Anime selectedAnime = state.selectedAnime;
    final Service provenance = serviceOfAnime(selectedAnime);
    final Service metadataService = state.loggedUser.settings.metadataService;
    if (metadataService == provenance) return;
    await _mediaIdResolver.forget(provenance, '${selectedAnime.id}');
    _promptedLinks.remove('${provenance.name}:${selectedAnime.id}->${metadataService.name}');
    await _getAnimeDetails(state.loggedUser, selectedAnime);
  }

  Future<void> _loadInstalledExtensions() async {
    try {
      _logger.i("Loading installed extensions for Aniyomi");
      Set<Extension> installedExtensions = await _extensionRepositoryAniyomi.getInstalledAnimeExtensions(
        state.loggedUser,
      );
      if (isClosed) return;
      emit(state.copyWith(installedExtensions: installedExtensions));
      _setSelectedExtension(state.loggedUser, state.selectedAnime);
    } catch (e, stackTrace) {
      handleError("Failed to load installed extensions $e", stackTrace: stackTrace);
    }
  }

  Future<void> _getAnimeInfoFromSelectedExtension(Extension selectedExtension) async {
    try {
      if (state.installedExtensions.isEmpty) {
        _logger.w("No installed extensions available to fetch anime info.");
        showSnackBarEffect(
          "No Installed Extensions",
          message: "Install some extensions if you want to watch some content",
          contentType: ContentType.warning,
        );
        return;
      }
      _logger.i(
        "Fetching Anime Info from extension ${selectedExtension.name} for ${state.selectedAnime.title.userPreferred}",
      );
      List<JSAnime> animeResults = await _extensionRepositoryAniyomi.getAnimeSearchResults(
        state.selectedAnime.title.userPreferred,
        selectedExtension,
      );
      if (animeResults.isEmpty) {
        _logger.w("No results found in ${selectedExtension.name} for ${state.selectedAnime.title.userPreferred}, trying alternative english title.");
        animeResults = await _extensionRepositoryAniyomi.getAnimeSearchResults(
          state.selectedAnime.title.english,
          selectedExtension,
        );
      }
      if (animeResults.isEmpty) {
        _logger.w("No results found in ${selectedExtension.name} for ${state.selectedAnime.title.english}, trying alternative native title.");
        animeResults = await _extensionRepositoryAniyomi.getAnimeSearchResults(
          state.selectedAnime.title.nativeTitle,
          selectedExtension,
        );
      }
      if (animeResults.isEmpty) {
        _logger.w("No results found in ${selectedExtension.name} for ${state.selectedAnime.title.nativeTitle}, trying alternative romaji title.");
        animeResults = await _extensionRepositoryAniyomi.getAnimeSearchResults(
          state.selectedAnime.title.romaji,
          selectedExtension,
        );
      }
      int selectedAnimeResultIndex = await _fuzzySelectAnimeResultIndex(animeResults);
      if (isClosed) return;
      emit(state.copyWith(extensionAnimeResults: animeResults, selectedAnimeResultIndex: selectedAnimeResultIndex));
      if (animeResults.isNotEmpty) {
        showSnackBarEffect(
          selectedExtension.name,
          message: "Found: ${animeResults[selectedAnimeResultIndex].getTitle()}",
          contentType: ContentType.success,
        );
      } else {
        showSnackBarEffect(
          selectedExtension.name,
          message:
              "No results found in ${selectedExtension.name} for ${state.selectedAnime.title.userPreferred}",
          contentType: ContentType.warning,
        );
      }
    } catch (e, stackTrace) {
      handleError("Error fetching Anime Info from selected extension: $e", stackTrace: stackTrace);
    }
  }

  Future<int> _fuzzySelectAnimeResultIndex(List<JSAnime> animeResults) async {
    // No candidates to score; 0 is the canonical index for an empty result set
    // (consumers guard on state.extensionAnimeResults.isEmpty before using it).
    if (animeResults.isEmpty) return 0;
    Set<String> animeTitles = {
      state.selectedAnime.title.userPreferred.toLowerCase(),
      if (state.selectedAnime.title.english.isNotEmpty)
        state.selectedAnime.title.english.toLowerCase(),
      if (state.selectedAnime.title.romaji.isNotEmpty)
        state.selectedAnime.title.romaji.toLowerCase(),
      if (state.selectedAnime.title.nativeTitle.isNotEmpty)
        state.selectedAnime.title.nativeTitle.toLowerCase(),
    };
    List<(int, JSAnime)> resultScores = [];
    for (var validTitle in animeTitles) {
      for (var animeResult in animeResults) {
        String testingTitle = animeResult.getTitle().toDartString().toLowerCase();
        int score = tokenSortRatio(validTitle, testingTitle);
        resultScores.add((score, animeResult));
      }
    }
    resultScores.sort((a, b) => b.$1.compareTo(a.$1));
    return animeResults.indexOf(resultScores.first.$2);
  }

  Future<bool> _getEpisodesFromSelectedExtension(
    Extension? selectedExtension,
    JSAnime? selectedJSAnime,
  ) async {
    if (selectedExtension == null) {
      _logger.w("No extension selected to fetch episodes.");
      showSnackBarEffect(
        "No Extension Selected",
        message: "Select an extension to fetch episodes.",
        contentType: ContentType.warning,
      );
      return false;
    } else if (selectedJSAnime == null) {
      _logger.w("No JSAnime selected to fetch episodes.");
      showSnackBarEffect(
        "No Anime Selected",
        message: "Select an anime to fetch episodes.",
        contentType: ContentType.warning,
      );
      return false;
    }
    try {
      _logger.i(
        "Fetching Episodes Info from extension ${selectedExtension.name} for ${state.selectedAnime.title.userPreferred}",
      );
      List<JSEpisode> episodeResults = await _extensionRepositoryAniyomi.getAnimeEpisodeList(
        selectedJSAnime,
        selectedExtension,
      );
      if (episodeResults.isNotEmpty) {
        List<JSEpisode> sortedEpisodes = episodeResults.sorted((animeEpisode1, animeEpisode2) => animeEpisode1.getEpisode_number().toInt() - animeEpisode2.getEpisode_number().toInt());
        if (isClosed) return false;
        emit(state.copyWith(extensionEpisodeResults: sortedEpisodes));
        _selectedEpisodesNotifier.updateSelectedJSEpisodes(sortedEpisodes);
        return true;
      } else {
        showSnackBarEffect(
          selectedExtension.name,
          message:
              "No episodes found in ${selectedExtension.name} for ${state.selectedAnime.title.userPreferred}",
          contentType: ContentType.warning,
        );
        return false;
      }
    } catch (e, stackTrace) {
      handleError("Error fetching Episodes Info from selected extension: $e", stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> _getVideosFromSelectedExtension(
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
      return false;
    } else if (selectedJSEpisode == null) {
      _logger.w("No JSEpisode selected to fetch videos.");
      showSnackBarEffect(
        "No Episode Selected",
        message: "Select an episode to fetch videos.",
        contentType: ContentType.warning,
      );
      return false;
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
        if (isClosed) return false;
        emit(state.copyWith(extensionVideoResults: videoResults.map((jVideo) => ext.Video.fromJVideo(jVideo)).toList()));
        return true;
      } else {
        showSnackBarEffect(
          selectedExtension.name,
          message:
              "No video links found in ${selectedExtension.name} for ${state.selectedAnime.title.userPreferred}",
          contentType: ContentType.warning,
        );
        return false;
      }
    } catch (e, stackTrace) {
      handleError("Error fetching Videos Info from selected extension: $e", stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> _getAlternativeImage(User loggedUser, Anime selectedAnime) async {
    try {
      _logger.i("Fetching Alternative Image for ${state.selectedAnime.title.userPreferred}");
      final AniZipLookupIds? ids = aniZipIdsForAnime(selectedAnime);
      if (ids == null) {
        _logger.w("No AniZip-addressable id for ${state.selectedAnime.title.userPreferred} (${serviceOfAnime(selectedAnime).name} record, no MAL id)");
        return;
      }
      final String alternateImage = await _episodeRepository.getAlternativeImage(
        malId: ids.malId,
        anilistId: ids.anilistId,
      );
      emit(state.copyWith(alternateImage: alternateImage));
    } on HttpServerException catch (e, stackTrace) {
      handleError("Error fetching Alternative Image:", responseBody: e.message, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      handleError("Error fetching Alternative Image: $e", stackTrace: stackTrace);
    }
  }

  Future<void> _getEpisodesDetails(User loggedUser, Anime selectedAnime) async {
    try {
      _logger.i("Fetching Episodes Details for ${state.selectedAnime.title.userPreferred}");
      final AniZipLookupIds? ids = aniZipIdsForAnime(selectedAnime);
      if (ids == null) {
        _logger.w("No AniZip-addressable id for ${state.selectedAnime.title.userPreferred} (${serviceOfAnime(selectedAnime).name} record, no MAL id)");
        return;
      }
      final List<EpisodeInfo> episodesInfo = await _episodeRepository.getEpisodeInfo(
        malId: ids.malId,
        anilistId: ids.anilistId,
      );
      emit(state.copyWith(episodesInfo: episodesInfo));
      _episodesInfoNotifier.updateSelectedEpisodeInfo(episodesInfo);
    } on HttpServerException catch (e, stackTrace) {
      handleError("Error fetching Episodes details:", responseBody: e.message, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      handleError("Error fetching Episodes Details: $e", stackTrace: stackTrace);
    }
  }

  Future<void> _getAnimeBanners(User loggedUser) async {
    try {
      _logger.i("Fetching Anime Banners for ${state.selectedAnime.title.userPreferred}");
      List<String> banners = await _animeRepository.getMediaCoverImages(loggedUser);
      emit(state.copyWith(banners: banners));
    } on HttpServerException catch (e, stackTrace) {
      handleError("Error fetching Anime banners:", responseBody: e.message, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      handleError("Error fetching Anime Banners: $e", stackTrace: stackTrace);
    }
  }

  Future<void> _setSelectedExtension(User loggedUser, Anime selectedAnime) async {
    try {
      Extension? savedExtension;
      switch (loggedUser) {
        case AnilistUserModel anilistUserModel:
          SettingsModel userSettings = anilistUserModel.settings as SettingsModel;
          savedExtension = userSettings.mediaExtensionConfigs[selectedAnime.id.toString()];
        case LocalUserModel localUserModel:
      }
      if (savedExtension != null) {
        await selectAnimeExtension(savedExtension.name);
        return;
      }
      if (isClosed) return;
      _showNoExtensionSelectedPrompt();
    } catch (e, stackTrace) {
      handleError("Error setting selected extension: $e", stackTrace: stackTrace);
    }
  }

  /// Proactive prompt when the details page opens without a usable extension.
  void _showNoExtensionSelectedPrompt() {
    if (isClosed) return;
    if (state.installedExtensions.isEmpty) {
      _logger.w("No installed extensions available to fetch episodes.");
      showSnackBarEffect(
        "No Installed Extensions",
        message: "Install some extensions to watch some content",
        contentType: ContentType.warning,
      );
      return;
    }
    _logger.w("No extension selected to fetch episodes.");
    showSnackBarEffect(
      "No Extension Selected",
      message: "Select an extension to fetch episodes.",
      contentType: ContentType.warning,
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'package:auto_route/auto_route.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo_lib/jmodels/jsmanga.dart';
import 'package:logger/logger.dart';
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:bloc/bloc.dart';
import 'package:unyo/application/states/manga_details_state.dart';
import 'package:unyo/core/di/locator.dart';

import 'package:unyo/core/notification/manga_genres_notifier.dart';
import 'package:unyo/core/notification/manga_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/data/repositories/extension_repository_aniyomi.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';
import 'package:unyo/domain/repositories/user_repository.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

class MangaDetailsCubit extends Cubit<MangaDetailsState> with EffectMixin<MangaDetailsState> {
  // Repositories
  final MangaRepository _mangaRepository;
  final ExtensionRepositoryAniyomi _extensionRepositoryAniyomi;
  final UserRepository _userRepository;

  // Notifiers / Subscriptions
  final MangaNotifier _selectedMangaNotifier;
  final MangaGenresNotifier _selectedMangaAdvancedSearchGenresFilters;
  final UserNotifier _loggedUserNotifier;
  final MediaListNotifier _selectedMediaListNotifier;
  late StreamSubscription<Manga> _selectedMangaSubscription;
  late StreamSubscription<User> _loggedUserSubscription;
  late StreamSubscription<MediaList> _selectedMediaListSubscription;

  // Logger
  final Logger _logger = sl<Logger>();

  MangaDetailsCubit(
    this._mangaRepository,
    this._loggedUserNotifier,
    this._selectedMangaNotifier,
    this._selectedMangaAdvancedSearchGenresFilters,
    this._selectedMediaListNotifier,
    this._extensionRepositoryAniyomi,
    this._userRepository,
  ) : super(
        MangaDetailsState(
          loggedUser: UserModel.empty(),
          selectedMediaList: MediaListModel.empty(),
          selectedManga: MangaModel.empty(),
          mediaListEntry: MediaListEntryModel.empty(),
          characters: (false, []),
          recommendations: (false, []),
          banners: [],
          alternateImage: '',
          installedExtensions: {},
          selectedExtension: null,
          userLoaded: false,
          extensionMangaResults: [],
          extensionEpisodeResults: [],
          extensionVideoResults: [],
        ),
      ) {
    _init();
  }

  @override
  MangaDetailsState copyStateWithEffects(MangaDetailsState state, List<AppEffect> effects) {
    return state.copyWith(effects: effects);
  }

  @override
  Future<void> close() {
    _loggedUserSubscription.cancel();
    _selectedMangaSubscription.cancel();
    _selectedMediaListSubscription.cancel();
    return super.close();
  }

  @override
  Logger get logger => _logger;

  void navigateBackToMangaPage(BuildContext context) {
    _logger.d("Returning to Manga Page");
    popRouteEffect(context);
    // close();
  }

  void _init() {
    _loggedUserSubscription = _loggedUserNotifier.userStream.listen((loggedUser) {
      emit(state.copyWith(loggedUser: loggedUser));
      if (!state.userLoaded) {
        _getMangaBanners(loggedUser);
        emit(state.copyWith(userLoaded: true));
      }
    });
    _selectedMangaSubscription = _selectedMangaNotifier.mangaStream.listen((manga) {
      _getMangaDetails(state.loggedUser, manga);
      emit(state.copyWith(selectedManga: manga));
    });
    _selectedMediaListSubscription = _selectedMediaListNotifier.mediaListStream.listen((mediaList) {
      emit(state.copyWith(selectedMediaList: mediaList));
    });
    _loadInstalledExtensions();
  }

  void navigateToMangaDetails(Manga manga, MediaList mediaList) {
    _logger.i("Navigating to Manga Details of ${manga.title.userPreferred}");
    _selectedMangaNotifier.updateSelectedManga(manga);
    _selectedMediaListNotifier.updateSelectedMediaList(mediaList);
  }

  void navigateToMangaAdvancedSearchScreenWithFilters(BuildContext context, String newAnimeGenre) {
    _logger.i("Navigating to Manga Advanced Search Filters");
    bool hasMangaSearchInStack = AutoRouter.of(context).stackData.any(
          (route) => route.name == "MangaAdvancedSearchRoute",
    );
    if (hasMangaSearchInStack) {
      popRouteEffect(context);
      _selectedMangaAdvancedSearchGenresFilters.updateSelectedMangaGenre(newAnimeGenre);
    } else {
      _selectedMangaAdvancedSearchGenresFilters.updateSelectedMangaGenre(newAnimeGenre);
      pushRouteEffect(path: "/mangasearch");
    }
  }

  Future<void> selectMangaExtension(String? selectedMangaExtensionName) async {
    Extension? selectedExtension =
        state.installedExtensions
            .where((extension) => selectedMangaExtensionName == extension.name)
            .firstOrNull;
    if (selectedExtension != null) {
      emit(state.copyWith(selectedExtension: selectedExtension));
      switch (state.loggedUser) {
        case AnilistUserModel anilistUserModel:
          // Persisting the choice must never block fetching from the extension.
          try {
            SettingsModel userSettings = anilistUserModel.settings as SettingsModel;
            Map<String, Extension> mediaExtensionsConfigUpdated = Map.from(userSettings.mediaExtensionConfigs);
            mediaExtensionsConfigUpdated.addAll({state.selectedManga.id.toString(): selectedExtension});
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
      await _getMangaInfoFromSelectedExtension(selectedExtension);
    } else {
      _logger.w("Selected extension $selectedMangaExtensionName not found among installed extensions.");
      showSnackBarEffect(
        "Extension Not Found",
        message: "The selected extension is not installed.",
        contentType: ContentType.warning,
      );
    }
  }

  Future<void> _getMangaDetails(User loggedUser, Manga selectedManga) async {
    try {
      _logger.i("Fetching Manga Details for ${state.selectedManga.title.userPreferred}");
      (bool, MangaDetails) mangaDetails = await _mangaRepository.getMangaDetails(
        selectedManga,
        loggedUser,
      );
      emit(
        state.copyWith(
          mediaListEntry: mangaDetails.$2.mediaListEntry,
          characters: (mangaDetails.$2.characters.isNotEmpty, mangaDetails.$2.characters),
          recommendations: (
            mangaDetails.$2.recommendedMangas.isNotEmpty,
            mangaDetails.$2.recommendedMangas,
          ),
        ),
      );
      if (mangaDetails.$2.recommendedMangas.isEmpty) {
        (bool, List<Manga>) trendingMangas = await _mangaRepository.getTrendingMangas(1, loggedUser);
        emit(state.copyWith(recommendations: (trendingMangas.$1, trendingMangas.$2.shuffled(Random()))));
      }
    } on HttpServerException catch (e, stackTrace) {
      handleError("Error fetching Manga details:", responseBody: e.message, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      handleError("Error fetching Manga Details: $e", stackTrace: stackTrace);
    }
  }

  Future<void> _loadInstalledExtensions() async {
    try {
      _logger.i("Loading installed extensions for Aniyomi");
      Set<Extension> installedExtensions = await _extensionRepositoryAniyomi.getInstalledMangaExtensions(
        state.loggedUser,
      );
      if (isClosed) return;
      emit(state.copyWith(installedExtensions: installedExtensions));
      _setSelectedExtension(state.loggedUser, state.selectedManga);
    } catch (e, stackTrace) {
      handleError("Failed to load installed extensions $e", stackTrace: stackTrace);
    }
  }

  Future<void> _getMangaInfoFromSelectedExtension(Extension selectedExtension) async {
    try {
      if (state.installedExtensions.isEmpty) {
        _logger.w("No installed extensions available to fetch manga info.");
        showSnackBarEffect(
          "No Installed Extensions",
          message: "Install some extensions if you want to watch some content",
          contentType: ContentType.warning,
        );
        return;
      }
      _logger.i(
        "Fetching Manga Info from extension ${selectedExtension.name} for ${state.selectedManga.title.userPreferred}",
      );
      List<JSManga> mangaResults = await _extensionRepositoryAniyomi.getMangaSearchResults(
        state.selectedManga.title.userPreferred,
        selectedExtension,
      );
      if (isClosed) return;
      emit(state.copyWith(extensionMangaResults: mangaResults));
    } catch (e, stackTrace) {
      handleError("Error fetching Manga Info from selected extension: $e", stackTrace: stackTrace);
    }
  }

  // Future<void> _getChaptersDetails(User loggedUser, Manga selectedManga) async {
  //   try {
  //     switch (loggedUser.settings.episodeService) {
  //       case EpisodeService.anizip:
  //         _logger.i("Fetching Episodes Details from Anizip for ${state.selectedManga.title}");
  //         late List<EpisodeInfo> episodesInfo;
  //         if (loggedUser.settings.service == Service.anilist) {
  //           episodesInfo = await _episodeRepositoryAnizip.getEpisodeInfo(malId: -1, anilistId: selectedManga.id);
  //         } else {
  //           episodesInfo = await _episodeRepositoryAnizip.getEpisodeInfo(malId: selectedManga.idMal, anilistId: -1);
  //         }
  //         emit(state.copyWith(episodesInfo: episodesInfo));
  //       case EpisodeService.kitsu:
  //         _logger.i("Fetching Episodes Details from Kitsu for ${state.selectedManga.title}");
  //     }
  //   } on HttpServerException catch (e, stackTrace) {
  //     handleError("Error fetching Episodes details:", responseBody: e.message, stackTrace: stackTrace);
  //   } catch (e, stackTrace) {
  //     handleError("Error fetching Episodes Details: $e", stackTrace: stackTrace);
  //   }
  // }

  Future<void> _getMangaBanners(User loggedUser) async {
    try {
      _logger.i("Fetching Manga Banners for ${state.selectedManga.title.userPreferred}");
      List<String> banners = await _mangaRepository.getMediaCoverImages(loggedUser);
      emit(state.copyWith(banners: banners));
    } on HttpServerException catch (e, stackTrace) {
      handleError("Error fetching Manga banners:", responseBody: e.message, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      handleError("Error fetching Manga Banners: $e", stackTrace: stackTrace);
    }
  }

  /// Handles a tap on a chapter button in the manga details page.
  ///
  /// Named after the anime-side equivalent (`openAnimeServerSelectionDrawer`).
  /// There is no manga reader in the app yet, so this only gives feedback
  /// instead of silently swallowing the tap.
  void openMangaServerSelectionDrawer(BuildContext context, int chapterIndex) {
    if (isClosed) return;
    _logger.i("Chapter ${chapterIndex + 1} pressed for ${state.selectedManga.title.userPreferred}");
    if (state.selectedExtension == null) {
      _logger.w("No extension selected to fetch chapters.");
      showSnackBarEffect(
        "No Extension Selected",
        message: "Select an extension to fetch chapters.",
        contentType: ContentType.warning,
      );
      return;
    }
    showSnackBarEffect(
      "Manga Reader",
      message: "The manga reader is not available yet.",
      contentType: ContentType.warning,
    );
  }

  Future<void> _setSelectedExtension(User loggedUser, Manga selectedManga) async {
    try {
      Extension? savedExtension;
      switch (loggedUser) {
        case AnilistUserModel anilistUserModel:
          SettingsModel userSettings = anilistUserModel.settings as SettingsModel;
          savedExtension = userSettings.mediaExtensionConfigs[selectedManga.id.toString()];
        case LocalUserModel localUserModel:
      }
      if (savedExtension != null) {
        await selectMangaExtension(savedExtension.name);
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
      _logger.w("No installed extensions available to fetch manga info.");
      showSnackBarEffect(
        "No Installed Extensions",
        message: "Install some extensions to watch some content",
        contentType: ContentType.warning,
      );
      return;
    }
    _logger.w("No extension selected to fetch chapters.");
    showSnackBarEffect(
      "No Extension Selected",
      message: "Select an extension to fetch chapters.",
      contentType: ContentType.warning,
    );
  }
}

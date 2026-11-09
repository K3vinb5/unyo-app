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
import 'package:unyo/application/states/episode_count.dart';
import 'package:unyo/application/states/manga_details_state.dart';
import 'package:unyo/core/di/locator.dart';

import 'package:unyo/core/notification/manga_genres_notifier.dart';
import 'package:unyo/core/notification/manga_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/media/media_link_exception.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/extension_repository_aniyomi.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';
import 'package:unyo/domain/repositories/user_repository.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/media/media_character.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/dialogs/character_dialog.dart';
import 'package:unyo/presentation/dialogs/manga_details_media_entry_dialog.dart';
import 'package:unyo/presentation/widgets/styled/unyo_date_picker.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

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
  final ReloadNotifier _reloadNotifier;
  late StreamSubscription<Manga> _selectedMangaSubscription;
  late StreamSubscription<User> _loggedUserSubscription;
  late StreamSubscription<MediaList> _selectedMediaListSubscription;

  /// Extension the page was showing when a switch arrived before
  /// [MangaDetailsState.installedExtensions] had loaded. The load callback
  /// consumes it, so a deferred switch resolves exactly like an immediate one
  /// (saved mapping first, then this extension, never a prompt).
  Extension? _deferredSwitchPreviousExtension;

  /// Whether a title switch is waiting for the installed extensions to load.
  bool _hasDeferredSwitch = false;

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
    this._reloadNotifier,
  ) : super(
        MangaDetailsState(
          loggedUser: UserModel.empty(),
          selectedMediaList: MediaListModel.empty(),
          selectedManga: MangaModel.empty(),
          mediaListEntry: MediaListEntryModel.empty(),
          newMediaListEntry: MediaListEntryModel.empty(),
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
      _handleSelectedMangaChanged(manga);
    });
    _selectedMediaListSubscription = _selectedMediaListNotifier.mediaListStream.listen((mediaList) {
      emit(state.copyWith(selectedMediaList: mediaList));
    });
    _loadInstalledExtensions();
  }

  /// Applies a selection coming from the notifier.
  ///
  /// A different manga id means the open details page was re-pointed at another
  /// title: every per-title extension field (`extensionMangaResults`,
  /// `extensionEpisodeResults`, ...) still describes the previous title, so it is
  /// reset and the new title is resolved against an extension again. A repeated
  /// emission of the same id is just an echo and must not re-resolve anything.
  void _handleSelectedMangaChanged(Manga manga) {
    bool isSameTitle = manga.id == state.selectedManga.id;
    _getMangaDetails(state.loggedUser, manga);
    if (isSameTitle) {
      emit(state.copyWith(selectedManga: manga));
      return;
    }
    Extension? previousExtension = state.selectedExtension;
    _logger.i(
      "Switched manga details to ${manga.title.userPreferred} (${manga.id}), resetting the per-title extension state",
    );
    emit(state.copyWith(
      selectedManga: manga,
      selectedExtension: null,
      extensionMangaResults: [],
      extensionEpisodeResults: [],
      extensionVideoResults: [],
    ));
    _resolveExtensionForSwitchedManga(manga, previousExtension);
  }

  /// Resolves the extension of [manga] after a title switch: the saved mapping
  /// wins, otherwise the extension the page was already using is carried over.
  /// With neither, the page stays silent — only a chapter tap warns.
  Future<void> _resolveExtensionForSwitchedManga(Manga manga, Extension? previousExtension) async {
    if (state.installedExtensions.isEmpty) {
      // `_loadInstalledExtensions` resolves the then-selected manga once it lands,
      // so resolving here would only fetch twice. Remember that the pending
      // resolution comes from a switch, so the load callback stays silent.
      _deferredSwitchPreviousExtension = previousExtension;
      _hasDeferredSwitch = true;
      _logger.d("Extensions are not loaded yet, leaving the resolution of manga ${manga.id} to the initial load.");
      return;
    }
    Extension? carriedExtension = previousExtension != null &&
            state.installedExtensions.any((extension) => extension.name == previousExtension.name)
        ? previousExtension
        : null;
    await _setSelectedExtension(
      state.loggedUser,
      manga,
      carriedExtension: carriedExtension,
    );
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
        case ShikimoriUserModel shikimoriUserModel:
          try {
            SettingsModel userSettings = shikimoriUserModel.settings as SettingsModel;
            Map<String, Extension> mediaExtensionsConfigUpdated = Map.from(userSettings.mediaExtensionConfigs);
            mediaExtensionsConfigUpdated.addAll({state.selectedManga.id.toString(): selectedExtension});
            await _userRepository.updateUserInfo(
              shikimoriUserModel.copyWith(
                settings: userSettings.copyWith(mediaExtensionConfigs: mediaExtensionsConfigUpdated),
              ),
            );
          } catch (e, stackTrace) {
            _logger.w("Failed to persist the selected extension: $e", stackTrace: stackTrace);
          }
        case LocalUserModel _:
      }
      if (isClosed) return;
      await _getMangaInfoFromSelectedExtension(selectedExtension);
    } else {
      _logger.w("Selected extension $selectedMangaExtensionName not found among installed extensions.");
      showSnackBarEffect(
        'error_extension_not_found',
        messageKey: 'error_extension_not_installed',
        contentType: ContentType.warning,
      );
    }
  }

  /// Opens the manga list editor (WP #167): the same editor the anime page
  /// has, with chapters as the progress range.
  void openMangaDetailsMediaEntryDialog(BuildContext context) {
    showWidgetDialogEffect(dialog: MangaDetailsMediaEntryDialog(cubit: this));
  }

  Future<void> updateMediaListEntryStatus(String? newStatus) async {
    if (newStatus == null) return;
    try {
      emit(state.copyWith(newMediaListEntry: _draft.copyWith(status: newStatus)));
    } catch (e, stackTrace) {
      handleError("Error updating Manga Entry status: $e", stackTrace: stackTrace);
    }
  }

  Future<void> updateMediaListEntryProgress(int? newProgress) async {
    if (newProgress == null) return;
    try {
      emit(state.copyWith(newMediaListEntry: _draft.copyWith(progress: newProgress)));
    } catch (e, stackTrace) {
      handleError("Error updating Manga Entry progress: $e", stackTrace: stackTrace);
    }
  }

  Future<void> updateMediaListEntryScore(double? newScore) async {
    if (newScore == null) return;
    try {
      emit(state.copyWith(newMediaListEntry: _draft.copyWith(score: newScore)));
    } catch (e, stackTrace) {
      handleError("Error updating Manga Entry score: $e", stackTrace: stackTrace);
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
      emit(state.copyWith(
        newMediaListEntry: _draft.copyWith(
          startedAt: [
            selectedDateTime.day.toString(),
            selectedDateTime.month.toString(),
            selectedDateTime.year.toString(),
          ],
        ),
      ));
    } catch (e, stackTrace) {
      handleError("Error updating Manga Entry started at: $e", stackTrace: stackTrace);
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
      emit(state.copyWith(
        newMediaListEntry: _draft.copyWith(
          completedAt: [
            selectedDateTime.day.toString(),
            selectedDateTime.month.toString(),
            selectedDateTime.year.toString(),
          ],
        ),
      ));
    } catch (e, stackTrace) {
      handleError("Error updating Manga Entry completed at: $e", stackTrace: stackTrace);
    }
  }

  /// Persists the editor's draft.
  Future<void> updateMediaListEntry(BuildContext context) async {
    // The editor clamps chapters into the chapter range for display and its
    // slider never reports that clamped initial value back, so persist what the
    // user actually saw (same rule as the anime editor).
    final MediaListEntry desiredMediaListEntry = _draft.copyWith(
      progress: EpisodeCount.progressForSave(
        progress: _draft.progress,
        episodeCount: state.selectedManga.chapters,
      ),
    );
    await _writeMediaListEntry(desiredMediaListEntry, context, operation: "Updating");
  }

  /// Removes the entry from the user's list (the editor's trash action).
  ///
  /// A removal is an update carrying no list status
  /// ([MediaListEntryModel.empty]) — the signal every tracker write path
  /// already understands (Shikimori `DELETE /user_rates/:id`, AniList
  /// `DeleteMediaListEntry`).
  Future<void> removeMediaListEntry(BuildContext context) async {
    await _writeMediaListEntry(MediaListEntryModel.empty(), context, operation: "Removing");
  }

  /// The editor's draft entry. A list entry is a patch-shaped value, so the
  /// draft is always a copy — never the stored entry itself.
  MediaListEntryModel get _draft {
    final MediaListEntry entry = state.newMediaListEntry;
    return entry is MediaListEntryModel ? entry : MediaListEntryModel.empty();
  }

  Future<void> _writeMediaListEntry(
    MediaListEntry mediaListEntry,
    BuildContext context, {
    required String operation,
  }) async {
    try {
      _logger.i("$operation Media List Entry to $mediaListEntry");
      final MediaListEntry stored = await _mangaRepository.updateMediaListEntry(
        mediaListEntry,
        state.selectedManga,
        state.loggedUser,
      );
      _emitMediaListEntry(stored);
      // Home renders the user's manga lists (and their progress), so every
      // successful write reloads it (WP #110 rule, shared with anime).
      _reloadNotifier.emitReload(ReloadType.homeMediaListEntryUpdated);
    } on MediaLinkUnresolvedException catch (e, stackTrace) {
      // Writing to a guessed id would corrupt another entry: nothing was sent.
      _logger.w("Skipped the manga list update, no verified user-provider entry: $e", stackTrace: stackTrace);
      showSnackBarEffect(
        'error_list_not_updated',
        messageKey: 'error_entry_not_matched_account',
        messageArgs: <String, String>{
          'service': TextUtils.capitalize(state.loggedUser.settings.userService.name),
        },
        contentType: ContentType.warning,
      );
      // Keep the editor open: nothing was written, so closing it would imply a save.
      return;
    } on HttpServerException catch (e, stackTrace) {
      handleError("Error updating Manga Entry:", responseBody: e.message, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      handleError("Error updating Manga Entry: $e", stackTrace: stackTrace);
    }
    if (!context.mounted) return;
    popRouteEffect(context);
  }

  void _emitMediaListEntry(MediaListEntry mediaListEntry) {
    emit(state.copyWith(mediaListEntry: mediaListEntry, newMediaListEntry: mediaListEntry));
  }

  Future<void> _getMangaDetails(User loggedUser, Manga selectedManga) async {
    try {
      _logger.i("Fetching Manga Details for ${state.selectedManga.title.userPreferred}");
      (bool, MangaDetails) mangaDetails = await _mangaRepository.getMangaDetails(
        selectedManga,
        loggedUser,
      );
      // List state always belongs to the user provider (WP #61 decision 3): a
      // metadata-provider payload must never seed the list editor, or a save
      // would write that provider's (possibly empty) values.
      final MediaListEntry listEntry =
          loggedUser.settings.metadataService == loggedUser.settings.userService
              ? mangaDetails.$2.mediaListEntry
              : await _getUserMediaListEntry(loggedUser, selectedManga);
      emit(
        state.copyWith(
          mediaListEntry: listEntry,
          newMediaListEntry: listEntry,
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

  Future<MediaListEntry> _getUserMediaListEntry(User loggedUser, Manga selectedManga) async {
    try {
      _logger.i("Fetching User Media List Entry for ${selectedManga.title.userPreferred}");
      return await _mangaRepository.getMediaListEntry(selectedManga, loggedUser);
    } on HttpServerException catch (e, stackTrace) {
      handleError("Error fetching User Media List entry:", responseBody: e.message, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      handleError("Error fetching User Media List Entry: $e", stackTrace: stackTrace);
    }
    return MediaListEntryModel.empty();
  }

  Future<void> _loadInstalledExtensions() async {
    try {
      _logger.i("Loading installed extensions for Aniyomi");
      Set<Extension> installedExtensions = await _extensionRepositoryAniyomi.getInstalledMangaExtensions(
        state.loggedUser,
      );
      if (isClosed) return;
      emit(state.copyWith(installedExtensions: installedExtensions));
      if (_hasDeferredSwitch) {
        // A switch landed before the extensions did: resolve it the way an
        // immediate switch would have (carry-over included), instead of the
        // initial-page path.
        _hasDeferredSwitch = false;
        final Extension? previousExtension = _deferredSwitchPreviousExtension;
        _deferredSwitchPreviousExtension = null;
        await _resolveExtensionForSwitchedManga(state.selectedManga, previousExtension);
        return;
      }
      // Opening the page never nags (WP #87): no prompt when nothing is saved.
      _setSelectedExtension(state.loggedUser, state.selectedManga);
    } catch (e, stackTrace) {
      handleError("Failed to load installed extensions $e", stackTrace: stackTrace);
    }
  }

  Future<void> _getMangaInfoFromSelectedExtension(Extension selectedExtension) async {
    final Manga requestedManga = state.selectedManga;
    final int requestedMangaId = requestedManga.id;
    try {
      if (state.installedExtensions.isEmpty) {
        _logger.w("No installed extensions available to fetch manga info.");
        showSnackBarEffect(
          'error_no_installed_extensions',
          messageKey: 'error_no_extensions_install_hint',
          contentType: ContentType.warning,
        );
        return;
      }
      _logger.i(
        "Fetching Manga Info from extension ${selectedExtension.name} for ${requestedManga.title.userPreferred}",
      );
      List<JSManga> mangaResults = await _extensionRepositoryAniyomi.getMangaSearchResults(
        requestedManga.title.userPreferred,
        selectedExtension,
      );
      // The page may have been re-pointed at another title while the search
      // ran: those results describe the old title and must not overwrite the
      // cleared state of the title that is open now.
      if (isClosed || state.selectedManga.id != requestedMangaId) {
        _logger.d("Discarding extension results for manga $requestedMangaId, the page moved on.");
        return;
      }
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

  /// Opens the read-only character dialog from the already-loaded list.
  void openCharacterDialog(MediaCharacter character) {
    showWidgetDialogEffect(dialog: CharacterDialog(character: character));
  }

  /// Handles a tap on a chapter button in the manga details page.
  ///
  /// Named after the anime-side equivalent (`openAnimeServerSelectionDrawer`).
  /// There is no manga reader in the app yet, so this only gives feedback
  /// instead of silently swallowing the tap.
  void openMangaServerSelectionDrawer(BuildContext context, int chapterIndex) {
    if (isClosed) return;
    _logger.i("Chapter ${chapterIndex + 1} pressed for ${state.selectedManga.title.userPreferred}");
    // Nothing to pick from: point at the Extensions tab instead of asking for a
    // selection the dropdown cannot offer.
    if (state.installedExtensions.isEmpty) {
      _logger.w("No installed extensions to fetch chapters.");
      showSnackBarEffect(
        'error_no_installed_extensions',
        messageKey: 'error_no_extensions_open_tab',
        contentType: ContentType.warning,
      );
      return;
    }
    if (state.selectedExtension == null) {
      _logger.w("No extension selected to fetch chapters.");
      showSnackBarEffect(
        'error_no_extension_selected',
        messageKey: 'error_select_extension_chapters',
        contentType: ContentType.warning,
      );
      return;
    }
    showSnackBarEffect(
      'common_manga_reader',
      messageKey: 'error_manga_reader_unavailable',
      contentType: ContentType.warning,
    );
  }

  Future<void> _setSelectedExtension(
    User loggedUser,
    Manga selectedManga, {
    Extension? carriedExtension,
  }) async {
    try {
      Extension? savedExtension;
      switch (loggedUser) {
        case AnilistUserModel anilistUserModel:
          SettingsModel userSettings = anilistUserModel.settings as SettingsModel;
          savedExtension = userSettings.mediaExtensionConfigs[selectedManga.id.toString()];
        case ShikimoriUserModel shikimoriUserModel:
          SettingsModel userSettings = shikimoriUserModel.settings as SettingsModel;
          savedExtension = userSettings.mediaExtensionConfigs[selectedManga.id.toString()];
        case LocalUserModel _:
      }
      if (savedExtension != null) {
        await selectMangaExtension(savedExtension.name);
        return;
      }
      if (carriedExtension != null) {
        // Switching titles from a loaded screen implies the user is already in
        // that extension, so the choice is carried over instead of prompting.
        _logger.i("Carrying extension ${carriedExtension.name} over to manga ${selectedManga.id}.");
        emit(state.copyWith(selectedExtension: carriedExtension));
        await _getMangaInfoFromSelectedExtension(carriedExtension);
        return;
      }
      if (isClosed) return;
      // Nothing to restore (WP #87/#88): the page stays silent, and the warning
      // fires when the user taps a chapter without a selected extension.
      _logger.d("No saved extension found for manga ${selectedManga.id}; leaving the pick to the user.");
    } catch (e, stackTrace) {
      handleError("Error setting selected extension: $e", stackTrace: stackTrace);
    }
  }
}

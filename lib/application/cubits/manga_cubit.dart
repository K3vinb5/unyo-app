import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:logger/logger.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/manga_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/factories/manga_repository_factory.dart';

import 'package:unyo/core/notification/manga_genres_notifier.dart';
import 'package:unyo/core/notification/manga_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'effect_mixin.dart';

class MangaCubit extends Cubit<MangaState> with EffectMixin<MangaState> {
  final MangaRepository _mangaRepository;
  final UserNotifier _loggedUserNotifier;
  final MangaNotifier _selectedMangaNotifier;
  final MangaGenresNotifier _selectedMangaAdvancedSearchGenresFilters;
  final MediaListNotifier _selectedMediaListNotifier;
  final ReloadNotifier _reloadNotifier;
  late StreamSubscription<User> _loggedUserSubscription;
  late StreamSubscription<ReloadType> _reloadSubscription;
  bool _refreshInFlight = false;
  bool _refreshQueued = false;
  bool _queuedProviderSwitch = false;
  final Logger _logger = sl<Logger>();

  MangaCubit(
    this._mangaRepository,
    this._loggedUserNotifier,
    this._selectedMangaNotifier,
    this._selectedMangaAdvancedSearchGenresFilters,
    this._selectedMediaListNotifier,
    this._reloadNotifier,
  )
    : super(
        MangaState(
          trending: (false, []),
          popular: (false, []),
          recentlyCompleted: (false, []),
          upcoming: (false, []),
          banners: [],
          loggedUser: UserModel.empty(),
          isLoading: true,
          userLoaded: false,
        ),
      ) {
    _init();
  }

  @override
  MangaState copyStateWithEffects(MangaState state, List<AppEffect> effects) {
    return state.copyWith(effects: effects);
  }

  @override
  Future<void> close() {
    _loggedUserSubscription.cancel();
    _reloadSubscription.cancel();
    return super.close();
  }

  @override
  Logger get logger => _logger;

  // TODO develop some loading states for the widgets and remove the awaits to make the load look faster
  void _init() async {
    _loggedUserSubscription = _loggedUserNotifier.userStream.listen((
      loggedUser,
    ) async {
      emit(state.copyWith(loggedUser: loggedUser));
      if (!state.userLoaded) {
        await _refreshAll(isProviderSwitch: false);
        emit(state.copyWith(userLoaded: true, isLoading: false));
      }
    });
    _reloadSubscription = _reloadNotifier.reloadStream.listen((reloadType) async {
      if (reloadType != ReloadType.newMetadataService) {
        return;
      }
      _logger.i("Reloading manga data due to new metadata service");
      await _refreshAll(isProviderSwitch: true);
    });
  }

  /// The four browse lists, fetched in one place so the initial load and the
  /// metadata-service reload cannot drift apart.
  ///
  /// Refreshes never drop a request: a switch that arrives while a fetch is
  /// running is coalesced and replayed once that fetch settles, because the
  /// running pass started for an older provider (and may even still be the
  /// initial load). Every pass reads [MangaState.loggedUser] as it fetches, so
  /// the replay always runs against the newest provider.
  Future<void> _refreshAll({required bool isProviderSwitch}) async {
    if (_refreshInFlight) {
      _logger.d("Queueing manga refresh: a refresh is already in flight");
      _refreshQueued = true;
      _queuedProviderSwitch = _queuedProviderSwitch || isProviderSwitch;
      return;
    }
    _refreshInFlight = true;
    try {
      bool providerSwitch = isProviderSwitch;
      do {
        _refreshQueued = false;
        _queuedProviderSwitch = false;
        if (providerSwitch) {
          // Drop the previous provider's rows before refetching: they carry
          // that provider's entity types and must not stay openable.
          _clearLists();
        }
        await _fetchAll(ignoreCache: providerSwitch);
        providerSwitch = _queuedProviderSwitch;
      } while (_refreshQueued);
    } finally {
      _refreshInFlight = false;
    }
  }

  Future<void> _fetchAll({required bool ignoreCache}) async {
    User loggedUser = state.loggedUser;
    Service metadataService = loggedUser.settings.metadataService;
    if (!MangaRepositoryFactory.supportsMetadataService(metadataService)) {
      _logger.w("Manga is not available with ${metadataService.name}");
      emit(
        state.copyWith(
          metadataServiceSupported: false,
          trending: (true, []),
          recentlyCompleted: (true, []),
          popular: (true, []),
          upcoming: (true, []),
          banners: [],
        ),
      );
      return;
    }
    emit(state.copyWith(metadataServiceSupported: true));
    await _fetchTrending(1, loggedUser, ignoreCache: ignoreCache);
    await _fetchRecentlyCompleted(1, loggedUser, ignoreCache: ignoreCache);
    await _fetchPopular(1, loggedUser, ignoreCache: ignoreCache);
    await _fetchUpcoming(1, loggedUser, ignoreCache: ignoreCache);
  }

  void _clearLists() {
    emit(
      state.copyWith(
        trending: (false, []),
        recentlyCompleted: (false, []),
        popular: (false, []),
        upcoming: (false, []),
        banners: [],
      ),
    );
  }

  void navigateToAdvancedSearch(BuildContext context) {
    _logger.i("Navigating to Manga Advanced Search");
    _selectedMangaAdvancedSearchGenresFilters.updateSelectedMangaGenre("");
    pushRouteEffect(path: "/mangasearch");
  }

  void navigateToMangaDetails(Manga manga, MediaList mediaList) {
    _logger.i("Navigating to Anime Details of ${manga.title.userPreferred}");
    _selectedMangaNotifier.updateSelectedManga(manga);
    _selectedMediaListNotifier.updateSelectedMediaList(mediaList);
    pushRouteEffect(path: "/mangadetails");
  }

  Future<void> _fetchTrending(int page, User loggedUser, {bool ignoreCache = false}) async {
    try {
      _logger.i("Fetching trending manga");
      (bool, List<Manga>) trending = await _mangaRepository
          .getTrendingMangas(page, loggedUser, ignoreCache: ignoreCache);
      emit(state.copyWith(trending: trending));
      if (page == 1) {
        emit(
          state.copyWith(
            banners:
                trending.$2
                    .where((manga) => manga.bannerImage != "")
                    .toList(),
          ),
        );
      }
    } catch (e, stackTrace) {
      handleError("Failed to fetch trending manga $e", stackTrace: stackTrace);
    }
  }

  Future<void> _fetchPopular(int page, User loggedUser, {bool ignoreCache = false}) async {
    try {
      _logger.i("Fetching popular manga");
      (bool, List<Manga>) popular = await _mangaRepository
          .getPopularMangas(page, loggedUser, ignoreCache: ignoreCache);
      emit(state.copyWith(popular: popular));
    } catch (e, stackTrace) {
      handleError("Failed to fetch popular manga $e", stackTrace: stackTrace);
    }
  }

  Future<void> _fetchRecentlyCompleted(int page, User loggedUser, {bool ignoreCache = false}) async {
    try {
      _logger.i("Fetching recently completed manga");
      (bool, List<Manga>) recentlyCompleted = await _mangaRepository
          .getRecentlyCompletedMangas(page, loggedUser, ignoreCache: ignoreCache);
      emit(state.copyWith(recentlyCompleted: recentlyCompleted));
    } catch (e, stackTrace) {
      handleError(
        "Failed to fetch recently completed manga $e",
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _fetchUpcoming(int page, User loggedUser, {bool ignoreCache = false}) async {
    try {
      _logger.i("Fetching upcoming manga");
      (bool, List<Manga>) upcoming = await _mangaRepository
          .getUpcomingMangas(page, loggedUser, ignoreCache: ignoreCache);
      emit(state.copyWith(upcoming: upcoming));
    } catch (e, stackTrace) {
      handleError("Failed to fetch upcoming manga $e", stackTrace: stackTrace);
    }
  }
}

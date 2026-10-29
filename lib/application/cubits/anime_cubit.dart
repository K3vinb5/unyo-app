// External dependencies
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/anime_state.dart';
import 'package:unyo/core/di/locator.dart';

import 'package:unyo/core/notification/anime_genres_notifier.dart';
import 'package:unyo/core/notification/anime_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/domain/entities/user/user.dart';

import '../../core/notification/reload/reload_notifier.dart';

class AnimeCubit extends Cubit<AnimeState> with EffectMixin<AnimeState> {
  final AnimeRepository _animeRepository;
  final UserNotifier _loggedUserNotifier;
  final AnimeNotifier _selectedAnimeNotifier;
  final AnimeGenresNotifier _selectedAnimeAdvancedSearchGenresFilters;
  final MediaListNotifier _selectedMediaListNotifier;
  final ReloadNotifier _reloadNotifier;
  late StreamSubscription<User> _loggedUserSubscription;
  late StreamSubscription<ReloadType> _reloadSubscription;
  bool _refreshInFlight = false;
  final Logger _logger = sl<Logger>();

  AnimeCubit(
    this._animeRepository,
    this._loggedUserNotifier,
    this._selectedAnimeNotifier,
    this._selectedAnimeAdvancedSearchGenresFilters,
    this._selectedMediaListNotifier,
    this._reloadNotifier,
  )
    : super(
        AnimeState(
          recentlyReleased: (false, []),
          popular: (false, []),
          trending: (false, []),
          recentlyCompleted: (false, []),
          upcoming: (false, []),
          banners: [],
          loggedUser: UserModel.empty(),
          isLoading: true,
          selectionDialogLoading: true,
          userLoaded: false,
        ),
      ) {
    _init();
  }

  @override
  AnimeState copyStateWithEffects(AnimeState state, List<AppEffect> effects) {
    return state.copyWith(effects: effects);
  }

  @override
  Logger get logger => _logger;

  @override
  Future<void> close() {
    _loggedUserSubscription.cancel();
    _reloadSubscription.cancel();
    return super.close();
  }

  // TODO develop some loading states for the widgets and remove the awaits to make the load look faster
  void _init() async {
    _loggedUserSubscription = _loggedUserNotifier.userStream.listen((
      loggedUser,
    ) async {
      emit(state.copyWith(loggedUser: loggedUser));
      if (!state.userLoaded) {
        await _refreshAll(loggedUser);
        emit(state.copyWith(userLoaded: true, isLoading: false));
      }
    });
    _reloadSubscription = _reloadNotifier.reloadStream.listen((reloadType) async {
      if (reloadType != ReloadType.newMetadataService) {
        return;
      }
      _logger.i("Reloading Anime Screen due to new metadata service");
      if (!state.userLoaded) {
        // Nothing fetched yet: the initial load still to come already runs
        // against the new provider, so refetching here would only duplicate it.
        return;
      }
      // Drop the previous provider's rows before refetching: they carry that
      // provider's entity types and must not stay openable from the screen.
      _clearLists();
      await _refreshAll(state.loggedUser, ignoreCache: true);
    });
  }

  /// The five browse lists, fetched in one place so the initial load and the
  /// metadata-service reload cannot drift apart.
  Future<void> _refreshAll(User loggedUser, {bool ignoreCache = false}) async {
    if (_refreshInFlight) {
      _logger.d("Skipping anime refresh: a refresh is already in flight");
      return;
    }
    _refreshInFlight = true;
    try {
      await _fetchRecentlyReleased(1, loggedUser, ignoreCache: ignoreCache);
      await _fetchTrending(1, loggedUser, ignoreCache: ignoreCache);
      await _fetchRecentlyCompleted(1, loggedUser, ignoreCache: ignoreCache);
      await _fetchPopular(1, loggedUser, ignoreCache: ignoreCache);
      await _fetchUpcoming(1, loggedUser, ignoreCache: ignoreCache);
    } finally {
      _refreshInFlight = false;
    }
  }

  void _clearLists() {
    emit(
      state.copyWith(
        recentlyReleased: (false, []),
        trending: (false, []),
        recentlyCompleted: (false, []),
        popular: (false, []),
        upcoming: (false, []),
        banners: [],
      ),
    );
  }

  void navigateToCalendar(BuildContext context) {
    _logger.i("Navigating to Anime Calendar");
    pushRouteEffect(path: "/calendar");
  }

  void navigateToAdvancedSearch(BuildContext context) {
    _logger.i("Navigating to Anime Advanced Search");
    _selectedAnimeAdvancedSearchGenresFilters.updateSelectedAnimeGenre("");
    pushRouteEffect(path: "/animesearch");
  }

  void navigateToAnimeDetails(Anime anime, MediaList mediaList) {
    _logger.i("Navigating to Anime Details of ${anime.title.userPreferred}");
    _selectedAnimeNotifier.updateSelectedAnime(anime);
    _selectedMediaListNotifier.updateSelectedMediaList(mediaList);
    pushRouteEffect(path: "/animedetails");
  }

  Future<void> _fetchRecentlyReleased(int page, User loggedUser, {bool ignoreCache = false}) async {
    try {
      _logger.i("Fetching recently released anime");
      (bool, List<Anime>) recentlyReleased = await _animeRepository
          .getRecentlyReleasedAnimes(page, loggedUser, ignoreCache: ignoreCache);
      emit(state.copyWith(recentlyReleased: recentlyReleased));
    } on HttpServerException catch (e, stackTrace) {
      handleError(
        "Failed to fetch recently released anime:",
        responseBody: e.message,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      handleError(
        "Failed to fetch recently released anime $e",
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _fetchTrending(int page, User loggedUser, {bool ignoreCache = false}) async {
    try {
      _logger.i("Fetching trending anime");
      (bool, List<Anime>) trending = await _animeRepository
          .getTrendingAnimes(page, loggedUser, ignoreCache: ignoreCache);
      emit(state.copyWith(trending: trending));
      if (page == 1) {
        List<Anime> banners = trending.$2.where((anime) => anime.bannerImage != "").toList();
        emit(
          state.copyWith(
            banners: banners.sublist(
              0,
              banners.length > 20 ? 20 : banners.length,
            ),
          ),
        );
      }
    } on HttpServerException catch (e, stackTrace) {
      handleError(
        "Failed to fetch trending anime:",
        responseBody: e.message,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      handleError("Failed to fetch trending anime $e", stackTrace: stackTrace);
    }
  }

  Future<void> _fetchPopular(int page, User loggedUser, {bool ignoreCache = false}) async {
    try {
      _logger.i("Fetching popular anime");
      (bool, List<Anime>) popular = await _animeRepository
          .getPopularAnimes(page, loggedUser, ignoreCache: ignoreCache);
      emit(state.copyWith(popular: popular));
    } on HttpServerException catch (e, stackTrace) {
      handleError(
        "Failed to fetch popular anime:",
        responseBody: e.message,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      handleError("Failed to fetch popular anime $e", stackTrace: stackTrace);
    }
  }

  Future<void> _fetchRecentlyCompleted(int page, User loggedUser, {bool ignoreCache = false}) async {
    try {
      _logger.i("Fetching recently completed anime");
      (bool, List<Anime>) recentlyCompleted = await _animeRepository
          .getRecentlyCompletedAnimes(page, loggedUser, ignoreCache: ignoreCache);
      emit(state.copyWith(recentlyCompleted: recentlyCompleted));
    } on HttpServerException catch (e, stackTrace) {
      handleError(
        "Failed to fetch recently completed anime:",
        responseBody: e.message,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      handleError(
        "Failed to fetch recently completed anime $e",
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _fetchUpcoming(int page, User loggedUser, {bool ignoreCache = false}) async {
    try {
      _logger.i("Fetching upcoming anime");
      (bool, List<Anime>) upcoming = await _animeRepository
          .getUpcomingAnimes(page, loggedUser, ignoreCache: ignoreCache);
      emit(state.copyWith(upcoming: upcoming));
    } on HttpServerException catch (e, stackTrace) {
      handleError(
        "Failed to fetch upcoming anime:",
        responseBody: e.message,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      handleError("Failed to fetch upcoming anime $e", stackTrace: stackTrace);
    }
  }
}

import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/anime_advanced_search_state.dart';
import 'package:unyo/core/di/locator.dart';

import 'package:unyo/core/notification/anime_genres_notifier.dart';
import 'package:unyo/core/notification/anime_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/domain/entities/user/user.dart';

class AnimeAdvancedSearchCubit extends Cubit<AnimeAdvancedSearchState>
    with EffectMixin<AnimeAdvancedSearchState> {
  final Logger _logger = sl<Logger>();

  // Notifiers
  final UserNotifier _loggedUserNotifier;
  final AnimeNotifier _selectedAnimeNotifier;
  final AnimeGenresNotifier _selectedAnimeAdvancedSearchGenresFilters;
  final MediaListNotifier _selectedMediaListNotifier;
  late final StreamSubscription<User> _loggedUserSubscription;
  late final StreamSubscription<String> _selectedAnimeAdvancedSearchGenresFiltersSubscription;

  // Repositories
  final AnimeRepository _animeRepository;

  AnimeAdvancedSearchCubit(
    this._loggedUserNotifier,
    this._selectedMediaListNotifier,
    this._selectedAnimeNotifier,
    this._selectedAnimeAdvancedSearchGenresFilters,
    this._animeRepository,
  ) : super(AnimeAdvancedSearchState(loggedUser: UserModel.empty())) {
    _init();
  }

  @override
  AnimeAdvancedSearchState copyStateWithEffects(AnimeAdvancedSearchState state, List<AppEffect> effects) {
    return state.copyWith(effects: effects);
  }

  @override
  Future<void> close() {
    _loggedUserSubscription.cancel();
    _selectedAnimeAdvancedSearchGenresFiltersSubscription.cancel();
    return super.close();
  }

  @override
  Logger get logger => _logger;

  void _init() async {
    _loggedUserSubscription = _loggedUserNotifier.userStream.listen((loggedUser) {
      emit(state.copyWith(loggedUser: loggedUser));
      _getLoggedUserServiceFilters(loggedUser);
      _performAnimeAdvancedSearch();
    });
    _selectedAnimeAdvancedSearchGenresFiltersSubscription = _selectedAnimeAdvancedSearchGenresFilters
        .animeGenreStream
        .listen((newAnimeGenre) {
          if (newAnimeGenre == "") return;
          updateGenres([newAnimeGenre]);
        });
  }

  void navigateToAnimeDetails(BuildContext context, Anime anime, MediaList mediaList) {
    _logger.i("Navigating to Anime Details of ${anime.title.userPreferred}");
    _selectedAnimeNotifier.updateSelectedAnime(anime);
    _selectedMediaListNotifier.updateSelectedMediaList(mediaList);
    bool hasAnimeDetailsInStack = AutoRouter.of(context).stackData.any(
          (route) => route.name == "AnimeDetailsRoute",
    );
    if (hasAnimeDetailsInStack) {
      popRouteEffect(context);
    } else {
      pushRouteEffect(path: "/animedetails");
    }
  }

  void popScreen(BuildContext context) {
    popRouteEffect(context);
    // close();
  }

  Future<void> updateSearchQuery(String query) async {
    emit(state.copyWith(searchQuery: query));
    try {
      _performAnimeAdvancedSearch();
    } catch (e, stackTrace) {
      _logger.e("Error updating search query $e", stackTrace: stackTrace);
      handleError("Error updating search query", stackTrace: stackTrace);
    }
  }

  void updateGenres(List<String> genres) {
    emit(state.copyWith(selectedGenres: genres));
    try {
      _performAnimeAdvancedSearch();
    } catch (e, stackTrace) {
      _logger.e("Error updating selected genres $e", stackTrace: stackTrace);
      handleError("Error updating selected genres", stackTrace: stackTrace);
    }
  }

  void updateSearchSortOption(String sortOption) {
    emit(state.copyWith(selectedSearchSortOption: sortOption));
    try {
      _performAnimeAdvancedSearch();
    } catch (e, stackTrace) {
      _logger.e("Error updating search sortOption $e", stackTrace: stackTrace);
      handleError("Error updating search sortOption", stackTrace: stackTrace);
    }
  }

  void updateSearchSortOrder(String sortOrder) {
    emit(state.copyWith(selectedSearchOrder: sortOrder));
    try {
      _performAnimeAdvancedSearch();
    } catch (e, stackTrace) {
      _logger.e("Error updating search sortOrder $e", stackTrace: stackTrace);
      handleError("Error updating search sortOrder", stackTrace: stackTrace);
    }
  }

  Future<void> updateSelectedYear(String? year) async {
    emit(state.copyWith(selectedYear: year));
    try {
      _performAnimeAdvancedSearch();
    } catch (e, stackTrace) {
      _logger.e("Error updating year $e", stackTrace: stackTrace);
      handleError("Error updating year", stackTrace: stackTrace);
    }
  }

  Future<void> updateSelectedSeason(String? season) async {
    emit(state.copyWith(selectedSeason: season));
    try {
      _performAnimeAdvancedSearch();
    } catch (e, stackTrace) {
      _logger.e("Error updating season $e", stackTrace: stackTrace);
      handleError("Error updating season", stackTrace: stackTrace);
    }
  }

  Future<void> updateSelectedFormat(String? format) async {
    emit(state.copyWith(selectedFormat: format));
    try {
      _performAnimeAdvancedSearch();
    } catch (e, stackTrace) {
      _logger.e("Error updating format $e", stackTrace: stackTrace);
      handleError("Error updating format", stackTrace: stackTrace);
    }
  }

  Future<void> updateSelectedAiringStatus(String? airingStatus) async {
    emit(state.copyWith(selectedAiringStatus: airingStatus));
    try {
      _performAnimeAdvancedSearch();
    } catch (e, stackTrace) {
      _logger.e("Error updating airing status $e", stackTrace: stackTrace);
      handleError("Error updating airing status", stackTrace: stackTrace);
    }
  }

  Future<void> _getLoggedUserServiceFilters(User loggedUser) async {
    try {
      final filters = await _animeRepository.getUserAnimeAdvancedSearchFilters();
      emit(
        state.copyWith(
          genresFilters: (filters['genres']?.$1 ?? false, filters['genres']?.$2 ?? []),
          seasonFilters: (filters['seasons']?.$1 ?? false, filters['seasons']?.$2 ?? []),
          formatFilters: (filters['formats']?.$1 ?? false, filters['formats']?.$2 ?? []),
          airingStatusFilters: (
            filters['airingStatuses']?.$1 ?? false,
            filters['airingStatuses']?.$2 ?? [],
          ),
          yearFilters: (filters['years']?.$1 ?? false, filters['years']?.$2 ?? []),
          searchSortOptions: (filters['sortOptions']?.$1 ?? false, filters['sortOptions']?.$2 ?? []),
          searchSortOrder: (filters['sortOrders']?.$1 ?? false, filters['sortOrders']?.$2 ?? []),
        ),
      );
    } catch (e, stackTrace) {
      _logger.e("Error getting logged user service filters $e", stackTrace: stackTrace);
      handleError("Error getting logged user service filters", stackTrace: stackTrace);
    }
  }

  Future<void> _performAnimeAdvancedSearch() async {
    List<Anime> searchResults = await _animeRepository.performAnimeAdvancedSearch(
      state.searchQuery,
      state.selectedGenres,
      state.selectedSeason,
      state.selectedFormat,
      int.tryParse(state.selectedYear ?? ''),
      state.selectedAiringStatus,
      "${state.selectedSearchSortOption.toUpperCase().replaceAll(" ", "_")}_${state.selectedSearchOrder.toUpperCase()}",
      1,
      state.loggedUser
    );
    emit(state.copyWith(searchResults: searchResults));
  }
}

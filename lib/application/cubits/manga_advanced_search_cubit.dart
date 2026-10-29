import 'dart:async';

import 'package:auto_route/auto_route.dart' show AutoRouter;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/manga_advanced_search_state.dart';
import 'package:unyo/core/di/locator.dart';

import 'package:unyo/core/notification/manga_genres_notifier.dart';
import 'package:unyo/core/notification/manga_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/domain/entities/user/user.dart';

class MangaAdvancedSearchCubit extends Cubit<MangaAdvancedSearchState>
    with EffectMixin<MangaAdvancedSearchState> {
  final Logger _logger = sl<Logger>();

  // Notifiers
  final UserNotifier _loggedUserNotifier;
  final MangaNotifier _selectedMangaNotifier;
  final MangaGenresNotifier _selectedMangaAdvancedSearchGenresFilters;
  final MediaListNotifier _selectedMediaListNotifier;
  late final StreamSubscription<User> _loggedUserSubscription;
  late final StreamSubscription<String> _selectedMangaAdvancedSearchGenresFiltersSubscription;

  // Repositories
  final MangaRepository _mangaRepository;

  MangaAdvancedSearchCubit(
    this._loggedUserNotifier,
    this._selectedMediaListNotifier,
    this._selectedMangaNotifier,
    this._selectedMangaAdvancedSearchGenresFilters,
    this._mangaRepository,
  ) : super(MangaAdvancedSearchState(loggedUser: UserModel.empty())) {
    _init();
  }

  @override
  MangaAdvancedSearchState copyStateWithEffects(MangaAdvancedSearchState state, List<AppEffect> effects) {
    return state.copyWith(effects: effects);
  }

  @override
  Future<void> close() {
    _loggedUserSubscription.cancel();
    _selectedMangaAdvancedSearchGenresFiltersSubscription.cancel();
    return super.close();
  }

  @override
  Logger get logger => _logger;

  void _init() async {
    _loggedUserSubscription = _loggedUserNotifier.userStream.listen((loggedUser) {
      emit(state.copyWith(loggedUser: loggedUser));
      _getLoggedUserServiceFilters(loggedUser);
      _performMangaAdvancedSearch();
    });
    _selectedMangaAdvancedSearchGenresFiltersSubscription = _selectedMangaAdvancedSearchGenresFilters
        .mangaGenreStream
        .listen((newMangaGenre) {
          if (newMangaGenre == "") return;
          updateGenres([newMangaGenre]);
        });
  }

  void navigateToMangaDetails(BuildContext context, Manga manga, MediaList mediaList) {
    _logger.i("Navigating to Manga Details of ${manga.title.userPreferred}");
    _selectedMangaNotifier.updateSelectedManga(manga);
    _selectedMediaListNotifier.updateSelectedMediaList(mediaList);
    bool hasMangaDetailsInStack = AutoRouter.of(context).stackData.any(
          (route) => route.name == "MangaDetailsRoute",
    );
    if (hasMangaDetailsInStack) {
      popRouteEffect(context);
    } else {
      pushRouteEffect(path: "/mangadetails");
    }
  }

  void popScreen(BuildContext context) {
    popRouteEffect(context);
    // close();
  }

  Future<void> updateSearchQuery(String query) async {
    emit(state.copyWith(searchQuery: query));
    try {
      _performMangaAdvancedSearch();
    } catch (e, stackTrace) {
      _logger.e("Error updating search query $e", stackTrace: stackTrace);
      handleError("Error updating search query", stackTrace: stackTrace);
    }
  }

  void updateGenres(List<String> genres) {
    emit(state.copyWith(selectedGenres: genres));
    try {
      _performMangaAdvancedSearch();
    } catch (e, stackTrace) {
      _logger.e("Error updating selected genres $e", stackTrace: stackTrace);
      handleError("Error updating selected genres", stackTrace: stackTrace);
    }
  }

  void updateSearchSortOption(String sortOption) {
    emit(state.copyWith(selectedSearchSortOption: sortOption));
    try {
      _performMangaAdvancedSearch();
    } catch (e, stackTrace) {
      _logger.e("Error updating search sortOption $e", stackTrace: stackTrace);
      handleError("Error updating search sortOption", stackTrace: stackTrace);
    }
  }

  void updateSearchSortOrder(String sortOrder) {
    emit(state.copyWith(selectedSearchOrder: sortOrder));
    try {
      _performMangaAdvancedSearch();
    } catch (e, stackTrace) {
      _logger.e("Error updating search sortOrder $e", stackTrace: stackTrace);
      handleError("Error updating search sortOrder", stackTrace: stackTrace);
    }
  }
  Future<void> updateSelectedFormat(String? format) async {
    emit(state.copyWith(selectedFormat: format));
    try {
      _performMangaAdvancedSearch();
    } catch (e, stackTrace) {
      _logger.e("Error updating format $e", stackTrace: stackTrace);
      handleError("Error updating format", stackTrace: stackTrace);
    }
  }

  Future<void> updateSelectedCountry(String? country) async {
    emit(state.copyWith(selectedCountry: country));
    try {
      _performMangaAdvancedSearch();
    } catch (e, stackTrace) {
      _logger.e("Error updating country $e", stackTrace: stackTrace);
      handleError("Error updating country", stackTrace: stackTrace);
    }
  }

  Future<void> updateSelectedAiringStatus(String? airingStatus) async {
    emit(state.copyWith(selectedAiringStatus: airingStatus));
    try {
      _performMangaAdvancedSearch();
    } catch (e, stackTrace) {
      _logger.e("Error updating airing status $e", stackTrace: stackTrace);
      handleError("Error updating airing status", stackTrace: stackTrace);
    }
  }

  Future<void> _getLoggedUserServiceFilters(User loggedUser) async {
    try {
      final filters = await _mangaRepository.getUserMangaAdvancedSearchFilters(loggedUser);
      emit(
        state.copyWith(
          genresFilters: (filters['genres']?.$1 ?? false, filters['genres']?.$2 ?? []),
          formatFilters: (filters['formats']?.$1 ?? false, filters['formats']?.$2 ?? []),
          countryFilters: (filters['countries']?.$1 ?? false, filters['countries']?.$2 ?? []),
          airingStatusFilters: (
            filters['airingStatuses']?.$1 ?? false,
            filters['airingStatuses']?.$2 ?? [],
          ),
          searchSortOptions: (filters['sortOptions']?.$1 ?? false, filters['sortOptions']?.$2 ?? []),
          searchSortOrder: (filters['sortOrders']?.$1 ?? false, filters['sortOrders']?.$2 ?? []),
        ),
      );
    } catch (e, stackTrace) {
      _logger.e("Error getting logged user service filters $e", stackTrace: stackTrace);
      handleError("Error getting logged user service filters", stackTrace: stackTrace);
    }
  }

  Future<void> _performMangaAdvancedSearch() async {
    List<Manga> searchResults = await _mangaRepository.performMangaAdvancedSearch(
      state.searchQuery,
      state.selectedGenres,
      state.selectedFormat,
      state.selectedCountry,
      state.selectedAiringStatus,
      "${state.selectedSearchSortOption.toUpperCase().replaceAll(" ", "_")}_${state.selectedSearchOrder.toUpperCase()}",
      1,
      state.loggedUser
    );
    emit(state.copyWith(searchResults: searchResults));
  }
}

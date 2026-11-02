import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/user/user.dart';

part 'anime_advanced_search_state.freezed.dart';

@freezed
abstract class AnimeAdvancedSearchState with _$AnimeAdvancedSearchState implements HasEffects {
  const factory AnimeAdvancedSearchState({
    required User loggedUser,
    @Default((false, <String>[])) (bool, List<String>) genresFilters,
    @Default((false, <String>[])) (bool, List<String>) yearFilters,
    @Default((false, <String>[])) (bool, List<String>) seasonFilters,
    @Default((false, <String>[])) (bool, List<String>) formatFilters,
    @Default((false, <String>[])) (bool, List<String>) airingStatusFilters,
    @Default((false, <String>[])) (bool, List<String>) searchSortOptions,
    @Default((false, <String>[])) (bool, List<String>) searchSortOrder,
    @Default('') String searchQuery,
    @Default(<String>[]) List<String> selectedGenres,
    @Default(null) String? selectedYear,
    @Default(null) String? selectedSeason,
    @Default(null) String? selectedFormat,
    @Default(null) String? selectedAiringStatus,
    @Default([]) List<Anime> searchResults,
    /// True while the results request is in flight, so the screen can paint
    /// the grid placeholder instead of an empty area.
    @Default(false) bool isSearching,
    @Default('Desc') String selectedSearchOrder,
    @Default('Popularity') String selectedSearchSortOption,
    @Default(<AppEffect>[]) List<AppEffect> effects,
  }) = _AnimeAdvancedSearchState;

  const AnimeAdvancedSearchState._();

  @override
  List<AppEffect> get stateEffects => effects;
}
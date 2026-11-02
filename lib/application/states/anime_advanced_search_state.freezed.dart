// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anime_advanced_search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimeAdvancedSearchState {

 User get loggedUser; (bool, List<String>) get genresFilters; (bool, List<String>) get yearFilters; (bool, List<String>) get seasonFilters; (bool, List<String>) get formatFilters; (bool, List<String>) get airingStatusFilters; (bool, List<String>) get searchSortOptions; (bool, List<String>) get searchSortOrder; String get searchQuery; List<String> get selectedGenres; String? get selectedYear; String? get selectedSeason; String? get selectedFormat; String? get selectedAiringStatus; List<Anime> get searchResults;/// True while the results request is in flight, so the screen can paint
/// the grid placeholder instead of an empty area.
 bool get isSearching; String get selectedSearchOrder; String get selectedSearchSortOption; List<AppEffect> get effects;
/// Create a copy of AnimeAdvancedSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimeAdvancedSearchStateCopyWith<AnimeAdvancedSearchState> get copyWith => _$AnimeAdvancedSearchStateCopyWithImpl<AnimeAdvancedSearchState>(this as AnimeAdvancedSearchState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimeAdvancedSearchState&&(identical(other.loggedUser, loggedUser) || other.loggedUser == loggedUser)&&(identical(other.genresFilters, genresFilters) || other.genresFilters == genresFilters)&&(identical(other.yearFilters, yearFilters) || other.yearFilters == yearFilters)&&(identical(other.seasonFilters, seasonFilters) || other.seasonFilters == seasonFilters)&&(identical(other.formatFilters, formatFilters) || other.formatFilters == formatFilters)&&(identical(other.airingStatusFilters, airingStatusFilters) || other.airingStatusFilters == airingStatusFilters)&&(identical(other.searchSortOptions, searchSortOptions) || other.searchSortOptions == searchSortOptions)&&(identical(other.searchSortOrder, searchSortOrder) || other.searchSortOrder == searchSortOrder)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&const DeepCollectionEquality().equals(other.selectedGenres, selectedGenres)&&(identical(other.selectedYear, selectedYear) || other.selectedYear == selectedYear)&&(identical(other.selectedSeason, selectedSeason) || other.selectedSeason == selectedSeason)&&(identical(other.selectedFormat, selectedFormat) || other.selectedFormat == selectedFormat)&&(identical(other.selectedAiringStatus, selectedAiringStatus) || other.selectedAiringStatus == selectedAiringStatus)&&const DeepCollectionEquality().equals(other.searchResults, searchResults)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching)&&(identical(other.selectedSearchOrder, selectedSearchOrder) || other.selectedSearchOrder == selectedSearchOrder)&&(identical(other.selectedSearchSortOption, selectedSearchSortOption) || other.selectedSearchSortOption == selectedSearchSortOption)&&const DeepCollectionEquality().equals(other.effects, effects));
}


@override
int get hashCode => Object.hashAll([runtimeType,loggedUser,genresFilters,yearFilters,seasonFilters,formatFilters,airingStatusFilters,searchSortOptions,searchSortOrder,searchQuery,const DeepCollectionEquality().hash(selectedGenres),selectedYear,selectedSeason,selectedFormat,selectedAiringStatus,const DeepCollectionEquality().hash(searchResults),isSearching,selectedSearchOrder,selectedSearchSortOption,const DeepCollectionEquality().hash(effects)]);

@override
String toString() {
  return 'AnimeAdvancedSearchState(loggedUser: $loggedUser, genresFilters: $genresFilters, yearFilters: $yearFilters, seasonFilters: $seasonFilters, formatFilters: $formatFilters, airingStatusFilters: $airingStatusFilters, searchSortOptions: $searchSortOptions, searchSortOrder: $searchSortOrder, searchQuery: $searchQuery, selectedGenres: $selectedGenres, selectedYear: $selectedYear, selectedSeason: $selectedSeason, selectedFormat: $selectedFormat, selectedAiringStatus: $selectedAiringStatus, searchResults: $searchResults, isSearching: $isSearching, selectedSearchOrder: $selectedSearchOrder, selectedSearchSortOption: $selectedSearchSortOption, effects: $effects)';
}


}

/// @nodoc
abstract mixin class $AnimeAdvancedSearchStateCopyWith<$Res>  {
  factory $AnimeAdvancedSearchStateCopyWith(AnimeAdvancedSearchState value, $Res Function(AnimeAdvancedSearchState) _then) = _$AnimeAdvancedSearchStateCopyWithImpl;
@useResult
$Res call({
 User loggedUser, (bool, List<String>) genresFilters, (bool, List<String>) yearFilters, (bool, List<String>) seasonFilters, (bool, List<String>) formatFilters, (bool, List<String>) airingStatusFilters, (bool, List<String>) searchSortOptions, (bool, List<String>) searchSortOrder, String searchQuery, List<String> selectedGenres, String? selectedYear, String? selectedSeason, String? selectedFormat, String? selectedAiringStatus, List<Anime> searchResults, bool isSearching, String selectedSearchOrder, String selectedSearchSortOption, List<AppEffect> effects
});




}
/// @nodoc
class _$AnimeAdvancedSearchStateCopyWithImpl<$Res>
    implements $AnimeAdvancedSearchStateCopyWith<$Res> {
  _$AnimeAdvancedSearchStateCopyWithImpl(this._self, this._then);

  final AnimeAdvancedSearchState _self;
  final $Res Function(AnimeAdvancedSearchState) _then;

/// Create a copy of AnimeAdvancedSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loggedUser = null,Object? genresFilters = null,Object? yearFilters = null,Object? seasonFilters = null,Object? formatFilters = null,Object? airingStatusFilters = null,Object? searchSortOptions = null,Object? searchSortOrder = null,Object? searchQuery = null,Object? selectedGenres = null,Object? selectedYear = freezed,Object? selectedSeason = freezed,Object? selectedFormat = freezed,Object? selectedAiringStatus = freezed,Object? searchResults = null,Object? isSearching = null,Object? selectedSearchOrder = null,Object? selectedSearchSortOption = null,Object? effects = null,}) {
  return _then(_self.copyWith(
loggedUser: null == loggedUser ? _self.loggedUser : loggedUser // ignore: cast_nullable_to_non_nullable
as User,genresFilters: null == genresFilters ? _self.genresFilters : genresFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),yearFilters: null == yearFilters ? _self.yearFilters : yearFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),seasonFilters: null == seasonFilters ? _self.seasonFilters : seasonFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),formatFilters: null == formatFilters ? _self.formatFilters : formatFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),airingStatusFilters: null == airingStatusFilters ? _self.airingStatusFilters : airingStatusFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),searchSortOptions: null == searchSortOptions ? _self.searchSortOptions : searchSortOptions // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),searchSortOrder: null == searchSortOrder ? _self.searchSortOrder : searchSortOrder // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedGenres: null == selectedGenres ? _self.selectedGenres : selectedGenres // ignore: cast_nullable_to_non_nullable
as List<String>,selectedYear: freezed == selectedYear ? _self.selectedYear : selectedYear // ignore: cast_nullable_to_non_nullable
as String?,selectedSeason: freezed == selectedSeason ? _self.selectedSeason : selectedSeason // ignore: cast_nullable_to_non_nullable
as String?,selectedFormat: freezed == selectedFormat ? _self.selectedFormat : selectedFormat // ignore: cast_nullable_to_non_nullable
as String?,selectedAiringStatus: freezed == selectedAiringStatus ? _self.selectedAiringStatus : selectedAiringStatus // ignore: cast_nullable_to_non_nullable
as String?,searchResults: null == searchResults ? _self.searchResults : searchResults // ignore: cast_nullable_to_non_nullable
as List<Anime>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,selectedSearchOrder: null == selectedSearchOrder ? _self.selectedSearchOrder : selectedSearchOrder // ignore: cast_nullable_to_non_nullable
as String,selectedSearchSortOption: null == selectedSearchSortOption ? _self.selectedSearchSortOption : selectedSearchSortOption // ignore: cast_nullable_to_non_nullable
as String,effects: null == effects ? _self.effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimeAdvancedSearchState].
extension AnimeAdvancedSearchStatePatterns on AnimeAdvancedSearchState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimeAdvancedSearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimeAdvancedSearchState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimeAdvancedSearchState value)  $default,){
final _that = this;
switch (_that) {
case _AnimeAdvancedSearchState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimeAdvancedSearchState value)?  $default,){
final _that = this;
switch (_that) {
case _AnimeAdvancedSearchState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User loggedUser,  (bool, List<String>) genresFilters,  (bool, List<String>) yearFilters,  (bool, List<String>) seasonFilters,  (bool, List<String>) formatFilters,  (bool, List<String>) airingStatusFilters,  (bool, List<String>) searchSortOptions,  (bool, List<String>) searchSortOrder,  String searchQuery,  List<String> selectedGenres,  String? selectedYear,  String? selectedSeason,  String? selectedFormat,  String? selectedAiringStatus,  List<Anime> searchResults,  bool isSearching,  String selectedSearchOrder,  String selectedSearchSortOption,  List<AppEffect> effects)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimeAdvancedSearchState() when $default != null:
return $default(_that.loggedUser,_that.genresFilters,_that.yearFilters,_that.seasonFilters,_that.formatFilters,_that.airingStatusFilters,_that.searchSortOptions,_that.searchSortOrder,_that.searchQuery,_that.selectedGenres,_that.selectedYear,_that.selectedSeason,_that.selectedFormat,_that.selectedAiringStatus,_that.searchResults,_that.isSearching,_that.selectedSearchOrder,_that.selectedSearchSortOption,_that.effects);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User loggedUser,  (bool, List<String>) genresFilters,  (bool, List<String>) yearFilters,  (bool, List<String>) seasonFilters,  (bool, List<String>) formatFilters,  (bool, List<String>) airingStatusFilters,  (bool, List<String>) searchSortOptions,  (bool, List<String>) searchSortOrder,  String searchQuery,  List<String> selectedGenres,  String? selectedYear,  String? selectedSeason,  String? selectedFormat,  String? selectedAiringStatus,  List<Anime> searchResults,  bool isSearching,  String selectedSearchOrder,  String selectedSearchSortOption,  List<AppEffect> effects)  $default,) {final _that = this;
switch (_that) {
case _AnimeAdvancedSearchState():
return $default(_that.loggedUser,_that.genresFilters,_that.yearFilters,_that.seasonFilters,_that.formatFilters,_that.airingStatusFilters,_that.searchSortOptions,_that.searchSortOrder,_that.searchQuery,_that.selectedGenres,_that.selectedYear,_that.selectedSeason,_that.selectedFormat,_that.selectedAiringStatus,_that.searchResults,_that.isSearching,_that.selectedSearchOrder,_that.selectedSearchSortOption,_that.effects);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User loggedUser,  (bool, List<String>) genresFilters,  (bool, List<String>) yearFilters,  (bool, List<String>) seasonFilters,  (bool, List<String>) formatFilters,  (bool, List<String>) airingStatusFilters,  (bool, List<String>) searchSortOptions,  (bool, List<String>) searchSortOrder,  String searchQuery,  List<String> selectedGenres,  String? selectedYear,  String? selectedSeason,  String? selectedFormat,  String? selectedAiringStatus,  List<Anime> searchResults,  bool isSearching,  String selectedSearchOrder,  String selectedSearchSortOption,  List<AppEffect> effects)?  $default,) {final _that = this;
switch (_that) {
case _AnimeAdvancedSearchState() when $default != null:
return $default(_that.loggedUser,_that.genresFilters,_that.yearFilters,_that.seasonFilters,_that.formatFilters,_that.airingStatusFilters,_that.searchSortOptions,_that.searchSortOrder,_that.searchQuery,_that.selectedGenres,_that.selectedYear,_that.selectedSeason,_that.selectedFormat,_that.selectedAiringStatus,_that.searchResults,_that.isSearching,_that.selectedSearchOrder,_that.selectedSearchSortOption,_that.effects);case _:
  return null;

}
}

}

/// @nodoc


class _AnimeAdvancedSearchState extends AnimeAdvancedSearchState {
  const _AnimeAdvancedSearchState({required this.loggedUser, this.genresFilters = const (false, <String>[]), this.yearFilters = const (false, <String>[]), this.seasonFilters = const (false, <String>[]), this.formatFilters = const (false, <String>[]), this.airingStatusFilters = const (false, <String>[]), this.searchSortOptions = const (false, <String>[]), this.searchSortOrder = const (false, <String>[]), this.searchQuery = '', final  List<String> selectedGenres = const <String>[], this.selectedYear = null, this.selectedSeason = null, this.selectedFormat = null, this.selectedAiringStatus = null, final  List<Anime> searchResults = const [], this.isSearching = false, this.selectedSearchOrder = 'Desc', this.selectedSearchSortOption = 'Popularity', final  List<AppEffect> effects = const <AppEffect>[]}): _selectedGenres = selectedGenres,_searchResults = searchResults,_effects = effects,super._();
  

@override final  User loggedUser;
@override@JsonKey() final  (bool, List<String>) genresFilters;
@override@JsonKey() final  (bool, List<String>) yearFilters;
@override@JsonKey() final  (bool, List<String>) seasonFilters;
@override@JsonKey() final  (bool, List<String>) formatFilters;
@override@JsonKey() final  (bool, List<String>) airingStatusFilters;
@override@JsonKey() final  (bool, List<String>) searchSortOptions;
@override@JsonKey() final  (bool, List<String>) searchSortOrder;
@override@JsonKey() final  String searchQuery;
 final  List<String> _selectedGenres;
@override@JsonKey() List<String> get selectedGenres {
  if (_selectedGenres is EqualUnmodifiableListView) return _selectedGenres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedGenres);
}

@override@JsonKey() final  String? selectedYear;
@override@JsonKey() final  String? selectedSeason;
@override@JsonKey() final  String? selectedFormat;
@override@JsonKey() final  String? selectedAiringStatus;
 final  List<Anime> _searchResults;
@override@JsonKey() List<Anime> get searchResults {
  if (_searchResults is EqualUnmodifiableListView) return _searchResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_searchResults);
}

/// True while the results request is in flight, so the screen can paint
/// the grid placeholder instead of an empty area.
@override@JsonKey() final  bool isSearching;
@override@JsonKey() final  String selectedSearchOrder;
@override@JsonKey() final  String selectedSearchSortOption;
 final  List<AppEffect> _effects;
@override@JsonKey() List<AppEffect> get effects {
  if (_effects is EqualUnmodifiableListView) return _effects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_effects);
}


/// Create a copy of AnimeAdvancedSearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimeAdvancedSearchStateCopyWith<_AnimeAdvancedSearchState> get copyWith => __$AnimeAdvancedSearchStateCopyWithImpl<_AnimeAdvancedSearchState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimeAdvancedSearchState&&(identical(other.loggedUser, loggedUser) || other.loggedUser == loggedUser)&&(identical(other.genresFilters, genresFilters) || other.genresFilters == genresFilters)&&(identical(other.yearFilters, yearFilters) || other.yearFilters == yearFilters)&&(identical(other.seasonFilters, seasonFilters) || other.seasonFilters == seasonFilters)&&(identical(other.formatFilters, formatFilters) || other.formatFilters == formatFilters)&&(identical(other.airingStatusFilters, airingStatusFilters) || other.airingStatusFilters == airingStatusFilters)&&(identical(other.searchSortOptions, searchSortOptions) || other.searchSortOptions == searchSortOptions)&&(identical(other.searchSortOrder, searchSortOrder) || other.searchSortOrder == searchSortOrder)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&const DeepCollectionEquality().equals(other._selectedGenres, _selectedGenres)&&(identical(other.selectedYear, selectedYear) || other.selectedYear == selectedYear)&&(identical(other.selectedSeason, selectedSeason) || other.selectedSeason == selectedSeason)&&(identical(other.selectedFormat, selectedFormat) || other.selectedFormat == selectedFormat)&&(identical(other.selectedAiringStatus, selectedAiringStatus) || other.selectedAiringStatus == selectedAiringStatus)&&const DeepCollectionEquality().equals(other._searchResults, _searchResults)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching)&&(identical(other.selectedSearchOrder, selectedSearchOrder) || other.selectedSearchOrder == selectedSearchOrder)&&(identical(other.selectedSearchSortOption, selectedSearchSortOption) || other.selectedSearchSortOption == selectedSearchSortOption)&&const DeepCollectionEquality().equals(other._effects, _effects));
}


@override
int get hashCode => Object.hashAll([runtimeType,loggedUser,genresFilters,yearFilters,seasonFilters,formatFilters,airingStatusFilters,searchSortOptions,searchSortOrder,searchQuery,const DeepCollectionEquality().hash(_selectedGenres),selectedYear,selectedSeason,selectedFormat,selectedAiringStatus,const DeepCollectionEquality().hash(_searchResults),isSearching,selectedSearchOrder,selectedSearchSortOption,const DeepCollectionEquality().hash(_effects)]);

@override
String toString() {
  return 'AnimeAdvancedSearchState(loggedUser: $loggedUser, genresFilters: $genresFilters, yearFilters: $yearFilters, seasonFilters: $seasonFilters, formatFilters: $formatFilters, airingStatusFilters: $airingStatusFilters, searchSortOptions: $searchSortOptions, searchSortOrder: $searchSortOrder, searchQuery: $searchQuery, selectedGenres: $selectedGenres, selectedYear: $selectedYear, selectedSeason: $selectedSeason, selectedFormat: $selectedFormat, selectedAiringStatus: $selectedAiringStatus, searchResults: $searchResults, isSearching: $isSearching, selectedSearchOrder: $selectedSearchOrder, selectedSearchSortOption: $selectedSearchSortOption, effects: $effects)';
}


}

/// @nodoc
abstract mixin class _$AnimeAdvancedSearchStateCopyWith<$Res> implements $AnimeAdvancedSearchStateCopyWith<$Res> {
  factory _$AnimeAdvancedSearchStateCopyWith(_AnimeAdvancedSearchState value, $Res Function(_AnimeAdvancedSearchState) _then) = __$AnimeAdvancedSearchStateCopyWithImpl;
@override @useResult
$Res call({
 User loggedUser, (bool, List<String>) genresFilters, (bool, List<String>) yearFilters, (bool, List<String>) seasonFilters, (bool, List<String>) formatFilters, (bool, List<String>) airingStatusFilters, (bool, List<String>) searchSortOptions, (bool, List<String>) searchSortOrder, String searchQuery, List<String> selectedGenres, String? selectedYear, String? selectedSeason, String? selectedFormat, String? selectedAiringStatus, List<Anime> searchResults, bool isSearching, String selectedSearchOrder, String selectedSearchSortOption, List<AppEffect> effects
});




}
/// @nodoc
class __$AnimeAdvancedSearchStateCopyWithImpl<$Res>
    implements _$AnimeAdvancedSearchStateCopyWith<$Res> {
  __$AnimeAdvancedSearchStateCopyWithImpl(this._self, this._then);

  final _AnimeAdvancedSearchState _self;
  final $Res Function(_AnimeAdvancedSearchState) _then;

/// Create a copy of AnimeAdvancedSearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loggedUser = null,Object? genresFilters = null,Object? yearFilters = null,Object? seasonFilters = null,Object? formatFilters = null,Object? airingStatusFilters = null,Object? searchSortOptions = null,Object? searchSortOrder = null,Object? searchQuery = null,Object? selectedGenres = null,Object? selectedYear = freezed,Object? selectedSeason = freezed,Object? selectedFormat = freezed,Object? selectedAiringStatus = freezed,Object? searchResults = null,Object? isSearching = null,Object? selectedSearchOrder = null,Object? selectedSearchSortOption = null,Object? effects = null,}) {
  return _then(_AnimeAdvancedSearchState(
loggedUser: null == loggedUser ? _self.loggedUser : loggedUser // ignore: cast_nullable_to_non_nullable
as User,genresFilters: null == genresFilters ? _self.genresFilters : genresFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),yearFilters: null == yearFilters ? _self.yearFilters : yearFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),seasonFilters: null == seasonFilters ? _self.seasonFilters : seasonFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),formatFilters: null == formatFilters ? _self.formatFilters : formatFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),airingStatusFilters: null == airingStatusFilters ? _self.airingStatusFilters : airingStatusFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),searchSortOptions: null == searchSortOptions ? _self.searchSortOptions : searchSortOptions // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),searchSortOrder: null == searchSortOrder ? _self.searchSortOrder : searchSortOrder // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedGenres: null == selectedGenres ? _self._selectedGenres : selectedGenres // ignore: cast_nullable_to_non_nullable
as List<String>,selectedYear: freezed == selectedYear ? _self.selectedYear : selectedYear // ignore: cast_nullable_to_non_nullable
as String?,selectedSeason: freezed == selectedSeason ? _self.selectedSeason : selectedSeason // ignore: cast_nullable_to_non_nullable
as String?,selectedFormat: freezed == selectedFormat ? _self.selectedFormat : selectedFormat // ignore: cast_nullable_to_non_nullable
as String?,selectedAiringStatus: freezed == selectedAiringStatus ? _self.selectedAiringStatus : selectedAiringStatus // ignore: cast_nullable_to_non_nullable
as String?,searchResults: null == searchResults ? _self._searchResults : searchResults // ignore: cast_nullable_to_non_nullable
as List<Anime>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,selectedSearchOrder: null == selectedSearchOrder ? _self.selectedSearchOrder : selectedSearchOrder // ignore: cast_nullable_to_non_nullable
as String,selectedSearchSortOption: null == selectedSearchSortOption ? _self.selectedSearchSortOption : selectedSearchSortOption // ignore: cast_nullable_to_non_nullable
as String,effects: null == effects ? _self._effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,
  ));
}


}

// dart format on

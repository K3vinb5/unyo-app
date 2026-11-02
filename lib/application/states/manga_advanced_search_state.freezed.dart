// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manga_advanced_search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MangaAdvancedSearchState {

 User get loggedUser; (bool, List<String>) get genresFilters; (bool, List<String>) get formatFilters; (bool, List<String>) get countryFilters; (bool, List<String>) get airingStatusFilters; (bool, List<String>) get searchSortOptions; (bool, List<String>) get searchSortOrder; String get searchQuery; List<String> get selectedGenres; String? get selectedFormat; String? get selectedCountry; String? get selectedAiringStatus; List<Manga> get searchResults;/// True while the results request is in flight, so the screen can paint
/// the grid placeholder instead of an empty area.
 bool get isSearching; String get selectedSearchOrder; String get selectedSearchSortOption; List<AppEffect> get effects;
/// Create a copy of MangaAdvancedSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MangaAdvancedSearchStateCopyWith<MangaAdvancedSearchState> get copyWith => _$MangaAdvancedSearchStateCopyWithImpl<MangaAdvancedSearchState>(this as MangaAdvancedSearchState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MangaAdvancedSearchState&&(identical(other.loggedUser, loggedUser) || other.loggedUser == loggedUser)&&(identical(other.genresFilters, genresFilters) || other.genresFilters == genresFilters)&&(identical(other.formatFilters, formatFilters) || other.formatFilters == formatFilters)&&(identical(other.countryFilters, countryFilters) || other.countryFilters == countryFilters)&&(identical(other.airingStatusFilters, airingStatusFilters) || other.airingStatusFilters == airingStatusFilters)&&(identical(other.searchSortOptions, searchSortOptions) || other.searchSortOptions == searchSortOptions)&&(identical(other.searchSortOrder, searchSortOrder) || other.searchSortOrder == searchSortOrder)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&const DeepCollectionEquality().equals(other.selectedGenres, selectedGenres)&&(identical(other.selectedFormat, selectedFormat) || other.selectedFormat == selectedFormat)&&(identical(other.selectedCountry, selectedCountry) || other.selectedCountry == selectedCountry)&&(identical(other.selectedAiringStatus, selectedAiringStatus) || other.selectedAiringStatus == selectedAiringStatus)&&const DeepCollectionEquality().equals(other.searchResults, searchResults)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching)&&(identical(other.selectedSearchOrder, selectedSearchOrder) || other.selectedSearchOrder == selectedSearchOrder)&&(identical(other.selectedSearchSortOption, selectedSearchSortOption) || other.selectedSearchSortOption == selectedSearchSortOption)&&const DeepCollectionEquality().equals(other.effects, effects));
}


@override
int get hashCode => Object.hash(runtimeType,loggedUser,genresFilters,formatFilters,countryFilters,airingStatusFilters,searchSortOptions,searchSortOrder,searchQuery,const DeepCollectionEquality().hash(selectedGenres),selectedFormat,selectedCountry,selectedAiringStatus,const DeepCollectionEquality().hash(searchResults),isSearching,selectedSearchOrder,selectedSearchSortOption,const DeepCollectionEquality().hash(effects));

@override
String toString() {
  return 'MangaAdvancedSearchState(loggedUser: $loggedUser, genresFilters: $genresFilters, formatFilters: $formatFilters, countryFilters: $countryFilters, airingStatusFilters: $airingStatusFilters, searchSortOptions: $searchSortOptions, searchSortOrder: $searchSortOrder, searchQuery: $searchQuery, selectedGenres: $selectedGenres, selectedFormat: $selectedFormat, selectedCountry: $selectedCountry, selectedAiringStatus: $selectedAiringStatus, searchResults: $searchResults, isSearching: $isSearching, selectedSearchOrder: $selectedSearchOrder, selectedSearchSortOption: $selectedSearchSortOption, effects: $effects)';
}


}

/// @nodoc
abstract mixin class $MangaAdvancedSearchStateCopyWith<$Res>  {
  factory $MangaAdvancedSearchStateCopyWith(MangaAdvancedSearchState value, $Res Function(MangaAdvancedSearchState) _then) = _$MangaAdvancedSearchStateCopyWithImpl;
@useResult
$Res call({
 User loggedUser, (bool, List<String>) genresFilters, (bool, List<String>) formatFilters, (bool, List<String>) countryFilters, (bool, List<String>) airingStatusFilters, (bool, List<String>) searchSortOptions, (bool, List<String>) searchSortOrder, String searchQuery, List<String> selectedGenres, String? selectedFormat, String? selectedCountry, String? selectedAiringStatus, List<Manga> searchResults, bool isSearching, String selectedSearchOrder, String selectedSearchSortOption, List<AppEffect> effects
});




}
/// @nodoc
class _$MangaAdvancedSearchStateCopyWithImpl<$Res>
    implements $MangaAdvancedSearchStateCopyWith<$Res> {
  _$MangaAdvancedSearchStateCopyWithImpl(this._self, this._then);

  final MangaAdvancedSearchState _self;
  final $Res Function(MangaAdvancedSearchState) _then;

/// Create a copy of MangaAdvancedSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loggedUser = null,Object? genresFilters = null,Object? formatFilters = null,Object? countryFilters = null,Object? airingStatusFilters = null,Object? searchSortOptions = null,Object? searchSortOrder = null,Object? searchQuery = null,Object? selectedGenres = null,Object? selectedFormat = freezed,Object? selectedCountry = freezed,Object? selectedAiringStatus = freezed,Object? searchResults = null,Object? isSearching = null,Object? selectedSearchOrder = null,Object? selectedSearchSortOption = null,Object? effects = null,}) {
  return _then(_self.copyWith(
loggedUser: null == loggedUser ? _self.loggedUser : loggedUser // ignore: cast_nullable_to_non_nullable
as User,genresFilters: null == genresFilters ? _self.genresFilters : genresFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),formatFilters: null == formatFilters ? _self.formatFilters : formatFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),countryFilters: null == countryFilters ? _self.countryFilters : countryFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),airingStatusFilters: null == airingStatusFilters ? _self.airingStatusFilters : airingStatusFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),searchSortOptions: null == searchSortOptions ? _self.searchSortOptions : searchSortOptions // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),searchSortOrder: null == searchSortOrder ? _self.searchSortOrder : searchSortOrder // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedGenres: null == selectedGenres ? _self.selectedGenres : selectedGenres // ignore: cast_nullable_to_non_nullable
as List<String>,selectedFormat: freezed == selectedFormat ? _self.selectedFormat : selectedFormat // ignore: cast_nullable_to_non_nullable
as String?,selectedCountry: freezed == selectedCountry ? _self.selectedCountry : selectedCountry // ignore: cast_nullable_to_non_nullable
as String?,selectedAiringStatus: freezed == selectedAiringStatus ? _self.selectedAiringStatus : selectedAiringStatus // ignore: cast_nullable_to_non_nullable
as String?,searchResults: null == searchResults ? _self.searchResults : searchResults // ignore: cast_nullable_to_non_nullable
as List<Manga>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,selectedSearchOrder: null == selectedSearchOrder ? _self.selectedSearchOrder : selectedSearchOrder // ignore: cast_nullable_to_non_nullable
as String,selectedSearchSortOption: null == selectedSearchSortOption ? _self.selectedSearchSortOption : selectedSearchSortOption // ignore: cast_nullable_to_non_nullable
as String,effects: null == effects ? _self.effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,
  ));
}

}


/// Adds pattern-matching-related methods to [MangaAdvancedSearchState].
extension MangaAdvancedSearchStatePatterns on MangaAdvancedSearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MangaAdvancedSearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MangaAdvancedSearchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MangaAdvancedSearchState value)  $default,){
final _that = this;
switch (_that) {
case _MangaAdvancedSearchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MangaAdvancedSearchState value)?  $default,){
final _that = this;
switch (_that) {
case _MangaAdvancedSearchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User loggedUser,  (bool, List<String>) genresFilters,  (bool, List<String>) formatFilters,  (bool, List<String>) countryFilters,  (bool, List<String>) airingStatusFilters,  (bool, List<String>) searchSortOptions,  (bool, List<String>) searchSortOrder,  String searchQuery,  List<String> selectedGenres,  String? selectedFormat,  String? selectedCountry,  String? selectedAiringStatus,  List<Manga> searchResults,  bool isSearching,  String selectedSearchOrder,  String selectedSearchSortOption,  List<AppEffect> effects)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MangaAdvancedSearchState() when $default != null:
return $default(_that.loggedUser,_that.genresFilters,_that.formatFilters,_that.countryFilters,_that.airingStatusFilters,_that.searchSortOptions,_that.searchSortOrder,_that.searchQuery,_that.selectedGenres,_that.selectedFormat,_that.selectedCountry,_that.selectedAiringStatus,_that.searchResults,_that.isSearching,_that.selectedSearchOrder,_that.selectedSearchSortOption,_that.effects);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User loggedUser,  (bool, List<String>) genresFilters,  (bool, List<String>) formatFilters,  (bool, List<String>) countryFilters,  (bool, List<String>) airingStatusFilters,  (bool, List<String>) searchSortOptions,  (bool, List<String>) searchSortOrder,  String searchQuery,  List<String> selectedGenres,  String? selectedFormat,  String? selectedCountry,  String? selectedAiringStatus,  List<Manga> searchResults,  bool isSearching,  String selectedSearchOrder,  String selectedSearchSortOption,  List<AppEffect> effects)  $default,) {final _that = this;
switch (_that) {
case _MangaAdvancedSearchState():
return $default(_that.loggedUser,_that.genresFilters,_that.formatFilters,_that.countryFilters,_that.airingStatusFilters,_that.searchSortOptions,_that.searchSortOrder,_that.searchQuery,_that.selectedGenres,_that.selectedFormat,_that.selectedCountry,_that.selectedAiringStatus,_that.searchResults,_that.isSearching,_that.selectedSearchOrder,_that.selectedSearchSortOption,_that.effects);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User loggedUser,  (bool, List<String>) genresFilters,  (bool, List<String>) formatFilters,  (bool, List<String>) countryFilters,  (bool, List<String>) airingStatusFilters,  (bool, List<String>) searchSortOptions,  (bool, List<String>) searchSortOrder,  String searchQuery,  List<String> selectedGenres,  String? selectedFormat,  String? selectedCountry,  String? selectedAiringStatus,  List<Manga> searchResults,  bool isSearching,  String selectedSearchOrder,  String selectedSearchSortOption,  List<AppEffect> effects)?  $default,) {final _that = this;
switch (_that) {
case _MangaAdvancedSearchState() when $default != null:
return $default(_that.loggedUser,_that.genresFilters,_that.formatFilters,_that.countryFilters,_that.airingStatusFilters,_that.searchSortOptions,_that.searchSortOrder,_that.searchQuery,_that.selectedGenres,_that.selectedFormat,_that.selectedCountry,_that.selectedAiringStatus,_that.searchResults,_that.isSearching,_that.selectedSearchOrder,_that.selectedSearchSortOption,_that.effects);case _:
  return null;

}
}

}

/// @nodoc


class _MangaAdvancedSearchState extends MangaAdvancedSearchState {
  const _MangaAdvancedSearchState({required this.loggedUser, this.genresFilters = const (false, <String>[]), this.formatFilters = const (false, <String>[]), this.countryFilters = const (false, <String>[]), this.airingStatusFilters = const (false, <String>[]), this.searchSortOptions = const (false, <String>[]), this.searchSortOrder = const (false, <String>[]), this.searchQuery = '', final  List<String> selectedGenres = const <String>[], this.selectedFormat = null, this.selectedCountry = null, this.selectedAiringStatus = null, final  List<Manga> searchResults = const [], this.isSearching = false, this.selectedSearchOrder = 'Desc', this.selectedSearchSortOption = 'Popularity', final  List<AppEffect> effects = const <AppEffect>[]}): _selectedGenres = selectedGenres,_searchResults = searchResults,_effects = effects,super._();
  

@override final  User loggedUser;
@override@JsonKey() final  (bool, List<String>) genresFilters;
@override@JsonKey() final  (bool, List<String>) formatFilters;
@override@JsonKey() final  (bool, List<String>) countryFilters;
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

@override@JsonKey() final  String? selectedFormat;
@override@JsonKey() final  String? selectedCountry;
@override@JsonKey() final  String? selectedAiringStatus;
 final  List<Manga> _searchResults;
@override@JsonKey() List<Manga> get searchResults {
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


/// Create a copy of MangaAdvancedSearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MangaAdvancedSearchStateCopyWith<_MangaAdvancedSearchState> get copyWith => __$MangaAdvancedSearchStateCopyWithImpl<_MangaAdvancedSearchState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MangaAdvancedSearchState&&(identical(other.loggedUser, loggedUser) || other.loggedUser == loggedUser)&&(identical(other.genresFilters, genresFilters) || other.genresFilters == genresFilters)&&(identical(other.formatFilters, formatFilters) || other.formatFilters == formatFilters)&&(identical(other.countryFilters, countryFilters) || other.countryFilters == countryFilters)&&(identical(other.airingStatusFilters, airingStatusFilters) || other.airingStatusFilters == airingStatusFilters)&&(identical(other.searchSortOptions, searchSortOptions) || other.searchSortOptions == searchSortOptions)&&(identical(other.searchSortOrder, searchSortOrder) || other.searchSortOrder == searchSortOrder)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&const DeepCollectionEquality().equals(other._selectedGenres, _selectedGenres)&&(identical(other.selectedFormat, selectedFormat) || other.selectedFormat == selectedFormat)&&(identical(other.selectedCountry, selectedCountry) || other.selectedCountry == selectedCountry)&&(identical(other.selectedAiringStatus, selectedAiringStatus) || other.selectedAiringStatus == selectedAiringStatus)&&const DeepCollectionEquality().equals(other._searchResults, _searchResults)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching)&&(identical(other.selectedSearchOrder, selectedSearchOrder) || other.selectedSearchOrder == selectedSearchOrder)&&(identical(other.selectedSearchSortOption, selectedSearchSortOption) || other.selectedSearchSortOption == selectedSearchSortOption)&&const DeepCollectionEquality().equals(other._effects, _effects));
}


@override
int get hashCode => Object.hash(runtimeType,loggedUser,genresFilters,formatFilters,countryFilters,airingStatusFilters,searchSortOptions,searchSortOrder,searchQuery,const DeepCollectionEquality().hash(_selectedGenres),selectedFormat,selectedCountry,selectedAiringStatus,const DeepCollectionEquality().hash(_searchResults),isSearching,selectedSearchOrder,selectedSearchSortOption,const DeepCollectionEquality().hash(_effects));

@override
String toString() {
  return 'MangaAdvancedSearchState(loggedUser: $loggedUser, genresFilters: $genresFilters, formatFilters: $formatFilters, countryFilters: $countryFilters, airingStatusFilters: $airingStatusFilters, searchSortOptions: $searchSortOptions, searchSortOrder: $searchSortOrder, searchQuery: $searchQuery, selectedGenres: $selectedGenres, selectedFormat: $selectedFormat, selectedCountry: $selectedCountry, selectedAiringStatus: $selectedAiringStatus, searchResults: $searchResults, isSearching: $isSearching, selectedSearchOrder: $selectedSearchOrder, selectedSearchSortOption: $selectedSearchSortOption, effects: $effects)';
}


}

/// @nodoc
abstract mixin class _$MangaAdvancedSearchStateCopyWith<$Res> implements $MangaAdvancedSearchStateCopyWith<$Res> {
  factory _$MangaAdvancedSearchStateCopyWith(_MangaAdvancedSearchState value, $Res Function(_MangaAdvancedSearchState) _then) = __$MangaAdvancedSearchStateCopyWithImpl;
@override @useResult
$Res call({
 User loggedUser, (bool, List<String>) genresFilters, (bool, List<String>) formatFilters, (bool, List<String>) countryFilters, (bool, List<String>) airingStatusFilters, (bool, List<String>) searchSortOptions, (bool, List<String>) searchSortOrder, String searchQuery, List<String> selectedGenres, String? selectedFormat, String? selectedCountry, String? selectedAiringStatus, List<Manga> searchResults, bool isSearching, String selectedSearchOrder, String selectedSearchSortOption, List<AppEffect> effects
});




}
/// @nodoc
class __$MangaAdvancedSearchStateCopyWithImpl<$Res>
    implements _$MangaAdvancedSearchStateCopyWith<$Res> {
  __$MangaAdvancedSearchStateCopyWithImpl(this._self, this._then);

  final _MangaAdvancedSearchState _self;
  final $Res Function(_MangaAdvancedSearchState) _then;

/// Create a copy of MangaAdvancedSearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loggedUser = null,Object? genresFilters = null,Object? formatFilters = null,Object? countryFilters = null,Object? airingStatusFilters = null,Object? searchSortOptions = null,Object? searchSortOrder = null,Object? searchQuery = null,Object? selectedGenres = null,Object? selectedFormat = freezed,Object? selectedCountry = freezed,Object? selectedAiringStatus = freezed,Object? searchResults = null,Object? isSearching = null,Object? selectedSearchOrder = null,Object? selectedSearchSortOption = null,Object? effects = null,}) {
  return _then(_MangaAdvancedSearchState(
loggedUser: null == loggedUser ? _self.loggedUser : loggedUser // ignore: cast_nullable_to_non_nullable
as User,genresFilters: null == genresFilters ? _self.genresFilters : genresFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),formatFilters: null == formatFilters ? _self.formatFilters : formatFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),countryFilters: null == countryFilters ? _self.countryFilters : countryFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),airingStatusFilters: null == airingStatusFilters ? _self.airingStatusFilters : airingStatusFilters // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),searchSortOptions: null == searchSortOptions ? _self.searchSortOptions : searchSortOptions // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),searchSortOrder: null == searchSortOrder ? _self.searchSortOrder : searchSortOrder // ignore: cast_nullable_to_non_nullable
as (bool, List<String>),searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedGenres: null == selectedGenres ? _self._selectedGenres : selectedGenres // ignore: cast_nullable_to_non_nullable
as List<String>,selectedFormat: freezed == selectedFormat ? _self.selectedFormat : selectedFormat // ignore: cast_nullable_to_non_nullable
as String?,selectedCountry: freezed == selectedCountry ? _self.selectedCountry : selectedCountry // ignore: cast_nullable_to_non_nullable
as String?,selectedAiringStatus: freezed == selectedAiringStatus ? _self.selectedAiringStatus : selectedAiringStatus // ignore: cast_nullable_to_non_nullable
as String?,searchResults: null == searchResults ? _self._searchResults : searchResults // ignore: cast_nullable_to_non_nullable
as List<Manga>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,selectedSearchOrder: null == selectedSearchOrder ? _self.selectedSearchOrder : selectedSearchOrder // ignore: cast_nullable_to_non_nullable
as String,selectedSearchSortOption: null == selectedSearchSortOption ? _self.selectedSearchSortOption : selectedSearchSortOption // ignore: cast_nullable_to_non_nullable
as String,effects: null == effects ? _self._effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manga_details_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MangaDetailsState {

 User get loggedUser; MediaList get selectedMediaList; Manga get selectedManga; MediaListEntry get mediaListEntry; (bool, List<MediaCharacter>) get characters; (bool, List<Manga>) get recommendations; List<String> get banners; String get alternateImage; Set<Extension> get installedExtensions; bool get userLoaded; Extension? get selectedExtension;// relations
// voice actors
 List<JSManga> get extensionMangaResults; List<JSChapter> get extensionEpisodeResults; List<JPage> get extensionVideoResults; List<AppEffect> get effects;
/// Create a copy of MangaDetailsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MangaDetailsStateCopyWith<MangaDetailsState> get copyWith => _$MangaDetailsStateCopyWithImpl<MangaDetailsState>(this as MangaDetailsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MangaDetailsState&&(identical(other.loggedUser, loggedUser) || other.loggedUser == loggedUser)&&(identical(other.selectedMediaList, selectedMediaList) || other.selectedMediaList == selectedMediaList)&&(identical(other.selectedManga, selectedManga) || other.selectedManga == selectedManga)&&(identical(other.mediaListEntry, mediaListEntry) || other.mediaListEntry == mediaListEntry)&&(identical(other.characters, characters) || other.characters == characters)&&(identical(other.recommendations, recommendations) || other.recommendations == recommendations)&&const DeepCollectionEquality().equals(other.banners, banners)&&(identical(other.alternateImage, alternateImage) || other.alternateImage == alternateImage)&&const DeepCollectionEquality().equals(other.installedExtensions, installedExtensions)&&(identical(other.userLoaded, userLoaded) || other.userLoaded == userLoaded)&&(identical(other.selectedExtension, selectedExtension) || other.selectedExtension == selectedExtension)&&const DeepCollectionEquality().equals(other.extensionMangaResults, extensionMangaResults)&&const DeepCollectionEquality().equals(other.extensionEpisodeResults, extensionEpisodeResults)&&const DeepCollectionEquality().equals(other.extensionVideoResults, extensionVideoResults)&&const DeepCollectionEquality().equals(other.effects, effects));
}


@override
int get hashCode => Object.hash(runtimeType,loggedUser,selectedMediaList,selectedManga,mediaListEntry,characters,recommendations,const DeepCollectionEquality().hash(banners),alternateImage,const DeepCollectionEquality().hash(installedExtensions),userLoaded,selectedExtension,const DeepCollectionEquality().hash(extensionMangaResults),const DeepCollectionEquality().hash(extensionEpisodeResults),const DeepCollectionEquality().hash(extensionVideoResults),const DeepCollectionEquality().hash(effects));

@override
String toString() {
  return 'MangaDetailsState(loggedUser: $loggedUser, selectedMediaList: $selectedMediaList, selectedManga: $selectedManga, mediaListEntry: $mediaListEntry, characters: $characters, recommendations: $recommendations, banners: $banners, alternateImage: $alternateImage, installedExtensions: $installedExtensions, userLoaded: $userLoaded, selectedExtension: $selectedExtension, extensionMangaResults: $extensionMangaResults, extensionEpisodeResults: $extensionEpisodeResults, extensionVideoResults: $extensionVideoResults, effects: $effects)';
}


}

/// @nodoc
abstract mixin class $MangaDetailsStateCopyWith<$Res>  {
  factory $MangaDetailsStateCopyWith(MangaDetailsState value, $Res Function(MangaDetailsState) _then) = _$MangaDetailsStateCopyWithImpl;
@useResult
$Res call({
 User loggedUser, MediaList selectedMediaList, Manga selectedManga, MediaListEntry mediaListEntry, (bool, List<MediaCharacter>) characters, (bool, List<Manga>) recommendations, List<String> banners, String alternateImage, Set<Extension> installedExtensions, bool userLoaded, Extension? selectedExtension, List<JSManga> extensionMangaResults, List<JSChapter> extensionEpisodeResults, List<JPage> extensionVideoResults, List<AppEffect> effects
});




}
/// @nodoc
class _$MangaDetailsStateCopyWithImpl<$Res>
    implements $MangaDetailsStateCopyWith<$Res> {
  _$MangaDetailsStateCopyWithImpl(this._self, this._then);

  final MangaDetailsState _self;
  final $Res Function(MangaDetailsState) _then;

/// Create a copy of MangaDetailsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loggedUser = null,Object? selectedMediaList = null,Object? selectedManga = null,Object? mediaListEntry = null,Object? characters = null,Object? recommendations = null,Object? banners = null,Object? alternateImage = null,Object? installedExtensions = null,Object? userLoaded = null,Object? selectedExtension = freezed,Object? extensionMangaResults = null,Object? extensionEpisodeResults = null,Object? extensionVideoResults = null,Object? effects = null,}) {
  return _then(_self.copyWith(
loggedUser: null == loggedUser ? _self.loggedUser : loggedUser // ignore: cast_nullable_to_non_nullable
as User,selectedMediaList: null == selectedMediaList ? _self.selectedMediaList : selectedMediaList // ignore: cast_nullable_to_non_nullable
as MediaList,selectedManga: null == selectedManga ? _self.selectedManga : selectedManga // ignore: cast_nullable_to_non_nullable
as Manga,mediaListEntry: null == mediaListEntry ? _self.mediaListEntry : mediaListEntry // ignore: cast_nullable_to_non_nullable
as MediaListEntry,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as (bool, List<MediaCharacter>),recommendations: null == recommendations ? _self.recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as (bool, List<Manga>),banners: null == banners ? _self.banners : banners // ignore: cast_nullable_to_non_nullable
as List<String>,alternateImage: null == alternateImage ? _self.alternateImage : alternateImage // ignore: cast_nullable_to_non_nullable
as String,installedExtensions: null == installedExtensions ? _self.installedExtensions : installedExtensions // ignore: cast_nullable_to_non_nullable
as Set<Extension>,userLoaded: null == userLoaded ? _self.userLoaded : userLoaded // ignore: cast_nullable_to_non_nullable
as bool,selectedExtension: freezed == selectedExtension ? _self.selectedExtension : selectedExtension // ignore: cast_nullable_to_non_nullable
as Extension?,extensionMangaResults: null == extensionMangaResults ? _self.extensionMangaResults : extensionMangaResults // ignore: cast_nullable_to_non_nullable
as List<JSManga>,extensionEpisodeResults: null == extensionEpisodeResults ? _self.extensionEpisodeResults : extensionEpisodeResults // ignore: cast_nullable_to_non_nullable
as List<JSChapter>,extensionVideoResults: null == extensionVideoResults ? _self.extensionVideoResults : extensionVideoResults // ignore: cast_nullable_to_non_nullable
as List<JPage>,effects: null == effects ? _self.effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,
  ));
}

}


/// Adds pattern-matching-related methods to [MangaDetailsState].
extension MangaDetailsStatePatterns on MangaDetailsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MangaDetailsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MangaDetailsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MangaDetailsState value)  $default,){
final _that = this;
switch (_that) {
case _MangaDetailsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MangaDetailsState value)?  $default,){
final _that = this;
switch (_that) {
case _MangaDetailsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User loggedUser,  MediaList selectedMediaList,  Manga selectedManga,  MediaListEntry mediaListEntry,  (bool, List<MediaCharacter>) characters,  (bool, List<Manga>) recommendations,  List<String> banners,  String alternateImage,  Set<Extension> installedExtensions,  bool userLoaded,  Extension? selectedExtension,  List<JSManga> extensionMangaResults,  List<JSChapter> extensionEpisodeResults,  List<JPage> extensionVideoResults,  List<AppEffect> effects)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MangaDetailsState() when $default != null:
return $default(_that.loggedUser,_that.selectedMediaList,_that.selectedManga,_that.mediaListEntry,_that.characters,_that.recommendations,_that.banners,_that.alternateImage,_that.installedExtensions,_that.userLoaded,_that.selectedExtension,_that.extensionMangaResults,_that.extensionEpisodeResults,_that.extensionVideoResults,_that.effects);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User loggedUser,  MediaList selectedMediaList,  Manga selectedManga,  MediaListEntry mediaListEntry,  (bool, List<MediaCharacter>) characters,  (bool, List<Manga>) recommendations,  List<String> banners,  String alternateImage,  Set<Extension> installedExtensions,  bool userLoaded,  Extension? selectedExtension,  List<JSManga> extensionMangaResults,  List<JSChapter> extensionEpisodeResults,  List<JPage> extensionVideoResults,  List<AppEffect> effects)  $default,) {final _that = this;
switch (_that) {
case _MangaDetailsState():
return $default(_that.loggedUser,_that.selectedMediaList,_that.selectedManga,_that.mediaListEntry,_that.characters,_that.recommendations,_that.banners,_that.alternateImage,_that.installedExtensions,_that.userLoaded,_that.selectedExtension,_that.extensionMangaResults,_that.extensionEpisodeResults,_that.extensionVideoResults,_that.effects);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User loggedUser,  MediaList selectedMediaList,  Manga selectedManga,  MediaListEntry mediaListEntry,  (bool, List<MediaCharacter>) characters,  (bool, List<Manga>) recommendations,  List<String> banners,  String alternateImage,  Set<Extension> installedExtensions,  bool userLoaded,  Extension? selectedExtension,  List<JSManga> extensionMangaResults,  List<JSChapter> extensionEpisodeResults,  List<JPage> extensionVideoResults,  List<AppEffect> effects)?  $default,) {final _that = this;
switch (_that) {
case _MangaDetailsState() when $default != null:
return $default(_that.loggedUser,_that.selectedMediaList,_that.selectedManga,_that.mediaListEntry,_that.characters,_that.recommendations,_that.banners,_that.alternateImage,_that.installedExtensions,_that.userLoaded,_that.selectedExtension,_that.extensionMangaResults,_that.extensionEpisodeResults,_that.extensionVideoResults,_that.effects);case _:
  return null;

}
}

}

/// @nodoc


class _MangaDetailsState extends MangaDetailsState {
  const _MangaDetailsState({required this.loggedUser, required this.selectedMediaList, required this.selectedManga, required this.mediaListEntry, required this.characters, required this.recommendations, required final  List<String> banners, required this.alternateImage, required final  Set<Extension> installedExtensions, required this.userLoaded, required this.selectedExtension, required final  List<JSManga> extensionMangaResults, required final  List<JSChapter> extensionEpisodeResults, required final  List<JPage> extensionVideoResults, final  List<AppEffect> effects = const <AppEffect>[]}): _banners = banners,_installedExtensions = installedExtensions,_extensionMangaResults = extensionMangaResults,_extensionEpisodeResults = extensionEpisodeResults,_extensionVideoResults = extensionVideoResults,_effects = effects,super._();
  

@override final  User loggedUser;
@override final  MediaList selectedMediaList;
@override final  Manga selectedManga;
@override final  MediaListEntry mediaListEntry;
@override final  (bool, List<MediaCharacter>) characters;
@override final  (bool, List<Manga>) recommendations;
 final  List<String> _banners;
@override List<String> get banners {
  if (_banners is EqualUnmodifiableListView) return _banners;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_banners);
}

@override final  String alternateImage;
 final  Set<Extension> _installedExtensions;
@override Set<Extension> get installedExtensions {
  if (_installedExtensions is EqualUnmodifiableSetView) return _installedExtensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_installedExtensions);
}

@override final  bool userLoaded;
@override final  Extension? selectedExtension;
// relations
// voice actors
 final  List<JSManga> _extensionMangaResults;
// relations
// voice actors
@override List<JSManga> get extensionMangaResults {
  if (_extensionMangaResults is EqualUnmodifiableListView) return _extensionMangaResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extensionMangaResults);
}

 final  List<JSChapter> _extensionEpisodeResults;
@override List<JSChapter> get extensionEpisodeResults {
  if (_extensionEpisodeResults is EqualUnmodifiableListView) return _extensionEpisodeResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extensionEpisodeResults);
}

 final  List<JPage> _extensionVideoResults;
@override List<JPage> get extensionVideoResults {
  if (_extensionVideoResults is EqualUnmodifiableListView) return _extensionVideoResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extensionVideoResults);
}

 final  List<AppEffect> _effects;
@override@JsonKey() List<AppEffect> get effects {
  if (_effects is EqualUnmodifiableListView) return _effects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_effects);
}


/// Create a copy of MangaDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MangaDetailsStateCopyWith<_MangaDetailsState> get copyWith => __$MangaDetailsStateCopyWithImpl<_MangaDetailsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MangaDetailsState&&(identical(other.loggedUser, loggedUser) || other.loggedUser == loggedUser)&&(identical(other.selectedMediaList, selectedMediaList) || other.selectedMediaList == selectedMediaList)&&(identical(other.selectedManga, selectedManga) || other.selectedManga == selectedManga)&&(identical(other.mediaListEntry, mediaListEntry) || other.mediaListEntry == mediaListEntry)&&(identical(other.characters, characters) || other.characters == characters)&&(identical(other.recommendations, recommendations) || other.recommendations == recommendations)&&const DeepCollectionEquality().equals(other._banners, _banners)&&(identical(other.alternateImage, alternateImage) || other.alternateImage == alternateImage)&&const DeepCollectionEquality().equals(other._installedExtensions, _installedExtensions)&&(identical(other.userLoaded, userLoaded) || other.userLoaded == userLoaded)&&(identical(other.selectedExtension, selectedExtension) || other.selectedExtension == selectedExtension)&&const DeepCollectionEquality().equals(other._extensionMangaResults, _extensionMangaResults)&&const DeepCollectionEquality().equals(other._extensionEpisodeResults, _extensionEpisodeResults)&&const DeepCollectionEquality().equals(other._extensionVideoResults, _extensionVideoResults)&&const DeepCollectionEquality().equals(other._effects, _effects));
}


@override
int get hashCode => Object.hash(runtimeType,loggedUser,selectedMediaList,selectedManga,mediaListEntry,characters,recommendations,const DeepCollectionEquality().hash(_banners),alternateImage,const DeepCollectionEquality().hash(_installedExtensions),userLoaded,selectedExtension,const DeepCollectionEquality().hash(_extensionMangaResults),const DeepCollectionEquality().hash(_extensionEpisodeResults),const DeepCollectionEquality().hash(_extensionVideoResults),const DeepCollectionEquality().hash(_effects));

@override
String toString() {
  return 'MangaDetailsState(loggedUser: $loggedUser, selectedMediaList: $selectedMediaList, selectedManga: $selectedManga, mediaListEntry: $mediaListEntry, characters: $characters, recommendations: $recommendations, banners: $banners, alternateImage: $alternateImage, installedExtensions: $installedExtensions, userLoaded: $userLoaded, selectedExtension: $selectedExtension, extensionMangaResults: $extensionMangaResults, extensionEpisodeResults: $extensionEpisodeResults, extensionVideoResults: $extensionVideoResults, effects: $effects)';
}


}

/// @nodoc
abstract mixin class _$MangaDetailsStateCopyWith<$Res> implements $MangaDetailsStateCopyWith<$Res> {
  factory _$MangaDetailsStateCopyWith(_MangaDetailsState value, $Res Function(_MangaDetailsState) _then) = __$MangaDetailsStateCopyWithImpl;
@override @useResult
$Res call({
 User loggedUser, MediaList selectedMediaList, Manga selectedManga, MediaListEntry mediaListEntry, (bool, List<MediaCharacter>) characters, (bool, List<Manga>) recommendations, List<String> banners, String alternateImage, Set<Extension> installedExtensions, bool userLoaded, Extension? selectedExtension, List<JSManga> extensionMangaResults, List<JSChapter> extensionEpisodeResults, List<JPage> extensionVideoResults, List<AppEffect> effects
});




}
/// @nodoc
class __$MangaDetailsStateCopyWithImpl<$Res>
    implements _$MangaDetailsStateCopyWith<$Res> {
  __$MangaDetailsStateCopyWithImpl(this._self, this._then);

  final _MangaDetailsState _self;
  final $Res Function(_MangaDetailsState) _then;

/// Create a copy of MangaDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loggedUser = null,Object? selectedMediaList = null,Object? selectedManga = null,Object? mediaListEntry = null,Object? characters = null,Object? recommendations = null,Object? banners = null,Object? alternateImage = null,Object? installedExtensions = null,Object? userLoaded = null,Object? selectedExtension = freezed,Object? extensionMangaResults = null,Object? extensionEpisodeResults = null,Object? extensionVideoResults = null,Object? effects = null,}) {
  return _then(_MangaDetailsState(
loggedUser: null == loggedUser ? _self.loggedUser : loggedUser // ignore: cast_nullable_to_non_nullable
as User,selectedMediaList: null == selectedMediaList ? _self.selectedMediaList : selectedMediaList // ignore: cast_nullable_to_non_nullable
as MediaList,selectedManga: null == selectedManga ? _self.selectedManga : selectedManga // ignore: cast_nullable_to_non_nullable
as Manga,mediaListEntry: null == mediaListEntry ? _self.mediaListEntry : mediaListEntry // ignore: cast_nullable_to_non_nullable
as MediaListEntry,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as (bool, List<MediaCharacter>),recommendations: null == recommendations ? _self.recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as (bool, List<Manga>),banners: null == banners ? _self._banners : banners // ignore: cast_nullable_to_non_nullable
as List<String>,alternateImage: null == alternateImage ? _self.alternateImage : alternateImage // ignore: cast_nullable_to_non_nullable
as String,installedExtensions: null == installedExtensions ? _self._installedExtensions : installedExtensions // ignore: cast_nullable_to_non_nullable
as Set<Extension>,userLoaded: null == userLoaded ? _self.userLoaded : userLoaded // ignore: cast_nullable_to_non_nullable
as bool,selectedExtension: freezed == selectedExtension ? _self.selectedExtension : selectedExtension // ignore: cast_nullable_to_non_nullable
as Extension?,extensionMangaResults: null == extensionMangaResults ? _self._extensionMangaResults : extensionMangaResults // ignore: cast_nullable_to_non_nullable
as List<JSManga>,extensionEpisodeResults: null == extensionEpisodeResults ? _self._extensionEpisodeResults : extensionEpisodeResults // ignore: cast_nullable_to_non_nullable
as List<JSChapter>,extensionVideoResults: null == extensionVideoResults ? _self._extensionVideoResults : extensionVideoResults // ignore: cast_nullable_to_non_nullable
as List<JPage>,effects: null == effects ? _self._effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anime_details_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimeDetailsState {

 User get loggedUser; MediaList get selectedMediaList; Anime get selectedAnime; MediaListEntry get mediaListEntry; MediaListEntry get newMediaListEntry; (bool, List<MediaCharacter>) get characters; (bool, List<Anime>) get recommendations; List<EpisodeInfo> get episodesInfo; List<String> get banners; String get alternateImage; Set<Extension> get installedExtensions; bool get userLoaded; bool get animeServerDialogReady; bool get animeServerDialogLoading; Extension? get selectedExtension;// relations
// voice actors
 List<JSAnime> get extensionAnimeResults; int get selectedAnimeResultIndex; List<JSEpisode> get extensionEpisodeResults; List<ext.Video> get extensionVideoResults; List<AppEffect> get effects;
/// Create a copy of AnimeDetailsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimeDetailsStateCopyWith<AnimeDetailsState> get copyWith => _$AnimeDetailsStateCopyWithImpl<AnimeDetailsState>(this as AnimeDetailsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimeDetailsState&&(identical(other.loggedUser, loggedUser) || other.loggedUser == loggedUser)&&(identical(other.selectedMediaList, selectedMediaList) || other.selectedMediaList == selectedMediaList)&&(identical(other.selectedAnime, selectedAnime) || other.selectedAnime == selectedAnime)&&(identical(other.mediaListEntry, mediaListEntry) || other.mediaListEntry == mediaListEntry)&&(identical(other.newMediaListEntry, newMediaListEntry) || other.newMediaListEntry == newMediaListEntry)&&(identical(other.characters, characters) || other.characters == characters)&&(identical(other.recommendations, recommendations) || other.recommendations == recommendations)&&const DeepCollectionEquality().equals(other.episodesInfo, episodesInfo)&&const DeepCollectionEquality().equals(other.banners, banners)&&(identical(other.alternateImage, alternateImage) || other.alternateImage == alternateImage)&&const DeepCollectionEquality().equals(other.installedExtensions, installedExtensions)&&(identical(other.userLoaded, userLoaded) || other.userLoaded == userLoaded)&&(identical(other.animeServerDialogReady, animeServerDialogReady) || other.animeServerDialogReady == animeServerDialogReady)&&(identical(other.animeServerDialogLoading, animeServerDialogLoading) || other.animeServerDialogLoading == animeServerDialogLoading)&&(identical(other.selectedExtension, selectedExtension) || other.selectedExtension == selectedExtension)&&const DeepCollectionEquality().equals(other.extensionAnimeResults, extensionAnimeResults)&&(identical(other.selectedAnimeResultIndex, selectedAnimeResultIndex) || other.selectedAnimeResultIndex == selectedAnimeResultIndex)&&const DeepCollectionEquality().equals(other.extensionEpisodeResults, extensionEpisodeResults)&&const DeepCollectionEquality().equals(other.extensionVideoResults, extensionVideoResults)&&const DeepCollectionEquality().equals(other.effects, effects));
}


@override
int get hashCode => Object.hashAll([runtimeType,loggedUser,selectedMediaList,selectedAnime,mediaListEntry,newMediaListEntry,characters,recommendations,const DeepCollectionEquality().hash(episodesInfo),const DeepCollectionEquality().hash(banners),alternateImage,const DeepCollectionEquality().hash(installedExtensions),userLoaded,animeServerDialogReady,animeServerDialogLoading,selectedExtension,const DeepCollectionEquality().hash(extensionAnimeResults),selectedAnimeResultIndex,const DeepCollectionEquality().hash(extensionEpisodeResults),const DeepCollectionEquality().hash(extensionVideoResults),const DeepCollectionEquality().hash(effects)]);

@override
String toString() {
  return 'AnimeDetailsState(loggedUser: $loggedUser, selectedMediaList: $selectedMediaList, selectedAnime: $selectedAnime, mediaListEntry: $mediaListEntry, newMediaListEntry: $newMediaListEntry, characters: $characters, recommendations: $recommendations, episodesInfo: $episodesInfo, banners: $banners, alternateImage: $alternateImage, installedExtensions: $installedExtensions, userLoaded: $userLoaded, animeServerDialogReady: $animeServerDialogReady, animeServerDialogLoading: $animeServerDialogLoading, selectedExtension: $selectedExtension, extensionAnimeResults: $extensionAnimeResults, selectedAnimeResultIndex: $selectedAnimeResultIndex, extensionEpisodeResults: $extensionEpisodeResults, extensionVideoResults: $extensionVideoResults, effects: $effects)';
}


}

/// @nodoc
abstract mixin class $AnimeDetailsStateCopyWith<$Res>  {
  factory $AnimeDetailsStateCopyWith(AnimeDetailsState value, $Res Function(AnimeDetailsState) _then) = _$AnimeDetailsStateCopyWithImpl;
@useResult
$Res call({
 User loggedUser, MediaList selectedMediaList, Anime selectedAnime, MediaListEntry mediaListEntry, MediaListEntry newMediaListEntry, (bool, List<MediaCharacter>) characters, (bool, List<Anime>) recommendations, List<EpisodeInfo> episodesInfo, List<String> banners, String alternateImage, Set<Extension> installedExtensions, bool userLoaded, bool animeServerDialogReady, bool animeServerDialogLoading, Extension? selectedExtension, List<JSAnime> extensionAnimeResults, int selectedAnimeResultIndex, List<JSEpisode> extensionEpisodeResults, List<ext.Video> extensionVideoResults, List<AppEffect> effects
});




}
/// @nodoc
class _$AnimeDetailsStateCopyWithImpl<$Res>
    implements $AnimeDetailsStateCopyWith<$Res> {
  _$AnimeDetailsStateCopyWithImpl(this._self, this._then);

  final AnimeDetailsState _self;
  final $Res Function(AnimeDetailsState) _then;

/// Create a copy of AnimeDetailsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loggedUser = null,Object? selectedMediaList = null,Object? selectedAnime = null,Object? mediaListEntry = null,Object? newMediaListEntry = null,Object? characters = null,Object? recommendations = null,Object? episodesInfo = null,Object? banners = null,Object? alternateImage = null,Object? installedExtensions = null,Object? userLoaded = null,Object? animeServerDialogReady = null,Object? animeServerDialogLoading = null,Object? selectedExtension = freezed,Object? extensionAnimeResults = null,Object? selectedAnimeResultIndex = null,Object? extensionEpisodeResults = null,Object? extensionVideoResults = null,Object? effects = null,}) {
  return _then(_self.copyWith(
loggedUser: null == loggedUser ? _self.loggedUser : loggedUser // ignore: cast_nullable_to_non_nullable
as User,selectedMediaList: null == selectedMediaList ? _self.selectedMediaList : selectedMediaList // ignore: cast_nullable_to_non_nullable
as MediaList,selectedAnime: null == selectedAnime ? _self.selectedAnime : selectedAnime // ignore: cast_nullable_to_non_nullable
as Anime,mediaListEntry: null == mediaListEntry ? _self.mediaListEntry : mediaListEntry // ignore: cast_nullable_to_non_nullable
as MediaListEntry,newMediaListEntry: null == newMediaListEntry ? _self.newMediaListEntry : newMediaListEntry // ignore: cast_nullable_to_non_nullable
as MediaListEntry,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as (bool, List<MediaCharacter>),recommendations: null == recommendations ? _self.recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as (bool, List<Anime>),episodesInfo: null == episodesInfo ? _self.episodesInfo : episodesInfo // ignore: cast_nullable_to_non_nullable
as List<EpisodeInfo>,banners: null == banners ? _self.banners : banners // ignore: cast_nullable_to_non_nullable
as List<String>,alternateImage: null == alternateImage ? _self.alternateImage : alternateImage // ignore: cast_nullable_to_non_nullable
as String,installedExtensions: null == installedExtensions ? _self.installedExtensions : installedExtensions // ignore: cast_nullable_to_non_nullable
as Set<Extension>,userLoaded: null == userLoaded ? _self.userLoaded : userLoaded // ignore: cast_nullable_to_non_nullable
as bool,animeServerDialogReady: null == animeServerDialogReady ? _self.animeServerDialogReady : animeServerDialogReady // ignore: cast_nullable_to_non_nullable
as bool,animeServerDialogLoading: null == animeServerDialogLoading ? _self.animeServerDialogLoading : animeServerDialogLoading // ignore: cast_nullable_to_non_nullable
as bool,selectedExtension: freezed == selectedExtension ? _self.selectedExtension : selectedExtension // ignore: cast_nullable_to_non_nullable
as Extension?,extensionAnimeResults: null == extensionAnimeResults ? _self.extensionAnimeResults : extensionAnimeResults // ignore: cast_nullable_to_non_nullable
as List<JSAnime>,selectedAnimeResultIndex: null == selectedAnimeResultIndex ? _self.selectedAnimeResultIndex : selectedAnimeResultIndex // ignore: cast_nullable_to_non_nullable
as int,extensionEpisodeResults: null == extensionEpisodeResults ? _self.extensionEpisodeResults : extensionEpisodeResults // ignore: cast_nullable_to_non_nullable
as List<JSEpisode>,extensionVideoResults: null == extensionVideoResults ? _self.extensionVideoResults : extensionVideoResults // ignore: cast_nullable_to_non_nullable
as List<ext.Video>,effects: null == effects ? _self.effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimeDetailsState].
extension AnimeDetailsStatePatterns on AnimeDetailsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimeDetailsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimeDetailsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimeDetailsState value)  $default,){
final _that = this;
switch (_that) {
case _AnimeDetailsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimeDetailsState value)?  $default,){
final _that = this;
switch (_that) {
case _AnimeDetailsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User loggedUser,  MediaList selectedMediaList,  Anime selectedAnime,  MediaListEntry mediaListEntry,  MediaListEntry newMediaListEntry,  (bool, List<MediaCharacter>) characters,  (bool, List<Anime>) recommendations,  List<EpisodeInfo> episodesInfo,  List<String> banners,  String alternateImage,  Set<Extension> installedExtensions,  bool userLoaded,  bool animeServerDialogReady,  bool animeServerDialogLoading,  Extension? selectedExtension,  List<JSAnime> extensionAnimeResults,  int selectedAnimeResultIndex,  List<JSEpisode> extensionEpisodeResults,  List<ext.Video> extensionVideoResults,  List<AppEffect> effects)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimeDetailsState() when $default != null:
return $default(_that.loggedUser,_that.selectedMediaList,_that.selectedAnime,_that.mediaListEntry,_that.newMediaListEntry,_that.characters,_that.recommendations,_that.episodesInfo,_that.banners,_that.alternateImage,_that.installedExtensions,_that.userLoaded,_that.animeServerDialogReady,_that.animeServerDialogLoading,_that.selectedExtension,_that.extensionAnimeResults,_that.selectedAnimeResultIndex,_that.extensionEpisodeResults,_that.extensionVideoResults,_that.effects);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User loggedUser,  MediaList selectedMediaList,  Anime selectedAnime,  MediaListEntry mediaListEntry,  MediaListEntry newMediaListEntry,  (bool, List<MediaCharacter>) characters,  (bool, List<Anime>) recommendations,  List<EpisodeInfo> episodesInfo,  List<String> banners,  String alternateImage,  Set<Extension> installedExtensions,  bool userLoaded,  bool animeServerDialogReady,  bool animeServerDialogLoading,  Extension? selectedExtension,  List<JSAnime> extensionAnimeResults,  int selectedAnimeResultIndex,  List<JSEpisode> extensionEpisodeResults,  List<ext.Video> extensionVideoResults,  List<AppEffect> effects)  $default,) {final _that = this;
switch (_that) {
case _AnimeDetailsState():
return $default(_that.loggedUser,_that.selectedMediaList,_that.selectedAnime,_that.mediaListEntry,_that.newMediaListEntry,_that.characters,_that.recommendations,_that.episodesInfo,_that.banners,_that.alternateImage,_that.installedExtensions,_that.userLoaded,_that.animeServerDialogReady,_that.animeServerDialogLoading,_that.selectedExtension,_that.extensionAnimeResults,_that.selectedAnimeResultIndex,_that.extensionEpisodeResults,_that.extensionVideoResults,_that.effects);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User loggedUser,  MediaList selectedMediaList,  Anime selectedAnime,  MediaListEntry mediaListEntry,  MediaListEntry newMediaListEntry,  (bool, List<MediaCharacter>) characters,  (bool, List<Anime>) recommendations,  List<EpisodeInfo> episodesInfo,  List<String> banners,  String alternateImage,  Set<Extension> installedExtensions,  bool userLoaded,  bool animeServerDialogReady,  bool animeServerDialogLoading,  Extension? selectedExtension,  List<JSAnime> extensionAnimeResults,  int selectedAnimeResultIndex,  List<JSEpisode> extensionEpisodeResults,  List<ext.Video> extensionVideoResults,  List<AppEffect> effects)?  $default,) {final _that = this;
switch (_that) {
case _AnimeDetailsState() when $default != null:
return $default(_that.loggedUser,_that.selectedMediaList,_that.selectedAnime,_that.mediaListEntry,_that.newMediaListEntry,_that.characters,_that.recommendations,_that.episodesInfo,_that.banners,_that.alternateImage,_that.installedExtensions,_that.userLoaded,_that.animeServerDialogReady,_that.animeServerDialogLoading,_that.selectedExtension,_that.extensionAnimeResults,_that.selectedAnimeResultIndex,_that.extensionEpisodeResults,_that.extensionVideoResults,_that.effects);case _:
  return null;

}
}

}

/// @nodoc


class _AnimeDetailsState extends AnimeDetailsState {
  const _AnimeDetailsState({required this.loggedUser, required this.selectedMediaList, required this.selectedAnime, required this.mediaListEntry, required this.newMediaListEntry, required this.characters, required this.recommendations, required final  List<EpisodeInfo> episodesInfo, required final  List<String> banners, required this.alternateImage, required final  Set<Extension> installedExtensions, required this.userLoaded, required this.animeServerDialogReady, required this.animeServerDialogLoading, required this.selectedExtension, required final  List<JSAnime> extensionAnimeResults, required this.selectedAnimeResultIndex, required final  List<JSEpisode> extensionEpisodeResults, required final  List<ext.Video> extensionVideoResults, final  List<AppEffect> effects = const <AppEffect>[]}): _episodesInfo = episodesInfo,_banners = banners,_installedExtensions = installedExtensions,_extensionAnimeResults = extensionAnimeResults,_extensionEpisodeResults = extensionEpisodeResults,_extensionVideoResults = extensionVideoResults,_effects = effects,super._();
  

@override final  User loggedUser;
@override final  MediaList selectedMediaList;
@override final  Anime selectedAnime;
@override final  MediaListEntry mediaListEntry;
@override final  MediaListEntry newMediaListEntry;
@override final  (bool, List<MediaCharacter>) characters;
@override final  (bool, List<Anime>) recommendations;
 final  List<EpisodeInfo> _episodesInfo;
@override List<EpisodeInfo> get episodesInfo {
  if (_episodesInfo is EqualUnmodifiableListView) return _episodesInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_episodesInfo);
}

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
@override final  bool animeServerDialogReady;
@override final  bool animeServerDialogLoading;
@override final  Extension? selectedExtension;
// relations
// voice actors
 final  List<JSAnime> _extensionAnimeResults;
// relations
// voice actors
@override List<JSAnime> get extensionAnimeResults {
  if (_extensionAnimeResults is EqualUnmodifiableListView) return _extensionAnimeResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extensionAnimeResults);
}

@override final  int selectedAnimeResultIndex;
 final  List<JSEpisode> _extensionEpisodeResults;
@override List<JSEpisode> get extensionEpisodeResults {
  if (_extensionEpisodeResults is EqualUnmodifiableListView) return _extensionEpisodeResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extensionEpisodeResults);
}

 final  List<ext.Video> _extensionVideoResults;
@override List<ext.Video> get extensionVideoResults {
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


/// Create a copy of AnimeDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimeDetailsStateCopyWith<_AnimeDetailsState> get copyWith => __$AnimeDetailsStateCopyWithImpl<_AnimeDetailsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimeDetailsState&&(identical(other.loggedUser, loggedUser) || other.loggedUser == loggedUser)&&(identical(other.selectedMediaList, selectedMediaList) || other.selectedMediaList == selectedMediaList)&&(identical(other.selectedAnime, selectedAnime) || other.selectedAnime == selectedAnime)&&(identical(other.mediaListEntry, mediaListEntry) || other.mediaListEntry == mediaListEntry)&&(identical(other.newMediaListEntry, newMediaListEntry) || other.newMediaListEntry == newMediaListEntry)&&(identical(other.characters, characters) || other.characters == characters)&&(identical(other.recommendations, recommendations) || other.recommendations == recommendations)&&const DeepCollectionEquality().equals(other._episodesInfo, _episodesInfo)&&const DeepCollectionEquality().equals(other._banners, _banners)&&(identical(other.alternateImage, alternateImage) || other.alternateImage == alternateImage)&&const DeepCollectionEquality().equals(other._installedExtensions, _installedExtensions)&&(identical(other.userLoaded, userLoaded) || other.userLoaded == userLoaded)&&(identical(other.animeServerDialogReady, animeServerDialogReady) || other.animeServerDialogReady == animeServerDialogReady)&&(identical(other.animeServerDialogLoading, animeServerDialogLoading) || other.animeServerDialogLoading == animeServerDialogLoading)&&(identical(other.selectedExtension, selectedExtension) || other.selectedExtension == selectedExtension)&&const DeepCollectionEquality().equals(other._extensionAnimeResults, _extensionAnimeResults)&&(identical(other.selectedAnimeResultIndex, selectedAnimeResultIndex) || other.selectedAnimeResultIndex == selectedAnimeResultIndex)&&const DeepCollectionEquality().equals(other._extensionEpisodeResults, _extensionEpisodeResults)&&const DeepCollectionEquality().equals(other._extensionVideoResults, _extensionVideoResults)&&const DeepCollectionEquality().equals(other._effects, _effects));
}


@override
int get hashCode => Object.hashAll([runtimeType,loggedUser,selectedMediaList,selectedAnime,mediaListEntry,newMediaListEntry,characters,recommendations,const DeepCollectionEquality().hash(_episodesInfo),const DeepCollectionEquality().hash(_banners),alternateImage,const DeepCollectionEquality().hash(_installedExtensions),userLoaded,animeServerDialogReady,animeServerDialogLoading,selectedExtension,const DeepCollectionEquality().hash(_extensionAnimeResults),selectedAnimeResultIndex,const DeepCollectionEquality().hash(_extensionEpisodeResults),const DeepCollectionEquality().hash(_extensionVideoResults),const DeepCollectionEquality().hash(_effects)]);

@override
String toString() {
  return 'AnimeDetailsState(loggedUser: $loggedUser, selectedMediaList: $selectedMediaList, selectedAnime: $selectedAnime, mediaListEntry: $mediaListEntry, newMediaListEntry: $newMediaListEntry, characters: $characters, recommendations: $recommendations, episodesInfo: $episodesInfo, banners: $banners, alternateImage: $alternateImage, installedExtensions: $installedExtensions, userLoaded: $userLoaded, animeServerDialogReady: $animeServerDialogReady, animeServerDialogLoading: $animeServerDialogLoading, selectedExtension: $selectedExtension, extensionAnimeResults: $extensionAnimeResults, selectedAnimeResultIndex: $selectedAnimeResultIndex, extensionEpisodeResults: $extensionEpisodeResults, extensionVideoResults: $extensionVideoResults, effects: $effects)';
}


}

/// @nodoc
abstract mixin class _$AnimeDetailsStateCopyWith<$Res> implements $AnimeDetailsStateCopyWith<$Res> {
  factory _$AnimeDetailsStateCopyWith(_AnimeDetailsState value, $Res Function(_AnimeDetailsState) _then) = __$AnimeDetailsStateCopyWithImpl;
@override @useResult
$Res call({
 User loggedUser, MediaList selectedMediaList, Anime selectedAnime, MediaListEntry mediaListEntry, MediaListEntry newMediaListEntry, (bool, List<MediaCharacter>) characters, (bool, List<Anime>) recommendations, List<EpisodeInfo> episodesInfo, List<String> banners, String alternateImage, Set<Extension> installedExtensions, bool userLoaded, bool animeServerDialogReady, bool animeServerDialogLoading, Extension? selectedExtension, List<JSAnime> extensionAnimeResults, int selectedAnimeResultIndex, List<JSEpisode> extensionEpisodeResults, List<ext.Video> extensionVideoResults, List<AppEffect> effects
});




}
/// @nodoc
class __$AnimeDetailsStateCopyWithImpl<$Res>
    implements _$AnimeDetailsStateCopyWith<$Res> {
  __$AnimeDetailsStateCopyWithImpl(this._self, this._then);

  final _AnimeDetailsState _self;
  final $Res Function(_AnimeDetailsState) _then;

/// Create a copy of AnimeDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loggedUser = null,Object? selectedMediaList = null,Object? selectedAnime = null,Object? mediaListEntry = null,Object? newMediaListEntry = null,Object? characters = null,Object? recommendations = null,Object? episodesInfo = null,Object? banners = null,Object? alternateImage = null,Object? installedExtensions = null,Object? userLoaded = null,Object? animeServerDialogReady = null,Object? animeServerDialogLoading = null,Object? selectedExtension = freezed,Object? extensionAnimeResults = null,Object? selectedAnimeResultIndex = null,Object? extensionEpisodeResults = null,Object? extensionVideoResults = null,Object? effects = null,}) {
  return _then(_AnimeDetailsState(
loggedUser: null == loggedUser ? _self.loggedUser : loggedUser // ignore: cast_nullable_to_non_nullable
as User,selectedMediaList: null == selectedMediaList ? _self.selectedMediaList : selectedMediaList // ignore: cast_nullable_to_non_nullable
as MediaList,selectedAnime: null == selectedAnime ? _self.selectedAnime : selectedAnime // ignore: cast_nullable_to_non_nullable
as Anime,mediaListEntry: null == mediaListEntry ? _self.mediaListEntry : mediaListEntry // ignore: cast_nullable_to_non_nullable
as MediaListEntry,newMediaListEntry: null == newMediaListEntry ? _self.newMediaListEntry : newMediaListEntry // ignore: cast_nullable_to_non_nullable
as MediaListEntry,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as (bool, List<MediaCharacter>),recommendations: null == recommendations ? _self.recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as (bool, List<Anime>),episodesInfo: null == episodesInfo ? _self._episodesInfo : episodesInfo // ignore: cast_nullable_to_non_nullable
as List<EpisodeInfo>,banners: null == banners ? _self._banners : banners // ignore: cast_nullable_to_non_nullable
as List<String>,alternateImage: null == alternateImage ? _self.alternateImage : alternateImage // ignore: cast_nullable_to_non_nullable
as String,installedExtensions: null == installedExtensions ? _self._installedExtensions : installedExtensions // ignore: cast_nullable_to_non_nullable
as Set<Extension>,userLoaded: null == userLoaded ? _self.userLoaded : userLoaded // ignore: cast_nullable_to_non_nullable
as bool,animeServerDialogReady: null == animeServerDialogReady ? _self.animeServerDialogReady : animeServerDialogReady // ignore: cast_nullable_to_non_nullable
as bool,animeServerDialogLoading: null == animeServerDialogLoading ? _self.animeServerDialogLoading : animeServerDialogLoading // ignore: cast_nullable_to_non_nullable
as bool,selectedExtension: freezed == selectedExtension ? _self.selectedExtension : selectedExtension // ignore: cast_nullable_to_non_nullable
as Extension?,extensionAnimeResults: null == extensionAnimeResults ? _self._extensionAnimeResults : extensionAnimeResults // ignore: cast_nullable_to_non_nullable
as List<JSAnime>,selectedAnimeResultIndex: null == selectedAnimeResultIndex ? _self.selectedAnimeResultIndex : selectedAnimeResultIndex // ignore: cast_nullable_to_non_nullable
as int,extensionEpisodeResults: null == extensionEpisodeResults ? _self._extensionEpisodeResults : extensionEpisodeResults // ignore: cast_nullable_to_non_nullable
as List<JSEpisode>,extensionVideoResults: null == extensionVideoResults ? _self._extensionVideoResults : extensionVideoResults // ignore: cast_nullable_to_non_nullable
as List<ext.Video>,effects: null == effects ? _self._effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,
  ));
}


}

// dart format on

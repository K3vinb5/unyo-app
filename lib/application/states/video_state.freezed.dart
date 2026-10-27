// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideoState {

 User get loggedUser; VideoInfo get videoInfo; Anime get selectedAnime; List<EpisodeInfo> get episodesInfo; bool get episodesLoaded; Extension get selectedExtension; List<JSEpisode> get extensionEpisodeResults; MediaListEntry get mediaListEntry; List<CastDevice> get availableCastDevices; AniskipTimesResults get openingSkipTimes; AniskipTimesResults get endingSkipTimes; bool get isLoading; List<AppEffect> get effects;
/// Create a copy of VideoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoStateCopyWith<VideoState> get copyWith => _$VideoStateCopyWithImpl<VideoState>(this as VideoState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoState&&(identical(other.loggedUser, loggedUser) || other.loggedUser == loggedUser)&&(identical(other.videoInfo, videoInfo) || other.videoInfo == videoInfo)&&(identical(other.selectedAnime, selectedAnime) || other.selectedAnime == selectedAnime)&&const DeepCollectionEquality().equals(other.episodesInfo, episodesInfo)&&(identical(other.episodesLoaded, episodesLoaded) || other.episodesLoaded == episodesLoaded)&&(identical(other.selectedExtension, selectedExtension) || other.selectedExtension == selectedExtension)&&const DeepCollectionEquality().equals(other.extensionEpisodeResults, extensionEpisodeResults)&&(identical(other.mediaListEntry, mediaListEntry) || other.mediaListEntry == mediaListEntry)&&const DeepCollectionEquality().equals(other.availableCastDevices, availableCastDevices)&&(identical(other.openingSkipTimes, openingSkipTimes) || other.openingSkipTimes == openingSkipTimes)&&(identical(other.endingSkipTimes, endingSkipTimes) || other.endingSkipTimes == endingSkipTimes)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.effects, effects));
}


@override
int get hashCode => Object.hash(runtimeType,loggedUser,videoInfo,selectedAnime,const DeepCollectionEquality().hash(episodesInfo),episodesLoaded,selectedExtension,const DeepCollectionEquality().hash(extensionEpisodeResults),mediaListEntry,const DeepCollectionEquality().hash(availableCastDevices),openingSkipTimes,endingSkipTimes,isLoading,const DeepCollectionEquality().hash(effects));

@override
String toString() {
  return 'VideoState(loggedUser: $loggedUser, videoInfo: $videoInfo, selectedAnime: $selectedAnime, episodesInfo: $episodesInfo, episodesLoaded: $episodesLoaded, selectedExtension: $selectedExtension, extensionEpisodeResults: $extensionEpisodeResults, mediaListEntry: $mediaListEntry, availableCastDevices: $availableCastDevices, openingSkipTimes: $openingSkipTimes, endingSkipTimes: $endingSkipTimes, isLoading: $isLoading, effects: $effects)';
}


}

/// @nodoc
abstract mixin class $VideoStateCopyWith<$Res>  {
  factory $VideoStateCopyWith(VideoState value, $Res Function(VideoState) _then) = _$VideoStateCopyWithImpl;
@useResult
$Res call({
 User loggedUser, VideoInfo videoInfo, Anime selectedAnime, List<EpisodeInfo> episodesInfo, bool episodesLoaded, Extension selectedExtension, List<JSEpisode> extensionEpisodeResults, MediaListEntry mediaListEntry, List<CastDevice> availableCastDevices, AniskipTimesResults openingSkipTimes, AniskipTimesResults endingSkipTimes, bool isLoading, List<AppEffect> effects
});




}
/// @nodoc
class _$VideoStateCopyWithImpl<$Res>
    implements $VideoStateCopyWith<$Res> {
  _$VideoStateCopyWithImpl(this._self, this._then);

  final VideoState _self;
  final $Res Function(VideoState) _then;

/// Create a copy of VideoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loggedUser = null,Object? videoInfo = null,Object? selectedAnime = null,Object? episodesInfo = null,Object? episodesLoaded = null,Object? selectedExtension = null,Object? extensionEpisodeResults = null,Object? mediaListEntry = null,Object? availableCastDevices = null,Object? openingSkipTimes = null,Object? endingSkipTimes = null,Object? isLoading = null,Object? effects = null,}) {
  return _then(_self.copyWith(
loggedUser: null == loggedUser ? _self.loggedUser : loggedUser // ignore: cast_nullable_to_non_nullable
as User,videoInfo: null == videoInfo ? _self.videoInfo : videoInfo // ignore: cast_nullable_to_non_nullable
as VideoInfo,selectedAnime: null == selectedAnime ? _self.selectedAnime : selectedAnime // ignore: cast_nullable_to_non_nullable
as Anime,episodesInfo: null == episodesInfo ? _self.episodesInfo : episodesInfo // ignore: cast_nullable_to_non_nullable
as List<EpisodeInfo>,episodesLoaded: null == episodesLoaded ? _self.episodesLoaded : episodesLoaded // ignore: cast_nullable_to_non_nullable
as bool,selectedExtension: null == selectedExtension ? _self.selectedExtension : selectedExtension // ignore: cast_nullable_to_non_nullable
as Extension,extensionEpisodeResults: null == extensionEpisodeResults ? _self.extensionEpisodeResults : extensionEpisodeResults // ignore: cast_nullable_to_non_nullable
as List<JSEpisode>,mediaListEntry: null == mediaListEntry ? _self.mediaListEntry : mediaListEntry // ignore: cast_nullable_to_non_nullable
as MediaListEntry,availableCastDevices: null == availableCastDevices ? _self.availableCastDevices : availableCastDevices // ignore: cast_nullable_to_non_nullable
as List<CastDevice>,openingSkipTimes: null == openingSkipTimes ? _self.openingSkipTimes : openingSkipTimes // ignore: cast_nullable_to_non_nullable
as AniskipTimesResults,endingSkipTimes: null == endingSkipTimes ? _self.endingSkipTimes : endingSkipTimes // ignore: cast_nullable_to_non_nullable
as AniskipTimesResults,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,effects: null == effects ? _self.effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoState].
extension VideoStatePatterns on VideoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoState value)  $default,){
final _that = this;
switch (_that) {
case _VideoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoState value)?  $default,){
final _that = this;
switch (_that) {
case _VideoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User loggedUser,  VideoInfo videoInfo,  Anime selectedAnime,  List<EpisodeInfo> episodesInfo,  bool episodesLoaded,  Extension selectedExtension,  List<JSEpisode> extensionEpisodeResults,  MediaListEntry mediaListEntry,  List<CastDevice> availableCastDevices,  AniskipTimesResults openingSkipTimes,  AniskipTimesResults endingSkipTimes,  bool isLoading,  List<AppEffect> effects)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoState() when $default != null:
return $default(_that.loggedUser,_that.videoInfo,_that.selectedAnime,_that.episodesInfo,_that.episodesLoaded,_that.selectedExtension,_that.extensionEpisodeResults,_that.mediaListEntry,_that.availableCastDevices,_that.openingSkipTimes,_that.endingSkipTimes,_that.isLoading,_that.effects);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User loggedUser,  VideoInfo videoInfo,  Anime selectedAnime,  List<EpisodeInfo> episodesInfo,  bool episodesLoaded,  Extension selectedExtension,  List<JSEpisode> extensionEpisodeResults,  MediaListEntry mediaListEntry,  List<CastDevice> availableCastDevices,  AniskipTimesResults openingSkipTimes,  AniskipTimesResults endingSkipTimes,  bool isLoading,  List<AppEffect> effects)  $default,) {final _that = this;
switch (_that) {
case _VideoState():
return $default(_that.loggedUser,_that.videoInfo,_that.selectedAnime,_that.episodesInfo,_that.episodesLoaded,_that.selectedExtension,_that.extensionEpisodeResults,_that.mediaListEntry,_that.availableCastDevices,_that.openingSkipTimes,_that.endingSkipTimes,_that.isLoading,_that.effects);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User loggedUser,  VideoInfo videoInfo,  Anime selectedAnime,  List<EpisodeInfo> episodesInfo,  bool episodesLoaded,  Extension selectedExtension,  List<JSEpisode> extensionEpisodeResults,  MediaListEntry mediaListEntry,  List<CastDevice> availableCastDevices,  AniskipTimesResults openingSkipTimes,  AniskipTimesResults endingSkipTimes,  bool isLoading,  List<AppEffect> effects)?  $default,) {final _that = this;
switch (_that) {
case _VideoState() when $default != null:
return $default(_that.loggedUser,_that.videoInfo,_that.selectedAnime,_that.episodesInfo,_that.episodesLoaded,_that.selectedExtension,_that.extensionEpisodeResults,_that.mediaListEntry,_that.availableCastDevices,_that.openingSkipTimes,_that.endingSkipTimes,_that.isLoading,_that.effects);case _:
  return null;

}
}

}

/// @nodoc


class _VideoState extends VideoState {
  const _VideoState({required this.loggedUser, required this.videoInfo, required this.selectedAnime, required final  List<EpisodeInfo> episodesInfo, required this.episodesLoaded, required this.selectedExtension, required final  List<JSEpisode> extensionEpisodeResults, required this.mediaListEntry, required final  List<CastDevice> availableCastDevices, required this.openingSkipTimes, required this.endingSkipTimes, required this.isLoading, final  List<AppEffect> effects = const <AppEffect>[]}): _episodesInfo = episodesInfo,_extensionEpisodeResults = extensionEpisodeResults,_availableCastDevices = availableCastDevices,_effects = effects,super._();
  

@override final  User loggedUser;
@override final  VideoInfo videoInfo;
@override final  Anime selectedAnime;
 final  List<EpisodeInfo> _episodesInfo;
@override List<EpisodeInfo> get episodesInfo {
  if (_episodesInfo is EqualUnmodifiableListView) return _episodesInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_episodesInfo);
}

@override final  bool episodesLoaded;
@override final  Extension selectedExtension;
 final  List<JSEpisode> _extensionEpisodeResults;
@override List<JSEpisode> get extensionEpisodeResults {
  if (_extensionEpisodeResults is EqualUnmodifiableListView) return _extensionEpisodeResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extensionEpisodeResults);
}

@override final  MediaListEntry mediaListEntry;
 final  List<CastDevice> _availableCastDevices;
@override List<CastDevice> get availableCastDevices {
  if (_availableCastDevices is EqualUnmodifiableListView) return _availableCastDevices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableCastDevices);
}

@override final  AniskipTimesResults openingSkipTimes;
@override final  AniskipTimesResults endingSkipTimes;
@override final  bool isLoading;
 final  List<AppEffect> _effects;
@override@JsonKey() List<AppEffect> get effects {
  if (_effects is EqualUnmodifiableListView) return _effects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_effects);
}


/// Create a copy of VideoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoStateCopyWith<_VideoState> get copyWith => __$VideoStateCopyWithImpl<_VideoState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoState&&(identical(other.loggedUser, loggedUser) || other.loggedUser == loggedUser)&&(identical(other.videoInfo, videoInfo) || other.videoInfo == videoInfo)&&(identical(other.selectedAnime, selectedAnime) || other.selectedAnime == selectedAnime)&&const DeepCollectionEquality().equals(other._episodesInfo, _episodesInfo)&&(identical(other.episodesLoaded, episodesLoaded) || other.episodesLoaded == episodesLoaded)&&(identical(other.selectedExtension, selectedExtension) || other.selectedExtension == selectedExtension)&&const DeepCollectionEquality().equals(other._extensionEpisodeResults, _extensionEpisodeResults)&&(identical(other.mediaListEntry, mediaListEntry) || other.mediaListEntry == mediaListEntry)&&const DeepCollectionEquality().equals(other._availableCastDevices, _availableCastDevices)&&(identical(other.openingSkipTimes, openingSkipTimes) || other.openingSkipTimes == openingSkipTimes)&&(identical(other.endingSkipTimes, endingSkipTimes) || other.endingSkipTimes == endingSkipTimes)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._effects, _effects));
}


@override
int get hashCode => Object.hash(runtimeType,loggedUser,videoInfo,selectedAnime,const DeepCollectionEquality().hash(_episodesInfo),episodesLoaded,selectedExtension,const DeepCollectionEquality().hash(_extensionEpisodeResults),mediaListEntry,const DeepCollectionEquality().hash(_availableCastDevices),openingSkipTimes,endingSkipTimes,isLoading,const DeepCollectionEquality().hash(_effects));

@override
String toString() {
  return 'VideoState(loggedUser: $loggedUser, videoInfo: $videoInfo, selectedAnime: $selectedAnime, episodesInfo: $episodesInfo, episodesLoaded: $episodesLoaded, selectedExtension: $selectedExtension, extensionEpisodeResults: $extensionEpisodeResults, mediaListEntry: $mediaListEntry, availableCastDevices: $availableCastDevices, openingSkipTimes: $openingSkipTimes, endingSkipTimes: $endingSkipTimes, isLoading: $isLoading, effects: $effects)';
}


}

/// @nodoc
abstract mixin class _$VideoStateCopyWith<$Res> implements $VideoStateCopyWith<$Res> {
  factory _$VideoStateCopyWith(_VideoState value, $Res Function(_VideoState) _then) = __$VideoStateCopyWithImpl;
@override @useResult
$Res call({
 User loggedUser, VideoInfo videoInfo, Anime selectedAnime, List<EpisodeInfo> episodesInfo, bool episodesLoaded, Extension selectedExtension, List<JSEpisode> extensionEpisodeResults, MediaListEntry mediaListEntry, List<CastDevice> availableCastDevices, AniskipTimesResults openingSkipTimes, AniskipTimesResults endingSkipTimes, bool isLoading, List<AppEffect> effects
});




}
/// @nodoc
class __$VideoStateCopyWithImpl<$Res>
    implements _$VideoStateCopyWith<$Res> {
  __$VideoStateCopyWithImpl(this._self, this._then);

  final _VideoState _self;
  final $Res Function(_VideoState) _then;

/// Create a copy of VideoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loggedUser = null,Object? videoInfo = null,Object? selectedAnime = null,Object? episodesInfo = null,Object? episodesLoaded = null,Object? selectedExtension = null,Object? extensionEpisodeResults = null,Object? mediaListEntry = null,Object? availableCastDevices = null,Object? openingSkipTimes = null,Object? endingSkipTimes = null,Object? isLoading = null,Object? effects = null,}) {
  return _then(_VideoState(
loggedUser: null == loggedUser ? _self.loggedUser : loggedUser // ignore: cast_nullable_to_non_nullable
as User,videoInfo: null == videoInfo ? _self.videoInfo : videoInfo // ignore: cast_nullable_to_non_nullable
as VideoInfo,selectedAnime: null == selectedAnime ? _self.selectedAnime : selectedAnime // ignore: cast_nullable_to_non_nullable
as Anime,episodesInfo: null == episodesInfo ? _self._episodesInfo : episodesInfo // ignore: cast_nullable_to_non_nullable
as List<EpisodeInfo>,episodesLoaded: null == episodesLoaded ? _self.episodesLoaded : episodesLoaded // ignore: cast_nullable_to_non_nullable
as bool,selectedExtension: null == selectedExtension ? _self.selectedExtension : selectedExtension // ignore: cast_nullable_to_non_nullable
as Extension,extensionEpisodeResults: null == extensionEpisodeResults ? _self._extensionEpisodeResults : extensionEpisodeResults // ignore: cast_nullable_to_non_nullable
as List<JSEpisode>,mediaListEntry: null == mediaListEntry ? _self.mediaListEntry : mediaListEntry // ignore: cast_nullable_to_non_nullable
as MediaListEntry,availableCastDevices: null == availableCastDevices ? _self._availableCastDevices : availableCastDevices // ignore: cast_nullable_to_non_nullable
as List<CastDevice>,openingSkipTimes: null == openingSkipTimes ? _self.openingSkipTimes : openingSkipTimes // ignore: cast_nullable_to_non_nullable
as AniskipTimesResults,endingSkipTimes: null == endingSkipTimes ? _self.endingSkipTimes : endingSkipTimes // ignore: cast_nullable_to_non_nullable
as AniskipTimesResults,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,effects: null == effects ? _self._effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,
  ));
}


}

// dart format on

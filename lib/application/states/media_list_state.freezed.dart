// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MediaListState {

 Map<String, List<Anime>> get userAnimeLists; Map<String, List<Manga>> get userMangaLists; User get loggedUser; bool get isLoading; List<AppEffect> get effects;
/// Create a copy of MediaListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaListStateCopyWith<MediaListState> get copyWith => _$MediaListStateCopyWithImpl<MediaListState>(this as MediaListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaListState&&const DeepCollectionEquality().equals(other.userAnimeLists, userAnimeLists)&&const DeepCollectionEquality().equals(other.userMangaLists, userMangaLists)&&(identical(other.loggedUser, loggedUser) || other.loggedUser == loggedUser)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.effects, effects));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(userAnimeLists),const DeepCollectionEquality().hash(userMangaLists),loggedUser,isLoading,const DeepCollectionEquality().hash(effects));

@override
String toString() {
  return 'MediaListState(userAnimeLists: $userAnimeLists, userMangaLists: $userMangaLists, loggedUser: $loggedUser, isLoading: $isLoading, effects: $effects)';
}


}

/// @nodoc
abstract mixin class $MediaListStateCopyWith<$Res>  {
  factory $MediaListStateCopyWith(MediaListState value, $Res Function(MediaListState) _then) = _$MediaListStateCopyWithImpl;
@useResult
$Res call({
 Map<String, List<Anime>> userAnimeLists, Map<String, List<Manga>> userMangaLists, User loggedUser, bool isLoading, List<AppEffect> effects
});




}
/// @nodoc
class _$MediaListStateCopyWithImpl<$Res>
    implements $MediaListStateCopyWith<$Res> {
  _$MediaListStateCopyWithImpl(this._self, this._then);

  final MediaListState _self;
  final $Res Function(MediaListState) _then;

/// Create a copy of MediaListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userAnimeLists = null,Object? userMangaLists = null,Object? loggedUser = null,Object? isLoading = null,Object? effects = null,}) {
  return _then(_self.copyWith(
userAnimeLists: null == userAnimeLists ? _self.userAnimeLists : userAnimeLists // ignore: cast_nullable_to_non_nullable
as Map<String, List<Anime>>,userMangaLists: null == userMangaLists ? _self.userMangaLists : userMangaLists // ignore: cast_nullable_to_non_nullable
as Map<String, List<Manga>>,loggedUser: null == loggedUser ? _self.loggedUser : loggedUser // ignore: cast_nullable_to_non_nullable
as User,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,effects: null == effects ? _self.effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaListState].
extension MediaListStatePatterns on MediaListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaListState value)  $default,){
final _that = this;
switch (_that) {
case _MediaListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaListState value)?  $default,){
final _that = this;
switch (_that) {
case _MediaListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, List<Anime>> userAnimeLists,  Map<String, List<Manga>> userMangaLists,  User loggedUser,  bool isLoading,  List<AppEffect> effects)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaListState() when $default != null:
return $default(_that.userAnimeLists,_that.userMangaLists,_that.loggedUser,_that.isLoading,_that.effects);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, List<Anime>> userAnimeLists,  Map<String, List<Manga>> userMangaLists,  User loggedUser,  bool isLoading,  List<AppEffect> effects)  $default,) {final _that = this;
switch (_that) {
case _MediaListState():
return $default(_that.userAnimeLists,_that.userMangaLists,_that.loggedUser,_that.isLoading,_that.effects);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, List<Anime>> userAnimeLists,  Map<String, List<Manga>> userMangaLists,  User loggedUser,  bool isLoading,  List<AppEffect> effects)?  $default,) {final _that = this;
switch (_that) {
case _MediaListState() when $default != null:
return $default(_that.userAnimeLists,_that.userMangaLists,_that.loggedUser,_that.isLoading,_that.effects);case _:
  return null;

}
}

}

/// @nodoc


class _MediaListState extends MediaListState {
  const _MediaListState({required final  Map<String, List<Anime>> userAnimeLists, required final  Map<String, List<Manga>> userMangaLists, required this.loggedUser, required this.isLoading, final  List<AppEffect> effects = const <AppEffect>[]}): _userAnimeLists = userAnimeLists,_userMangaLists = userMangaLists,_effects = effects,super._();
  

 final  Map<String, List<Anime>> _userAnimeLists;
@override Map<String, List<Anime>> get userAnimeLists {
  if (_userAnimeLists is EqualUnmodifiableMapView) return _userAnimeLists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_userAnimeLists);
}

 final  Map<String, List<Manga>> _userMangaLists;
@override Map<String, List<Manga>> get userMangaLists {
  if (_userMangaLists is EqualUnmodifiableMapView) return _userMangaLists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_userMangaLists);
}

@override final  User loggedUser;
@override final  bool isLoading;
 final  List<AppEffect> _effects;
@override@JsonKey() List<AppEffect> get effects {
  if (_effects is EqualUnmodifiableListView) return _effects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_effects);
}


/// Create a copy of MediaListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaListStateCopyWith<_MediaListState> get copyWith => __$MediaListStateCopyWithImpl<_MediaListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaListState&&const DeepCollectionEquality().equals(other._userAnimeLists, _userAnimeLists)&&const DeepCollectionEquality().equals(other._userMangaLists, _userMangaLists)&&(identical(other.loggedUser, loggedUser) || other.loggedUser == loggedUser)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._effects, _effects));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_userAnimeLists),const DeepCollectionEquality().hash(_userMangaLists),loggedUser,isLoading,const DeepCollectionEquality().hash(_effects));

@override
String toString() {
  return 'MediaListState(userAnimeLists: $userAnimeLists, userMangaLists: $userMangaLists, loggedUser: $loggedUser, isLoading: $isLoading, effects: $effects)';
}


}

/// @nodoc
abstract mixin class _$MediaListStateCopyWith<$Res> implements $MediaListStateCopyWith<$Res> {
  factory _$MediaListStateCopyWith(_MediaListState value, $Res Function(_MediaListState) _then) = __$MediaListStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, List<Anime>> userAnimeLists, Map<String, List<Manga>> userMangaLists, User loggedUser, bool isLoading, List<AppEffect> effects
});




}
/// @nodoc
class __$MediaListStateCopyWithImpl<$Res>
    implements _$MediaListStateCopyWith<$Res> {
  __$MediaListStateCopyWithImpl(this._self, this._then);

  final _MediaListState _self;
  final $Res Function(_MediaListState) _then;

/// Create a copy of MediaListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userAnimeLists = null,Object? userMangaLists = null,Object? loggedUser = null,Object? isLoading = null,Object? effects = null,}) {
  return _then(_MediaListState(
userAnimeLists: null == userAnimeLists ? _self._userAnimeLists : userAnimeLists // ignore: cast_nullable_to_non_nullable
as Map<String, List<Anime>>,userMangaLists: null == userMangaLists ? _self._userMangaLists : userMangaLists // ignore: cast_nullable_to_non_nullable
as Map<String, List<Manga>>,loggedUser: null == loggedUser ? _self.loggedUser : loggedUser // ignore: cast_nullable_to_non_nullable
as User,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,effects: null == effects ? _self._effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,
  ));
}


}

// dart format on

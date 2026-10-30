// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manga_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MangaState {

 (bool, List<Manga>) get trending; (bool, List<Manga>) get recentlyCompleted; (bool, List<Manga>) get popular; (bool, List<Manga>) get upcoming; List<Manga> get banners; User get loggedUser; bool get isLoading; bool get metadataServiceSupported; List<AppEffect> get effects; bool get userLoaded;
/// Create a copy of MangaState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MangaStateCopyWith<MangaState> get copyWith => _$MangaStateCopyWithImpl<MangaState>(this as MangaState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MangaState&&(identical(other.trending, trending) || other.trending == trending)&&(identical(other.recentlyCompleted, recentlyCompleted) || other.recentlyCompleted == recentlyCompleted)&&(identical(other.popular, popular) || other.popular == popular)&&(identical(other.upcoming, upcoming) || other.upcoming == upcoming)&&const DeepCollectionEquality().equals(other.banners, banners)&&(identical(other.loggedUser, loggedUser) || other.loggedUser == loggedUser)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.metadataServiceSupported, metadataServiceSupported) || other.metadataServiceSupported == metadataServiceSupported)&&const DeepCollectionEquality().equals(other.effects, effects)&&(identical(other.userLoaded, userLoaded) || other.userLoaded == userLoaded));
}


@override
int get hashCode => Object.hash(runtimeType,trending,recentlyCompleted,popular,upcoming,const DeepCollectionEquality().hash(banners),loggedUser,isLoading,metadataServiceSupported,const DeepCollectionEquality().hash(effects),userLoaded);

@override
String toString() {
  return 'MangaState(trending: $trending, recentlyCompleted: $recentlyCompleted, popular: $popular, upcoming: $upcoming, banners: $banners, loggedUser: $loggedUser, isLoading: $isLoading, metadataServiceSupported: $metadataServiceSupported, effects: $effects, userLoaded: $userLoaded)';
}


}

/// @nodoc
abstract mixin class $MangaStateCopyWith<$Res>  {
  factory $MangaStateCopyWith(MangaState value, $Res Function(MangaState) _then) = _$MangaStateCopyWithImpl;
@useResult
$Res call({
 (bool, List<Manga>) trending, (bool, List<Manga>) recentlyCompleted, (bool, List<Manga>) popular, (bool, List<Manga>) upcoming, List<Manga> banners, User loggedUser, bool isLoading, bool metadataServiceSupported, List<AppEffect> effects, bool userLoaded
});




}
/// @nodoc
class _$MangaStateCopyWithImpl<$Res>
    implements $MangaStateCopyWith<$Res> {
  _$MangaStateCopyWithImpl(this._self, this._then);

  final MangaState _self;
  final $Res Function(MangaState) _then;

/// Create a copy of MangaState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trending = null,Object? recentlyCompleted = null,Object? popular = null,Object? upcoming = null,Object? banners = null,Object? loggedUser = null,Object? isLoading = null,Object? metadataServiceSupported = null,Object? effects = null,Object? userLoaded = null,}) {
  return _then(_self.copyWith(
trending: null == trending ? _self.trending : trending // ignore: cast_nullable_to_non_nullable
as (bool, List<Manga>),recentlyCompleted: null == recentlyCompleted ? _self.recentlyCompleted : recentlyCompleted // ignore: cast_nullable_to_non_nullable
as (bool, List<Manga>),popular: null == popular ? _self.popular : popular // ignore: cast_nullable_to_non_nullable
as (bool, List<Manga>),upcoming: null == upcoming ? _self.upcoming : upcoming // ignore: cast_nullable_to_non_nullable
as (bool, List<Manga>),banners: null == banners ? _self.banners : banners // ignore: cast_nullable_to_non_nullable
as List<Manga>,loggedUser: null == loggedUser ? _self.loggedUser : loggedUser // ignore: cast_nullable_to_non_nullable
as User,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,metadataServiceSupported: null == metadataServiceSupported ? _self.metadataServiceSupported : metadataServiceSupported // ignore: cast_nullable_to_non_nullable
as bool,effects: null == effects ? _self.effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,userLoaded: null == userLoaded ? _self.userLoaded : userLoaded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MangaState].
extension MangaStatePatterns on MangaState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MangaState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MangaState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MangaState value)  $default,){
final _that = this;
switch (_that) {
case _MangaState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MangaState value)?  $default,){
final _that = this;
switch (_that) {
case _MangaState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( (bool, List<Manga>) trending,  (bool, List<Manga>) recentlyCompleted,  (bool, List<Manga>) popular,  (bool, List<Manga>) upcoming,  List<Manga> banners,  User loggedUser,  bool isLoading,  bool metadataServiceSupported,  List<AppEffect> effects,  bool userLoaded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MangaState() when $default != null:
return $default(_that.trending,_that.recentlyCompleted,_that.popular,_that.upcoming,_that.banners,_that.loggedUser,_that.isLoading,_that.metadataServiceSupported,_that.effects,_that.userLoaded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( (bool, List<Manga>) trending,  (bool, List<Manga>) recentlyCompleted,  (bool, List<Manga>) popular,  (bool, List<Manga>) upcoming,  List<Manga> banners,  User loggedUser,  bool isLoading,  bool metadataServiceSupported,  List<AppEffect> effects,  bool userLoaded)  $default,) {final _that = this;
switch (_that) {
case _MangaState():
return $default(_that.trending,_that.recentlyCompleted,_that.popular,_that.upcoming,_that.banners,_that.loggedUser,_that.isLoading,_that.metadataServiceSupported,_that.effects,_that.userLoaded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( (bool, List<Manga>) trending,  (bool, List<Manga>) recentlyCompleted,  (bool, List<Manga>) popular,  (bool, List<Manga>) upcoming,  List<Manga> banners,  User loggedUser,  bool isLoading,  bool metadataServiceSupported,  List<AppEffect> effects,  bool userLoaded)?  $default,) {final _that = this;
switch (_that) {
case _MangaState() when $default != null:
return $default(_that.trending,_that.recentlyCompleted,_that.popular,_that.upcoming,_that.banners,_that.loggedUser,_that.isLoading,_that.metadataServiceSupported,_that.effects,_that.userLoaded);case _:
  return null;

}
}

}

/// @nodoc


class _MangaState extends MangaState {
  const _MangaState({required this.trending, required this.recentlyCompleted, required this.popular, required this.upcoming, required final  List<Manga> banners, required this.loggedUser, required this.isLoading, this.metadataServiceSupported = true, final  List<AppEffect> effects = const <AppEffect>[], required this.userLoaded}): _banners = banners,_effects = effects,super._();
  

@override final  (bool, List<Manga>) trending;
@override final  (bool, List<Manga>) recentlyCompleted;
@override final  (bool, List<Manga>) popular;
@override final  (bool, List<Manga>) upcoming;
 final  List<Manga> _banners;
@override List<Manga> get banners {
  if (_banners is EqualUnmodifiableListView) return _banners;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_banners);
}

@override final  User loggedUser;
@override final  bool isLoading;
@override@JsonKey() final  bool metadataServiceSupported;
 final  List<AppEffect> _effects;
@override@JsonKey() List<AppEffect> get effects {
  if (_effects is EqualUnmodifiableListView) return _effects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_effects);
}

@override final  bool userLoaded;

/// Create a copy of MangaState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MangaStateCopyWith<_MangaState> get copyWith => __$MangaStateCopyWithImpl<_MangaState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MangaState&&(identical(other.trending, trending) || other.trending == trending)&&(identical(other.recentlyCompleted, recentlyCompleted) || other.recentlyCompleted == recentlyCompleted)&&(identical(other.popular, popular) || other.popular == popular)&&(identical(other.upcoming, upcoming) || other.upcoming == upcoming)&&const DeepCollectionEquality().equals(other._banners, _banners)&&(identical(other.loggedUser, loggedUser) || other.loggedUser == loggedUser)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.metadataServiceSupported, metadataServiceSupported) || other.metadataServiceSupported == metadataServiceSupported)&&const DeepCollectionEquality().equals(other._effects, _effects)&&(identical(other.userLoaded, userLoaded) || other.userLoaded == userLoaded));
}


@override
int get hashCode => Object.hash(runtimeType,trending,recentlyCompleted,popular,upcoming,const DeepCollectionEquality().hash(_banners),loggedUser,isLoading,metadataServiceSupported,const DeepCollectionEquality().hash(_effects),userLoaded);

@override
String toString() {
  return 'MangaState(trending: $trending, recentlyCompleted: $recentlyCompleted, popular: $popular, upcoming: $upcoming, banners: $banners, loggedUser: $loggedUser, isLoading: $isLoading, metadataServiceSupported: $metadataServiceSupported, effects: $effects, userLoaded: $userLoaded)';
}


}

/// @nodoc
abstract mixin class _$MangaStateCopyWith<$Res> implements $MangaStateCopyWith<$Res> {
  factory _$MangaStateCopyWith(_MangaState value, $Res Function(_MangaState) _then) = __$MangaStateCopyWithImpl;
@override @useResult
$Res call({
 (bool, List<Manga>) trending, (bool, List<Manga>) recentlyCompleted, (bool, List<Manga>) popular, (bool, List<Manga>) upcoming, List<Manga> banners, User loggedUser, bool isLoading, bool metadataServiceSupported, List<AppEffect> effects, bool userLoaded
});




}
/// @nodoc
class __$MangaStateCopyWithImpl<$Res>
    implements _$MangaStateCopyWith<$Res> {
  __$MangaStateCopyWithImpl(this._self, this._then);

  final _MangaState _self;
  final $Res Function(_MangaState) _then;

/// Create a copy of MangaState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trending = null,Object? recentlyCompleted = null,Object? popular = null,Object? upcoming = null,Object? banners = null,Object? loggedUser = null,Object? isLoading = null,Object? metadataServiceSupported = null,Object? effects = null,Object? userLoaded = null,}) {
  return _then(_MangaState(
trending: null == trending ? _self.trending : trending // ignore: cast_nullable_to_non_nullable
as (bool, List<Manga>),recentlyCompleted: null == recentlyCompleted ? _self.recentlyCompleted : recentlyCompleted // ignore: cast_nullable_to_non_nullable
as (bool, List<Manga>),popular: null == popular ? _self.popular : popular // ignore: cast_nullable_to_non_nullable
as (bool, List<Manga>),upcoming: null == upcoming ? _self.upcoming : upcoming // ignore: cast_nullable_to_non_nullable
as (bool, List<Manga>),banners: null == banners ? _self._banners : banners // ignore: cast_nullable_to_non_nullable
as List<Manga>,loggedUser: null == loggedUser ? _self.loggedUser : loggedUser // ignore: cast_nullable_to_non_nullable
as User,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,metadataServiceSupported: null == metadataServiceSupported ? _self.metadataServiceSupported : metadataServiceSupported // ignore: cast_nullable_to_non_nullable
as bool,effects: null == effects ? _self._effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,userLoaded: null == userLoaded ? _self.userLoaded : userLoaded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

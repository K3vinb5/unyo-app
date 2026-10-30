// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'title.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TitleModel {

 String get romaji; String get english; String get nativeTitle; String get userPreferred; String get russian;
/// Create a copy of TitleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TitleModelCopyWith<TitleModel> get copyWith => _$TitleModelCopyWithImpl<TitleModel>(this as TitleModel, _$identity);

  /// Serializes this TitleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TitleModel&&(identical(other.romaji, romaji) || other.romaji == romaji)&&(identical(other.english, english) || other.english == english)&&(identical(other.nativeTitle, nativeTitle) || other.nativeTitle == nativeTitle)&&(identical(other.userPreferred, userPreferred) || other.userPreferred == userPreferred)&&(identical(other.russian, russian) || other.russian == russian));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,romaji,english,nativeTitle,userPreferred,russian);



}

/// @nodoc
abstract mixin class $TitleModelCopyWith<$Res>  {
  factory $TitleModelCopyWith(TitleModel value, $Res Function(TitleModel) _then) = _$TitleModelCopyWithImpl;
@useResult
$Res call({
 String romaji, String english, String nativeTitle, String userPreferred, String russian
});




}
/// @nodoc
class _$TitleModelCopyWithImpl<$Res>
    implements $TitleModelCopyWith<$Res> {
  _$TitleModelCopyWithImpl(this._self, this._then);

  final TitleModel _self;
  final $Res Function(TitleModel) _then;

/// Create a copy of TitleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? romaji = null,Object? english = null,Object? nativeTitle = null,Object? userPreferred = null,Object? russian = null,}) {
  return _then(_self.copyWith(
romaji: null == romaji ? _self.romaji : romaji // ignore: cast_nullable_to_non_nullable
as String,english: null == english ? _self.english : english // ignore: cast_nullable_to_non_nullable
as String,nativeTitle: null == nativeTitle ? _self.nativeTitle : nativeTitle // ignore: cast_nullable_to_non_nullable
as String,userPreferred: null == userPreferred ? _self.userPreferred : userPreferred // ignore: cast_nullable_to_non_nullable
as String,russian: null == russian ? _self.russian : russian // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TitleModel].
extension TitleModelPatterns on TitleModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TitleModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TitleModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TitleModel value)  $default,){
final _that = this;
switch (_that) {
case _TitleModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TitleModel value)?  $default,){
final _that = this;
switch (_that) {
case _TitleModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String romaji,  String english,  String nativeTitle,  String userPreferred,  String russian)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TitleModel() when $default != null:
return $default(_that.romaji,_that.english,_that.nativeTitle,_that.userPreferred,_that.russian);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String romaji,  String english,  String nativeTitle,  String userPreferred,  String russian)  $default,) {final _that = this;
switch (_that) {
case _TitleModel():
return $default(_that.romaji,_that.english,_that.nativeTitle,_that.userPreferred,_that.russian);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String romaji,  String english,  String nativeTitle,  String userPreferred,  String russian)?  $default,) {final _that = this;
switch (_that) {
case _TitleModel() when $default != null:
return $default(_that.romaji,_that.english,_that.nativeTitle,_that.userPreferred,_that.russian);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TitleModel implements TitleModel {
  const _TitleModel({required this.romaji, required this.english, required this.nativeTitle, required this.userPreferred, this.russian = ''});
  factory _TitleModel.fromJson(Map<String, dynamic> json) => _$TitleModelFromJson(json);

@override final  String romaji;
@override final  String english;
@override final  String nativeTitle;
@override final  String userPreferred;
@override@JsonKey() final  String russian;

/// Create a copy of TitleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TitleModelCopyWith<_TitleModel> get copyWith => __$TitleModelCopyWithImpl<_TitleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TitleModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TitleModel&&(identical(other.romaji, romaji) || other.romaji == romaji)&&(identical(other.english, english) || other.english == english)&&(identical(other.nativeTitle, nativeTitle) || other.nativeTitle == nativeTitle)&&(identical(other.userPreferred, userPreferred) || other.userPreferred == userPreferred)&&(identical(other.russian, russian) || other.russian == russian));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,romaji,english,nativeTitle,userPreferred,russian);



}

/// @nodoc
abstract mixin class _$TitleModelCopyWith<$Res> implements $TitleModelCopyWith<$Res> {
  factory _$TitleModelCopyWith(_TitleModel value, $Res Function(_TitleModel) _then) = __$TitleModelCopyWithImpl;
@override @useResult
$Res call({
 String romaji, String english, String nativeTitle, String userPreferred, String russian
});




}
/// @nodoc
class __$TitleModelCopyWithImpl<$Res>
    implements _$TitleModelCopyWith<$Res> {
  __$TitleModelCopyWithImpl(this._self, this._then);

  final _TitleModel _self;
  final $Res Function(_TitleModel) _then;

/// Create a copy of TitleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? romaji = null,Object? english = null,Object? nativeTitle = null,Object? userPreferred = null,Object? russian = null,}) {
  return _then(_TitleModel(
romaji: null == romaji ? _self.romaji : romaji // ignore: cast_nullable_to_non_nullable
as String,english: null == english ? _self.english : english // ignore: cast_nullable_to_non_nullable
as String,nativeTitle: null == nativeTitle ? _self.nativeTitle : nativeTitle // ignore: cast_nullable_to_non_nullable
as String,userPreferred: null == userPreferred ? _self.userPreferred : userPreferred // ignore: cast_nullable_to_non_nullable
as String,russian: null == russian ? _self.russian : russian // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

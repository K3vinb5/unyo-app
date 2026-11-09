// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mal_manga_details_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MalMangaDetailsModel {

@MediaListEntryConverter() MediaListEntry get mediaListEntry;@MangaConverter() List<Manga> get recommendedMangas;@MediaCharacterConverter() List<MediaCharacter> get characters;
/// Create a copy of MalMangaDetailsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MalMangaDetailsModelCopyWith<MalMangaDetailsModel> get copyWith => _$MalMangaDetailsModelCopyWithImpl<MalMangaDetailsModel>(this as MalMangaDetailsModel, _$identity);

  /// Serializes this MalMangaDetailsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MalMangaDetailsModel&&(identical(other.mediaListEntry, mediaListEntry) || other.mediaListEntry == mediaListEntry)&&const DeepCollectionEquality().equals(other.recommendedMangas, recommendedMangas)&&const DeepCollectionEquality().equals(other.characters, characters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaListEntry,const DeepCollectionEquality().hash(recommendedMangas),const DeepCollectionEquality().hash(characters));

@override
String toString() {
  return 'MalMangaDetailsModel(mediaListEntry: $mediaListEntry, recommendedMangas: $recommendedMangas, characters: $characters)';
}


}

/// @nodoc
abstract mixin class $MalMangaDetailsModelCopyWith<$Res>  {
  factory $MalMangaDetailsModelCopyWith(MalMangaDetailsModel value, $Res Function(MalMangaDetailsModel) _then) = _$MalMangaDetailsModelCopyWithImpl;
@useResult
$Res call({
@MediaListEntryConverter() MediaListEntry mediaListEntry,@MangaConverter() List<Manga> recommendedMangas,@MediaCharacterConverter() List<MediaCharacter> characters
});




}
/// @nodoc
class _$MalMangaDetailsModelCopyWithImpl<$Res>
    implements $MalMangaDetailsModelCopyWith<$Res> {
  _$MalMangaDetailsModelCopyWithImpl(this._self, this._then);

  final MalMangaDetailsModel _self;
  final $Res Function(MalMangaDetailsModel) _then;

/// Create a copy of MalMangaDetailsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaListEntry = null,Object? recommendedMangas = null,Object? characters = null,}) {
  return _then(_self.copyWith(
mediaListEntry: null == mediaListEntry ? _self.mediaListEntry : mediaListEntry // ignore: cast_nullable_to_non_nullable
as MediaListEntry,recommendedMangas: null == recommendedMangas ? _self.recommendedMangas : recommendedMangas // ignore: cast_nullable_to_non_nullable
as List<Manga>,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as List<MediaCharacter>,
  ));
}

}


/// Adds pattern-matching-related methods to [MalMangaDetailsModel].
extension MalMangaDetailsModelPatterns on MalMangaDetailsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MalMangaDetailsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MalMangaDetailsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MalMangaDetailsModel value)  $default,){
final _that = this;
switch (_that) {
case _MalMangaDetailsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MalMangaDetailsModel value)?  $default,){
final _that = this;
switch (_that) {
case _MalMangaDetailsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@MediaListEntryConverter()  MediaListEntry mediaListEntry, @MangaConverter()  List<Manga> recommendedMangas, @MediaCharacterConverter()  List<MediaCharacter> characters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MalMangaDetailsModel() when $default != null:
return $default(_that.mediaListEntry,_that.recommendedMangas,_that.characters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@MediaListEntryConverter()  MediaListEntry mediaListEntry, @MangaConverter()  List<Manga> recommendedMangas, @MediaCharacterConverter()  List<MediaCharacter> characters)  $default,) {final _that = this;
switch (_that) {
case _MalMangaDetailsModel():
return $default(_that.mediaListEntry,_that.recommendedMangas,_that.characters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@MediaListEntryConverter()  MediaListEntry mediaListEntry, @MangaConverter()  List<Manga> recommendedMangas, @MediaCharacterConverter()  List<MediaCharacter> characters)?  $default,) {final _that = this;
switch (_that) {
case _MalMangaDetailsModel() when $default != null:
return $default(_that.mediaListEntry,_that.recommendedMangas,_that.characters);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MalMangaDetailsModel extends MalMangaDetailsModel {
  const _MalMangaDetailsModel({@MediaListEntryConverter() required this.mediaListEntry, @MangaConverter() required final  List<Manga> recommendedMangas, @MediaCharacterConverter() required final  List<MediaCharacter> characters}): _recommendedMangas = recommendedMangas,_characters = characters,super._();
  factory _MalMangaDetailsModel.fromJson(Map<String, dynamic> json) => _$MalMangaDetailsModelFromJson(json);

@override@MediaListEntryConverter() final  MediaListEntry mediaListEntry;
 final  List<Manga> _recommendedMangas;
@override@MangaConverter() List<Manga> get recommendedMangas {
  if (_recommendedMangas is EqualUnmodifiableListView) return _recommendedMangas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recommendedMangas);
}

 final  List<MediaCharacter> _characters;
@override@MediaCharacterConverter() List<MediaCharacter> get characters {
  if (_characters is EqualUnmodifiableListView) return _characters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_characters);
}


/// Create a copy of MalMangaDetailsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MalMangaDetailsModelCopyWith<_MalMangaDetailsModel> get copyWith => __$MalMangaDetailsModelCopyWithImpl<_MalMangaDetailsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MalMangaDetailsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MalMangaDetailsModel&&(identical(other.mediaListEntry, mediaListEntry) || other.mediaListEntry == mediaListEntry)&&const DeepCollectionEquality().equals(other._recommendedMangas, _recommendedMangas)&&const DeepCollectionEquality().equals(other._characters, _characters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaListEntry,const DeepCollectionEquality().hash(_recommendedMangas),const DeepCollectionEquality().hash(_characters));

@override
String toString() {
  return 'MalMangaDetailsModel(mediaListEntry: $mediaListEntry, recommendedMangas: $recommendedMangas, characters: $characters)';
}


}

/// @nodoc
abstract mixin class _$MalMangaDetailsModelCopyWith<$Res> implements $MalMangaDetailsModelCopyWith<$Res> {
  factory _$MalMangaDetailsModelCopyWith(_MalMangaDetailsModel value, $Res Function(_MalMangaDetailsModel) _then) = __$MalMangaDetailsModelCopyWithImpl;
@override @useResult
$Res call({
@MediaListEntryConverter() MediaListEntry mediaListEntry,@MangaConverter() List<Manga> recommendedMangas,@MediaCharacterConverter() List<MediaCharacter> characters
});




}
/// @nodoc
class __$MalMangaDetailsModelCopyWithImpl<$Res>
    implements _$MalMangaDetailsModelCopyWith<$Res> {
  __$MalMangaDetailsModelCopyWithImpl(this._self, this._then);

  final _MalMangaDetailsModel _self;
  final $Res Function(_MalMangaDetailsModel) _then;

/// Create a copy of MalMangaDetailsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaListEntry = null,Object? recommendedMangas = null,Object? characters = null,}) {
  return _then(_MalMangaDetailsModel(
mediaListEntry: null == mediaListEntry ? _self.mediaListEntry : mediaListEntry // ignore: cast_nullable_to_non_nullable
as MediaListEntry,recommendedMangas: null == recommendedMangas ? _self._recommendedMangas : recommendedMangas // ignore: cast_nullable_to_non_nullable
as List<Manga>,characters: null == characters ? _self._characters : characters // ignore: cast_nullable_to_non_nullable
as List<MediaCharacter>,
  ));
}


}

// dart format on

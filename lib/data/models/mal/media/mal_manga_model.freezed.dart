// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mal_manga_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MalMangaModel {

 int get id; int get idMal;@TitleConverter() Title get title; int get averageScore; String get bannerImage; int get chapters; String get countryOfOrigin; String get coverImage; String get description; String get endDate; String get startDate; List<String> get genres; String get format; bool get isAdult; int get popularity; int get meanScore; String get status; bool get isFavourite;
/// Create a copy of MalMangaModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MalMangaModelCopyWith<MalMangaModel> get copyWith => _$MalMangaModelCopyWithImpl<MalMangaModel>(this as MalMangaModel, _$identity);

  /// Serializes this MalMangaModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MalMangaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.idMal, idMal) || other.idMal == idMal)&&(identical(other.title, title) || other.title == title)&&(identical(other.averageScore, averageScore) || other.averageScore == averageScore)&&(identical(other.bannerImage, bannerImage) || other.bannerImage == bannerImage)&&(identical(other.chapters, chapters) || other.chapters == chapters)&&(identical(other.countryOfOrigin, countryOfOrigin) || other.countryOfOrigin == countryOfOrigin)&&(identical(other.coverImage, coverImage) || other.coverImage == coverImage)&&(identical(other.description, description) || other.description == description)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.format, format) || other.format == format)&&(identical(other.isAdult, isAdult) || other.isAdult == isAdult)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.meanScore, meanScore) || other.meanScore == meanScore)&&(identical(other.status, status) || other.status == status)&&(identical(other.isFavourite, isFavourite) || other.isFavourite == isFavourite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,idMal,title,averageScore,bannerImage,chapters,countryOfOrigin,coverImage,description,endDate,startDate,const DeepCollectionEquality().hash(genres),format,isAdult,popularity,meanScore,status,isFavourite);



}

/// @nodoc
abstract mixin class $MalMangaModelCopyWith<$Res>  {
  factory $MalMangaModelCopyWith(MalMangaModel value, $Res Function(MalMangaModel) _then) = _$MalMangaModelCopyWithImpl;
@useResult
$Res call({
 int id, int idMal,@TitleConverter() Title title, int averageScore, String bannerImage, int chapters, String countryOfOrigin, String coverImage, String description, String endDate, String startDate, List<String> genres, String format, bool isAdult, int popularity, int meanScore, String status, bool isFavourite
});




}
/// @nodoc
class _$MalMangaModelCopyWithImpl<$Res>
    implements $MalMangaModelCopyWith<$Res> {
  _$MalMangaModelCopyWithImpl(this._self, this._then);

  final MalMangaModel _self;
  final $Res Function(MalMangaModel) _then;

/// Create a copy of MalMangaModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? idMal = null,Object? title = null,Object? averageScore = null,Object? bannerImage = null,Object? chapters = null,Object? countryOfOrigin = null,Object? coverImage = null,Object? description = null,Object? endDate = null,Object? startDate = null,Object? genres = null,Object? format = null,Object? isAdult = null,Object? popularity = null,Object? meanScore = null,Object? status = null,Object? isFavourite = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,idMal: null == idMal ? _self.idMal : idMal // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Title,averageScore: null == averageScore ? _self.averageScore : averageScore // ignore: cast_nullable_to_non_nullable
as int,bannerImage: null == bannerImage ? _self.bannerImage : bannerImage // ignore: cast_nullable_to_non_nullable
as String,chapters: null == chapters ? _self.chapters : chapters // ignore: cast_nullable_to_non_nullable
as int,countryOfOrigin: null == countryOfOrigin ? _self.countryOfOrigin : countryOfOrigin // ignore: cast_nullable_to_non_nullable
as String,coverImage: null == coverImage ? _self.coverImage : coverImage // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,isAdult: null == isAdult ? _self.isAdult : isAdult // ignore: cast_nullable_to_non_nullable
as bool,popularity: null == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as int,meanScore: null == meanScore ? _self.meanScore : meanScore // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isFavourite: null == isFavourite ? _self.isFavourite : isFavourite // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MalMangaModel].
extension MalMangaModelPatterns on MalMangaModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MalMangaModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MalMangaModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MalMangaModel value)  $default,){
final _that = this;
switch (_that) {
case _MalMangaModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MalMangaModel value)?  $default,){
final _that = this;
switch (_that) {
case _MalMangaModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int idMal, @TitleConverter()  Title title,  int averageScore,  String bannerImage,  int chapters,  String countryOfOrigin,  String coverImage,  String description,  String endDate,  String startDate,  List<String> genres,  String format,  bool isAdult,  int popularity,  int meanScore,  String status,  bool isFavourite)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MalMangaModel() when $default != null:
return $default(_that.id,_that.idMal,_that.title,_that.averageScore,_that.bannerImage,_that.chapters,_that.countryOfOrigin,_that.coverImage,_that.description,_that.endDate,_that.startDate,_that.genres,_that.format,_that.isAdult,_that.popularity,_that.meanScore,_that.status,_that.isFavourite);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int idMal, @TitleConverter()  Title title,  int averageScore,  String bannerImage,  int chapters,  String countryOfOrigin,  String coverImage,  String description,  String endDate,  String startDate,  List<String> genres,  String format,  bool isAdult,  int popularity,  int meanScore,  String status,  bool isFavourite)  $default,) {final _that = this;
switch (_that) {
case _MalMangaModel():
return $default(_that.id,_that.idMal,_that.title,_that.averageScore,_that.bannerImage,_that.chapters,_that.countryOfOrigin,_that.coverImage,_that.description,_that.endDate,_that.startDate,_that.genres,_that.format,_that.isAdult,_that.popularity,_that.meanScore,_that.status,_that.isFavourite);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int idMal, @TitleConverter()  Title title,  int averageScore,  String bannerImage,  int chapters,  String countryOfOrigin,  String coverImage,  String description,  String endDate,  String startDate,  List<String> genres,  String format,  bool isAdult,  int popularity,  int meanScore,  String status,  bool isFavourite)?  $default,) {final _that = this;
switch (_that) {
case _MalMangaModel() when $default != null:
return $default(_that.id,_that.idMal,_that.title,_that.averageScore,_that.bannerImage,_that.chapters,_that.countryOfOrigin,_that.coverImage,_that.description,_that.endDate,_that.startDate,_that.genres,_that.format,_that.isAdult,_that.popularity,_that.meanScore,_that.status,_that.isFavourite);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MalMangaModel extends MalMangaModel {
   _MalMangaModel({required this.id, required this.idMal, @TitleConverter() required this.title, required this.averageScore, required this.bannerImage, required this.chapters, required this.countryOfOrigin, required this.coverImage, required this.description, required this.endDate, required this.startDate, required final  List<String> genres, required this.format, required this.isAdult, required this.popularity, required this.meanScore, required this.status, required this.isFavourite}): _genres = genres,super._();
  factory _MalMangaModel.fromJson(Map<String, dynamic> json) => _$MalMangaModelFromJson(json);

@override final  int id;
@override final  int idMal;
@override@TitleConverter() final  Title title;
@override final  int averageScore;
@override final  String bannerImage;
@override final  int chapters;
@override final  String countryOfOrigin;
@override final  String coverImage;
@override final  String description;
@override final  String endDate;
@override final  String startDate;
 final  List<String> _genres;
@override List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override final  String format;
@override final  bool isAdult;
@override final  int popularity;
@override final  int meanScore;
@override final  String status;
@override final  bool isFavourite;

/// Create a copy of MalMangaModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MalMangaModelCopyWith<_MalMangaModel> get copyWith => __$MalMangaModelCopyWithImpl<_MalMangaModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MalMangaModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MalMangaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.idMal, idMal) || other.idMal == idMal)&&(identical(other.title, title) || other.title == title)&&(identical(other.averageScore, averageScore) || other.averageScore == averageScore)&&(identical(other.bannerImage, bannerImage) || other.bannerImage == bannerImage)&&(identical(other.chapters, chapters) || other.chapters == chapters)&&(identical(other.countryOfOrigin, countryOfOrigin) || other.countryOfOrigin == countryOfOrigin)&&(identical(other.coverImage, coverImage) || other.coverImage == coverImage)&&(identical(other.description, description) || other.description == description)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.format, format) || other.format == format)&&(identical(other.isAdult, isAdult) || other.isAdult == isAdult)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.meanScore, meanScore) || other.meanScore == meanScore)&&(identical(other.status, status) || other.status == status)&&(identical(other.isFavourite, isFavourite) || other.isFavourite == isFavourite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,idMal,title,averageScore,bannerImage,chapters,countryOfOrigin,coverImage,description,endDate,startDate,const DeepCollectionEquality().hash(_genres),format,isAdult,popularity,meanScore,status,isFavourite);



}

/// @nodoc
abstract mixin class _$MalMangaModelCopyWith<$Res> implements $MalMangaModelCopyWith<$Res> {
  factory _$MalMangaModelCopyWith(_MalMangaModel value, $Res Function(_MalMangaModel) _then) = __$MalMangaModelCopyWithImpl;
@override @useResult
$Res call({
 int id, int idMal,@TitleConverter() Title title, int averageScore, String bannerImage, int chapters, String countryOfOrigin, String coverImage, String description, String endDate, String startDate, List<String> genres, String format, bool isAdult, int popularity, int meanScore, String status, bool isFavourite
});




}
/// @nodoc
class __$MalMangaModelCopyWithImpl<$Res>
    implements _$MalMangaModelCopyWith<$Res> {
  __$MalMangaModelCopyWithImpl(this._self, this._then);

  final _MalMangaModel _self;
  final $Res Function(_MalMangaModel) _then;

/// Create a copy of MalMangaModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? idMal = null,Object? title = null,Object? averageScore = null,Object? bannerImage = null,Object? chapters = null,Object? countryOfOrigin = null,Object? coverImage = null,Object? description = null,Object? endDate = null,Object? startDate = null,Object? genres = null,Object? format = null,Object? isAdult = null,Object? popularity = null,Object? meanScore = null,Object? status = null,Object? isFavourite = null,}) {
  return _then(_MalMangaModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,idMal: null == idMal ? _self.idMal : idMal // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Title,averageScore: null == averageScore ? _self.averageScore : averageScore // ignore: cast_nullable_to_non_nullable
as int,bannerImage: null == bannerImage ? _self.bannerImage : bannerImage // ignore: cast_nullable_to_non_nullable
as String,chapters: null == chapters ? _self.chapters : chapters // ignore: cast_nullable_to_non_nullable
as int,countryOfOrigin: null == countryOfOrigin ? _self.countryOfOrigin : countryOfOrigin // ignore: cast_nullable_to_non_nullable
as String,coverImage: null == coverImage ? _self.coverImage : coverImage // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,isAdult: null == isAdult ? _self.isAdult : isAdult // ignore: cast_nullable_to_non_nullable
as bool,popularity: null == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as int,meanScore: null == meanScore ? _self.meanScore : meanScore // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isFavourite: null == isFavourite ? _self.isFavourite : isFavourite // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

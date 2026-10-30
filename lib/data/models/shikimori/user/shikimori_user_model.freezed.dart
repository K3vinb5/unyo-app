// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shikimori_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShikimoriUserModel {

@HiveField(0) String get id;@HiveField(1) String get name;@SettingsConverter()@HiveField(2) Settings get settings;@HiveField(3) String get avatarImage;@HiveField(4) String get bannerImage;@HiveField(5) String get accessToken;@HiveField(6) String get refreshToken;@HiveField(7) String get accessTokenExpiresAt;@HiveField(8) String get profileUrl;
/// Create a copy of ShikimoriUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShikimoriUserModelCopyWith<ShikimoriUserModel> get copyWith => _$ShikimoriUserModelCopyWithImpl<ShikimoriUserModel>(this as ShikimoriUserModel, _$identity);

  /// Serializes this ShikimoriUserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShikimoriUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.avatarImage, avatarImage) || other.avatarImage == avatarImage)&&(identical(other.bannerImage, bannerImage) || other.bannerImage == bannerImage)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.accessTokenExpiresAt, accessTokenExpiresAt) || other.accessTokenExpiresAt == accessTokenExpiresAt)&&(identical(other.profileUrl, profileUrl) || other.profileUrl == profileUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,settings,avatarImage,bannerImage,accessToken,refreshToken,accessTokenExpiresAt,profileUrl);

@override
String toString() {
  return 'ShikimoriUserModel(id: $id, name: $name, settings: $settings, avatarImage: $avatarImage, bannerImage: $bannerImage, accessToken: $accessToken, refreshToken: $refreshToken, accessTokenExpiresAt: $accessTokenExpiresAt, profileUrl: $profileUrl)';
}


}

/// @nodoc
abstract mixin class $ShikimoriUserModelCopyWith<$Res>  {
  factory $ShikimoriUserModelCopyWith(ShikimoriUserModel value, $Res Function(ShikimoriUserModel) _then) = _$ShikimoriUserModelCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String name,@SettingsConverter()@HiveField(2) Settings settings,@HiveField(3) String avatarImage,@HiveField(4) String bannerImage,@HiveField(5) String accessToken,@HiveField(6) String refreshToken,@HiveField(7) String accessTokenExpiresAt,@HiveField(8) String profileUrl
});




}
/// @nodoc
class _$ShikimoriUserModelCopyWithImpl<$Res>
    implements $ShikimoriUserModelCopyWith<$Res> {
  _$ShikimoriUserModelCopyWithImpl(this._self, this._then);

  final ShikimoriUserModel _self;
  final $Res Function(ShikimoriUserModel) _then;

/// Create a copy of ShikimoriUserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? settings = null,Object? avatarImage = null,Object? bannerImage = null,Object? accessToken = null,Object? refreshToken = null,Object? accessTokenExpiresAt = null,Object? profileUrl = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Settings,avatarImage: null == avatarImage ? _self.avatarImage : avatarImage // ignore: cast_nullable_to_non_nullable
as String,bannerImage: null == bannerImage ? _self.bannerImage : bannerImage // ignore: cast_nullable_to_non_nullable
as String,accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,accessTokenExpiresAt: null == accessTokenExpiresAt ? _self.accessTokenExpiresAt : accessTokenExpiresAt // ignore: cast_nullable_to_non_nullable
as String,profileUrl: null == profileUrl ? _self.profileUrl : profileUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ShikimoriUserModel].
extension ShikimoriUserModelPatterns on ShikimoriUserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShikimoriUserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShikimoriUserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShikimoriUserModel value)  $default,){
final _that = this;
switch (_that) {
case _ShikimoriUserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShikimoriUserModel value)?  $default,){
final _that = this;
switch (_that) {
case _ShikimoriUserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String name, @SettingsConverter()@HiveField(2)  Settings settings, @HiveField(3)  String avatarImage, @HiveField(4)  String bannerImage, @HiveField(5)  String accessToken, @HiveField(6)  String refreshToken, @HiveField(7)  String accessTokenExpiresAt, @HiveField(8)  String profileUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShikimoriUserModel() when $default != null:
return $default(_that.id,_that.name,_that.settings,_that.avatarImage,_that.bannerImage,_that.accessToken,_that.refreshToken,_that.accessTokenExpiresAt,_that.profileUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String name, @SettingsConverter()@HiveField(2)  Settings settings, @HiveField(3)  String avatarImage, @HiveField(4)  String bannerImage, @HiveField(5)  String accessToken, @HiveField(6)  String refreshToken, @HiveField(7)  String accessTokenExpiresAt, @HiveField(8)  String profileUrl)  $default,) {final _that = this;
switch (_that) {
case _ShikimoriUserModel():
return $default(_that.id,_that.name,_that.settings,_that.avatarImage,_that.bannerImage,_that.accessToken,_that.refreshToken,_that.accessTokenExpiresAt,_that.profileUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String id, @HiveField(1)  String name, @SettingsConverter()@HiveField(2)  Settings settings, @HiveField(3)  String avatarImage, @HiveField(4)  String bannerImage, @HiveField(5)  String accessToken, @HiveField(6)  String refreshToken, @HiveField(7)  String accessTokenExpiresAt, @HiveField(8)  String profileUrl)?  $default,) {final _that = this;
switch (_that) {
case _ShikimoriUserModel() when $default != null:
return $default(_that.id,_that.name,_that.settings,_that.avatarImage,_that.bannerImage,_that.accessToken,_that.refreshToken,_that.accessTokenExpiresAt,_that.profileUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShikimoriUserModel extends ShikimoriUserModel {
  const _ShikimoriUserModel({@HiveField(0) required this.id, @HiveField(1) required this.name, @SettingsConverter()@HiveField(2) required this.settings, @HiveField(3) required this.avatarImage, @HiveField(4) required this.bannerImage, @HiveField(5) required this.accessToken, @HiveField(6) required this.refreshToken, @HiveField(7) required this.accessTokenExpiresAt, @HiveField(8) required this.profileUrl}): super._();
  factory _ShikimoriUserModel.fromJson(Map<String, dynamic> json) => _$ShikimoriUserModelFromJson(json);

@override@HiveField(0) final  String id;
@override@HiveField(1) final  String name;
@override@SettingsConverter()@HiveField(2) final  Settings settings;
@override@HiveField(3) final  String avatarImage;
@override@HiveField(4) final  String bannerImage;
@override@HiveField(5) final  String accessToken;
@override@HiveField(6) final  String refreshToken;
@override@HiveField(7) final  String accessTokenExpiresAt;
@override@HiveField(8) final  String profileUrl;

/// Create a copy of ShikimoriUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShikimoriUserModelCopyWith<_ShikimoriUserModel> get copyWith => __$ShikimoriUserModelCopyWithImpl<_ShikimoriUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShikimoriUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShikimoriUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.avatarImage, avatarImage) || other.avatarImage == avatarImage)&&(identical(other.bannerImage, bannerImage) || other.bannerImage == bannerImage)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.accessTokenExpiresAt, accessTokenExpiresAt) || other.accessTokenExpiresAt == accessTokenExpiresAt)&&(identical(other.profileUrl, profileUrl) || other.profileUrl == profileUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,settings,avatarImage,bannerImage,accessToken,refreshToken,accessTokenExpiresAt,profileUrl);

@override
String toString() {
  return 'ShikimoriUserModel(id: $id, name: $name, settings: $settings, avatarImage: $avatarImage, bannerImage: $bannerImage, accessToken: $accessToken, refreshToken: $refreshToken, accessTokenExpiresAt: $accessTokenExpiresAt, profileUrl: $profileUrl)';
}


}

/// @nodoc
abstract mixin class _$ShikimoriUserModelCopyWith<$Res> implements $ShikimoriUserModelCopyWith<$Res> {
  factory _$ShikimoriUserModelCopyWith(_ShikimoriUserModel value, $Res Function(_ShikimoriUserModel) _then) = __$ShikimoriUserModelCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String name,@SettingsConverter()@HiveField(2) Settings settings,@HiveField(3) String avatarImage,@HiveField(4) String bannerImage,@HiveField(5) String accessToken,@HiveField(6) String refreshToken,@HiveField(7) String accessTokenExpiresAt,@HiveField(8) String profileUrl
});




}
/// @nodoc
class __$ShikimoriUserModelCopyWithImpl<$Res>
    implements _$ShikimoriUserModelCopyWith<$Res> {
  __$ShikimoriUserModelCopyWithImpl(this._self, this._then);

  final _ShikimoriUserModel _self;
  final $Res Function(_ShikimoriUserModel) _then;

/// Create a copy of ShikimoriUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? settings = null,Object? avatarImage = null,Object? bannerImage = null,Object? accessToken = null,Object? refreshToken = null,Object? accessTokenExpiresAt = null,Object? profileUrl = null,}) {
  return _then(_ShikimoriUserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Settings,avatarImage: null == avatarImage ? _self.avatarImage : avatarImage // ignore: cast_nullable_to_non_nullable
as String,bannerImage: null == bannerImage ? _self.bannerImage : bannerImage // ignore: cast_nullable_to_non_nullable
as String,accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,accessTokenExpiresAt: null == accessTokenExpiresAt ? _self.accessTokenExpiresAt : accessTokenExpiresAt // ignore: cast_nullable_to_non_nullable
as String,profileUrl: null == profileUrl ? _self.profileUrl : profileUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

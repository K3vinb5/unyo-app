// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SettingsModel {

@HiveField(0) String get language;/// Deprecated legacy knob (pre user/metadata split). Read only by the
/// [SettingsModel.fromJson] migration below.
@HiveField(1) Service get service;@HiveField(2) EpisodeService get episodeService;@HiveField(3)@ExtensionConverter() List<Extension> get installedAnimeExtensions;@HiveField(4)@ExtensionConverter() List<Extension> get installedMangaExtensions;@HiveField(7)@ExtensionConverter() Map<String, Extension> get mediaExtensionConfigs;@HiveField(8) String get mediaTitleLanguage;@HiveField(9) String get episodeTitleLanguage;@HiveField(10) bool get enableDiscordRichPresence;@HiveField(11) bool get automaticallySkipOpening;@HiveField(12) bool get automaticallySkipEnding;@HiveField(13) int get manualSkipTime;@HiveField(14) bool get autoPlayNextEpisode;@HiveField(15) bool get enableOpenSubtitlesIntegration;@HiveField(16) bool get enableNsfwContent;@HiveField(17)@ColorConverter() Color get themeColor;@HiveField(18) bool get useWallpaperAsThemeColor;@HiveField(19) List<String> get aniyomiExtensionsRepositories;@HiveField(20) List<String> get tachiyomiExtensionsRepositories;@HiveField(21) Service get userService;@HiveField(22) Service get metadataService;
/// Create a copy of SettingsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsModelCopyWith<SettingsModel> get copyWith => _$SettingsModelCopyWithImpl<SettingsModel>(this as SettingsModel, _$identity);

  /// Serializes this SettingsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsModel&&(identical(other.language, language) || other.language == language)&&(identical(other.service, service) || other.service == service)&&(identical(other.episodeService, episodeService) || other.episodeService == episodeService)&&const DeepCollectionEquality().equals(other.installedAnimeExtensions, installedAnimeExtensions)&&const DeepCollectionEquality().equals(other.installedMangaExtensions, installedMangaExtensions)&&const DeepCollectionEquality().equals(other.mediaExtensionConfigs, mediaExtensionConfigs)&&(identical(other.mediaTitleLanguage, mediaTitleLanguage) || other.mediaTitleLanguage == mediaTitleLanguage)&&(identical(other.episodeTitleLanguage, episodeTitleLanguage) || other.episodeTitleLanguage == episodeTitleLanguage)&&(identical(other.enableDiscordRichPresence, enableDiscordRichPresence) || other.enableDiscordRichPresence == enableDiscordRichPresence)&&(identical(other.automaticallySkipOpening, automaticallySkipOpening) || other.automaticallySkipOpening == automaticallySkipOpening)&&(identical(other.automaticallySkipEnding, automaticallySkipEnding) || other.automaticallySkipEnding == automaticallySkipEnding)&&(identical(other.manualSkipTime, manualSkipTime) || other.manualSkipTime == manualSkipTime)&&(identical(other.autoPlayNextEpisode, autoPlayNextEpisode) || other.autoPlayNextEpisode == autoPlayNextEpisode)&&(identical(other.enableOpenSubtitlesIntegration, enableOpenSubtitlesIntegration) || other.enableOpenSubtitlesIntegration == enableOpenSubtitlesIntegration)&&(identical(other.enableNsfwContent, enableNsfwContent) || other.enableNsfwContent == enableNsfwContent)&&(identical(other.themeColor, themeColor) || other.themeColor == themeColor)&&(identical(other.useWallpaperAsThemeColor, useWallpaperAsThemeColor) || other.useWallpaperAsThemeColor == useWallpaperAsThemeColor)&&const DeepCollectionEquality().equals(other.aniyomiExtensionsRepositories, aniyomiExtensionsRepositories)&&const DeepCollectionEquality().equals(other.tachiyomiExtensionsRepositories, tachiyomiExtensionsRepositories)&&(identical(other.userService, userService) || other.userService == userService)&&(identical(other.metadataService, metadataService) || other.metadataService == metadataService));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,language,service,episodeService,const DeepCollectionEquality().hash(installedAnimeExtensions),const DeepCollectionEquality().hash(installedMangaExtensions),const DeepCollectionEquality().hash(mediaExtensionConfigs),mediaTitleLanguage,episodeTitleLanguage,enableDiscordRichPresence,automaticallySkipOpening,automaticallySkipEnding,manualSkipTime,autoPlayNextEpisode,enableOpenSubtitlesIntegration,enableNsfwContent,themeColor,useWallpaperAsThemeColor,const DeepCollectionEquality().hash(aniyomiExtensionsRepositories),const DeepCollectionEquality().hash(tachiyomiExtensionsRepositories),userService,metadataService]);

@override
String toString() {
  return 'SettingsModel(language: $language, service: $service, episodeService: $episodeService, installedAnimeExtensions: $installedAnimeExtensions, installedMangaExtensions: $installedMangaExtensions, mediaExtensionConfigs: $mediaExtensionConfigs, mediaTitleLanguage: $mediaTitleLanguage, episodeTitleLanguage: $episodeTitleLanguage, enableDiscordRichPresence: $enableDiscordRichPresence, automaticallySkipOpening: $automaticallySkipOpening, automaticallySkipEnding: $automaticallySkipEnding, manualSkipTime: $manualSkipTime, autoPlayNextEpisode: $autoPlayNextEpisode, enableOpenSubtitlesIntegration: $enableOpenSubtitlesIntegration, enableNsfwContent: $enableNsfwContent, themeColor: $themeColor, useWallpaperAsThemeColor: $useWallpaperAsThemeColor, aniyomiExtensionsRepositories: $aniyomiExtensionsRepositories, tachiyomiExtensionsRepositories: $tachiyomiExtensionsRepositories, userService: $userService, metadataService: $metadataService)';
}


}

/// @nodoc
abstract mixin class $SettingsModelCopyWith<$Res>  {
  factory $SettingsModelCopyWith(SettingsModel value, $Res Function(SettingsModel) _then) = _$SettingsModelCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String language,@HiveField(1) Service service,@HiveField(2) EpisodeService episodeService,@HiveField(3)@ExtensionConverter() List<Extension> installedAnimeExtensions,@HiveField(4)@ExtensionConverter() List<Extension> installedMangaExtensions,@HiveField(7)@ExtensionConverter() Map<String, Extension> mediaExtensionConfigs,@HiveField(8) String mediaTitleLanguage,@HiveField(9) String episodeTitleLanguage,@HiveField(10) bool enableDiscordRichPresence,@HiveField(11) bool automaticallySkipOpening,@HiveField(12) bool automaticallySkipEnding,@HiveField(13) int manualSkipTime,@HiveField(14) bool autoPlayNextEpisode,@HiveField(15) bool enableOpenSubtitlesIntegration,@HiveField(16) bool enableNsfwContent,@HiveField(17)@ColorConverter() Color themeColor,@HiveField(18) bool useWallpaperAsThemeColor,@HiveField(19) List<String> aniyomiExtensionsRepositories,@HiveField(20) List<String> tachiyomiExtensionsRepositories,@HiveField(21) Service userService,@HiveField(22) Service metadataService
});




}
/// @nodoc
class _$SettingsModelCopyWithImpl<$Res>
    implements $SettingsModelCopyWith<$Res> {
  _$SettingsModelCopyWithImpl(this._self, this._then);

  final SettingsModel _self;
  final $Res Function(SettingsModel) _then;

/// Create a copy of SettingsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? language = null,Object? service = null,Object? episodeService = null,Object? installedAnimeExtensions = null,Object? installedMangaExtensions = null,Object? mediaExtensionConfigs = null,Object? mediaTitleLanguage = null,Object? episodeTitleLanguage = null,Object? enableDiscordRichPresence = null,Object? automaticallySkipOpening = null,Object? automaticallySkipEnding = null,Object? manualSkipTime = null,Object? autoPlayNextEpisode = null,Object? enableOpenSubtitlesIntegration = null,Object? enableNsfwContent = null,Object? themeColor = null,Object? useWallpaperAsThemeColor = null,Object? aniyomiExtensionsRepositories = null,Object? tachiyomiExtensionsRepositories = null,Object? userService = null,Object? metadataService = null,}) {
  return _then(_self.copyWith(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as Service,episodeService: null == episodeService ? _self.episodeService : episodeService // ignore: cast_nullable_to_non_nullable
as EpisodeService,installedAnimeExtensions: null == installedAnimeExtensions ? _self.installedAnimeExtensions : installedAnimeExtensions // ignore: cast_nullable_to_non_nullable
as List<Extension>,installedMangaExtensions: null == installedMangaExtensions ? _self.installedMangaExtensions : installedMangaExtensions // ignore: cast_nullable_to_non_nullable
as List<Extension>,mediaExtensionConfigs: null == mediaExtensionConfigs ? _self.mediaExtensionConfigs : mediaExtensionConfigs // ignore: cast_nullable_to_non_nullable
as Map<String, Extension>,mediaTitleLanguage: null == mediaTitleLanguage ? _self.mediaTitleLanguage : mediaTitleLanguage // ignore: cast_nullable_to_non_nullable
as String,episodeTitleLanguage: null == episodeTitleLanguage ? _self.episodeTitleLanguage : episodeTitleLanguage // ignore: cast_nullable_to_non_nullable
as String,enableDiscordRichPresence: null == enableDiscordRichPresence ? _self.enableDiscordRichPresence : enableDiscordRichPresence // ignore: cast_nullable_to_non_nullable
as bool,automaticallySkipOpening: null == automaticallySkipOpening ? _self.automaticallySkipOpening : automaticallySkipOpening // ignore: cast_nullable_to_non_nullable
as bool,automaticallySkipEnding: null == automaticallySkipEnding ? _self.automaticallySkipEnding : automaticallySkipEnding // ignore: cast_nullable_to_non_nullable
as bool,manualSkipTime: null == manualSkipTime ? _self.manualSkipTime : manualSkipTime // ignore: cast_nullable_to_non_nullable
as int,autoPlayNextEpisode: null == autoPlayNextEpisode ? _self.autoPlayNextEpisode : autoPlayNextEpisode // ignore: cast_nullable_to_non_nullable
as bool,enableOpenSubtitlesIntegration: null == enableOpenSubtitlesIntegration ? _self.enableOpenSubtitlesIntegration : enableOpenSubtitlesIntegration // ignore: cast_nullable_to_non_nullable
as bool,enableNsfwContent: null == enableNsfwContent ? _self.enableNsfwContent : enableNsfwContent // ignore: cast_nullable_to_non_nullable
as bool,themeColor: null == themeColor ? _self.themeColor : themeColor // ignore: cast_nullable_to_non_nullable
as Color,useWallpaperAsThemeColor: null == useWallpaperAsThemeColor ? _self.useWallpaperAsThemeColor : useWallpaperAsThemeColor // ignore: cast_nullable_to_non_nullable
as bool,aniyomiExtensionsRepositories: null == aniyomiExtensionsRepositories ? _self.aniyomiExtensionsRepositories : aniyomiExtensionsRepositories // ignore: cast_nullable_to_non_nullable
as List<String>,tachiyomiExtensionsRepositories: null == tachiyomiExtensionsRepositories ? _self.tachiyomiExtensionsRepositories : tachiyomiExtensionsRepositories // ignore: cast_nullable_to_non_nullable
as List<String>,userService: null == userService ? _self.userService : userService // ignore: cast_nullable_to_non_nullable
as Service,metadataService: null == metadataService ? _self.metadataService : metadataService // ignore: cast_nullable_to_non_nullable
as Service,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsModel].
extension SettingsModelPatterns on SettingsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsModel value)  $default,){
final _that = this;
switch (_that) {
case _SettingsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsModel value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String language, @HiveField(1)  Service service, @HiveField(2)  EpisodeService episodeService, @HiveField(3)@ExtensionConverter()  List<Extension> installedAnimeExtensions, @HiveField(4)@ExtensionConverter()  List<Extension> installedMangaExtensions, @HiveField(7)@ExtensionConverter()  Map<String, Extension> mediaExtensionConfigs, @HiveField(8)  String mediaTitleLanguage, @HiveField(9)  String episodeTitleLanguage, @HiveField(10)  bool enableDiscordRichPresence, @HiveField(11)  bool automaticallySkipOpening, @HiveField(12)  bool automaticallySkipEnding, @HiveField(13)  int manualSkipTime, @HiveField(14)  bool autoPlayNextEpisode, @HiveField(15)  bool enableOpenSubtitlesIntegration, @HiveField(16)  bool enableNsfwContent, @HiveField(17)@ColorConverter()  Color themeColor, @HiveField(18)  bool useWallpaperAsThemeColor, @HiveField(19)  List<String> aniyomiExtensionsRepositories, @HiveField(20)  List<String> tachiyomiExtensionsRepositories, @HiveField(21)  Service userService, @HiveField(22)  Service metadataService)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsModel() when $default != null:
return $default(_that.language,_that.service,_that.episodeService,_that.installedAnimeExtensions,_that.installedMangaExtensions,_that.mediaExtensionConfigs,_that.mediaTitleLanguage,_that.episodeTitleLanguage,_that.enableDiscordRichPresence,_that.automaticallySkipOpening,_that.automaticallySkipEnding,_that.manualSkipTime,_that.autoPlayNextEpisode,_that.enableOpenSubtitlesIntegration,_that.enableNsfwContent,_that.themeColor,_that.useWallpaperAsThemeColor,_that.aniyomiExtensionsRepositories,_that.tachiyomiExtensionsRepositories,_that.userService,_that.metadataService);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String language, @HiveField(1)  Service service, @HiveField(2)  EpisodeService episodeService, @HiveField(3)@ExtensionConverter()  List<Extension> installedAnimeExtensions, @HiveField(4)@ExtensionConverter()  List<Extension> installedMangaExtensions, @HiveField(7)@ExtensionConverter()  Map<String, Extension> mediaExtensionConfigs, @HiveField(8)  String mediaTitleLanguage, @HiveField(9)  String episodeTitleLanguage, @HiveField(10)  bool enableDiscordRichPresence, @HiveField(11)  bool automaticallySkipOpening, @HiveField(12)  bool automaticallySkipEnding, @HiveField(13)  int manualSkipTime, @HiveField(14)  bool autoPlayNextEpisode, @HiveField(15)  bool enableOpenSubtitlesIntegration, @HiveField(16)  bool enableNsfwContent, @HiveField(17)@ColorConverter()  Color themeColor, @HiveField(18)  bool useWallpaperAsThemeColor, @HiveField(19)  List<String> aniyomiExtensionsRepositories, @HiveField(20)  List<String> tachiyomiExtensionsRepositories, @HiveField(21)  Service userService, @HiveField(22)  Service metadataService)  $default,) {final _that = this;
switch (_that) {
case _SettingsModel():
return $default(_that.language,_that.service,_that.episodeService,_that.installedAnimeExtensions,_that.installedMangaExtensions,_that.mediaExtensionConfigs,_that.mediaTitleLanguage,_that.episodeTitleLanguage,_that.enableDiscordRichPresence,_that.automaticallySkipOpening,_that.automaticallySkipEnding,_that.manualSkipTime,_that.autoPlayNextEpisode,_that.enableOpenSubtitlesIntegration,_that.enableNsfwContent,_that.themeColor,_that.useWallpaperAsThemeColor,_that.aniyomiExtensionsRepositories,_that.tachiyomiExtensionsRepositories,_that.userService,_that.metadataService);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String language, @HiveField(1)  Service service, @HiveField(2)  EpisodeService episodeService, @HiveField(3)@ExtensionConverter()  List<Extension> installedAnimeExtensions, @HiveField(4)@ExtensionConverter()  List<Extension> installedMangaExtensions, @HiveField(7)@ExtensionConverter()  Map<String, Extension> mediaExtensionConfigs, @HiveField(8)  String mediaTitleLanguage, @HiveField(9)  String episodeTitleLanguage, @HiveField(10)  bool enableDiscordRichPresence, @HiveField(11)  bool automaticallySkipOpening, @HiveField(12)  bool automaticallySkipEnding, @HiveField(13)  int manualSkipTime, @HiveField(14)  bool autoPlayNextEpisode, @HiveField(15)  bool enableOpenSubtitlesIntegration, @HiveField(16)  bool enableNsfwContent, @HiveField(17)@ColorConverter()  Color themeColor, @HiveField(18)  bool useWallpaperAsThemeColor, @HiveField(19)  List<String> aniyomiExtensionsRepositories, @HiveField(20)  List<String> tachiyomiExtensionsRepositories, @HiveField(21)  Service userService, @HiveField(22)  Service metadataService)?  $default,) {final _that = this;
switch (_that) {
case _SettingsModel() when $default != null:
return $default(_that.language,_that.service,_that.episodeService,_that.installedAnimeExtensions,_that.installedMangaExtensions,_that.mediaExtensionConfigs,_that.mediaTitleLanguage,_that.episodeTitleLanguage,_that.enableDiscordRichPresence,_that.automaticallySkipOpening,_that.automaticallySkipEnding,_that.manualSkipTime,_that.autoPlayNextEpisode,_that.enableOpenSubtitlesIntegration,_that.enableNsfwContent,_that.themeColor,_that.useWallpaperAsThemeColor,_that.aniyomiExtensionsRepositories,_that.tachiyomiExtensionsRepositories,_that.userService,_that.metadataService);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SettingsModel implements SettingsModel {
  const _SettingsModel({@HiveField(0) this.language = 'en', @HiveField(1) this.service = Service.anilist, @HiveField(2) this.episodeService = EpisodeService.anizip, @HiveField(3)@ExtensionConverter() final  List<Extension> installedAnimeExtensions = const [], @HiveField(4)@ExtensionConverter() final  List<Extension> installedMangaExtensions = const [], @HiveField(7)@ExtensionConverter() final  Map<String, Extension> mediaExtensionConfigs = const {}, @HiveField(8) this.mediaTitleLanguage = 'userPreferred', @HiveField(9) this.episodeTitleLanguage = 'en', @HiveField(10) this.enableDiscordRichPresence = true, @HiveField(11) this.automaticallySkipOpening = false, @HiveField(12) this.automaticallySkipEnding = false, @HiveField(13) this.manualSkipTime = 85, @HiveField(14) this.autoPlayNextEpisode = false, @HiveField(15) this.enableOpenSubtitlesIntegration = false, @HiveField(16) this.enableNsfwContent = false, @HiveField(17)@ColorConverter() this.themeColor = const Color(0xFF2196F3), @HiveField(18) this.useWallpaperAsThemeColor = true, @HiveField(19) final  List<String> aniyomiExtensionsRepositories = const [config.aniyomiExtensionsDefaultRepositoryUrl], @HiveField(20) final  List<String> tachiyomiExtensionsRepositories = const [config.tachiyomiExtensionsDefaultRepositoryUrl], @HiveField(21) this.userService = Service.anilist, @HiveField(22) this.metadataService = Service.anilist}): _installedAnimeExtensions = installedAnimeExtensions,_installedMangaExtensions = installedMangaExtensions,_mediaExtensionConfigs = mediaExtensionConfigs,_aniyomiExtensionsRepositories = aniyomiExtensionsRepositories,_tachiyomiExtensionsRepositories = tachiyomiExtensionsRepositories;
  factory _SettingsModel.fromJson(Map<String, dynamic> json) => _$SettingsModelFromJson(json);

@override@JsonKey()@HiveField(0) final  String language;
/// Deprecated legacy knob (pre user/metadata split). Read only by the
/// [SettingsModel.fromJson] migration below.
@override@JsonKey()@HiveField(1) final  Service service;
@override@JsonKey()@HiveField(2) final  EpisodeService episodeService;
 final  List<Extension> _installedAnimeExtensions;
@override@JsonKey()@HiveField(3)@ExtensionConverter() List<Extension> get installedAnimeExtensions {
  if (_installedAnimeExtensions is EqualUnmodifiableListView) return _installedAnimeExtensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_installedAnimeExtensions);
}

 final  List<Extension> _installedMangaExtensions;
@override@JsonKey()@HiveField(4)@ExtensionConverter() List<Extension> get installedMangaExtensions {
  if (_installedMangaExtensions is EqualUnmodifiableListView) return _installedMangaExtensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_installedMangaExtensions);
}

 final  Map<String, Extension> _mediaExtensionConfigs;
@override@JsonKey()@HiveField(7)@ExtensionConverter() Map<String, Extension> get mediaExtensionConfigs {
  if (_mediaExtensionConfigs is EqualUnmodifiableMapView) return _mediaExtensionConfigs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_mediaExtensionConfigs);
}

@override@JsonKey()@HiveField(8) final  String mediaTitleLanguage;
@override@JsonKey()@HiveField(9) final  String episodeTitleLanguage;
@override@JsonKey()@HiveField(10) final  bool enableDiscordRichPresence;
@override@JsonKey()@HiveField(11) final  bool automaticallySkipOpening;
@override@JsonKey()@HiveField(12) final  bool automaticallySkipEnding;
@override@JsonKey()@HiveField(13) final  int manualSkipTime;
@override@JsonKey()@HiveField(14) final  bool autoPlayNextEpisode;
@override@JsonKey()@HiveField(15) final  bool enableOpenSubtitlesIntegration;
@override@JsonKey()@HiveField(16) final  bool enableNsfwContent;
@override@JsonKey()@HiveField(17)@ColorConverter() final  Color themeColor;
@override@JsonKey()@HiveField(18) final  bool useWallpaperAsThemeColor;
 final  List<String> _aniyomiExtensionsRepositories;
@override@JsonKey()@HiveField(19) List<String> get aniyomiExtensionsRepositories {
  if (_aniyomiExtensionsRepositories is EqualUnmodifiableListView) return _aniyomiExtensionsRepositories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aniyomiExtensionsRepositories);
}

 final  List<String> _tachiyomiExtensionsRepositories;
@override@JsonKey()@HiveField(20) List<String> get tachiyomiExtensionsRepositories {
  if (_tachiyomiExtensionsRepositories is EqualUnmodifiableListView) return _tachiyomiExtensionsRepositories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tachiyomiExtensionsRepositories);
}

@override@JsonKey()@HiveField(21) final  Service userService;
@override@JsonKey()@HiveField(22) final  Service metadataService;

/// Create a copy of SettingsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsModelCopyWith<_SettingsModel> get copyWith => __$SettingsModelCopyWithImpl<_SettingsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SettingsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsModel&&(identical(other.language, language) || other.language == language)&&(identical(other.service, service) || other.service == service)&&(identical(other.episodeService, episodeService) || other.episodeService == episodeService)&&const DeepCollectionEquality().equals(other._installedAnimeExtensions, _installedAnimeExtensions)&&const DeepCollectionEquality().equals(other._installedMangaExtensions, _installedMangaExtensions)&&const DeepCollectionEquality().equals(other._mediaExtensionConfigs, _mediaExtensionConfigs)&&(identical(other.mediaTitleLanguage, mediaTitleLanguage) || other.mediaTitleLanguage == mediaTitleLanguage)&&(identical(other.episodeTitleLanguage, episodeTitleLanguage) || other.episodeTitleLanguage == episodeTitleLanguage)&&(identical(other.enableDiscordRichPresence, enableDiscordRichPresence) || other.enableDiscordRichPresence == enableDiscordRichPresence)&&(identical(other.automaticallySkipOpening, automaticallySkipOpening) || other.automaticallySkipOpening == automaticallySkipOpening)&&(identical(other.automaticallySkipEnding, automaticallySkipEnding) || other.automaticallySkipEnding == automaticallySkipEnding)&&(identical(other.manualSkipTime, manualSkipTime) || other.manualSkipTime == manualSkipTime)&&(identical(other.autoPlayNextEpisode, autoPlayNextEpisode) || other.autoPlayNextEpisode == autoPlayNextEpisode)&&(identical(other.enableOpenSubtitlesIntegration, enableOpenSubtitlesIntegration) || other.enableOpenSubtitlesIntegration == enableOpenSubtitlesIntegration)&&(identical(other.enableNsfwContent, enableNsfwContent) || other.enableNsfwContent == enableNsfwContent)&&(identical(other.themeColor, themeColor) || other.themeColor == themeColor)&&(identical(other.useWallpaperAsThemeColor, useWallpaperAsThemeColor) || other.useWallpaperAsThemeColor == useWallpaperAsThemeColor)&&const DeepCollectionEquality().equals(other._aniyomiExtensionsRepositories, _aniyomiExtensionsRepositories)&&const DeepCollectionEquality().equals(other._tachiyomiExtensionsRepositories, _tachiyomiExtensionsRepositories)&&(identical(other.userService, userService) || other.userService == userService)&&(identical(other.metadataService, metadataService) || other.metadataService == metadataService));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,language,service,episodeService,const DeepCollectionEquality().hash(_installedAnimeExtensions),const DeepCollectionEquality().hash(_installedMangaExtensions),const DeepCollectionEquality().hash(_mediaExtensionConfigs),mediaTitleLanguage,episodeTitleLanguage,enableDiscordRichPresence,automaticallySkipOpening,automaticallySkipEnding,manualSkipTime,autoPlayNextEpisode,enableOpenSubtitlesIntegration,enableNsfwContent,themeColor,useWallpaperAsThemeColor,const DeepCollectionEquality().hash(_aniyomiExtensionsRepositories),const DeepCollectionEquality().hash(_tachiyomiExtensionsRepositories),userService,metadataService]);

@override
String toString() {
  return 'SettingsModel(language: $language, service: $service, episodeService: $episodeService, installedAnimeExtensions: $installedAnimeExtensions, installedMangaExtensions: $installedMangaExtensions, mediaExtensionConfigs: $mediaExtensionConfigs, mediaTitleLanguage: $mediaTitleLanguage, episodeTitleLanguage: $episodeTitleLanguage, enableDiscordRichPresence: $enableDiscordRichPresence, automaticallySkipOpening: $automaticallySkipOpening, automaticallySkipEnding: $automaticallySkipEnding, manualSkipTime: $manualSkipTime, autoPlayNextEpisode: $autoPlayNextEpisode, enableOpenSubtitlesIntegration: $enableOpenSubtitlesIntegration, enableNsfwContent: $enableNsfwContent, themeColor: $themeColor, useWallpaperAsThemeColor: $useWallpaperAsThemeColor, aniyomiExtensionsRepositories: $aniyomiExtensionsRepositories, tachiyomiExtensionsRepositories: $tachiyomiExtensionsRepositories, userService: $userService, metadataService: $metadataService)';
}


}

/// @nodoc
abstract mixin class _$SettingsModelCopyWith<$Res> implements $SettingsModelCopyWith<$Res> {
  factory _$SettingsModelCopyWith(_SettingsModel value, $Res Function(_SettingsModel) _then) = __$SettingsModelCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String language,@HiveField(1) Service service,@HiveField(2) EpisodeService episodeService,@HiveField(3)@ExtensionConverter() List<Extension> installedAnimeExtensions,@HiveField(4)@ExtensionConverter() List<Extension> installedMangaExtensions,@HiveField(7)@ExtensionConverter() Map<String, Extension> mediaExtensionConfigs,@HiveField(8) String mediaTitleLanguage,@HiveField(9) String episodeTitleLanguage,@HiveField(10) bool enableDiscordRichPresence,@HiveField(11) bool automaticallySkipOpening,@HiveField(12) bool automaticallySkipEnding,@HiveField(13) int manualSkipTime,@HiveField(14) bool autoPlayNextEpisode,@HiveField(15) bool enableOpenSubtitlesIntegration,@HiveField(16) bool enableNsfwContent,@HiveField(17)@ColorConverter() Color themeColor,@HiveField(18) bool useWallpaperAsThemeColor,@HiveField(19) List<String> aniyomiExtensionsRepositories,@HiveField(20) List<String> tachiyomiExtensionsRepositories,@HiveField(21) Service userService,@HiveField(22) Service metadataService
});




}
/// @nodoc
class __$SettingsModelCopyWithImpl<$Res>
    implements _$SettingsModelCopyWith<$Res> {
  __$SettingsModelCopyWithImpl(this._self, this._then);

  final _SettingsModel _self;
  final $Res Function(_SettingsModel) _then;

/// Create a copy of SettingsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? language = null,Object? service = null,Object? episodeService = null,Object? installedAnimeExtensions = null,Object? installedMangaExtensions = null,Object? mediaExtensionConfigs = null,Object? mediaTitleLanguage = null,Object? episodeTitleLanguage = null,Object? enableDiscordRichPresence = null,Object? automaticallySkipOpening = null,Object? automaticallySkipEnding = null,Object? manualSkipTime = null,Object? autoPlayNextEpisode = null,Object? enableOpenSubtitlesIntegration = null,Object? enableNsfwContent = null,Object? themeColor = null,Object? useWallpaperAsThemeColor = null,Object? aniyomiExtensionsRepositories = null,Object? tachiyomiExtensionsRepositories = null,Object? userService = null,Object? metadataService = null,}) {
  return _then(_SettingsModel(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as Service,episodeService: null == episodeService ? _self.episodeService : episodeService // ignore: cast_nullable_to_non_nullable
as EpisodeService,installedAnimeExtensions: null == installedAnimeExtensions ? _self._installedAnimeExtensions : installedAnimeExtensions // ignore: cast_nullable_to_non_nullable
as List<Extension>,installedMangaExtensions: null == installedMangaExtensions ? _self._installedMangaExtensions : installedMangaExtensions // ignore: cast_nullable_to_non_nullable
as List<Extension>,mediaExtensionConfigs: null == mediaExtensionConfigs ? _self._mediaExtensionConfigs : mediaExtensionConfigs // ignore: cast_nullable_to_non_nullable
as Map<String, Extension>,mediaTitleLanguage: null == mediaTitleLanguage ? _self.mediaTitleLanguage : mediaTitleLanguage // ignore: cast_nullable_to_non_nullable
as String,episodeTitleLanguage: null == episodeTitleLanguage ? _self.episodeTitleLanguage : episodeTitleLanguage // ignore: cast_nullable_to_non_nullable
as String,enableDiscordRichPresence: null == enableDiscordRichPresence ? _self.enableDiscordRichPresence : enableDiscordRichPresence // ignore: cast_nullable_to_non_nullable
as bool,automaticallySkipOpening: null == automaticallySkipOpening ? _self.automaticallySkipOpening : automaticallySkipOpening // ignore: cast_nullable_to_non_nullable
as bool,automaticallySkipEnding: null == automaticallySkipEnding ? _self.automaticallySkipEnding : automaticallySkipEnding // ignore: cast_nullable_to_non_nullable
as bool,manualSkipTime: null == manualSkipTime ? _self.manualSkipTime : manualSkipTime // ignore: cast_nullable_to_non_nullable
as int,autoPlayNextEpisode: null == autoPlayNextEpisode ? _self.autoPlayNextEpisode : autoPlayNextEpisode // ignore: cast_nullable_to_non_nullable
as bool,enableOpenSubtitlesIntegration: null == enableOpenSubtitlesIntegration ? _self.enableOpenSubtitlesIntegration : enableOpenSubtitlesIntegration // ignore: cast_nullable_to_non_nullable
as bool,enableNsfwContent: null == enableNsfwContent ? _self.enableNsfwContent : enableNsfwContent // ignore: cast_nullable_to_non_nullable
as bool,themeColor: null == themeColor ? _self.themeColor : themeColor // ignore: cast_nullable_to_non_nullable
as Color,useWallpaperAsThemeColor: null == useWallpaperAsThemeColor ? _self.useWallpaperAsThemeColor : useWallpaperAsThemeColor // ignore: cast_nullable_to_non_nullable
as bool,aniyomiExtensionsRepositories: null == aniyomiExtensionsRepositories ? _self._aniyomiExtensionsRepositories : aniyomiExtensionsRepositories // ignore: cast_nullable_to_non_nullable
as List<String>,tachiyomiExtensionsRepositories: null == tachiyomiExtensionsRepositories ? _self._tachiyomiExtensionsRepositories : tachiyomiExtensionsRepositories // ignore: cast_nullable_to_non_nullable
as List<String>,userService: null == userService ? _self.userService : userService // ignore: cast_nullable_to_non_nullable
as Service,metadataService: null == metadataService ? _self.metadataService : metadataService // ignore: cast_nullable_to_non_nullable
as Service,
  ));
}


}

// dart format on

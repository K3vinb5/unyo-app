import 'package:material_ui/material_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';
import 'package:unyo/core/enums/episode_service.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/data/adapters/adapters_names.dart' as names;
import 'package:unyo/data/adapters/adapters_types.dart' as types;
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/data/adapters/type_adapters/color_adapter.dart';
import 'package:unyo/domain/entities/extension/extension.dart';

part 'settings.freezed.dart';

part 'settings.g.dart';

abstract class Settings {
  // Configurable
  final String language;
  final String mediaTitleLanguage;
  final String episodeTitleLanguage;
  final Service service;
  final EpisodeService episodeService;
  final List<String> aniyomiExtensionsRepositories;
  final List<String> tachiyomiExtensionsRepositories;
  final bool enableDiscordRichPresence;
  final bool automaticallySkipOpening;
  final bool automaticallySkipEnding;
  final int manualSkipTime;
  final bool autoPlayNextEpisode;
  final bool enableOpenSubtitlesIntegration;
  final bool enableNsfwContent;
  final Color themeColor;
  final bool useWallpaperAsThemeColor;
  // Not configurable
  final List<Extension> installedAnimeExtensions;
  final List<Extension> installedMangaExtensions;
  final Map<String, Extension> mediaExtensionConfigs;

  const Settings({
    required this.service,
    required this.episodeService,
    required this.language,
    required this.mediaTitleLanguage,
    required this.episodeTitleLanguage,
    required this.aniyomiExtensionsRepositories,
    required this.tachiyomiExtensionsRepositories,
    required this.enableDiscordRichPresence,
    required this.automaticallySkipOpening,
    required this.automaticallySkipEnding,
    required this.manualSkipTime,
    required this.autoPlayNextEpisode,
    required this.enableOpenSubtitlesIntegration,
    required this.enableNsfwContent,
    required this.themeColor,
    required this.useWallpaperAsThemeColor,

    required this.installedAnimeExtensions,
    required this.installedMangaExtensions,
    required this.mediaExtensionConfigs,
  });
}

@freezed
@HiveType(typeId: types.settingsAdapterType, adapterName: names.settingsModelAdapterName)
abstract class SettingsModel with _$SettingsModel implements Settings {
  const factory SettingsModel({
    @HiveField(0) @Default('en') String language,
    @HiveField(1) @Default(Service.anilist) Service service,
    @HiveField(2) @Default(EpisodeService.anizip) EpisodeService episodeService,
    @HiveField(3) @ExtensionConverter() @Default([]) List<Extension> installedAnimeExtensions,
    @HiveField(4) @ExtensionConverter() @Default([]) List<Extension> installedMangaExtensions,
    @HiveField(7) @ExtensionConverter() @Default({}) Map<String, Extension> mediaExtensionConfigs,
    @HiveField(8) @Default('userPreferred') String mediaTitleLanguage,
    @HiveField(9) @Default('en') String episodeTitleLanguage,
    @HiveField(10) @Default(true) bool enableDiscordRichPresence,
    @HiveField(11) @Default(false) bool automaticallySkipOpening,
    @HiveField(12) @Default(false) bool automaticallySkipEnding,
    @HiveField(13) @Default(85) int manualSkipTime,
    @HiveField(14) @Default(false) bool autoPlayNextEpisode,
    @HiveField(15) @Default(false) bool enableOpenSubtitlesIntegration,
    @HiveField(16) @Default(false) bool enableNsfwContent,
    @HiveField(17) @ColorConverter() @Default(Color(0xFF2196F3)) Color themeColor,
    @HiveField(18) @Default(true) bool useWallpaperAsThemeColor,
    @HiveField(19) @Default([config.aniyomiExtensionsDefaultRepositoryUrl]) List<String> aniyomiExtensionsRepositories,
    @HiveField(20) @Default([config.tachiyomiExtensionsDefaultRepositoryUrl]) List<String> tachiyomiExtensionsRepositories,
  }) = _SettingsModel;

  factory SettingsModel.empty() =>
      const SettingsModel();

  factory SettingsModel.fromJson(Map<String, dynamic> json) => _$SettingsModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SettingsModelToJson(this as _SettingsModel);
}

class SettingsConverter implements JsonConverter<Settings, Map<String, dynamic>> {
  const SettingsConverter();

  @override
  Settings fromJson(Map<String, dynamic> json) => SettingsModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(Settings object) => (object as SettingsModel).toJson();
}

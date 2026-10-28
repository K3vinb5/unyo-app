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

  /// Legacy single service knob. Only kept so pre-split Hive payloads stay
  /// readable; nothing reads it outside of the [SettingsModel.fromJson]
  /// migration. Use [userService] / [metadataService] instead.
  final Service service;

  /// Provider that owns account identity, lists, progress and score.
  final Service userService;

  /// Provider that owns presentation details (synopsis, covers, genres, ...).
  final Service metadataService;
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
    required this.userService,
    required this.metadataService,
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
    /// Deprecated legacy knob (pre user/metadata split). Read only by the
    /// [SettingsModel.fromJson] migration below.
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
    @HiveField(21) @Default(Service.anilist) Service userService,
    @HiveField(22) @Default(Service.anilist) Service metadataService,
  }) = _SettingsModel;

  factory SettingsModel.empty() =>
      const SettingsModel();

  /// Pre-split installs only carry [service]; that value was always the media
  /// metadata provider, so it migrates into [metadataService] and
  /// [userService] keeps its AniList default. Key presence — not the value —
  /// decides whether this install was ever migrated.
  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      reconcileLegacyService(_$SettingsModelFromJson(_migrateLegacyServiceKeys(json)));

  static Map<String, dynamic> _migrateLegacyServiceKeys(Map<String, dynamic> json) {
    if (json.containsKey('metadataService') || !json.containsKey('service') || json['service'] == null) {
      return json;
    }
    return <String, dynamic>{...json, 'metadataService': json['service']};
  }

  /// Read-time rule shared by the JSON entry point and the Hive adapter:
  /// pre-split rows stored the old `service` knob and no `metadataService`, so
  /// they deserialise with the `anilist` default even though the user had
  /// picked another provider. Every write mirrors [metadataService] into
  /// [service], which makes this rule unambiguous: an `anilist`
  /// [metadataService] next to a non-AniList [service] can only be pre-split
  /// data.
  static SettingsModel reconcileLegacyService(SettingsModel settings) {
    if (settings.metadataService != Service.anilist) return settings;
    if (settings.service == Service.anilist) return settings;
    return settings.copyWith(metadataService: settings.service);
  }

  /// Keeps the legacy `service` field a mirror of [metadataService] on every
  /// write, so [reconcileLegacyService] never has to guess between a genuine
  /// post-split AniList choice and stale pre-split data.
  static SettingsModel mirrorLegacyService(SettingsModel settings) =>
      settings.service == settings.metadataService ? settings : settings.copyWith(service: settings.metadataService);

  /// Freezed generates `toJson()` for this class, so the legacy mirror lives in
  /// [SettingsConverter] — the only place settings are serialised.
  @override
  Map<String, dynamic> toJson() => _$SettingsModelToJson(this as _SettingsModel);
}

class SettingsConverter implements JsonConverter<Settings, Map<String, dynamic>> {
  const SettingsConverter();

  @override
  Settings fromJson(Map<String, dynamic> json) => SettingsModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(Settings object) =>
      SettingsModel.mirrorLegacyService(object as SettingsModel).toJson();
}

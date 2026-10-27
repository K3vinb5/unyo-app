// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final typeId = 2;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      language: fields[0] == null ? 'en' : fields[0] as String,
      service: fields[1] == null ? Service.anilist : fields[1] as Service,
      episodeService: fields[2] == null
          ? EpisodeService.anizip
          : fields[2] as EpisodeService,
      installedAnimeExtensions: fields[3] == null
          ? []
          : (fields[3] as List).cast<Extension>(),
      installedMangaExtensions: fields[4] == null
          ? []
          : (fields[4] as List).cast<Extension>(),
      mediaExtensionConfigs: fields[7] == null
          ? {}
          : (fields[7] as Map).cast<String, Extension>(),
      mediaTitleLanguage: fields[8] == null
          ? 'userPreferred'
          : fields[8] as String,
      episodeTitleLanguage: fields[9] == null ? 'en' : fields[9] as String,
      enableDiscordRichPresence: fields[10] == null ? true : fields[10] as bool,
      automaticallySkipOpening: fields[11] == null ? false : fields[11] as bool,
      automaticallySkipEnding: fields[12] == null ? false : fields[12] as bool,
      manualSkipTime: fields[13] == null ? 85 : (fields[13] as num).toInt(),
      autoPlayNextEpisode: fields[14] == null ? false : fields[14] as bool,
      enableOpenSubtitlesIntegration: fields[15] == null
          ? false
          : fields[15] as bool,
      enableNsfwContent: fields[16] == null ? false : fields[16] as bool,
      themeColor: fields[17] == null
          ? const Color(4280391411)
          : fields[17] as Color,
      useWallpaperAsThemeColor: fields[18] == null ? true : fields[18] as bool,
      aniyomiExtensionsRepositories: fields[19] == null
          ? [
              'https://gitea.k3vinb5.dev/Backups/kohi-den-extensions/raw/branch/main/index.min.json',
            ]
          : (fields[19] as List).cast<String>(),
      tachiyomiExtensionsRepositories: fields[20] == null
          ? [
              'https://gitea.k3vinb5.dev/Backups/keiyoushi-extensions/raw/branch/repo/index.min.json',
            ]
          : (fields[20] as List).cast<String>(),
      userService: fields[21] == null ? Service.anilist : fields[21] as Service,
      metadataService: fields[22] == null
          ? Service.anilist
          : fields[22] as Service,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.language)
      ..writeByte(1)
      ..write(obj.service)
      ..writeByte(2)
      ..write(obj.episodeService)
      ..writeByte(3)
      ..write(obj.installedAnimeExtensions)
      ..writeByte(4)
      ..write(obj.installedMangaExtensions)
      ..writeByte(7)
      ..write(obj.mediaExtensionConfigs)
      ..writeByte(8)
      ..write(obj.mediaTitleLanguage)
      ..writeByte(9)
      ..write(obj.episodeTitleLanguage)
      ..writeByte(10)
      ..write(obj.enableDiscordRichPresence)
      ..writeByte(11)
      ..write(obj.automaticallySkipOpening)
      ..writeByte(12)
      ..write(obj.automaticallySkipEnding)
      ..writeByte(13)
      ..write(obj.manualSkipTime)
      ..writeByte(14)
      ..write(obj.autoPlayNextEpisode)
      ..writeByte(15)
      ..write(obj.enableOpenSubtitlesIntegration)
      ..writeByte(16)
      ..write(obj.enableNsfwContent)
      ..writeByte(17)
      ..write(obj.themeColor)
      ..writeByte(18)
      ..write(obj.useWallpaperAsThemeColor)
      ..writeByte(19)
      ..write(obj.aniyomiExtensionsRepositories)
      ..writeByte(20)
      ..write(obj.tachiyomiExtensionsRepositories)
      ..writeByte(21)
      ..write(obj.userService)
      ..writeByte(22)
      ..write(obj.metadataService);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SettingsModel _$SettingsModelFromJson(
  Map<String, dynamic> json,
) => _SettingsModel(
  language: json['language'] as String? ?? 'en',
  service:
      $enumDecodeNullable(_$ServiceEnumMap, json['service']) ?? Service.anilist,
  episodeService:
      $enumDecodeNullable(_$EpisodeServiceEnumMap, json['episodeService']) ??
      EpisodeService.anizip,
  installedAnimeExtensions:
      (json['installedAnimeExtensions'] as List<dynamic>?)
          ?.map(
            (e) =>
                const ExtensionConverter().fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  installedMangaExtensions:
      (json['installedMangaExtensions'] as List<dynamic>?)
          ?.map(
            (e) =>
                const ExtensionConverter().fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  mediaExtensionConfigs:
      (json['mediaExtensionConfigs'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          const ExtensionConverter().fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const {},
  mediaTitleLanguage: json['mediaTitleLanguage'] as String? ?? 'userPreferred',
  episodeTitleLanguage: json['episodeTitleLanguage'] as String? ?? 'en',
  enableDiscordRichPresence: json['enableDiscordRichPresence'] as bool? ?? true,
  automaticallySkipOpening: json['automaticallySkipOpening'] as bool? ?? false,
  automaticallySkipEnding: json['automaticallySkipEnding'] as bool? ?? false,
  manualSkipTime: (json['manualSkipTime'] as num?)?.toInt() ?? 85,
  autoPlayNextEpisode: json['autoPlayNextEpisode'] as bool? ?? false,
  enableOpenSubtitlesIntegration:
      json['enableOpenSubtitlesIntegration'] as bool? ?? false,
  enableNsfwContent: json['enableNsfwContent'] as bool? ?? false,
  themeColor: json['themeColor'] == null
      ? const Color(0xFF2196F3)
      : const ColorConverter().fromJson((json['themeColor'] as num).toInt()),
  useWallpaperAsThemeColor: json['useWallpaperAsThemeColor'] as bool? ?? true,
  aniyomiExtensionsRepositories:
      (json['aniyomiExtensionsRepositories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [config.aniyomiExtensionsDefaultRepositoryUrl],
  tachiyomiExtensionsRepositories:
      (json['tachiyomiExtensionsRepositories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [config.tachiyomiExtensionsDefaultRepositoryUrl],
  userService:
      $enumDecodeNullable(_$ServiceEnumMap, json['userService']) ??
      Service.anilist,
  metadataService:
      $enumDecodeNullable(_$ServiceEnumMap, json['metadataService']) ??
      Service.anilist,
);

Map<String, dynamic> _$SettingsModelToJson(
  _SettingsModel instance,
) => <String, dynamic>{
  'language': instance.language,
  'service': _$ServiceEnumMap[instance.service]!,
  'episodeService': _$EpisodeServiceEnumMap[instance.episodeService]!,
  'installedAnimeExtensions': instance.installedAnimeExtensions
      .map(const ExtensionConverter().toJson)
      .toList(),
  'installedMangaExtensions': instance.installedMangaExtensions
      .map(const ExtensionConverter().toJson)
      .toList(),
  'mediaExtensionConfigs': instance.mediaExtensionConfigs.map(
    (k, e) => MapEntry(k, const ExtensionConverter().toJson(e)),
  ),
  'mediaTitleLanguage': instance.mediaTitleLanguage,
  'episodeTitleLanguage': instance.episodeTitleLanguage,
  'enableDiscordRichPresence': instance.enableDiscordRichPresence,
  'automaticallySkipOpening': instance.automaticallySkipOpening,
  'automaticallySkipEnding': instance.automaticallySkipEnding,
  'manualSkipTime': instance.manualSkipTime,
  'autoPlayNextEpisode': instance.autoPlayNextEpisode,
  'enableOpenSubtitlesIntegration': instance.enableOpenSubtitlesIntegration,
  'enableNsfwContent': instance.enableNsfwContent,
  'themeColor': const ColorConverter().toJson(instance.themeColor),
  'useWallpaperAsThemeColor': instance.useWallpaperAsThemeColor,
  'aniyomiExtensionsRepositories': instance.aniyomiExtensionsRepositories,
  'tachiyomiExtensionsRepositories': instance.tachiyomiExtensionsRepositories,
  'userService': _$ServiceEnumMap[instance.userService]!,
  'metadataService': _$ServiceEnumMap[instance.metadataService]!,
};

const _$ServiceEnumMap = {
  Service.anilist: 'anilist',
  Service.mal: 'mal',
  Service.kitsu: 'kitsu',
  Service.shikimori: 'shikimori',
  Service.simkl: 'simkl',
};

const _$EpisodeServiceEnumMap = {
  EpisodeService.anizip: 'anizip',
  EpisodeService.kitsu: 'kitsu',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mal_anime_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MalAnimeDetailsModel _$MalAnimeDetailsModelFromJson(
  Map<String, dynamic> json,
) => _MalAnimeDetailsModel(
  mediaListEntry: const MediaListEntryConverter().fromJson(
    json['mediaListEntry'] as Map<String, dynamic>,
  ),
  recommendedAnimes: (json['recommendedAnimes'] as List<dynamic>)
      .map((e) => const AnimeConverter().fromJson(e as Map<String, dynamic>))
      .toList(),
  characters: (json['characters'] as List<dynamic>)
      .map(
        (e) =>
            const MediaCharacterConverter().fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$MalAnimeDetailsModelToJson(
  _MalAnimeDetailsModel instance,
) => <String, dynamic>{
  'mediaListEntry': const MediaListEntryConverter().toJson(
    instance.mediaListEntry,
  ),
  'recommendedAnimes': instance.recommendedAnimes
      .map(const AnimeConverter().toJson)
      .toList(),
  'characters': instance.characters
      .map(const MediaCharacterConverter().toJson)
      .toList(),
};

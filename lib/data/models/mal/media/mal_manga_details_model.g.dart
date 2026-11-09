// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mal_manga_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MalMangaDetailsModel _$MalMangaDetailsModelFromJson(
  Map<String, dynamic> json,
) => _MalMangaDetailsModel(
  mediaListEntry: const MediaListEntryConverter().fromJson(
    json['mediaListEntry'] as Map<String, dynamic>,
  ),
  recommendedMangas: (json['recommendedMangas'] as List<dynamic>)
      .map((e) => const MangaConverter().fromJson(e as Map<String, dynamic>))
      .toList(),
  characters: (json['characters'] as List<dynamic>)
      .map(
        (e) =>
            const MediaCharacterConverter().fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$MalMangaDetailsModelToJson(
  _MalMangaDetailsModel instance,
) => <String, dynamic>{
  'mediaListEntry': const MediaListEntryConverter().toJson(
    instance.mediaListEntry,
  ),
  'recommendedMangas': instance.recommendedMangas
      .map(const MangaConverter().toJson)
      .toList(),
  'characters': instance.characters
      .map(const MediaCharacterConverter().toJson)
      .toList(),
};

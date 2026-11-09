// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mal_anime_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MalAnimeModel _$MalAnimeModelFromJson(
  Map<String, dynamic> json,
) => _MalAnimeModel(
  id: (json['id'] as num).toInt(),
  idMal: (json['idMal'] as num).toInt(),
  title: const TitleConverter().fromJson(json['title'] as Map<String, dynamic>),
  averageScore: (json['averageScore'] as num).toInt(),
  bannerImage: json['bannerImage'] as String,
  countryOfOrigin: json['countryOfOrigin'] as String,
  coverImage: json['coverImage'] as String,
  description: json['description'] as String,
  duration: (json['duration'] as num).toInt(),
  endDate: json['endDate'] as String,
  startDate: json['startDate'] as String,
  episodes: (json['episodes'] as num).toInt(),
  genres: (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
  format: json['format'] as String,
  isAdult: json['isAdult'] as bool,
  popularity: (json['popularity'] as num).toInt(),
  meanScore: (json['meanScore'] as num).toInt(),
  season: json['season'] as String,
  status: json['status'] as String,
  isFavourite: json['isFavourite'] as bool,
  nextAiringEpisode: const AiringEpisodeConverter().fromJson(
    json['nextAiringEpisode'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$MalAnimeModelToJson(_MalAnimeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'idMal': instance.idMal,
      'title': const TitleConverter().toJson(instance.title),
      'averageScore': instance.averageScore,
      'bannerImage': instance.bannerImage,
      'countryOfOrigin': instance.countryOfOrigin,
      'coverImage': instance.coverImage,
      'description': instance.description,
      'duration': instance.duration,
      'endDate': instance.endDate,
      'startDate': instance.startDate,
      'episodes': instance.episodes,
      'genres': instance.genres,
      'format': instance.format,
      'isAdult': instance.isAdult,
      'popularity': instance.popularity,
      'meanScore': instance.meanScore,
      'season': instance.season,
      'status': instance.status,
      'isFavourite': instance.isFavourite,
      'nextAiringEpisode': const AiringEpisodeConverter().toJson(
        instance.nextAiringEpisode,
      ),
    };

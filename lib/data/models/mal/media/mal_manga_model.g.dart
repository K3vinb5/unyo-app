// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mal_manga_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MalMangaModel _$MalMangaModelFromJson(
  Map<String, dynamic> json,
) => _MalMangaModel(
  id: (json['id'] as num).toInt(),
  idMal: (json['idMal'] as num).toInt(),
  title: const TitleConverter().fromJson(json['title'] as Map<String, dynamic>),
  averageScore: (json['averageScore'] as num).toInt(),
  bannerImage: json['bannerImage'] as String,
  chapters: (json['chapters'] as num).toInt(),
  countryOfOrigin: json['countryOfOrigin'] as String,
  coverImage: json['coverImage'] as String,
  description: json['description'] as String,
  endDate: json['endDate'] as String,
  startDate: json['startDate'] as String,
  genres: (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
  format: json['format'] as String,
  isAdult: json['isAdult'] as bool,
  popularity: (json['popularity'] as num).toInt(),
  meanScore: (json['meanScore'] as num).toInt(),
  status: json['status'] as String,
  isFavourite: json['isFavourite'] as bool,
);

Map<String, dynamic> _$MalMangaModelToJson(_MalMangaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'idMal': instance.idMal,
      'title': const TitleConverter().toJson(instance.title),
      'averageScore': instance.averageScore,
      'bannerImage': instance.bannerImage,
      'chapters': instance.chapters,
      'countryOfOrigin': instance.countryOfOrigin,
      'coverImage': instance.coverImage,
      'description': instance.description,
      'endDate': instance.endDate,
      'startDate': instance.startDate,
      'genres': instance.genres,
      'format': instance.format,
      'isAdult': instance.isAdult,
      'popularity': instance.popularity,
      'meanScore': instance.meanScore,
      'status': instance.status,
      'isFavourite': instance.isFavourite,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'title.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TitleModel _$TitleModelFromJson(Map<String, dynamic> json) => _TitleModel(
  romaji: json['romaji'] as String,
  english: json['english'] as String,
  nativeTitle: json['nativeTitle'] as String,
  userPreferred: json['userPreferred'] as String,
  russian: json['russian'] as String? ?? '',
);

Map<String, dynamic> _$TitleModelToJson(_TitleModel instance) =>
    <String, dynamic>{
      'romaji': instance.romaji,
      'english': instance.english,
      'nativeTitle': instance.nativeTitle,
      'userPreferred': instance.userPreferred,
      'russian': instance.russian,
    };

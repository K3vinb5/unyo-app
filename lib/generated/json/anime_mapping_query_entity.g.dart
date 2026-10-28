import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_mapping_query_entity.dart';

AnimeMappingQueryEntity $AnimeMappingQueryEntityFromJson(Map<String, dynamic> json) {
	final AnimeMappingQueryEntity animeMappingQueryEntity = AnimeMappingQueryEntity();
	final List<AnimeMappingQueryAnimes>? animes = (json['animes'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AnimeMappingQueryAnimes>(e) as AnimeMappingQueryAnimes).toList();
	if (animes != null) {
		animeMappingQueryEntity.animes = animes;
	}
	return animeMappingQueryEntity;
}

Map<String, dynamic> $AnimeMappingQueryEntityToJson(AnimeMappingQueryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['animes'] =  entity.animes.map((v) => v.toJson()).toList();
	return data;
}

extension AnimeMappingQueryEntityExtension on AnimeMappingQueryEntity {
	AnimeMappingQueryEntity copyWith({
	List<AnimeMappingQueryAnimes>? animes,
	}) {
		return AnimeMappingQueryEntity()
			..animes = animes ?? this.animes;
	}
}


AnimeMappingQueryAnimes $AnimeMappingQueryAnimesFromJson(Map<String, dynamic> json) {
	final AnimeMappingQueryAnimes animeMappingQueryAnimes = AnimeMappingQueryAnimes();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		animeMappingQueryAnimes.id = id;
	}
	final String? malId = jsonConvert.convert<String>(json['malId']);
	if (malId != null) {
		animeMappingQueryAnimes.malId = malId;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		animeMappingQueryAnimes.name = name;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		animeMappingQueryAnimes.russian = russian;
	}
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		animeMappingQueryAnimes.english = english;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		animeMappingQueryAnimes.kind = kind;
	}
	final AnimeMappingQueryAnimesAiredOn? airedOn = jsonConvert.convert<AnimeMappingQueryAnimesAiredOn>(json['airedOn']);
	if (airedOn != null) {
		animeMappingQueryAnimes.airedOn = airedOn;
	}
	return animeMappingQueryAnimes;
}

Map<String, dynamic> $AnimeMappingQueryAnimesToJson(AnimeMappingQueryAnimes entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['malId'] = entity.malId;
	data['name'] = entity.name;
	data['russian'] = entity.russian;
	data['english'] = entity.english;
	data['kind'] = entity.kind;
	data['airedOn'] = entity.airedOn.toJson();
	return data;
}

extension AnimeMappingQueryAnimesExtension on AnimeMappingQueryAnimes {
	AnimeMappingQueryAnimes copyWith({
	String? id,
	String? malId,
	String? name,
	String? russian,
	String? english,
	String? kind,
	AnimeMappingQueryAnimesAiredOn? airedOn,
	}) {
		return AnimeMappingQueryAnimes()
			..id = id ?? this.id
			..malId = malId ?? this.malId
			..name = name ?? this.name
			..russian = russian ?? this.russian
			..english = english ?? this.english
			..kind = kind ?? this.kind
			..airedOn = airedOn ?? this.airedOn;
	}
}


AnimeMappingQueryAnimesAiredOn $AnimeMappingQueryAnimesAiredOnFromJson(Map<String, dynamic> json) {
	final AnimeMappingQueryAnimesAiredOn animeMappingQueryAnimesAiredOn = AnimeMappingQueryAnimesAiredOn();
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		animeMappingQueryAnimesAiredOn.year = year;
	}
	return animeMappingQueryAnimesAiredOn;
}

Map<String, dynamic> $AnimeMappingQueryAnimesAiredOnToJson(AnimeMappingQueryAnimesAiredOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['year'] = entity.year;
	return data;
}

extension AnimeMappingQueryAnimesAiredOnExtension on AnimeMappingQueryAnimesAiredOn {
	AnimeMappingQueryAnimesAiredOn copyWith({
	int? year,
	}) {
		return AnimeMappingQueryAnimesAiredOn()
			..year = year ?? this.year;
	}
}

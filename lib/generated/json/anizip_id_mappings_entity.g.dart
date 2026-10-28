import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/anizip/anizip_id_mappings_entity.dart';

AnizipIdMappingsEntity $AnizipIdMappingsEntityFromJson(Map<String, dynamic> json) {
	final AnizipIdMappingsEntity anizipIdMappingsEntity = AnizipIdMappingsEntity();
	final AnizipIdMappingsMappings? mappings = jsonConvert.convert<AnizipIdMappingsMappings>(json['mappings']);
	if (mappings != null) {
		anizipIdMappingsEntity.mappings = mappings;
	}
	return anizipIdMappingsEntity;
}

Map<String, dynamic> $AnizipIdMappingsEntityToJson(AnizipIdMappingsEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['mappings'] = entity.mappings.toJson();
	return data;
}

extension AnizipIdMappingsEntityExtension on AnizipIdMappingsEntity {
	AnizipIdMappingsEntity copyWith({
	AnizipIdMappingsMappings? mappings,
	}) {
		return AnizipIdMappingsEntity()
			..mappings = mappings ?? this.mappings;
	}
}


AnizipIdMappingsMappings $AnizipIdMappingsMappingsFromJson(Map<String, dynamic> json) {
	final AnizipIdMappingsMappings anizipIdMappingsMappings = AnizipIdMappingsMappings();
	final int? malId = jsonConvert.convert<int>(json['mal_id']);
	if (malId != null) {
		anizipIdMappingsMappings.malId = malId;
	}
	final int? anilistId = jsonConvert.convert<int>(json['anilist_id']);
	if (anilistId != null) {
		anizipIdMappingsMappings.anilistId = anilistId;
	}
	return anizipIdMappingsMappings;
}

Map<String, dynamic> $AnizipIdMappingsMappingsToJson(AnizipIdMappingsMappings entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['mal_id'] = entity.malId;
	data['anilist_id'] = entity.anilistId;
	return data;
}

extension AnizipIdMappingsMappingsExtension on AnizipIdMappingsMappings {
	AnizipIdMappingsMappings copyWith({
	int? malId,
	int? anilistId,
	}) {
		return AnizipIdMappingsMappings()
			..malId = malId ?? this.malId
			..anilistId = anilistId ?? this.anilistId;
	}
}

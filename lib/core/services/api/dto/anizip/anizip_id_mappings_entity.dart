import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/anizip_id_mappings_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/anizip_id_mappings_entity.g.dart';

@JsonSerializable()
class AnizipIdMappingsEntity {
	late AnizipIdMappingsMappings mappings = AnizipIdMappingsMappings();

	AnizipIdMappingsEntity();

	factory AnizipIdMappingsEntity.fromJson(Map<String, dynamic> json) => $AnizipIdMappingsEntityFromJson(json);

	Map<String, dynamic> toJson() => $AnizipIdMappingsEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnizipIdMappingsMappings {
	@JSONField(name: 'mal_id')
	late int malId = 0;
	@JSONField(name: 'anilist_id')
	late int anilistId = 0;

	AnizipIdMappingsMappings();

	factory AnizipIdMappingsMappings.fromJson(Map<String, dynamic> json) => $AnizipIdMappingsMappingsFromJson(json);

	Map<String, dynamic> toJson() => $AnizipIdMappingsMappingsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
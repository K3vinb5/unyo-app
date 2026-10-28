import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/anime_mapping_query_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/anime_mapping_query_entity.g.dart';

@JsonSerializable()
class AnimeMappingQueryEntity {
	late List<AnimeMappingQueryAnimes> animes = [];

	AnimeMappingQueryEntity();

	factory AnimeMappingQueryEntity.fromJson(Map<String, dynamic> json) => $AnimeMappingQueryEntityFromJson(json);

	Map<String, dynamic> toJson() => $AnimeMappingQueryEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeMappingQueryAnimes {
	late String id = '';
	late String malId = '';
	late String name = '';
	late String russian = '';
	late String english = '';
	late String kind = '';
	late AnimeMappingQueryAnimesAiredOn airedOn = AnimeMappingQueryAnimesAiredOn();

	AnimeMappingQueryAnimes();

	factory AnimeMappingQueryAnimes.fromJson(Map<String, dynamic> json) => $AnimeMappingQueryAnimesFromJson(json);

	Map<String, dynamic> toJson() => $AnimeMappingQueryAnimesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeMappingQueryAnimesAiredOn {
	late int year = 0;

	AnimeMappingQueryAnimesAiredOn();

	factory AnimeMappingQueryAnimesAiredOn.fromJson(Map<String, dynamic> json) => $AnimeMappingQueryAnimesAiredOnFromJson(json);

	Map<String, dynamic> toJson() => $AnimeMappingQueryAnimesAiredOnToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
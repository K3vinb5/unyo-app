import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/shikimori_genres_list_query_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/shikimori_genres_list_query_entity.g.dart';

@JsonSerializable()
class ShikimoriGenresListQueryEntity {
	late List<ShikimoriGenresListQueryGenres> genres = [];

	ShikimoriGenresListQueryEntity();

	factory ShikimoriGenresListQueryEntity.fromJson(Map<String, dynamic> json) => $ShikimoriGenresListQueryEntityFromJson(json);

	Map<String, dynamic> toJson() => $ShikimoriGenresListQueryEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class ShikimoriGenresListQueryGenres {
	late String id = '';
	late String name = '';
	late String russian = '';
	late String kind = '';

	ShikimoriGenresListQueryGenres();

	factory ShikimoriGenresListQueryGenres.fromJson(Map<String, dynamic> json) => $ShikimoriGenresListQueryGenresFromJson(json);

	Map<String, dynamic> toJson() => $ShikimoriGenresListQueryGenresToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
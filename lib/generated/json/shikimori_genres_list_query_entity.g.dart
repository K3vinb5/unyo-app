import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_genres_list_query_entity.dart';

ShikimoriGenresListQueryEntity $ShikimoriGenresListQueryEntityFromJson(Map<String, dynamic> json) {
	final ShikimoriGenresListQueryEntity shikimoriGenresListQueryEntity = ShikimoriGenresListQueryEntity();
	final List<ShikimoriGenresListQueryGenres>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<ShikimoriGenresListQueryGenres>(e) as ShikimoriGenresListQueryGenres).toList();
	if (genres != null) {
		shikimoriGenresListQueryEntity.genres = genres;
	}
	return shikimoriGenresListQueryEntity;
}

Map<String, dynamic> $ShikimoriGenresListQueryEntityToJson(ShikimoriGenresListQueryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['genres'] =  entity.genres.map((v) => v.toJson()).toList();
	return data;
}

extension ShikimoriGenresListQueryEntityExtension on ShikimoriGenresListQueryEntity {
	ShikimoriGenresListQueryEntity copyWith({
	List<ShikimoriGenresListQueryGenres>? genres,
	}) {
		return ShikimoriGenresListQueryEntity()
			..genres = genres ?? this.genres;
	}
}


ShikimoriGenresListQueryGenres $ShikimoriGenresListQueryGenresFromJson(Map<String, dynamic> json) {
	final ShikimoriGenresListQueryGenres shikimoriGenresListQueryGenres = ShikimoriGenresListQueryGenres();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		shikimoriGenresListQueryGenres.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		shikimoriGenresListQueryGenres.name = name;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		shikimoriGenresListQueryGenres.russian = russian;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		shikimoriGenresListQueryGenres.kind = kind;
	}
	return shikimoriGenresListQueryGenres;
}

Map<String, dynamic> $ShikimoriGenresListQueryGenresToJson(ShikimoriGenresListQueryGenres entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['russian'] = entity.russian;
	data['kind'] = entity.kind;
	return data;
}

extension ShikimoriGenresListQueryGenresExtension on ShikimoriGenresListQueryGenres {
	ShikimoriGenresListQueryGenres copyWith({
	String? id,
	String? name,
	String? russian,
	String? kind,
	}) {
		return ShikimoriGenresListQueryGenres()
			..id = id ?? this.id
			..name = name ?? this.name
			..russian = russian ?? this.russian
			..kind = kind ?? this.kind;
	}
}

import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_user_rates_anime_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_list_query_entity.dart';

ShikimoriUserRatesAnimeQueryEntity $ShikimoriUserRatesAnimeQueryEntityFromJson(Map<String, dynamic> json) {
	final ShikimoriUserRatesAnimeQueryEntity shikimoriUserRatesAnimeQueryEntity = ShikimoriUserRatesAnimeQueryEntity();
	final List<ShikimoriUserRatesAnimeQueryUserRates>? userRates = (json['userRates'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<ShikimoriUserRatesAnimeQueryUserRates>(e) as ShikimoriUserRatesAnimeQueryUserRates).toList();
	if (userRates != null) {
		shikimoriUserRatesAnimeQueryEntity.userRates = userRates;
	}
	return shikimoriUserRatesAnimeQueryEntity;
}

Map<String, dynamic> $ShikimoriUserRatesAnimeQueryEntityToJson(ShikimoriUserRatesAnimeQueryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['userRates'] =  entity.userRates.map((v) => v.toJson()).toList();
	return data;
}

extension ShikimoriUserRatesAnimeQueryEntityExtension on ShikimoriUserRatesAnimeQueryEntity {
	ShikimoriUserRatesAnimeQueryEntity copyWith({
	List<ShikimoriUserRatesAnimeQueryUserRates>? userRates,
	}) {
		return ShikimoriUserRatesAnimeQueryEntity()
			..userRates = userRates ?? this.userRates;
	}
}


ShikimoriUserRatesAnimeQueryUserRates $ShikimoriUserRatesAnimeQueryUserRatesFromJson(Map<String, dynamic> json) {
	final ShikimoriUserRatesAnimeQueryUserRates shikimoriUserRatesAnimeQueryUserRates = ShikimoriUserRatesAnimeQueryUserRates();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		shikimoriUserRatesAnimeQueryUserRates.id = id;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		shikimoriUserRatesAnimeQueryUserRates.status = status;
	}
	final int? score = jsonConvert.convert<int>(json['score']);
	if (score != null) {
		shikimoriUserRatesAnimeQueryUserRates.score = score;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		shikimoriUserRatesAnimeQueryUserRates.episodes = episodes;
	}
	final int? rewatches = jsonConvert.convert<int>(json['rewatches']);
	if (rewatches != null) {
		shikimoriUserRatesAnimeQueryUserRates.rewatches = rewatches;
	}
	final int? volumes = jsonConvert.convert<int>(json['volumes']);
	if (volumes != null) {
		shikimoriUserRatesAnimeQueryUserRates.volumes = volumes;
	}
	final int? chapters = jsonConvert.convert<int>(json['chapters']);
	if (chapters != null) {
		shikimoriUserRatesAnimeQueryUserRates.chapters = chapters;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		shikimoriUserRatesAnimeQueryUserRates.createdAt = createdAt;
	}
	final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
	if (updatedAt != null) {
		shikimoriUserRatesAnimeQueryUserRates.updatedAt = updatedAt;
	}
	final AnimeListQueryAnimes? anime = jsonConvert.convert<AnimeListQueryAnimes>(json['anime']);
	if (anime != null) {
		shikimoriUserRatesAnimeQueryUserRates.anime = anime;
	}
	return shikimoriUserRatesAnimeQueryUserRates;
}

Map<String, dynamic> $ShikimoriUserRatesAnimeQueryUserRatesToJson(ShikimoriUserRatesAnimeQueryUserRates entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['status'] = entity.status;
	data['score'] = entity.score;
	data['episodes'] = entity.episodes;
	data['rewatches'] = entity.rewatches;
	data['volumes'] = entity.volumes;
	data['chapters'] = entity.chapters;
	data['createdAt'] = entity.createdAt;
	data['updatedAt'] = entity.updatedAt;
	data['anime'] = entity.anime.toJson();
	return data;
}

extension ShikimoriUserRatesAnimeQueryUserRatesExtension on ShikimoriUserRatesAnimeQueryUserRates {
	ShikimoriUserRatesAnimeQueryUserRates copyWith({
	String? id,
	String? status,
	int? score,
	int? episodes,
	int? rewatches,
	int? volumes,
	int? chapters,
	String? createdAt,
	String? updatedAt,
	AnimeListQueryAnimes? anime,
	}) {
		return ShikimoriUserRatesAnimeQueryUserRates()
			..id = id ?? this.id
			..status = status ?? this.status
			..score = score ?? this.score
			..episodes = episodes ?? this.episodes
			..rewatches = rewatches ?? this.rewatches
			..volumes = volumes ?? this.volumes
			..chapters = chapters ?? this.chapters
			..createdAt = createdAt ?? this.createdAt
			..updatedAt = updatedAt ?? this.updatedAt
			..anime = anime ?? this.anime;
	}
}

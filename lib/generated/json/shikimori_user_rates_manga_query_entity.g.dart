import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_user_rates_manga_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/manga_list_query_entity.dart';

ShikimoriUserRatesMangaQueryEntity $ShikimoriUserRatesMangaQueryEntityFromJson(Map<String, dynamic> json) {
	final ShikimoriUserRatesMangaQueryEntity shikimoriUserRatesMangaQueryEntity = ShikimoriUserRatesMangaQueryEntity();
	final List<ShikimoriUserRatesMangaQueryUserRates>? userRates = (json['userRates'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<ShikimoriUserRatesMangaQueryUserRates>(e) as ShikimoriUserRatesMangaQueryUserRates).toList();
	if (userRates != null) {
		shikimoriUserRatesMangaQueryEntity.userRates = userRates;
	}
	return shikimoriUserRatesMangaQueryEntity;
}

Map<String, dynamic> $ShikimoriUserRatesMangaQueryEntityToJson(ShikimoriUserRatesMangaQueryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['userRates'] =  entity.userRates.map((v) => v.toJson()).toList();
	return data;
}

extension ShikimoriUserRatesMangaQueryEntityExtension on ShikimoriUserRatesMangaQueryEntity {
	ShikimoriUserRatesMangaQueryEntity copyWith({
	List<ShikimoriUserRatesMangaQueryUserRates>? userRates,
	}) {
		return ShikimoriUserRatesMangaQueryEntity()
			..userRates = userRates ?? this.userRates;
	}
}


ShikimoriUserRatesMangaQueryUserRates $ShikimoriUserRatesMangaQueryUserRatesFromJson(Map<String, dynamic> json) {
	final ShikimoriUserRatesMangaQueryUserRates shikimoriUserRatesMangaQueryUserRates = ShikimoriUserRatesMangaQueryUserRates();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		shikimoriUserRatesMangaQueryUserRates.id = id;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		shikimoriUserRatesMangaQueryUserRates.status = status;
	}
	final int? score = jsonConvert.convert<int>(json['score']);
	if (score != null) {
		shikimoriUserRatesMangaQueryUserRates.score = score;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		shikimoriUserRatesMangaQueryUserRates.episodes = episodes;
	}
	final int? rewatches = jsonConvert.convert<int>(json['rewatches']);
	if (rewatches != null) {
		shikimoriUserRatesMangaQueryUserRates.rewatches = rewatches;
	}
	final int? volumes = jsonConvert.convert<int>(json['volumes']);
	if (volumes != null) {
		shikimoriUserRatesMangaQueryUserRates.volumes = volumes;
	}
	final int? chapters = jsonConvert.convert<int>(json['chapters']);
	if (chapters != null) {
		shikimoriUserRatesMangaQueryUserRates.chapters = chapters;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		shikimoriUserRatesMangaQueryUserRates.createdAt = createdAt;
	}
	final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
	if (updatedAt != null) {
		shikimoriUserRatesMangaQueryUserRates.updatedAt = updatedAt;
	}
	final MangaListQueryMangas? manga = jsonConvert.convert<MangaListQueryMangas>(json['manga']);
	if (manga != null) {
		shikimoriUserRatesMangaQueryUserRates.manga = manga;
	}
	return shikimoriUserRatesMangaQueryUserRates;
}

Map<String, dynamic> $ShikimoriUserRatesMangaQueryUserRatesToJson(ShikimoriUserRatesMangaQueryUserRates entity) {
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
	data['manga'] = entity.manga.toJson();
	return data;
}

extension ShikimoriUserRatesMangaQueryUserRatesExtension on ShikimoriUserRatesMangaQueryUserRates {
	ShikimoriUserRatesMangaQueryUserRates copyWith({
	String? id,
	String? status,
	int? score,
	int? episodes,
	int? rewatches,
	int? volumes,
	int? chapters,
	String? createdAt,
	String? updatedAt,
	MangaListQueryMangas? manga,
	}) {
		return ShikimoriUserRatesMangaQueryUserRates()
			..id = id ?? this.id
			..status = status ?? this.status
			..score = score ?? this.score
			..episodes = episodes ?? this.episodes
			..rewatches = rewatches ?? this.rewatches
			..volumes = volumes ?? this.volumes
			..chapters = chapters ?? this.chapters
			..createdAt = createdAt ?? this.createdAt
			..updatedAt = updatedAt ?? this.updatedAt
			..manga = manga ?? this.manga;
	}
}

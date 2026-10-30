import 'package:unyo/core/services/api/dto/shikimori/manga_list_query_entity.dart';
import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/shikimori_user_rates_manga_query_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/shikimori_user_rates_manga_query_entity.g.dart';

/// `data` payload of the `userRates` list document for **manga** rates
/// (mirror of [ShikimoriUserRatesAnimeQueryEntity]; the manga node is the
/// carousel shape [MangaListQueryMangas]).
@JsonSerializable()
class ShikimoriUserRatesMangaQueryEntity {
	late List<ShikimoriUserRatesMangaQueryUserRates> userRates = [];

	ShikimoriUserRatesMangaQueryEntity();

	factory ShikimoriUserRatesMangaQueryEntity.fromJson(Map<String, dynamic> json) => $ShikimoriUserRatesMangaQueryEntityFromJson(json);

	Map<String, dynamic> toJson() => $ShikimoriUserRatesMangaQueryEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class ShikimoriUserRatesMangaQueryUserRates {
	late String id = '';
	late String status = '';
	late int score = 0;
	late int episodes = 0;
	late int rewatches = 0;
	late int volumes = 0;
	late int chapters = 0;
	late String createdAt = '';
	late String updatedAt = '';
	late MangaListQueryMangas manga = MangaListQueryMangas();

	ShikimoriUserRatesMangaQueryUserRates();

	factory ShikimoriUserRatesMangaQueryUserRates.fromJson(Map<String, dynamic> json) => $ShikimoriUserRatesMangaQueryUserRatesFromJson(json);

	Map<String, dynamic> toJson() => $ShikimoriUserRatesMangaQueryUserRatesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

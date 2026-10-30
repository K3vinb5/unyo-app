import 'package:unyo/core/services/api/dto/shikimori/anime_list_query_entity.dart';
import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/shikimori_user_rates_anime_query_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/shikimori_user_rates_anime_query_entity.g.dart';

/// `data` payload of the `userRates` list document for **anime** rates.
///
/// One document per target type: selecting both the `anime` and the `manga`
/// node blows the query-cost budget (`Query has complexity of 227, which exceeds
/// max complexity of 190`, `raws/api/gql-user-rates-probes.txt` §5).
///
/// The nested `anime` node is the **carousel** shape ([AnimeListQueryAnimes]),
/// so the list screen and the watch carousel map every card through the exact
/// same `ShikimoriAnimeModel.fromListEntry` factory.
@JsonSerializable()
class ShikimoriUserRatesAnimeQueryEntity {
	late List<ShikimoriUserRatesAnimeQueryUserRates> userRates = [];

	ShikimoriUserRatesAnimeQueryEntity();

	factory ShikimoriUserRatesAnimeQueryEntity.fromJson(Map<String, dynamic> json) => $ShikimoriUserRatesAnimeQueryEntityFromJson(json);

	Map<String, dynamic> toJson() => $ShikimoriUserRatesAnimeQueryEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class ShikimoriUserRatesAnimeQueryUserRates {
	late String id = '';
	late String status = '';
	late int score = 0;
	late int episodes = 0;
	late int rewatches = 0;
	late int volumes = 0;
	late int chapters = 0;
	late String createdAt = '';
	late String updatedAt = '';
	late AnimeListQueryAnimes anime = AnimeListQueryAnimes();

	ShikimoriUserRatesAnimeQueryUserRates();

	factory ShikimoriUserRatesAnimeQueryUserRates.fromJson(Map<String, dynamic> json) => $ShikimoriUserRatesAnimeQueryUserRatesFromJson(json);

	Map<String, dynamic> toJson() => $ShikimoriUserRatesAnimeQueryUserRatesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

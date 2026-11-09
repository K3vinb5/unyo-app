import 'package:unyo/core/services/api/dto/mal/mal_my_list_status_entity.dart';
import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/mal_anime_node.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/mal_anime_node.g.dart';

/// One MyAnimeList anime node (WP #166).
///
/// The same shape is returned by `GET /anime`, `GET /anime/ranking` and
/// `GET /anime/{id}`; MAL only trims keys that were not requested through
/// `fields=`, so the DTO keeps the superset. Field names follow the official v2
/// reference (<https://myanimelist.net/apiconfig/references/api/v2>).
@JsonSerializable()
class MalAnimeNode {
	late int id = 0;
	late String title = '';
	@JSONField(name: 'main_picture')
	late MalAnimeNodeMainPicture mainPicture = MalAnimeNodeMainPicture();
	@JSONField(name: 'alternative_titles')
	late MalAnimeNodeAlternativeTitles alternativeTitles = MalAnimeNodeAlternativeTitles();
	@JSONField(name: 'start_date')
	late String startDate = '';
	@JSONField(name: 'end_date')
	late String endDate = '';
	late String synopsis = '';
	late double mean = 0;
	late int rank = 0;
	late int popularity = 0;
	@JSONField(name: 'num_list_users')
	late int numListUsers = 0;
	@JSONField(name: 'media_type')
	late String mediaType = '';
	late String status = '';
	late List<MalAnimeNodeGenres> genres = [];
	late String nsfw = '';
	late String rating = '';
	@JSONField(name: 'num_episodes')
	late int numEpisodes = 0;
	@JSONField(name: 'start_season')
	late MalAnimeNodeStartSeason startSeason = MalAnimeNodeStartSeason();
	late MalAnimeNodeBroadcast broadcast = MalAnimeNodeBroadcast();
	@JSONField(name: 'average_episode_duration')
	late int averageEpisodeDuration = 0;
	late List<MalAnimeNodeStudios> studios = [];
	@JSONField(name: 'related_anime')
	late List<MalAnimeNodeRelated> relatedAnime = [];
	@JSONField(name: 'related_manga')
	late List<MalAnimeNodeRelated> relatedManga = [];
	@JSONField(name: 'my_list_status')
	late MalMyListStatusEntity myListStatus = MalMyListStatusEntity();

	MalAnimeNode();

	factory MalAnimeNode.fromJson(Map<String, dynamic> json) => $MalAnimeNodeFromJson(json);

	Map<String, dynamic> toJson() => $MalAnimeNodeToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalAnimeNodeMainPicture {
	late String medium = '';
	late String large = '';

	MalAnimeNodeMainPicture();

	factory MalAnimeNodeMainPicture.fromJson(Map<String, dynamic> json) => $MalAnimeNodeMainPictureFromJson(json);

	Map<String, dynamic> toJson() => $MalAnimeNodeMainPictureToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalAnimeNodeAlternativeTitles {
	late List<String> synonyms = [];
	late String en = '';
	late String ja = '';

	MalAnimeNodeAlternativeTitles();

	factory MalAnimeNodeAlternativeTitles.fromJson(Map<String, dynamic> json) => $MalAnimeNodeAlternativeTitlesFromJson(json);

	Map<String, dynamic> toJson() => $MalAnimeNodeAlternativeTitlesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalAnimeNodeGenres {
	late int id = 0;
	late String name = '';

	MalAnimeNodeGenres();

	factory MalAnimeNodeGenres.fromJson(Map<String, dynamic> json) => $MalAnimeNodeGenresFromJson(json);

	Map<String, dynamic> toJson() => $MalAnimeNodeGenresToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalAnimeNodeStudios {
	late int id = 0;
	late String name = '';

	MalAnimeNodeStudios();

	factory MalAnimeNodeStudios.fromJson(Map<String, dynamic> json) => $MalAnimeNodeStudiosFromJson(json);

	Map<String, dynamic> toJson() => $MalAnimeNodeStudiosToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

/// `start_season`: `{year, season}` with season `winter|spring|summer|fall`.
@JsonSerializable()
class MalAnimeNodeStartSeason {
	late int year = 0;
	late String season = '';

	MalAnimeNodeStartSeason();

	factory MalAnimeNodeStartSeason.fromJson(Map<String, dynamic> json) => $MalAnimeNodeStartSeasonFromJson(json);

	Map<String, dynamic> toJson() => $MalAnimeNodeStartSeasonToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

/// `broadcast`: the weekly slot only — MAL v2 exposes no next-episode timestamp.
@JsonSerializable()
class MalAnimeNodeBroadcast {
	@JSONField(name: 'day_of_the_week')
	late String dayOfTheWeek = '';
	@JSONField(name: 'start_time')
	late String startTime = '';

	MalAnimeNodeBroadcast();

	factory MalAnimeNodeBroadcast.fromJson(Map<String, dynamic> json) => $MalAnimeNodeBroadcastFromJson(json);

	Map<String, dynamic> toJson() => $MalAnimeNodeBroadcastToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

/// One `related_anime`/`related_manga` entry: relation label plus node.
@JsonSerializable()
class MalAnimeNodeRelated {
	@JSONField(name: 'relation_type')
	late String relationType = '';
	@JSONField(name: 'relation_type_formatted')
	late String relationTypeFormatted = '';
	late MalAnimeNodeRelatedNode node = MalAnimeNodeRelatedNode();

	MalAnimeNodeRelated();

	factory MalAnimeNodeRelated.fromJson(Map<String, dynamic> json) => $MalAnimeNodeRelatedFromJson(json);

	Map<String, dynamic> toJson() => $MalAnimeNodeRelatedToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

/// The reduced node MAL returns inside a relation: list-level keys only, and no
/// `fields=` applies there.
@JsonSerializable()
class MalAnimeNodeRelatedNode {
	late int id = 0;
	late String title = '';
	@JSONField(name: 'main_picture')
	late MalAnimeNodeRelatedNodeMainPicture mainPicture = MalAnimeNodeRelatedNodeMainPicture();
	@JSONField(name: 'start_date')
	late String startDate = '';
	@JSONField(name: 'end_date')
	late String endDate = '';
	late String synopsis = '';
	late double mean = 0;
	@JSONField(name: 'media_type')
	late String mediaType = '';
	late String status = '';
	late String rating = '';
	late String nsfw = '';
	late List<MalAnimeNodeGenres> genres = [];
	@JSONField(name: 'num_episodes')
	late int numEpisodes = 0;
	late int popularity = 0;

	MalAnimeNodeRelatedNode();

	factory MalAnimeNodeRelatedNode.fromJson(Map<String, dynamic> json) => $MalAnimeNodeRelatedNodeFromJson(json);

	Map<String, dynamic> toJson() => $MalAnimeNodeRelatedNodeToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalAnimeNodeRelatedNodeMainPicture {
	late String medium = '';
	late String large = '';

	MalAnimeNodeRelatedNodeMainPicture();

	factory MalAnimeNodeRelatedNodeMainPicture.fromJson(Map<String, dynamic> json) =>
			$MalAnimeNodeRelatedNodeMainPictureFromJson(json);

	Map<String, dynamic> toJson() => $MalAnimeNodeRelatedNodeMainPictureToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

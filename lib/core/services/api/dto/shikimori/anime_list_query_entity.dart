import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/anime_list_query_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/anime_list_query_entity.g.dart';

@JsonSerializable()
class AnimeListQueryEntity {
	late List<AnimeListQueryAnimes> animes = [];

	AnimeListQueryEntity();

	factory AnimeListQueryEntity.fromJson(Map<String, dynamic> json) => $AnimeListQueryEntityFromJson(json);

	Map<String, dynamic> toJson() => $AnimeListQueryEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeListQueryAnimes {
	late String id = '';
	late String malId = '';
	late String name = '';
	late String english = '';
	late String japanese = '';
	late String russian = '';
	late AnimeListQueryAnimesPoster poster = AnimeListQueryAnimesPoster();
	late String description = '';
	late int duration = 0;
	late AnimeListQueryAnimesAiredOn airedOn = AnimeListQueryAnimesAiredOn();
	late AnimeListQueryAnimesReleasedOn releasedOn = AnimeListQueryAnimesReleasedOn();
	late int episodes = 0;
	late int episodesAired = 0;
	late String nextEpisodeAt = '';
	late List<AnimeListQueryAnimesGenres> genres = [];
	late String kind = '';
	late bool isCensored = false;
	late double score = 0.0;
	late String season = '';
	late String status = '';

	AnimeListQueryAnimes();

	factory AnimeListQueryAnimes.fromJson(Map<String, dynamic> json) => $AnimeListQueryAnimesFromJson(json);

	Map<String, dynamic> toJson() => $AnimeListQueryAnimesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeListQueryAnimesPoster {
	late String originalUrl = '';
	late String mainAlt2xUrl = '';

	AnimeListQueryAnimesPoster();

	factory AnimeListQueryAnimesPoster.fromJson(Map<String, dynamic> json) => $AnimeListQueryAnimesPosterFromJson(json);

	Map<String, dynamic> toJson() => $AnimeListQueryAnimesPosterToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeListQueryAnimesAiredOn {
	late String date = '';
	late int day = 0;
	late int month = 0;
	late int year = 0;

	AnimeListQueryAnimesAiredOn();

	factory AnimeListQueryAnimesAiredOn.fromJson(Map<String, dynamic> json) => $AnimeListQueryAnimesAiredOnFromJson(json);

	Map<String, dynamic> toJson() => $AnimeListQueryAnimesAiredOnToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeListQueryAnimesReleasedOn {
	late String date = '';
	late int day = 0;
	late int month = 0;
	late int year = 0;

	AnimeListQueryAnimesReleasedOn();

	factory AnimeListQueryAnimesReleasedOn.fromJson(Map<String, dynamic> json) => $AnimeListQueryAnimesReleasedOnFromJson(json);

	Map<String, dynamic> toJson() => $AnimeListQueryAnimesReleasedOnToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeListQueryAnimesGenres {
	late String id = '';
	late String name = '';
	late String kind = '';
	late String russian = '';

	AnimeListQueryAnimesGenres();

	factory AnimeListQueryAnimesGenres.fromJson(Map<String, dynamic> json) => $AnimeListQueryAnimesGenresFromJson(json);

	Map<String, dynamic> toJson() => $AnimeListQueryAnimesGenresToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
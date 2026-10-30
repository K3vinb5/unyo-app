import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/anime_details_query_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/anime_details_query_entity.g.dart';

@JsonSerializable()
class AnimeDetailsQueryEntity {
	late List<AnimeDetailsQueryAnimes> animes = [];

	AnimeDetailsQueryEntity();

	factory AnimeDetailsQueryEntity.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryEntityFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeDetailsQueryAnimes {
	late String id = '';
	late String malId = '';
	late String name = '';
	late String english = '';
	late String japanese = '';
	late String russian = '';
	late AnimeDetailsQueryAnimesPoster poster = AnimeDetailsQueryAnimesPoster();
	late String description = '';
	late int duration = 0;
	late AnimeDetailsQueryAnimesAiredOn airedOn = AnimeDetailsQueryAnimesAiredOn();
	late AnimeDetailsQueryAnimesReleasedOn releasedOn = AnimeDetailsQueryAnimesReleasedOn();
	late int episodes = 0;
	late int episodesAired = 0;
	late String nextEpisodeAt = '';
	late List<AnimeDetailsQueryAnimesGenres> genres = [];
	late String kind = '';
	late bool isCensored = false;
	late double score = 0.0;
	late String season = '';
	late String status = '';
	late AnimeDetailsQueryAnimesUserRate userRate = AnimeDetailsQueryAnimesUserRate();
	late List<AnimeDetailsQueryAnimesCharacterRoles> characterRoles = [];
	late List<AnimeDetailsQueryAnimesRelated> related = [];

	AnimeDetailsQueryAnimes();

	factory AnimeDetailsQueryAnimes.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryAnimesFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryAnimesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeDetailsQueryAnimesUserRate {
	late String id = '';
	late int episodes = 0;
	late int score = 0;
	late int rewatches = 0;
	late String status = '';
	late String createdAt = '';
	late String updatedAt = '';

	AnimeDetailsQueryAnimesUserRate();

	factory AnimeDetailsQueryAnimesUserRate.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryAnimesUserRateFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryAnimesUserRateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeDetailsQueryAnimesPoster {
	late String originalUrl = '';
	late String mainAlt2xUrl = '';

	AnimeDetailsQueryAnimesPoster();

	factory AnimeDetailsQueryAnimesPoster.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryAnimesPosterFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryAnimesPosterToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeDetailsQueryAnimesAiredOn {
	late String date = '';
	late int day = 0;
	late int month = 0;
	late int year = 0;

	AnimeDetailsQueryAnimesAiredOn();

	factory AnimeDetailsQueryAnimesAiredOn.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryAnimesAiredOnFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryAnimesAiredOnToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeDetailsQueryAnimesReleasedOn {
	late String date = '';
	late int day = 0;
	late int month = 0;
	late int year = 0;

	AnimeDetailsQueryAnimesReleasedOn();

	factory AnimeDetailsQueryAnimesReleasedOn.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryAnimesReleasedOnFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryAnimesReleasedOnToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeDetailsQueryAnimesGenres {
	late String id = '';
	late String name = '';
	late String kind = '';
	late String russian = '';

	AnimeDetailsQueryAnimesGenres();

	factory AnimeDetailsQueryAnimesGenres.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryAnimesGenresFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryAnimesGenresToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeDetailsQueryAnimesCharacterRoles {
	late String id = '';
	late List<String> rolesEn = [];
	late List<String> rolesRu = [];
	late AnimeDetailsQueryAnimesCharacterRolesCharacter character = AnimeDetailsQueryAnimesCharacterRolesCharacter();

	AnimeDetailsQueryAnimesCharacterRoles();

	factory AnimeDetailsQueryAnimesCharacterRoles.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryAnimesCharacterRolesFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryAnimesCharacterRolesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeDetailsQueryAnimesCharacterRolesCharacter {
	late String id = '';
	late String name = '';
	late AnimeDetailsQueryAnimesCharacterRolesCharacterPoster poster = AnimeDetailsQueryAnimesCharacterRolesCharacterPoster();

	AnimeDetailsQueryAnimesCharacterRolesCharacter();

	factory AnimeDetailsQueryAnimesCharacterRolesCharacter.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryAnimesCharacterRolesCharacterFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryAnimesCharacterRolesCharacterToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeDetailsQueryAnimesCharacterRolesCharacterPoster {
	late String originalUrl = '';

	AnimeDetailsQueryAnimesCharacterRolesCharacterPoster();

	factory AnimeDetailsQueryAnimesCharacterRolesCharacterPoster.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryAnimesCharacterRolesCharacterPosterFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryAnimesCharacterRolesCharacterPosterToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeDetailsQueryAnimesRelated {
	late String relationKind = '';
	late String relationText = '';
	late AnimeDetailsQueryAnimesRelatedAnime anime = AnimeDetailsQueryAnimesRelatedAnime();

	AnimeDetailsQueryAnimesRelated();

	factory AnimeDetailsQueryAnimesRelated.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryAnimesRelatedFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryAnimesRelatedToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeDetailsQueryAnimesRelatedAnime {
	late String id = '';
	late String malId = '';
	late String name = '';
	late String english = '';
	late String japanese = '';
	late String russian = '';
	late AnimeDetailsQueryAnimesRelatedAnimePoster poster = AnimeDetailsQueryAnimesRelatedAnimePoster();
	late String description = '';
	late int duration = 0;
	late AnimeDetailsQueryAnimesRelatedAnimeAiredOn airedOn = AnimeDetailsQueryAnimesRelatedAnimeAiredOn();
	late AnimeDetailsQueryAnimesRelatedAnimeReleasedOn releasedOn = AnimeDetailsQueryAnimesRelatedAnimeReleasedOn();
	late int episodes = 0;
	late int episodesAired = 0;
	late String nextEpisodeAt = '';
	late List<AnimeDetailsQueryAnimesRelatedAnimeGenres> genres = [];
	late String kind = '';
	late bool isCensored = false;
	late double score = 0.0;
	late String season = '';
	late String status = '';

	AnimeDetailsQueryAnimesRelatedAnime();

	factory AnimeDetailsQueryAnimesRelatedAnime.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryAnimesRelatedAnimeFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryAnimesRelatedAnimeToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeDetailsQueryAnimesRelatedAnimePoster {
	late String originalUrl = '';
	late String mainAlt2xUrl = '';

	AnimeDetailsQueryAnimesRelatedAnimePoster();

	factory AnimeDetailsQueryAnimesRelatedAnimePoster.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryAnimesRelatedAnimePosterFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryAnimesRelatedAnimePosterToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeDetailsQueryAnimesRelatedAnimeAiredOn {
	late String date = '';
	late int day = 0;
	late int month = 0;
	late int year = 0;

	AnimeDetailsQueryAnimesRelatedAnimeAiredOn();

	factory AnimeDetailsQueryAnimesRelatedAnimeAiredOn.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryAnimesRelatedAnimeAiredOnFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryAnimesRelatedAnimeAiredOnToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeDetailsQueryAnimesRelatedAnimeReleasedOn {
	late String date = '';
	late int day = 0;
	late int month = 0;
	late int year = 0;

	AnimeDetailsQueryAnimesRelatedAnimeReleasedOn();

	factory AnimeDetailsQueryAnimesRelatedAnimeReleasedOn.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryAnimesRelatedAnimeReleasedOnFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryAnimesRelatedAnimeReleasedOnToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnimeDetailsQueryAnimesRelatedAnimeGenres {
	late String id = '';
	late String name = '';
	late String kind = '';
	late String russian = '';

	AnimeDetailsQueryAnimesRelatedAnimeGenres();

	factory AnimeDetailsQueryAnimesRelatedAnimeGenres.fromJson(Map<String, dynamic> json) => $AnimeDetailsQueryAnimesRelatedAnimeGenresFromJson(json);

	Map<String, dynamic> toJson() => $AnimeDetailsQueryAnimesRelatedAnimeGenresToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
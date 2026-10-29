import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/manga_details_query_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/manga_details_query_entity.g.dart';

@JsonSerializable()
class MangaDetailsQueryEntity {
	late List<MangaDetailsQueryMangas> mangas = [];

	MangaDetailsQueryEntity();

	factory MangaDetailsQueryEntity.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryEntityFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangas {
	late String id = '';
	late String malId = '';
	late String name = '';
	late String english = '';
	late String japanese = '';
	late String russian = '';
	late MangaDetailsQueryMangasPoster poster = MangaDetailsQueryMangasPoster();
	late String description = '';
	late MangaDetailsQueryMangasAiredOn airedOn = MangaDetailsQueryMangasAiredOn();
	late MangaDetailsQueryMangasReleasedOn releasedOn = MangaDetailsQueryMangasReleasedOn();
	late int volumes = 0;
	late int chapters = 0;
	late List<MangaDetailsQueryMangasGenres> genres = [];
	late String kind = '';
	late bool isCensored = false;
	late double score = 0.0;
	late String status = '';
	late List<MangaDetailsQueryMangasPublishers> publishers = [];
	late MangaDetailsQueryMangasUserRate userRate = MangaDetailsQueryMangasUserRate();
	late List<MangaDetailsQueryMangasCharacterRoles> characterRoles = [];
	late List<MangaDetailsQueryMangasRelated> related = [];

	MangaDetailsQueryMangas();

	factory MangaDetailsQueryMangas.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangasUserRate {
	late String id = '';
	late int episodes = 0;
	late int score = 0;
	late int rewatches = 0;
	late String status = '';
	late String createdAt = '';
	late String updatedAt = '';

	MangaDetailsQueryMangasUserRate();

	factory MangaDetailsQueryMangasUserRate.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasUserRateFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasUserRateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangasPoster {
	late String originalUrl = '';
	late String mainAlt2xUrl = '';

	MangaDetailsQueryMangasPoster();

	factory MangaDetailsQueryMangasPoster.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasPosterFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasPosterToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangasAiredOn {
	late String date = '';
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MangaDetailsQueryMangasAiredOn();

	factory MangaDetailsQueryMangasAiredOn.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasAiredOnFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasAiredOnToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangasReleasedOn {
	late String date = '';
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MangaDetailsQueryMangasReleasedOn();

	factory MangaDetailsQueryMangasReleasedOn.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasReleasedOnFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasReleasedOnToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangasGenres {
	late String id = '';
	late String name = '';
	late String kind = '';
	late String russian = '';

	MangaDetailsQueryMangasGenres();

	factory MangaDetailsQueryMangasGenres.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasGenresFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasGenresToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangasPublishers {
	late String id = '';
	late String name = '';

	MangaDetailsQueryMangasPublishers();

	factory MangaDetailsQueryMangasPublishers.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasPublishersFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasPublishersToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangasCharacterRoles {
	late String id = '';
	late List<String> rolesEn = [];
	late List<String> rolesRu = [];
	late MangaDetailsQueryMangasCharacterRolesCharacter character = MangaDetailsQueryMangasCharacterRolesCharacter();

	MangaDetailsQueryMangasCharacterRoles();

	factory MangaDetailsQueryMangasCharacterRoles.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasCharacterRolesFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasCharacterRolesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangasCharacterRolesCharacter {
	late String id = '';
	late String name = '';
	late MangaDetailsQueryMangasCharacterRolesCharacterPoster poster = MangaDetailsQueryMangasCharacterRolesCharacterPoster();

	MangaDetailsQueryMangasCharacterRolesCharacter();

	factory MangaDetailsQueryMangasCharacterRolesCharacter.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasCharacterRolesCharacterFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasCharacterRolesCharacterToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangasCharacterRolesCharacterPoster {
	late String originalUrl = '';

	MangaDetailsQueryMangasCharacterRolesCharacterPoster();

	factory MangaDetailsQueryMangasCharacterRolesCharacterPoster.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasCharacterRolesCharacterPosterFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasCharacterRolesCharacterPosterToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangasRelated {
	late String relationKind = '';
	late String relationText = '';
	late MangaDetailsQueryMangasRelatedManga manga = MangaDetailsQueryMangasRelatedManga();

	MangaDetailsQueryMangasRelated();

	factory MangaDetailsQueryMangasRelated.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasRelatedFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasRelatedToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangasRelatedManga {
	late String id = '';
	late String malId = '';
	late String name = '';
	late String english = '';
	late String japanese = '';
	late String russian = '';
	late MangaDetailsQueryMangasRelatedMangaPoster poster = MangaDetailsQueryMangasRelatedMangaPoster();
	late String description = '';
	late MangaDetailsQueryMangasRelatedMangaAiredOn airedOn = MangaDetailsQueryMangasRelatedMangaAiredOn();
	late MangaDetailsQueryMangasRelatedMangaReleasedOn releasedOn = MangaDetailsQueryMangasRelatedMangaReleasedOn();
	late int volumes = 0;
	late int chapters = 0;
	late List<MangaDetailsQueryMangasRelatedMangaGenres> genres = [];
	late String kind = '';
	late bool isCensored = false;
	late double score = 0.0;
	late String status = '';

	MangaDetailsQueryMangasRelatedManga();

	factory MangaDetailsQueryMangasRelatedManga.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasRelatedMangaFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasRelatedMangaToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangasRelatedMangaPoster {
	late String originalUrl = '';
	late String mainAlt2xUrl = '';

	MangaDetailsQueryMangasRelatedMangaPoster();

	factory MangaDetailsQueryMangasRelatedMangaPoster.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasRelatedMangaPosterFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasRelatedMangaPosterToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangasRelatedMangaAiredOn {
	late String date = '';
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MangaDetailsQueryMangasRelatedMangaAiredOn();

	factory MangaDetailsQueryMangasRelatedMangaAiredOn.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasRelatedMangaAiredOnFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasRelatedMangaAiredOnToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangasRelatedMangaReleasedOn {
	late String date = '';
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MangaDetailsQueryMangasRelatedMangaReleasedOn();

	factory MangaDetailsQueryMangasRelatedMangaReleasedOn.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasRelatedMangaReleasedOnFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasRelatedMangaReleasedOnToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaDetailsQueryMangasRelatedMangaGenres {
	late String id = '';
	late String name = '';
	late String kind = '';
	late String russian = '';

	MangaDetailsQueryMangasRelatedMangaGenres();

	factory MangaDetailsQueryMangasRelatedMangaGenres.fromJson(Map<String, dynamic> json) => $MangaDetailsQueryMangasRelatedMangaGenresFromJson(json);

	Map<String, dynamic> toJson() => $MangaDetailsQueryMangasRelatedMangaGenresToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
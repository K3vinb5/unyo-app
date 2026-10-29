import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/manga_list_query_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/manga_list_query_entity.g.dart';

@JsonSerializable()
class MangaListQueryEntity {
	late List<MangaListQueryMangas> mangas = [];

	MangaListQueryEntity();

	factory MangaListQueryEntity.fromJson(Map<String, dynamic> json) => $MangaListQueryEntityFromJson(json);

	Map<String, dynamic> toJson() => $MangaListQueryEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaListQueryMangas {
	late String id = '';
	late String malId = '';
	late String name = '';
	late String english = '';
	late String japanese = '';
	late String russian = '';
	late MangaListQueryMangasPoster poster = MangaListQueryMangasPoster();
	late String description = '';
	late MangaListQueryMangasAiredOn airedOn = MangaListQueryMangasAiredOn();
	late MangaListQueryMangasReleasedOn releasedOn = MangaListQueryMangasReleasedOn();
	late int volumes = 0;
	late int chapters = 0;
	late List<MangaListQueryMangasGenres> genres = [];
	late String kind = '';
	late bool isCensored = false;
	late double score = 0.0;
	late String status = '';
	late List<MangaListQueryMangasPublishers> publishers = [];

	MangaListQueryMangas();

	factory MangaListQueryMangas.fromJson(Map<String, dynamic> json) => $MangaListQueryMangasFromJson(json);

	Map<String, dynamic> toJson() => $MangaListQueryMangasToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaListQueryMangasPoster {
	late String originalUrl = '';
	late String mainAlt2xUrl = '';

	MangaListQueryMangasPoster();

	factory MangaListQueryMangasPoster.fromJson(Map<String, dynamic> json) => $MangaListQueryMangasPosterFromJson(json);

	Map<String, dynamic> toJson() => $MangaListQueryMangasPosterToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaListQueryMangasAiredOn {
	late String date = '';
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MangaListQueryMangasAiredOn();

	factory MangaListQueryMangasAiredOn.fromJson(Map<String, dynamic> json) => $MangaListQueryMangasAiredOnFromJson(json);

	Map<String, dynamic> toJson() => $MangaListQueryMangasAiredOnToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaListQueryMangasReleasedOn {
	late String date = '';
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MangaListQueryMangasReleasedOn();

	factory MangaListQueryMangasReleasedOn.fromJson(Map<String, dynamic> json) => $MangaListQueryMangasReleasedOnFromJson(json);

	Map<String, dynamic> toJson() => $MangaListQueryMangasReleasedOnToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaListQueryMangasGenres {
	late String id = '';
	late String name = '';
	late String kind = '';
	late String russian = '';

	MangaListQueryMangasGenres();

	factory MangaListQueryMangasGenres.fromJson(Map<String, dynamic> json) => $MangaListQueryMangasGenresFromJson(json);

	Map<String, dynamic> toJson() => $MangaListQueryMangasGenresToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MangaListQueryMangasPublishers {
	late String id = '';
	late String name = '';

	MangaListQueryMangasPublishers();

	factory MangaListQueryMangasPublishers.fromJson(Map<String, dynamic> json) => $MangaListQueryMangasPublishersFromJson(json);

	Map<String, dynamic> toJson() => $MangaListQueryMangasPublishersToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
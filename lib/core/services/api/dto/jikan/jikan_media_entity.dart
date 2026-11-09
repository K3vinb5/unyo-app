import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/jikan_media_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/jikan_media_entity.g.dart';

/// Jikan v4 wire shape (served by Tenrai by default; a self-hosted Jikan is
/// compatible).
///
/// `GET <jikanBaseEndpoint>/anime` and `/manga` (WP #166). MAL v2's `/anime` and
/// `/manga` accept only `q` (required), paging and `fields` — no
/// status/type/genre/sort filter — so the catalog feeds and advanced search
/// are served from the Jikan v4 API, which does filter and order (SPEC §2).
/// Read-only, anonymous, and trimmed to the fields the
/// [MalAnimeModel]/[MalMangaModel] Jikan factories fill.
///
/// Both spaces share this shape: the anime node carries `episodes`, `aired`,
/// `rating`, `duration` and `season`; the manga node carries `chapters`,
/// `volumes` and `published` instead, and every field that is absent on a node
/// keeps its default, so one entity parses both.
@JsonSerializable()
class JikanMediaListEntity {
	late List<JikanMediaData> data = [];
	late JikanMediaPagination pagination = JikanMediaPagination();

	JikanMediaListEntity();

	factory JikanMediaListEntity.fromJson(Map<String, dynamic> json) => $JikanMediaListEntityFromJson(json);

	Map<String, dynamic> toJson() => $JikanMediaListEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class JikanMediaData {
	@JSONField(name: 'mal_id')
	late int malId = 0;
	late String title = '';
	@JSONField(name: 'title_english')
	late String titleEnglish = '';
	@JSONField(name: 'title_japanese')
	late String titleJapanese = '';
	late String type = '';
	late String status = '';
	late String synopsis = '';
	late double score = 0;
	late String rating = '';
	late int episodes = 0;
	late int chapters = 0;
	late int volumes = 0;
	late String duration = '';
	late String season = '';
	late int year = 0;
	late int popularity = 0;
	late int members = 0;
	late JikanMediaDataImages images = JikanMediaDataImages();
	late JikanMediaDataAired aired = JikanMediaDataAired();
	late JikanMediaDataAired published = JikanMediaDataAired();
	late List<JikanMediaDataGenre> genres = [];
	/// Jikan moved adult genres out of `genres`: they arrive here instead, so
	/// the adult marker must read both lists.
	@JSONField(name: 'explicit_genres')
	late List<JikanMediaDataGenre> explicitGenres = [];

	JikanMediaData();

	factory JikanMediaData.fromJson(Map<String, dynamic> json) => $JikanMediaDataFromJson(json);

	Map<String, dynamic> toJson() => $JikanMediaDataToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class JikanMediaDataImages {
	late JikanMediaDataImagesJpg jpg = JikanMediaDataImagesJpg();

	JikanMediaDataImages();

	factory JikanMediaDataImages.fromJson(Map<String, dynamic> json) => $JikanMediaDataImagesFromJson(json);

	Map<String, dynamic> toJson() => $JikanMediaDataImagesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class JikanMediaDataImagesJpg {
	@JSONField(name: 'image_url')
	late String imageUrl = '';
	@JSONField(name: 'small_image_url')
	late String smallImageUrl = '';
	@JSONField(name: 'large_image_url')
	late String largeImageUrl = '';

	JikanMediaDataImagesJpg();

	factory JikanMediaDataImagesJpg.fromJson(Map<String, dynamic> json) => $JikanMediaDataImagesJpgFromJson(json);

	Map<String, dynamic> toJson() => $JikanMediaDataImagesJpgToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

/// Airing range (anime `aired`) and publishing range (manga `published`).
@JsonSerializable()
class JikanMediaDataAired {
	late String from = '';
	late String to = '';

	JikanMediaDataAired();

	factory JikanMediaDataAired.fromJson(Map<String, dynamic> json) => $JikanMediaDataAiredFromJson(json);

	Map<String, dynamic> toJson() => $JikanMediaDataAiredToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class JikanMediaDataGenre {
	@JSONField(name: 'mal_id')
	late int malId = 0;
	late String name = '';

	JikanMediaDataGenre();

	factory JikanMediaDataGenre.fromJson(Map<String, dynamic> json) => $JikanMediaDataGenreFromJson(json);

	Map<String, dynamic> toJson() => $JikanMediaDataGenreToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class JikanMediaPagination {
	@JSONField(name: 'last_visible_page')
	late int lastVisiblePage = 0;
	@JSONField(name: 'has_next_page')
	late bool hasNextPage = false;
	@JSONField(name: 'current_page')
	late int currentPage = 0;
	late JikanMediaPaginationItems items = JikanMediaPaginationItems();

	JikanMediaPagination();

	factory JikanMediaPagination.fromJson(Map<String, dynamic> json) => $JikanMediaPaginationFromJson(json);

	Map<String, dynamic> toJson() => $JikanMediaPaginationToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class JikanMediaPaginationItems {
	late int count = 0;
	late int total = 0;
	@JSONField(name: 'per_page')
	late int perPage = 0;

	JikanMediaPaginationItems();

	factory JikanMediaPaginationItems.fromJson(Map<String, dynamic> json) => $JikanMediaPaginationItemsFromJson(json);

	Map<String, dynamic> toJson() => $JikanMediaPaginationItemsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

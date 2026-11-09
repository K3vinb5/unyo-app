import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/jikan_schedule_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/jikan_schedule_entity.g.dart';

/// `GET https://api.jikan.moe/v4/schedules` (WP #166, calendar only).
///
/// Jikan is a third-party mirror of MyAnimeList. MAL v2 has no schedule
/// endpoint; since the amended SPEC §2 map Jikan also serves the catalog feeds
/// and the advanced search (`JikanMediaListEntity`), all of it under one
/// `JikanRateLimiter` (60/min, 429 = throttle). Read-only, anonymous, and the
/// node is trimmed to what a calendar card needs.
@JsonSerializable()
class JikanScheduleEntity {
	late List<JikanScheduleData> data = [];
	late JikanSchedulePagination pagination = JikanSchedulePagination();

	JikanScheduleEntity();

	factory JikanScheduleEntity.fromJson(Map<String, dynamic> json) => $JikanScheduleEntityFromJson(json);

	Map<String, dynamic> toJson() => $JikanScheduleEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class JikanScheduleData {
	@JSONField(name: 'mal_id')
	late int malId = 0;
	late String title = '';
	late String type = '';
	late int episodes = 0;
	late String status = '';
	late double score = 0;
	late String rating = '';
	late bool airing = false;
	late String synopsis = '';
	late JikanScheduleDataImages images = JikanScheduleDataImages();
	late JikanScheduleDataBroadcast broadcast = JikanScheduleDataBroadcast();
	late JikanScheduleDataAired aired = JikanScheduleDataAired();

	JikanScheduleData();

	factory JikanScheduleData.fromJson(Map<String, dynamic> json) => $JikanScheduleDataFromJson(json);

	Map<String, dynamic> toJson() => $JikanScheduleDataToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class JikanScheduleDataImages {
	late JikanScheduleDataImagesJpg jpg = JikanScheduleDataImagesJpg();

	JikanScheduleDataImages();

	factory JikanScheduleDataImages.fromJson(Map<String, dynamic> json) => $JikanScheduleDataImagesFromJson(json);

	Map<String, dynamic> toJson() => $JikanScheduleDataImagesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class JikanScheduleDataImagesJpg {
	@JSONField(name: 'image_url')
	late String imageUrl = '';
	@JSONField(name: 'small_image_url')
	late String smallImageUrl = '';
	@JSONField(name: 'large_image_url')
	late String largeImageUrl = '';

	JikanScheduleDataImagesJpg();

	factory JikanScheduleDataImagesJpg.fromJson(Map<String, dynamic> json) => $JikanScheduleDataImagesJpgFromJson(json);

	Map<String, dynamic> toJson() => $JikanScheduleDataImagesJpgToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class JikanScheduleDataBroadcast {
	late String day = '';
	late String time = '';
	late String string = '';

	JikanScheduleDataBroadcast();

	factory JikanScheduleDataBroadcast.fromJson(Map<String, dynamic> json) => $JikanScheduleDataBroadcastFromJson(json);

	Map<String, dynamic> toJson() => $JikanScheduleDataBroadcastToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class JikanScheduleDataAired {
	late String from = '';

	JikanScheduleDataAired();

	factory JikanScheduleDataAired.fromJson(Map<String, dynamic> json) => $JikanScheduleDataAiredFromJson(json);

	Map<String, dynamic> toJson() => $JikanScheduleDataAiredToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class JikanSchedulePagination {
	@JSONField(name: 'last_visible_page')
	late int lastVisiblePage = 0;
	@JSONField(name: 'has_next_page')
	late bool hasNextPage = false;

	JikanSchedulePagination();

	factory JikanSchedulePagination.fromJson(Map<String, dynamic> json) => $JikanSchedulePaginationFromJson(json);

	Map<String, dynamic> toJson() => $JikanSchedulePaginationToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

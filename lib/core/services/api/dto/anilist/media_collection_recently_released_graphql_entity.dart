import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/media_collection_recently_released_graphql_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/media_collection_recently_released_graphql_entity.g.dart';

@JsonSerializable()
class MediaCollectionRecentlyReleasedGraphqlEntity {
	@JSONField(name: "Page")
	late MediaCollectionRecentlyReleasedGraphqlDtoPage page = MediaCollectionRecentlyReleasedGraphqlDtoPage();

	MediaCollectionRecentlyReleasedGraphqlEntity();

	factory MediaCollectionRecentlyReleasedGraphqlEntity.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyReleasedGraphqlEntityFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyReleasedGraphqlEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionRecentlyReleasedGraphqlDtoPage {
	late List<MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules> airingSchedules = [];

	MediaCollectionRecentlyReleasedGraphqlDtoPage();

	factory MediaCollectionRecentlyReleasedGraphqlDtoPage.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyReleasedGraphqlDtoPageFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyReleasedGraphqlDtoPageToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules {
	late MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia media = MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia();

	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules();

	factory MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia {
	late MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode nextAiringEpisode = MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode();
	late String status = '';
	late bool isFavourite = false;
	late String season = '';
	late int id = 0;
	late int idMal = 0;
	late bool isAdult = false;
	late int meanScore = 0;
	late int popularity = 0;
	late List<String> genres = [];
	late String format = '';
	late int episodes = 0;
	late MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate endDate = MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate();
	late MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate startDate = MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate();
	late int duration = 0;
	late String description = '';
	late MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage coverImage = MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage();
	late String countryOfOrigin = '';
	late int chapters = 0;
	late String bannerImage = '';
	late int averageScore = 0;
	late MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle title = MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle();

	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia();

	factory MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode {
	late int episode = 0;
	late int airingAt = 0;

	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode();

	factory MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisodeFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisodeToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate {
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate();

	factory MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDateFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate {
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate();

	factory MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDateFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage {
	late String large = '';

	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage();

	factory MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImageFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImageToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle {
	late String english = '';
	late String native = '';
	late String romaji = '';
	late String userPreferred = '';

	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle();

	factory MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitleFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitleToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
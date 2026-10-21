import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/media_collection_upcoming_graphql_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/media_collection_upcoming_graphql_entity.g.dart';

@JsonSerializable()
class MediaCollectionUpcomingGraphqlEntity {
	@JSONField(name: "Page")
	late MediaCollectionUpcomingGraphqlDtoPage page = MediaCollectionUpcomingGraphqlDtoPage();

	MediaCollectionUpcomingGraphqlEntity();

	factory MediaCollectionUpcomingGraphqlEntity.fromJson(Map<String, dynamic> json) => $MediaCollectionUpcomingGraphqlEntityFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionUpcomingGraphqlEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionUpcomingGraphqlDtoPage {
	late List<MediaCollectionUpcomingGraphqlDtoPageMedia> media = [];

	MediaCollectionUpcomingGraphqlDtoPage();

	factory MediaCollectionUpcomingGraphqlDtoPage.fromJson(Map<String, dynamic> json) => $MediaCollectionUpcomingGraphqlDtoPageFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionUpcomingGraphqlDtoPageToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionUpcomingGraphqlDtoPageMedia {
	late MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode nextAiringEpisode = MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode();
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
	late MediaCollectionUpcomingGraphqlDtoPageMediaEndDate endDate = MediaCollectionUpcomingGraphqlDtoPageMediaEndDate();
	late MediaCollectionUpcomingGraphqlDtoPageMediaStartDate startDate = MediaCollectionUpcomingGraphqlDtoPageMediaStartDate();
	late int duration = 0;
	late String description = '';
	late MediaCollectionUpcomingGraphqlDtoPageMediaCoverImage coverImage = MediaCollectionUpcomingGraphqlDtoPageMediaCoverImage();
	late String countryOfOrigin = '';
	late int chapters = 0;
	late String bannerImage = '';
	late int averageScore = 0;
	late MediaCollectionUpcomingGraphqlDtoPageMediaTitle title = MediaCollectionUpcomingGraphqlDtoPageMediaTitle();

	MediaCollectionUpcomingGraphqlDtoPageMedia();

	factory MediaCollectionUpcomingGraphqlDtoPageMedia.fromJson(Map<String, dynamic> json) => $MediaCollectionUpcomingGraphqlDtoPageMediaFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionUpcomingGraphqlDtoPageMediaToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode {
	late int episode = 0;
	late int airingAt = 0;

	MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode();

	factory MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode.fromJson(Map<String, dynamic> json) => $MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisodeFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisodeToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionUpcomingGraphqlDtoPageMediaEndDate {
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MediaCollectionUpcomingGraphqlDtoPageMediaEndDate();

	factory MediaCollectionUpcomingGraphqlDtoPageMediaEndDate.fromJson(Map<String, dynamic> json) => $MediaCollectionUpcomingGraphqlDtoPageMediaEndDateFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionUpcomingGraphqlDtoPageMediaEndDateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionUpcomingGraphqlDtoPageMediaStartDate {
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MediaCollectionUpcomingGraphqlDtoPageMediaStartDate();

	factory MediaCollectionUpcomingGraphqlDtoPageMediaStartDate.fromJson(Map<String, dynamic> json) => $MediaCollectionUpcomingGraphqlDtoPageMediaStartDateFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionUpcomingGraphqlDtoPageMediaStartDateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionUpcomingGraphqlDtoPageMediaCoverImage {
	late String large = '';

	MediaCollectionUpcomingGraphqlDtoPageMediaCoverImage();

	factory MediaCollectionUpcomingGraphqlDtoPageMediaCoverImage.fromJson(Map<String, dynamic> json) => $MediaCollectionUpcomingGraphqlDtoPageMediaCoverImageFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionUpcomingGraphqlDtoPageMediaCoverImageToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionUpcomingGraphqlDtoPageMediaTitle {
	late String english = '';
	late String native = '';
	late String romaji = '';
	late String userPreferred = '';

	MediaCollectionUpcomingGraphqlDtoPageMediaTitle();

	factory MediaCollectionUpcomingGraphqlDtoPageMediaTitle.fromJson(Map<String, dynamic> json) => $MediaCollectionUpcomingGraphqlDtoPageMediaTitleFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionUpcomingGraphqlDtoPageMediaTitleToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
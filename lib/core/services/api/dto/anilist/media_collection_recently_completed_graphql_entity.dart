import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/media_collection_recently_completed_graphql_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/media_collection_recently_completed_graphql_entity.g.dart';

@JsonSerializable()
class MediaCollectionRecentlyCompletedGraphqlEntity {
	@JSONField(name: "Page")
	late MediaCollectionRecentlyCompletedGraphqlDtoPage page = MediaCollectionRecentlyCompletedGraphqlDtoPage();

	MediaCollectionRecentlyCompletedGraphqlEntity();

	factory MediaCollectionRecentlyCompletedGraphqlEntity.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyCompletedGraphqlEntityFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyCompletedGraphqlEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionRecentlyCompletedGraphqlDtoPage {
	late List<MediaCollectionRecentlyCompletedGraphqlDtoPageMedia> media = [];

	MediaCollectionRecentlyCompletedGraphqlDtoPage();

	factory MediaCollectionRecentlyCompletedGraphqlDtoPage.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyCompletedGraphqlDtoPageFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyCompletedGraphqlDtoPageToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionRecentlyCompletedGraphqlDtoPageMedia {
	dynamic nextAiringEpisode;
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
	late MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate endDate = MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate();
	late MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate startDate = MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate();
	late int duration = 0;
	late String description = '';
	late MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage coverImage = MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage();
	late String countryOfOrigin = '';
	late int chapters = 0;
	late String bannerImage = '';
	late int averageScore = 0;
	late MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle title = MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle();

	MediaCollectionRecentlyCompletedGraphqlDtoPageMedia();

	factory MediaCollectionRecentlyCompletedGraphqlDtoPageMedia.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate {
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate();

	factory MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDateFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate {
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate();

	factory MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDateFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage {
	late String large = '';

	MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage();

	factory MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImageFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImageToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle {
	late String english = '';
	late String native = '';
	late String romaji = '';
	late String userPreferred = '';

	MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle();

	factory MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle.fromJson(Map<String, dynamic> json) => $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitleFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitleToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
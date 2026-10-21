import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/media_advanced_search_query_graphql_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/media_advanced_search_query_graphql_entity.g.dart';

@JsonSerializable()
class MediaAdvancedSearchQueryGraphqlEntity {
	@JSONField(name: "Page")
	late MediaAdvancedSearchQueryGraphqlPage page = MediaAdvancedSearchQueryGraphqlPage();

	MediaAdvancedSearchQueryGraphqlEntity();

	factory MediaAdvancedSearchQueryGraphqlEntity.fromJson(Map<String, dynamic> json) => $MediaAdvancedSearchQueryGraphqlEntityFromJson(json);

	Map<String, dynamic> toJson() => $MediaAdvancedSearchQueryGraphqlEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaAdvancedSearchQueryGraphqlPage {
	late List<MediaAdvancedSearchQueryGraphqlPageMedia> media = [];

	MediaAdvancedSearchQueryGraphqlPage();

	factory MediaAdvancedSearchQueryGraphqlPage.fromJson(Map<String, dynamic> json) => $MediaAdvancedSearchQueryGraphqlPageFromJson(json);

	Map<String, dynamic> toJson() => $MediaAdvancedSearchQueryGraphqlPageToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaAdvancedSearchQueryGraphqlPageMedia {
	late int id = 0;
	late int idMal = 0;
	late MediaAdvancedSearchQueryGraphqlPageMediaTitle title = MediaAdvancedSearchQueryGraphqlPageMediaTitle();
	late int averageScore = 0;
	late String bannerImage = '';
	late int chapters = 0;
	late String countryOfOrigin = '';
	late MediaAdvancedSearchQueryGraphqlPageMediaCoverImage coverImage = MediaAdvancedSearchQueryGraphqlPageMediaCoverImage();
	late String description = '';
	late int duration = 0;
	late MediaAdvancedSearchQueryGraphqlPageMediaEndDate endDate = MediaAdvancedSearchQueryGraphqlPageMediaEndDate();
	late MediaAdvancedSearchQueryGraphqlPageMediaStartDate startDate = MediaAdvancedSearchQueryGraphqlPageMediaStartDate();
	late int episodes = 0;
	late List<String> genres = [];
	late String format = '';
	late bool isAdult = false;
	late int popularity = 0;
	late int meanScore = 0;
	late String season = '';
	late bool isFavourite = false;
	late MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode nextAiringEpisode = MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode();
	late String status = '';

	MediaAdvancedSearchQueryGraphqlPageMedia();

	factory MediaAdvancedSearchQueryGraphqlPageMedia.fromJson(Map<String, dynamic> json) => $MediaAdvancedSearchQueryGraphqlPageMediaFromJson(json);

	Map<String, dynamic> toJson() => $MediaAdvancedSearchQueryGraphqlPageMediaToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaAdvancedSearchQueryGraphqlPageMediaTitle {
	late String english = '';
	late String native = '';
	late String romaji = '';
	late String userPreferred = '';

	MediaAdvancedSearchQueryGraphqlPageMediaTitle();

	factory MediaAdvancedSearchQueryGraphqlPageMediaTitle.fromJson(Map<String, dynamic> json) => $MediaAdvancedSearchQueryGraphqlPageMediaTitleFromJson(json);

	Map<String, dynamic> toJson() => $MediaAdvancedSearchQueryGraphqlPageMediaTitleToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaAdvancedSearchQueryGraphqlPageMediaCoverImage {
	late String large = '';

	MediaAdvancedSearchQueryGraphqlPageMediaCoverImage();

	factory MediaAdvancedSearchQueryGraphqlPageMediaCoverImage.fromJson(Map<String, dynamic> json) => $MediaAdvancedSearchQueryGraphqlPageMediaCoverImageFromJson(json);

	Map<String, dynamic> toJson() => $MediaAdvancedSearchQueryGraphqlPageMediaCoverImageToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaAdvancedSearchQueryGraphqlPageMediaEndDate {
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MediaAdvancedSearchQueryGraphqlPageMediaEndDate();

	factory MediaAdvancedSearchQueryGraphqlPageMediaEndDate.fromJson(Map<String, dynamic> json) => $MediaAdvancedSearchQueryGraphqlPageMediaEndDateFromJson(json);

	Map<String, dynamic> toJson() => $MediaAdvancedSearchQueryGraphqlPageMediaEndDateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaAdvancedSearchQueryGraphqlPageMediaStartDate {
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MediaAdvancedSearchQueryGraphqlPageMediaStartDate();

	factory MediaAdvancedSearchQueryGraphqlPageMediaStartDate.fromJson(Map<String, dynamic> json) => $MediaAdvancedSearchQueryGraphqlPageMediaStartDateFromJson(json);

	Map<String, dynamic> toJson() => $MediaAdvancedSearchQueryGraphqlPageMediaStartDateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode {
	late int episode = 0;
	late int airingAt = 0;

	MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode();

	factory MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode.fromJson(Map<String, dynamic> json) => $MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisodeFromJson(json);

	Map<String, dynamic> toJson() => $MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisodeToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
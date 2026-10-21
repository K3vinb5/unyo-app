import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/media_collection_trendingOrPopular_graphql_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/media_collection_trendingOrPopular_graphql_entity.g.dart';

@JsonSerializable()
class MediaCollectionTrendingOrPopularGraphqlEntity {
	@JSONField(name: "Page")
	late MediaCollectionTrendingOrPopularGraphqlDtoPage page = MediaCollectionTrendingOrPopularGraphqlDtoPage();

	MediaCollectionTrendingOrPopularGraphqlEntity();

	factory MediaCollectionTrendingOrPopularGraphqlEntity.fromJson(Map<String, dynamic> json) => $MediaCollectionTrendingOrPopularGraphqlEntityFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionTrendingOrPopularGraphqlEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionTrendingOrPopularGraphqlDtoPage {
	late List<MediaCollectionTrendingOrPopularGraphqlDtoPageMedia> media = [];

	MediaCollectionTrendingOrPopularGraphqlDtoPage();

	factory MediaCollectionTrendingOrPopularGraphqlDtoPage.fromJson(Map<String, dynamic> json) => $MediaCollectionTrendingOrPopularGraphqlDtoPageFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionTrendingOrPopularGraphqlDtoPageToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionTrendingOrPopularGraphqlDtoPageMedia {
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
	late MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate endDate = MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate();
	late MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate startDate = MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate();
	late int duration = 0;
	late String description = '';
	late MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage coverImage = MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage();
	late String countryOfOrigin = '';
	late int chapters = 0;
	late String bannerImage = '';
	late int averageScore = 0;
	late MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle title = MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle();

	MediaCollectionTrendingOrPopularGraphqlDtoPageMedia();

	factory MediaCollectionTrendingOrPopularGraphqlDtoPageMedia.fromJson(Map<String, dynamic> json) => $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate {
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate();

	factory MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate.fromJson(Map<String, dynamic> json) => $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDateFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate {
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate();

	factory MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate.fromJson(Map<String, dynamic> json) => $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDateFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage {
	late String large = '';

	MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage();

	factory MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage.fromJson(Map<String, dynamic> json) => $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImageFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImageToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle {
	late String english = '';
	late String native = '';
	late String romaji = '';
	late String userPreferred = '';

	MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle();

	factory MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle.fromJson(Map<String, dynamic> json) => $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitleFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitleToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
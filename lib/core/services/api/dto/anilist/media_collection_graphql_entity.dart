import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/media_collection_graphql_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/media_collection_graphql_entity.g.dart';

@JsonSerializable()
class MediaCollectionGraphqlEntity {
	late MediaCollectionGraphqlDtoData data = MediaCollectionGraphqlDtoData();

	MediaCollectionGraphqlEntity();

	factory MediaCollectionGraphqlEntity.fromJson(Map<String, dynamic> json) => $MediaCollectionGraphqlEntityFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionGraphqlEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionGraphqlDtoData {
	@JSONField(name: "MediaListCollection")
	late MediaCollectionGraphqlDtoDataMediaListCollection mediaListCollection = MediaCollectionGraphqlDtoDataMediaListCollection();

	MediaCollectionGraphqlDtoData();

	factory MediaCollectionGraphqlDtoData.fromJson(Map<String, dynamic> json) => $MediaCollectionGraphqlDtoDataFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionGraphqlDtoDataToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionGraphqlDtoDataMediaListCollection {
	late List<MediaCollectionGraphqlDtoDataMediaListCollectionLists> lists = [];
	late bool hasNextChunk = false;

	MediaCollectionGraphqlDtoDataMediaListCollection();

	factory MediaCollectionGraphqlDtoDataMediaListCollection.fromJson(Map<String, dynamic> json) => $MediaCollectionGraphqlDtoDataMediaListCollectionFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionGraphqlDtoDataMediaListCollectionToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionGraphqlDtoDataMediaListCollectionLists {
	late List<MediaCollectionGraphqlDtoDataMediaListCollectionListsEntries> entries = [];
	late String name = '';
	late bool isCustomList = false;

	MediaCollectionGraphqlDtoDataMediaListCollectionLists();

	factory MediaCollectionGraphqlDtoDataMediaListCollectionLists.fromJson(Map<String, dynamic> json) => $MediaCollectionGraphqlDtoDataMediaListCollectionListsFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionGraphqlDtoDataMediaListCollectionListsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionGraphqlDtoDataMediaListCollectionListsEntries {
	late MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia media = MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia();

	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntries();

	factory MediaCollectionGraphqlDtoDataMediaListCollectionListsEntries.fromJson(Map<String, dynamic> json) => $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia {
	late int id = 0;
	late int idMal = 0;
	late MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle title = MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle();
	late int averageScore = 0;
	late String bannerImage = '';
	late int? chapters = 0;
	late String countryOfOrigin = '';
	late MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage coverImage = MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage();
	late String description = '';
	late int duration = 0;
	late MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate endDate = MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate();
	late MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate startDate = MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate();
	late int episodes = 0;
	late List<String> genres = [];
	late String format = '';
	late bool isAdult = false;
	late int popularity = 0;
	late int meanScore = 0;
	late String season = '';
	late bool isFavourite = false;
	late String status = '';
	dynamic nextAiringEpisode;


	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia();

	factory MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.fromJson(Map<String, dynamic> json) => $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle {
	late String english = '';
	late String userPreferred = '';
	late String romaji = '';
	late String native = '';

	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle();

	factory MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle.fromJson(Map<String, dynamic> json) => $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitleFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitleToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage {
	late String large = '';

	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage();

	factory MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage.fromJson(Map<String, dynamic> json) => $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImageFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImageToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate {
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate();

	factory MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate.fromJson(Map<String, dynamic> json) => $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDateFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate {
	late int day = 0;
	late int month = 0;
	late int year = 0;

	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate();

	factory MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate.fromJson(Map<String, dynamic> json) => $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDateFromJson(json);

	Map<String, dynamic> toJson() => $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/media_details_graphql_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/media_details_graphql_entity.g.dart';

@JsonSerializable()
class MediaDetailsGraphqlEntity {
	@JSONField(name: 'Media')
	late MediaDetailsGraphqlMedia media = MediaDetailsGraphqlMedia();

	MediaDetailsGraphqlEntity();

	factory MediaDetailsGraphqlEntity.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlEntityFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsGraphqlMedia {
	late int id = 0;
	late MediaDetailsGraphqlMediaTitle title = MediaDetailsGraphqlMediaTitle();
	late MediaDetailsGraphqlMediaRecommendations recommendations = MediaDetailsGraphqlMediaRecommendations();
	late MediaDetailsGraphqlMediaCharacters characters = MediaDetailsGraphqlMediaCharacters();

	MediaDetailsGraphqlMedia();

	factory MediaDetailsGraphqlMedia.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlMediaFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlMediaToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsGraphqlMediaTitle {
	late String english = '';
	late String romaji = '';
	late String native = '';
	late String userPreferred = '';

	MediaDetailsGraphqlMediaTitle();

	factory MediaDetailsGraphqlMediaTitle.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlMediaTitleFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlMediaTitleToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsGraphqlMediaRecommendations {
	late List<MediaDetailsGraphqlMediaRecommendationsNodes> nodes = [];

	MediaDetailsGraphqlMediaRecommendations();

	factory MediaDetailsGraphqlMediaRecommendations.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlMediaRecommendationsFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlMediaRecommendationsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsGraphqlMediaRecommendationsNodes {
	late MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation mediaRecommendation = MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation();

	MediaDetailsGraphqlMediaRecommendationsNodes();

	factory MediaDetailsGraphqlMediaRecommendationsNodes.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlMediaRecommendationsNodesFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlMediaRecommendationsNodesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation {
	int id = 0;
	int idMal = 0;
	late MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate startDate = MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate();
	late MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate endDate = MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate();
	String season = '';
	String status = '';
	bool isFavourite = false;
	bool isAdult = false;
	int episodes = 0;
  int chapters = 0;
	late MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle title = MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle();
	String bannerImage = '';
	late MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage coverImage = MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage();
	int averageScore = 0;
	int duration = 0;
	String format = '';
	List<String> genres = [];
	String description = '';
	int meanScore = 0;
	dynamic nextAiringEpisode;

	MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation();

	factory MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate {
	int day = 0;
	int month = 0;
	int year = 0;

	MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate();

	factory MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDateFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate {
	int day = 0;
	int month = 0;
	int year = 0;

	MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate();

	factory MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDateFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle {
	String english = '';
	String native = '';
	String romaji = '';
	String userPreferred = '';

	MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle();

	factory MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitleFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitleToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage {
	String large = '';

	MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage();

	factory MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImageFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImageToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsGraphqlMediaCharacters {
	List<MediaDetailsGraphqlMediaCharactersNodes> nodes = [];

	MediaDetailsGraphqlMediaCharacters();

	factory MediaDetailsGraphqlMediaCharacters.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlMediaCharactersFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlMediaCharactersToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsGraphqlMediaCharactersNodes {
	int id = 0;
	late MediaDetailsGraphqlMediaCharactersNodesImage image = MediaDetailsGraphqlMediaCharactersNodesImage();
	late MediaDetailsGraphqlMediaCharactersNodesName name = MediaDetailsGraphqlMediaCharactersNodesName();
	String gender = '';
	String description = '';
	late MediaDetailsGraphqlMediaCharactersNodesDateOfBirth dateOfBirth = MediaDetailsGraphqlMediaCharactersNodesDateOfBirth();
	String age = '';

	MediaDetailsGraphqlMediaCharactersNodes();

	factory MediaDetailsGraphqlMediaCharactersNodes.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlMediaCharactersNodesFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlMediaCharactersNodesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsGraphqlMediaCharactersNodesImage {
	String large = '';

	MediaDetailsGraphqlMediaCharactersNodesImage();

	factory MediaDetailsGraphqlMediaCharactersNodesImage.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlMediaCharactersNodesImageFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlMediaCharactersNodesImageToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsGraphqlMediaCharactersNodesName {
	String userPreferred = '';

	MediaDetailsGraphqlMediaCharactersNodesName();

	factory MediaDetailsGraphqlMediaCharactersNodesName.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlMediaCharactersNodesNameFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlMediaCharactersNodesNameToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsGraphqlMediaCharactersNodesDateOfBirth {
	int day = 0;
	int month = 0;
	int year = 0;

	MediaDetailsGraphqlMediaCharactersNodesDateOfBirth();

	factory MediaDetailsGraphqlMediaCharactersNodesDateOfBirth.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlMediaCharactersNodesDateOfBirthFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlMediaCharactersNodesDateOfBirthToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsGraphqlMediaMediaListEntryCustomLists {
	String name = '';
	bool enabled = false;

	MediaDetailsGraphqlMediaMediaListEntryCustomLists();

	factory MediaDetailsGraphqlMediaMediaListEntryCustomLists.fromJson(Map<String, dynamic> json) => $MediaDetailsGraphqlMediaMediaListEntryCustomListsFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsGraphqlMediaMediaListEntryCustomListsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
import 'package:unyo/core/services/api/dto/mal/mal_my_list_status_entity.dart';
import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/mal_manga_node.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/mal_manga_node.g.dart';

/// One MyAnimeList manga node (WP #166). Mirror of `MalAnimeNode` for
/// `/manga`, `/manga/ranking` and `/manga/{id}`: `num_volumes`/`num_chapters`
/// replace `num_episodes`, and there is no season/broadcast.
@JsonSerializable()
class MalMangaNode {
	late int id = 0;
	late String title = '';
	@JSONField(name: 'main_picture')
	late MalMangaNodeMainPicture mainPicture = MalMangaNodeMainPicture();
	@JSONField(name: 'alternative_titles')
	late MalMangaNodeAlternativeTitles alternativeTitles = MalMangaNodeAlternativeTitles();
	@JSONField(name: 'start_date')
	late String startDate = '';
	@JSONField(name: 'end_date')
	late String endDate = '';
	late String synopsis = '';
	late double mean = 0;
	late int rank = 0;
	late int popularity = 0;
	@JSONField(name: 'num_list_users')
	late int numListUsers = 0;
	@JSONField(name: 'media_type')
	late String mediaType = '';
	late String status = '';
	late List<MalMangaNodeGenres> genres = [];
	late String nsfw = '';
	late String rating = '';
	@JSONField(name: 'num_volumes')
	late int numVolumes = 0;
	@JSONField(name: 'num_chapters')
	late int numChapters = 0;
	@JSONField(name: 'related_anime')
	late List<MalMangaNodeRelated> relatedAnime = [];
	@JSONField(name: 'related_manga')
	late List<MalMangaNodeRelated> relatedManga = [];
	@JSONField(name: 'my_list_status')
	late MalMyListStatusEntity myListStatus = MalMyListStatusEntity();

	MalMangaNode();

	factory MalMangaNode.fromJson(Map<String, dynamic> json) => $MalMangaNodeFromJson(json);

	Map<String, dynamic> toJson() => $MalMangaNodeToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalMangaNodeMainPicture {
	late String medium = '';
	late String large = '';

	MalMangaNodeMainPicture();

	factory MalMangaNodeMainPicture.fromJson(Map<String, dynamic> json) => $MalMangaNodeMainPictureFromJson(json);

	Map<String, dynamic> toJson() => $MalMangaNodeMainPictureToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalMangaNodeAlternativeTitles {
	late List<String> synonyms = [];
	late String en = '';
	late String ja = '';

	MalMangaNodeAlternativeTitles();

	factory MalMangaNodeAlternativeTitles.fromJson(Map<String, dynamic> json) => $MalMangaNodeAlternativeTitlesFromJson(json);

	Map<String, dynamic> toJson() => $MalMangaNodeAlternativeTitlesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalMangaNodeGenres {
	late int id = 0;
	late String name = '';

	MalMangaNodeGenres();

	factory MalMangaNodeGenres.fromJson(Map<String, dynamic> json) => $MalMangaNodeGenresFromJson(json);

	Map<String, dynamic> toJson() => $MalMangaNodeGenresToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalMangaNodeRelated {
	@JSONField(name: 'relation_type')
	late String relationType = '';
	@JSONField(name: 'relation_type_formatted')
	late String relationTypeFormatted = '';
	late MalMangaNodeRelatedNode node = MalMangaNodeRelatedNode();

	MalMangaNodeRelated();

	factory MalMangaNodeRelated.fromJson(Map<String, dynamic> json) => $MalMangaNodeRelatedFromJson(json);

	Map<String, dynamic> toJson() => $MalMangaNodeRelatedToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalMangaNodeRelatedNode {
	late int id = 0;
	late String title = '';
	@JSONField(name: 'main_picture')
	late MalMangaNodeRelatedNodeMainPicture mainPicture = MalMangaNodeRelatedNodeMainPicture();
	@JSONField(name: 'start_date')
	late String startDate = '';
	@JSONField(name: 'end_date')
	late String endDate = '';
	late String synopsis = '';
	late double mean = 0;
	@JSONField(name: 'media_type')
	late String mediaType = '';
	late String status = '';
	late String rating = '';
	late String nsfw = '';
	late List<MalMangaNodeGenres> genres = [];
	@JSONField(name: 'num_volumes')
	late int numVolumes = 0;
	@JSONField(name: 'num_chapters')
	late int numChapters = 0;
	late int popularity = 0;

	MalMangaNodeRelatedNode();

	factory MalMangaNodeRelatedNode.fromJson(Map<String, dynamic> json) => $MalMangaNodeRelatedNodeFromJson(json);

	Map<String, dynamic> toJson() => $MalMangaNodeRelatedNodeToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalMangaNodeRelatedNodeMainPicture {
	late String medium = '';
	late String large = '';

	MalMangaNodeRelatedNodeMainPicture();

	factory MalMangaNodeRelatedNodeMainPicture.fromJson(Map<String, dynamic> json) =>
			$MalMangaNodeRelatedNodeMainPictureFromJson(json);

	Map<String, dynamic> toJson() => $MalMangaNodeRelatedNodeMainPictureToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

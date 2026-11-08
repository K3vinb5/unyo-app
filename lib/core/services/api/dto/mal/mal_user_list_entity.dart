import 'package:unyo/core/services/api/dto/mal/mal_my_list_status_entity.dart';
import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/mal_user_list_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/mal_user_list_entity.g.dart';

/// `GET /users/@me/animelist` / `/mangalist` (WP #156): the paging envelope
/// `{data:[{node, list_status}], paging:{previous, next}}`. `fields=list_status`
/// is mandatory — without it the status object is omitted from every node.
@JsonSerializable()
class MalUserListEntity {
	late List<MalUserListEntityData> data = [];
	late MalUserListEntityPaging paging = MalUserListEntityPaging();

	MalUserListEntity();

	factory MalUserListEntity.fromJson(Map<String, dynamic> json) => $MalUserListEntityFromJson(json);

	Map<String, dynamic> toJson() => $MalUserListEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalUserListEntityData {
	late MalUserListEntityDataNode node = MalUserListEntityDataNode();
	@JSONField(name: 'list_status')
	late MalMyListStatusEntity listStatus = MalMyListStatusEntity();

	MalUserListEntityData();

	factory MalUserListEntityData.fromJson(Map<String, dynamic> json) => $MalUserListEntityDataFromJson(json);

	Map<String, dynamic> toJson() => $MalUserListEntityDataToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

/// The media node of one list entry: id/title/main_picture are always present,
/// the rest only when requested via `fields` (the repository asks for
/// `alternative_titles,start_date,end_date,mean,num_episodes` /
/// `num_volumes,num_chapters,media_type,status,genres,nsfw,popularity`).
@JsonSerializable()
class MalUserListEntityDataNode {
	late int id = 0;
	late String title = '';
	@JSONField(name: 'main_picture')
	late MalUserListEntityDataNodeMainPicture mainPicture = MalUserListEntityDataNodeMainPicture();
	@JSONField(name: 'alternative_titles')
	late MalUserListEntityDataNodeAlternativeTitles alternativeTitles = MalUserListEntityDataNodeAlternativeTitles();
	@JSONField(name: 'start_date')
	late String startDate = '';
	@JSONField(name: 'end_date')
	late String endDate = '';
	late double mean = 0;
	@JSONField(name: 'num_episodes')
	late int numEpisodes = 0;
	@JSONField(name: 'num_volumes')
	late int numVolumes = 0;
	@JSONField(name: 'num_chapters')
	late int numChapters = 0;
	@JSONField(name: 'media_type')
	late String mediaType = '';
	late String status = '';
	late List<MalUserListEntityDataNodeGenres> genres = [];
	late String nsfw = '';
	late int popularity = 0;

	MalUserListEntityDataNode();

	factory MalUserListEntityDataNode.fromJson(Map<String, dynamic> json) => $MalUserListEntityDataNodeFromJson(json);

	Map<String, dynamic> toJson() => $MalUserListEntityDataNodeToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalUserListEntityDataNodeMainPicture {
	late String medium = '';
	late String large = '';

	MalUserListEntityDataNodeMainPicture();

	factory MalUserListEntityDataNodeMainPicture.fromJson(Map<String, dynamic> json) => $MalUserListEntityDataNodeMainPictureFromJson(json);

	Map<String, dynamic> toJson() => $MalUserListEntityDataNodeMainPictureToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalUserListEntityDataNodeAlternativeTitles {
	late List<String> synonyms = [];
	late String en = '';
	late String ja = '';

	MalUserListEntityDataNodeAlternativeTitles();

	factory MalUserListEntityDataNodeAlternativeTitles.fromJson(Map<String, dynamic> json) => $MalUserListEntityDataNodeAlternativeTitlesFromJson(json);

	Map<String, dynamic> toJson() => $MalUserListEntityDataNodeAlternativeTitlesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalUserListEntityDataNodeGenres {
	late int id = 0;
	late String name = '';

	MalUserListEntityDataNodeGenres();

	factory MalUserListEntityDataNodeGenres.fromJson(Map<String, dynamic> json) => $MalUserListEntityDataNodeGenresFromJson(json);

	Map<String, dynamic> toJson() => $MalUserListEntityDataNodeGenresToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

/// `{paging: {previous, next}}` — URL strings; a missing side is an empty
/// string. `next` empty means the last page.
@JsonSerializable()
class MalUserListEntityPaging {
	late String previous = '';
	late String next = '';

	MalUserListEntityPaging();

	factory MalUserListEntityPaging.fromJson(Map<String, dynamic> json) => $MalUserListEntityPagingFromJson(json);

	Map<String, dynamic> toJson() => $MalUserListEntityPagingToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

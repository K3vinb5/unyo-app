import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/viewer_graphql_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/viewer_graphql_entity.g.dart';

@JsonSerializable()
class ViewerGraphqlEntity {
	@JSONField(name: "Viewer")
	late ViewerGraphqlDtoViewer viewer = ViewerGraphqlDtoViewer();

	ViewerGraphqlEntity();

	factory ViewerGraphqlEntity.fromJson(Map<String, dynamic> json) => $ViewerGraphqlEntityFromJson(json);

	Map<String, dynamic> toJson() => $ViewerGraphqlEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class ViewerGraphqlDtoViewer {
	late int id = 0;
	late String bannerImage = '';
	late ViewerGraphqlDtoViewerAvatar avatar = ViewerGraphqlDtoViewerAvatar();
	late ViewerGraphqlDtoViewerMediaListOptions mediaListOptions = ViewerGraphqlDtoViewerMediaListOptions();
	late String name = '';

	ViewerGraphqlDtoViewer();

	factory ViewerGraphqlDtoViewer.fromJson(Map<String, dynamic> json) => $ViewerGraphqlDtoViewerFromJson(json);

	Map<String, dynamic> toJson() => $ViewerGraphqlDtoViewerToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class ViewerGraphqlDtoViewerAvatar {
	late String medium = '';

	ViewerGraphqlDtoViewerAvatar();

	factory ViewerGraphqlDtoViewerAvatar.fromJson(Map<String, dynamic> json) => $ViewerGraphqlDtoViewerAvatarFromJson(json);

	Map<String, dynamic> toJson() => $ViewerGraphqlDtoViewerAvatarToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class ViewerGraphqlDtoViewerMediaListOptions {
	late ViewerGraphqlDtoViewerMediaListOptionsAnimeList animeList = ViewerGraphqlDtoViewerMediaListOptionsAnimeList();
	late ViewerGraphqlDtoViewerMediaListOptionsMangaList mangaList = ViewerGraphqlDtoViewerMediaListOptionsMangaList();
	late String scoreFormat = '';

	ViewerGraphqlDtoViewerMediaListOptions();

	factory ViewerGraphqlDtoViewerMediaListOptions.fromJson(Map<String, dynamic> json) => $ViewerGraphqlDtoViewerMediaListOptionsFromJson(json);

	Map<String, dynamic> toJson() => $ViewerGraphqlDtoViewerMediaListOptionsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class ViewerGraphqlDtoViewerMediaListOptionsAnimeList {
	late List<String> customLists = [];

	ViewerGraphqlDtoViewerMediaListOptionsAnimeList();

	factory ViewerGraphqlDtoViewerMediaListOptionsAnimeList.fromJson(Map<String, dynamic> json) => $ViewerGraphqlDtoViewerMediaListOptionsAnimeListFromJson(json);

	Map<String, dynamic> toJson() => $ViewerGraphqlDtoViewerMediaListOptionsAnimeListToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class ViewerGraphqlDtoViewerMediaListOptionsMangaList {
	late List<dynamic> customLists = [];

	ViewerGraphqlDtoViewerMediaListOptionsMangaList();

	factory ViewerGraphqlDtoViewerMediaListOptionsMangaList.fromJson(Map<String, dynamic> json) => $ViewerGraphqlDtoViewerMediaListOptionsMangaListFromJson(json);

	Map<String, dynamic> toJson() => $ViewerGraphqlDtoViewerMediaListOptionsMangaListToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
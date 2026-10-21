import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/anilist/viewer_graphql_entity.dart';

ViewerGraphqlEntity $ViewerGraphqlEntityFromJson(Map<String, dynamic> json) {
	final ViewerGraphqlEntity viewerGraphqlEntity = ViewerGraphqlEntity();
	final ViewerGraphqlDtoViewer? viewer = jsonConvert.convert<ViewerGraphqlDtoViewer>(json['Viewer']);
	if (viewer != null) {
		viewerGraphqlEntity.viewer = viewer;
	}
	return viewerGraphqlEntity;
}

Map<String, dynamic> $ViewerGraphqlEntityToJson(ViewerGraphqlEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['Viewer'] = entity.viewer.toJson();
	return data;
}

extension ViewerGraphqlEntityExtension on ViewerGraphqlEntity {
	ViewerGraphqlEntity copyWith({
	ViewerGraphqlDtoViewer? viewer,
	}) {
		return ViewerGraphqlEntity()
			..viewer = viewer ?? this.viewer;
	}
}


ViewerGraphqlDtoViewer $ViewerGraphqlDtoViewerFromJson(Map<String, dynamic> json) {
	final ViewerGraphqlDtoViewer viewerGraphqlDtoViewer = ViewerGraphqlDtoViewer();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		viewerGraphqlDtoViewer.id = id;
	}
	final String? bannerImage = jsonConvert.convert<String>(json['bannerImage']);
	if (bannerImage != null) {
		viewerGraphqlDtoViewer.bannerImage = bannerImage;
	}
	final ViewerGraphqlDtoViewerAvatar? avatar = jsonConvert.convert<ViewerGraphqlDtoViewerAvatar>(json['avatar']);
	if (avatar != null) {
		viewerGraphqlDtoViewer.avatar = avatar;
	}
	final ViewerGraphqlDtoViewerMediaListOptions? mediaListOptions = jsonConvert.convert<ViewerGraphqlDtoViewerMediaListOptions>(json['mediaListOptions']);
	if (mediaListOptions != null) {
		viewerGraphqlDtoViewer.mediaListOptions = mediaListOptions;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		viewerGraphqlDtoViewer.name = name;
	}
	return viewerGraphqlDtoViewer;
}

Map<String, dynamic> $ViewerGraphqlDtoViewerToJson(ViewerGraphqlDtoViewer entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['bannerImage'] = entity.bannerImage;
	data['avatar'] = entity.avatar.toJson();
	data['mediaListOptions'] = entity.mediaListOptions.toJson();
	data['name'] = entity.name;
	return data;
}

extension ViewerGraphqlDtoViewerExtension on ViewerGraphqlDtoViewer {
	ViewerGraphqlDtoViewer copyWith({
	int? id,
	String? bannerImage,
	ViewerGraphqlDtoViewerAvatar? avatar,
	ViewerGraphqlDtoViewerMediaListOptions? mediaListOptions,
	String? name,
	}) {
		return ViewerGraphqlDtoViewer()
			..id = id ?? this.id
			..bannerImage = bannerImage ?? this.bannerImage
			..avatar = avatar ?? this.avatar
			..mediaListOptions = mediaListOptions ?? this.mediaListOptions
			..name = name ?? this.name;
	}
}


ViewerGraphqlDtoViewerAvatar $ViewerGraphqlDtoViewerAvatarFromJson(Map<String, dynamic> json) {
	final ViewerGraphqlDtoViewerAvatar viewerGraphqlDtoViewerAvatar = ViewerGraphqlDtoViewerAvatar();
	final String? medium = jsonConvert.convert<String>(json['medium']);
	if (medium != null) {
		viewerGraphqlDtoViewerAvatar.medium = medium;
	}
	return viewerGraphqlDtoViewerAvatar;
}

Map<String, dynamic> $ViewerGraphqlDtoViewerAvatarToJson(ViewerGraphqlDtoViewerAvatar entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['medium'] = entity.medium;
	return data;
}

extension ViewerGraphqlDtoViewerAvatarExtension on ViewerGraphqlDtoViewerAvatar {
	ViewerGraphqlDtoViewerAvatar copyWith({
	String? medium,
	}) {
		return ViewerGraphqlDtoViewerAvatar()
			..medium = medium ?? this.medium;
	}
}


ViewerGraphqlDtoViewerMediaListOptions $ViewerGraphqlDtoViewerMediaListOptionsFromJson(Map<String, dynamic> json) {
	final ViewerGraphqlDtoViewerMediaListOptions viewerGraphqlDtoViewerMediaListOptions = ViewerGraphqlDtoViewerMediaListOptions();
	final ViewerGraphqlDtoViewerMediaListOptionsAnimeList? animeList = jsonConvert.convert<ViewerGraphqlDtoViewerMediaListOptionsAnimeList>(json['animeList']);
	if (animeList != null) {
		viewerGraphqlDtoViewerMediaListOptions.animeList = animeList;
	}
	final ViewerGraphqlDtoViewerMediaListOptionsMangaList? mangaList = jsonConvert.convert<ViewerGraphqlDtoViewerMediaListOptionsMangaList>(json['mangaList']);
	if (mangaList != null) {
		viewerGraphqlDtoViewerMediaListOptions.mangaList = mangaList;
	}
	final String? scoreFormat = jsonConvert.convert<String>(json['scoreFormat']);
	if (scoreFormat != null) {
		viewerGraphqlDtoViewerMediaListOptions.scoreFormat = scoreFormat;
	}
	return viewerGraphqlDtoViewerMediaListOptions;
}

Map<String, dynamic> $ViewerGraphqlDtoViewerMediaListOptionsToJson(ViewerGraphqlDtoViewerMediaListOptions entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['animeList'] = entity.animeList.toJson();
	data['mangaList'] = entity.mangaList.toJson();
	data['scoreFormat'] = entity.scoreFormat;
	return data;
}

extension ViewerGraphqlDtoViewerMediaListOptionsExtension on ViewerGraphqlDtoViewerMediaListOptions {
	ViewerGraphqlDtoViewerMediaListOptions copyWith({
	ViewerGraphqlDtoViewerMediaListOptionsAnimeList? animeList,
	ViewerGraphqlDtoViewerMediaListOptionsMangaList? mangaList,
	String? scoreFormat,
	}) {
		return ViewerGraphqlDtoViewerMediaListOptions()
			..animeList = animeList ?? this.animeList
			..mangaList = mangaList ?? this.mangaList
			..scoreFormat = scoreFormat ?? this.scoreFormat;
	}
}


ViewerGraphqlDtoViewerMediaListOptionsAnimeList $ViewerGraphqlDtoViewerMediaListOptionsAnimeListFromJson(Map<String, dynamic> json) {
	final ViewerGraphqlDtoViewerMediaListOptionsAnimeList viewerGraphqlDtoViewerMediaListOptionsAnimeList = ViewerGraphqlDtoViewerMediaListOptionsAnimeList();
	final List<String>? customLists = (json['customLists'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (customLists != null) {
		viewerGraphqlDtoViewerMediaListOptionsAnimeList.customLists = customLists;
	}
	return viewerGraphqlDtoViewerMediaListOptionsAnimeList;
}

Map<String, dynamic> $ViewerGraphqlDtoViewerMediaListOptionsAnimeListToJson(ViewerGraphqlDtoViewerMediaListOptionsAnimeList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['customLists'] =  entity.customLists;
	return data;
}

extension ViewerGraphqlDtoViewerMediaListOptionsAnimeListExtension on ViewerGraphqlDtoViewerMediaListOptionsAnimeList {
	ViewerGraphqlDtoViewerMediaListOptionsAnimeList copyWith({
	List<String>? customLists,
	}) {
		return ViewerGraphqlDtoViewerMediaListOptionsAnimeList()
			..customLists = customLists ?? this.customLists;
	}
}


ViewerGraphqlDtoViewerMediaListOptionsMangaList $ViewerGraphqlDtoViewerMediaListOptionsMangaListFromJson(Map<String, dynamic> json) {
	final ViewerGraphqlDtoViewerMediaListOptionsMangaList viewerGraphqlDtoViewerMediaListOptionsMangaList = ViewerGraphqlDtoViewerMediaListOptionsMangaList();
	final List<dynamic>? customLists = (json['customLists'] as List<dynamic>?)?.map(
	(e) => e).toList();
	if (customLists != null) {
		viewerGraphqlDtoViewerMediaListOptionsMangaList.customLists = customLists;
	}
	return viewerGraphqlDtoViewerMediaListOptionsMangaList;
}

Map<String, dynamic> $ViewerGraphqlDtoViewerMediaListOptionsMangaListToJson(ViewerGraphqlDtoViewerMediaListOptionsMangaList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['customLists'] =  entity.customLists;
	return data;
}

extension ViewerGraphqlDtoViewerMediaListOptionsMangaListExtension on ViewerGraphqlDtoViewerMediaListOptionsMangaList {
	ViewerGraphqlDtoViewerMediaListOptionsMangaList copyWith({
	List<dynamic>? customLists,
	}) {
		return ViewerGraphqlDtoViewerMediaListOptionsMangaList()
			..customLists = customLists ?? this.customLists;
	}
}

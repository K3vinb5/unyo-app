import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/mal/mal_user_list_entity.dart';
import 'package:unyo/core/services/api/dto/mal/mal_my_list_status_entity.dart';

MalUserListEntity $MalUserListEntityFromJson(Map<String, dynamic> json) {
	final MalUserListEntity malUserListEntity = MalUserListEntity();
	final List<MalUserListEntityData>? data = (json['data'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MalUserListEntityData>(e) as MalUserListEntityData).toList();
	if (data != null) {
		malUserListEntity.data = data;
	}
	final MalUserListEntityPaging? paging = jsonConvert.convert<MalUserListEntityPaging>(json['paging']);
	if (paging != null) {
		malUserListEntity.paging = paging;
	}
	return malUserListEntity;
}

Map<String, dynamic> $MalUserListEntityToJson(MalUserListEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['data'] =  entity.data.map((v) => v.toJson()).toList();
	data['paging'] = entity.paging.toJson();
	return data;
}

extension MalUserListEntityExtension on MalUserListEntity {
	MalUserListEntity copyWith({
	List<MalUserListEntityData>? data,
	MalUserListEntityPaging? paging,
	}) {
		return MalUserListEntity()
			..data = data ?? this.data
			..paging = paging ?? this.paging;
	}
}


MalUserListEntityData $MalUserListEntityDataFromJson(Map<String, dynamic> json) {
	final MalUserListEntityData malUserListEntityData = MalUserListEntityData();
	final MalUserListEntityDataNode? node = jsonConvert.convert<MalUserListEntityDataNode>(json['node']);
	if (node != null) {
		malUserListEntityData.node = node;
	}
	final MalMyListStatusEntity? listStatus = jsonConvert.convert<MalMyListStatusEntity>(json['list_status']);
	if (listStatus != null) {
		malUserListEntityData.listStatus = listStatus;
	}
	return malUserListEntityData;
}

Map<String, dynamic> $MalUserListEntityDataToJson(MalUserListEntityData entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['node'] = entity.node.toJson();
	data['list_status'] = entity.listStatus.toJson();
	return data;
}

extension MalUserListEntityDataExtension on MalUserListEntityData {
	MalUserListEntityData copyWith({
	MalUserListEntityDataNode? node,
	MalMyListStatusEntity? listStatus,
	}) {
		return MalUserListEntityData()
			..node = node ?? this.node
			..listStatus = listStatus ?? this.listStatus;
	}
}


MalUserListEntityDataNode $MalUserListEntityDataNodeFromJson(Map<String, dynamic> json) {
	final MalUserListEntityDataNode malUserListEntityDataNode = MalUserListEntityDataNode();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		malUserListEntityDataNode.id = id;
	}
	final String? title = jsonConvert.convert<String>(json['title']);
	if (title != null) {
		malUserListEntityDataNode.title = title;
	}
	final MalUserListEntityDataNodeMainPicture? mainPicture = jsonConvert.convert<MalUserListEntityDataNodeMainPicture>(json['main_picture']);
	if (mainPicture != null) {
		malUserListEntityDataNode.mainPicture = mainPicture;
	}
	final MalUserListEntityDataNodeAlternativeTitles? alternativeTitles = jsonConvert.convert<MalUserListEntityDataNodeAlternativeTitles>(json['alternative_titles']);
	if (alternativeTitles != null) {
		malUserListEntityDataNode.alternativeTitles = alternativeTitles;
	}
	final String? startDate = jsonConvert.convert<String>(json['start_date']);
	if (startDate != null) {
		malUserListEntityDataNode.startDate = startDate;
	}
	final String? endDate = jsonConvert.convert<String>(json['end_date']);
	if (endDate != null) {
		malUserListEntityDataNode.endDate = endDate;
	}
	final double? mean = jsonConvert.convert<double>(json['mean']);
	if (mean != null) {
		malUserListEntityDataNode.mean = mean;
	}
	final int? numEpisodes = jsonConvert.convert<int>(json['num_episodes']);
	if (numEpisodes != null) {
		malUserListEntityDataNode.numEpisodes = numEpisodes;
	}
	final int? numVolumes = jsonConvert.convert<int>(json['num_volumes']);
	if (numVolumes != null) {
		malUserListEntityDataNode.numVolumes = numVolumes;
	}
	final int? numChapters = jsonConvert.convert<int>(json['num_chapters']);
	if (numChapters != null) {
		malUserListEntityDataNode.numChapters = numChapters;
	}
	final String? mediaType = jsonConvert.convert<String>(json['media_type']);
	if (mediaType != null) {
		malUserListEntityDataNode.mediaType = mediaType;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		malUserListEntityDataNode.status = status;
	}
	final List<MalUserListEntityDataNodeGenres>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MalUserListEntityDataNodeGenres>(e) as MalUserListEntityDataNodeGenres).toList();
	if (genres != null) {
		malUserListEntityDataNode.genres = genres;
	}
	final String? nsfw = jsonConvert.convert<String>(json['nsfw']);
	if (nsfw != null) {
		malUserListEntityDataNode.nsfw = nsfw;
	}
	final int? popularity = jsonConvert.convert<int>(json['popularity']);
	if (popularity != null) {
		malUserListEntityDataNode.popularity = popularity;
	}
	return malUserListEntityDataNode;
}

Map<String, dynamic> $MalUserListEntityDataNodeToJson(MalUserListEntityDataNode entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['title'] = entity.title;
	data['main_picture'] = entity.mainPicture.toJson();
	data['alternative_titles'] = entity.alternativeTitles.toJson();
	data['start_date'] = entity.startDate;
	data['end_date'] = entity.endDate;
	data['mean'] = entity.mean;
	data['num_episodes'] = entity.numEpisodes;
	data['num_volumes'] = entity.numVolumes;
	data['num_chapters'] = entity.numChapters;
	data['media_type'] = entity.mediaType;
	data['status'] = entity.status;
	data['genres'] =  entity.genres.map((v) => v.toJson()).toList();
	data['nsfw'] = entity.nsfw;
	data['popularity'] = entity.popularity;
	return data;
}

extension MalUserListEntityDataNodeExtension on MalUserListEntityDataNode {
	MalUserListEntityDataNode copyWith({
	int? id,
	String? title,
	MalUserListEntityDataNodeMainPicture? mainPicture,
	MalUserListEntityDataNodeAlternativeTitles? alternativeTitles,
	String? startDate,
	String? endDate,
	double? mean,
	int? numEpisodes,
	int? numVolumes,
	int? numChapters,
	String? mediaType,
	String? status,
	List<MalUserListEntityDataNodeGenres>? genres,
	String? nsfw,
	int? popularity,
	}) {
		return MalUserListEntityDataNode()
			..id = id ?? this.id
			..title = title ?? this.title
			..mainPicture = mainPicture ?? this.mainPicture
			..alternativeTitles = alternativeTitles ?? this.alternativeTitles
			..startDate = startDate ?? this.startDate
			..endDate = endDate ?? this.endDate
			..mean = mean ?? this.mean
			..numEpisodes = numEpisodes ?? this.numEpisodes
			..numVolumes = numVolumes ?? this.numVolumes
			..numChapters = numChapters ?? this.numChapters
			..mediaType = mediaType ?? this.mediaType
			..status = status ?? this.status
			..genres = genres ?? this.genres
			..nsfw = nsfw ?? this.nsfw
			..popularity = popularity ?? this.popularity;
	}
}


MalUserListEntityDataNodeMainPicture $MalUserListEntityDataNodeMainPictureFromJson(Map<String, dynamic> json) {
	final MalUserListEntityDataNodeMainPicture malUserListEntityDataNodeMainPicture = MalUserListEntityDataNodeMainPicture();
	final String? medium = jsonConvert.convert<String>(json['medium']);
	if (medium != null) {
		malUserListEntityDataNodeMainPicture.medium = medium;
	}
	final String? large = jsonConvert.convert<String>(json['large']);
	if (large != null) {
		malUserListEntityDataNodeMainPicture.large = large;
	}
	return malUserListEntityDataNodeMainPicture;
}

Map<String, dynamic> $MalUserListEntityDataNodeMainPictureToJson(MalUserListEntityDataNodeMainPicture entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['medium'] = entity.medium;
	data['large'] = entity.large;
	return data;
}

extension MalUserListEntityDataNodeMainPictureExtension on MalUserListEntityDataNodeMainPicture {
	MalUserListEntityDataNodeMainPicture copyWith({
	String? medium,
	String? large,
	}) {
		return MalUserListEntityDataNodeMainPicture()
			..medium = medium ?? this.medium
			..large = large ?? this.large;
	}
}


MalUserListEntityDataNodeAlternativeTitles $MalUserListEntityDataNodeAlternativeTitlesFromJson(Map<String, dynamic> json) {
	final MalUserListEntityDataNodeAlternativeTitles malUserListEntityDataNodeAlternativeTitles = MalUserListEntityDataNodeAlternativeTitles();
	final List<String>? synonyms = (json['synonyms'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (synonyms != null) {
		malUserListEntityDataNodeAlternativeTitles.synonyms = synonyms;
	}
	final String? en = jsonConvert.convert<String>(json['en']);
	if (en != null) {
		malUserListEntityDataNodeAlternativeTitles.en = en;
	}
	final String? ja = jsonConvert.convert<String>(json['ja']);
	if (ja != null) {
		malUserListEntityDataNodeAlternativeTitles.ja = ja;
	}
	return malUserListEntityDataNodeAlternativeTitles;
}

Map<String, dynamic> $MalUserListEntityDataNodeAlternativeTitlesToJson(MalUserListEntityDataNodeAlternativeTitles entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['synonyms'] =  entity.synonyms;
	data['en'] = entity.en;
	data['ja'] = entity.ja;
	return data;
}

extension MalUserListEntityDataNodeAlternativeTitlesExtension on MalUserListEntityDataNodeAlternativeTitles {
	MalUserListEntityDataNodeAlternativeTitles copyWith({
	List<String>? synonyms,
	String? en,
	String? ja,
	}) {
		return MalUserListEntityDataNodeAlternativeTitles()
			..synonyms = synonyms ?? this.synonyms
			..en = en ?? this.en
			..ja = ja ?? this.ja;
	}
}


MalUserListEntityDataNodeGenres $MalUserListEntityDataNodeGenresFromJson(Map<String, dynamic> json) {
	final MalUserListEntityDataNodeGenres malUserListEntityDataNodeGenres = MalUserListEntityDataNodeGenres();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		malUserListEntityDataNodeGenres.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		malUserListEntityDataNodeGenres.name = name;
	}
	return malUserListEntityDataNodeGenres;
}

Map<String, dynamic> $MalUserListEntityDataNodeGenresToJson(MalUserListEntityDataNodeGenres entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	return data;
}

extension MalUserListEntityDataNodeGenresExtension on MalUserListEntityDataNodeGenres {
	MalUserListEntityDataNodeGenres copyWith({
	int? id,
	String? name,
	}) {
		return MalUserListEntityDataNodeGenres()
			..id = id ?? this.id
			..name = name ?? this.name;
	}
}


MalUserListEntityPaging $MalUserListEntityPagingFromJson(Map<String, dynamic> json) {
	final MalUserListEntityPaging malUserListEntityPaging = MalUserListEntityPaging();
	final String? previous = jsonConvert.convert<String>(json['previous']);
	if (previous != null) {
		malUserListEntityPaging.previous = previous;
	}
	final String? next = jsonConvert.convert<String>(json['next']);
	if (next != null) {
		malUserListEntityPaging.next = next;
	}
	return malUserListEntityPaging;
}

Map<String, dynamic> $MalUserListEntityPagingToJson(MalUserListEntityPaging entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['previous'] = entity.previous;
	data['next'] = entity.next;
	return data;
}

extension MalUserListEntityPagingExtension on MalUserListEntityPaging {
	MalUserListEntityPaging copyWith({
	String? previous,
	String? next,
	}) {
		return MalUserListEntityPaging()
			..previous = previous ?? this.previous
			..next = next ?? this.next;
	}
}

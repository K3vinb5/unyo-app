import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/mal/mal_manga_node.dart';
import 'package:unyo/core/services/api/dto/mal/mal_my_list_status_entity.dart';

MalMangaNode $MalMangaNodeFromJson(Map<String, dynamic> json) {
	final MalMangaNode malMangaNode = MalMangaNode();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		malMangaNode.id = id;
	}
	final String? title = jsonConvert.convert<String>(json['title']);
	if (title != null) {
		malMangaNode.title = title;
	}
	final MalMangaNodeMainPicture? mainPicture = jsonConvert.convert<MalMangaNodeMainPicture>(json['main_picture']);
	if (mainPicture != null) {
		malMangaNode.mainPicture = mainPicture;
	}
	final MalMangaNodeAlternativeTitles? alternativeTitles = jsonConvert.convert<MalMangaNodeAlternativeTitles>(json['alternative_titles']);
	if (alternativeTitles != null) {
		malMangaNode.alternativeTitles = alternativeTitles;
	}
	final String? startDate = jsonConvert.convert<String>(json['start_date']);
	if (startDate != null) {
		malMangaNode.startDate = startDate;
	}
	final String? endDate = jsonConvert.convert<String>(json['end_date']);
	if (endDate != null) {
		malMangaNode.endDate = endDate;
	}
	final String? synopsis = jsonConvert.convert<String>(json['synopsis']);
	if (synopsis != null) {
		malMangaNode.synopsis = synopsis;
	}
	final double? mean = jsonConvert.convert<double>(json['mean']);
	if (mean != null) {
		malMangaNode.mean = mean;
	}
	final int? rank = jsonConvert.convert<int>(json['rank']);
	if (rank != null) {
		malMangaNode.rank = rank;
	}
	final int? popularity = jsonConvert.convert<int>(json['popularity']);
	if (popularity != null) {
		malMangaNode.popularity = popularity;
	}
	final int? numListUsers = jsonConvert.convert<int>(json['num_list_users']);
	if (numListUsers != null) {
		malMangaNode.numListUsers = numListUsers;
	}
	final String? mediaType = jsonConvert.convert<String>(json['media_type']);
	if (mediaType != null) {
		malMangaNode.mediaType = mediaType;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		malMangaNode.status = status;
	}
	final List<MalMangaNodeGenres>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MalMangaNodeGenres>(e) as MalMangaNodeGenres).toList();
	if (genres != null) {
		malMangaNode.genres = genres;
	}
	final String? nsfw = jsonConvert.convert<String>(json['nsfw']);
	if (nsfw != null) {
		malMangaNode.nsfw = nsfw;
	}
	final String? rating = jsonConvert.convert<String>(json['rating']);
	if (rating != null) {
		malMangaNode.rating = rating;
	}
	final int? numVolumes = jsonConvert.convert<int>(json['num_volumes']);
	if (numVolumes != null) {
		malMangaNode.numVolumes = numVolumes;
	}
	final int? numChapters = jsonConvert.convert<int>(json['num_chapters']);
	if (numChapters != null) {
		malMangaNode.numChapters = numChapters;
	}
	final List<MalMangaNodeRelated>? relatedAnime = (json['related_anime'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MalMangaNodeRelated>(e) as MalMangaNodeRelated).toList();
	if (relatedAnime != null) {
		malMangaNode.relatedAnime = relatedAnime;
	}
	final List<MalMangaNodeRelated>? relatedManga = (json['related_manga'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MalMangaNodeRelated>(e) as MalMangaNodeRelated).toList();
	if (relatedManga != null) {
		malMangaNode.relatedManga = relatedManga;
	}
	final MalMyListStatusEntity? myListStatus = jsonConvert.convert<MalMyListStatusEntity>(json['my_list_status']);
	if (myListStatus != null) {
		malMangaNode.myListStatus = myListStatus;
	}
	return malMangaNode;
}

Map<String, dynamic> $MalMangaNodeToJson(MalMangaNode entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['title'] = entity.title;
	data['main_picture'] = entity.mainPicture.toJson();
	data['alternative_titles'] = entity.alternativeTitles.toJson();
	data['start_date'] = entity.startDate;
	data['end_date'] = entity.endDate;
	data['synopsis'] = entity.synopsis;
	data['mean'] = entity.mean;
	data['rank'] = entity.rank;
	data['popularity'] = entity.popularity;
	data['num_list_users'] = entity.numListUsers;
	data['media_type'] = entity.mediaType;
	data['status'] = entity.status;
	data['genres'] =  entity.genres.map((v) => v.toJson()).toList();
	data['nsfw'] = entity.nsfw;
	data['rating'] = entity.rating;
	data['num_volumes'] = entity.numVolumes;
	data['num_chapters'] = entity.numChapters;
	data['related_anime'] =  entity.relatedAnime.map((v) => v.toJson()).toList();
	data['related_manga'] =  entity.relatedManga.map((v) => v.toJson()).toList();
	data['my_list_status'] = entity.myListStatus.toJson();
	return data;
}

extension MalMangaNodeExtension on MalMangaNode {
	MalMangaNode copyWith({
	int? id,
	String? title,
	MalMangaNodeMainPicture? mainPicture,
	MalMangaNodeAlternativeTitles? alternativeTitles,
	String? startDate,
	String? endDate,
	String? synopsis,
	double? mean,
	int? rank,
	int? popularity,
	int? numListUsers,
	String? mediaType,
	String? status,
	List<MalMangaNodeGenres>? genres,
	String? nsfw,
	String? rating,
	int? numVolumes,
	int? numChapters,
	List<MalMangaNodeRelated>? relatedAnime,
	List<MalMangaNodeRelated>? relatedManga,
	MalMyListStatusEntity? myListStatus,
	}) {
		return MalMangaNode()
			..id = id ?? this.id
			..title = title ?? this.title
			..mainPicture = mainPicture ?? this.mainPicture
			..alternativeTitles = alternativeTitles ?? this.alternativeTitles
			..startDate = startDate ?? this.startDate
			..endDate = endDate ?? this.endDate
			..synopsis = synopsis ?? this.synopsis
			..mean = mean ?? this.mean
			..rank = rank ?? this.rank
			..popularity = popularity ?? this.popularity
			..numListUsers = numListUsers ?? this.numListUsers
			..mediaType = mediaType ?? this.mediaType
			..status = status ?? this.status
			..genres = genres ?? this.genres
			..nsfw = nsfw ?? this.nsfw
			..rating = rating ?? this.rating
			..numVolumes = numVolumes ?? this.numVolumes
			..numChapters = numChapters ?? this.numChapters
			..relatedAnime = relatedAnime ?? this.relatedAnime
			..relatedManga = relatedManga ?? this.relatedManga
			..myListStatus = myListStatus ?? this.myListStatus;
	}
}


MalMangaNodeMainPicture $MalMangaNodeMainPictureFromJson(Map<String, dynamic> json) {
	final MalMangaNodeMainPicture malMangaNodeMainPicture = MalMangaNodeMainPicture();
	final String? medium = jsonConvert.convert<String>(json['medium']);
	if (medium != null) {
		malMangaNodeMainPicture.medium = medium;
	}
	final String? large = jsonConvert.convert<String>(json['large']);
	if (large != null) {
		malMangaNodeMainPicture.large = large;
	}
	return malMangaNodeMainPicture;
}

Map<String, dynamic> $MalMangaNodeMainPictureToJson(MalMangaNodeMainPicture entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['medium'] = entity.medium;
	data['large'] = entity.large;
	return data;
}

extension MalMangaNodeMainPictureExtension on MalMangaNodeMainPicture {
	MalMangaNodeMainPicture copyWith({
	String? medium,
	String? large,
	}) {
		return MalMangaNodeMainPicture()
			..medium = medium ?? this.medium
			..large = large ?? this.large;
	}
}


MalMangaNodeAlternativeTitles $MalMangaNodeAlternativeTitlesFromJson(Map<String, dynamic> json) {
	final MalMangaNodeAlternativeTitles malMangaNodeAlternativeTitles = MalMangaNodeAlternativeTitles();
	final List<String>? synonyms = (json['synonyms'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (synonyms != null) {
		malMangaNodeAlternativeTitles.synonyms = synonyms;
	}
	final String? en = jsonConvert.convert<String>(json['en']);
	if (en != null) {
		malMangaNodeAlternativeTitles.en = en;
	}
	final String? ja = jsonConvert.convert<String>(json['ja']);
	if (ja != null) {
		malMangaNodeAlternativeTitles.ja = ja;
	}
	return malMangaNodeAlternativeTitles;
}

Map<String, dynamic> $MalMangaNodeAlternativeTitlesToJson(MalMangaNodeAlternativeTitles entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['synonyms'] =  entity.synonyms;
	data['en'] = entity.en;
	data['ja'] = entity.ja;
	return data;
}

extension MalMangaNodeAlternativeTitlesExtension on MalMangaNodeAlternativeTitles {
	MalMangaNodeAlternativeTitles copyWith({
	List<String>? synonyms,
	String? en,
	String? ja,
	}) {
		return MalMangaNodeAlternativeTitles()
			..synonyms = synonyms ?? this.synonyms
			..en = en ?? this.en
			..ja = ja ?? this.ja;
	}
}


MalMangaNodeGenres $MalMangaNodeGenresFromJson(Map<String, dynamic> json) {
	final MalMangaNodeGenres malMangaNodeGenres = MalMangaNodeGenres();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		malMangaNodeGenres.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		malMangaNodeGenres.name = name;
	}
	return malMangaNodeGenres;
}

Map<String, dynamic> $MalMangaNodeGenresToJson(MalMangaNodeGenres entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	return data;
}

extension MalMangaNodeGenresExtension on MalMangaNodeGenres {
	MalMangaNodeGenres copyWith({
	int? id,
	String? name,
	}) {
		return MalMangaNodeGenres()
			..id = id ?? this.id
			..name = name ?? this.name;
	}
}


MalMangaNodeRelated $MalMangaNodeRelatedFromJson(Map<String, dynamic> json) {
	final MalMangaNodeRelated malMangaNodeRelated = MalMangaNodeRelated();
	final String? relationType = jsonConvert.convert<String>(json['relation_type']);
	if (relationType != null) {
		malMangaNodeRelated.relationType = relationType;
	}
	final String? relationTypeFormatted = jsonConvert.convert<String>(json['relation_type_formatted']);
	if (relationTypeFormatted != null) {
		malMangaNodeRelated.relationTypeFormatted = relationTypeFormatted;
	}
	final MalMangaNodeRelatedNode? node = jsonConvert.convert<MalMangaNodeRelatedNode>(json['node']);
	if (node != null) {
		malMangaNodeRelated.node = node;
	}
	return malMangaNodeRelated;
}

Map<String, dynamic> $MalMangaNodeRelatedToJson(MalMangaNodeRelated entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['relation_type'] = entity.relationType;
	data['relation_type_formatted'] = entity.relationTypeFormatted;
	data['node'] = entity.node.toJson();
	return data;
}

extension MalMangaNodeRelatedExtension on MalMangaNodeRelated {
	MalMangaNodeRelated copyWith({
	String? relationType,
	String? relationTypeFormatted,
	MalMangaNodeRelatedNode? node,
	}) {
		return MalMangaNodeRelated()
			..relationType = relationType ?? this.relationType
			..relationTypeFormatted = relationTypeFormatted ?? this.relationTypeFormatted
			..node = node ?? this.node;
	}
}


MalMangaNodeRelatedNode $MalMangaNodeRelatedNodeFromJson(Map<String, dynamic> json) {
	final MalMangaNodeRelatedNode malMangaNodeRelatedNode = MalMangaNodeRelatedNode();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		malMangaNodeRelatedNode.id = id;
	}
	final String? title = jsonConvert.convert<String>(json['title']);
	if (title != null) {
		malMangaNodeRelatedNode.title = title;
	}
	final MalMangaNodeRelatedNodeMainPicture? mainPicture = jsonConvert.convert<MalMangaNodeRelatedNodeMainPicture>(json['main_picture']);
	if (mainPicture != null) {
		malMangaNodeRelatedNode.mainPicture = mainPicture;
	}
	final String? startDate = jsonConvert.convert<String>(json['start_date']);
	if (startDate != null) {
		malMangaNodeRelatedNode.startDate = startDate;
	}
	final String? endDate = jsonConvert.convert<String>(json['end_date']);
	if (endDate != null) {
		malMangaNodeRelatedNode.endDate = endDate;
	}
	final String? synopsis = jsonConvert.convert<String>(json['synopsis']);
	if (synopsis != null) {
		malMangaNodeRelatedNode.synopsis = synopsis;
	}
	final double? mean = jsonConvert.convert<double>(json['mean']);
	if (mean != null) {
		malMangaNodeRelatedNode.mean = mean;
	}
	final String? mediaType = jsonConvert.convert<String>(json['media_type']);
	if (mediaType != null) {
		malMangaNodeRelatedNode.mediaType = mediaType;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		malMangaNodeRelatedNode.status = status;
	}
	final String? rating = jsonConvert.convert<String>(json['rating']);
	if (rating != null) {
		malMangaNodeRelatedNode.rating = rating;
	}
	final String? nsfw = jsonConvert.convert<String>(json['nsfw']);
	if (nsfw != null) {
		malMangaNodeRelatedNode.nsfw = nsfw;
	}
	final List<MalMangaNodeGenres>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MalMangaNodeGenres>(e) as MalMangaNodeGenres).toList();
	if (genres != null) {
		malMangaNodeRelatedNode.genres = genres;
	}
	final int? numVolumes = jsonConvert.convert<int>(json['num_volumes']);
	if (numVolumes != null) {
		malMangaNodeRelatedNode.numVolumes = numVolumes;
	}
	final int? numChapters = jsonConvert.convert<int>(json['num_chapters']);
	if (numChapters != null) {
		malMangaNodeRelatedNode.numChapters = numChapters;
	}
	final int? popularity = jsonConvert.convert<int>(json['popularity']);
	if (popularity != null) {
		malMangaNodeRelatedNode.popularity = popularity;
	}
	return malMangaNodeRelatedNode;
}

Map<String, dynamic> $MalMangaNodeRelatedNodeToJson(MalMangaNodeRelatedNode entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['title'] = entity.title;
	data['main_picture'] = entity.mainPicture.toJson();
	data['start_date'] = entity.startDate;
	data['end_date'] = entity.endDate;
	data['synopsis'] = entity.synopsis;
	data['mean'] = entity.mean;
	data['media_type'] = entity.mediaType;
	data['status'] = entity.status;
	data['rating'] = entity.rating;
	data['nsfw'] = entity.nsfw;
	data['genres'] =  entity.genres.map((v) => v.toJson()).toList();
	data['num_volumes'] = entity.numVolumes;
	data['num_chapters'] = entity.numChapters;
	data['popularity'] = entity.popularity;
	return data;
}

extension MalMangaNodeRelatedNodeExtension on MalMangaNodeRelatedNode {
	MalMangaNodeRelatedNode copyWith({
	int? id,
	String? title,
	MalMangaNodeRelatedNodeMainPicture? mainPicture,
	String? startDate,
	String? endDate,
	String? synopsis,
	double? mean,
	String? mediaType,
	String? status,
	String? rating,
	String? nsfw,
	List<MalMangaNodeGenres>? genres,
	int? numVolumes,
	int? numChapters,
	int? popularity,
	}) {
		return MalMangaNodeRelatedNode()
			..id = id ?? this.id
			..title = title ?? this.title
			..mainPicture = mainPicture ?? this.mainPicture
			..startDate = startDate ?? this.startDate
			..endDate = endDate ?? this.endDate
			..synopsis = synopsis ?? this.synopsis
			..mean = mean ?? this.mean
			..mediaType = mediaType ?? this.mediaType
			..status = status ?? this.status
			..rating = rating ?? this.rating
			..nsfw = nsfw ?? this.nsfw
			..genres = genres ?? this.genres
			..numVolumes = numVolumes ?? this.numVolumes
			..numChapters = numChapters ?? this.numChapters
			..popularity = popularity ?? this.popularity;
	}
}


MalMangaNodeRelatedNodeMainPicture $MalMangaNodeRelatedNodeMainPictureFromJson(Map<String, dynamic> json) {
	final MalMangaNodeRelatedNodeMainPicture malMangaNodeRelatedNodeMainPicture = MalMangaNodeRelatedNodeMainPicture();
	final String? medium = jsonConvert.convert<String>(json['medium']);
	if (medium != null) {
		malMangaNodeRelatedNodeMainPicture.medium = medium;
	}
	final String? large = jsonConvert.convert<String>(json['large']);
	if (large != null) {
		malMangaNodeRelatedNodeMainPicture.large = large;
	}
	return malMangaNodeRelatedNodeMainPicture;
}

Map<String, dynamic> $MalMangaNodeRelatedNodeMainPictureToJson(MalMangaNodeRelatedNodeMainPicture entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['medium'] = entity.medium;
	data['large'] = entity.large;
	return data;
}

extension MalMangaNodeRelatedNodeMainPictureExtension on MalMangaNodeRelatedNodeMainPicture {
	MalMangaNodeRelatedNodeMainPicture copyWith({
	String? medium,
	String? large,
	}) {
		return MalMangaNodeRelatedNodeMainPicture()
			..medium = medium ?? this.medium
			..large = large ?? this.large;
	}
}

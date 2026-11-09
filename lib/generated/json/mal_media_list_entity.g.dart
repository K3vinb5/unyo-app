import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/mal/mal_media_list_entity.dart';
import 'package:unyo/core/services/api/dto/mal/mal_anime_node.dart';
import 'package:unyo/core/services/api/dto/mal/mal_manga_node.dart';

MalAnimeListEntity $MalAnimeListEntityFromJson(Map<String, dynamic> json) {
	final MalAnimeListEntity malAnimeListEntity = MalAnimeListEntity();
	final List<MalAnimeListEntityData>? data = (json['data'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MalAnimeListEntityData>(e) as MalAnimeListEntityData).toList();
	if (data != null) {
		malAnimeListEntity.data = data;
	}
	final MalPagingEntity? paging = jsonConvert.convert<MalPagingEntity>(json['paging']);
	if (paging != null) {
		malAnimeListEntity.paging = paging;
	}
	return malAnimeListEntity;
}

Map<String, dynamic> $MalAnimeListEntityToJson(MalAnimeListEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['data'] =  entity.data.map((v) => v.toJson()).toList();
	data['paging'] = entity.paging.toJson();
	return data;
}

extension MalAnimeListEntityExtension on MalAnimeListEntity {
	MalAnimeListEntity copyWith({
	List<MalAnimeListEntityData>? data,
	MalPagingEntity? paging,
	}) {
		return MalAnimeListEntity()
			..data = data ?? this.data
			..paging = paging ?? this.paging;
	}
}


MalAnimeListEntityData $MalAnimeListEntityDataFromJson(Map<String, dynamic> json) {
	final MalAnimeListEntityData malAnimeListEntityData = MalAnimeListEntityData();
	final MalAnimeNode? node = jsonConvert.convert<MalAnimeNode>(json['node']);
	if (node != null) {
		malAnimeListEntityData.node = node;
	}
	final MalAnimeListEntityRanking? ranking = jsonConvert.convert<MalAnimeListEntityRanking>(json['ranking']);
	if (ranking != null) {
		malAnimeListEntityData.ranking = ranking;
	}
	return malAnimeListEntityData;
}

Map<String, dynamic> $MalAnimeListEntityDataToJson(MalAnimeListEntityData entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['node'] = entity.node.toJson();
	data['ranking'] = entity.ranking.toJson();
	return data;
}

extension MalAnimeListEntityDataExtension on MalAnimeListEntityData {
	MalAnimeListEntityData copyWith({
	MalAnimeNode? node,
	MalAnimeListEntityRanking? ranking,
	}) {
		return MalAnimeListEntityData()
			..node = node ?? this.node
			..ranking = ranking ?? this.ranking;
	}
}


MalAnimeListEntityRanking $MalAnimeListEntityRankingFromJson(Map<String, dynamic> json) {
	final MalAnimeListEntityRanking malAnimeListEntityRanking = MalAnimeListEntityRanking();
	final int? rank = jsonConvert.convert<int>(json['rank']);
	if (rank != null) {
		malAnimeListEntityRanking.rank = rank;
	}
	return malAnimeListEntityRanking;
}

Map<String, dynamic> $MalAnimeListEntityRankingToJson(MalAnimeListEntityRanking entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['rank'] = entity.rank;
	return data;
}

extension MalAnimeListEntityRankingExtension on MalAnimeListEntityRanking {
	MalAnimeListEntityRanking copyWith({
	int? rank,
	}) {
		return MalAnimeListEntityRanking()
			..rank = rank ?? this.rank;
	}
}


MalMangaListEntity $MalMangaListEntityFromJson(Map<String, dynamic> json) {
	final MalMangaListEntity malMangaListEntity = MalMangaListEntity();
	final List<MalMangaListEntityData>? data = (json['data'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MalMangaListEntityData>(e) as MalMangaListEntityData).toList();
	if (data != null) {
		malMangaListEntity.data = data;
	}
	final MalPagingEntity? paging = jsonConvert.convert<MalPagingEntity>(json['paging']);
	if (paging != null) {
		malMangaListEntity.paging = paging;
	}
	return malMangaListEntity;
}

Map<String, dynamic> $MalMangaListEntityToJson(MalMangaListEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['data'] =  entity.data.map((v) => v.toJson()).toList();
	data['paging'] = entity.paging.toJson();
	return data;
}

extension MalMangaListEntityExtension on MalMangaListEntity {
	MalMangaListEntity copyWith({
	List<MalMangaListEntityData>? data,
	MalPagingEntity? paging,
	}) {
		return MalMangaListEntity()
			..data = data ?? this.data
			..paging = paging ?? this.paging;
	}
}


MalMangaListEntityData $MalMangaListEntityDataFromJson(Map<String, dynamic> json) {
	final MalMangaListEntityData malMangaListEntityData = MalMangaListEntityData();
	final MalMangaNode? node = jsonConvert.convert<MalMangaNode>(json['node']);
	if (node != null) {
		malMangaListEntityData.node = node;
	}
	final MalMangaListEntityRanking? ranking = jsonConvert.convert<MalMangaListEntityRanking>(json['ranking']);
	if (ranking != null) {
		malMangaListEntityData.ranking = ranking;
	}
	return malMangaListEntityData;
}

Map<String, dynamic> $MalMangaListEntityDataToJson(MalMangaListEntityData entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['node'] = entity.node.toJson();
	data['ranking'] = entity.ranking.toJson();
	return data;
}

extension MalMangaListEntityDataExtension on MalMangaListEntityData {
	MalMangaListEntityData copyWith({
	MalMangaNode? node,
	MalMangaListEntityRanking? ranking,
	}) {
		return MalMangaListEntityData()
			..node = node ?? this.node
			..ranking = ranking ?? this.ranking;
	}
}


MalMangaListEntityRanking $MalMangaListEntityRankingFromJson(Map<String, dynamic> json) {
	final MalMangaListEntityRanking malMangaListEntityRanking = MalMangaListEntityRanking();
	final int? rank = jsonConvert.convert<int>(json['rank']);
	if (rank != null) {
		malMangaListEntityRanking.rank = rank;
	}
	return malMangaListEntityRanking;
}

Map<String, dynamic> $MalMangaListEntityRankingToJson(MalMangaListEntityRanking entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['rank'] = entity.rank;
	return data;
}

extension MalMangaListEntityRankingExtension on MalMangaListEntityRanking {
	MalMangaListEntityRanking copyWith({
	int? rank,
	}) {
		return MalMangaListEntityRanking()
			..rank = rank ?? this.rank;
	}
}


MalPagingEntity $MalPagingEntityFromJson(Map<String, dynamic> json) {
	final MalPagingEntity malPagingEntity = MalPagingEntity();
	final String? previous = jsonConvert.convert<String>(json['previous']);
	if (previous != null) {
		malPagingEntity.previous = previous;
	}
	final String? next = jsonConvert.convert<String>(json['next']);
	if (next != null) {
		malPagingEntity.next = next;
	}
	return malPagingEntity;
}

Map<String, dynamic> $MalPagingEntityToJson(MalPagingEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['previous'] = entity.previous;
	data['next'] = entity.next;
	return data;
}

extension MalPagingEntityExtension on MalPagingEntity {
	MalPagingEntity copyWith({
	String? previous,
	String? next,
	}) {
		return MalPagingEntity()
			..previous = previous ?? this.previous
			..next = next ?? this.next;
	}
}

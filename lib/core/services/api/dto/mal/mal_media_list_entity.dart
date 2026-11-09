import 'package:unyo/core/services/api/dto/mal/mal_anime_node.dart';
import 'package:unyo/core/services/api/dto/mal/mal_manga_node.dart';
import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/mal_media_list_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/mal_media_list_entity.g.dart';

/// `GET /anime` and `GET /anime/ranking` (WP #166): the paging envelope
/// `{data:[{node, ranking}], paging:{previous, next}}`. `ranking` is present
/// only on the ranking endpoint (and on a ranking-shaped list read), so it
/// defaults to `rank == 0`.
@JsonSerializable()
class MalAnimeListEntity {
	late List<MalAnimeListEntityData> data = [];
	late MalPagingEntity paging = MalPagingEntity();

	MalAnimeListEntity();

	factory MalAnimeListEntity.fromJson(Map<String, dynamic> json) => $MalAnimeListEntityFromJson(json);

	Map<String, dynamic> toJson() => $MalAnimeListEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalAnimeListEntityData {
	late MalAnimeNode node = MalAnimeNode();
	late MalAnimeListEntityRanking ranking = MalAnimeListEntityRanking();

	MalAnimeListEntityData();

	factory MalAnimeListEntityData.fromJson(Map<String, dynamic> json) => $MalAnimeListEntityDataFromJson(json);

	Map<String, dynamic> toJson() => $MalAnimeListEntityDataToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalAnimeListEntityRanking {
	late int rank = 0;

	MalAnimeListEntityRanking();

	factory MalAnimeListEntityRanking.fromJson(Map<String, dynamic> json) => $MalAnimeListEntityRankingFromJson(json);

	Map<String, dynamic> toJson() => $MalAnimeListEntityRankingToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

/// Manga mirror of [MalAnimeListEntity] (`GET /manga`, `GET /manga/ranking`).
@JsonSerializable()
class MalMangaListEntity {
	late List<MalMangaListEntityData> data = [];
	late MalPagingEntity paging = MalPagingEntity();

	MalMangaListEntity();

	factory MalMangaListEntity.fromJson(Map<String, dynamic> json) => $MalMangaListEntityFromJson(json);

	Map<String, dynamic> toJson() => $MalMangaListEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalMangaListEntityData {
	late MalMangaNode node = MalMangaNode();
	late MalMangaListEntityRanking ranking = MalMangaListEntityRanking();

	MalMangaListEntityData();

	factory MalMangaListEntityData.fromJson(Map<String, dynamic> json) => $MalMangaListEntityDataFromJson(json);

	Map<String, dynamic> toJson() => $MalMangaListEntityDataToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MalMangaListEntityRanking {
	late int rank = 0;

	MalMangaListEntityRanking();

	factory MalMangaListEntityRanking.fromJson(Map<String, dynamic> json) => $MalMangaListEntityRankingFromJson(json);

	Map<String, dynamic> toJson() => $MalMangaListEntityRankingToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

/// `{paging: {previous, next}}`: URL strings, empty when the side is absent
/// (`next` empty = last page).
@JsonSerializable()
class MalPagingEntity {
	late String previous = '';
	late String next = '';

	MalPagingEntity();

	factory MalPagingEntity.fromJson(Map<String, dynamic> json) => $MalPagingEntityFromJson(json);

	Map<String, dynamic> toJson() => $MalPagingEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

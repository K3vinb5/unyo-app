import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_calendar_query_entity.dart';

ShikimoriCalendarQueryEntity $ShikimoriCalendarQueryEntityFromJson(Map<String, dynamic> json) {
	final ShikimoriCalendarQueryEntity shikimoriCalendarQueryEntity = ShikimoriCalendarQueryEntity();
	final List<ShikimoriCalendarQueryList>? list = (json['list'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<ShikimoriCalendarQueryList>(e) as ShikimoriCalendarQueryList).toList();
	if (list != null) {
		shikimoriCalendarQueryEntity.list = list;
	}
	return shikimoriCalendarQueryEntity;
}

Map<String, dynamic> $ShikimoriCalendarQueryEntityToJson(ShikimoriCalendarQueryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['list'] =  entity.list.map((v) => v.toJson()).toList();
	return data;
}

extension ShikimoriCalendarQueryEntityExtension on ShikimoriCalendarQueryEntity {
	ShikimoriCalendarQueryEntity copyWith({
	List<ShikimoriCalendarQueryList>? list,
	}) {
		return ShikimoriCalendarQueryEntity()
			..list = list ?? this.list;
	}
}


ShikimoriCalendarQueryList $ShikimoriCalendarQueryListFromJson(Map<String, dynamic> json) {
	final ShikimoriCalendarQueryList shikimoriCalendarQueryList = ShikimoriCalendarQueryList();
	final int? nextEpisode = jsonConvert.convert<int>(json['next_episode']);
	if (nextEpisode != null) {
		shikimoriCalendarQueryList.nextEpisode = nextEpisode;
	}
	final String? nextEpisodeAt = jsonConvert.convert<String>(json['next_episode_at']);
	if (nextEpisodeAt != null) {
		shikimoriCalendarQueryList.nextEpisodeAt = nextEpisodeAt;
	}
	final int? duration = jsonConvert.convert<int>(json['duration']);
	if (duration != null) {
		shikimoriCalendarQueryList.duration = duration;
	}
	final ShikimoriCalendarQueryListAnime? anime = jsonConvert.convert<ShikimoriCalendarQueryListAnime>(json['anime']);
	if (anime != null) {
		shikimoriCalendarQueryList.anime = anime;
	}
	return shikimoriCalendarQueryList;
}

Map<String, dynamic> $ShikimoriCalendarQueryListToJson(ShikimoriCalendarQueryList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['next_episode'] = entity.nextEpisode;
	data['next_episode_at'] = entity.nextEpisodeAt;
	data['duration'] = entity.duration;
	data['anime'] = entity.anime.toJson();
	return data;
}

extension ShikimoriCalendarQueryListExtension on ShikimoriCalendarQueryList {
	ShikimoriCalendarQueryList copyWith({
	int? nextEpisode,
	String? nextEpisodeAt,
	int? duration,
	ShikimoriCalendarQueryListAnime? anime,
	}) {
		return ShikimoriCalendarQueryList()
			..nextEpisode = nextEpisode ?? this.nextEpisode
			..nextEpisodeAt = nextEpisodeAt ?? this.nextEpisodeAt
			..duration = duration ?? this.duration
			..anime = anime ?? this.anime;
	}
}


ShikimoriCalendarQueryListAnime $ShikimoriCalendarQueryListAnimeFromJson(Map<String, dynamic> json) {
	final ShikimoriCalendarQueryListAnime shikimoriCalendarQueryListAnime = ShikimoriCalendarQueryListAnime();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		shikimoriCalendarQueryListAnime.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		shikimoriCalendarQueryListAnime.name = name;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		shikimoriCalendarQueryListAnime.russian = russian;
	}
	final ShikimoriCalendarQueryListAnimeImage? image = jsonConvert.convert<ShikimoriCalendarQueryListAnimeImage>(json['image']);
	if (image != null) {
		shikimoriCalendarQueryListAnime.image = image;
	}
	final String? url = jsonConvert.convert<String>(json['url']);
	if (url != null) {
		shikimoriCalendarQueryListAnime.url = url;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		shikimoriCalendarQueryListAnime.kind = kind;
	}
	final String? score = jsonConvert.convert<String>(json['score']);
	if (score != null) {
		shikimoriCalendarQueryListAnime.score = score;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		shikimoriCalendarQueryListAnime.status = status;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		shikimoriCalendarQueryListAnime.episodes = episodes;
	}
	final int? episodesAired = jsonConvert.convert<int>(json['episodes_aired']);
	if (episodesAired != null) {
		shikimoriCalendarQueryListAnime.episodesAired = episodesAired;
	}
	final String? airedOn = jsonConvert.convert<String>(json['aired_on']);
	if (airedOn != null) {
		shikimoriCalendarQueryListAnime.airedOn = airedOn;
	}
	final String? releasedOn = jsonConvert.convert<String>(json['released_on']);
	if (releasedOn != null) {
		shikimoriCalendarQueryListAnime.releasedOn = releasedOn;
	}
	return shikimoriCalendarQueryListAnime;
}

Map<String, dynamic> $ShikimoriCalendarQueryListAnimeToJson(ShikimoriCalendarQueryListAnime entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['russian'] = entity.russian;
	data['image'] = entity.image.toJson();
	data['url'] = entity.url;
	data['kind'] = entity.kind;
	data['score'] = entity.score;
	data['status'] = entity.status;
	data['episodes'] = entity.episodes;
	data['episodes_aired'] = entity.episodesAired;
	data['aired_on'] = entity.airedOn;
	data['released_on'] = entity.releasedOn;
	return data;
}

extension ShikimoriCalendarQueryListAnimeExtension on ShikimoriCalendarQueryListAnime {
	ShikimoriCalendarQueryListAnime copyWith({
	int? id,
	String? name,
	String? russian,
	ShikimoriCalendarQueryListAnimeImage? image,
	String? url,
	String? kind,
	String? score,
	String? status,
	int? episodes,
	int? episodesAired,
	String? airedOn,
	String? releasedOn,
	}) {
		return ShikimoriCalendarQueryListAnime()
			..id = id ?? this.id
			..name = name ?? this.name
			..russian = russian ?? this.russian
			..image = image ?? this.image
			..url = url ?? this.url
			..kind = kind ?? this.kind
			..score = score ?? this.score
			..status = status ?? this.status
			..episodes = episodes ?? this.episodes
			..episodesAired = episodesAired ?? this.episodesAired
			..airedOn = airedOn ?? this.airedOn
			..releasedOn = releasedOn ?? this.releasedOn;
	}
}


ShikimoriCalendarQueryListAnimeImage $ShikimoriCalendarQueryListAnimeImageFromJson(Map<String, dynamic> json) {
	final ShikimoriCalendarQueryListAnimeImage shikimoriCalendarQueryListAnimeImage = ShikimoriCalendarQueryListAnimeImage();
	final String? original = jsonConvert.convert<String>(json['original']);
	if (original != null) {
		shikimoriCalendarQueryListAnimeImage.original = original;
	}
	final String? preview = jsonConvert.convert<String>(json['preview']);
	if (preview != null) {
		shikimoriCalendarQueryListAnimeImage.preview = preview;
	}
	final String? x96 = jsonConvert.convert<String>(json['x96']);
	if (x96 != null) {
		shikimoriCalendarQueryListAnimeImage.x96 = x96;
	}
	final String? x48 = jsonConvert.convert<String>(json['x48']);
	if (x48 != null) {
		shikimoriCalendarQueryListAnimeImage.x48 = x48;
	}
	return shikimoriCalendarQueryListAnimeImage;
}

Map<String, dynamic> $ShikimoriCalendarQueryListAnimeImageToJson(ShikimoriCalendarQueryListAnimeImage entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['original'] = entity.original;
	data['preview'] = entity.preview;
	data['x96'] = entity.x96;
	data['x48'] = entity.x48;
	return data;
}

extension ShikimoriCalendarQueryListAnimeImageExtension on ShikimoriCalendarQueryListAnimeImage {
	ShikimoriCalendarQueryListAnimeImage copyWith({
	String? original,
	String? preview,
	String? x96,
	String? x48,
	}) {
		return ShikimoriCalendarQueryListAnimeImage()
			..original = original ?? this.original
			..preview = preview ?? this.preview
			..x96 = x96 ?? this.x96
			..x48 = x48 ?? this.x48;
	}
}

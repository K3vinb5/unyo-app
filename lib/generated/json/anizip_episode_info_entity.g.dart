import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/anizip/anizip_episode_info_entity.dart';

AnizipEpisodeInfoEntity $AnizipEpisodeInfoEntityFromJson(Map<String, dynamic> json) {
	final AnizipEpisodeInfoEntity anizipEpisodeInfoEntity = AnizipEpisodeInfoEntity();
	final int? tvdbShowId = jsonConvert.convert<int>(json['tvdbShowId']);
	if (tvdbShowId != null) {
		anizipEpisodeInfoEntity.tvdbShowId = tvdbShowId;
	}
	final int? tvdbId = jsonConvert.convert<int>(json['tvdbId']);
	if (tvdbId != null) {
		anizipEpisodeInfoEntity.tvdbId = tvdbId;
	}
	final int? seasonNumber = jsonConvert.convert<int>(json['seasonNumber']);
	if (seasonNumber != null) {
		anizipEpisodeInfoEntity.seasonNumber = seasonNumber;
	}
	final int? episodeNumber = jsonConvert.convert<int>(json['episodeNumber']);
	if (episodeNumber != null) {
		anizipEpisodeInfoEntity.episodeNumber = episodeNumber;
	}
	final int? absoluteEpisodeNumber = jsonConvert.convert<int>(json['absoluteEpisodeNumber']);
	if (absoluteEpisodeNumber != null) {
		anizipEpisodeInfoEntity.absoluteEpisodeNumber = absoluteEpisodeNumber;
	}
	final AnizipEpisodeInfoTitle? title = jsonConvert.convert<AnizipEpisodeInfoTitle>(json['title']);
	if (title != null) {
		anizipEpisodeInfoEntity.title = title;
	}
	final String? airDate = jsonConvert.convert<String>(json['airDate']);
	if (airDate != null) {
		anizipEpisodeInfoEntity.airDate = airDate;
	}
	final String? airDateUtc = jsonConvert.convert<String>(json['airDateUtc']);
	if (airDateUtc != null) {
		anizipEpisodeInfoEntity.airDateUtc = airDateUtc;
	}
	final int? runtime = jsonConvert.convert<int>(json['runtime']);
	if (runtime != null) {
		anizipEpisodeInfoEntity.runtime = runtime;
	}
	final String? overview = jsonConvert.convert<String>(json['overview']);
	if (overview != null) {
		anizipEpisodeInfoEntity.overview = overview;
	}
	final String? image = jsonConvert.convert<String>(json['image']);
	if (image != null) {
		anizipEpisodeInfoEntity.image = image;
	}
	final String? episode = jsonConvert.convert<String>(json['episode']);
	if (episode != null) {
		anizipEpisodeInfoEntity.episode = episode;
	}
	final int? anidbEid = jsonConvert.convert<int>(json['anidbEid']);
	if (anidbEid != null) {
		anizipEpisodeInfoEntity.anidbEid = anidbEid;
	}
	final int? length = jsonConvert.convert<int>(json['length']);
	if (length != null) {
		anizipEpisodeInfoEntity.length = length;
	}
	final String? airdate = jsonConvert.convert<String>(json['airdate']);
	if (airdate != null) {
		anizipEpisodeInfoEntity.airdate = airdate;
	}
	final String? rating = jsonConvert.convert<String>(json['rating']);
	if (rating != null) {
		anizipEpisodeInfoEntity.rating = rating;
	}
	final String? summary = jsonConvert.convert<String>(json['summary']);
	if (summary != null) {
		anizipEpisodeInfoEntity.summary = summary;
	}
	return anizipEpisodeInfoEntity;
}

Map<String, dynamic> $AnizipEpisodeInfoEntityToJson(AnizipEpisodeInfoEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['tvdbShowId'] = entity.tvdbShowId;
	data['tvdbId'] = entity.tvdbId;
	data['seasonNumber'] = entity.seasonNumber;
	data['episodeNumber'] = entity.episodeNumber;
	data['absoluteEpisodeNumber'] = entity.absoluteEpisodeNumber;
	data['title'] = entity.title.toJson();
	data['airDate'] = entity.airDate;
	data['airDateUtc'] = entity.airDateUtc;
	data['runtime'] = entity.runtime;
	data['overview'] = entity.overview;
	data['image'] = entity.image;
	data['episode'] = entity.episode;
	data['anidbEid'] = entity.anidbEid;
	data['length'] = entity.length;
	data['airdate'] = entity.airdate;
	data['rating'] = entity.rating;
	data['summary'] = entity.summary;
	return data;
}

extension AnizipEpisodeInfoEntityExtension on AnizipEpisodeInfoEntity {
	AnizipEpisodeInfoEntity copyWith({
	int? tvdbShowId,
	int? tvdbId,
	int? seasonNumber,
	int? episodeNumber,
	int? absoluteEpisodeNumber,
	AnizipEpisodeInfoTitle? title,
	String? airDate,
	String? airDateUtc,
	int? runtime,
	String? overview,
	String? image,
	String? episode,
	int? anidbEid,
	int? length,
	String? airdate,
	String? rating,
	String? summary,
	}) {
		return AnizipEpisodeInfoEntity()
			..tvdbShowId = tvdbShowId ?? this.tvdbShowId
			..tvdbId = tvdbId ?? this.tvdbId
			..seasonNumber = seasonNumber ?? this.seasonNumber
			..episodeNumber = episodeNumber ?? this.episodeNumber
			..absoluteEpisodeNumber = absoluteEpisodeNumber ?? this.absoluteEpisodeNumber
			..title = title ?? this.title
			..airDate = airDate ?? this.airDate
			..airDateUtc = airDateUtc ?? this.airDateUtc
			..runtime = runtime ?? this.runtime
			..overview = overview ?? this.overview
			..image = image ?? this.image
			..episode = episode ?? this.episode
			..anidbEid = anidbEid ?? this.anidbEid
			..length = length ?? this.length
			..airdate = airdate ?? this.airdate
			..rating = rating ?? this.rating
			..summary = summary ?? this.summary;
	}
}


AnizipEpisodeInfoTitle $AnizipEpisodeInfoTitleFromJson(Map<String, dynamic> json) {
	final AnizipEpisodeInfoTitle anizipEpisodeInfoTitle = AnizipEpisodeInfoTitle();
	final String? ja = jsonConvert.convert<String>(json['ja']);
	if (ja != null) {
		anizipEpisodeInfoTitle.ja = ja;
	}
	final String? en = jsonConvert.convert<String>(json['en']);
	if (en != null) {
		anizipEpisodeInfoTitle.en = en;
	}
	final String? fr = jsonConvert.convert<String>(json['fr']);
	if (fr != null) {
		anizipEpisodeInfoTitle.fr = fr;
	}
	final String? xJat = jsonConvert.convert<String>(json['x-jat']);
	if (xJat != null) {
		anizipEpisodeInfoTitle.xJat = xJat;
	}
	return anizipEpisodeInfoTitle;
}

Map<String, dynamic> $AnizipEpisodeInfoTitleToJson(AnizipEpisodeInfoTitle entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['ja'] = entity.ja;
	data['en'] = entity.en;
	data['fr'] = entity.fr;
	data['x-jat'] = entity.xJat;
	return data;
}

extension AnizipEpisodeInfoTitleExtension on AnizipEpisodeInfoTitle {
	AnizipEpisodeInfoTitle copyWith({
	String? ja,
	String? en,
	String? fr,
	String? xJat,
	}) {
		return AnizipEpisodeInfoTitle()
			..ja = ja ?? this.ja
			..en = en ?? this.en
			..fr = fr ?? this.fr
			..xJat = xJat ?? this.xJat;
	}
}

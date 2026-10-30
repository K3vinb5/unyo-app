import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_list_query_entity.dart';

AnimeListQueryEntity $AnimeListQueryEntityFromJson(Map<String, dynamic> json) {
	final AnimeListQueryEntity animeListQueryEntity = AnimeListQueryEntity();
	final List<AnimeListQueryAnimes>? animes = (json['animes'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AnimeListQueryAnimes>(e) as AnimeListQueryAnimes).toList();
	if (animes != null) {
		animeListQueryEntity.animes = animes;
	}
	return animeListQueryEntity;
}

Map<String, dynamic> $AnimeListQueryEntityToJson(AnimeListQueryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['animes'] =  entity.animes.map((v) => v.toJson()).toList();
	return data;
}

extension AnimeListQueryEntityExtension on AnimeListQueryEntity {
	AnimeListQueryEntity copyWith({
	List<AnimeListQueryAnimes>? animes,
	}) {
		return AnimeListQueryEntity()
			..animes = animes ?? this.animes;
	}
}


AnimeListQueryAnimes $AnimeListQueryAnimesFromJson(Map<String, dynamic> json) {
	final AnimeListQueryAnimes animeListQueryAnimes = AnimeListQueryAnimes();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		animeListQueryAnimes.id = id;
	}
	final String? malId = jsonConvert.convert<String>(json['malId']);
	if (malId != null) {
		animeListQueryAnimes.malId = malId;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		animeListQueryAnimes.name = name;
	}
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		animeListQueryAnimes.english = english;
	}
	final String? japanese = jsonConvert.convert<String>(json['japanese']);
	if (japanese != null) {
		animeListQueryAnimes.japanese = japanese;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		animeListQueryAnimes.russian = russian;
	}
	final AnimeListQueryAnimesPoster? poster = jsonConvert.convert<AnimeListQueryAnimesPoster>(json['poster']);
	if (poster != null) {
		animeListQueryAnimes.poster = poster;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		animeListQueryAnimes.description = description;
	}
	final int? duration = jsonConvert.convert<int>(json['duration']);
	if (duration != null) {
		animeListQueryAnimes.duration = duration;
	}
	final AnimeListQueryAnimesAiredOn? airedOn = jsonConvert.convert<AnimeListQueryAnimesAiredOn>(json['airedOn']);
	if (airedOn != null) {
		animeListQueryAnimes.airedOn = airedOn;
	}
	final AnimeListQueryAnimesReleasedOn? releasedOn = jsonConvert.convert<AnimeListQueryAnimesReleasedOn>(json['releasedOn']);
	if (releasedOn != null) {
		animeListQueryAnimes.releasedOn = releasedOn;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		animeListQueryAnimes.episodes = episodes;
	}
	final int? episodesAired = jsonConvert.convert<int>(json['episodesAired']);
	if (episodesAired != null) {
		animeListQueryAnimes.episodesAired = episodesAired;
	}
	final String? nextEpisodeAt = jsonConvert.convert<String>(json['nextEpisodeAt']);
	if (nextEpisodeAt != null) {
		animeListQueryAnimes.nextEpisodeAt = nextEpisodeAt;
	}
	final List<AnimeListQueryAnimesGenres>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AnimeListQueryAnimesGenres>(e) as AnimeListQueryAnimesGenres).toList();
	if (genres != null) {
		animeListQueryAnimes.genres = genres;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		animeListQueryAnimes.kind = kind;
	}
	final bool? isCensored = jsonConvert.convert<bool>(json['isCensored']);
	if (isCensored != null) {
		animeListQueryAnimes.isCensored = isCensored;
	}
	final double? score = jsonConvert.convert<double>(json['score']);
	if (score != null) {
		animeListQueryAnimes.score = score;
	}
	final String? season = jsonConvert.convert<String>(json['season']);
	if (season != null) {
		animeListQueryAnimes.season = season;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		animeListQueryAnimes.status = status;
	}
	return animeListQueryAnimes;
}

Map<String, dynamic> $AnimeListQueryAnimesToJson(AnimeListQueryAnimes entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['malId'] = entity.malId;
	data['name'] = entity.name;
	data['english'] = entity.english;
	data['japanese'] = entity.japanese;
	data['russian'] = entity.russian;
	data['poster'] = entity.poster.toJson();
	data['description'] = entity.description;
	data['duration'] = entity.duration;
	data['airedOn'] = entity.airedOn.toJson();
	data['releasedOn'] = entity.releasedOn.toJson();
	data['episodes'] = entity.episodes;
	data['episodesAired'] = entity.episodesAired;
	data['nextEpisodeAt'] = entity.nextEpisodeAt;
	data['genres'] =  entity.genres.map((v) => v.toJson()).toList();
	data['kind'] = entity.kind;
	data['isCensored'] = entity.isCensored;
	data['score'] = entity.score;
	data['season'] = entity.season;
	data['status'] = entity.status;
	return data;
}

extension AnimeListQueryAnimesExtension on AnimeListQueryAnimes {
	AnimeListQueryAnimes copyWith({
	String? id,
	String? malId,
	String? name,
	String? english,
	String? japanese,
	String? russian,
	AnimeListQueryAnimesPoster? poster,
	String? description,
	int? duration,
	AnimeListQueryAnimesAiredOn? airedOn,
	AnimeListQueryAnimesReleasedOn? releasedOn,
	int? episodes,
	int? episodesAired,
	String? nextEpisodeAt,
	List<AnimeListQueryAnimesGenres>? genres,
	String? kind,
	bool? isCensored,
	double? score,
	String? season,
	String? status,
	}) {
		return AnimeListQueryAnimes()
			..id = id ?? this.id
			..malId = malId ?? this.malId
			..name = name ?? this.name
			..english = english ?? this.english
			..japanese = japanese ?? this.japanese
			..russian = russian ?? this.russian
			..poster = poster ?? this.poster
			..description = description ?? this.description
			..duration = duration ?? this.duration
			..airedOn = airedOn ?? this.airedOn
			..releasedOn = releasedOn ?? this.releasedOn
			..episodes = episodes ?? this.episodes
			..episodesAired = episodesAired ?? this.episodesAired
			..nextEpisodeAt = nextEpisodeAt ?? this.nextEpisodeAt
			..genres = genres ?? this.genres
			..kind = kind ?? this.kind
			..isCensored = isCensored ?? this.isCensored
			..score = score ?? this.score
			..season = season ?? this.season
			..status = status ?? this.status;
	}
}


AnimeListQueryAnimesPoster $AnimeListQueryAnimesPosterFromJson(Map<String, dynamic> json) {
	final AnimeListQueryAnimesPoster animeListQueryAnimesPoster = AnimeListQueryAnimesPoster();
	final String? originalUrl = jsonConvert.convert<String>(json['originalUrl']);
	if (originalUrl != null) {
		animeListQueryAnimesPoster.originalUrl = originalUrl;
	}
	final String? mainAlt2xUrl = jsonConvert.convert<String>(json['mainAlt2xUrl']);
	if (mainAlt2xUrl != null) {
		animeListQueryAnimesPoster.mainAlt2xUrl = mainAlt2xUrl;
	}
	return animeListQueryAnimesPoster;
}

Map<String, dynamic> $AnimeListQueryAnimesPosterToJson(AnimeListQueryAnimesPoster entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['originalUrl'] = entity.originalUrl;
	data['mainAlt2xUrl'] = entity.mainAlt2xUrl;
	return data;
}

extension AnimeListQueryAnimesPosterExtension on AnimeListQueryAnimesPoster {
	AnimeListQueryAnimesPoster copyWith({
	String? originalUrl,
	String? mainAlt2xUrl,
	}) {
		return AnimeListQueryAnimesPoster()
			..originalUrl = originalUrl ?? this.originalUrl
			..mainAlt2xUrl = mainAlt2xUrl ?? this.mainAlt2xUrl;
	}
}


AnimeListQueryAnimesAiredOn $AnimeListQueryAnimesAiredOnFromJson(Map<String, dynamic> json) {
	final AnimeListQueryAnimesAiredOn animeListQueryAnimesAiredOn = AnimeListQueryAnimesAiredOn();
	final String? date = jsonConvert.convert<String>(json['date']);
	if (date != null) {
		animeListQueryAnimesAiredOn.date = date;
	}
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		animeListQueryAnimesAiredOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		animeListQueryAnimesAiredOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		animeListQueryAnimesAiredOn.year = year;
	}
	return animeListQueryAnimesAiredOn;
}

Map<String, dynamic> $AnimeListQueryAnimesAiredOnToJson(AnimeListQueryAnimesAiredOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['date'] = entity.date;
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension AnimeListQueryAnimesAiredOnExtension on AnimeListQueryAnimesAiredOn {
	AnimeListQueryAnimesAiredOn copyWith({
	String? date,
	int? day,
	int? month,
	int? year,
	}) {
		return AnimeListQueryAnimesAiredOn()
			..date = date ?? this.date
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


AnimeListQueryAnimesReleasedOn $AnimeListQueryAnimesReleasedOnFromJson(Map<String, dynamic> json) {
	final AnimeListQueryAnimesReleasedOn animeListQueryAnimesReleasedOn = AnimeListQueryAnimesReleasedOn();
	final String? date = jsonConvert.convert<String>(json['date']);
	if (date != null) {
		animeListQueryAnimesReleasedOn.date = date;
	}
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		animeListQueryAnimesReleasedOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		animeListQueryAnimesReleasedOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		animeListQueryAnimesReleasedOn.year = year;
	}
	return animeListQueryAnimesReleasedOn;
}

Map<String, dynamic> $AnimeListQueryAnimesReleasedOnToJson(AnimeListQueryAnimesReleasedOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['date'] = entity.date;
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension AnimeListQueryAnimesReleasedOnExtension on AnimeListQueryAnimesReleasedOn {
	AnimeListQueryAnimesReleasedOn copyWith({
	String? date,
	int? day,
	int? month,
	int? year,
	}) {
		return AnimeListQueryAnimesReleasedOn()
			..date = date ?? this.date
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


AnimeListQueryAnimesGenres $AnimeListQueryAnimesGenresFromJson(Map<String, dynamic> json) {
	final AnimeListQueryAnimesGenres animeListQueryAnimesGenres = AnimeListQueryAnimesGenres();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		animeListQueryAnimesGenres.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		animeListQueryAnimesGenres.name = name;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		animeListQueryAnimesGenres.kind = kind;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		animeListQueryAnimesGenres.russian = russian;
	}
	return animeListQueryAnimesGenres;
}

Map<String, dynamic> $AnimeListQueryAnimesGenresToJson(AnimeListQueryAnimesGenres entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['kind'] = entity.kind;
	data['russian'] = entity.russian;
	return data;
}

extension AnimeListQueryAnimesGenresExtension on AnimeListQueryAnimesGenres {
	AnimeListQueryAnimesGenres copyWith({
	String? id,
	String? name,
	String? kind,
	String? russian,
	}) {
		return AnimeListQueryAnimesGenres()
			..id = id ?? this.id
			..name = name ?? this.name
			..kind = kind ?? this.kind
			..russian = russian ?? this.russian;
	}
}

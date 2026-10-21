import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_popular_query_entity.dart';

AnimePopularQueryEntity $AnimePopularQueryEntityFromJson(Map<String, dynamic> json) {
	final AnimePopularQueryEntity animePopularQueryEntity = AnimePopularQueryEntity();
	final List<AnimePopularQueryAnimes>? animes = (json['animes'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AnimePopularQueryAnimes>(e) as AnimePopularQueryAnimes).toList();
	if (animes != null) {
		animePopularQueryEntity.animes = animes;
	}
	return animePopularQueryEntity;
}

Map<String, dynamic> $AnimePopularQueryEntityToJson(AnimePopularQueryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['animes'] =  entity.animes.map((v) => v.toJson()).toList();
	return data;
}

extension AnimePopularQueryEntityExtension on AnimePopularQueryEntity {
	AnimePopularQueryEntity copyWith({
	List<AnimePopularQueryAnimes>? animes,
	}) {
		return AnimePopularQueryEntity()
			..animes = animes ?? this.animes;
	}
}


AnimePopularQueryAnimes $AnimePopularQueryAnimesFromJson(Map<String, dynamic> json) {
	final AnimePopularQueryAnimes animePopularQueryAnimes = AnimePopularQueryAnimes();
	final String? malId = jsonConvert.convert<String>(json['malId']);
	if (malId != null) {
		animePopularQueryAnimes.malId = malId;
	}
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		animePopularQueryAnimes.id = id;
	}
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		animePopularQueryAnimes.english = english;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		animePopularQueryAnimes.name = name;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		animePopularQueryAnimes.russian = russian;
	}
	final String? japanese = jsonConvert.convert<String>(json['japanese']);
	if (japanese != null) {
		animePopularQueryAnimes.japanese = japanese;
	}
	final AnimePopularQueryAnimesPoster? poster = jsonConvert.convert<AnimePopularQueryAnimesPoster>(json['poster']);
	if (poster != null) {
		animePopularQueryAnimes.poster = poster;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		animePopularQueryAnimes.description = description;
	}
	final int? duration = jsonConvert.convert<int>(json['duration']);
	if (duration != null) {
		animePopularQueryAnimes.duration = duration;
	}
	final AnimePopularQueryAnimesAiredOn? airedOn = jsonConvert.convert<AnimePopularQueryAnimesAiredOn>(json['airedOn']);
	if (airedOn != null) {
		animePopularQueryAnimes.airedOn = airedOn;
	}
	final AnimePopularQueryAnimesReleasedOn? releasedOn = jsonConvert.convert<AnimePopularQueryAnimesReleasedOn>(json['releasedOn']);
	if (releasedOn != null) {
		animePopularQueryAnimes.releasedOn = releasedOn;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		animePopularQueryAnimes.episodes = episodes;
	}
	final String? nextEpisodeAt = jsonConvert.convert<String>(json['nextEpisodeAt']);
	if (nextEpisodeAt != null) {
		animePopularQueryAnimes.nextEpisodeAt = nextEpisodeAt;
	}
	final List<AnimePopularQueryAnimesGenres>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AnimePopularQueryAnimesGenres>(e) as AnimePopularQueryAnimesGenres).toList();
	if (genres != null) {
		animePopularQueryAnimes.genres = genres;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		animePopularQueryAnimes.kind = kind;
	}
	final bool? isCensored = jsonConvert.convert<bool>(json['isCensored']);
	if (isCensored != null) {
		animePopularQueryAnimes.isCensored = isCensored;
	}
	final double? score = jsonConvert.convert<double>(json['score']);
	if (score != null) {
		animePopularQueryAnimes.score = score;
	}
	final String? season = jsonConvert.convert<String>(json['season']);
	if (season != null) {
		animePopularQueryAnimes.season = season;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		animePopularQueryAnimes.status = status;
	}
	return animePopularQueryAnimes;
}

Map<String, dynamic> $AnimePopularQueryAnimesToJson(AnimePopularQueryAnimes entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['malId'] = entity.malId;
	data['id'] = entity.id;
	data['english'] = entity.english;
	data['name'] = entity.name;
	data['russian'] = entity.russian;
	data['japanese'] = entity.japanese;
	data['poster'] = entity.poster.toJson();
	data['description'] = entity.description;
	data['duration'] = entity.duration;
	data['airedOn'] = entity.airedOn.toJson();
	data['releasedOn'] = entity.releasedOn.toJson();
	data['episodes'] = entity.episodes;
	data['nextEpisodeAt'] = entity.nextEpisodeAt;
	data['genres'] =  entity.genres.map((v) => v.toJson()).toList();
	data['kind'] = entity.kind;
	data['isCensored'] = entity.isCensored;
	data['score'] = entity.score;
	data['season'] = entity.season;
	data['status'] = entity.status;
	return data;
}

extension AnimePopularQueryAnimesExtension on AnimePopularQueryAnimes {
	AnimePopularQueryAnimes copyWith({
	String? malId,
	String? id,
	String? english,
	String? name,
	String? russian,
	String? japanese,
	AnimePopularQueryAnimesPoster? poster,
	String? description,
	int? duration,
	AnimePopularQueryAnimesAiredOn? airedOn,
	AnimePopularQueryAnimesReleasedOn? releasedOn,
	int? episodes,
	String? nextEpisodeAt,
	List<AnimePopularQueryAnimesGenres>? genres,
	String? kind,
	bool? isCensored,
	double? score,
	String? season,
	String? status,
	}) {
		return AnimePopularQueryAnimes()
			..malId = malId ?? this.malId
			..id = id ?? this.id
			..english = english ?? this.english
			..name = name ?? this.name
			..russian = russian ?? this.russian
			..japanese = japanese ?? this.japanese
			..poster = poster ?? this.poster
			..description = description ?? this.description
			..duration = duration ?? this.duration
			..airedOn = airedOn ?? this.airedOn
			..releasedOn = releasedOn ?? this.releasedOn
			..episodes = episodes ?? this.episodes
			..nextEpisodeAt = nextEpisodeAt ?? this.nextEpisodeAt
			..genres = genres ?? this.genres
			..kind = kind ?? this.kind
			..isCensored = isCensored ?? this.isCensored
			..score = score ?? this.score
			..season = season ?? this.season
			..status = status ?? this.status;
	}
}


AnimePopularQueryAnimesPoster $AnimePopularQueryAnimesPosterFromJson(Map<String, dynamic> json) {
	final AnimePopularQueryAnimesPoster animePopularQueryAnimesPoster = AnimePopularQueryAnimesPoster();
	final String? originalUrl = jsonConvert.convert<String>(json['originalUrl']);
	if (originalUrl != null) {
		animePopularQueryAnimesPoster.originalUrl = originalUrl;
	}
	final String? mainAlt2xUrl = jsonConvert.convert<String>(json['mainAlt2xUrl']);
	if (mainAlt2xUrl != null) {
		animePopularQueryAnimesPoster.mainAlt2xUrl = mainAlt2xUrl;
	}
	return animePopularQueryAnimesPoster;
}

Map<String, dynamic> $AnimePopularQueryAnimesPosterToJson(AnimePopularQueryAnimesPoster entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['originalUrl'] = entity.originalUrl;
	data['mainAlt2xUrl'] = entity.mainAlt2xUrl;
	return data;
}

extension AnimePopularQueryAnimesPosterExtension on AnimePopularQueryAnimesPoster {
	AnimePopularQueryAnimesPoster copyWith({
	String? originalUrl,
	String? mainAlt2xUrl,
	}) {
		return AnimePopularQueryAnimesPoster()
			..originalUrl = originalUrl ?? this.originalUrl
			..mainAlt2xUrl = mainAlt2xUrl ?? this.mainAlt2xUrl;
	}
}


AnimePopularQueryAnimesAiredOn $AnimePopularQueryAnimesAiredOnFromJson(Map<String, dynamic> json) {
	final AnimePopularQueryAnimesAiredOn animePopularQueryAnimesAiredOn = AnimePopularQueryAnimesAiredOn();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		animePopularQueryAnimesAiredOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		animePopularQueryAnimesAiredOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		animePopularQueryAnimesAiredOn.year = year;
	}
	return animePopularQueryAnimesAiredOn;
}

Map<String, dynamic> $AnimePopularQueryAnimesAiredOnToJson(AnimePopularQueryAnimesAiredOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension AnimePopularQueryAnimesAiredOnExtension on AnimePopularQueryAnimesAiredOn {
	AnimePopularQueryAnimesAiredOn copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return AnimePopularQueryAnimesAiredOn()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


AnimePopularQueryAnimesReleasedOn $AnimePopularQueryAnimesReleasedOnFromJson(Map<String, dynamic> json) {
	final AnimePopularQueryAnimesReleasedOn animePopularQueryAnimesReleasedOn = AnimePopularQueryAnimesReleasedOn();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		animePopularQueryAnimesReleasedOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		animePopularQueryAnimesReleasedOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		animePopularQueryAnimesReleasedOn.year = year;
	}
	return animePopularQueryAnimesReleasedOn;
}

Map<String, dynamic> $AnimePopularQueryAnimesReleasedOnToJson(AnimePopularQueryAnimesReleasedOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension AnimePopularQueryAnimesReleasedOnExtension on AnimePopularQueryAnimesReleasedOn {
	AnimePopularQueryAnimesReleasedOn copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return AnimePopularQueryAnimesReleasedOn()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


AnimePopularQueryAnimesGenres $AnimePopularQueryAnimesGenresFromJson(Map<String, dynamic> json) {
	final AnimePopularQueryAnimesGenres animePopularQueryAnimesGenres = AnimePopularQueryAnimesGenres();
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		animePopularQueryAnimesGenres.kind = kind;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		animePopularQueryAnimesGenres.name = name;
	}
	return animePopularQueryAnimesGenres;
}

Map<String, dynamic> $AnimePopularQueryAnimesGenresToJson(AnimePopularQueryAnimesGenres entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['kind'] = entity.kind;
	data['name'] = entity.name;
	return data;
}

extension AnimePopularQueryAnimesGenresExtension on AnimePopularQueryAnimesGenres {
	AnimePopularQueryAnimesGenres copyWith({
	String? kind,
	String? name,
	}) {
		return AnimePopularQueryAnimesGenres()
			..kind = kind ?? this.kind
			..name = name ?? this.name;
	}
}

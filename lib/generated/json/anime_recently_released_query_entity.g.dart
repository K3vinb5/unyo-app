import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_recently_released_query_entity.dart';

AnimeRecentlyReleasedQueryEntity $AnimeRecentlyReleasedQueryEntityFromJson(Map<String, dynamic> json) {
	final AnimeRecentlyReleasedQueryEntity animeRecentlyReleasedQueryEntity = AnimeRecentlyReleasedQueryEntity();
	final List<AnimeRecentlyReleasedQueryAnimes>? animes = (json['animes'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AnimeRecentlyReleasedQueryAnimes>(e) as AnimeRecentlyReleasedQueryAnimes).toList();
	if (animes != null) {
		animeRecentlyReleasedQueryEntity.animes = animes;
	}
	return animeRecentlyReleasedQueryEntity;
}

Map<String, dynamic> $AnimeRecentlyReleasedQueryEntityToJson(AnimeRecentlyReleasedQueryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['animes'] =  entity.animes.map((v) => v.toJson()).toList();
	return data;
}

extension AnimeRecentlyReleasedQueryEntityExtension on AnimeRecentlyReleasedQueryEntity {
	AnimeRecentlyReleasedQueryEntity copyWith({
	List<AnimeRecentlyReleasedQueryAnimes>? animes,
	}) {
		return AnimeRecentlyReleasedQueryEntity()
			..animes = animes ?? this.animes;
	}
}


AnimeRecentlyReleasedQueryAnimes $AnimeRecentlyReleasedQueryAnimesFromJson(Map<String, dynamic> json) {
	final AnimeRecentlyReleasedQueryAnimes animeRecentlyReleasedQueryAnimes = AnimeRecentlyReleasedQueryAnimes();
	final String? malId = jsonConvert.convert<String>(json['malId']);
	if (malId != null) {
		animeRecentlyReleasedQueryAnimes.malId = malId;
	}
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		animeRecentlyReleasedQueryAnimes.id = id;
	}
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		animeRecentlyReleasedQueryAnimes.english = english;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		animeRecentlyReleasedQueryAnimes.name = name;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		animeRecentlyReleasedQueryAnimes.russian = russian;
	}
	final String? japanese = jsonConvert.convert<String>(json['japanese']);
	if (japanese != null) {
		animeRecentlyReleasedQueryAnimes.japanese = japanese;
	}
	final AnimeRecentlyReleasedQueryAnimesPoster? poster = jsonConvert.convert<AnimeRecentlyReleasedQueryAnimesPoster>(json['poster']);
	if (poster != null) {
		animeRecentlyReleasedQueryAnimes.poster = poster;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		animeRecentlyReleasedQueryAnimes.description = description;
	}
	final int? duration = jsonConvert.convert<int>(json['duration']);
	if (duration != null) {
		animeRecentlyReleasedQueryAnimes.duration = duration;
	}
	final AnimeRecentlyReleasedQueryAnimesAiredOn? airedOn = jsonConvert.convert<AnimeRecentlyReleasedQueryAnimesAiredOn>(json['airedOn']);
	if (airedOn != null) {
		animeRecentlyReleasedQueryAnimes.airedOn = airedOn;
	}
	final AnimeRecentlyReleasedQueryAnimesReleasedOn? releasedOn = jsonConvert.convert<AnimeRecentlyReleasedQueryAnimesReleasedOn>(json['releasedOn']);
	if (releasedOn != null) {
		animeRecentlyReleasedQueryAnimes.releasedOn = releasedOn;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		animeRecentlyReleasedQueryAnimes.episodes = episodes;
	}
	final dynamic nextEpisodeAt = json['nextEpisodeAt'];
	if (nextEpisodeAt != null) {
		animeRecentlyReleasedQueryAnimes.nextEpisodeAt = nextEpisodeAt;
	}
	final List<AnimeRecentlyReleasedQueryAnimesGenres>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AnimeRecentlyReleasedQueryAnimesGenres>(e) as AnimeRecentlyReleasedQueryAnimesGenres).toList();
	if (genres != null) {
		animeRecentlyReleasedQueryAnimes.genres = genres;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		animeRecentlyReleasedQueryAnimes.kind = kind;
	}
	final bool? isCensored = jsonConvert.convert<bool>(json['isCensored']);
	if (isCensored != null) {
		animeRecentlyReleasedQueryAnimes.isCensored = isCensored;
	}
	final double? score = jsonConvert.convert<double>(json['score']);
	if (score != null) {
		animeRecentlyReleasedQueryAnimes.score = score;
	}
	final String? season = jsonConvert.convert<String>(json['season']);
	if (season != null) {
		animeRecentlyReleasedQueryAnimes.season = season;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		animeRecentlyReleasedQueryAnimes.status = status;
	}
	return animeRecentlyReleasedQueryAnimes;
}

Map<String, dynamic> $AnimeRecentlyReleasedQueryAnimesToJson(AnimeRecentlyReleasedQueryAnimes entity) {
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

extension AnimeRecentlyReleasedQueryAnimesExtension on AnimeRecentlyReleasedQueryAnimes {
	AnimeRecentlyReleasedQueryAnimes copyWith({
	String? malId,
	String? id,
	String? english,
	String? name,
	String? russian,
	String? japanese,
	AnimeRecentlyReleasedQueryAnimesPoster? poster,
	String? description,
	int? duration,
	AnimeRecentlyReleasedQueryAnimesAiredOn? airedOn,
	AnimeRecentlyReleasedQueryAnimesReleasedOn? releasedOn,
	int? episodes,
	dynamic nextEpisodeAt,
	List<AnimeRecentlyReleasedQueryAnimesGenres>? genres,
	String? kind,
	bool? isCensored,
	double? score,
	String? season,
	String? status,
	}) {
		return AnimeRecentlyReleasedQueryAnimes()
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


AnimeRecentlyReleasedQueryAnimesPoster $AnimeRecentlyReleasedQueryAnimesPosterFromJson(Map<String, dynamic> json) {
	final AnimeRecentlyReleasedQueryAnimesPoster animeRecentlyReleasedQueryAnimesPoster = AnimeRecentlyReleasedQueryAnimesPoster();
	final String? originalUrl = jsonConvert.convert<String>(json['originalUrl']);
	if (originalUrl != null) {
		animeRecentlyReleasedQueryAnimesPoster.originalUrl = originalUrl;
	}
	final String? mainAlt2xUrl = jsonConvert.convert<String>(json['mainAlt2xUrl']);
	if (mainAlt2xUrl != null) {
		animeRecentlyReleasedQueryAnimesPoster.mainAlt2xUrl = mainAlt2xUrl;
	}
	return animeRecentlyReleasedQueryAnimesPoster;
}

Map<String, dynamic> $AnimeRecentlyReleasedQueryAnimesPosterToJson(AnimeRecentlyReleasedQueryAnimesPoster entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['originalUrl'] = entity.originalUrl;
	data['mainAlt2xUrl'] = entity.mainAlt2xUrl;
	return data;
}

extension AnimeRecentlyReleasedQueryAnimesPosterExtension on AnimeRecentlyReleasedQueryAnimesPoster {
	AnimeRecentlyReleasedQueryAnimesPoster copyWith({
	String? originalUrl,
	String? mainAlt2xUrl,
	}) {
		return AnimeRecentlyReleasedQueryAnimesPoster()
			..originalUrl = originalUrl ?? this.originalUrl
			..mainAlt2xUrl = mainAlt2xUrl ?? this.mainAlt2xUrl;
	}
}


AnimeRecentlyReleasedQueryAnimesAiredOn $AnimeRecentlyReleasedQueryAnimesAiredOnFromJson(Map<String, dynamic> json) {
	final AnimeRecentlyReleasedQueryAnimesAiredOn animeRecentlyReleasedQueryAnimesAiredOn = AnimeRecentlyReleasedQueryAnimesAiredOn();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		animeRecentlyReleasedQueryAnimesAiredOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		animeRecentlyReleasedQueryAnimesAiredOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		animeRecentlyReleasedQueryAnimesAiredOn.year = year;
	}
	return animeRecentlyReleasedQueryAnimesAiredOn;
}

Map<String, dynamic> $AnimeRecentlyReleasedQueryAnimesAiredOnToJson(AnimeRecentlyReleasedQueryAnimesAiredOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension AnimeRecentlyReleasedQueryAnimesAiredOnExtension on AnimeRecentlyReleasedQueryAnimesAiredOn {
	AnimeRecentlyReleasedQueryAnimesAiredOn copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return AnimeRecentlyReleasedQueryAnimesAiredOn()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


AnimeRecentlyReleasedQueryAnimesReleasedOn $AnimeRecentlyReleasedQueryAnimesReleasedOnFromJson(Map<String, dynamic> json) {
	final AnimeRecentlyReleasedQueryAnimesReleasedOn animeRecentlyReleasedQueryAnimesReleasedOn = AnimeRecentlyReleasedQueryAnimesReleasedOn();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		animeRecentlyReleasedQueryAnimesReleasedOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		animeRecentlyReleasedQueryAnimesReleasedOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		animeRecentlyReleasedQueryAnimesReleasedOn.year = year;
	}
	return animeRecentlyReleasedQueryAnimesReleasedOn;
}

Map<String, dynamic> $AnimeRecentlyReleasedQueryAnimesReleasedOnToJson(AnimeRecentlyReleasedQueryAnimesReleasedOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension AnimeRecentlyReleasedQueryAnimesReleasedOnExtension on AnimeRecentlyReleasedQueryAnimesReleasedOn {
	AnimeRecentlyReleasedQueryAnimesReleasedOn copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return AnimeRecentlyReleasedQueryAnimesReleasedOn()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


AnimeRecentlyReleasedQueryAnimesGenres $AnimeRecentlyReleasedQueryAnimesGenresFromJson(Map<String, dynamic> json) {
	final AnimeRecentlyReleasedQueryAnimesGenres animeRecentlyReleasedQueryAnimesGenres = AnimeRecentlyReleasedQueryAnimesGenres();
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		animeRecentlyReleasedQueryAnimesGenres.kind = kind;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		animeRecentlyReleasedQueryAnimesGenres.name = name;
	}
	return animeRecentlyReleasedQueryAnimesGenres;
}

Map<String, dynamic> $AnimeRecentlyReleasedQueryAnimesGenresToJson(AnimeRecentlyReleasedQueryAnimesGenres entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['kind'] = entity.kind;
	data['name'] = entity.name;
	return data;
}

extension AnimeRecentlyReleasedQueryAnimesGenresExtension on AnimeRecentlyReleasedQueryAnimesGenres {
	AnimeRecentlyReleasedQueryAnimesGenres copyWith({
	String? kind,
	String? name,
	}) {
		return AnimeRecentlyReleasedQueryAnimesGenres()
			..kind = kind ?? this.kind
			..name = name ?? this.name;
	}
}

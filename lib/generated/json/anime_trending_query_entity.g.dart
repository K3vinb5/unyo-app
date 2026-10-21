import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_trending_query_entity.dart';

AnimeTrendingQueryEntity $AnimeTrendingQueryEntityFromJson(Map<String, dynamic> json) {
	final AnimeTrendingQueryEntity animeTrendingQueryEntity = AnimeTrendingQueryEntity();
	final List<AnimeTrendingQueryAnimes>? animes = (json['animes'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AnimeTrendingQueryAnimes>(e) as AnimeTrendingQueryAnimes).toList();
	if (animes != null) {
		animeTrendingQueryEntity.animes = animes;
	}
	return animeTrendingQueryEntity;
}

Map<String, dynamic> $AnimeTrendingQueryEntityToJson(AnimeTrendingQueryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['animes'] =  entity.animes.map((v) => v.toJson()).toList();
	return data;
}

extension AnimeTrendingQueryEntityExtension on AnimeTrendingQueryEntity {
	AnimeTrendingQueryEntity copyWith({
	List<AnimeTrendingQueryAnimes>? animes,
	}) {
		return AnimeTrendingQueryEntity()
			..animes = animes ?? this.animes;
	}
}


AnimeTrendingQueryAnimes $AnimeTrendingQueryAnimesFromJson(Map<String, dynamic> json) {
	final AnimeTrendingQueryAnimes animeTrendingQueryAnimes = AnimeTrendingQueryAnimes();
	final String? malId = jsonConvert.convert<String>(json['malId']);
	if (malId != null) {
		animeTrendingQueryAnimes.malId = malId;
	}
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		animeTrendingQueryAnimes.id = id;
	}
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		animeTrendingQueryAnimes.english = english;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		animeTrendingQueryAnimes.name = name;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		animeTrendingQueryAnimes.russian = russian;
	}
	final String? japanese = jsonConvert.convert<String>(json['japanese']);
	if (japanese != null) {
		animeTrendingQueryAnimes.japanese = japanese;
	}
	final AnimeTrendingQueryAnimesPoster? poster = jsonConvert.convert<AnimeTrendingQueryAnimesPoster>(json['poster']);
	if (poster != null) {
		animeTrendingQueryAnimes.poster = poster;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		animeTrendingQueryAnimes.description = description;
	}
	final int? duration = jsonConvert.convert<int>(json['duration']);
	if (duration != null) {
		animeTrendingQueryAnimes.duration = duration;
	}
	final AnimeTrendingQueryAnimesAiredOn? airedOn = jsonConvert.convert<AnimeTrendingQueryAnimesAiredOn>(json['airedOn']);
	if (airedOn != null) {
		animeTrendingQueryAnimes.airedOn = airedOn;
	}
	final AnimeTrendingQueryAnimesReleasedOn? releasedOn = jsonConvert.convert<AnimeTrendingQueryAnimesReleasedOn>(json['releasedOn']);
	if (releasedOn != null) {
		animeTrendingQueryAnimes.releasedOn = releasedOn;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		animeTrendingQueryAnimes.episodes = episodes;
	}
	final String? nextEpisodeAt = jsonConvert.convert<String>(json['nextEpisodeAt']);
	if (nextEpisodeAt != null) {
		animeTrendingQueryAnimes.nextEpisodeAt = nextEpisodeAt;
	}
	final List<AnimeTrendingQueryAnimesGenres>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AnimeTrendingQueryAnimesGenres>(e) as AnimeTrendingQueryAnimesGenres).toList();
	if (genres != null) {
		animeTrendingQueryAnimes.genres = genres;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		animeTrendingQueryAnimes.kind = kind;
	}
	final bool? isCensored = jsonConvert.convert<bool>(json['isCensored']);
	if (isCensored != null) {
		animeTrendingQueryAnimes.isCensored = isCensored;
	}
	final double? score = jsonConvert.convert<double>(json['score']);
	if (score != null) {
		animeTrendingQueryAnimes.score = score;
	}
	final String? season = jsonConvert.convert<String>(json['season']);
	if (season != null) {
		animeTrendingQueryAnimes.season = season;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		animeTrendingQueryAnimes.status = status;
	}
	return animeTrendingQueryAnimes;
}

Map<String, dynamic> $AnimeTrendingQueryAnimesToJson(AnimeTrendingQueryAnimes entity) {
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

extension AnimeTrendingQueryAnimesExtension on AnimeTrendingQueryAnimes {
	AnimeTrendingQueryAnimes copyWith({
	String? malId,
	String? id,
	String? english,
	String? name,
	String? russian,
	String? japanese,
	AnimeTrendingQueryAnimesPoster? poster,
	String? description,
	int? duration,
	AnimeTrendingQueryAnimesAiredOn? airedOn,
	AnimeTrendingQueryAnimesReleasedOn? releasedOn,
	int? episodes,
	String? nextEpisodeAt,
	List<AnimeTrendingQueryAnimesGenres>? genres,
	String? kind,
	bool? isCensored,
	double? score,
	String? season,
	String? status,
	}) {
		return AnimeTrendingQueryAnimes()
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


AnimeTrendingQueryAnimesPoster $AnimeTrendingQueryAnimesPosterFromJson(Map<String, dynamic> json) {
	final AnimeTrendingQueryAnimesPoster animeTrendingQueryAnimesPoster = AnimeTrendingQueryAnimesPoster();
	final String? originalUrl = jsonConvert.convert<String>(json['originalUrl']);
	if (originalUrl != null) {
		animeTrendingQueryAnimesPoster.originalUrl = originalUrl;
	}
	final String? mainAlt2xUrl = jsonConvert.convert<String>(json['mainAlt2xUrl']);
	if (mainAlt2xUrl != null) {
		animeTrendingQueryAnimesPoster.mainAlt2xUrl = mainAlt2xUrl;
	}
	return animeTrendingQueryAnimesPoster;
}

Map<String, dynamic> $AnimeTrendingQueryAnimesPosterToJson(AnimeTrendingQueryAnimesPoster entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['originalUrl'] = entity.originalUrl;
	data['mainAlt2xUrl'] = entity.mainAlt2xUrl;
	return data;
}

extension AnimeTrendingQueryAnimesPosterExtension on AnimeTrendingQueryAnimesPoster {
	AnimeTrendingQueryAnimesPoster copyWith({
	String? originalUrl,
	String? mainAlt2xUrl,
	}) {
		return AnimeTrendingQueryAnimesPoster()
			..originalUrl = originalUrl ?? this.originalUrl
			..mainAlt2xUrl = mainAlt2xUrl ?? this.mainAlt2xUrl;
	}
}


AnimeTrendingQueryAnimesAiredOn $AnimeTrendingQueryAnimesAiredOnFromJson(Map<String, dynamic> json) {
	final AnimeTrendingQueryAnimesAiredOn animeTrendingQueryAnimesAiredOn = AnimeTrendingQueryAnimesAiredOn();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		animeTrendingQueryAnimesAiredOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		animeTrendingQueryAnimesAiredOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		animeTrendingQueryAnimesAiredOn.year = year;
	}
	return animeTrendingQueryAnimesAiredOn;
}

Map<String, dynamic> $AnimeTrendingQueryAnimesAiredOnToJson(AnimeTrendingQueryAnimesAiredOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension AnimeTrendingQueryAnimesAiredOnExtension on AnimeTrendingQueryAnimesAiredOn {
	AnimeTrendingQueryAnimesAiredOn copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return AnimeTrendingQueryAnimesAiredOn()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


AnimeTrendingQueryAnimesReleasedOn $AnimeTrendingQueryAnimesReleasedOnFromJson(Map<String, dynamic> json) {
	final AnimeTrendingQueryAnimesReleasedOn animeTrendingQueryAnimesReleasedOn = AnimeTrendingQueryAnimesReleasedOn();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		animeTrendingQueryAnimesReleasedOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		animeTrendingQueryAnimesReleasedOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		animeTrendingQueryAnimesReleasedOn.year = year;
	}
	return animeTrendingQueryAnimesReleasedOn;
}

Map<String, dynamic> $AnimeTrendingQueryAnimesReleasedOnToJson(AnimeTrendingQueryAnimesReleasedOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension AnimeTrendingQueryAnimesReleasedOnExtension on AnimeTrendingQueryAnimesReleasedOn {
	AnimeTrendingQueryAnimesReleasedOn copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return AnimeTrendingQueryAnimesReleasedOn()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


AnimeTrendingQueryAnimesGenres $AnimeTrendingQueryAnimesGenresFromJson(Map<String, dynamic> json) {
	final AnimeTrendingQueryAnimesGenres animeTrendingQueryAnimesGenres = AnimeTrendingQueryAnimesGenres();
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		animeTrendingQueryAnimesGenres.kind = kind;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		animeTrendingQueryAnimesGenres.name = name;
	}
	return animeTrendingQueryAnimesGenres;
}

Map<String, dynamic> $AnimeTrendingQueryAnimesGenresToJson(AnimeTrendingQueryAnimesGenres entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['kind'] = entity.kind;
	data['name'] = entity.name;
	return data;
}

extension AnimeTrendingQueryAnimesGenresExtension on AnimeTrendingQueryAnimesGenres {
	AnimeTrendingQueryAnimesGenres copyWith({
	String? kind,
	String? name,
	}) {
		return AnimeTrendingQueryAnimesGenres()
			..kind = kind ?? this.kind
			..name = name ?? this.name;
	}
}

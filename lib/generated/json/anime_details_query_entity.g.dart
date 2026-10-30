import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_details_query_entity.dart';

AnimeDetailsQueryEntity $AnimeDetailsQueryEntityFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryEntity animeDetailsQueryEntity = AnimeDetailsQueryEntity();
	final List<AnimeDetailsQueryAnimes>? animes = (json['animes'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AnimeDetailsQueryAnimes>(e) as AnimeDetailsQueryAnimes).toList();
	if (animes != null) {
		animeDetailsQueryEntity.animes = animes;
	}
	return animeDetailsQueryEntity;
}

Map<String, dynamic> $AnimeDetailsQueryEntityToJson(AnimeDetailsQueryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['animes'] =  entity.animes.map((v) => v.toJson()).toList();
	return data;
}

extension AnimeDetailsQueryEntityExtension on AnimeDetailsQueryEntity {
	AnimeDetailsQueryEntity copyWith({
	List<AnimeDetailsQueryAnimes>? animes,
	}) {
		return AnimeDetailsQueryEntity()
			..animes = animes ?? this.animes;
	}
}


AnimeDetailsQueryAnimes $AnimeDetailsQueryAnimesFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryAnimes animeDetailsQueryAnimes = AnimeDetailsQueryAnimes();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		animeDetailsQueryAnimes.id = id;
	}
	final String? malId = jsonConvert.convert<String>(json['malId']);
	if (malId != null) {
		animeDetailsQueryAnimes.malId = malId;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		animeDetailsQueryAnimes.name = name;
	}
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		animeDetailsQueryAnimes.english = english;
	}
	final String? japanese = jsonConvert.convert<String>(json['japanese']);
	if (japanese != null) {
		animeDetailsQueryAnimes.japanese = japanese;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		animeDetailsQueryAnimes.russian = russian;
	}
	final AnimeDetailsQueryAnimesPoster? poster = jsonConvert.convert<AnimeDetailsQueryAnimesPoster>(json['poster']);
	if (poster != null) {
		animeDetailsQueryAnimes.poster = poster;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		animeDetailsQueryAnimes.description = description;
	}
	final int? duration = jsonConvert.convert<int>(json['duration']);
	if (duration != null) {
		animeDetailsQueryAnimes.duration = duration;
	}
	final AnimeDetailsQueryAnimesAiredOn? airedOn = jsonConvert.convert<AnimeDetailsQueryAnimesAiredOn>(json['airedOn']);
	if (airedOn != null) {
		animeDetailsQueryAnimes.airedOn = airedOn;
	}
	final AnimeDetailsQueryAnimesReleasedOn? releasedOn = jsonConvert.convert<AnimeDetailsQueryAnimesReleasedOn>(json['releasedOn']);
	if (releasedOn != null) {
		animeDetailsQueryAnimes.releasedOn = releasedOn;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		animeDetailsQueryAnimes.episodes = episodes;
	}
	final int? episodesAired = jsonConvert.convert<int>(json['episodesAired']);
	if (episodesAired != null) {
		animeDetailsQueryAnimes.episodesAired = episodesAired;
	}
	final String? nextEpisodeAt = jsonConvert.convert<String>(json['nextEpisodeAt']);
	if (nextEpisodeAt != null) {
		animeDetailsQueryAnimes.nextEpisodeAt = nextEpisodeAt;
	}
	final List<AnimeDetailsQueryAnimesGenres>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AnimeDetailsQueryAnimesGenres>(e) as AnimeDetailsQueryAnimesGenres).toList();
	if (genres != null) {
		animeDetailsQueryAnimes.genres = genres;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		animeDetailsQueryAnimes.kind = kind;
	}
	final bool? isCensored = jsonConvert.convert<bool>(json['isCensored']);
	if (isCensored != null) {
		animeDetailsQueryAnimes.isCensored = isCensored;
	}
	final double? score = jsonConvert.convert<double>(json['score']);
	if (score != null) {
		animeDetailsQueryAnimes.score = score;
	}
	final String? season = jsonConvert.convert<String>(json['season']);
	if (season != null) {
		animeDetailsQueryAnimes.season = season;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		animeDetailsQueryAnimes.status = status;
	}
	final AnimeDetailsQueryAnimesUserRate? userRate = jsonConvert.convert<AnimeDetailsQueryAnimesUserRate>(json['userRate']);
	if (userRate != null) {
		animeDetailsQueryAnimes.userRate = userRate;
	}
	final List<AnimeDetailsQueryAnimesCharacterRoles>? characterRoles = (json['characterRoles'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AnimeDetailsQueryAnimesCharacterRoles>(e) as AnimeDetailsQueryAnimesCharacterRoles).toList();
	if (characterRoles != null) {
		animeDetailsQueryAnimes.characterRoles = characterRoles;
	}
	final List<AnimeDetailsQueryAnimesRelated>? related = (json['related'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AnimeDetailsQueryAnimesRelated>(e) as AnimeDetailsQueryAnimesRelated).toList();
	if (related != null) {
		animeDetailsQueryAnimes.related = related;
	}
	return animeDetailsQueryAnimes;
}

Map<String, dynamic> $AnimeDetailsQueryAnimesToJson(AnimeDetailsQueryAnimes entity) {
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
	data['userRate'] = entity.userRate.toJson();
	data['characterRoles'] =  entity.characterRoles.map((v) => v.toJson()).toList();
	data['related'] =  entity.related.map((v) => v.toJson()).toList();
	return data;
}

extension AnimeDetailsQueryAnimesExtension on AnimeDetailsQueryAnimes {
	AnimeDetailsQueryAnimes copyWith({
	String? id,
	String? malId,
	String? name,
	String? english,
	String? japanese,
	String? russian,
	AnimeDetailsQueryAnimesPoster? poster,
	String? description,
	int? duration,
	AnimeDetailsQueryAnimesAiredOn? airedOn,
	AnimeDetailsQueryAnimesReleasedOn? releasedOn,
	int? episodes,
	int? episodesAired,
	String? nextEpisodeAt,
	List<AnimeDetailsQueryAnimesGenres>? genres,
	String? kind,
	bool? isCensored,
	double? score,
	String? season,
	String? status,
	AnimeDetailsQueryAnimesUserRate? userRate,
	List<AnimeDetailsQueryAnimesCharacterRoles>? characterRoles,
	List<AnimeDetailsQueryAnimesRelated>? related,
	}) {
		return AnimeDetailsQueryAnimes()
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
			..status = status ?? this.status
			..userRate = userRate ?? this.userRate
			..characterRoles = characterRoles ?? this.characterRoles
			..related = related ?? this.related;
	}
}


AnimeDetailsQueryAnimesUserRate $AnimeDetailsQueryAnimesUserRateFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryAnimesUserRate animeDetailsQueryAnimesUserRate = AnimeDetailsQueryAnimesUserRate();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		animeDetailsQueryAnimesUserRate.id = id;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		animeDetailsQueryAnimesUserRate.episodes = episodes;
	}
	final int? score = jsonConvert.convert<int>(json['score']);
	if (score != null) {
		animeDetailsQueryAnimesUserRate.score = score;
	}
	final int? rewatches = jsonConvert.convert<int>(json['rewatches']);
	if (rewatches != null) {
		animeDetailsQueryAnimesUserRate.rewatches = rewatches;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		animeDetailsQueryAnimesUserRate.status = status;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		animeDetailsQueryAnimesUserRate.createdAt = createdAt;
	}
	final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
	if (updatedAt != null) {
		animeDetailsQueryAnimesUserRate.updatedAt = updatedAt;
	}
	return animeDetailsQueryAnimesUserRate;
}

Map<String, dynamic> $AnimeDetailsQueryAnimesUserRateToJson(AnimeDetailsQueryAnimesUserRate entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['episodes'] = entity.episodes;
	data['score'] = entity.score;
	data['rewatches'] = entity.rewatches;
	data['status'] = entity.status;
	data['createdAt'] = entity.createdAt;
	data['updatedAt'] = entity.updatedAt;
	return data;
}

extension AnimeDetailsQueryAnimesUserRateExtension on AnimeDetailsQueryAnimesUserRate {
	AnimeDetailsQueryAnimesUserRate copyWith({
	String? id,
	int? episodes,
	int? score,
	int? rewatches,
	String? status,
	String? createdAt,
	String? updatedAt,
	}) {
		return AnimeDetailsQueryAnimesUserRate()
			..id = id ?? this.id
			..episodes = episodes ?? this.episodes
			..score = score ?? this.score
			..rewatches = rewatches ?? this.rewatches
			..status = status ?? this.status
			..createdAt = createdAt ?? this.createdAt
			..updatedAt = updatedAt ?? this.updatedAt;
	}
}


AnimeDetailsQueryAnimesPoster $AnimeDetailsQueryAnimesPosterFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryAnimesPoster animeDetailsQueryAnimesPoster = AnimeDetailsQueryAnimesPoster();
	final String? originalUrl = jsonConvert.convert<String>(json['originalUrl']);
	if (originalUrl != null) {
		animeDetailsQueryAnimesPoster.originalUrl = originalUrl;
	}
	final String? mainAlt2xUrl = jsonConvert.convert<String>(json['mainAlt2xUrl']);
	if (mainAlt2xUrl != null) {
		animeDetailsQueryAnimesPoster.mainAlt2xUrl = mainAlt2xUrl;
	}
	return animeDetailsQueryAnimesPoster;
}

Map<String, dynamic> $AnimeDetailsQueryAnimesPosterToJson(AnimeDetailsQueryAnimesPoster entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['originalUrl'] = entity.originalUrl;
	data['mainAlt2xUrl'] = entity.mainAlt2xUrl;
	return data;
}

extension AnimeDetailsQueryAnimesPosterExtension on AnimeDetailsQueryAnimesPoster {
	AnimeDetailsQueryAnimesPoster copyWith({
	String? originalUrl,
	String? mainAlt2xUrl,
	}) {
		return AnimeDetailsQueryAnimesPoster()
			..originalUrl = originalUrl ?? this.originalUrl
			..mainAlt2xUrl = mainAlt2xUrl ?? this.mainAlt2xUrl;
	}
}


AnimeDetailsQueryAnimesAiredOn $AnimeDetailsQueryAnimesAiredOnFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryAnimesAiredOn animeDetailsQueryAnimesAiredOn = AnimeDetailsQueryAnimesAiredOn();
	final String? date = jsonConvert.convert<String>(json['date']);
	if (date != null) {
		animeDetailsQueryAnimesAiredOn.date = date;
	}
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		animeDetailsQueryAnimesAiredOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		animeDetailsQueryAnimesAiredOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		animeDetailsQueryAnimesAiredOn.year = year;
	}
	return animeDetailsQueryAnimesAiredOn;
}

Map<String, dynamic> $AnimeDetailsQueryAnimesAiredOnToJson(AnimeDetailsQueryAnimesAiredOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['date'] = entity.date;
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension AnimeDetailsQueryAnimesAiredOnExtension on AnimeDetailsQueryAnimesAiredOn {
	AnimeDetailsQueryAnimesAiredOn copyWith({
	String? date,
	int? day,
	int? month,
	int? year,
	}) {
		return AnimeDetailsQueryAnimesAiredOn()
			..date = date ?? this.date
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


AnimeDetailsQueryAnimesReleasedOn $AnimeDetailsQueryAnimesReleasedOnFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryAnimesReleasedOn animeDetailsQueryAnimesReleasedOn = AnimeDetailsQueryAnimesReleasedOn();
	final String? date = jsonConvert.convert<String>(json['date']);
	if (date != null) {
		animeDetailsQueryAnimesReleasedOn.date = date;
	}
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		animeDetailsQueryAnimesReleasedOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		animeDetailsQueryAnimesReleasedOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		animeDetailsQueryAnimesReleasedOn.year = year;
	}
	return animeDetailsQueryAnimesReleasedOn;
}

Map<String, dynamic> $AnimeDetailsQueryAnimesReleasedOnToJson(AnimeDetailsQueryAnimesReleasedOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['date'] = entity.date;
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension AnimeDetailsQueryAnimesReleasedOnExtension on AnimeDetailsQueryAnimesReleasedOn {
	AnimeDetailsQueryAnimesReleasedOn copyWith({
	String? date,
	int? day,
	int? month,
	int? year,
	}) {
		return AnimeDetailsQueryAnimesReleasedOn()
			..date = date ?? this.date
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


AnimeDetailsQueryAnimesGenres $AnimeDetailsQueryAnimesGenresFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryAnimesGenres animeDetailsQueryAnimesGenres = AnimeDetailsQueryAnimesGenres();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		animeDetailsQueryAnimesGenres.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		animeDetailsQueryAnimesGenres.name = name;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		animeDetailsQueryAnimesGenres.kind = kind;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		animeDetailsQueryAnimesGenres.russian = russian;
	}
	return animeDetailsQueryAnimesGenres;
}

Map<String, dynamic> $AnimeDetailsQueryAnimesGenresToJson(AnimeDetailsQueryAnimesGenres entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['kind'] = entity.kind;
	data['russian'] = entity.russian;
	return data;
}

extension AnimeDetailsQueryAnimesGenresExtension on AnimeDetailsQueryAnimesGenres {
	AnimeDetailsQueryAnimesGenres copyWith({
	String? id,
	String? name,
	String? kind,
	String? russian,
	}) {
		return AnimeDetailsQueryAnimesGenres()
			..id = id ?? this.id
			..name = name ?? this.name
			..kind = kind ?? this.kind
			..russian = russian ?? this.russian;
	}
}


AnimeDetailsQueryAnimesCharacterRoles $AnimeDetailsQueryAnimesCharacterRolesFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryAnimesCharacterRoles animeDetailsQueryAnimesCharacterRoles = AnimeDetailsQueryAnimesCharacterRoles();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		animeDetailsQueryAnimesCharacterRoles.id = id;
	}
	final List<String>? rolesEn = (json['rolesEn'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (rolesEn != null) {
		animeDetailsQueryAnimesCharacterRoles.rolesEn = rolesEn;
	}
	final List<String>? rolesRu = (json['rolesRu'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (rolesRu != null) {
		animeDetailsQueryAnimesCharacterRoles.rolesRu = rolesRu;
	}
	final AnimeDetailsQueryAnimesCharacterRolesCharacter? character = jsonConvert.convert<AnimeDetailsQueryAnimesCharacterRolesCharacter>(json['character']);
	if (character != null) {
		animeDetailsQueryAnimesCharacterRoles.character = character;
	}
	return animeDetailsQueryAnimesCharacterRoles;
}

Map<String, dynamic> $AnimeDetailsQueryAnimesCharacterRolesToJson(AnimeDetailsQueryAnimesCharacterRoles entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['rolesEn'] =  entity.rolesEn;
	data['rolesRu'] =  entity.rolesRu;
	data['character'] = entity.character.toJson();
	return data;
}

extension AnimeDetailsQueryAnimesCharacterRolesExtension on AnimeDetailsQueryAnimesCharacterRoles {
	AnimeDetailsQueryAnimesCharacterRoles copyWith({
	String? id,
	List<String>? rolesEn,
	List<String>? rolesRu,
	AnimeDetailsQueryAnimesCharacterRolesCharacter? character,
	}) {
		return AnimeDetailsQueryAnimesCharacterRoles()
			..id = id ?? this.id
			..rolesEn = rolesEn ?? this.rolesEn
			..rolesRu = rolesRu ?? this.rolesRu
			..character = character ?? this.character;
	}
}


AnimeDetailsQueryAnimesCharacterRolesCharacter $AnimeDetailsQueryAnimesCharacterRolesCharacterFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryAnimesCharacterRolesCharacter animeDetailsQueryAnimesCharacterRolesCharacter = AnimeDetailsQueryAnimesCharacterRolesCharacter();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		animeDetailsQueryAnimesCharacterRolesCharacter.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		animeDetailsQueryAnimesCharacterRolesCharacter.name = name;
	}
	final AnimeDetailsQueryAnimesCharacterRolesCharacterPoster? poster = jsonConvert.convert<AnimeDetailsQueryAnimesCharacterRolesCharacterPoster>(json['poster']);
	if (poster != null) {
		animeDetailsQueryAnimesCharacterRolesCharacter.poster = poster;
	}
	return animeDetailsQueryAnimesCharacterRolesCharacter;
}

Map<String, dynamic> $AnimeDetailsQueryAnimesCharacterRolesCharacterToJson(AnimeDetailsQueryAnimesCharacterRolesCharacter entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['poster'] = entity.poster.toJson();
	return data;
}

extension AnimeDetailsQueryAnimesCharacterRolesCharacterExtension on AnimeDetailsQueryAnimesCharacterRolesCharacter {
	AnimeDetailsQueryAnimesCharacterRolesCharacter copyWith({
	String? id,
	String? name,
	AnimeDetailsQueryAnimesCharacterRolesCharacterPoster? poster,
	}) {
		return AnimeDetailsQueryAnimesCharacterRolesCharacter()
			..id = id ?? this.id
			..name = name ?? this.name
			..poster = poster ?? this.poster;
	}
}


AnimeDetailsQueryAnimesCharacterRolesCharacterPoster $AnimeDetailsQueryAnimesCharacterRolesCharacterPosterFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryAnimesCharacterRolesCharacterPoster animeDetailsQueryAnimesCharacterRolesCharacterPoster = AnimeDetailsQueryAnimesCharacterRolesCharacterPoster();
	final String? originalUrl = jsonConvert.convert<String>(json['originalUrl']);
	if (originalUrl != null) {
		animeDetailsQueryAnimesCharacterRolesCharacterPoster.originalUrl = originalUrl;
	}
	return animeDetailsQueryAnimesCharacterRolesCharacterPoster;
}

Map<String, dynamic> $AnimeDetailsQueryAnimesCharacterRolesCharacterPosterToJson(AnimeDetailsQueryAnimesCharacterRolesCharacterPoster entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['originalUrl'] = entity.originalUrl;
	return data;
}

extension AnimeDetailsQueryAnimesCharacterRolesCharacterPosterExtension on AnimeDetailsQueryAnimesCharacterRolesCharacterPoster {
	AnimeDetailsQueryAnimesCharacterRolesCharacterPoster copyWith({
	String? originalUrl,
	}) {
		return AnimeDetailsQueryAnimesCharacterRolesCharacterPoster()
			..originalUrl = originalUrl ?? this.originalUrl;
	}
}


AnimeDetailsQueryAnimesRelated $AnimeDetailsQueryAnimesRelatedFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryAnimesRelated animeDetailsQueryAnimesRelated = AnimeDetailsQueryAnimesRelated();
	final String? relationKind = jsonConvert.convert<String>(json['relationKind']);
	if (relationKind != null) {
		animeDetailsQueryAnimesRelated.relationKind = relationKind;
	}
	final String? relationText = jsonConvert.convert<String>(json['relationText']);
	if (relationText != null) {
		animeDetailsQueryAnimesRelated.relationText = relationText;
	}
	final AnimeDetailsQueryAnimesRelatedAnime? anime = jsonConvert.convert<AnimeDetailsQueryAnimesRelatedAnime>(json['anime']);
	if (anime != null) {
		animeDetailsQueryAnimesRelated.anime = anime;
	}
	return animeDetailsQueryAnimesRelated;
}

Map<String, dynamic> $AnimeDetailsQueryAnimesRelatedToJson(AnimeDetailsQueryAnimesRelated entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['relationKind'] = entity.relationKind;
	data['relationText'] = entity.relationText;
	data['anime'] = entity.anime.toJson();
	return data;
}

extension AnimeDetailsQueryAnimesRelatedExtension on AnimeDetailsQueryAnimesRelated {
	AnimeDetailsQueryAnimesRelated copyWith({
	String? relationKind,
	String? relationText,
	AnimeDetailsQueryAnimesRelatedAnime? anime,
	}) {
		return AnimeDetailsQueryAnimesRelated()
			..relationKind = relationKind ?? this.relationKind
			..relationText = relationText ?? this.relationText
			..anime = anime ?? this.anime;
	}
}


AnimeDetailsQueryAnimesRelatedAnime $AnimeDetailsQueryAnimesRelatedAnimeFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryAnimesRelatedAnime animeDetailsQueryAnimesRelatedAnime = AnimeDetailsQueryAnimesRelatedAnime();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		animeDetailsQueryAnimesRelatedAnime.id = id;
	}
	final String? malId = jsonConvert.convert<String>(json['malId']);
	if (malId != null) {
		animeDetailsQueryAnimesRelatedAnime.malId = malId;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		animeDetailsQueryAnimesRelatedAnime.name = name;
	}
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		animeDetailsQueryAnimesRelatedAnime.english = english;
	}
	final String? japanese = jsonConvert.convert<String>(json['japanese']);
	if (japanese != null) {
		animeDetailsQueryAnimesRelatedAnime.japanese = japanese;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		animeDetailsQueryAnimesRelatedAnime.russian = russian;
	}
	final AnimeDetailsQueryAnimesRelatedAnimePoster? poster = jsonConvert.convert<AnimeDetailsQueryAnimesRelatedAnimePoster>(json['poster']);
	if (poster != null) {
		animeDetailsQueryAnimesRelatedAnime.poster = poster;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		animeDetailsQueryAnimesRelatedAnime.description = description;
	}
	final int? duration = jsonConvert.convert<int>(json['duration']);
	if (duration != null) {
		animeDetailsQueryAnimesRelatedAnime.duration = duration;
	}
	final AnimeDetailsQueryAnimesRelatedAnimeAiredOn? airedOn = jsonConvert.convert<AnimeDetailsQueryAnimesRelatedAnimeAiredOn>(json['airedOn']);
	if (airedOn != null) {
		animeDetailsQueryAnimesRelatedAnime.airedOn = airedOn;
	}
	final AnimeDetailsQueryAnimesRelatedAnimeReleasedOn? releasedOn = jsonConvert.convert<AnimeDetailsQueryAnimesRelatedAnimeReleasedOn>(json['releasedOn']);
	if (releasedOn != null) {
		animeDetailsQueryAnimesRelatedAnime.releasedOn = releasedOn;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		animeDetailsQueryAnimesRelatedAnime.episodes = episodes;
	}
	final int? episodesAired = jsonConvert.convert<int>(json['episodesAired']);
	if (episodesAired != null) {
		animeDetailsQueryAnimesRelatedAnime.episodesAired = episodesAired;
	}
	final String? nextEpisodeAt = jsonConvert.convert<String>(json['nextEpisodeAt']);
	if (nextEpisodeAt != null) {
		animeDetailsQueryAnimesRelatedAnime.nextEpisodeAt = nextEpisodeAt;
	}
	final List<AnimeDetailsQueryAnimesRelatedAnimeGenres>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AnimeDetailsQueryAnimesRelatedAnimeGenres>(e) as AnimeDetailsQueryAnimesRelatedAnimeGenres).toList();
	if (genres != null) {
		animeDetailsQueryAnimesRelatedAnime.genres = genres;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		animeDetailsQueryAnimesRelatedAnime.kind = kind;
	}
	final bool? isCensored = jsonConvert.convert<bool>(json['isCensored']);
	if (isCensored != null) {
		animeDetailsQueryAnimesRelatedAnime.isCensored = isCensored;
	}
	final double? score = jsonConvert.convert<double>(json['score']);
	if (score != null) {
		animeDetailsQueryAnimesRelatedAnime.score = score;
	}
	final String? season = jsonConvert.convert<String>(json['season']);
	if (season != null) {
		animeDetailsQueryAnimesRelatedAnime.season = season;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		animeDetailsQueryAnimesRelatedAnime.status = status;
	}
	return animeDetailsQueryAnimesRelatedAnime;
}

Map<String, dynamic> $AnimeDetailsQueryAnimesRelatedAnimeToJson(AnimeDetailsQueryAnimesRelatedAnime entity) {
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

extension AnimeDetailsQueryAnimesRelatedAnimeExtension on AnimeDetailsQueryAnimesRelatedAnime {
	AnimeDetailsQueryAnimesRelatedAnime copyWith({
	String? id,
	String? malId,
	String? name,
	String? english,
	String? japanese,
	String? russian,
	AnimeDetailsQueryAnimesRelatedAnimePoster? poster,
	String? description,
	int? duration,
	AnimeDetailsQueryAnimesRelatedAnimeAiredOn? airedOn,
	AnimeDetailsQueryAnimesRelatedAnimeReleasedOn? releasedOn,
	int? episodes,
	int? episodesAired,
	String? nextEpisodeAt,
	List<AnimeDetailsQueryAnimesRelatedAnimeGenres>? genres,
	String? kind,
	bool? isCensored,
	double? score,
	String? season,
	String? status,
	}) {
		return AnimeDetailsQueryAnimesRelatedAnime()
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


AnimeDetailsQueryAnimesRelatedAnimePoster $AnimeDetailsQueryAnimesRelatedAnimePosterFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryAnimesRelatedAnimePoster animeDetailsQueryAnimesRelatedAnimePoster = AnimeDetailsQueryAnimesRelatedAnimePoster();
	final String? originalUrl = jsonConvert.convert<String>(json['originalUrl']);
	if (originalUrl != null) {
		animeDetailsQueryAnimesRelatedAnimePoster.originalUrl = originalUrl;
	}
	final String? mainAlt2xUrl = jsonConvert.convert<String>(json['mainAlt2xUrl']);
	if (mainAlt2xUrl != null) {
		animeDetailsQueryAnimesRelatedAnimePoster.mainAlt2xUrl = mainAlt2xUrl;
	}
	return animeDetailsQueryAnimesRelatedAnimePoster;
}

Map<String, dynamic> $AnimeDetailsQueryAnimesRelatedAnimePosterToJson(AnimeDetailsQueryAnimesRelatedAnimePoster entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['originalUrl'] = entity.originalUrl;
	data['mainAlt2xUrl'] = entity.mainAlt2xUrl;
	return data;
}

extension AnimeDetailsQueryAnimesRelatedAnimePosterExtension on AnimeDetailsQueryAnimesRelatedAnimePoster {
	AnimeDetailsQueryAnimesRelatedAnimePoster copyWith({
	String? originalUrl,
	String? mainAlt2xUrl,
	}) {
		return AnimeDetailsQueryAnimesRelatedAnimePoster()
			..originalUrl = originalUrl ?? this.originalUrl
			..mainAlt2xUrl = mainAlt2xUrl ?? this.mainAlt2xUrl;
	}
}


AnimeDetailsQueryAnimesRelatedAnimeAiredOn $AnimeDetailsQueryAnimesRelatedAnimeAiredOnFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryAnimesRelatedAnimeAiredOn animeDetailsQueryAnimesRelatedAnimeAiredOn = AnimeDetailsQueryAnimesRelatedAnimeAiredOn();
	final String? date = jsonConvert.convert<String>(json['date']);
	if (date != null) {
		animeDetailsQueryAnimesRelatedAnimeAiredOn.date = date;
	}
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		animeDetailsQueryAnimesRelatedAnimeAiredOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		animeDetailsQueryAnimesRelatedAnimeAiredOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		animeDetailsQueryAnimesRelatedAnimeAiredOn.year = year;
	}
	return animeDetailsQueryAnimesRelatedAnimeAiredOn;
}

Map<String, dynamic> $AnimeDetailsQueryAnimesRelatedAnimeAiredOnToJson(AnimeDetailsQueryAnimesRelatedAnimeAiredOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['date'] = entity.date;
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension AnimeDetailsQueryAnimesRelatedAnimeAiredOnExtension on AnimeDetailsQueryAnimesRelatedAnimeAiredOn {
	AnimeDetailsQueryAnimesRelatedAnimeAiredOn copyWith({
	String? date,
	int? day,
	int? month,
	int? year,
	}) {
		return AnimeDetailsQueryAnimesRelatedAnimeAiredOn()
			..date = date ?? this.date
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


AnimeDetailsQueryAnimesRelatedAnimeReleasedOn $AnimeDetailsQueryAnimesRelatedAnimeReleasedOnFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryAnimesRelatedAnimeReleasedOn animeDetailsQueryAnimesRelatedAnimeReleasedOn = AnimeDetailsQueryAnimesRelatedAnimeReleasedOn();
	final String? date = jsonConvert.convert<String>(json['date']);
	if (date != null) {
		animeDetailsQueryAnimesRelatedAnimeReleasedOn.date = date;
	}
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		animeDetailsQueryAnimesRelatedAnimeReleasedOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		animeDetailsQueryAnimesRelatedAnimeReleasedOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		animeDetailsQueryAnimesRelatedAnimeReleasedOn.year = year;
	}
	return animeDetailsQueryAnimesRelatedAnimeReleasedOn;
}

Map<String, dynamic> $AnimeDetailsQueryAnimesRelatedAnimeReleasedOnToJson(AnimeDetailsQueryAnimesRelatedAnimeReleasedOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['date'] = entity.date;
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension AnimeDetailsQueryAnimesRelatedAnimeReleasedOnExtension on AnimeDetailsQueryAnimesRelatedAnimeReleasedOn {
	AnimeDetailsQueryAnimesRelatedAnimeReleasedOn copyWith({
	String? date,
	int? day,
	int? month,
	int? year,
	}) {
		return AnimeDetailsQueryAnimesRelatedAnimeReleasedOn()
			..date = date ?? this.date
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


AnimeDetailsQueryAnimesRelatedAnimeGenres $AnimeDetailsQueryAnimesRelatedAnimeGenresFromJson(Map<String, dynamic> json) {
	final AnimeDetailsQueryAnimesRelatedAnimeGenres animeDetailsQueryAnimesRelatedAnimeGenres = AnimeDetailsQueryAnimesRelatedAnimeGenres();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		animeDetailsQueryAnimesRelatedAnimeGenres.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		animeDetailsQueryAnimesRelatedAnimeGenres.name = name;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		animeDetailsQueryAnimesRelatedAnimeGenres.kind = kind;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		animeDetailsQueryAnimesRelatedAnimeGenres.russian = russian;
	}
	return animeDetailsQueryAnimesRelatedAnimeGenres;
}

Map<String, dynamic> $AnimeDetailsQueryAnimesRelatedAnimeGenresToJson(AnimeDetailsQueryAnimesRelatedAnimeGenres entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['kind'] = entity.kind;
	data['russian'] = entity.russian;
	return data;
}

extension AnimeDetailsQueryAnimesRelatedAnimeGenresExtension on AnimeDetailsQueryAnimesRelatedAnimeGenres {
	AnimeDetailsQueryAnimesRelatedAnimeGenres copyWith({
	String? id,
	String? name,
	String? kind,
	String? russian,
	}) {
		return AnimeDetailsQueryAnimesRelatedAnimeGenres()
			..id = id ?? this.id
			..name = name ?? this.name
			..kind = kind ?? this.kind
			..russian = russian ?? this.russian;
	}
}

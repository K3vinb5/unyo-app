import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/manga_details_query_entity.dart';

MangaDetailsQueryEntity $MangaDetailsQueryEntityFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryEntity mangaDetailsQueryEntity = MangaDetailsQueryEntity();
	final List<MangaDetailsQueryMangas>? mangas = (json['mangas'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MangaDetailsQueryMangas>(e) as MangaDetailsQueryMangas).toList();
	if (mangas != null) {
		mangaDetailsQueryEntity.mangas = mangas;
	}
	return mangaDetailsQueryEntity;
}

Map<String, dynamic> $MangaDetailsQueryEntityToJson(MangaDetailsQueryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['mangas'] =  entity.mangas.map((v) => v.toJson()).toList();
	return data;
}

extension MangaDetailsQueryEntityExtension on MangaDetailsQueryEntity {
	MangaDetailsQueryEntity copyWith({
	List<MangaDetailsQueryMangas>? mangas,
	}) {
		return MangaDetailsQueryEntity()
			..mangas = mangas ?? this.mangas;
	}
}


MangaDetailsQueryMangas $MangaDetailsQueryMangasFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangas mangaDetailsQueryMangas = MangaDetailsQueryMangas();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		mangaDetailsQueryMangas.id = id;
	}
	final String? malId = jsonConvert.convert<String>(json['malId']);
	if (malId != null) {
		mangaDetailsQueryMangas.malId = malId;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		mangaDetailsQueryMangas.name = name;
	}
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		mangaDetailsQueryMangas.english = english;
	}
	final String? japanese = jsonConvert.convert<String>(json['japanese']);
	if (japanese != null) {
		mangaDetailsQueryMangas.japanese = japanese;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		mangaDetailsQueryMangas.russian = russian;
	}
	final MangaDetailsQueryMangasPoster? poster = jsonConvert.convert<MangaDetailsQueryMangasPoster>(json['poster']);
	if (poster != null) {
		mangaDetailsQueryMangas.poster = poster;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		mangaDetailsQueryMangas.description = description;
	}
	final MangaDetailsQueryMangasAiredOn? airedOn = jsonConvert.convert<MangaDetailsQueryMangasAiredOn>(json['airedOn']);
	if (airedOn != null) {
		mangaDetailsQueryMangas.airedOn = airedOn;
	}
	final MangaDetailsQueryMangasReleasedOn? releasedOn = jsonConvert.convert<MangaDetailsQueryMangasReleasedOn>(json['releasedOn']);
	if (releasedOn != null) {
		mangaDetailsQueryMangas.releasedOn = releasedOn;
	}
	final int? volumes = jsonConvert.convert<int>(json['volumes']);
	if (volumes != null) {
		mangaDetailsQueryMangas.volumes = volumes;
	}
	final int? chapters = jsonConvert.convert<int>(json['chapters']);
	if (chapters != null) {
		mangaDetailsQueryMangas.chapters = chapters;
	}
	final List<MangaDetailsQueryMangasGenres>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MangaDetailsQueryMangasGenres>(e) as MangaDetailsQueryMangasGenres).toList();
	if (genres != null) {
		mangaDetailsQueryMangas.genres = genres;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		mangaDetailsQueryMangas.kind = kind;
	}
	final bool? isCensored = jsonConvert.convert<bool>(json['isCensored']);
	if (isCensored != null) {
		mangaDetailsQueryMangas.isCensored = isCensored;
	}
	final double? score = jsonConvert.convert<double>(json['score']);
	if (score != null) {
		mangaDetailsQueryMangas.score = score;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		mangaDetailsQueryMangas.status = status;
	}
	final List<MangaDetailsQueryMangasPublishers>? publishers = (json['publishers'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MangaDetailsQueryMangasPublishers>(e) as MangaDetailsQueryMangasPublishers).toList();
	if (publishers != null) {
		mangaDetailsQueryMangas.publishers = publishers;
	}
	final MangaDetailsQueryMangasUserRate? userRate = jsonConvert.convert<MangaDetailsQueryMangasUserRate>(json['userRate']);
	if (userRate != null) {
		mangaDetailsQueryMangas.userRate = userRate;
	}
	final List<MangaDetailsQueryMangasCharacterRoles>? characterRoles = (json['characterRoles'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MangaDetailsQueryMangasCharacterRoles>(e) as MangaDetailsQueryMangasCharacterRoles).toList();
	if (characterRoles != null) {
		mangaDetailsQueryMangas.characterRoles = characterRoles;
	}
	final List<MangaDetailsQueryMangasRelated>? related = (json['related'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MangaDetailsQueryMangasRelated>(e) as MangaDetailsQueryMangasRelated).toList();
	if (related != null) {
		mangaDetailsQueryMangas.related = related;
	}
	return mangaDetailsQueryMangas;
}

Map<String, dynamic> $MangaDetailsQueryMangasToJson(MangaDetailsQueryMangas entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['malId'] = entity.malId;
	data['name'] = entity.name;
	data['english'] = entity.english;
	data['japanese'] = entity.japanese;
	data['russian'] = entity.russian;
	data['poster'] = entity.poster.toJson();
	data['description'] = entity.description;
	data['airedOn'] = entity.airedOn.toJson();
	data['releasedOn'] = entity.releasedOn.toJson();
	data['volumes'] = entity.volumes;
	data['chapters'] = entity.chapters;
	data['genres'] =  entity.genres.map((v) => v.toJson()).toList();
	data['kind'] = entity.kind;
	data['isCensored'] = entity.isCensored;
	data['score'] = entity.score;
	data['status'] = entity.status;
	data['publishers'] =  entity.publishers.map((v) => v.toJson()).toList();
	data['userRate'] = entity.userRate.toJson();
	data['characterRoles'] =  entity.characterRoles.map((v) => v.toJson()).toList();
	data['related'] =  entity.related.map((v) => v.toJson()).toList();
	return data;
}

extension MangaDetailsQueryMangasExtension on MangaDetailsQueryMangas {
	MangaDetailsQueryMangas copyWith({
	String? id,
	String? malId,
	String? name,
	String? english,
	String? japanese,
	String? russian,
	MangaDetailsQueryMangasPoster? poster,
	String? description,
	MangaDetailsQueryMangasAiredOn? airedOn,
	MangaDetailsQueryMangasReleasedOn? releasedOn,
	int? volumes,
	int? chapters,
	List<MangaDetailsQueryMangasGenres>? genres,
	String? kind,
	bool? isCensored,
	double? score,
	String? status,
	List<MangaDetailsQueryMangasPublishers>? publishers,
	MangaDetailsQueryMangasUserRate? userRate,
	List<MangaDetailsQueryMangasCharacterRoles>? characterRoles,
	List<MangaDetailsQueryMangasRelated>? related,
	}) {
		return MangaDetailsQueryMangas()
			..id = id ?? this.id
			..malId = malId ?? this.malId
			..name = name ?? this.name
			..english = english ?? this.english
			..japanese = japanese ?? this.japanese
			..russian = russian ?? this.russian
			..poster = poster ?? this.poster
			..description = description ?? this.description
			..airedOn = airedOn ?? this.airedOn
			..releasedOn = releasedOn ?? this.releasedOn
			..volumes = volumes ?? this.volumes
			..chapters = chapters ?? this.chapters
			..genres = genres ?? this.genres
			..kind = kind ?? this.kind
			..isCensored = isCensored ?? this.isCensored
			..score = score ?? this.score
			..status = status ?? this.status
			..publishers = publishers ?? this.publishers
			..userRate = userRate ?? this.userRate
			..characterRoles = characterRoles ?? this.characterRoles
			..related = related ?? this.related;
	}
}


MangaDetailsQueryMangasUserRate $MangaDetailsQueryMangasUserRateFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangasUserRate mangaDetailsQueryMangasUserRate = MangaDetailsQueryMangasUserRate();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		mangaDetailsQueryMangasUserRate.id = id;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		mangaDetailsQueryMangasUserRate.episodes = episodes;
	}
	final int? score = jsonConvert.convert<int>(json['score']);
	if (score != null) {
		mangaDetailsQueryMangasUserRate.score = score;
	}
	final int? rewatches = jsonConvert.convert<int>(json['rewatches']);
	if (rewatches != null) {
		mangaDetailsQueryMangasUserRate.rewatches = rewatches;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		mangaDetailsQueryMangasUserRate.status = status;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		mangaDetailsQueryMangasUserRate.createdAt = createdAt;
	}
	final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
	if (updatedAt != null) {
		mangaDetailsQueryMangasUserRate.updatedAt = updatedAt;
	}
	return mangaDetailsQueryMangasUserRate;
}

Map<String, dynamic> $MangaDetailsQueryMangasUserRateToJson(MangaDetailsQueryMangasUserRate entity) {
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

extension MangaDetailsQueryMangasUserRateExtension on MangaDetailsQueryMangasUserRate {
	MangaDetailsQueryMangasUserRate copyWith({
	String? id,
	int? episodes,
	int? score,
	int? rewatches,
	String? status,
	String? createdAt,
	String? updatedAt,
	}) {
		return MangaDetailsQueryMangasUserRate()
			..id = id ?? this.id
			..episodes = episodes ?? this.episodes
			..score = score ?? this.score
			..rewatches = rewatches ?? this.rewatches
			..status = status ?? this.status
			..createdAt = createdAt ?? this.createdAt
			..updatedAt = updatedAt ?? this.updatedAt;
	}
}


MangaDetailsQueryMangasPoster $MangaDetailsQueryMangasPosterFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangasPoster mangaDetailsQueryMangasPoster = MangaDetailsQueryMangasPoster();
	final String? originalUrl = jsonConvert.convert<String>(json['originalUrl']);
	if (originalUrl != null) {
		mangaDetailsQueryMangasPoster.originalUrl = originalUrl;
	}
	final String? mainAlt2xUrl = jsonConvert.convert<String>(json['mainAlt2xUrl']);
	if (mainAlt2xUrl != null) {
		mangaDetailsQueryMangasPoster.mainAlt2xUrl = mainAlt2xUrl;
	}
	return mangaDetailsQueryMangasPoster;
}

Map<String, dynamic> $MangaDetailsQueryMangasPosterToJson(MangaDetailsQueryMangasPoster entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['originalUrl'] = entity.originalUrl;
	data['mainAlt2xUrl'] = entity.mainAlt2xUrl;
	return data;
}

extension MangaDetailsQueryMangasPosterExtension on MangaDetailsQueryMangasPoster {
	MangaDetailsQueryMangasPoster copyWith({
	String? originalUrl,
	String? mainAlt2xUrl,
	}) {
		return MangaDetailsQueryMangasPoster()
			..originalUrl = originalUrl ?? this.originalUrl
			..mainAlt2xUrl = mainAlt2xUrl ?? this.mainAlt2xUrl;
	}
}


MangaDetailsQueryMangasAiredOn $MangaDetailsQueryMangasAiredOnFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangasAiredOn mangaDetailsQueryMangasAiredOn = MangaDetailsQueryMangasAiredOn();
	final String? date = jsonConvert.convert<String>(json['date']);
	if (date != null) {
		mangaDetailsQueryMangasAiredOn.date = date;
	}
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mangaDetailsQueryMangasAiredOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mangaDetailsQueryMangasAiredOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mangaDetailsQueryMangasAiredOn.year = year;
	}
	return mangaDetailsQueryMangasAiredOn;
}

Map<String, dynamic> $MangaDetailsQueryMangasAiredOnToJson(MangaDetailsQueryMangasAiredOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['date'] = entity.date;
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MangaDetailsQueryMangasAiredOnExtension on MangaDetailsQueryMangasAiredOn {
	MangaDetailsQueryMangasAiredOn copyWith({
	String? date,
	int? day,
	int? month,
	int? year,
	}) {
		return MangaDetailsQueryMangasAiredOn()
			..date = date ?? this.date
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MangaDetailsQueryMangasReleasedOn $MangaDetailsQueryMangasReleasedOnFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangasReleasedOn mangaDetailsQueryMangasReleasedOn = MangaDetailsQueryMangasReleasedOn();
	final String? date = jsonConvert.convert<String>(json['date']);
	if (date != null) {
		mangaDetailsQueryMangasReleasedOn.date = date;
	}
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mangaDetailsQueryMangasReleasedOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mangaDetailsQueryMangasReleasedOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mangaDetailsQueryMangasReleasedOn.year = year;
	}
	return mangaDetailsQueryMangasReleasedOn;
}

Map<String, dynamic> $MangaDetailsQueryMangasReleasedOnToJson(MangaDetailsQueryMangasReleasedOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['date'] = entity.date;
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MangaDetailsQueryMangasReleasedOnExtension on MangaDetailsQueryMangasReleasedOn {
	MangaDetailsQueryMangasReleasedOn copyWith({
	String? date,
	int? day,
	int? month,
	int? year,
	}) {
		return MangaDetailsQueryMangasReleasedOn()
			..date = date ?? this.date
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MangaDetailsQueryMangasGenres $MangaDetailsQueryMangasGenresFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangasGenres mangaDetailsQueryMangasGenres = MangaDetailsQueryMangasGenres();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		mangaDetailsQueryMangasGenres.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		mangaDetailsQueryMangasGenres.name = name;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		mangaDetailsQueryMangasGenres.kind = kind;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		mangaDetailsQueryMangasGenres.russian = russian;
	}
	return mangaDetailsQueryMangasGenres;
}

Map<String, dynamic> $MangaDetailsQueryMangasGenresToJson(MangaDetailsQueryMangasGenres entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['kind'] = entity.kind;
	data['russian'] = entity.russian;
	return data;
}

extension MangaDetailsQueryMangasGenresExtension on MangaDetailsQueryMangasGenres {
	MangaDetailsQueryMangasGenres copyWith({
	String? id,
	String? name,
	String? kind,
	String? russian,
	}) {
		return MangaDetailsQueryMangasGenres()
			..id = id ?? this.id
			..name = name ?? this.name
			..kind = kind ?? this.kind
			..russian = russian ?? this.russian;
	}
}


MangaDetailsQueryMangasPublishers $MangaDetailsQueryMangasPublishersFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangasPublishers mangaDetailsQueryMangasPublishers = MangaDetailsQueryMangasPublishers();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		mangaDetailsQueryMangasPublishers.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		mangaDetailsQueryMangasPublishers.name = name;
	}
	return mangaDetailsQueryMangasPublishers;
}

Map<String, dynamic> $MangaDetailsQueryMangasPublishersToJson(MangaDetailsQueryMangasPublishers entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	return data;
}

extension MangaDetailsQueryMangasPublishersExtension on MangaDetailsQueryMangasPublishers {
	MangaDetailsQueryMangasPublishers copyWith({
	String? id,
	String? name,
	}) {
		return MangaDetailsQueryMangasPublishers()
			..id = id ?? this.id
			..name = name ?? this.name;
	}
}


MangaDetailsQueryMangasCharacterRoles $MangaDetailsQueryMangasCharacterRolesFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangasCharacterRoles mangaDetailsQueryMangasCharacterRoles = MangaDetailsQueryMangasCharacterRoles();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		mangaDetailsQueryMangasCharacterRoles.id = id;
	}
	final List<String>? rolesEn = (json['rolesEn'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (rolesEn != null) {
		mangaDetailsQueryMangasCharacterRoles.rolesEn = rolesEn;
	}
	final List<String>? rolesRu = (json['rolesRu'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (rolesRu != null) {
		mangaDetailsQueryMangasCharacterRoles.rolesRu = rolesRu;
	}
	final MangaDetailsQueryMangasCharacterRolesCharacter? character = jsonConvert.convert<MangaDetailsQueryMangasCharacterRolesCharacter>(json['character']);
	if (character != null) {
		mangaDetailsQueryMangasCharacterRoles.character = character;
	}
	return mangaDetailsQueryMangasCharacterRoles;
}

Map<String, dynamic> $MangaDetailsQueryMangasCharacterRolesToJson(MangaDetailsQueryMangasCharacterRoles entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['rolesEn'] =  entity.rolesEn;
	data['rolesRu'] =  entity.rolesRu;
	data['character'] = entity.character.toJson();
	return data;
}

extension MangaDetailsQueryMangasCharacterRolesExtension on MangaDetailsQueryMangasCharacterRoles {
	MangaDetailsQueryMangasCharacterRoles copyWith({
	String? id,
	List<String>? rolesEn,
	List<String>? rolesRu,
	MangaDetailsQueryMangasCharacterRolesCharacter? character,
	}) {
		return MangaDetailsQueryMangasCharacterRoles()
			..id = id ?? this.id
			..rolesEn = rolesEn ?? this.rolesEn
			..rolesRu = rolesRu ?? this.rolesRu
			..character = character ?? this.character;
	}
}


MangaDetailsQueryMangasCharacterRolesCharacter $MangaDetailsQueryMangasCharacterRolesCharacterFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangasCharacterRolesCharacter mangaDetailsQueryMangasCharacterRolesCharacter = MangaDetailsQueryMangasCharacterRolesCharacter();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		mangaDetailsQueryMangasCharacterRolesCharacter.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		mangaDetailsQueryMangasCharacterRolesCharacter.name = name;
	}
	final MangaDetailsQueryMangasCharacterRolesCharacterPoster? poster = jsonConvert.convert<MangaDetailsQueryMangasCharacterRolesCharacterPoster>(json['poster']);
	if (poster != null) {
		mangaDetailsQueryMangasCharacterRolesCharacter.poster = poster;
	}
	return mangaDetailsQueryMangasCharacterRolesCharacter;
}

Map<String, dynamic> $MangaDetailsQueryMangasCharacterRolesCharacterToJson(MangaDetailsQueryMangasCharacterRolesCharacter entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['poster'] = entity.poster.toJson();
	return data;
}

extension MangaDetailsQueryMangasCharacterRolesCharacterExtension on MangaDetailsQueryMangasCharacterRolesCharacter {
	MangaDetailsQueryMangasCharacterRolesCharacter copyWith({
	String? id,
	String? name,
	MangaDetailsQueryMangasCharacterRolesCharacterPoster? poster,
	}) {
		return MangaDetailsQueryMangasCharacterRolesCharacter()
			..id = id ?? this.id
			..name = name ?? this.name
			..poster = poster ?? this.poster;
	}
}


MangaDetailsQueryMangasCharacterRolesCharacterPoster $MangaDetailsQueryMangasCharacterRolesCharacterPosterFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangasCharacterRolesCharacterPoster mangaDetailsQueryMangasCharacterRolesCharacterPoster = MangaDetailsQueryMangasCharacterRolesCharacterPoster();
	final String? originalUrl = jsonConvert.convert<String>(json['originalUrl']);
	if (originalUrl != null) {
		mangaDetailsQueryMangasCharacterRolesCharacterPoster.originalUrl = originalUrl;
	}
	return mangaDetailsQueryMangasCharacterRolesCharacterPoster;
}

Map<String, dynamic> $MangaDetailsQueryMangasCharacterRolesCharacterPosterToJson(MangaDetailsQueryMangasCharacterRolesCharacterPoster entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['originalUrl'] = entity.originalUrl;
	return data;
}

extension MangaDetailsQueryMangasCharacterRolesCharacterPosterExtension on MangaDetailsQueryMangasCharacterRolesCharacterPoster {
	MangaDetailsQueryMangasCharacterRolesCharacterPoster copyWith({
	String? originalUrl,
	}) {
		return MangaDetailsQueryMangasCharacterRolesCharacterPoster()
			..originalUrl = originalUrl ?? this.originalUrl;
	}
}


MangaDetailsQueryMangasRelated $MangaDetailsQueryMangasRelatedFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangasRelated mangaDetailsQueryMangasRelated = MangaDetailsQueryMangasRelated();
	final String? relationKind = jsonConvert.convert<String>(json['relationKind']);
	if (relationKind != null) {
		mangaDetailsQueryMangasRelated.relationKind = relationKind;
	}
	final String? relationText = jsonConvert.convert<String>(json['relationText']);
	if (relationText != null) {
		mangaDetailsQueryMangasRelated.relationText = relationText;
	}
	final MangaDetailsQueryMangasRelatedManga? manga = jsonConvert.convert<MangaDetailsQueryMangasRelatedManga>(json['manga']);
	if (manga != null) {
		mangaDetailsQueryMangasRelated.manga = manga;
	}
	return mangaDetailsQueryMangasRelated;
}

Map<String, dynamic> $MangaDetailsQueryMangasRelatedToJson(MangaDetailsQueryMangasRelated entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['relationKind'] = entity.relationKind;
	data['relationText'] = entity.relationText;
	data['manga'] = entity.manga.toJson();
	return data;
}

extension MangaDetailsQueryMangasRelatedExtension on MangaDetailsQueryMangasRelated {
	MangaDetailsQueryMangasRelated copyWith({
	String? relationKind,
	String? relationText,
	MangaDetailsQueryMangasRelatedManga? manga,
	}) {
		return MangaDetailsQueryMangasRelated()
			..relationKind = relationKind ?? this.relationKind
			..relationText = relationText ?? this.relationText
			..manga = manga ?? this.manga;
	}
}


MangaDetailsQueryMangasRelatedManga $MangaDetailsQueryMangasRelatedMangaFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangasRelatedManga mangaDetailsQueryMangasRelatedManga = MangaDetailsQueryMangasRelatedManga();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		mangaDetailsQueryMangasRelatedManga.id = id;
	}
	final String? malId = jsonConvert.convert<String>(json['malId']);
	if (malId != null) {
		mangaDetailsQueryMangasRelatedManga.malId = malId;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		mangaDetailsQueryMangasRelatedManga.name = name;
	}
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		mangaDetailsQueryMangasRelatedManga.english = english;
	}
	final String? japanese = jsonConvert.convert<String>(json['japanese']);
	if (japanese != null) {
		mangaDetailsQueryMangasRelatedManga.japanese = japanese;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		mangaDetailsQueryMangasRelatedManga.russian = russian;
	}
	final MangaDetailsQueryMangasRelatedMangaPoster? poster = jsonConvert.convert<MangaDetailsQueryMangasRelatedMangaPoster>(json['poster']);
	if (poster != null) {
		mangaDetailsQueryMangasRelatedManga.poster = poster;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		mangaDetailsQueryMangasRelatedManga.description = description;
	}
	final MangaDetailsQueryMangasRelatedMangaAiredOn? airedOn = jsonConvert.convert<MangaDetailsQueryMangasRelatedMangaAiredOn>(json['airedOn']);
	if (airedOn != null) {
		mangaDetailsQueryMangasRelatedManga.airedOn = airedOn;
	}
	final MangaDetailsQueryMangasRelatedMangaReleasedOn? releasedOn = jsonConvert.convert<MangaDetailsQueryMangasRelatedMangaReleasedOn>(json['releasedOn']);
	if (releasedOn != null) {
		mangaDetailsQueryMangasRelatedManga.releasedOn = releasedOn;
	}
	final int? volumes = jsonConvert.convert<int>(json['volumes']);
	if (volumes != null) {
		mangaDetailsQueryMangasRelatedManga.volumes = volumes;
	}
	final int? chapters = jsonConvert.convert<int>(json['chapters']);
	if (chapters != null) {
		mangaDetailsQueryMangasRelatedManga.chapters = chapters;
	}
	final List<MangaDetailsQueryMangasRelatedMangaGenres>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MangaDetailsQueryMangasRelatedMangaGenres>(e) as MangaDetailsQueryMangasRelatedMangaGenres).toList();
	if (genres != null) {
		mangaDetailsQueryMangasRelatedManga.genres = genres;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		mangaDetailsQueryMangasRelatedManga.kind = kind;
	}
	final bool? isCensored = jsonConvert.convert<bool>(json['isCensored']);
	if (isCensored != null) {
		mangaDetailsQueryMangasRelatedManga.isCensored = isCensored;
	}
	final double? score = jsonConvert.convert<double>(json['score']);
	if (score != null) {
		mangaDetailsQueryMangasRelatedManga.score = score;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		mangaDetailsQueryMangasRelatedManga.status = status;
	}
	return mangaDetailsQueryMangasRelatedManga;
}

Map<String, dynamic> $MangaDetailsQueryMangasRelatedMangaToJson(MangaDetailsQueryMangasRelatedManga entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['malId'] = entity.malId;
	data['name'] = entity.name;
	data['english'] = entity.english;
	data['japanese'] = entity.japanese;
	data['russian'] = entity.russian;
	data['poster'] = entity.poster.toJson();
	data['description'] = entity.description;
	data['airedOn'] = entity.airedOn.toJson();
	data['releasedOn'] = entity.releasedOn.toJson();
	data['volumes'] = entity.volumes;
	data['chapters'] = entity.chapters;
	data['genres'] =  entity.genres.map((v) => v.toJson()).toList();
	data['kind'] = entity.kind;
	data['isCensored'] = entity.isCensored;
	data['score'] = entity.score;
	data['status'] = entity.status;
	return data;
}

extension MangaDetailsQueryMangasRelatedMangaExtension on MangaDetailsQueryMangasRelatedManga {
	MangaDetailsQueryMangasRelatedManga copyWith({
	String? id,
	String? malId,
	String? name,
	String? english,
	String? japanese,
	String? russian,
	MangaDetailsQueryMangasRelatedMangaPoster? poster,
	String? description,
	MangaDetailsQueryMangasRelatedMangaAiredOn? airedOn,
	MangaDetailsQueryMangasRelatedMangaReleasedOn? releasedOn,
	int? volumes,
	int? chapters,
	List<MangaDetailsQueryMangasRelatedMangaGenres>? genres,
	String? kind,
	bool? isCensored,
	double? score,
	String? status,
	}) {
		return MangaDetailsQueryMangasRelatedManga()
			..id = id ?? this.id
			..malId = malId ?? this.malId
			..name = name ?? this.name
			..english = english ?? this.english
			..japanese = japanese ?? this.japanese
			..russian = russian ?? this.russian
			..poster = poster ?? this.poster
			..description = description ?? this.description
			..airedOn = airedOn ?? this.airedOn
			..releasedOn = releasedOn ?? this.releasedOn
			..volumes = volumes ?? this.volumes
			..chapters = chapters ?? this.chapters
			..genres = genres ?? this.genres
			..kind = kind ?? this.kind
			..isCensored = isCensored ?? this.isCensored
			..score = score ?? this.score
			..status = status ?? this.status;
	}
}


MangaDetailsQueryMangasRelatedMangaPoster $MangaDetailsQueryMangasRelatedMangaPosterFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangasRelatedMangaPoster mangaDetailsQueryMangasRelatedMangaPoster = MangaDetailsQueryMangasRelatedMangaPoster();
	final String? originalUrl = jsonConvert.convert<String>(json['originalUrl']);
	if (originalUrl != null) {
		mangaDetailsQueryMangasRelatedMangaPoster.originalUrl = originalUrl;
	}
	final String? mainAlt2xUrl = jsonConvert.convert<String>(json['mainAlt2xUrl']);
	if (mainAlt2xUrl != null) {
		mangaDetailsQueryMangasRelatedMangaPoster.mainAlt2xUrl = mainAlt2xUrl;
	}
	return mangaDetailsQueryMangasRelatedMangaPoster;
}

Map<String, dynamic> $MangaDetailsQueryMangasRelatedMangaPosterToJson(MangaDetailsQueryMangasRelatedMangaPoster entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['originalUrl'] = entity.originalUrl;
	data['mainAlt2xUrl'] = entity.mainAlt2xUrl;
	return data;
}

extension MangaDetailsQueryMangasRelatedMangaPosterExtension on MangaDetailsQueryMangasRelatedMangaPoster {
	MangaDetailsQueryMangasRelatedMangaPoster copyWith({
	String? originalUrl,
	String? mainAlt2xUrl,
	}) {
		return MangaDetailsQueryMangasRelatedMangaPoster()
			..originalUrl = originalUrl ?? this.originalUrl
			..mainAlt2xUrl = mainAlt2xUrl ?? this.mainAlt2xUrl;
	}
}


MangaDetailsQueryMangasRelatedMangaAiredOn $MangaDetailsQueryMangasRelatedMangaAiredOnFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangasRelatedMangaAiredOn mangaDetailsQueryMangasRelatedMangaAiredOn = MangaDetailsQueryMangasRelatedMangaAiredOn();
	final String? date = jsonConvert.convert<String>(json['date']);
	if (date != null) {
		mangaDetailsQueryMangasRelatedMangaAiredOn.date = date;
	}
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mangaDetailsQueryMangasRelatedMangaAiredOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mangaDetailsQueryMangasRelatedMangaAiredOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mangaDetailsQueryMangasRelatedMangaAiredOn.year = year;
	}
	return mangaDetailsQueryMangasRelatedMangaAiredOn;
}

Map<String, dynamic> $MangaDetailsQueryMangasRelatedMangaAiredOnToJson(MangaDetailsQueryMangasRelatedMangaAiredOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['date'] = entity.date;
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MangaDetailsQueryMangasRelatedMangaAiredOnExtension on MangaDetailsQueryMangasRelatedMangaAiredOn {
	MangaDetailsQueryMangasRelatedMangaAiredOn copyWith({
	String? date,
	int? day,
	int? month,
	int? year,
	}) {
		return MangaDetailsQueryMangasRelatedMangaAiredOn()
			..date = date ?? this.date
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MangaDetailsQueryMangasRelatedMangaReleasedOn $MangaDetailsQueryMangasRelatedMangaReleasedOnFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangasRelatedMangaReleasedOn mangaDetailsQueryMangasRelatedMangaReleasedOn = MangaDetailsQueryMangasRelatedMangaReleasedOn();
	final String? date = jsonConvert.convert<String>(json['date']);
	if (date != null) {
		mangaDetailsQueryMangasRelatedMangaReleasedOn.date = date;
	}
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mangaDetailsQueryMangasRelatedMangaReleasedOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mangaDetailsQueryMangasRelatedMangaReleasedOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mangaDetailsQueryMangasRelatedMangaReleasedOn.year = year;
	}
	return mangaDetailsQueryMangasRelatedMangaReleasedOn;
}

Map<String, dynamic> $MangaDetailsQueryMangasRelatedMangaReleasedOnToJson(MangaDetailsQueryMangasRelatedMangaReleasedOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['date'] = entity.date;
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MangaDetailsQueryMangasRelatedMangaReleasedOnExtension on MangaDetailsQueryMangasRelatedMangaReleasedOn {
	MangaDetailsQueryMangasRelatedMangaReleasedOn copyWith({
	String? date,
	int? day,
	int? month,
	int? year,
	}) {
		return MangaDetailsQueryMangasRelatedMangaReleasedOn()
			..date = date ?? this.date
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MangaDetailsQueryMangasRelatedMangaGenres $MangaDetailsQueryMangasRelatedMangaGenresFromJson(Map<String, dynamic> json) {
	final MangaDetailsQueryMangasRelatedMangaGenres mangaDetailsQueryMangasRelatedMangaGenres = MangaDetailsQueryMangasRelatedMangaGenres();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		mangaDetailsQueryMangasRelatedMangaGenres.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		mangaDetailsQueryMangasRelatedMangaGenres.name = name;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		mangaDetailsQueryMangasRelatedMangaGenres.kind = kind;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		mangaDetailsQueryMangasRelatedMangaGenres.russian = russian;
	}
	return mangaDetailsQueryMangasRelatedMangaGenres;
}

Map<String, dynamic> $MangaDetailsQueryMangasRelatedMangaGenresToJson(MangaDetailsQueryMangasRelatedMangaGenres entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['kind'] = entity.kind;
	data['russian'] = entity.russian;
	return data;
}

extension MangaDetailsQueryMangasRelatedMangaGenresExtension on MangaDetailsQueryMangasRelatedMangaGenres {
	MangaDetailsQueryMangasRelatedMangaGenres copyWith({
	String? id,
	String? name,
	String? kind,
	String? russian,
	}) {
		return MangaDetailsQueryMangasRelatedMangaGenres()
			..id = id ?? this.id
			..name = name ?? this.name
			..kind = kind ?? this.kind
			..russian = russian ?? this.russian;
	}
}

import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/manga_list_query_entity.dart';

MangaListQueryEntity $MangaListQueryEntityFromJson(Map<String, dynamic> json) {
	final MangaListQueryEntity mangaListQueryEntity = MangaListQueryEntity();
	final List<MangaListQueryMangas>? mangas = (json['mangas'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MangaListQueryMangas>(e) as MangaListQueryMangas).toList();
	if (mangas != null) {
		mangaListQueryEntity.mangas = mangas;
	}
	return mangaListQueryEntity;
}

Map<String, dynamic> $MangaListQueryEntityToJson(MangaListQueryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['mangas'] =  entity.mangas.map((v) => v.toJson()).toList();
	return data;
}

extension MangaListQueryEntityExtension on MangaListQueryEntity {
	MangaListQueryEntity copyWith({
	List<MangaListQueryMangas>? mangas,
	}) {
		return MangaListQueryEntity()
			..mangas = mangas ?? this.mangas;
	}
}


MangaListQueryMangas $MangaListQueryMangasFromJson(Map<String, dynamic> json) {
	final MangaListQueryMangas mangaListQueryMangas = MangaListQueryMangas();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		mangaListQueryMangas.id = id;
	}
	final String? malId = jsonConvert.convert<String>(json['malId']);
	if (malId != null) {
		mangaListQueryMangas.malId = malId;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		mangaListQueryMangas.name = name;
	}
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		mangaListQueryMangas.english = english;
	}
	final String? japanese = jsonConvert.convert<String>(json['japanese']);
	if (japanese != null) {
		mangaListQueryMangas.japanese = japanese;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		mangaListQueryMangas.russian = russian;
	}
	final MangaListQueryMangasPoster? poster = jsonConvert.convert<MangaListQueryMangasPoster>(json['poster']);
	if (poster != null) {
		mangaListQueryMangas.poster = poster;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		mangaListQueryMangas.description = description;
	}
	final MangaListQueryMangasAiredOn? airedOn = jsonConvert.convert<MangaListQueryMangasAiredOn>(json['airedOn']);
	if (airedOn != null) {
		mangaListQueryMangas.airedOn = airedOn;
	}
	final MangaListQueryMangasReleasedOn? releasedOn = jsonConvert.convert<MangaListQueryMangasReleasedOn>(json['releasedOn']);
	if (releasedOn != null) {
		mangaListQueryMangas.releasedOn = releasedOn;
	}
	final int? volumes = jsonConvert.convert<int>(json['volumes']);
	if (volumes != null) {
		mangaListQueryMangas.volumes = volumes;
	}
	final int? chapters = jsonConvert.convert<int>(json['chapters']);
	if (chapters != null) {
		mangaListQueryMangas.chapters = chapters;
	}
	final List<MangaListQueryMangasGenres>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MangaListQueryMangasGenres>(e) as MangaListQueryMangasGenres).toList();
	if (genres != null) {
		mangaListQueryMangas.genres = genres;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		mangaListQueryMangas.kind = kind;
	}
	final bool? isCensored = jsonConvert.convert<bool>(json['isCensored']);
	if (isCensored != null) {
		mangaListQueryMangas.isCensored = isCensored;
	}
	final double? score = jsonConvert.convert<double>(json['score']);
	if (score != null) {
		mangaListQueryMangas.score = score;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		mangaListQueryMangas.status = status;
	}
	final List<MangaListQueryMangasPublishers>? publishers = (json['publishers'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MangaListQueryMangasPublishers>(e) as MangaListQueryMangasPublishers).toList();
	if (publishers != null) {
		mangaListQueryMangas.publishers = publishers;
	}
	return mangaListQueryMangas;
}

Map<String, dynamic> $MangaListQueryMangasToJson(MangaListQueryMangas entity) {
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
	return data;
}

extension MangaListQueryMangasExtension on MangaListQueryMangas {
	MangaListQueryMangas copyWith({
	String? id,
	String? malId,
	String? name,
	String? english,
	String? japanese,
	String? russian,
	MangaListQueryMangasPoster? poster,
	String? description,
	MangaListQueryMangasAiredOn? airedOn,
	MangaListQueryMangasReleasedOn? releasedOn,
	int? volumes,
	int? chapters,
	List<MangaListQueryMangasGenres>? genres,
	String? kind,
	bool? isCensored,
	double? score,
	String? status,
	List<MangaListQueryMangasPublishers>? publishers,
	}) {
		return MangaListQueryMangas()
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
			..publishers = publishers ?? this.publishers;
	}
}


MangaListQueryMangasPoster $MangaListQueryMangasPosterFromJson(Map<String, dynamic> json) {
	final MangaListQueryMangasPoster mangaListQueryMangasPoster = MangaListQueryMangasPoster();
	final String? originalUrl = jsonConvert.convert<String>(json['originalUrl']);
	if (originalUrl != null) {
		mangaListQueryMangasPoster.originalUrl = originalUrl;
	}
	final String? mainAlt2xUrl = jsonConvert.convert<String>(json['mainAlt2xUrl']);
	if (mainAlt2xUrl != null) {
		mangaListQueryMangasPoster.mainAlt2xUrl = mainAlt2xUrl;
	}
	return mangaListQueryMangasPoster;
}

Map<String, dynamic> $MangaListQueryMangasPosterToJson(MangaListQueryMangasPoster entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['originalUrl'] = entity.originalUrl;
	data['mainAlt2xUrl'] = entity.mainAlt2xUrl;
	return data;
}

extension MangaListQueryMangasPosterExtension on MangaListQueryMangasPoster {
	MangaListQueryMangasPoster copyWith({
	String? originalUrl,
	String? mainAlt2xUrl,
	}) {
		return MangaListQueryMangasPoster()
			..originalUrl = originalUrl ?? this.originalUrl
			..mainAlt2xUrl = mainAlt2xUrl ?? this.mainAlt2xUrl;
	}
}


MangaListQueryMangasAiredOn $MangaListQueryMangasAiredOnFromJson(Map<String, dynamic> json) {
	final MangaListQueryMangasAiredOn mangaListQueryMangasAiredOn = MangaListQueryMangasAiredOn();
	final String? date = jsonConvert.convert<String>(json['date']);
	if (date != null) {
		mangaListQueryMangasAiredOn.date = date;
	}
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mangaListQueryMangasAiredOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mangaListQueryMangasAiredOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mangaListQueryMangasAiredOn.year = year;
	}
	return mangaListQueryMangasAiredOn;
}

Map<String, dynamic> $MangaListQueryMangasAiredOnToJson(MangaListQueryMangasAiredOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['date'] = entity.date;
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MangaListQueryMangasAiredOnExtension on MangaListQueryMangasAiredOn {
	MangaListQueryMangasAiredOn copyWith({
	String? date,
	int? day,
	int? month,
	int? year,
	}) {
		return MangaListQueryMangasAiredOn()
			..date = date ?? this.date
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MangaListQueryMangasReleasedOn $MangaListQueryMangasReleasedOnFromJson(Map<String, dynamic> json) {
	final MangaListQueryMangasReleasedOn mangaListQueryMangasReleasedOn = MangaListQueryMangasReleasedOn();
	final String? date = jsonConvert.convert<String>(json['date']);
	if (date != null) {
		mangaListQueryMangasReleasedOn.date = date;
	}
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mangaListQueryMangasReleasedOn.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mangaListQueryMangasReleasedOn.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mangaListQueryMangasReleasedOn.year = year;
	}
	return mangaListQueryMangasReleasedOn;
}

Map<String, dynamic> $MangaListQueryMangasReleasedOnToJson(MangaListQueryMangasReleasedOn entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['date'] = entity.date;
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MangaListQueryMangasReleasedOnExtension on MangaListQueryMangasReleasedOn {
	MangaListQueryMangasReleasedOn copyWith({
	String? date,
	int? day,
	int? month,
	int? year,
	}) {
		return MangaListQueryMangasReleasedOn()
			..date = date ?? this.date
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MangaListQueryMangasGenres $MangaListQueryMangasGenresFromJson(Map<String, dynamic> json) {
	final MangaListQueryMangasGenres mangaListQueryMangasGenres = MangaListQueryMangasGenres();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		mangaListQueryMangasGenres.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		mangaListQueryMangasGenres.name = name;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		mangaListQueryMangasGenres.kind = kind;
	}
	final String? russian = jsonConvert.convert<String>(json['russian']);
	if (russian != null) {
		mangaListQueryMangasGenres.russian = russian;
	}
	return mangaListQueryMangasGenres;
}

Map<String, dynamic> $MangaListQueryMangasGenresToJson(MangaListQueryMangasGenres entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['kind'] = entity.kind;
	data['russian'] = entity.russian;
	return data;
}

extension MangaListQueryMangasGenresExtension on MangaListQueryMangasGenres {
	MangaListQueryMangasGenres copyWith({
	String? id,
	String? name,
	String? kind,
	String? russian,
	}) {
		return MangaListQueryMangasGenres()
			..id = id ?? this.id
			..name = name ?? this.name
			..kind = kind ?? this.kind
			..russian = russian ?? this.russian;
	}
}


MangaListQueryMangasPublishers $MangaListQueryMangasPublishersFromJson(Map<String, dynamic> json) {
	final MangaListQueryMangasPublishers mangaListQueryMangasPublishers = MangaListQueryMangasPublishers();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		mangaListQueryMangasPublishers.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		mangaListQueryMangasPublishers.name = name;
	}
	return mangaListQueryMangasPublishers;
}

Map<String, dynamic> $MangaListQueryMangasPublishersToJson(MangaListQueryMangasPublishers entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	return data;
}

extension MangaListQueryMangasPublishersExtension on MangaListQueryMangasPublishers {
	MangaListQueryMangasPublishers copyWith({
	String? id,
	String? name,
	}) {
		return MangaListQueryMangasPublishers()
			..id = id ?? this.id
			..name = name ?? this.name;
	}
}

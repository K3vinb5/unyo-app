import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/jikan/jikan_media_entity.dart';

JikanMediaListEntity $JikanMediaListEntityFromJson(Map<String, dynamic> json) {
	final JikanMediaListEntity jikanMediaListEntity = JikanMediaListEntity();
	final List<JikanMediaData>? data = (json['data'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<JikanMediaData>(e) as JikanMediaData).toList();
	if (data != null) {
		jikanMediaListEntity.data = data;
	}
	final JikanMediaPagination? pagination = jsonConvert.convert<JikanMediaPagination>(json['pagination']);
	if (pagination != null) {
		jikanMediaListEntity.pagination = pagination;
	}
	return jikanMediaListEntity;
}

Map<String, dynamic> $JikanMediaListEntityToJson(JikanMediaListEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['data'] =  entity.data.map((v) => v.toJson()).toList();
	data['pagination'] = entity.pagination.toJson();
	return data;
}

extension JikanMediaListEntityExtension on JikanMediaListEntity {
	JikanMediaListEntity copyWith({
	List<JikanMediaData>? data,
	JikanMediaPagination? pagination,
	}) {
		return JikanMediaListEntity()
			..data = data ?? this.data
			..pagination = pagination ?? this.pagination;
	}
}


JikanMediaData $JikanMediaDataFromJson(Map<String, dynamic> json) {
	final JikanMediaData jikanMediaData = JikanMediaData();
	final int? malId = jsonConvert.convert<int>(json['mal_id']);
	if (malId != null) {
		jikanMediaData.malId = malId;
	}
	final String? title = jsonConvert.convert<String>(json['title']);
	if (title != null) {
		jikanMediaData.title = title;
	}
	final String? titleEnglish = jsonConvert.convert<String>(json['title_english']);
	if (titleEnglish != null) {
		jikanMediaData.titleEnglish = titleEnglish;
	}
	final String? titleJapanese = jsonConvert.convert<String>(json['title_japanese']);
	if (titleJapanese != null) {
		jikanMediaData.titleJapanese = titleJapanese;
	}
	final String? type = jsonConvert.convert<String>(json['type']);
	if (type != null) {
		jikanMediaData.type = type;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		jikanMediaData.status = status;
	}
	final String? synopsis = jsonConvert.convert<String>(json['synopsis']);
	if (synopsis != null) {
		jikanMediaData.synopsis = synopsis;
	}
	final double? score = jsonConvert.convert<double>(json['score']);
	if (score != null) {
		jikanMediaData.score = score;
	}
	final String? rating = jsonConvert.convert<String>(json['rating']);
	if (rating != null) {
		jikanMediaData.rating = rating;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		jikanMediaData.episodes = episodes;
	}
	final int? chapters = jsonConvert.convert<int>(json['chapters']);
	if (chapters != null) {
		jikanMediaData.chapters = chapters;
	}
	final int? volumes = jsonConvert.convert<int>(json['volumes']);
	if (volumes != null) {
		jikanMediaData.volumes = volumes;
	}
	final String? duration = jsonConvert.convert<String>(json['duration']);
	if (duration != null) {
		jikanMediaData.duration = duration;
	}
	final String? season = jsonConvert.convert<String>(json['season']);
	if (season != null) {
		jikanMediaData.season = season;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		jikanMediaData.year = year;
	}
	final int? popularity = jsonConvert.convert<int>(json['popularity']);
	if (popularity != null) {
		jikanMediaData.popularity = popularity;
	}
	final int? members = jsonConvert.convert<int>(json['members']);
	if (members != null) {
		jikanMediaData.members = members;
	}
	final JikanMediaDataImages? images = jsonConvert.convert<JikanMediaDataImages>(json['images']);
	if (images != null) {
		jikanMediaData.images = images;
	}
	final JikanMediaDataAired? aired = jsonConvert.convert<JikanMediaDataAired>(json['aired']);
	if (aired != null) {
		jikanMediaData.aired = aired;
	}
	final JikanMediaDataAired? published = jsonConvert.convert<JikanMediaDataAired>(json['published']);
	if (published != null) {
		jikanMediaData.published = published;
	}
	final List<JikanMediaDataGenre>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<JikanMediaDataGenre>(e) as JikanMediaDataGenre).toList();
	if (genres != null) {
		jikanMediaData.genres = genres;
	}
	final List<JikanMediaDataGenre>? explicitGenres = (json['explicit_genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<JikanMediaDataGenre>(e) as JikanMediaDataGenre).toList();
	if (explicitGenres != null) {
		jikanMediaData.explicitGenres = explicitGenres;
	}
	return jikanMediaData;
}

Map<String, dynamic> $JikanMediaDataToJson(JikanMediaData entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['mal_id'] = entity.malId;
	data['title'] = entity.title;
	data['title_english'] = entity.titleEnglish;
	data['title_japanese'] = entity.titleJapanese;
	data['type'] = entity.type;
	data['status'] = entity.status;
	data['synopsis'] = entity.synopsis;
	data['score'] = entity.score;
	data['rating'] = entity.rating;
	data['episodes'] = entity.episodes;
	data['chapters'] = entity.chapters;
	data['volumes'] = entity.volumes;
	data['duration'] = entity.duration;
	data['season'] = entity.season;
	data['year'] = entity.year;
	data['popularity'] = entity.popularity;
	data['members'] = entity.members;
	data['images'] = entity.images.toJson();
	data['aired'] = entity.aired.toJson();
	data['published'] = entity.published.toJson();
	data['genres'] =  entity.genres.map((v) => v.toJson()).toList();
	data['explicit_genres'] =  entity.explicitGenres.map((v) => v.toJson()).toList();
	return data;
}

extension JikanMediaDataExtension on JikanMediaData {
	JikanMediaData copyWith({
	int? malId,
	String? title,
	String? titleEnglish,
	String? titleJapanese,
	String? type,
	String? status,
	String? synopsis,
	double? score,
	String? rating,
	int? episodes,
	int? chapters,
	int? volumes,
	String? duration,
	String? season,
	int? year,
	int? popularity,
	int? members,
	JikanMediaDataImages? images,
	JikanMediaDataAired? aired,
	JikanMediaDataAired? published,
	List<JikanMediaDataGenre>? genres,
	List<JikanMediaDataGenre>? explicitGenres,
	}) {
		return JikanMediaData()
			..malId = malId ?? this.malId
			..title = title ?? this.title
			..titleEnglish = titleEnglish ?? this.titleEnglish
			..titleJapanese = titleJapanese ?? this.titleJapanese
			..type = type ?? this.type
			..status = status ?? this.status
			..synopsis = synopsis ?? this.synopsis
			..score = score ?? this.score
			..rating = rating ?? this.rating
			..episodes = episodes ?? this.episodes
			..chapters = chapters ?? this.chapters
			..volumes = volumes ?? this.volumes
			..duration = duration ?? this.duration
			..season = season ?? this.season
			..year = year ?? this.year
			..popularity = popularity ?? this.popularity
			..members = members ?? this.members
			..images = images ?? this.images
			..aired = aired ?? this.aired
			..published = published ?? this.published
			..genres = genres ?? this.genres
			..explicitGenres = explicitGenres ?? this.explicitGenres;
	}
}


JikanMediaDataImages $JikanMediaDataImagesFromJson(Map<String, dynamic> json) {
	final JikanMediaDataImages jikanMediaDataImages = JikanMediaDataImages();
	final JikanMediaDataImagesJpg? jpg = jsonConvert.convert<JikanMediaDataImagesJpg>(json['jpg']);
	if (jpg != null) {
		jikanMediaDataImages.jpg = jpg;
	}
	return jikanMediaDataImages;
}

Map<String, dynamic> $JikanMediaDataImagesToJson(JikanMediaDataImages entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['jpg'] = entity.jpg.toJson();
	return data;
}

extension JikanMediaDataImagesExtension on JikanMediaDataImages {
	JikanMediaDataImages copyWith({
	JikanMediaDataImagesJpg? jpg,
	}) {
		return JikanMediaDataImages()
			..jpg = jpg ?? this.jpg;
	}
}


JikanMediaDataImagesJpg $JikanMediaDataImagesJpgFromJson(Map<String, dynamic> json) {
	final JikanMediaDataImagesJpg jikanMediaDataImagesJpg = JikanMediaDataImagesJpg();
	final String? imageUrl = jsonConvert.convert<String>(json['image_url']);
	if (imageUrl != null) {
		jikanMediaDataImagesJpg.imageUrl = imageUrl;
	}
	final String? smallImageUrl = jsonConvert.convert<String>(json['small_image_url']);
	if (smallImageUrl != null) {
		jikanMediaDataImagesJpg.smallImageUrl = smallImageUrl;
	}
	final String? largeImageUrl = jsonConvert.convert<String>(json['large_image_url']);
	if (largeImageUrl != null) {
		jikanMediaDataImagesJpg.largeImageUrl = largeImageUrl;
	}
	return jikanMediaDataImagesJpg;
}

Map<String, dynamic> $JikanMediaDataImagesJpgToJson(JikanMediaDataImagesJpg entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['image_url'] = entity.imageUrl;
	data['small_image_url'] = entity.smallImageUrl;
	data['large_image_url'] = entity.largeImageUrl;
	return data;
}

extension JikanMediaDataImagesJpgExtension on JikanMediaDataImagesJpg {
	JikanMediaDataImagesJpg copyWith({
	String? imageUrl,
	String? smallImageUrl,
	String? largeImageUrl,
	}) {
		return JikanMediaDataImagesJpg()
			..imageUrl = imageUrl ?? this.imageUrl
			..smallImageUrl = smallImageUrl ?? this.smallImageUrl
			..largeImageUrl = largeImageUrl ?? this.largeImageUrl;
	}
}


JikanMediaDataAired $JikanMediaDataAiredFromJson(Map<String, dynamic> json) {
	final JikanMediaDataAired jikanMediaDataAired = JikanMediaDataAired();
	final String? from = jsonConvert.convert<String>(json['from']);
	if (from != null) {
		jikanMediaDataAired.from = from;
	}
	final String? to = jsonConvert.convert<String>(json['to']);
	if (to != null) {
		jikanMediaDataAired.to = to;
	}
	return jikanMediaDataAired;
}

Map<String, dynamic> $JikanMediaDataAiredToJson(JikanMediaDataAired entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['from'] = entity.from;
	data['to'] = entity.to;
	return data;
}

extension JikanMediaDataAiredExtension on JikanMediaDataAired {
	JikanMediaDataAired copyWith({
	String? from,
	String? to,
	}) {
		return JikanMediaDataAired()
			..from = from ?? this.from
			..to = to ?? this.to;
	}
}


JikanMediaDataGenre $JikanMediaDataGenreFromJson(Map<String, dynamic> json) {
	final JikanMediaDataGenre jikanMediaDataGenre = JikanMediaDataGenre();
	final int? malId = jsonConvert.convert<int>(json['mal_id']);
	if (malId != null) {
		jikanMediaDataGenre.malId = malId;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		jikanMediaDataGenre.name = name;
	}
	return jikanMediaDataGenre;
}

Map<String, dynamic> $JikanMediaDataGenreToJson(JikanMediaDataGenre entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['mal_id'] = entity.malId;
	data['name'] = entity.name;
	return data;
}

extension JikanMediaDataGenreExtension on JikanMediaDataGenre {
	JikanMediaDataGenre copyWith({
	int? malId,
	String? name,
	}) {
		return JikanMediaDataGenre()
			..malId = malId ?? this.malId
			..name = name ?? this.name;
	}
}


JikanMediaPagination $JikanMediaPaginationFromJson(Map<String, dynamic> json) {
	final JikanMediaPagination jikanMediaPagination = JikanMediaPagination();
	final int? lastVisiblePage = jsonConvert.convert<int>(json['last_visible_page']);
	if (lastVisiblePage != null) {
		jikanMediaPagination.lastVisiblePage = lastVisiblePage;
	}
	final bool? hasNextPage = jsonConvert.convert<bool>(json['has_next_page']);
	if (hasNextPage != null) {
		jikanMediaPagination.hasNextPage = hasNextPage;
	}
	final int? currentPage = jsonConvert.convert<int>(json['current_page']);
	if (currentPage != null) {
		jikanMediaPagination.currentPage = currentPage;
	}
	final JikanMediaPaginationItems? items = jsonConvert.convert<JikanMediaPaginationItems>(json['items']);
	if (items != null) {
		jikanMediaPagination.items = items;
	}
	return jikanMediaPagination;
}

Map<String, dynamic> $JikanMediaPaginationToJson(JikanMediaPagination entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['last_visible_page'] = entity.lastVisiblePage;
	data['has_next_page'] = entity.hasNextPage;
	data['current_page'] = entity.currentPage;
	data['items'] = entity.items.toJson();
	return data;
}

extension JikanMediaPaginationExtension on JikanMediaPagination {
	JikanMediaPagination copyWith({
	int? lastVisiblePage,
	bool? hasNextPage,
	int? currentPage,
	JikanMediaPaginationItems? items,
	}) {
		return JikanMediaPagination()
			..lastVisiblePage = lastVisiblePage ?? this.lastVisiblePage
			..hasNextPage = hasNextPage ?? this.hasNextPage
			..currentPage = currentPage ?? this.currentPage
			..items = items ?? this.items;
	}
}


JikanMediaPaginationItems $JikanMediaPaginationItemsFromJson(Map<String, dynamic> json) {
	final JikanMediaPaginationItems jikanMediaPaginationItems = JikanMediaPaginationItems();
	final int? count = jsonConvert.convert<int>(json['count']);
	if (count != null) {
		jikanMediaPaginationItems.count = count;
	}
	final int? total = jsonConvert.convert<int>(json['total']);
	if (total != null) {
		jikanMediaPaginationItems.total = total;
	}
	final int? perPage = jsonConvert.convert<int>(json['per_page']);
	if (perPage != null) {
		jikanMediaPaginationItems.perPage = perPage;
	}
	return jikanMediaPaginationItems;
}

Map<String, dynamic> $JikanMediaPaginationItemsToJson(JikanMediaPaginationItems entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['count'] = entity.count;
	data['total'] = entity.total;
	data['per_page'] = entity.perPage;
	return data;
}

extension JikanMediaPaginationItemsExtension on JikanMediaPaginationItems {
	JikanMediaPaginationItems copyWith({
	int? count,
	int? total,
	int? perPage,
	}) {
		return JikanMediaPaginationItems()
			..count = count ?? this.count
			..total = total ?? this.total
			..perPage = perPage ?? this.perPage;
	}
}

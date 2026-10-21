import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/anilist/media_collection_trendingOrPopular_graphql_entity.dart';

MediaCollectionTrendingOrPopularGraphqlEntity $MediaCollectionTrendingOrPopularGraphqlEntityFromJson(Map<String, dynamic> json) {
	final MediaCollectionTrendingOrPopularGraphqlEntity mediaCollectionTrendingOrPopularGraphqlEntity = MediaCollectionTrendingOrPopularGraphqlEntity();
	final MediaCollectionTrendingOrPopularGraphqlDtoPage? page = jsonConvert.convert<MediaCollectionTrendingOrPopularGraphqlDtoPage>(json['Page']);
	if (page != null) {
		mediaCollectionTrendingOrPopularGraphqlEntity.page = page;
	}
	return mediaCollectionTrendingOrPopularGraphqlEntity;
}

Map<String, dynamic> $MediaCollectionTrendingOrPopularGraphqlEntityToJson(MediaCollectionTrendingOrPopularGraphqlEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['Page'] = entity.page.toJson();
	return data;
}

extension MediaCollectionTrendingOrPopularGraphqlEntityExtension on MediaCollectionTrendingOrPopularGraphqlEntity {
	MediaCollectionTrendingOrPopularGraphqlEntity copyWith({
	MediaCollectionTrendingOrPopularGraphqlDtoPage? page,
	}) {
		return MediaCollectionTrendingOrPopularGraphqlEntity()
			..page = page ?? this.page;
	}
}


MediaCollectionTrendingOrPopularGraphqlDtoPage $MediaCollectionTrendingOrPopularGraphqlDtoPageFromJson(Map<String, dynamic> json) {
	final MediaCollectionTrendingOrPopularGraphqlDtoPage mediaCollectionTrendingOrPopularGraphqlDtoPage = MediaCollectionTrendingOrPopularGraphqlDtoPage();
	final List<MediaCollectionTrendingOrPopularGraphqlDtoPageMedia>? media = (json['media'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MediaCollectionTrendingOrPopularGraphqlDtoPageMedia>(e) as MediaCollectionTrendingOrPopularGraphqlDtoPageMedia).toList();
	if (media != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPage.media = media;
	}
	return mediaCollectionTrendingOrPopularGraphqlDtoPage;
}

Map<String, dynamic> $MediaCollectionTrendingOrPopularGraphqlDtoPageToJson(MediaCollectionTrendingOrPopularGraphqlDtoPage entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['media'] =  entity.media.map((v) => v.toJson()).toList();
	return data;
}

extension MediaCollectionTrendingOrPopularGraphqlDtoPageExtension on MediaCollectionTrendingOrPopularGraphqlDtoPage {
	MediaCollectionTrendingOrPopularGraphqlDtoPage copyWith({
	List<MediaCollectionTrendingOrPopularGraphqlDtoPageMedia>? media,
	}) {
		return MediaCollectionTrendingOrPopularGraphqlDtoPage()
			..media = media ?? this.media;
	}
}


MediaCollectionTrendingOrPopularGraphqlDtoPageMedia $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaFromJson(Map<String, dynamic> json) {
	final MediaCollectionTrendingOrPopularGraphqlDtoPageMedia mediaCollectionTrendingOrPopularGraphqlDtoPageMedia = MediaCollectionTrendingOrPopularGraphqlDtoPageMedia();
	final dynamic nextAiringEpisode = json['nextAiringEpisode'];
	if (nextAiringEpisode != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.nextAiringEpisode = nextAiringEpisode;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.status = status;
	}
	final bool? isFavourite = jsonConvert.convert<bool>(json['isFavourite']);
	if (isFavourite != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.isFavourite = isFavourite;
	}
	final String? season = jsonConvert.convert<String>(json['season']);
	if (season != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.season = season;
	}
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.id = id;
	}
	final int? idMal = jsonConvert.convert<int>(json['idMal']);
	if (idMal != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.idMal = idMal;
	}
	final bool? isAdult = jsonConvert.convert<bool>(json['isAdult']);
	if (isAdult != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.isAdult = isAdult;
	}
	final int? meanScore = jsonConvert.convert<int>(json['meanScore']);
	if (meanScore != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.meanScore = meanScore;
	}
	final int? popularity = jsonConvert.convert<int>(json['popularity']);
	if (popularity != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.popularity = popularity;
	}
	final List<String>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (genres != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.genres = genres;
	}
	final String? format = jsonConvert.convert<String>(json['format']);
	if (format != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.format = format;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.episodes = episodes;
	}
	final MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate? endDate = jsonConvert.convert<MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate>(json['endDate']);
	if (endDate != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.endDate = endDate;
	}
	final MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate? startDate = jsonConvert.convert<MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate>(json['startDate']);
	if (startDate != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.startDate = startDate;
	}
	final int? duration = jsonConvert.convert<int>(json['duration']);
	if (duration != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.duration = duration;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.description = description;
	}
	final MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage? coverImage = jsonConvert.convert<MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage>(json['coverImage']);
	if (coverImage != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.coverImage = coverImage;
	}
	final String? countryOfOrigin = jsonConvert.convert<String>(json['countryOfOrigin']);
	if (countryOfOrigin != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.countryOfOrigin = countryOfOrigin;
	}
	final int? chapters = jsonConvert.convert<int>(json['chapters']);
	if (chapters != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.chapters = chapters;
	}
	final String? bannerImage = jsonConvert.convert<String>(json['bannerImage']);
	if (bannerImage != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.bannerImage = bannerImage;
	}
	final int? averageScore = jsonConvert.convert<int>(json['averageScore']);
	if (averageScore != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.averageScore = averageScore;
	}
	final MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle? title = jsonConvert.convert<MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle>(json['title']);
	if (title != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMedia.title = title;
	}
	return mediaCollectionTrendingOrPopularGraphqlDtoPageMedia;
}

Map<String, dynamic> $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaToJson(MediaCollectionTrendingOrPopularGraphqlDtoPageMedia entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['nextAiringEpisode'] = entity.nextAiringEpisode;
	data['status'] = entity.status;
	data['isFavourite'] = entity.isFavourite;
	data['season'] = entity.season;
	data['id'] = entity.id;
	data['idMal'] = entity.idMal;
	data['isAdult'] = entity.isAdult;
	data['meanScore'] = entity.meanScore;
	data['popularity'] = entity.popularity;
	data['genres'] =  entity.genres;
	data['format'] = entity.format;
	data['episodes'] = entity.episodes;
	data['endDate'] = entity.endDate.toJson();
	data['startDate'] = entity.startDate.toJson();
	data['duration'] = entity.duration;
	data['description'] = entity.description;
	data['coverImage'] = entity.coverImage.toJson();
	data['countryOfOrigin'] = entity.countryOfOrigin;
	data['chapters'] = entity.chapters;
	data['bannerImage'] = entity.bannerImage;
	data['averageScore'] = entity.averageScore;
	data['title'] = entity.title.toJson();
	return data;
}

extension MediaCollectionTrendingOrPopularGraphqlDtoPageMediaExtension on MediaCollectionTrendingOrPopularGraphqlDtoPageMedia {
	MediaCollectionTrendingOrPopularGraphqlDtoPageMedia copyWith({
	dynamic nextAiringEpisode,
	String? status,
	bool? isFavourite,
	String? season,
	int? id,
	int? idMal,
	bool? isAdult,
	int? meanScore,
	int? popularity,
	List<String>? genres,
	String? format,
	int? episodes,
	MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate? endDate,
	MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate? startDate,
	int? duration,
	String? description,
	MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage? coverImage,
	String? countryOfOrigin,
	int? chapters,
	String? bannerImage,
	int? averageScore,
	MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle? title,
	}) {
		return MediaCollectionTrendingOrPopularGraphqlDtoPageMedia()
			..nextAiringEpisode = nextAiringEpisode ?? this.nextAiringEpisode
			..status = status ?? this.status
			..isFavourite = isFavourite ?? this.isFavourite
			..season = season ?? this.season
			..id = id ?? this.id
			..idMal = idMal ?? this.idMal
			..isAdult = isAdult ?? this.isAdult
			..meanScore = meanScore ?? this.meanScore
			..popularity = popularity ?? this.popularity
			..genres = genres ?? this.genres
			..format = format ?? this.format
			..episodes = episodes ?? this.episodes
			..endDate = endDate ?? this.endDate
			..startDate = startDate ?? this.startDate
			..duration = duration ?? this.duration
			..description = description ?? this.description
			..coverImage = coverImage ?? this.coverImage
			..countryOfOrigin = countryOfOrigin ?? this.countryOfOrigin
			..chapters = chapters ?? this.chapters
			..bannerImage = bannerImage ?? this.bannerImage
			..averageScore = averageScore ?? this.averageScore
			..title = title ?? this.title;
	}
}


MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDateFromJson(Map<String, dynamic> json) {
	final MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate mediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate = MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate.year = year;
	}
	return mediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate;
}

Map<String, dynamic> $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDateToJson(MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDateExtension on MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate {
	MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaCollectionTrendingOrPopularGraphqlDtoPageMediaEndDate()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDateFromJson(Map<String, dynamic> json) {
	final MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate mediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate = MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate.year = year;
	}
	return mediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate;
}

Map<String, dynamic> $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDateToJson(MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDateExtension on MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate {
	MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaCollectionTrendingOrPopularGraphqlDtoPageMediaStartDate()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImageFromJson(Map<String, dynamic> json) {
	final MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage mediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage = MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage();
	final String? large = jsonConvert.convert<String>(json['large']);
	if (large != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage.large = large;
	}
	return mediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage;
}

Map<String, dynamic> $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImageToJson(MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['large'] = entity.large;
	return data;
}

extension MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImageExtension on MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage {
	MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage copyWith({
	String? large,
	}) {
		return MediaCollectionTrendingOrPopularGraphqlDtoPageMediaCoverImage()
			..large = large ?? this.large;
	}
}


MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitleFromJson(Map<String, dynamic> json) {
	final MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle mediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle = MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle();
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle.english = english;
	}
	final String? native = jsonConvert.convert<String>(json['native']);
	if (native != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle.native = native;
	}
	final String? romaji = jsonConvert.convert<String>(json['romaji']);
	if (romaji != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle.romaji = romaji;
	}
	final String? userPreferred = jsonConvert.convert<String>(json['userPreferred']);
	if (userPreferred != null) {
		mediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle.userPreferred = userPreferred;
	}
	return mediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle;
}

Map<String, dynamic> $MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitleToJson(MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['english'] = entity.english;
	data['native'] = entity.native;
	data['romaji'] = entity.romaji;
	data['userPreferred'] = entity.userPreferred;
	return data;
}

extension MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitleExtension on MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle {
	MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle copyWith({
	String? english,
	String? native,
	String? romaji,
	String? userPreferred,
	}) {
		return MediaCollectionTrendingOrPopularGraphqlDtoPageMediaTitle()
			..english = english ?? this.english
			..native = native ?? this.native
			..romaji = romaji ?? this.romaji
			..userPreferred = userPreferred ?? this.userPreferred;
	}
}

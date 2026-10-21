import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/anilist/media_collection_recently_completed_graphql_entity.dart';

MediaCollectionRecentlyCompletedGraphqlEntity $MediaCollectionRecentlyCompletedGraphqlEntityFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyCompletedGraphqlEntity mediaCollectionRecentlyCompletedGraphqlEntity = MediaCollectionRecentlyCompletedGraphqlEntity();
	final MediaCollectionRecentlyCompletedGraphqlDtoPage? page = jsonConvert.convert<MediaCollectionRecentlyCompletedGraphqlDtoPage>(json['Page']);
	if (page != null) {
		mediaCollectionRecentlyCompletedGraphqlEntity.page = page;
	}
	return mediaCollectionRecentlyCompletedGraphqlEntity;
}

Map<String, dynamic> $MediaCollectionRecentlyCompletedGraphqlEntityToJson(MediaCollectionRecentlyCompletedGraphqlEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['Page'] = entity.page.toJson();
	return data;
}

extension MediaCollectionRecentlyCompletedGraphqlEntityExtension on MediaCollectionRecentlyCompletedGraphqlEntity {
	MediaCollectionRecentlyCompletedGraphqlEntity copyWith({
	MediaCollectionRecentlyCompletedGraphqlDtoPage? page,
	}) {
		return MediaCollectionRecentlyCompletedGraphqlEntity()
			..page = page ?? this.page;
	}
}


MediaCollectionRecentlyCompletedGraphqlDtoPage $MediaCollectionRecentlyCompletedGraphqlDtoPageFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyCompletedGraphqlDtoPage mediaCollectionRecentlyCompletedGraphqlDtoPage = MediaCollectionRecentlyCompletedGraphqlDtoPage();
	final List<MediaCollectionRecentlyCompletedGraphqlDtoPageMedia>? media = (json['media'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MediaCollectionRecentlyCompletedGraphqlDtoPageMedia>(e) as MediaCollectionRecentlyCompletedGraphqlDtoPageMedia).toList();
	if (media != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPage.media = media;
	}
	return mediaCollectionRecentlyCompletedGraphqlDtoPage;
}

Map<String, dynamic> $MediaCollectionRecentlyCompletedGraphqlDtoPageToJson(MediaCollectionRecentlyCompletedGraphqlDtoPage entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['media'] =  entity.media.map((v) => v.toJson()).toList();
	return data;
}

extension MediaCollectionRecentlyCompletedGraphqlDtoPageExtension on MediaCollectionRecentlyCompletedGraphqlDtoPage {
	MediaCollectionRecentlyCompletedGraphqlDtoPage copyWith({
	List<MediaCollectionRecentlyCompletedGraphqlDtoPageMedia>? media,
	}) {
		return MediaCollectionRecentlyCompletedGraphqlDtoPage()
			..media = media ?? this.media;
	}
}


MediaCollectionRecentlyCompletedGraphqlDtoPageMedia $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyCompletedGraphqlDtoPageMedia mediaCollectionRecentlyCompletedGraphqlDtoPageMedia = MediaCollectionRecentlyCompletedGraphqlDtoPageMedia();
	final dynamic nextAiringEpisode = json['nextAiringEpisode'];
	if (nextAiringEpisode != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.nextAiringEpisode = nextAiringEpisode;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.status = status;
	}
	final bool? isFavourite = jsonConvert.convert<bool>(json['isFavourite']);
	if (isFavourite != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.isFavourite = isFavourite;
	}
	final String? season = jsonConvert.convert<String>(json['season']);
	if (season != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.season = season;
	}
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.id = id;
	}
	final int? idMal = jsonConvert.convert<int>(json['idMal']);
	if (idMal != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.idMal = idMal;
	}
	final bool? isAdult = jsonConvert.convert<bool>(json['isAdult']);
	if (isAdult != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.isAdult = isAdult;
	}
	final int? meanScore = jsonConvert.convert<int>(json['meanScore']);
	if (meanScore != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.meanScore = meanScore;
	}
	final int? popularity = jsonConvert.convert<int>(json['popularity']);
	if (popularity != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.popularity = popularity;
	}
	final List<String>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (genres != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.genres = genres;
	}
	final String? format = jsonConvert.convert<String>(json['format']);
	if (format != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.format = format;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.episodes = episodes;
	}
	final MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate? endDate = jsonConvert.convert<MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate>(json['endDate']);
	if (endDate != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.endDate = endDate;
	}
	final MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate? startDate = jsonConvert.convert<MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate>(json['startDate']);
	if (startDate != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.startDate = startDate;
	}
	final int? duration = jsonConvert.convert<int>(json['duration']);
	if (duration != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.duration = duration;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.description = description;
	}
	final MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage? coverImage = jsonConvert.convert<MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage>(json['coverImage']);
	if (coverImage != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.coverImage = coverImage;
	}
	final String? countryOfOrigin = jsonConvert.convert<String>(json['countryOfOrigin']);
	if (countryOfOrigin != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.countryOfOrigin = countryOfOrigin;
	}
	final int? chapters = jsonConvert.convert<int>(json['chapters']);
	if (chapters != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.chapters = chapters;
	}
	final String? bannerImage = jsonConvert.convert<String>(json['bannerImage']);
	if (bannerImage != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.bannerImage = bannerImage;
	}
	final int? averageScore = jsonConvert.convert<int>(json['averageScore']);
	if (averageScore != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.averageScore = averageScore;
	}
	final MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle? title = jsonConvert.convert<MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle>(json['title']);
	if (title != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMedia.title = title;
	}
	return mediaCollectionRecentlyCompletedGraphqlDtoPageMedia;
}

Map<String, dynamic> $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaToJson(MediaCollectionRecentlyCompletedGraphqlDtoPageMedia entity) {
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

extension MediaCollectionRecentlyCompletedGraphqlDtoPageMediaExtension on MediaCollectionRecentlyCompletedGraphqlDtoPageMedia {
	MediaCollectionRecentlyCompletedGraphqlDtoPageMedia copyWith({
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
	MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate? endDate,
	MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate? startDate,
	int? duration,
	String? description,
	MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage? coverImage,
	String? countryOfOrigin,
	int? chapters,
	String? bannerImage,
	int? averageScore,
	MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle? title,
	}) {
		return MediaCollectionRecentlyCompletedGraphqlDtoPageMedia()
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


MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDateFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate mediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate = MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate.year = year;
	}
	return mediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate;
}

Map<String, dynamic> $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDateToJson(MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDateExtension on MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate {
	MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaCollectionRecentlyCompletedGraphqlDtoPageMediaEndDate()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDateFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate mediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate = MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate.year = year;
	}
	return mediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate;
}

Map<String, dynamic> $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDateToJson(MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDateExtension on MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate {
	MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaCollectionRecentlyCompletedGraphqlDtoPageMediaStartDate()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImageFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage mediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage = MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage();
	final String? large = jsonConvert.convert<String>(json['large']);
	if (large != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage.large = large;
	}
	return mediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage;
}

Map<String, dynamic> $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImageToJson(MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['large'] = entity.large;
	return data;
}

extension MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImageExtension on MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage {
	MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage copyWith({
	String? large,
	}) {
		return MediaCollectionRecentlyCompletedGraphqlDtoPageMediaCoverImage()
			..large = large ?? this.large;
	}
}


MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitleFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle mediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle = MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle();
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle.english = english;
	}
	final String? native = jsonConvert.convert<String>(json['native']);
	if (native != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle.native = native;
	}
	final String? romaji = jsonConvert.convert<String>(json['romaji']);
	if (romaji != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle.romaji = romaji;
	}
	final String? userPreferred = jsonConvert.convert<String>(json['userPreferred']);
	if (userPreferred != null) {
		mediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle.userPreferred = userPreferred;
	}
	return mediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle;
}

Map<String, dynamic> $MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitleToJson(MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['english'] = entity.english;
	data['native'] = entity.native;
	data['romaji'] = entity.romaji;
	data['userPreferred'] = entity.userPreferred;
	return data;
}

extension MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitleExtension on MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle {
	MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle copyWith({
	String? english,
	String? native,
	String? romaji,
	String? userPreferred,
	}) {
		return MediaCollectionRecentlyCompletedGraphqlDtoPageMediaTitle()
			..english = english ?? this.english
			..native = native ?? this.native
			..romaji = romaji ?? this.romaji
			..userPreferred = userPreferred ?? this.userPreferred;
	}
}

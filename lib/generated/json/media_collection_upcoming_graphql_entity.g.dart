import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/anilist/media_collection_upcoming_graphql_entity.dart';

MediaCollectionUpcomingGraphqlEntity $MediaCollectionUpcomingGraphqlEntityFromJson(Map<String, dynamic> json) {
	final MediaCollectionUpcomingGraphqlEntity mediaCollectionUpcomingGraphqlEntity = MediaCollectionUpcomingGraphqlEntity();
	final MediaCollectionUpcomingGraphqlDtoPage? page = jsonConvert.convert<MediaCollectionUpcomingGraphqlDtoPage>(json['Page']);
	if (page != null) {
		mediaCollectionUpcomingGraphqlEntity.page = page;
	}
	return mediaCollectionUpcomingGraphqlEntity;
}

Map<String, dynamic> $MediaCollectionUpcomingGraphqlEntityToJson(MediaCollectionUpcomingGraphqlEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['Page'] = entity.page.toJson();
	return data;
}

extension MediaCollectionUpcomingGraphqlEntityExtension on MediaCollectionUpcomingGraphqlEntity {
	MediaCollectionUpcomingGraphqlEntity copyWith({
	MediaCollectionUpcomingGraphqlDtoPage? page,
	}) {
		return MediaCollectionUpcomingGraphqlEntity()
			..page = page ?? this.page;
	}
}


MediaCollectionUpcomingGraphqlDtoPage $MediaCollectionUpcomingGraphqlDtoPageFromJson(Map<String, dynamic> json) {
	final MediaCollectionUpcomingGraphqlDtoPage mediaCollectionUpcomingGraphqlDtoPage = MediaCollectionUpcomingGraphqlDtoPage();
	final List<MediaCollectionUpcomingGraphqlDtoPageMedia>? media = (json['media'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MediaCollectionUpcomingGraphqlDtoPageMedia>(e) as MediaCollectionUpcomingGraphqlDtoPageMedia).toList();
	if (media != null) {
		mediaCollectionUpcomingGraphqlDtoPage.media = media;
	}
	return mediaCollectionUpcomingGraphqlDtoPage;
}

Map<String, dynamic> $MediaCollectionUpcomingGraphqlDtoPageToJson(MediaCollectionUpcomingGraphqlDtoPage entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['media'] =  entity.media.map((v) => v.toJson()).toList();
	return data;
}

extension MediaCollectionUpcomingGraphqlDtoPageExtension on MediaCollectionUpcomingGraphqlDtoPage {
	MediaCollectionUpcomingGraphqlDtoPage copyWith({
	List<MediaCollectionUpcomingGraphqlDtoPageMedia>? media,
	}) {
		return MediaCollectionUpcomingGraphqlDtoPage()
			..media = media ?? this.media;
	}
}


MediaCollectionUpcomingGraphqlDtoPageMedia $MediaCollectionUpcomingGraphqlDtoPageMediaFromJson(Map<String, dynamic> json) {
	final MediaCollectionUpcomingGraphqlDtoPageMedia mediaCollectionUpcomingGraphqlDtoPageMedia = MediaCollectionUpcomingGraphqlDtoPageMedia();
	final MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode? nextAiringEpisode = jsonConvert.convert<MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode>(json['nextAiringEpisode']);
	if (nextAiringEpisode != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.nextAiringEpisode = nextAiringEpisode;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.status = status;
	}
	final bool? isFavourite = jsonConvert.convert<bool>(json['isFavourite']);
	if (isFavourite != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.isFavourite = isFavourite;
	}
	final String? season = jsonConvert.convert<String>(json['season']);
	if (season != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.season = season;
	}
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.id = id;
	}
	final int? idMal = jsonConvert.convert<int>(json['idMal']);
	if (idMal != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.idMal = idMal;
	}
	final bool? isAdult = jsonConvert.convert<bool>(json['isAdult']);
	if (isAdult != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.isAdult = isAdult;
	}
	final int? meanScore = jsonConvert.convert<int>(json['meanScore']);
	if (meanScore != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.meanScore = meanScore;
	}
	final int? popularity = jsonConvert.convert<int>(json['popularity']);
	if (popularity != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.popularity = popularity;
	}
	final List<String>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (genres != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.genres = genres;
	}
	final String? format = jsonConvert.convert<String>(json['format']);
	if (format != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.format = format;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.episodes = episodes;
	}
	final MediaCollectionUpcomingGraphqlDtoPageMediaEndDate? endDate = jsonConvert.convert<MediaCollectionUpcomingGraphqlDtoPageMediaEndDate>(json['endDate']);
	if (endDate != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.endDate = endDate;
	}
	final MediaCollectionUpcomingGraphqlDtoPageMediaStartDate? startDate = jsonConvert.convert<MediaCollectionUpcomingGraphqlDtoPageMediaStartDate>(json['startDate']);
	if (startDate != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.startDate = startDate;
	}
	final int? duration = jsonConvert.convert<int>(json['duration']);
	if (duration != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.duration = duration;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.description = description;
	}
	final MediaCollectionUpcomingGraphqlDtoPageMediaCoverImage? coverImage = jsonConvert.convert<MediaCollectionUpcomingGraphqlDtoPageMediaCoverImage>(json['coverImage']);
	if (coverImage != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.coverImage = coverImage;
	}
	final String? countryOfOrigin = jsonConvert.convert<String>(json['countryOfOrigin']);
	if (countryOfOrigin != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.countryOfOrigin = countryOfOrigin;
	}
	final int? chapters = jsonConvert.convert<int>(json['chapters']);
	if (chapters != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.chapters = chapters;
	}
	final String? bannerImage = jsonConvert.convert<String>(json['bannerImage']);
	if (bannerImage != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.bannerImage = bannerImage;
	}
	final int? averageScore = jsonConvert.convert<int>(json['averageScore']);
	if (averageScore != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.averageScore = averageScore;
	}
	final MediaCollectionUpcomingGraphqlDtoPageMediaTitle? title = jsonConvert.convert<MediaCollectionUpcomingGraphqlDtoPageMediaTitle>(json['title']);
	if (title != null) {
		mediaCollectionUpcomingGraphqlDtoPageMedia.title = title;
	}
	return mediaCollectionUpcomingGraphqlDtoPageMedia;
}

Map<String, dynamic> $MediaCollectionUpcomingGraphqlDtoPageMediaToJson(MediaCollectionUpcomingGraphqlDtoPageMedia entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['nextAiringEpisode'] = entity.nextAiringEpisode.toJson();
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

extension MediaCollectionUpcomingGraphqlDtoPageMediaExtension on MediaCollectionUpcomingGraphqlDtoPageMedia {
	MediaCollectionUpcomingGraphqlDtoPageMedia copyWith({
	MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode? nextAiringEpisode,
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
	MediaCollectionUpcomingGraphqlDtoPageMediaEndDate? endDate,
	MediaCollectionUpcomingGraphqlDtoPageMediaStartDate? startDate,
	int? duration,
	String? description,
	MediaCollectionUpcomingGraphqlDtoPageMediaCoverImage? coverImage,
	String? countryOfOrigin,
	int? chapters,
	String? bannerImage,
	int? averageScore,
	MediaCollectionUpcomingGraphqlDtoPageMediaTitle? title,
	}) {
		return MediaCollectionUpcomingGraphqlDtoPageMedia()
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


MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode $MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisodeFromJson(Map<String, dynamic> json) {
	final MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode mediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode = MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode();
	final int? episode = jsonConvert.convert<int>(json['episode']);
	if (episode != null) {
		mediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode.episode = episode;
	}
	final int? airingAt = jsonConvert.convert<int>(json['airingAt']);
	if (airingAt != null) {
		mediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode.airingAt = airingAt;
	}
	return mediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode;
}

Map<String, dynamic> $MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisodeToJson(MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['episode'] = entity.episode;
	data['airingAt'] = entity.airingAt;
	return data;
}

extension MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisodeExtension on MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode {
	MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode copyWith({
	int? episode,
	int? airingAt,
	}) {
		return MediaCollectionUpcomingGraphqlDtoPageMediaNextAiringEpisode()
			..episode = episode ?? this.episode
			..airingAt = airingAt ?? this.airingAt;
	}
}


MediaCollectionUpcomingGraphqlDtoPageMediaEndDate $MediaCollectionUpcomingGraphqlDtoPageMediaEndDateFromJson(Map<String, dynamic> json) {
	final MediaCollectionUpcomingGraphqlDtoPageMediaEndDate mediaCollectionUpcomingGraphqlDtoPageMediaEndDate = MediaCollectionUpcomingGraphqlDtoPageMediaEndDate();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaCollectionUpcomingGraphqlDtoPageMediaEndDate.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaCollectionUpcomingGraphqlDtoPageMediaEndDate.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaCollectionUpcomingGraphqlDtoPageMediaEndDate.year = year;
	}
	return mediaCollectionUpcomingGraphqlDtoPageMediaEndDate;
}

Map<String, dynamic> $MediaCollectionUpcomingGraphqlDtoPageMediaEndDateToJson(MediaCollectionUpcomingGraphqlDtoPageMediaEndDate entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaCollectionUpcomingGraphqlDtoPageMediaEndDateExtension on MediaCollectionUpcomingGraphqlDtoPageMediaEndDate {
	MediaCollectionUpcomingGraphqlDtoPageMediaEndDate copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaCollectionUpcomingGraphqlDtoPageMediaEndDate()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaCollectionUpcomingGraphqlDtoPageMediaStartDate $MediaCollectionUpcomingGraphqlDtoPageMediaStartDateFromJson(Map<String, dynamic> json) {
	final MediaCollectionUpcomingGraphqlDtoPageMediaStartDate mediaCollectionUpcomingGraphqlDtoPageMediaStartDate = MediaCollectionUpcomingGraphqlDtoPageMediaStartDate();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaCollectionUpcomingGraphqlDtoPageMediaStartDate.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaCollectionUpcomingGraphqlDtoPageMediaStartDate.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaCollectionUpcomingGraphqlDtoPageMediaStartDate.year = year;
	}
	return mediaCollectionUpcomingGraphqlDtoPageMediaStartDate;
}

Map<String, dynamic> $MediaCollectionUpcomingGraphqlDtoPageMediaStartDateToJson(MediaCollectionUpcomingGraphqlDtoPageMediaStartDate entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaCollectionUpcomingGraphqlDtoPageMediaStartDateExtension on MediaCollectionUpcomingGraphqlDtoPageMediaStartDate {
	MediaCollectionUpcomingGraphqlDtoPageMediaStartDate copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaCollectionUpcomingGraphqlDtoPageMediaStartDate()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaCollectionUpcomingGraphqlDtoPageMediaCoverImage $MediaCollectionUpcomingGraphqlDtoPageMediaCoverImageFromJson(Map<String, dynamic> json) {
	final MediaCollectionUpcomingGraphqlDtoPageMediaCoverImage mediaCollectionUpcomingGraphqlDtoPageMediaCoverImage = MediaCollectionUpcomingGraphqlDtoPageMediaCoverImage();
	final String? large = jsonConvert.convert<String>(json['large']);
	if (large != null) {
		mediaCollectionUpcomingGraphqlDtoPageMediaCoverImage.large = large;
	}
	return mediaCollectionUpcomingGraphqlDtoPageMediaCoverImage;
}

Map<String, dynamic> $MediaCollectionUpcomingGraphqlDtoPageMediaCoverImageToJson(MediaCollectionUpcomingGraphqlDtoPageMediaCoverImage entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['large'] = entity.large;
	return data;
}

extension MediaCollectionUpcomingGraphqlDtoPageMediaCoverImageExtension on MediaCollectionUpcomingGraphqlDtoPageMediaCoverImage {
	MediaCollectionUpcomingGraphqlDtoPageMediaCoverImage copyWith({
	String? large,
	}) {
		return MediaCollectionUpcomingGraphqlDtoPageMediaCoverImage()
			..large = large ?? this.large;
	}
}


MediaCollectionUpcomingGraphqlDtoPageMediaTitle $MediaCollectionUpcomingGraphqlDtoPageMediaTitleFromJson(Map<String, dynamic> json) {
	final MediaCollectionUpcomingGraphqlDtoPageMediaTitle mediaCollectionUpcomingGraphqlDtoPageMediaTitle = MediaCollectionUpcomingGraphqlDtoPageMediaTitle();
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		mediaCollectionUpcomingGraphqlDtoPageMediaTitle.english = english;
	}
	final String? native = jsonConvert.convert<String>(json['native']);
	if (native != null) {
		mediaCollectionUpcomingGraphqlDtoPageMediaTitle.native = native;
	}
	final String? romaji = jsonConvert.convert<String>(json['romaji']);
	if (romaji != null) {
		mediaCollectionUpcomingGraphqlDtoPageMediaTitle.romaji = romaji;
	}
	final String? userPreferred = jsonConvert.convert<String>(json['userPreferred']);
	if (userPreferred != null) {
		mediaCollectionUpcomingGraphqlDtoPageMediaTitle.userPreferred = userPreferred;
	}
	return mediaCollectionUpcomingGraphqlDtoPageMediaTitle;
}

Map<String, dynamic> $MediaCollectionUpcomingGraphqlDtoPageMediaTitleToJson(MediaCollectionUpcomingGraphqlDtoPageMediaTitle entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['english'] = entity.english;
	data['native'] = entity.native;
	data['romaji'] = entity.romaji;
	data['userPreferred'] = entity.userPreferred;
	return data;
}

extension MediaCollectionUpcomingGraphqlDtoPageMediaTitleExtension on MediaCollectionUpcomingGraphqlDtoPageMediaTitle {
	MediaCollectionUpcomingGraphqlDtoPageMediaTitle copyWith({
	String? english,
	String? native,
	String? romaji,
	String? userPreferred,
	}) {
		return MediaCollectionUpcomingGraphqlDtoPageMediaTitle()
			..english = english ?? this.english
			..native = native ?? this.native
			..romaji = romaji ?? this.romaji
			..userPreferred = userPreferred ?? this.userPreferred;
	}
}

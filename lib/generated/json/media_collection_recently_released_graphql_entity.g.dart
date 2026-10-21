import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/anilist/media_collection_recently_released_graphql_entity.dart';

MediaCollectionRecentlyReleasedGraphqlEntity $MediaCollectionRecentlyReleasedGraphqlEntityFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyReleasedGraphqlEntity mediaCollectionRecentlyReleasedGraphqlEntity = MediaCollectionRecentlyReleasedGraphqlEntity();
	final MediaCollectionRecentlyReleasedGraphqlDtoPage? page = jsonConvert.convert<MediaCollectionRecentlyReleasedGraphqlDtoPage>(json['Page']);
	if (page != null) {
		mediaCollectionRecentlyReleasedGraphqlEntity.page = page;
	}
	return mediaCollectionRecentlyReleasedGraphqlEntity;
}

Map<String, dynamic> $MediaCollectionRecentlyReleasedGraphqlEntityToJson(MediaCollectionRecentlyReleasedGraphqlEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['Page'] = entity.page.toJson();
	return data;
}

extension MediaCollectionRecentlyReleasedGraphqlEntityExtension on MediaCollectionRecentlyReleasedGraphqlEntity {
	MediaCollectionRecentlyReleasedGraphqlEntity copyWith({
	MediaCollectionRecentlyReleasedGraphqlDtoPage? page,
	}) {
		return MediaCollectionRecentlyReleasedGraphqlEntity()
			..page = page ?? this.page;
	}
}


MediaCollectionRecentlyReleasedGraphqlDtoPage $MediaCollectionRecentlyReleasedGraphqlDtoPageFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyReleasedGraphqlDtoPage mediaCollectionRecentlyReleasedGraphqlDtoPage = MediaCollectionRecentlyReleasedGraphqlDtoPage();
	final List<MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules>? airingSchedules = (json['airingSchedules'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules>(e) as MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules).toList();
	if (airingSchedules != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPage.airingSchedules = airingSchedules;
	}
	return mediaCollectionRecentlyReleasedGraphqlDtoPage;
}

Map<String, dynamic> $MediaCollectionRecentlyReleasedGraphqlDtoPageToJson(MediaCollectionRecentlyReleasedGraphqlDtoPage entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['airingSchedules'] =  entity.airingSchedules.map((v) => v.toJson()).toList();
	return data;
}

extension MediaCollectionRecentlyReleasedGraphqlDtoPageExtension on MediaCollectionRecentlyReleasedGraphqlDtoPage {
	MediaCollectionRecentlyReleasedGraphqlDtoPage copyWith({
	List<MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules>? airingSchedules,
	}) {
		return MediaCollectionRecentlyReleasedGraphqlDtoPage()
			..airingSchedules = airingSchedules ?? this.airingSchedules;
	}
}


MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules = MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules();
	final MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia? media = jsonConvert.convert<MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia>(json['media']);
	if (media != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules.media = media;
	}
	return mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules;
}

Map<String, dynamic> $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesToJson(MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['media'] = entity.media.toJson();
	return data;
}

extension MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesExtension on MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules {
	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules copyWith({
	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia? media,
	}) {
		return MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedules()
			..media = media ?? this.media;
	}
}


MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia = MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia();
	final MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode? nextAiringEpisode = jsonConvert.convert<MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode>(json['nextAiringEpisode']);
	if (nextAiringEpisode != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.nextAiringEpisode = nextAiringEpisode;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.status = status;
	}
	final bool? isFavourite = jsonConvert.convert<bool>(json['isFavourite']);
	if (isFavourite != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.isFavourite = isFavourite;
	}
	final String? season = jsonConvert.convert<String>(json['season']);
	if (season != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.season = season;
	}
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.id = id;
	}
	final int? idMal = jsonConvert.convert<int>(json['idMal']);
	if (idMal != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.idMal = idMal;
	}
	final bool? isAdult = jsonConvert.convert<bool>(json['isAdult']);
	if (isAdult != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.isAdult = isAdult;
	}
	final int? meanScore = jsonConvert.convert<int>(json['meanScore']);
	if (meanScore != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.meanScore = meanScore;
	}
	final int? popularity = jsonConvert.convert<int>(json['popularity']);
	if (popularity != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.popularity = popularity;
	}
	final List<String>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (genres != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.genres = genres;
	}
	final String? format = jsonConvert.convert<String>(json['format']);
	if (format != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.format = format;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.episodes = episodes;
	}
	final MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate? endDate = jsonConvert.convert<MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate>(json['endDate']);
	if (endDate != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.endDate = endDate;
	}
	final MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate? startDate = jsonConvert.convert<MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate>(json['startDate']);
	if (startDate != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.startDate = startDate;
	}
	final int? duration = jsonConvert.convert<int>(json['duration']);
	if (duration != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.duration = duration;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.description = description;
	}
	final MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage? coverImage = jsonConvert.convert<MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage>(json['coverImage']);
	if (coverImage != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.coverImage = coverImage;
	}
	final String? countryOfOrigin = jsonConvert.convert<String>(json['countryOfOrigin']);
	if (countryOfOrigin != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.countryOfOrigin = countryOfOrigin;
	}
	final int? chapters = jsonConvert.convert<int>(json['chapters']);
	if (chapters != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.chapters = chapters;
	}
	final String? bannerImage = jsonConvert.convert<String>(json['bannerImage']);
	if (bannerImage != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.bannerImage = bannerImage;
	}
	final int? averageScore = jsonConvert.convert<int>(json['averageScore']);
	if (averageScore != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.averageScore = averageScore;
	}
	final MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle? title = jsonConvert.convert<MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle>(json['title']);
	if (title != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia.title = title;
	}
	return mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia;
}

Map<String, dynamic> $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaToJson(MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia entity) {
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

extension MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaExtension on MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia {
	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia copyWith({
	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode? nextAiringEpisode,
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
	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate? endDate,
	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate? startDate,
	int? duration,
	String? description,
	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage? coverImage,
	String? countryOfOrigin,
	int? chapters,
	String? bannerImage,
	int? averageScore,
	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle? title,
	}) {
		return MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMedia()
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


MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisodeFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode = MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode();
	final int? episode = jsonConvert.convert<int>(json['episode']);
	if (episode != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode.episode = episode;
	}
	final int? airingAt = jsonConvert.convert<int>(json['airingAt']);
	if (airingAt != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode.airingAt = airingAt;
	}
	return mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode;
}

Map<String, dynamic> $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisodeToJson(MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['episode'] = entity.episode;
	data['airingAt'] = entity.airingAt;
	return data;
}

extension MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisodeExtension on MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode {
	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode copyWith({
	int? episode,
	int? airingAt,
	}) {
		return MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaNextAiringEpisode()
			..episode = episode ?? this.episode
			..airingAt = airingAt ?? this.airingAt;
	}
}


MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDateFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate = MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate.year = year;
	}
	return mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate;
}

Map<String, dynamic> $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDateToJson(MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDateExtension on MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate {
	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaEndDate()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDateFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate = MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate.year = year;
	}
	return mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate;
}

Map<String, dynamic> $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDateToJson(MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDateExtension on MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate {
	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaStartDate()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImageFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage = MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage();
	final String? large = jsonConvert.convert<String>(json['large']);
	if (large != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage.large = large;
	}
	return mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage;
}

Map<String, dynamic> $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImageToJson(MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['large'] = entity.large;
	return data;
}

extension MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImageExtension on MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage {
	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage copyWith({
	String? large,
	}) {
		return MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaCoverImage()
			..large = large ?? this.large;
	}
}


MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitleFromJson(Map<String, dynamic> json) {
	final MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle = MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle();
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle.english = english;
	}
	final String? native = jsonConvert.convert<String>(json['native']);
	if (native != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle.native = native;
	}
	final String? romaji = jsonConvert.convert<String>(json['romaji']);
	if (romaji != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle.romaji = romaji;
	}
	final String? userPreferred = jsonConvert.convert<String>(json['userPreferred']);
	if (userPreferred != null) {
		mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle.userPreferred = userPreferred;
	}
	return mediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle;
}

Map<String, dynamic> $MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitleToJson(MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['english'] = entity.english;
	data['native'] = entity.native;
	data['romaji'] = entity.romaji;
	data['userPreferred'] = entity.userPreferred;
	return data;
}

extension MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitleExtension on MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle {
	MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle copyWith({
	String? english,
	String? native,
	String? romaji,
	String? userPreferred,
	}) {
		return MediaCollectionRecentlyReleasedGraphqlDtoPageAiringSchedulesMediaTitle()
			..english = english ?? this.english
			..native = native ?? this.native
			..romaji = romaji ?? this.romaji
			..userPreferred = userPreferred ?? this.userPreferred;
	}
}

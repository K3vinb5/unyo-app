import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/anilist/media_advanced_search_query_graphql_entity.dart';

MediaAdvancedSearchQueryGraphqlEntity $MediaAdvancedSearchQueryGraphqlEntityFromJson(Map<String, dynamic> json) {
	final MediaAdvancedSearchQueryGraphqlEntity mediaAdvancedSearchQueryGraphqlEntity = MediaAdvancedSearchQueryGraphqlEntity();
	final MediaAdvancedSearchQueryGraphqlPage? page = jsonConvert.convert<MediaAdvancedSearchQueryGraphqlPage>(json['Page']);
	if (page != null) {
		mediaAdvancedSearchQueryGraphqlEntity.page = page;
	}
	return mediaAdvancedSearchQueryGraphqlEntity;
}

Map<String, dynamic> $MediaAdvancedSearchQueryGraphqlEntityToJson(MediaAdvancedSearchQueryGraphqlEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['Page'] = entity.page.toJson();
	return data;
}

extension MediaAdvancedSearchQueryGraphqlEntityExtension on MediaAdvancedSearchQueryGraphqlEntity {
	MediaAdvancedSearchQueryGraphqlEntity copyWith({
	MediaAdvancedSearchQueryGraphqlPage? page,
	}) {
		return MediaAdvancedSearchQueryGraphqlEntity()
			..page = page ?? this.page;
	}
}


MediaAdvancedSearchQueryGraphqlPage $MediaAdvancedSearchQueryGraphqlPageFromJson(Map<String, dynamic> json) {
	final MediaAdvancedSearchQueryGraphqlPage mediaAdvancedSearchQueryGraphqlPage = MediaAdvancedSearchQueryGraphqlPage();
	final List<MediaAdvancedSearchQueryGraphqlPageMedia>? media = (json['media'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MediaAdvancedSearchQueryGraphqlPageMedia>(e) as MediaAdvancedSearchQueryGraphqlPageMedia).toList();
	if (media != null) {
		mediaAdvancedSearchQueryGraphqlPage.media = media;
	}
	return mediaAdvancedSearchQueryGraphqlPage;
}

Map<String, dynamic> $MediaAdvancedSearchQueryGraphqlPageToJson(MediaAdvancedSearchQueryGraphqlPage entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['media'] =  entity.media.map((v) => v.toJson()).toList();
	return data;
}

extension MediaAdvancedSearchQueryGraphqlPageExtension on MediaAdvancedSearchQueryGraphqlPage {
	MediaAdvancedSearchQueryGraphqlPage copyWith({
	List<MediaAdvancedSearchQueryGraphqlPageMedia>? media,
	}) {
		return MediaAdvancedSearchQueryGraphqlPage()
			..media = media ?? this.media;
	}
}


MediaAdvancedSearchQueryGraphqlPageMedia $MediaAdvancedSearchQueryGraphqlPageMediaFromJson(Map<String, dynamic> json) {
	final MediaAdvancedSearchQueryGraphqlPageMedia mediaAdvancedSearchQueryGraphqlPageMedia = MediaAdvancedSearchQueryGraphqlPageMedia();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.id = id;
	}
	final int? idMal = jsonConvert.convert<int>(json['idMal']);
	if (idMal != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.idMal = idMal;
	}
	final MediaAdvancedSearchQueryGraphqlPageMediaTitle? title = jsonConvert.convert<MediaAdvancedSearchQueryGraphqlPageMediaTitle>(json['title']);
	if (title != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.title = title;
	}
	final int? averageScore = jsonConvert.convert<int>(json['averageScore']);
	if (averageScore != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.averageScore = averageScore;
	}
	final String? bannerImage = jsonConvert.convert<String>(json['bannerImage']);
	if (bannerImage != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.bannerImage = bannerImage;
	}
	final int? chapters = jsonConvert.convert<int>(json['chapters']);
	if (chapters != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.chapters = chapters;
	}
	final String? countryOfOrigin = jsonConvert.convert<String>(json['countryOfOrigin']);
	if (countryOfOrigin != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.countryOfOrigin = countryOfOrigin;
	}
	final MediaAdvancedSearchQueryGraphqlPageMediaCoverImage? coverImage = jsonConvert.convert<MediaAdvancedSearchQueryGraphqlPageMediaCoverImage>(json['coverImage']);
	if (coverImage != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.coverImage = coverImage;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.description = description;
	}
	final int? duration = jsonConvert.convert<int>(json['duration']);
	if (duration != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.duration = duration;
	}
	final MediaAdvancedSearchQueryGraphqlPageMediaEndDate? endDate = jsonConvert.convert<MediaAdvancedSearchQueryGraphqlPageMediaEndDate>(json['endDate']);
	if (endDate != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.endDate = endDate;
	}
	final MediaAdvancedSearchQueryGraphqlPageMediaStartDate? startDate = jsonConvert.convert<MediaAdvancedSearchQueryGraphqlPageMediaStartDate>(json['startDate']);
	if (startDate != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.startDate = startDate;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.episodes = episodes;
	}
	final List<String>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (genres != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.genres = genres;
	}
	final String? format = jsonConvert.convert<String>(json['format']);
	if (format != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.format = format;
	}
	final bool? isAdult = jsonConvert.convert<bool>(json['isAdult']);
	if (isAdult != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.isAdult = isAdult;
	}
	final int? popularity = jsonConvert.convert<int>(json['popularity']);
	if (popularity != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.popularity = popularity;
	}
	final int? meanScore = jsonConvert.convert<int>(json['meanScore']);
	if (meanScore != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.meanScore = meanScore;
	}
	final String? season = jsonConvert.convert<String>(json['season']);
	if (season != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.season = season;
	}
	final bool? isFavourite = jsonConvert.convert<bool>(json['isFavourite']);
	if (isFavourite != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.isFavourite = isFavourite;
	}
	final MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode? nextAiringEpisode = jsonConvert.convert<MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode>(json['nextAiringEpisode']);
	if (nextAiringEpisode != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.nextAiringEpisode = nextAiringEpisode;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		mediaAdvancedSearchQueryGraphqlPageMedia.status = status;
	}
	return mediaAdvancedSearchQueryGraphqlPageMedia;
}

Map<String, dynamic> $MediaAdvancedSearchQueryGraphqlPageMediaToJson(MediaAdvancedSearchQueryGraphqlPageMedia entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['idMal'] = entity.idMal;
	data['title'] = entity.title.toJson();
	data['averageScore'] = entity.averageScore;
	data['bannerImage'] = entity.bannerImage;
	data['chapters'] = entity.chapters;
	data['countryOfOrigin'] = entity.countryOfOrigin;
	data['coverImage'] = entity.coverImage.toJson();
	data['description'] = entity.description;
	data['duration'] = entity.duration;
	data['endDate'] = entity.endDate.toJson();
	data['startDate'] = entity.startDate.toJson();
	data['episodes'] = entity.episodes;
	data['genres'] =  entity.genres;
	data['format'] = entity.format;
	data['isAdult'] = entity.isAdult;
	data['popularity'] = entity.popularity;
	data['meanScore'] = entity.meanScore;
	data['season'] = entity.season;
	data['isFavourite'] = entity.isFavourite;
	data['nextAiringEpisode'] = entity.nextAiringEpisode.toJson();
	data['status'] = entity.status;
	return data;
}

extension MediaAdvancedSearchQueryGraphqlPageMediaExtension on MediaAdvancedSearchQueryGraphqlPageMedia {
	MediaAdvancedSearchQueryGraphqlPageMedia copyWith({
	int? id,
	int? idMal,
	MediaAdvancedSearchQueryGraphqlPageMediaTitle? title,
	int? averageScore,
	String? bannerImage,
	int? chapters,
	String? countryOfOrigin,
	MediaAdvancedSearchQueryGraphqlPageMediaCoverImage? coverImage,
	String? description,
	int? duration,
	MediaAdvancedSearchQueryGraphqlPageMediaEndDate? endDate,
	MediaAdvancedSearchQueryGraphqlPageMediaStartDate? startDate,
	int? episodes,
	List<String>? genres,
	String? format,
	bool? isAdult,
	int? popularity,
	int? meanScore,
	String? season,
	bool? isFavourite,
	MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode? nextAiringEpisode,
	String? status,
	}) {
		return MediaAdvancedSearchQueryGraphqlPageMedia()
			..id = id ?? this.id
			..idMal = idMal ?? this.idMal
			..title = title ?? this.title
			..averageScore = averageScore ?? this.averageScore
			..bannerImage = bannerImage ?? this.bannerImage
			..chapters = chapters ?? this.chapters
			..countryOfOrigin = countryOfOrigin ?? this.countryOfOrigin
			..coverImage = coverImage ?? this.coverImage
			..description = description ?? this.description
			..duration = duration ?? this.duration
			..endDate = endDate ?? this.endDate
			..startDate = startDate ?? this.startDate
			..episodes = episodes ?? this.episodes
			..genres = genres ?? this.genres
			..format = format ?? this.format
			..isAdult = isAdult ?? this.isAdult
			..popularity = popularity ?? this.popularity
			..meanScore = meanScore ?? this.meanScore
			..season = season ?? this.season
			..isFavourite = isFavourite ?? this.isFavourite
			..nextAiringEpisode = nextAiringEpisode ?? this.nextAiringEpisode
			..status = status ?? this.status;
	}
}


MediaAdvancedSearchQueryGraphqlPageMediaTitle $MediaAdvancedSearchQueryGraphqlPageMediaTitleFromJson(Map<String, dynamic> json) {
	final MediaAdvancedSearchQueryGraphqlPageMediaTitle mediaAdvancedSearchQueryGraphqlPageMediaTitle = MediaAdvancedSearchQueryGraphqlPageMediaTitle();
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		mediaAdvancedSearchQueryGraphqlPageMediaTitle.english = english;
	}
	final String? native = jsonConvert.convert<String>(json['native']);
	if (native != null) {
		mediaAdvancedSearchQueryGraphqlPageMediaTitle.native = native;
	}
	final String? romaji = jsonConvert.convert<String>(json['romaji']);
	if (romaji != null) {
		mediaAdvancedSearchQueryGraphqlPageMediaTitle.romaji = romaji;
	}
	final String? userPreferred = jsonConvert.convert<String>(json['userPreferred']);
	if (userPreferred != null) {
		mediaAdvancedSearchQueryGraphqlPageMediaTitle.userPreferred = userPreferred;
	}
	return mediaAdvancedSearchQueryGraphqlPageMediaTitle;
}

Map<String, dynamic> $MediaAdvancedSearchQueryGraphqlPageMediaTitleToJson(MediaAdvancedSearchQueryGraphqlPageMediaTitle entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['english'] = entity.english;
	data['native'] = entity.native;
	data['romaji'] = entity.romaji;
	data['userPreferred'] = entity.userPreferred;
	return data;
}

extension MediaAdvancedSearchQueryGraphqlPageMediaTitleExtension on MediaAdvancedSearchQueryGraphqlPageMediaTitle {
	MediaAdvancedSearchQueryGraphqlPageMediaTitle copyWith({
	String? english,
	String? native,
	String? romaji,
	String? userPreferred,
	}) {
		return MediaAdvancedSearchQueryGraphqlPageMediaTitle()
			..english = english ?? this.english
			..native = native ?? this.native
			..romaji = romaji ?? this.romaji
			..userPreferred = userPreferred ?? this.userPreferred;
	}
}


MediaAdvancedSearchQueryGraphqlPageMediaCoverImage $MediaAdvancedSearchQueryGraphqlPageMediaCoverImageFromJson(Map<String, dynamic> json) {
	final MediaAdvancedSearchQueryGraphqlPageMediaCoverImage mediaAdvancedSearchQueryGraphqlPageMediaCoverImage = MediaAdvancedSearchQueryGraphqlPageMediaCoverImage();
	final String? large = jsonConvert.convert<String>(json['large']);
	if (large != null) {
		mediaAdvancedSearchQueryGraphqlPageMediaCoverImage.large = large;
	}
	return mediaAdvancedSearchQueryGraphqlPageMediaCoverImage;
}

Map<String, dynamic> $MediaAdvancedSearchQueryGraphqlPageMediaCoverImageToJson(MediaAdvancedSearchQueryGraphqlPageMediaCoverImage entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['large'] = entity.large;
	return data;
}

extension MediaAdvancedSearchQueryGraphqlPageMediaCoverImageExtension on MediaAdvancedSearchQueryGraphqlPageMediaCoverImage {
	MediaAdvancedSearchQueryGraphqlPageMediaCoverImage copyWith({
	String? large,
	}) {
		return MediaAdvancedSearchQueryGraphqlPageMediaCoverImage()
			..large = large ?? this.large;
	}
}


MediaAdvancedSearchQueryGraphqlPageMediaEndDate $MediaAdvancedSearchQueryGraphqlPageMediaEndDateFromJson(Map<String, dynamic> json) {
	final MediaAdvancedSearchQueryGraphqlPageMediaEndDate mediaAdvancedSearchQueryGraphqlPageMediaEndDate = MediaAdvancedSearchQueryGraphqlPageMediaEndDate();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaAdvancedSearchQueryGraphqlPageMediaEndDate.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaAdvancedSearchQueryGraphqlPageMediaEndDate.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaAdvancedSearchQueryGraphqlPageMediaEndDate.year = year;
	}
	return mediaAdvancedSearchQueryGraphqlPageMediaEndDate;
}

Map<String, dynamic> $MediaAdvancedSearchQueryGraphqlPageMediaEndDateToJson(MediaAdvancedSearchQueryGraphqlPageMediaEndDate entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaAdvancedSearchQueryGraphqlPageMediaEndDateExtension on MediaAdvancedSearchQueryGraphqlPageMediaEndDate {
	MediaAdvancedSearchQueryGraphqlPageMediaEndDate copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaAdvancedSearchQueryGraphqlPageMediaEndDate()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaAdvancedSearchQueryGraphqlPageMediaStartDate $MediaAdvancedSearchQueryGraphqlPageMediaStartDateFromJson(Map<String, dynamic> json) {
	final MediaAdvancedSearchQueryGraphqlPageMediaStartDate mediaAdvancedSearchQueryGraphqlPageMediaStartDate = MediaAdvancedSearchQueryGraphqlPageMediaStartDate();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaAdvancedSearchQueryGraphqlPageMediaStartDate.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaAdvancedSearchQueryGraphqlPageMediaStartDate.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaAdvancedSearchQueryGraphqlPageMediaStartDate.year = year;
	}
	return mediaAdvancedSearchQueryGraphqlPageMediaStartDate;
}

Map<String, dynamic> $MediaAdvancedSearchQueryGraphqlPageMediaStartDateToJson(MediaAdvancedSearchQueryGraphqlPageMediaStartDate entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaAdvancedSearchQueryGraphqlPageMediaStartDateExtension on MediaAdvancedSearchQueryGraphqlPageMediaStartDate {
	MediaAdvancedSearchQueryGraphqlPageMediaStartDate copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaAdvancedSearchQueryGraphqlPageMediaStartDate()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode $MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisodeFromJson(Map<String, dynamic> json) {
	final MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode mediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode = MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode();
	final int? episode = jsonConvert.convert<int>(json['episode']);
	if (episode != null) {
		mediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode.episode = episode;
	}
	final int? airingAt = jsonConvert.convert<int>(json['airingAt']);
	if (airingAt != null) {
		mediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode.airingAt = airingAt;
	}
	return mediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode;
}

Map<String, dynamic> $MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisodeToJson(MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['episode'] = entity.episode;
	data['airingAt'] = entity.airingAt;
	return data;
}

extension MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisodeExtension on MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode {
	MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode copyWith({
	int? episode,
	int? airingAt,
	}) {
		return MediaAdvancedSearchQueryGraphqlPageMediaNextAiringEpisode()
			..episode = episode ?? this.episode
			..airingAt = airingAt ?? this.airingAt;
	}
}

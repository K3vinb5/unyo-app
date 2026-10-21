import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/anilist/media_collection_graphql_entity.dart';

MediaCollectionGraphqlEntity $MediaCollectionGraphqlEntityFromJson(Map<String, dynamic> json) {
	final MediaCollectionGraphqlEntity mediaCollectionGraphqlEntity = MediaCollectionGraphqlEntity();
	final MediaCollectionGraphqlDtoData? data = jsonConvert.convert<MediaCollectionGraphqlDtoData>(json['data']);
	if (data != null) {
		mediaCollectionGraphqlEntity.data = data;
	}
	return mediaCollectionGraphqlEntity;
}

Map<String, dynamic> $MediaCollectionGraphqlEntityToJson(MediaCollectionGraphqlEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['data'] = entity.data.toJson();
	return data;
}

extension MediaCollectionGraphqlEntityExtension on MediaCollectionGraphqlEntity {
	MediaCollectionGraphqlEntity copyWith({
	MediaCollectionGraphqlDtoData? data,
	}) {
		return MediaCollectionGraphqlEntity()
			..data = data ?? this.data;
	}
}


MediaCollectionGraphqlDtoData $MediaCollectionGraphqlDtoDataFromJson(Map<String, dynamic> json) {
	final MediaCollectionGraphqlDtoData mediaCollectionGraphqlDtoData = MediaCollectionGraphqlDtoData();
	final MediaCollectionGraphqlDtoDataMediaListCollection? mediaListCollection = jsonConvert.convert<MediaCollectionGraphqlDtoDataMediaListCollection>(json['MediaListCollection']);
	if (mediaListCollection != null) {
		mediaCollectionGraphqlDtoData.mediaListCollection = mediaListCollection;
	}
	return mediaCollectionGraphqlDtoData;
}

Map<String, dynamic> $MediaCollectionGraphqlDtoDataToJson(MediaCollectionGraphqlDtoData entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['MediaListCollection'] = entity.mediaListCollection.toJson();
	return data;
}

extension MediaCollectionGraphqlDtoDataExtension on MediaCollectionGraphqlDtoData {
	MediaCollectionGraphqlDtoData copyWith({
	MediaCollectionGraphqlDtoDataMediaListCollection? mediaListCollection,
	}) {
		return MediaCollectionGraphqlDtoData()
			..mediaListCollection = mediaListCollection ?? this.mediaListCollection;
	}
}


MediaCollectionGraphqlDtoDataMediaListCollection $MediaCollectionGraphqlDtoDataMediaListCollectionFromJson(Map<String, dynamic> json) {
	final MediaCollectionGraphqlDtoDataMediaListCollection mediaCollectionGraphqlDtoDataMediaListCollection = MediaCollectionGraphqlDtoDataMediaListCollection();
	final List<MediaCollectionGraphqlDtoDataMediaListCollectionLists>? lists = (json['lists'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MediaCollectionGraphqlDtoDataMediaListCollectionLists>(e) as MediaCollectionGraphqlDtoDataMediaListCollectionLists).toList();
	if (lists != null) {
		mediaCollectionGraphqlDtoDataMediaListCollection.lists = lists;
	}
	final bool? hasNextChunk = jsonConvert.convert<bool>(json['hasNextChunk']);
	if (hasNextChunk != null) {
		mediaCollectionGraphqlDtoDataMediaListCollection.hasNextChunk = hasNextChunk;
	}
	return mediaCollectionGraphqlDtoDataMediaListCollection;
}

Map<String, dynamic> $MediaCollectionGraphqlDtoDataMediaListCollectionToJson(MediaCollectionGraphqlDtoDataMediaListCollection entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['lists'] =  entity.lists.map((v) => v.toJson()).toList();
	data['hasNextChunk'] = entity.hasNextChunk;
	return data;
}

extension MediaCollectionGraphqlDtoDataMediaListCollectionExtension on MediaCollectionGraphqlDtoDataMediaListCollection {
	MediaCollectionGraphqlDtoDataMediaListCollection copyWith({
	List<MediaCollectionGraphqlDtoDataMediaListCollectionLists>? lists,
	bool? hasNextChunk,
	}) {
		return MediaCollectionGraphqlDtoDataMediaListCollection()
			..lists = lists ?? this.lists
			..hasNextChunk = hasNextChunk ?? this.hasNextChunk;
	}
}


MediaCollectionGraphqlDtoDataMediaListCollectionLists $MediaCollectionGraphqlDtoDataMediaListCollectionListsFromJson(Map<String, dynamic> json) {
	final MediaCollectionGraphqlDtoDataMediaListCollectionLists mediaCollectionGraphqlDtoDataMediaListCollectionLists = MediaCollectionGraphqlDtoDataMediaListCollectionLists();
	final List<MediaCollectionGraphqlDtoDataMediaListCollectionListsEntries>? entries = (json['entries'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MediaCollectionGraphqlDtoDataMediaListCollectionListsEntries>(e) as MediaCollectionGraphqlDtoDataMediaListCollectionListsEntries).toList();
	if (entries != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionLists.entries = entries;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionLists.name = name;
	}
	final bool? isCustomList = jsonConvert.convert<bool>(json['isCustomList']);
	if (isCustomList != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionLists.isCustomList = isCustomList;
	}
	return mediaCollectionGraphqlDtoDataMediaListCollectionLists;
}

Map<String, dynamic> $MediaCollectionGraphqlDtoDataMediaListCollectionListsToJson(MediaCollectionGraphqlDtoDataMediaListCollectionLists entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['entries'] =  entity.entries.map((v) => v.toJson()).toList();
	data['name'] = entity.name;
	data['isCustomList'] = entity.isCustomList;
	return data;
}

extension MediaCollectionGraphqlDtoDataMediaListCollectionListsExtension on MediaCollectionGraphqlDtoDataMediaListCollectionLists {
	MediaCollectionGraphqlDtoDataMediaListCollectionLists copyWith({
	List<MediaCollectionGraphqlDtoDataMediaListCollectionListsEntries>? entries,
	String? name,
	bool? isCustomList,
	}) {
		return MediaCollectionGraphqlDtoDataMediaListCollectionLists()
			..entries = entries ?? this.entries
			..name = name ?? this.name
			..isCustomList = isCustomList ?? this.isCustomList;
	}
}


MediaCollectionGraphqlDtoDataMediaListCollectionListsEntries $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesFromJson(Map<String, dynamic> json) {
	final MediaCollectionGraphqlDtoDataMediaListCollectionListsEntries mediaCollectionGraphqlDtoDataMediaListCollectionListsEntries = MediaCollectionGraphqlDtoDataMediaListCollectionListsEntries();
	final MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia? media = jsonConvert.convert<MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia>(json['media']);
	if (media != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntries.media = media;
	}
	return mediaCollectionGraphqlDtoDataMediaListCollectionListsEntries;
}

Map<String, dynamic> $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesToJson(MediaCollectionGraphqlDtoDataMediaListCollectionListsEntries entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['media'] = entity.media.toJson();
	return data;
}

extension MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesExtension on MediaCollectionGraphqlDtoDataMediaListCollectionListsEntries {
	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntries copyWith({
	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia? media,
	}) {
		return MediaCollectionGraphqlDtoDataMediaListCollectionListsEntries()
			..media = media ?? this.media;
	}
}


MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaFromJson(Map<String, dynamic> json) {
	final MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia = MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.id = id;
	}
	final int? idMal = jsonConvert.convert<int>(json['idMal']);
	if (idMal != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.idMal = idMal;
	}
	final MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle? title = jsonConvert.convert<MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle>(json['title']);
	if (title != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.title = title;
	}
	final int? averageScore = jsonConvert.convert<int>(json['averageScore']);
	if (averageScore != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.averageScore = averageScore;
	}
	final String? bannerImage = jsonConvert.convert<String>(json['bannerImage']);
	if (bannerImage != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.bannerImage = bannerImage;
	}
	final int? chapters = jsonConvert.convert<int>(json['chapters']);
	if (chapters != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.chapters = chapters;
	}
	final String? countryOfOrigin = jsonConvert.convert<String>(json['countryOfOrigin']);
	if (countryOfOrigin != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.countryOfOrigin = countryOfOrigin;
	}
	final MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage? coverImage = jsonConvert.convert<MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage>(json['coverImage']);
	if (coverImage != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.coverImage = coverImage;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.description = description;
	}
	final int? duration = jsonConvert.convert<int>(json['duration']);
	if (duration != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.duration = duration;
	}
	final MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate? endDate = jsonConvert.convert<MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate>(json['endDate']);
	if (endDate != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.endDate = endDate;
	}
	final MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate? startDate = jsonConvert.convert<MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate>(json['startDate']);
	if (startDate != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.startDate = startDate;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.episodes = episodes;
	}
	final List<String>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (genres != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.genres = genres;
	}
	final String? format = jsonConvert.convert<String>(json['format']);
	if (format != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.format = format;
	}
	final bool? isAdult = jsonConvert.convert<bool>(json['isAdult']);
	if (isAdult != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.isAdult = isAdult;
	}
	final int? popularity = jsonConvert.convert<int>(json['popularity']);
	if (popularity != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.popularity = popularity;
	}
	final int? meanScore = jsonConvert.convert<int>(json['meanScore']);
	if (meanScore != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.meanScore = meanScore;
	}
	final String? season = jsonConvert.convert<String>(json['season']);
	if (season != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.season = season;
	}
	final bool? isFavourite = jsonConvert.convert<bool>(json['isFavourite']);
	if (isFavourite != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.isFavourite = isFavourite;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.status = status;
	}
	final dynamic nextAiringEpisode = json['nextAiringEpisode'];
	if (nextAiringEpisode != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia.nextAiringEpisode = nextAiringEpisode;
	}
	return mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia;
}

Map<String, dynamic> $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaToJson(MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia entity) {
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
	data['status'] = entity.status;
	data['nextAiringEpisode'] = entity.nextAiringEpisode;
	return data;
}

extension MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaExtension on MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia {
	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia copyWith({
	int? id,
	int? idMal,
	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle? title,
	int? averageScore,
	String? bannerImage,
	int? chapters,
	String? countryOfOrigin,
	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage? coverImage,
	String? description,
	int? duration,
	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate? endDate,
	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate? startDate,
	int? episodes,
	List<String>? genres,
	String? format,
	bool? isAdult,
	int? popularity,
	int? meanScore,
	String? season,
	bool? isFavourite,
	String? status,
	dynamic nextAiringEpisode,
	}) {
		return MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia()
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
			..status = status ?? this.status
			..nextAiringEpisode = nextAiringEpisode ?? this.nextAiringEpisode;
	}
}


MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitleFromJson(Map<String, dynamic> json) {
	final MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle = MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle();
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle.english = english;
	}
	final String? userPreferred = jsonConvert.convert<String>(json['userPreferred']);
	if (userPreferred != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle.userPreferred = userPreferred;
	}
	final String? romaji = jsonConvert.convert<String>(json['romaji']);
	if (romaji != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle.romaji = romaji;
	}
	final String? native = jsonConvert.convert<String>(json['native']);
	if (native != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle.native = native;
	}
	return mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle;
}

Map<String, dynamic> $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitleToJson(MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['english'] = entity.english;
	data['userPreferred'] = entity.userPreferred;
	data['romaji'] = entity.romaji;
	data['native'] = entity.native;
	return data;
}

extension MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitleExtension on MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle {
	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle copyWith({
	String? english,
	String? userPreferred,
	String? romaji,
	String? native,
	}) {
		return MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaTitle()
			..english = english ?? this.english
			..userPreferred = userPreferred ?? this.userPreferred
			..romaji = romaji ?? this.romaji
			..native = native ?? this.native;
	}
}


MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImageFromJson(Map<String, dynamic> json) {
	final MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage = MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage();
	final String? large = jsonConvert.convert<String>(json['large']);
	if (large != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage.large = large;
	}
	return mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage;
}

Map<String, dynamic> $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImageToJson(MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['large'] = entity.large;
	return data;
}

extension MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImageExtension on MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage {
	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage copyWith({
	String? large,
	}) {
		return MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaCoverImage()
			..large = large ?? this.large;
	}
}


MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDateFromJson(Map<String, dynamic> json) {
	final MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate = MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate.year = year;
	}
	return mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate;
}

Map<String, dynamic> $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDateToJson(MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDateExtension on MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate {
	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaEndDate()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDateFromJson(Map<String, dynamic> json) {
	final MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate = MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate.year = year;
	}
	return mediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate;
}

Map<String, dynamic> $MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDateToJson(MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDateExtension on MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate {
	MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMediaStartDate()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}

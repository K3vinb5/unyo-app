import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/anilist/media_details_graphql_entity.dart';

MediaDetailsGraphqlEntity $MediaDetailsGraphqlEntityFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlEntity mediaDetailsGraphqlEntity = MediaDetailsGraphqlEntity();
	final MediaDetailsGraphqlMedia? media = jsonConvert.convert<MediaDetailsGraphqlMedia>(json['Media']);
	if (media != null) {
		mediaDetailsGraphqlEntity.media = media;
	}
	return mediaDetailsGraphqlEntity;
}

Map<String, dynamic> $MediaDetailsGraphqlEntityToJson(MediaDetailsGraphqlEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['Media'] = entity.media.toJson();
	return data;
}

extension MediaDetailsGraphqlEntityExtension on MediaDetailsGraphqlEntity {
	MediaDetailsGraphqlEntity copyWith({
	MediaDetailsGraphqlMedia? media,
	}) {
		return MediaDetailsGraphqlEntity()
			..media = media ?? this.media;
	}
}


MediaDetailsGraphqlMedia $MediaDetailsGraphqlMediaFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlMedia mediaDetailsGraphqlMedia = MediaDetailsGraphqlMedia();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		mediaDetailsGraphqlMedia.id = id;
	}
	final MediaDetailsGraphqlMediaTitle? title = jsonConvert.convert<MediaDetailsGraphqlMediaTitle>(json['title']);
	if (title != null) {
		mediaDetailsGraphqlMedia.title = title;
	}
	final MediaDetailsGraphqlMediaRecommendations? recommendations = jsonConvert.convert<MediaDetailsGraphqlMediaRecommendations>(json['recommendations']);
	if (recommendations != null) {
		mediaDetailsGraphqlMedia.recommendations = recommendations;
	}
	final MediaDetailsGraphqlMediaCharacters? characters = jsonConvert.convert<MediaDetailsGraphqlMediaCharacters>(json['characters']);
	if (characters != null) {
		mediaDetailsGraphqlMedia.characters = characters;
	}
	return mediaDetailsGraphqlMedia;
}

Map<String, dynamic> $MediaDetailsGraphqlMediaToJson(MediaDetailsGraphqlMedia entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['title'] = entity.title.toJson();
	data['recommendations'] = entity.recommendations.toJson();
	data['characters'] = entity.characters.toJson();
	return data;
}

extension MediaDetailsGraphqlMediaExtension on MediaDetailsGraphqlMedia {
	MediaDetailsGraphqlMedia copyWith({
	int? id,
	MediaDetailsGraphqlMediaTitle? title,
	MediaDetailsGraphqlMediaRecommendations? recommendations,
	MediaDetailsGraphqlMediaCharacters? characters,
	}) {
		return MediaDetailsGraphqlMedia()
			..id = id ?? this.id
			..title = title ?? this.title
			..recommendations = recommendations ?? this.recommendations
			..characters = characters ?? this.characters;
	}
}


MediaDetailsGraphqlMediaTitle $MediaDetailsGraphqlMediaTitleFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlMediaTitle mediaDetailsGraphqlMediaTitle = MediaDetailsGraphqlMediaTitle();
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		mediaDetailsGraphqlMediaTitle.english = english;
	}
	final String? romaji = jsonConvert.convert<String>(json['romaji']);
	if (romaji != null) {
		mediaDetailsGraphqlMediaTitle.romaji = romaji;
	}
	final String? native = jsonConvert.convert<String>(json['native']);
	if (native != null) {
		mediaDetailsGraphqlMediaTitle.native = native;
	}
	final String? userPreferred = jsonConvert.convert<String>(json['userPreferred']);
	if (userPreferred != null) {
		mediaDetailsGraphqlMediaTitle.userPreferred = userPreferred;
	}
	return mediaDetailsGraphqlMediaTitle;
}

Map<String, dynamic> $MediaDetailsGraphqlMediaTitleToJson(MediaDetailsGraphqlMediaTitle entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['english'] = entity.english;
	data['romaji'] = entity.romaji;
	data['native'] = entity.native;
	data['userPreferred'] = entity.userPreferred;
	return data;
}

extension MediaDetailsGraphqlMediaTitleExtension on MediaDetailsGraphqlMediaTitle {
	MediaDetailsGraphqlMediaTitle copyWith({
	String? english,
	String? romaji,
	String? native,
	String? userPreferred,
	}) {
		return MediaDetailsGraphqlMediaTitle()
			..english = english ?? this.english
			..romaji = romaji ?? this.romaji
			..native = native ?? this.native
			..userPreferred = userPreferred ?? this.userPreferred;
	}
}


MediaDetailsGraphqlMediaRecommendations $MediaDetailsGraphqlMediaRecommendationsFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlMediaRecommendations mediaDetailsGraphqlMediaRecommendations = MediaDetailsGraphqlMediaRecommendations();
	final List<MediaDetailsGraphqlMediaRecommendationsNodes>? nodes = (json['nodes'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MediaDetailsGraphqlMediaRecommendationsNodes>(e) as MediaDetailsGraphqlMediaRecommendationsNodes).toList();
	if (nodes != null) {
		mediaDetailsGraphqlMediaRecommendations.nodes = nodes;
	}
	return mediaDetailsGraphqlMediaRecommendations;
}

Map<String, dynamic> $MediaDetailsGraphqlMediaRecommendationsToJson(MediaDetailsGraphqlMediaRecommendations entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['nodes'] =  entity.nodes.map((v) => v.toJson()).toList();
	return data;
}

extension MediaDetailsGraphqlMediaRecommendationsExtension on MediaDetailsGraphqlMediaRecommendations {
	MediaDetailsGraphqlMediaRecommendations copyWith({
	List<MediaDetailsGraphqlMediaRecommendationsNodes>? nodes,
	}) {
		return MediaDetailsGraphqlMediaRecommendations()
			..nodes = nodes ?? this.nodes;
	}
}


MediaDetailsGraphqlMediaRecommendationsNodes $MediaDetailsGraphqlMediaRecommendationsNodesFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlMediaRecommendationsNodes mediaDetailsGraphqlMediaRecommendationsNodes = MediaDetailsGraphqlMediaRecommendationsNodes();
	final MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation? mediaRecommendation = jsonConvert.convert<MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation>(json['mediaRecommendation']);
	if (mediaRecommendation != null) {
		mediaDetailsGraphqlMediaRecommendationsNodes.mediaRecommendation = mediaRecommendation;
	}
	return mediaDetailsGraphqlMediaRecommendationsNodes;
}

Map<String, dynamic> $MediaDetailsGraphqlMediaRecommendationsNodesToJson(MediaDetailsGraphqlMediaRecommendationsNodes entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['mediaRecommendation'] = entity.mediaRecommendation.toJson();
	return data;
}

extension MediaDetailsGraphqlMediaRecommendationsNodesExtension on MediaDetailsGraphqlMediaRecommendationsNodes {
	MediaDetailsGraphqlMediaRecommendationsNodes copyWith({
	MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation? mediaRecommendation,
	}) {
		return MediaDetailsGraphqlMediaRecommendationsNodes()
			..mediaRecommendation = mediaRecommendation ?? this.mediaRecommendation;
	}
}


MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation = MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.id = id;
	}
	final int? idMal = jsonConvert.convert<int>(json['idMal']);
	if (idMal != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.idMal = idMal;
	}
	final MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate? startDate = jsonConvert.convert<MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate>(json['startDate']);
	if (startDate != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.startDate = startDate;
	}
	final MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate? endDate = jsonConvert.convert<MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate>(json['endDate']);
	if (endDate != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.endDate = endDate;
	}
	final String? season = jsonConvert.convert<String>(json['season']);
	if (season != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.season = season;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.status = status;
	}
	final bool? isFavourite = jsonConvert.convert<bool>(json['isFavourite']);
	if (isFavourite != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.isFavourite = isFavourite;
	}
	final bool? isAdult = jsonConvert.convert<bool>(json['isAdult']);
	if (isAdult != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.isAdult = isAdult;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.episodes = episodes;
	}
	final int? chapters = jsonConvert.convert<int>(json['chapters']);
	if (chapters != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.chapters = chapters;
	}
	final MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle? title = jsonConvert.convert<MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle>(json['title']);
	if (title != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.title = title;
	}
	final String? bannerImage = jsonConvert.convert<String>(json['bannerImage']);
	if (bannerImage != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.bannerImage = bannerImage;
	}
	final MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage? coverImage = jsonConvert.convert<MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage>(json['coverImage']);
	if (coverImage != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.coverImage = coverImage;
	}
	final int? averageScore = jsonConvert.convert<int>(json['averageScore']);
	if (averageScore != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.averageScore = averageScore;
	}
	final int? duration = jsonConvert.convert<int>(json['duration']);
	if (duration != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.duration = duration;
	}
	final String? format = jsonConvert.convert<String>(json['format']);
	if (format != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.format = format;
	}
	final List<String>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (genres != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.genres = genres;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.description = description;
	}
	final int? meanScore = jsonConvert.convert<int>(json['meanScore']);
	if (meanScore != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.meanScore = meanScore;
	}
	final dynamic nextAiringEpisode = json['nextAiringEpisode'];
	if (nextAiringEpisode != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation.nextAiringEpisode = nextAiringEpisode;
	}
	return mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation;
}

Map<String, dynamic> $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationToJson(MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['idMal'] = entity.idMal;
	data['startDate'] = entity.startDate.toJson();
	data['endDate'] = entity.endDate.toJson();
	data['season'] = entity.season;
	data['status'] = entity.status;
	data['isFavourite'] = entity.isFavourite;
	data['isAdult'] = entity.isAdult;
	data['episodes'] = entity.episodes;
	data['chapters'] = entity.chapters;
	data['title'] = entity.title.toJson();
	data['bannerImage'] = entity.bannerImage;
	data['coverImage'] = entity.coverImage.toJson();
	data['averageScore'] = entity.averageScore;
	data['duration'] = entity.duration;
	data['format'] = entity.format;
	data['genres'] =  entity.genres;
	data['description'] = entity.description;
	data['meanScore'] = entity.meanScore;
	data['nextAiringEpisode'] = entity.nextAiringEpisode;
	return data;
}

extension MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationExtension on MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation {
	MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation copyWith({
	int? id,
	int? idMal,
	MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate? startDate,
	MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate? endDate,
	String? season,
	String? status,
	bool? isFavourite,
	bool? isAdult,
	int? episodes,
	int? chapters,
	MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle? title,
	String? bannerImage,
	MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage? coverImage,
	int? averageScore,
	int? duration,
	String? format,
	List<String>? genres,
	String? description,
	int? meanScore,
	dynamic nextAiringEpisode,
	}) {
		return MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendation()
			..id = id ?? this.id
			..idMal = idMal ?? this.idMal
			..startDate = startDate ?? this.startDate
			..endDate = endDate ?? this.endDate
			..season = season ?? this.season
			..status = status ?? this.status
			..isFavourite = isFavourite ?? this.isFavourite
			..isAdult = isAdult ?? this.isAdult
			..episodes = episodes ?? this.episodes
			..chapters = chapters ?? this.chapters
			..title = title ?? this.title
			..bannerImage = bannerImage ?? this.bannerImage
			..coverImage = coverImage ?? this.coverImage
			..averageScore = averageScore ?? this.averageScore
			..duration = duration ?? this.duration
			..format = format ?? this.format
			..genres = genres ?? this.genres
			..description = description ?? this.description
			..meanScore = meanScore ?? this.meanScore
			..nextAiringEpisode = nextAiringEpisode ?? this.nextAiringEpisode;
	}
}


MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDateFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate = MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate.year = year;
	}
	return mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate;
}

Map<String, dynamic> $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDateToJson(MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDateExtension on MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate {
	MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationStartDate()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDateFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate = MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate.year = year;
	}
	return mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate;
}

Map<String, dynamic> $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDateToJson(MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDateExtension on MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate {
	MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationEndDate()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitleFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle = MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle();
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle.english = english;
	}
	final String? native = jsonConvert.convert<String>(json['native']);
	if (native != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle.native = native;
	}
	final String? romaji = jsonConvert.convert<String>(json['romaji']);
	if (romaji != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle.romaji = romaji;
	}
	final String? userPreferred = jsonConvert.convert<String>(json['userPreferred']);
	if (userPreferred != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle.userPreferred = userPreferred;
	}
	return mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle;
}

Map<String, dynamic> $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitleToJson(MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['english'] = entity.english;
	data['native'] = entity.native;
	data['romaji'] = entity.romaji;
	data['userPreferred'] = entity.userPreferred;
	return data;
}

extension MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitleExtension on MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle {
	MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle copyWith({
	String? english,
	String? native,
	String? romaji,
	String? userPreferred,
	}) {
		return MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationTitle()
			..english = english ?? this.english
			..native = native ?? this.native
			..romaji = romaji ?? this.romaji
			..userPreferred = userPreferred ?? this.userPreferred;
	}
}


MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImageFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage = MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage();
	final String? large = jsonConvert.convert<String>(json['large']);
	if (large != null) {
		mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage.large = large;
	}
	return mediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage;
}

Map<String, dynamic> $MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImageToJson(MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['large'] = entity.large;
	return data;
}

extension MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImageExtension on MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage {
	MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage copyWith({
	String? large,
	}) {
		return MediaDetailsGraphqlMediaRecommendationsNodesMediaRecommendationCoverImage()
			..large = large ?? this.large;
	}
}


MediaDetailsGraphqlMediaCharacters $MediaDetailsGraphqlMediaCharactersFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlMediaCharacters mediaDetailsGraphqlMediaCharacters = MediaDetailsGraphqlMediaCharacters();
	final List<MediaDetailsGraphqlMediaCharactersNodes>? nodes = (json['nodes'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MediaDetailsGraphqlMediaCharactersNodes>(e) as MediaDetailsGraphqlMediaCharactersNodes).toList();
	if (nodes != null) {
		mediaDetailsGraphqlMediaCharacters.nodes = nodes;
	}
	return mediaDetailsGraphqlMediaCharacters;
}

Map<String, dynamic> $MediaDetailsGraphqlMediaCharactersToJson(MediaDetailsGraphqlMediaCharacters entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['nodes'] =  entity.nodes.map((v) => v.toJson()).toList();
	return data;
}

extension MediaDetailsGraphqlMediaCharactersExtension on MediaDetailsGraphqlMediaCharacters {
	MediaDetailsGraphqlMediaCharacters copyWith({
	List<MediaDetailsGraphqlMediaCharactersNodes>? nodes,
	}) {
		return MediaDetailsGraphqlMediaCharacters()
			..nodes = nodes ?? this.nodes;
	}
}


MediaDetailsGraphqlMediaCharactersNodes $MediaDetailsGraphqlMediaCharactersNodesFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlMediaCharactersNodes mediaDetailsGraphqlMediaCharactersNodes = MediaDetailsGraphqlMediaCharactersNodes();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		mediaDetailsGraphqlMediaCharactersNodes.id = id;
	}
	final MediaDetailsGraphqlMediaCharactersNodesImage? image = jsonConvert.convert<MediaDetailsGraphqlMediaCharactersNodesImage>(json['image']);
	if (image != null) {
		mediaDetailsGraphqlMediaCharactersNodes.image = image;
	}
	final MediaDetailsGraphqlMediaCharactersNodesName? name = jsonConvert.convert<MediaDetailsGraphqlMediaCharactersNodesName>(json['name']);
	if (name != null) {
		mediaDetailsGraphqlMediaCharactersNodes.name = name;
	}
	final String? gender = jsonConvert.convert<String>(json['gender']);
	if (gender != null) {
		mediaDetailsGraphqlMediaCharactersNodes.gender = gender;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		mediaDetailsGraphqlMediaCharactersNodes.description = description;
	}
	final MediaDetailsGraphqlMediaCharactersNodesDateOfBirth? dateOfBirth = jsonConvert.convert<MediaDetailsGraphqlMediaCharactersNodesDateOfBirth>(json['dateOfBirth']);
	if (dateOfBirth != null) {
		mediaDetailsGraphqlMediaCharactersNodes.dateOfBirth = dateOfBirth;
	}
	final String? age = jsonConvert.convert<String>(json['age']);
	if (age != null) {
		mediaDetailsGraphqlMediaCharactersNodes.age = age;
	}
	return mediaDetailsGraphqlMediaCharactersNodes;
}

Map<String, dynamic> $MediaDetailsGraphqlMediaCharactersNodesToJson(MediaDetailsGraphqlMediaCharactersNodes entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['image'] = entity.image.toJson();
	data['name'] = entity.name.toJson();
	data['gender'] = entity.gender;
	data['description'] = entity.description;
	data['dateOfBirth'] = entity.dateOfBirth.toJson();
	data['age'] = entity.age;
	return data;
}

extension MediaDetailsGraphqlMediaCharactersNodesExtension on MediaDetailsGraphqlMediaCharactersNodes {
	MediaDetailsGraphqlMediaCharactersNodes copyWith({
	int? id,
	MediaDetailsGraphqlMediaCharactersNodesImage? image,
	MediaDetailsGraphqlMediaCharactersNodesName? name,
	String? gender,
	String? description,
	MediaDetailsGraphqlMediaCharactersNodesDateOfBirth? dateOfBirth,
	String? age,
	}) {
		return MediaDetailsGraphqlMediaCharactersNodes()
			..id = id ?? this.id
			..image = image ?? this.image
			..name = name ?? this.name
			..gender = gender ?? this.gender
			..description = description ?? this.description
			..dateOfBirth = dateOfBirth ?? this.dateOfBirth
			..age = age ?? this.age;
	}
}


MediaDetailsGraphqlMediaCharactersNodesImage $MediaDetailsGraphqlMediaCharactersNodesImageFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlMediaCharactersNodesImage mediaDetailsGraphqlMediaCharactersNodesImage = MediaDetailsGraphqlMediaCharactersNodesImage();
	final String? large = jsonConvert.convert<String>(json['large']);
	if (large != null) {
		mediaDetailsGraphqlMediaCharactersNodesImage.large = large;
	}
	return mediaDetailsGraphqlMediaCharactersNodesImage;
}

Map<String, dynamic> $MediaDetailsGraphqlMediaCharactersNodesImageToJson(MediaDetailsGraphqlMediaCharactersNodesImage entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['large'] = entity.large;
	return data;
}

extension MediaDetailsGraphqlMediaCharactersNodesImageExtension on MediaDetailsGraphqlMediaCharactersNodesImage {
	MediaDetailsGraphqlMediaCharactersNodesImage copyWith({
	String? large,
	}) {
		return MediaDetailsGraphqlMediaCharactersNodesImage()
			..large = large ?? this.large;
	}
}


MediaDetailsGraphqlMediaCharactersNodesName $MediaDetailsGraphqlMediaCharactersNodesNameFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlMediaCharactersNodesName mediaDetailsGraphqlMediaCharactersNodesName = MediaDetailsGraphqlMediaCharactersNodesName();
	final String? userPreferred = jsonConvert.convert<String>(json['userPreferred']);
	if (userPreferred != null) {
		mediaDetailsGraphqlMediaCharactersNodesName.userPreferred = userPreferred;
	}
	return mediaDetailsGraphqlMediaCharactersNodesName;
}

Map<String, dynamic> $MediaDetailsGraphqlMediaCharactersNodesNameToJson(MediaDetailsGraphqlMediaCharactersNodesName entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['userPreferred'] = entity.userPreferred;
	return data;
}

extension MediaDetailsGraphqlMediaCharactersNodesNameExtension on MediaDetailsGraphqlMediaCharactersNodesName {
	MediaDetailsGraphqlMediaCharactersNodesName copyWith({
	String? userPreferred,
	}) {
		return MediaDetailsGraphqlMediaCharactersNodesName()
			..userPreferred = userPreferred ?? this.userPreferred;
	}
}


MediaDetailsGraphqlMediaCharactersNodesDateOfBirth $MediaDetailsGraphqlMediaCharactersNodesDateOfBirthFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlMediaCharactersNodesDateOfBirth mediaDetailsGraphqlMediaCharactersNodesDateOfBirth = MediaDetailsGraphqlMediaCharactersNodesDateOfBirth();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaDetailsGraphqlMediaCharactersNodesDateOfBirth.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaDetailsGraphqlMediaCharactersNodesDateOfBirth.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaDetailsGraphqlMediaCharactersNodesDateOfBirth.year = year;
	}
	return mediaDetailsGraphqlMediaCharactersNodesDateOfBirth;
}

Map<String, dynamic> $MediaDetailsGraphqlMediaCharactersNodesDateOfBirthToJson(MediaDetailsGraphqlMediaCharactersNodesDateOfBirth entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaDetailsGraphqlMediaCharactersNodesDateOfBirthExtension on MediaDetailsGraphqlMediaCharactersNodesDateOfBirth {
	MediaDetailsGraphqlMediaCharactersNodesDateOfBirth copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaDetailsGraphqlMediaCharactersNodesDateOfBirth()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaDetailsGraphqlMediaMediaListEntryCustomLists $MediaDetailsGraphqlMediaMediaListEntryCustomListsFromJson(Map<String, dynamic> json) {
	final MediaDetailsGraphqlMediaMediaListEntryCustomLists mediaDetailsGraphqlMediaMediaListEntryCustomLists = MediaDetailsGraphqlMediaMediaListEntryCustomLists();
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		mediaDetailsGraphqlMediaMediaListEntryCustomLists.name = name;
	}
	final bool? enabled = jsonConvert.convert<bool>(json['enabled']);
	if (enabled != null) {
		mediaDetailsGraphqlMediaMediaListEntryCustomLists.enabled = enabled;
	}
	return mediaDetailsGraphqlMediaMediaListEntryCustomLists;
}

Map<String, dynamic> $MediaDetailsGraphqlMediaMediaListEntryCustomListsToJson(MediaDetailsGraphqlMediaMediaListEntryCustomLists entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['name'] = entity.name;
	data['enabled'] = entity.enabled;
	return data;
}

extension MediaDetailsGraphqlMediaMediaListEntryCustomListsExtension on MediaDetailsGraphqlMediaMediaListEntryCustomLists {
	MediaDetailsGraphqlMediaMediaListEntryCustomLists copyWith({
	String? name,
	bool? enabled,
	}) {
		return MediaDetailsGraphqlMediaMediaListEntryCustomLists()
			..name = name ?? this.name
			..enabled = enabled ?? this.enabled;
	}
}

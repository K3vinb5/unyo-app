import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/mal/mal_anime_node.dart';
import 'package:unyo/core/services/api/dto/mal/mal_my_list_status_entity.dart';

MalAnimeNode $MalAnimeNodeFromJson(Map<String, dynamic> json) {
	final MalAnimeNode malAnimeNode = MalAnimeNode();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		malAnimeNode.id = id;
	}
	final String? title = jsonConvert.convert<String>(json['title']);
	if (title != null) {
		malAnimeNode.title = title;
	}
	final MalAnimeNodeMainPicture? mainPicture = jsonConvert.convert<MalAnimeNodeMainPicture>(json['main_picture']);
	if (mainPicture != null) {
		malAnimeNode.mainPicture = mainPicture;
	}
	final MalAnimeNodeAlternativeTitles? alternativeTitles = jsonConvert.convert<MalAnimeNodeAlternativeTitles>(json['alternative_titles']);
	if (alternativeTitles != null) {
		malAnimeNode.alternativeTitles = alternativeTitles;
	}
	final String? startDate = jsonConvert.convert<String>(json['start_date']);
	if (startDate != null) {
		malAnimeNode.startDate = startDate;
	}
	final String? endDate = jsonConvert.convert<String>(json['end_date']);
	if (endDate != null) {
		malAnimeNode.endDate = endDate;
	}
	final String? synopsis = jsonConvert.convert<String>(json['synopsis']);
	if (synopsis != null) {
		malAnimeNode.synopsis = synopsis;
	}
	final double? mean = jsonConvert.convert<double>(json['mean']);
	if (mean != null) {
		malAnimeNode.mean = mean;
	}
	final int? rank = jsonConvert.convert<int>(json['rank']);
	if (rank != null) {
		malAnimeNode.rank = rank;
	}
	final int? popularity = jsonConvert.convert<int>(json['popularity']);
	if (popularity != null) {
		malAnimeNode.popularity = popularity;
	}
	final int? numListUsers = jsonConvert.convert<int>(json['num_list_users']);
	if (numListUsers != null) {
		malAnimeNode.numListUsers = numListUsers;
	}
	final String? mediaType = jsonConvert.convert<String>(json['media_type']);
	if (mediaType != null) {
		malAnimeNode.mediaType = mediaType;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		malAnimeNode.status = status;
	}
	final List<MalAnimeNodeGenres>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MalAnimeNodeGenres>(e) as MalAnimeNodeGenres).toList();
	if (genres != null) {
		malAnimeNode.genres = genres;
	}
	final String? nsfw = jsonConvert.convert<String>(json['nsfw']);
	if (nsfw != null) {
		malAnimeNode.nsfw = nsfw;
	}
	final String? rating = jsonConvert.convert<String>(json['rating']);
	if (rating != null) {
		malAnimeNode.rating = rating;
	}
	final int? numEpisodes = jsonConvert.convert<int>(json['num_episodes']);
	if (numEpisodes != null) {
		malAnimeNode.numEpisodes = numEpisodes;
	}
	final MalAnimeNodeStartSeason? startSeason = jsonConvert.convert<MalAnimeNodeStartSeason>(json['start_season']);
	if (startSeason != null) {
		malAnimeNode.startSeason = startSeason;
	}
	final MalAnimeNodeBroadcast? broadcast = jsonConvert.convert<MalAnimeNodeBroadcast>(json['broadcast']);
	if (broadcast != null) {
		malAnimeNode.broadcast = broadcast;
	}
	final int? averageEpisodeDuration = jsonConvert.convert<int>(json['average_episode_duration']);
	if (averageEpisodeDuration != null) {
		malAnimeNode.averageEpisodeDuration = averageEpisodeDuration;
	}
	final List<MalAnimeNodeStudios>? studios = (json['studios'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MalAnimeNodeStudios>(e) as MalAnimeNodeStudios).toList();
	if (studios != null) {
		malAnimeNode.studios = studios;
	}
	final List<MalAnimeNodeRelated>? relatedAnime = (json['related_anime'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MalAnimeNodeRelated>(e) as MalAnimeNodeRelated).toList();
	if (relatedAnime != null) {
		malAnimeNode.relatedAnime = relatedAnime;
	}
	final List<MalAnimeNodeRelated>? relatedManga = (json['related_manga'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MalAnimeNodeRelated>(e) as MalAnimeNodeRelated).toList();
	if (relatedManga != null) {
		malAnimeNode.relatedManga = relatedManga;
	}
	final MalMyListStatusEntity? myListStatus = jsonConvert.convert<MalMyListStatusEntity>(json['my_list_status']);
	if (myListStatus != null) {
		malAnimeNode.myListStatus = myListStatus;
	}
	return malAnimeNode;
}

Map<String, dynamic> $MalAnimeNodeToJson(MalAnimeNode entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['title'] = entity.title;
	data['main_picture'] = entity.mainPicture.toJson();
	data['alternative_titles'] = entity.alternativeTitles.toJson();
	data['start_date'] = entity.startDate;
	data['end_date'] = entity.endDate;
	data['synopsis'] = entity.synopsis;
	data['mean'] = entity.mean;
	data['rank'] = entity.rank;
	data['popularity'] = entity.popularity;
	data['num_list_users'] = entity.numListUsers;
	data['media_type'] = entity.mediaType;
	data['status'] = entity.status;
	data['genres'] =  entity.genres.map((v) => v.toJson()).toList();
	data['nsfw'] = entity.nsfw;
	data['rating'] = entity.rating;
	data['num_episodes'] = entity.numEpisodes;
	data['start_season'] = entity.startSeason.toJson();
	data['broadcast'] = entity.broadcast.toJson();
	data['average_episode_duration'] = entity.averageEpisodeDuration;
	data['studios'] =  entity.studios.map((v) => v.toJson()).toList();
	data['related_anime'] =  entity.relatedAnime.map((v) => v.toJson()).toList();
	data['related_manga'] =  entity.relatedManga.map((v) => v.toJson()).toList();
	data['my_list_status'] = entity.myListStatus.toJson();
	return data;
}

extension MalAnimeNodeExtension on MalAnimeNode {
	MalAnimeNode copyWith({
	int? id,
	String? title,
	MalAnimeNodeMainPicture? mainPicture,
	MalAnimeNodeAlternativeTitles? alternativeTitles,
	String? startDate,
	String? endDate,
	String? synopsis,
	double? mean,
	int? rank,
	int? popularity,
	int? numListUsers,
	String? mediaType,
	String? status,
	List<MalAnimeNodeGenres>? genres,
	String? nsfw,
	String? rating,
	int? numEpisodes,
	MalAnimeNodeStartSeason? startSeason,
	MalAnimeNodeBroadcast? broadcast,
	int? averageEpisodeDuration,
	List<MalAnimeNodeStudios>? studios,
	List<MalAnimeNodeRelated>? relatedAnime,
	List<MalAnimeNodeRelated>? relatedManga,
	MalMyListStatusEntity? myListStatus,
	}) {
		return MalAnimeNode()
			..id = id ?? this.id
			..title = title ?? this.title
			..mainPicture = mainPicture ?? this.mainPicture
			..alternativeTitles = alternativeTitles ?? this.alternativeTitles
			..startDate = startDate ?? this.startDate
			..endDate = endDate ?? this.endDate
			..synopsis = synopsis ?? this.synopsis
			..mean = mean ?? this.mean
			..rank = rank ?? this.rank
			..popularity = popularity ?? this.popularity
			..numListUsers = numListUsers ?? this.numListUsers
			..mediaType = mediaType ?? this.mediaType
			..status = status ?? this.status
			..genres = genres ?? this.genres
			..nsfw = nsfw ?? this.nsfw
			..rating = rating ?? this.rating
			..numEpisodes = numEpisodes ?? this.numEpisodes
			..startSeason = startSeason ?? this.startSeason
			..broadcast = broadcast ?? this.broadcast
			..averageEpisodeDuration = averageEpisodeDuration ?? this.averageEpisodeDuration
			..studios = studios ?? this.studios
			..relatedAnime = relatedAnime ?? this.relatedAnime
			..relatedManga = relatedManga ?? this.relatedManga
			..myListStatus = myListStatus ?? this.myListStatus;
	}
}


MalAnimeNodeMainPicture $MalAnimeNodeMainPictureFromJson(Map<String, dynamic> json) {
	final MalAnimeNodeMainPicture malAnimeNodeMainPicture = MalAnimeNodeMainPicture();
	final String? medium = jsonConvert.convert<String>(json['medium']);
	if (medium != null) {
		malAnimeNodeMainPicture.medium = medium;
	}
	final String? large = jsonConvert.convert<String>(json['large']);
	if (large != null) {
		malAnimeNodeMainPicture.large = large;
	}
	return malAnimeNodeMainPicture;
}

Map<String, dynamic> $MalAnimeNodeMainPictureToJson(MalAnimeNodeMainPicture entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['medium'] = entity.medium;
	data['large'] = entity.large;
	return data;
}

extension MalAnimeNodeMainPictureExtension on MalAnimeNodeMainPicture {
	MalAnimeNodeMainPicture copyWith({
	String? medium,
	String? large,
	}) {
		return MalAnimeNodeMainPicture()
			..medium = medium ?? this.medium
			..large = large ?? this.large;
	}
}


MalAnimeNodeAlternativeTitles $MalAnimeNodeAlternativeTitlesFromJson(Map<String, dynamic> json) {
	final MalAnimeNodeAlternativeTitles malAnimeNodeAlternativeTitles = MalAnimeNodeAlternativeTitles();
	final List<String>? synonyms = (json['synonyms'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (synonyms != null) {
		malAnimeNodeAlternativeTitles.synonyms = synonyms;
	}
	final String? en = jsonConvert.convert<String>(json['en']);
	if (en != null) {
		malAnimeNodeAlternativeTitles.en = en;
	}
	final String? ja = jsonConvert.convert<String>(json['ja']);
	if (ja != null) {
		malAnimeNodeAlternativeTitles.ja = ja;
	}
	return malAnimeNodeAlternativeTitles;
}

Map<String, dynamic> $MalAnimeNodeAlternativeTitlesToJson(MalAnimeNodeAlternativeTitles entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['synonyms'] =  entity.synonyms;
	data['en'] = entity.en;
	data['ja'] = entity.ja;
	return data;
}

extension MalAnimeNodeAlternativeTitlesExtension on MalAnimeNodeAlternativeTitles {
	MalAnimeNodeAlternativeTitles copyWith({
	List<String>? synonyms,
	String? en,
	String? ja,
	}) {
		return MalAnimeNodeAlternativeTitles()
			..synonyms = synonyms ?? this.synonyms
			..en = en ?? this.en
			..ja = ja ?? this.ja;
	}
}


MalAnimeNodeGenres $MalAnimeNodeGenresFromJson(Map<String, dynamic> json) {
	final MalAnimeNodeGenres malAnimeNodeGenres = MalAnimeNodeGenres();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		malAnimeNodeGenres.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		malAnimeNodeGenres.name = name;
	}
	return malAnimeNodeGenres;
}

Map<String, dynamic> $MalAnimeNodeGenresToJson(MalAnimeNodeGenres entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	return data;
}

extension MalAnimeNodeGenresExtension on MalAnimeNodeGenres {
	MalAnimeNodeGenres copyWith({
	int? id,
	String? name,
	}) {
		return MalAnimeNodeGenres()
			..id = id ?? this.id
			..name = name ?? this.name;
	}
}


MalAnimeNodeStudios $MalAnimeNodeStudiosFromJson(Map<String, dynamic> json) {
	final MalAnimeNodeStudios malAnimeNodeStudios = MalAnimeNodeStudios();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		malAnimeNodeStudios.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		malAnimeNodeStudios.name = name;
	}
	return malAnimeNodeStudios;
}

Map<String, dynamic> $MalAnimeNodeStudiosToJson(MalAnimeNodeStudios entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	return data;
}

extension MalAnimeNodeStudiosExtension on MalAnimeNodeStudios {
	MalAnimeNodeStudios copyWith({
	int? id,
	String? name,
	}) {
		return MalAnimeNodeStudios()
			..id = id ?? this.id
			..name = name ?? this.name;
	}
}


MalAnimeNodeStartSeason $MalAnimeNodeStartSeasonFromJson(Map<String, dynamic> json) {
	final MalAnimeNodeStartSeason malAnimeNodeStartSeason = MalAnimeNodeStartSeason();
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		malAnimeNodeStartSeason.year = year;
	}
	final String? season = jsonConvert.convert<String>(json['season']);
	if (season != null) {
		malAnimeNodeStartSeason.season = season;
	}
	return malAnimeNodeStartSeason;
}

Map<String, dynamic> $MalAnimeNodeStartSeasonToJson(MalAnimeNodeStartSeason entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['year'] = entity.year;
	data['season'] = entity.season;
	return data;
}

extension MalAnimeNodeStartSeasonExtension on MalAnimeNodeStartSeason {
	MalAnimeNodeStartSeason copyWith({
	int? year,
	String? season,
	}) {
		return MalAnimeNodeStartSeason()
			..year = year ?? this.year
			..season = season ?? this.season;
	}
}


MalAnimeNodeBroadcast $MalAnimeNodeBroadcastFromJson(Map<String, dynamic> json) {
	final MalAnimeNodeBroadcast malAnimeNodeBroadcast = MalAnimeNodeBroadcast();
	final String? dayOfTheWeek = jsonConvert.convert<String>(json['day_of_the_week']);
	if (dayOfTheWeek != null) {
		malAnimeNodeBroadcast.dayOfTheWeek = dayOfTheWeek;
	}
	final String? startTime = jsonConvert.convert<String>(json['start_time']);
	if (startTime != null) {
		malAnimeNodeBroadcast.startTime = startTime;
	}
	return malAnimeNodeBroadcast;
}

Map<String, dynamic> $MalAnimeNodeBroadcastToJson(MalAnimeNodeBroadcast entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day_of_the_week'] = entity.dayOfTheWeek;
	data['start_time'] = entity.startTime;
	return data;
}

extension MalAnimeNodeBroadcastExtension on MalAnimeNodeBroadcast {
	MalAnimeNodeBroadcast copyWith({
	String? dayOfTheWeek,
	String? startTime,
	}) {
		return MalAnimeNodeBroadcast()
			..dayOfTheWeek = dayOfTheWeek ?? this.dayOfTheWeek
			..startTime = startTime ?? this.startTime;
	}
}


MalAnimeNodeRelated $MalAnimeNodeRelatedFromJson(Map<String, dynamic> json) {
	final MalAnimeNodeRelated malAnimeNodeRelated = MalAnimeNodeRelated();
	final String? relationType = jsonConvert.convert<String>(json['relation_type']);
	if (relationType != null) {
		malAnimeNodeRelated.relationType = relationType;
	}
	final String? relationTypeFormatted = jsonConvert.convert<String>(json['relation_type_formatted']);
	if (relationTypeFormatted != null) {
		malAnimeNodeRelated.relationTypeFormatted = relationTypeFormatted;
	}
	final MalAnimeNodeRelatedNode? node = jsonConvert.convert<MalAnimeNodeRelatedNode>(json['node']);
	if (node != null) {
		malAnimeNodeRelated.node = node;
	}
	return malAnimeNodeRelated;
}

Map<String, dynamic> $MalAnimeNodeRelatedToJson(MalAnimeNodeRelated entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['relation_type'] = entity.relationType;
	data['relation_type_formatted'] = entity.relationTypeFormatted;
	data['node'] = entity.node.toJson();
	return data;
}

extension MalAnimeNodeRelatedExtension on MalAnimeNodeRelated {
	MalAnimeNodeRelated copyWith({
	String? relationType,
	String? relationTypeFormatted,
	MalAnimeNodeRelatedNode? node,
	}) {
		return MalAnimeNodeRelated()
			..relationType = relationType ?? this.relationType
			..relationTypeFormatted = relationTypeFormatted ?? this.relationTypeFormatted
			..node = node ?? this.node;
	}
}


MalAnimeNodeRelatedNode $MalAnimeNodeRelatedNodeFromJson(Map<String, dynamic> json) {
	final MalAnimeNodeRelatedNode malAnimeNodeRelatedNode = MalAnimeNodeRelatedNode();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		malAnimeNodeRelatedNode.id = id;
	}
	final String? title = jsonConvert.convert<String>(json['title']);
	if (title != null) {
		malAnimeNodeRelatedNode.title = title;
	}
	final MalAnimeNodeRelatedNodeMainPicture? mainPicture = jsonConvert.convert<MalAnimeNodeRelatedNodeMainPicture>(json['main_picture']);
	if (mainPicture != null) {
		malAnimeNodeRelatedNode.mainPicture = mainPicture;
	}
	final String? startDate = jsonConvert.convert<String>(json['start_date']);
	if (startDate != null) {
		malAnimeNodeRelatedNode.startDate = startDate;
	}
	final String? endDate = jsonConvert.convert<String>(json['end_date']);
	if (endDate != null) {
		malAnimeNodeRelatedNode.endDate = endDate;
	}
	final String? synopsis = jsonConvert.convert<String>(json['synopsis']);
	if (synopsis != null) {
		malAnimeNodeRelatedNode.synopsis = synopsis;
	}
	final double? mean = jsonConvert.convert<double>(json['mean']);
	if (mean != null) {
		malAnimeNodeRelatedNode.mean = mean;
	}
	final String? mediaType = jsonConvert.convert<String>(json['media_type']);
	if (mediaType != null) {
		malAnimeNodeRelatedNode.mediaType = mediaType;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		malAnimeNodeRelatedNode.status = status;
	}
	final String? rating = jsonConvert.convert<String>(json['rating']);
	if (rating != null) {
		malAnimeNodeRelatedNode.rating = rating;
	}
	final String? nsfw = jsonConvert.convert<String>(json['nsfw']);
	if (nsfw != null) {
		malAnimeNodeRelatedNode.nsfw = nsfw;
	}
	final List<MalAnimeNodeGenres>? genres = (json['genres'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MalAnimeNodeGenres>(e) as MalAnimeNodeGenres).toList();
	if (genres != null) {
		malAnimeNodeRelatedNode.genres = genres;
	}
	final int? numEpisodes = jsonConvert.convert<int>(json['num_episodes']);
	if (numEpisodes != null) {
		malAnimeNodeRelatedNode.numEpisodes = numEpisodes;
	}
	final int? popularity = jsonConvert.convert<int>(json['popularity']);
	if (popularity != null) {
		malAnimeNodeRelatedNode.popularity = popularity;
	}
	return malAnimeNodeRelatedNode;
}

Map<String, dynamic> $MalAnimeNodeRelatedNodeToJson(MalAnimeNodeRelatedNode entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['title'] = entity.title;
	data['main_picture'] = entity.mainPicture.toJson();
	data['start_date'] = entity.startDate;
	data['end_date'] = entity.endDate;
	data['synopsis'] = entity.synopsis;
	data['mean'] = entity.mean;
	data['media_type'] = entity.mediaType;
	data['status'] = entity.status;
	data['rating'] = entity.rating;
	data['nsfw'] = entity.nsfw;
	data['genres'] =  entity.genres.map((v) => v.toJson()).toList();
	data['num_episodes'] = entity.numEpisodes;
	data['popularity'] = entity.popularity;
	return data;
}

extension MalAnimeNodeRelatedNodeExtension on MalAnimeNodeRelatedNode {
	MalAnimeNodeRelatedNode copyWith({
	int? id,
	String? title,
	MalAnimeNodeRelatedNodeMainPicture? mainPicture,
	String? startDate,
	String? endDate,
	String? synopsis,
	double? mean,
	String? mediaType,
	String? status,
	String? rating,
	String? nsfw,
	List<MalAnimeNodeGenres>? genres,
	int? numEpisodes,
	int? popularity,
	}) {
		return MalAnimeNodeRelatedNode()
			..id = id ?? this.id
			..title = title ?? this.title
			..mainPicture = mainPicture ?? this.mainPicture
			..startDate = startDate ?? this.startDate
			..endDate = endDate ?? this.endDate
			..synopsis = synopsis ?? this.synopsis
			..mean = mean ?? this.mean
			..mediaType = mediaType ?? this.mediaType
			..status = status ?? this.status
			..rating = rating ?? this.rating
			..nsfw = nsfw ?? this.nsfw
			..genres = genres ?? this.genres
			..numEpisodes = numEpisodes ?? this.numEpisodes
			..popularity = popularity ?? this.popularity;
	}
}


MalAnimeNodeRelatedNodeMainPicture $MalAnimeNodeRelatedNodeMainPictureFromJson(Map<String, dynamic> json) {
	final MalAnimeNodeRelatedNodeMainPicture malAnimeNodeRelatedNodeMainPicture = MalAnimeNodeRelatedNodeMainPicture();
	final String? medium = jsonConvert.convert<String>(json['medium']);
	if (medium != null) {
		malAnimeNodeRelatedNodeMainPicture.medium = medium;
	}
	final String? large = jsonConvert.convert<String>(json['large']);
	if (large != null) {
		malAnimeNodeRelatedNodeMainPicture.large = large;
	}
	return malAnimeNodeRelatedNodeMainPicture;
}

Map<String, dynamic> $MalAnimeNodeRelatedNodeMainPictureToJson(MalAnimeNodeRelatedNodeMainPicture entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['medium'] = entity.medium;
	data['large'] = entity.large;
	return data;
}

extension MalAnimeNodeRelatedNodeMainPictureExtension on MalAnimeNodeRelatedNodeMainPicture {
	MalAnimeNodeRelatedNodeMainPicture copyWith({
	String? medium,
	String? large,
	}) {
		return MalAnimeNodeRelatedNodeMainPicture()
			..medium = medium ?? this.medium
			..large = large ?? this.large;
	}
}

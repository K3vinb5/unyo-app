import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/jikan/jikan_schedule_entity.dart';

JikanScheduleEntity $JikanScheduleEntityFromJson(Map<String, dynamic> json) {
	final JikanScheduleEntity jikanScheduleEntity = JikanScheduleEntity();
	final List<JikanScheduleData>? data = (json['data'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<JikanScheduleData>(e) as JikanScheduleData).toList();
	if (data != null) {
		jikanScheduleEntity.data = data;
	}
	final JikanSchedulePagination? pagination = jsonConvert.convert<JikanSchedulePagination>(json['pagination']);
	if (pagination != null) {
		jikanScheduleEntity.pagination = pagination;
	}
	return jikanScheduleEntity;
}

Map<String, dynamic> $JikanScheduleEntityToJson(JikanScheduleEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['data'] =  entity.data.map((v) => v.toJson()).toList();
	data['pagination'] = entity.pagination.toJson();
	return data;
}

extension JikanScheduleEntityExtension on JikanScheduleEntity {
	JikanScheduleEntity copyWith({
	List<JikanScheduleData>? data,
	JikanSchedulePagination? pagination,
	}) {
		return JikanScheduleEntity()
			..data = data ?? this.data
			..pagination = pagination ?? this.pagination;
	}
}


JikanScheduleData $JikanScheduleDataFromJson(Map<String, dynamic> json) {
	final JikanScheduleData jikanScheduleData = JikanScheduleData();
	final int? malId = jsonConvert.convert<int>(json['mal_id']);
	if (malId != null) {
		jikanScheduleData.malId = malId;
	}
	final String? title = jsonConvert.convert<String>(json['title']);
	if (title != null) {
		jikanScheduleData.title = title;
	}
	final String? type = jsonConvert.convert<String>(json['type']);
	if (type != null) {
		jikanScheduleData.type = type;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		jikanScheduleData.episodes = episodes;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		jikanScheduleData.status = status;
	}
	final double? score = jsonConvert.convert<double>(json['score']);
	if (score != null) {
		jikanScheduleData.score = score;
	}
	final String? rating = jsonConvert.convert<String>(json['rating']);
	if (rating != null) {
		jikanScheduleData.rating = rating;
	}
	final bool? airing = jsonConvert.convert<bool>(json['airing']);
	if (airing != null) {
		jikanScheduleData.airing = airing;
	}
	final String? synopsis = jsonConvert.convert<String>(json['synopsis']);
	if (synopsis != null) {
		jikanScheduleData.synopsis = synopsis;
	}
	final JikanScheduleDataImages? images = jsonConvert.convert<JikanScheduleDataImages>(json['images']);
	if (images != null) {
		jikanScheduleData.images = images;
	}
	final JikanScheduleDataBroadcast? broadcast = jsonConvert.convert<JikanScheduleDataBroadcast>(json['broadcast']);
	if (broadcast != null) {
		jikanScheduleData.broadcast = broadcast;
	}
	final JikanScheduleDataAired? aired = jsonConvert.convert<JikanScheduleDataAired>(json['aired']);
	if (aired != null) {
		jikanScheduleData.aired = aired;
	}
	return jikanScheduleData;
}

Map<String, dynamic> $JikanScheduleDataToJson(JikanScheduleData entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['mal_id'] = entity.malId;
	data['title'] = entity.title;
	data['type'] = entity.type;
	data['episodes'] = entity.episodes;
	data['status'] = entity.status;
	data['score'] = entity.score;
	data['rating'] = entity.rating;
	data['airing'] = entity.airing;
	data['synopsis'] = entity.synopsis;
	data['images'] = entity.images.toJson();
	data['broadcast'] = entity.broadcast.toJson();
	data['aired'] = entity.aired.toJson();
	return data;
}

extension JikanScheduleDataExtension on JikanScheduleData {
	JikanScheduleData copyWith({
	int? malId,
	String? title,
	String? type,
	int? episodes,
	String? status,
	double? score,
	String? rating,
	bool? airing,
	String? synopsis,
	JikanScheduleDataImages? images,
	JikanScheduleDataBroadcast? broadcast,
	JikanScheduleDataAired? aired,
	}) {
		return JikanScheduleData()
			..malId = malId ?? this.malId
			..title = title ?? this.title
			..type = type ?? this.type
			..episodes = episodes ?? this.episodes
			..status = status ?? this.status
			..score = score ?? this.score
			..rating = rating ?? this.rating
			..airing = airing ?? this.airing
			..synopsis = synopsis ?? this.synopsis
			..images = images ?? this.images
			..broadcast = broadcast ?? this.broadcast
			..aired = aired ?? this.aired;
	}
}


JikanScheduleDataImages $JikanScheduleDataImagesFromJson(Map<String, dynamic> json) {
	final JikanScheduleDataImages jikanScheduleDataImages = JikanScheduleDataImages();
	final JikanScheduleDataImagesJpg? jpg = jsonConvert.convert<JikanScheduleDataImagesJpg>(json['jpg']);
	if (jpg != null) {
		jikanScheduleDataImages.jpg = jpg;
	}
	return jikanScheduleDataImages;
}

Map<String, dynamic> $JikanScheduleDataImagesToJson(JikanScheduleDataImages entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['jpg'] = entity.jpg.toJson();
	return data;
}

extension JikanScheduleDataImagesExtension on JikanScheduleDataImages {
	JikanScheduleDataImages copyWith({
	JikanScheduleDataImagesJpg? jpg,
	}) {
		return JikanScheduleDataImages()
			..jpg = jpg ?? this.jpg;
	}
}


JikanScheduleDataImagesJpg $JikanScheduleDataImagesJpgFromJson(Map<String, dynamic> json) {
	final JikanScheduleDataImagesJpg jikanScheduleDataImagesJpg = JikanScheduleDataImagesJpg();
	final String? imageUrl = jsonConvert.convert<String>(json['image_url']);
	if (imageUrl != null) {
		jikanScheduleDataImagesJpg.imageUrl = imageUrl;
	}
	final String? smallImageUrl = jsonConvert.convert<String>(json['small_image_url']);
	if (smallImageUrl != null) {
		jikanScheduleDataImagesJpg.smallImageUrl = smallImageUrl;
	}
	final String? largeImageUrl = jsonConvert.convert<String>(json['large_image_url']);
	if (largeImageUrl != null) {
		jikanScheduleDataImagesJpg.largeImageUrl = largeImageUrl;
	}
	return jikanScheduleDataImagesJpg;
}

Map<String, dynamic> $JikanScheduleDataImagesJpgToJson(JikanScheduleDataImagesJpg entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['image_url'] = entity.imageUrl;
	data['small_image_url'] = entity.smallImageUrl;
	data['large_image_url'] = entity.largeImageUrl;
	return data;
}

extension JikanScheduleDataImagesJpgExtension on JikanScheduleDataImagesJpg {
	JikanScheduleDataImagesJpg copyWith({
	String? imageUrl,
	String? smallImageUrl,
	String? largeImageUrl,
	}) {
		return JikanScheduleDataImagesJpg()
			..imageUrl = imageUrl ?? this.imageUrl
			..smallImageUrl = smallImageUrl ?? this.smallImageUrl
			..largeImageUrl = largeImageUrl ?? this.largeImageUrl;
	}
}


JikanScheduleDataBroadcast $JikanScheduleDataBroadcastFromJson(Map<String, dynamic> json) {
	final JikanScheduleDataBroadcast jikanScheduleDataBroadcast = JikanScheduleDataBroadcast();
	final String? day = jsonConvert.convert<String>(json['day']);
	if (day != null) {
		jikanScheduleDataBroadcast.day = day;
	}
	final String? time = jsonConvert.convert<String>(json['time']);
	if (time != null) {
		jikanScheduleDataBroadcast.time = time;
	}
	final String? string = jsonConvert.convert<String>(json['string']);
	if (string != null) {
		jikanScheduleDataBroadcast.string = string;
	}
	return jikanScheduleDataBroadcast;
}

Map<String, dynamic> $JikanScheduleDataBroadcastToJson(JikanScheduleDataBroadcast entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['time'] = entity.time;
	data['string'] = entity.string;
	return data;
}

extension JikanScheduleDataBroadcastExtension on JikanScheduleDataBroadcast {
	JikanScheduleDataBroadcast copyWith({
	String? day,
	String? time,
	String? string,
	}) {
		return JikanScheduleDataBroadcast()
			..day = day ?? this.day
			..time = time ?? this.time
			..string = string ?? this.string;
	}
}


JikanScheduleDataAired $JikanScheduleDataAiredFromJson(Map<String, dynamic> json) {
	final JikanScheduleDataAired jikanScheduleDataAired = JikanScheduleDataAired();
	final String? from = jsonConvert.convert<String>(json['from']);
	if (from != null) {
		jikanScheduleDataAired.from = from;
	}
	return jikanScheduleDataAired;
}

Map<String, dynamic> $JikanScheduleDataAiredToJson(JikanScheduleDataAired entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['from'] = entity.from;
	return data;
}

extension JikanScheduleDataAiredExtension on JikanScheduleDataAired {
	JikanScheduleDataAired copyWith({
	String? from,
	}) {
		return JikanScheduleDataAired()
			..from = from ?? this.from;
	}
}


JikanSchedulePagination $JikanSchedulePaginationFromJson(Map<String, dynamic> json) {
	final JikanSchedulePagination jikanSchedulePagination = JikanSchedulePagination();
	final int? lastVisiblePage = jsonConvert.convert<int>(json['last_visible_page']);
	if (lastVisiblePage != null) {
		jikanSchedulePagination.lastVisiblePage = lastVisiblePage;
	}
	final bool? hasNextPage = jsonConvert.convert<bool>(json['has_next_page']);
	if (hasNextPage != null) {
		jikanSchedulePagination.hasNextPage = hasNextPage;
	}
	return jikanSchedulePagination;
}

Map<String, dynamic> $JikanSchedulePaginationToJson(JikanSchedulePagination entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['last_visible_page'] = entity.lastVisiblePage;
	data['has_next_page'] = entity.hasNextPage;
	return data;
}

extension JikanSchedulePaginationExtension on JikanSchedulePagination {
	JikanSchedulePagination copyWith({
	int? lastVisiblePage,
	bool? hasNextPage,
	}) {
		return JikanSchedulePagination()
			..lastVisiblePage = lastVisiblePage ?? this.lastVisiblePage
			..hasNextPage = hasNextPage ?? this.hasNextPage;
	}
}

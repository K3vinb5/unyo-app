import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/anilist/media_details_media_list_entry_entity.dart';

MediaDetailsMediaListEntryEntity $MediaDetailsMediaListEntryEntityFromJson(Map<String, dynamic> json) {
	final MediaDetailsMediaListEntryEntity mediaDetailsMediaListEntryEntity = MediaDetailsMediaListEntryEntity();
	final MediaDetailsMediaListEntryMedia? media = jsonConvert.convert<MediaDetailsMediaListEntryMedia>(json['Media']);
	if (media != null) {
		mediaDetailsMediaListEntryEntity.media = media;
	}
	return mediaDetailsMediaListEntryEntity;
}

Map<String, dynamic> $MediaDetailsMediaListEntryEntityToJson(MediaDetailsMediaListEntryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['Media'] = entity.media.toJson();
	return data;
}

extension MediaDetailsMediaListEntryEntityExtension on MediaDetailsMediaListEntryEntity {
	MediaDetailsMediaListEntryEntity copyWith({
	MediaDetailsMediaListEntryMedia? media,
	}) {
		return MediaDetailsMediaListEntryEntity()
			..media = media ?? this.media;
	}
}


MediaDetailsMediaListEntryMedia $MediaDetailsMediaListEntryMediaFromJson(Map<String, dynamic> json) {
	final MediaDetailsMediaListEntryMedia mediaDetailsMediaListEntryMedia = MediaDetailsMediaListEntryMedia();
	final MediaDetailsMediaListEntryMediaMediaListEntry? mediaListEntry = jsonConvert.convert<MediaDetailsMediaListEntryMediaMediaListEntry>(json['mediaListEntry']);
	if (mediaListEntry != null) {
		mediaDetailsMediaListEntryMedia.mediaListEntry = mediaListEntry;
	}
	return mediaDetailsMediaListEntryMedia;
}

Map<String, dynamic> $MediaDetailsMediaListEntryMediaToJson(MediaDetailsMediaListEntryMedia entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['mediaListEntry'] = entity.mediaListEntry.toJson();
	return data;
}

extension MediaDetailsMediaListEntryMediaExtension on MediaDetailsMediaListEntryMedia {
	MediaDetailsMediaListEntryMedia copyWith({
	MediaDetailsMediaListEntryMediaMediaListEntry? mediaListEntry,
	}) {
		return MediaDetailsMediaListEntryMedia()
			..mediaListEntry = mediaListEntry ?? this.mediaListEntry;
	}
}


MediaDetailsMediaListEntryMediaMediaListEntry $MediaDetailsMediaListEntryMediaMediaListEntryFromJson(Map<String, dynamic> json) {
	final MediaDetailsMediaListEntryMediaMediaListEntry mediaDetailsMediaListEntryMediaMediaListEntry = MediaDetailsMediaListEntryMediaMediaListEntry();
	final int? progress = jsonConvert.convert<int>(json['progress']);
	if (progress != null) {
		mediaDetailsMediaListEntryMediaMediaListEntry.progress = progress;
	}
	final double? score = jsonConvert.convert<double>(json['score']);
	if (score != null) {
		mediaDetailsMediaListEntryMediaMediaListEntry.score = score;
	}
	final int? repeat = jsonConvert.convert<int>(json['repeat']);
	if (repeat != null) {
		mediaDetailsMediaListEntryMediaMediaListEntry.repeat = repeat;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		mediaDetailsMediaListEntryMediaMediaListEntry.status = status;
	}
	final MediaDetailsMediaListEntryMediaMediaListEntryStartedAt? startedAt = jsonConvert.convert<MediaDetailsMediaListEntryMediaMediaListEntryStartedAt>(json['startedAt']);
	if (startedAt != null) {
		mediaDetailsMediaListEntryMediaMediaListEntry.startedAt = startedAt;
	}
	final MediaDetailsMediaListEntryMediaMediaListEntryCompletedAt? completedAt = jsonConvert.convert<MediaDetailsMediaListEntryMediaMediaListEntryCompletedAt>(json['completedAt']);
	if (completedAt != null) {
		mediaDetailsMediaListEntryMediaMediaListEntry.completedAt = completedAt;
	}
	final List<MediaDetailsMediaListEntryMediaMediaListEntryCustomLists>? customLists = (json['customLists'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<MediaDetailsMediaListEntryMediaMediaListEntryCustomLists>(e) as MediaDetailsMediaListEntryMediaMediaListEntryCustomLists).toList();
	if (customLists != null) {
		mediaDetailsMediaListEntryMediaMediaListEntry.customLists = customLists;
	}
	final int? progressVolumes = jsonConvert.convert<int>(json['progressVolumes']);
	if (progressVolumes != null) {
		mediaDetailsMediaListEntryMediaMediaListEntry.progressVolumes = progressVolumes;
	}
	return mediaDetailsMediaListEntryMediaMediaListEntry;
}

Map<String, dynamic> $MediaDetailsMediaListEntryMediaMediaListEntryToJson(MediaDetailsMediaListEntryMediaMediaListEntry entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['progress'] = entity.progress;
	data['score'] = entity.score;
	data['repeat'] = entity.repeat;
	data['status'] = entity.status;
	data['startedAt'] = entity.startedAt.toJson();
	data['completedAt'] = entity.completedAt.toJson();
	data['customLists'] =  entity.customLists.map((v) => v.toJson()).toList();
	data['progressVolumes'] = entity.progressVolumes;
	return data;
}

extension MediaDetailsMediaListEntryMediaMediaListEntryExtension on MediaDetailsMediaListEntryMediaMediaListEntry {
	MediaDetailsMediaListEntryMediaMediaListEntry copyWith({
	int? progress,
	double? score,
	int? repeat,
	String? status,
	MediaDetailsMediaListEntryMediaMediaListEntryStartedAt? startedAt,
	MediaDetailsMediaListEntryMediaMediaListEntryCompletedAt? completedAt,
	List<MediaDetailsMediaListEntryMediaMediaListEntryCustomLists>? customLists,
	int? progressVolumes,
	}) {
		return MediaDetailsMediaListEntryMediaMediaListEntry()
			..progress = progress ?? this.progress
			..score = score ?? this.score
			..repeat = repeat ?? this.repeat
			..status = status ?? this.status
			..startedAt = startedAt ?? this.startedAt
			..completedAt = completedAt ?? this.completedAt
			..customLists = customLists ?? this.customLists
			..progressVolumes = progressVolumes ?? this.progressVolumes;
	}
}


MediaDetailsMediaListEntryMediaMediaListEntryStartedAt $MediaDetailsMediaListEntryMediaMediaListEntryStartedAtFromJson(Map<String, dynamic> json) {
	final MediaDetailsMediaListEntryMediaMediaListEntryStartedAt mediaDetailsMediaListEntryMediaMediaListEntryStartedAt = MediaDetailsMediaListEntryMediaMediaListEntryStartedAt();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaDetailsMediaListEntryMediaMediaListEntryStartedAt.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaDetailsMediaListEntryMediaMediaListEntryStartedAt.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaDetailsMediaListEntryMediaMediaListEntryStartedAt.year = year;
	}
	return mediaDetailsMediaListEntryMediaMediaListEntryStartedAt;
}

Map<String, dynamic> $MediaDetailsMediaListEntryMediaMediaListEntryStartedAtToJson(MediaDetailsMediaListEntryMediaMediaListEntryStartedAt entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaDetailsMediaListEntryMediaMediaListEntryStartedAtExtension on MediaDetailsMediaListEntryMediaMediaListEntryStartedAt {
	MediaDetailsMediaListEntryMediaMediaListEntryStartedAt copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaDetailsMediaListEntryMediaMediaListEntryStartedAt()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaDetailsMediaListEntryMediaMediaListEntryCompletedAt $MediaDetailsMediaListEntryMediaMediaListEntryCompletedAtFromJson(Map<String, dynamic> json) {
	final MediaDetailsMediaListEntryMediaMediaListEntryCompletedAt mediaDetailsMediaListEntryMediaMediaListEntryCompletedAt = MediaDetailsMediaListEntryMediaMediaListEntryCompletedAt();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		mediaDetailsMediaListEntryMediaMediaListEntryCompletedAt.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		mediaDetailsMediaListEntryMediaMediaListEntryCompletedAt.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		mediaDetailsMediaListEntryMediaMediaListEntryCompletedAt.year = year;
	}
	return mediaDetailsMediaListEntryMediaMediaListEntryCompletedAt;
}

Map<String, dynamic> $MediaDetailsMediaListEntryMediaMediaListEntryCompletedAtToJson(MediaDetailsMediaListEntryMediaMediaListEntryCompletedAt entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension MediaDetailsMediaListEntryMediaMediaListEntryCompletedAtExtension on MediaDetailsMediaListEntryMediaMediaListEntryCompletedAt {
	MediaDetailsMediaListEntryMediaMediaListEntryCompletedAt copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return MediaDetailsMediaListEntryMediaMediaListEntryCompletedAt()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


MediaDetailsMediaListEntryMediaMediaListEntryCustomLists $MediaDetailsMediaListEntryMediaMediaListEntryCustomListsFromJson(Map<String, dynamic> json) {
	final MediaDetailsMediaListEntryMediaMediaListEntryCustomLists mediaDetailsMediaListEntryMediaMediaListEntryCustomLists = MediaDetailsMediaListEntryMediaMediaListEntryCustomLists();
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		mediaDetailsMediaListEntryMediaMediaListEntryCustomLists.name = name;
	}
	final bool? enabled = jsonConvert.convert<bool>(json['enabled']);
	if (enabled != null) {
		mediaDetailsMediaListEntryMediaMediaListEntryCustomLists.enabled = enabled;
	}
	return mediaDetailsMediaListEntryMediaMediaListEntryCustomLists;
}

Map<String, dynamic> $MediaDetailsMediaListEntryMediaMediaListEntryCustomListsToJson(MediaDetailsMediaListEntryMediaMediaListEntryCustomLists entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['name'] = entity.name;
	data['enabled'] = entity.enabled;
	return data;
}

extension MediaDetailsMediaListEntryMediaMediaListEntryCustomListsExtension on MediaDetailsMediaListEntryMediaMediaListEntryCustomLists {
	MediaDetailsMediaListEntryMediaMediaListEntryCustomLists copyWith({
	String? name,
	bool? enabled,
	}) {
		return MediaDetailsMediaListEntryMediaMediaListEntryCustomLists()
			..name = name ?? this.name
			..enabled = enabled ?? this.enabled;
	}
}

import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/anilist/save_media_list_entry_entity.dart';

SaveMediaListEntryEntity $SaveMediaListEntryEntityFromJson(Map<String, dynamic> json) {
	final SaveMediaListEntryEntity saveMediaListEntryEntity = SaveMediaListEntryEntity();
	final SaveMediaListEntrySaveMediaListEntry? saveMediaListEntry = jsonConvert.convert<SaveMediaListEntrySaveMediaListEntry>(json['SaveMediaListEntry']);
	if (saveMediaListEntry != null) {
		saveMediaListEntryEntity.saveMediaListEntry = saveMediaListEntry;
	}
	return saveMediaListEntryEntity;
}

Map<String, dynamic> $SaveMediaListEntryEntityToJson(SaveMediaListEntryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['SaveMediaListEntry'] = entity.saveMediaListEntry.toJson();
	return data;
}

extension SaveMediaListEntryEntityExtension on SaveMediaListEntryEntity {
	SaveMediaListEntryEntity copyWith({
	SaveMediaListEntrySaveMediaListEntry? saveMediaListEntry,
	}) {
		return SaveMediaListEntryEntity()
			..saveMediaListEntry = saveMediaListEntry ?? this.saveMediaListEntry;
	}
}


SaveMediaListEntrySaveMediaListEntry $SaveMediaListEntrySaveMediaListEntryFromJson(Map<String, dynamic> json) {
	final SaveMediaListEntrySaveMediaListEntry saveMediaListEntrySaveMediaListEntry = SaveMediaListEntrySaveMediaListEntry();
	final int? progress = jsonConvert.convert<int>(json['progress']);
	if (progress != null) {
		saveMediaListEntrySaveMediaListEntry.progress = progress;
	}
	final int? progressVolumes = jsonConvert.convert<int>(json['progressVolumes']);
	if (progressVolumes != null) {
		saveMediaListEntrySaveMediaListEntry.progressVolumes = progressVolumes;
	}
	final int? repeat = jsonConvert.convert<int>(json['repeat']);
	if (repeat != null) {
		saveMediaListEntrySaveMediaListEntry.repeat = repeat;
	}
	final double? score = jsonConvert.convert<double>(json['score']);
	if (score != null) {
		saveMediaListEntrySaveMediaListEntry.score = score;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		saveMediaListEntrySaveMediaListEntry.status = status;
	}
	final SaveMediaListEntrySaveMediaListEntryStartedAt? startedAt = jsonConvert.convert<SaveMediaListEntrySaveMediaListEntryStartedAt>(json['startedAt']);
	if (startedAt != null) {
		saveMediaListEntrySaveMediaListEntry.startedAt = startedAt;
	}
	final SaveMediaListEntrySaveMediaListEntryCompletedAt? completedAt = jsonConvert.convert<SaveMediaListEntrySaveMediaListEntryCompletedAt>(json['completedAt']);
	if (completedAt != null) {
		saveMediaListEntrySaveMediaListEntry.completedAt = completedAt;
	}
	return saveMediaListEntrySaveMediaListEntry;
}

Map<String, dynamic> $SaveMediaListEntrySaveMediaListEntryToJson(SaveMediaListEntrySaveMediaListEntry entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['progress'] = entity.progress;
	data['progressVolumes'] = entity.progressVolumes;
	data['repeat'] = entity.repeat;
	data['score'] = entity.score;
	data['status'] = entity.status;
	data['startedAt'] = entity.startedAt.toJson();
	data['completedAt'] = entity.completedAt.toJson();
	return data;
}

extension SaveMediaListEntrySaveMediaListEntryExtension on SaveMediaListEntrySaveMediaListEntry {
	SaveMediaListEntrySaveMediaListEntry copyWith({
	int? progress,
	int? progressVolumes,
	int? repeat,
	double? score,
	String? status,
	SaveMediaListEntrySaveMediaListEntryStartedAt? startedAt,
	SaveMediaListEntrySaveMediaListEntryCompletedAt? completedAt,
	}) {
		return SaveMediaListEntrySaveMediaListEntry()
			..progress = progress ?? this.progress
			..progressVolumes = progressVolumes ?? this.progressVolumes
			..repeat = repeat ?? this.repeat
			..score = score ?? this.score
			..status = status ?? this.status
			..startedAt = startedAt ?? this.startedAt
			..completedAt = completedAt ?? this.completedAt;
	}
}


SaveMediaListEntrySaveMediaListEntryStartedAt $SaveMediaListEntrySaveMediaListEntryStartedAtFromJson(Map<String, dynamic> json) {
	final SaveMediaListEntrySaveMediaListEntryStartedAt saveMediaListEntrySaveMediaListEntryStartedAt = SaveMediaListEntrySaveMediaListEntryStartedAt();
	final dynamic day = json['day'];
	if (day != null) {
		saveMediaListEntrySaveMediaListEntryStartedAt.day = day;
	}
	final dynamic month = json['month'];
	if (month != null) {
		saveMediaListEntrySaveMediaListEntryStartedAt.month = month;
	}
	final dynamic year = json['year'];
	if (year != null) {
		saveMediaListEntrySaveMediaListEntryStartedAt.year = year;
	}
	return saveMediaListEntrySaveMediaListEntryStartedAt;
}

Map<String, dynamic> $SaveMediaListEntrySaveMediaListEntryStartedAtToJson(SaveMediaListEntrySaveMediaListEntryStartedAt entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension SaveMediaListEntrySaveMediaListEntryStartedAtExtension on SaveMediaListEntrySaveMediaListEntryStartedAt {
	SaveMediaListEntrySaveMediaListEntryStartedAt copyWith({
	dynamic day,
	dynamic month,
	dynamic year,
	}) {
		return SaveMediaListEntrySaveMediaListEntryStartedAt()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}


SaveMediaListEntrySaveMediaListEntryCompletedAt $SaveMediaListEntrySaveMediaListEntryCompletedAtFromJson(Map<String, dynamic> json) {
	final SaveMediaListEntrySaveMediaListEntryCompletedAt saveMediaListEntrySaveMediaListEntryCompletedAt = SaveMediaListEntrySaveMediaListEntryCompletedAt();
	final int? day = jsonConvert.convert<int>(json['day']);
	if (day != null) {
		saveMediaListEntrySaveMediaListEntryCompletedAt.day = day;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		saveMediaListEntrySaveMediaListEntryCompletedAt.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		saveMediaListEntrySaveMediaListEntryCompletedAt.year = year;
	}
	return saveMediaListEntrySaveMediaListEntryCompletedAt;
}

Map<String, dynamic> $SaveMediaListEntrySaveMediaListEntryCompletedAtToJson(SaveMediaListEntrySaveMediaListEntryCompletedAt entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

extension SaveMediaListEntrySaveMediaListEntryCompletedAtExtension on SaveMediaListEntrySaveMediaListEntryCompletedAt {
	SaveMediaListEntrySaveMediaListEntryCompletedAt copyWith({
	int? day,
	int? month,
	int? year,
	}) {
		return SaveMediaListEntrySaveMediaListEntryCompletedAt()
			..day = day ?? this.day
			..month = month ?? this.month
			..year = year ?? this.year;
	}
}

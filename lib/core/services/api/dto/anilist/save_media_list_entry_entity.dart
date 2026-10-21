import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/save_media_list_entry_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/save_media_list_entry_entity.g.dart';

@JsonSerializable()
class SaveMediaListEntryEntity {
	@JSONField(name: 'SaveMediaListEntry')
	late SaveMediaListEntrySaveMediaListEntry saveMediaListEntry = SaveMediaListEntrySaveMediaListEntry();

	SaveMediaListEntryEntity();

	factory SaveMediaListEntryEntity.fromJson(Map<String, dynamic> json) => $SaveMediaListEntryEntityFromJson(json);

	Map<String, dynamic> toJson() => $SaveMediaListEntryEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class SaveMediaListEntrySaveMediaListEntry {
	int progress = 0;
	int progressVolumes = 0;
	int repeat = 0;
	double score = 0;
	String status = '';
	late SaveMediaListEntrySaveMediaListEntryStartedAt startedAt = SaveMediaListEntrySaveMediaListEntryStartedAt();
	late SaveMediaListEntrySaveMediaListEntryCompletedAt completedAt = SaveMediaListEntrySaveMediaListEntryCompletedAt();

	SaveMediaListEntrySaveMediaListEntry();

	factory SaveMediaListEntrySaveMediaListEntry.fromJson(Map<String, dynamic> json) => $SaveMediaListEntrySaveMediaListEntryFromJson(json);

	Map<String, dynamic> toJson() => $SaveMediaListEntrySaveMediaListEntryToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class SaveMediaListEntrySaveMediaListEntryStartedAt {
	dynamic day;
	dynamic month;
	dynamic year;

	SaveMediaListEntrySaveMediaListEntryStartedAt();

	factory SaveMediaListEntrySaveMediaListEntryStartedAt.fromJson(Map<String, dynamic> json) => $SaveMediaListEntrySaveMediaListEntryStartedAtFromJson(json);

	Map<String, dynamic> toJson() => $SaveMediaListEntrySaveMediaListEntryStartedAtToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class SaveMediaListEntrySaveMediaListEntryCompletedAt {
	int day = 0;
	int month = 0;
	int year = 0;

	SaveMediaListEntrySaveMediaListEntryCompletedAt();

	factory SaveMediaListEntrySaveMediaListEntryCompletedAt.fromJson(Map<String, dynamic> json) => $SaveMediaListEntrySaveMediaListEntryCompletedAtFromJson(json);

	Map<String, dynamic> toJson() => $SaveMediaListEntrySaveMediaListEntryCompletedAtToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
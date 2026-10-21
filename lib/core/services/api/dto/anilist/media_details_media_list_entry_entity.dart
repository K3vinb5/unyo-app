import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/media_details_media_list_entry_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/media_details_media_list_entry_entity.g.dart';

@JsonSerializable()
class MediaDetailsMediaListEntryEntity {
	@JSONField(name: 'Media')
	late MediaDetailsMediaListEntryMedia media = MediaDetailsMediaListEntryMedia();

	MediaDetailsMediaListEntryEntity();

	factory MediaDetailsMediaListEntryEntity.fromJson(Map<String, dynamic> json) => $MediaDetailsMediaListEntryEntityFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsMediaListEntryEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsMediaListEntryMedia {
	MediaDetailsMediaListEntryMediaMediaListEntry mediaListEntry = MediaDetailsMediaListEntryMediaMediaListEntry();

	MediaDetailsMediaListEntryMedia();

	factory MediaDetailsMediaListEntryMedia.fromJson(Map<String, dynamic> json) => $MediaDetailsMediaListEntryMediaFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsMediaListEntryMediaToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsMediaListEntryMediaMediaListEntry {
	int progress = 0;
	double score = 0.0;
	int repeat = 0;
	String status = 'ADD TO LIST';
	MediaDetailsMediaListEntryMediaMediaListEntryStartedAt startedAt = MediaDetailsMediaListEntryMediaMediaListEntryStartedAt();
	MediaDetailsMediaListEntryMediaMediaListEntryCompletedAt completedAt = MediaDetailsMediaListEntryMediaMediaListEntryCompletedAt();
	List<MediaDetailsMediaListEntryMediaMediaListEntryCustomLists> customLists = [];
	int progressVolumes = 0;

	MediaDetailsMediaListEntryMediaMediaListEntry();

	factory MediaDetailsMediaListEntryMediaMediaListEntry.fromJson(Map<String, dynamic> json) => $MediaDetailsMediaListEntryMediaMediaListEntryFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsMediaListEntryMediaMediaListEntryToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsMediaListEntryMediaMediaListEntryStartedAt {
	int day = 0;
	int month = 0;
	int year = 0;

	MediaDetailsMediaListEntryMediaMediaListEntryStartedAt();

	factory MediaDetailsMediaListEntryMediaMediaListEntryStartedAt.fromJson(Map<String, dynamic> json) => $MediaDetailsMediaListEntryMediaMediaListEntryStartedAtFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsMediaListEntryMediaMediaListEntryStartedAtToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsMediaListEntryMediaMediaListEntryCompletedAt {
	int day = 0;
	int month = 0;
	int year = 0;

	MediaDetailsMediaListEntryMediaMediaListEntryCompletedAt();

	factory MediaDetailsMediaListEntryMediaMediaListEntryCompletedAt.fromJson(Map<String, dynamic> json) => $MediaDetailsMediaListEntryMediaMediaListEntryCompletedAtFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsMediaListEntryMediaMediaListEntryCompletedAtToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MediaDetailsMediaListEntryMediaMediaListEntryCustomLists {
	String name = '';
	bool enabled = false;

	MediaDetailsMediaListEntryMediaMediaListEntryCustomLists();

	factory MediaDetailsMediaListEntryMediaMediaListEntryCustomLists.fromJson(Map<String, dynamic> json) => $MediaDetailsMediaListEntryMediaMediaListEntryCustomListsFromJson(json);

	Map<String, dynamic> toJson() => $MediaDetailsMediaListEntryMediaMediaListEntryCustomListsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
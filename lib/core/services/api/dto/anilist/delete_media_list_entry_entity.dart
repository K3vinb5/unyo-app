import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/delete_media_list_entry_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/delete_media_list_entry_entity.g.dart';

@JsonSerializable()
class DeleteMediaListEntryEntity {
	@JSONField(name: 'DeleteMediaListEntry')
	late DeleteMediaListEntryDeleteMediaListEntry deleteMediaListEntry = DeleteMediaListEntryDeleteMediaListEntry();

	DeleteMediaListEntryEntity();

	factory DeleteMediaListEntryEntity.fromJson(Map<String, dynamic> json) => $DeleteMediaListEntryEntityFromJson(json);

	Map<String, dynamic> toJson() => $DeleteMediaListEntryEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class DeleteMediaListEntryDeleteMediaListEntry {
	late bool deleted = false;

	DeleteMediaListEntryDeleteMediaListEntry();

	factory DeleteMediaListEntryDeleteMediaListEntry.fromJson(Map<String, dynamic> json) => $DeleteMediaListEntryDeleteMediaListEntryFromJson(json);

	Map<String, dynamic> toJson() => $DeleteMediaListEntryDeleteMediaListEntryToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
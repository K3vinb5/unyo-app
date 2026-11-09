import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/anilist/delete_media_list_entry_entity.dart';

DeleteMediaListEntryEntity $DeleteMediaListEntryEntityFromJson(Map<String, dynamic> json) {
	final DeleteMediaListEntryEntity deleteMediaListEntryEntity = DeleteMediaListEntryEntity();
	final DeleteMediaListEntryDeleteMediaListEntry? deleteMediaListEntry = jsonConvert.convert<DeleteMediaListEntryDeleteMediaListEntry>(json['DeleteMediaListEntry']);
	if (deleteMediaListEntry != null) {
		deleteMediaListEntryEntity.deleteMediaListEntry = deleteMediaListEntry;
	}
	return deleteMediaListEntryEntity;
}

Map<String, dynamic> $DeleteMediaListEntryEntityToJson(DeleteMediaListEntryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['DeleteMediaListEntry'] = entity.deleteMediaListEntry.toJson();
	return data;
}

extension DeleteMediaListEntryEntityExtension on DeleteMediaListEntryEntity {
	DeleteMediaListEntryEntity copyWith({
	DeleteMediaListEntryDeleteMediaListEntry? deleteMediaListEntry,
	}) {
		return DeleteMediaListEntryEntity()
			..deleteMediaListEntry = deleteMediaListEntry ?? this.deleteMediaListEntry;
	}
}


DeleteMediaListEntryDeleteMediaListEntry $DeleteMediaListEntryDeleteMediaListEntryFromJson(Map<String, dynamic> json) {
	final DeleteMediaListEntryDeleteMediaListEntry deleteMediaListEntryDeleteMediaListEntry = DeleteMediaListEntryDeleteMediaListEntry();
	final bool? deleted = jsonConvert.convert<bool>(json['deleted']);
	if (deleted != null) {
		deleteMediaListEntryDeleteMediaListEntry.deleted = deleted;
	}
	return deleteMediaListEntryDeleteMediaListEntry;
}

Map<String, dynamic> $DeleteMediaListEntryDeleteMediaListEntryToJson(DeleteMediaListEntryDeleteMediaListEntry entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['deleted'] = entity.deleted;
	return data;
}

extension DeleteMediaListEntryDeleteMediaListEntryExtension on DeleteMediaListEntryDeleteMediaListEntry {
	DeleteMediaListEntryDeleteMediaListEntry copyWith({
	bool? deleted,
	}) {
		return DeleteMediaListEntryDeleteMediaListEntry()
			..deleted = deleted ?? this.deleted;
	}
}

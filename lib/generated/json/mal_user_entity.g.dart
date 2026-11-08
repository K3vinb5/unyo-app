import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/mal/mal_user_entity.dart';

MalUserEntity $MalUserEntityFromJson(Map<String, dynamic> json) {
	final MalUserEntity malUserEntity = MalUserEntity();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		malUserEntity.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		malUserEntity.name = name;
	}
	final String? picture = jsonConvert.convert<String>(json['picture']);
	if (picture != null) {
		malUserEntity.picture = picture;
	}
	return malUserEntity;
}

Map<String, dynamic> $MalUserEntityToJson(MalUserEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['picture'] = entity.picture;
	return data;
}

extension MalUserEntityExtension on MalUserEntity {
	MalUserEntity copyWith({
	int? id,
	String? name,
	String? picture,
	}) {
		return MalUserEntity()
			..id = id ?? this.id
			..name = name ?? this.name
			..picture = picture ?? this.picture;
	}
}

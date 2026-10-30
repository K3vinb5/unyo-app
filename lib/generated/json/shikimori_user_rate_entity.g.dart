import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_user_rate_entity.dart';

ShikimoriUserRateEntity $ShikimoriUserRateEntityFromJson(Map<String, dynamic> json) {
	final ShikimoriUserRateEntity shikimoriUserRateEntity = ShikimoriUserRateEntity();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		shikimoriUserRateEntity.id = id;
	}
	final int? userId = jsonConvert.convert<int>(json['user_id']);
	if (userId != null) {
		shikimoriUserRateEntity.userId = userId;
	}
	final int? targetId = jsonConvert.convert<int>(json['target_id']);
	if (targetId != null) {
		shikimoriUserRateEntity.targetId = targetId;
	}
	final String? targetType = jsonConvert.convert<String>(json['target_type']);
	if (targetType != null) {
		shikimoriUserRateEntity.targetType = targetType;
	}
	final int? score = jsonConvert.convert<int>(json['score']);
	if (score != null) {
		shikimoriUserRateEntity.score = score;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		shikimoriUserRateEntity.status = status;
	}
	final int? rewatches = jsonConvert.convert<int>(json['rewatches']);
	if (rewatches != null) {
		shikimoriUserRateEntity.rewatches = rewatches;
	}
	final int? episodes = jsonConvert.convert<int>(json['episodes']);
	if (episodes != null) {
		shikimoriUserRateEntity.episodes = episodes;
	}
	final int? volumes = jsonConvert.convert<int>(json['volumes']);
	if (volumes != null) {
		shikimoriUserRateEntity.volumes = volumes;
	}
	final int? chapters = jsonConvert.convert<int>(json['chapters']);
	if (chapters != null) {
		shikimoriUserRateEntity.chapters = chapters;
	}
	final String? text = jsonConvert.convert<String>(json['text']);
	if (text != null) {
		shikimoriUserRateEntity.text = text;
	}
	final String? textHtml = jsonConvert.convert<String>(json['text_html']);
	if (textHtml != null) {
		shikimoriUserRateEntity.textHtml = textHtml;
	}
	final String? createdAt = jsonConvert.convert<String>(json['created_at']);
	if (createdAt != null) {
		shikimoriUserRateEntity.createdAt = createdAt;
	}
	final String? updatedAt = jsonConvert.convert<String>(json['updated_at']);
	if (updatedAt != null) {
		shikimoriUserRateEntity.updatedAt = updatedAt;
	}
	return shikimoriUserRateEntity;
}

Map<String, dynamic> $ShikimoriUserRateEntityToJson(ShikimoriUserRateEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['user_id'] = entity.userId;
	data['target_id'] = entity.targetId;
	data['target_type'] = entity.targetType;
	data['score'] = entity.score;
	data['status'] = entity.status;
	data['rewatches'] = entity.rewatches;
	data['episodes'] = entity.episodes;
	data['volumes'] = entity.volumes;
	data['chapters'] = entity.chapters;
	data['text'] = entity.text;
	data['text_html'] = entity.textHtml;
	data['created_at'] = entity.createdAt;
	data['updated_at'] = entity.updatedAt;
	return data;
}

extension ShikimoriUserRateEntityExtension on ShikimoriUserRateEntity {
	ShikimoriUserRateEntity copyWith({
	int? id,
	int? userId,
	int? targetId,
	String? targetType,
	int? score,
	String? status,
	int? rewatches,
	int? episodes,
	int? volumes,
	int? chapters,
	String? text,
	String? textHtml,
	String? createdAt,
	String? updatedAt,
	}) {
		return ShikimoriUserRateEntity()
			..id = id ?? this.id
			..userId = userId ?? this.userId
			..targetId = targetId ?? this.targetId
			..targetType = targetType ?? this.targetType
			..score = score ?? this.score
			..status = status ?? this.status
			..rewatches = rewatches ?? this.rewatches
			..episodes = episodes ?? this.episodes
			..volumes = volumes ?? this.volumes
			..chapters = chapters ?? this.chapters
			..text = text ?? this.text
			..textHtml = textHtml ?? this.textHtml
			..createdAt = createdAt ?? this.createdAt
			..updatedAt = updatedAt ?? this.updatedAt;
	}
}

import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/shikimori_user_rate_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/shikimori_user_rate_entity.g.dart';

@JsonSerializable()
class ShikimoriUserRateEntity {
	late int id = 0;
	@JSONField(name: 'user_id')
	late int userId = 0;
	@JSONField(name: 'target_id')
	late int targetId = 0;
	@JSONField(name: 'target_type')
	late String targetType = '';
	late int score = 0;
	late String status = '';
	late int rewatches = 0;
	late int episodes = 0;
	late int volumes = 0;
	late int chapters = 0;
	late String text = '';
	@JSONField(name: 'text_html')
	late String textHtml = '';
	@JSONField(name: 'created_at')
	late String createdAt = '';
	@JSONField(name: 'updated_at')
	late String updatedAt = '';

	ShikimoriUserRateEntity();

	factory ShikimoriUserRateEntity.fromJson(Map<String, dynamic> json) => $ShikimoriUserRateEntityFromJson(json);

	Map<String, dynamic> toJson() => $ShikimoriUserRateEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/shikimori_token_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/shikimori_token_entity.g.dart';

@JsonSerializable()
class ShikimoriTokenEntity {
	@JSONField(name: 'access_token')
	late String accessToken = '';
	@JSONField(name: 'token_type')
	late String tokenType = '';
	@JSONField(name: 'expires_in')
	late int expiresIn = 0;
	@JSONField(name: 'refresh_token')
	late String refreshToken = '';
	late String scope = '';
	@JSONField(name: 'created_at')
	late int createdAt = 0;

	ShikimoriTokenEntity();

	factory ShikimoriTokenEntity.fromJson(Map<String, dynamic> json) => $ShikimoriTokenEntityFromJson(json);

	Map<String, dynamic> toJson() => $ShikimoriTokenEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/mal_token_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/mal_token_entity.g.dart';

@JsonSerializable()
class MalTokenEntity {
	@JSONField(name: 'token_type')
	late String tokenType = '';
	@JSONField(name: 'expires_in')
	late int expiresIn = 0;
	@JSONField(name: 'access_token')
	late String accessToken = '';
	@JSONField(name: 'refresh_token')
	late String refreshToken = '';

	MalTokenEntity();

	factory MalTokenEntity.fromJson(Map<String, dynamic> json) => $MalTokenEntityFromJson(json);

	Map<String, dynamic> toJson() => $MalTokenEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
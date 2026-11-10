import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/mal_user_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/mal_user_entity.g.dart';

/// `GET /users/@me` (WP #156): the account identity the login flow stores in
/// `MalUserModel`. `picture` is the avatar URL; `bannerImage` does not exist on
/// MAL, so the model keeps it empty.
@JsonSerializable()
class MalUserEntity {
	late int id = 0;
	late String name = '';
	late String picture = '';

	MalUserEntity();

	factory MalUserEntity.fromJson(Map<String, dynamic> json) => $MalUserEntityFromJson(json);

	Map<String, dynamic> toJson() => $MalUserEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

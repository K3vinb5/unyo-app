import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/shikimori_viewer_query_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/shikimori_viewer_query_entity.g.dart';

/// `data` payload of `{ currentUser { id nickname avatarUrl url lastOnlineAt } }`.
///
/// There is **no** `users(login:)` query on this schema (WP #64 §8), so the
/// viewer is the only way to learn who the token belongs to. Without a token the
/// server answers HTTP 200 with `{"data":{"currentUser":null}}`
/// (`raws/api/gql-currentuser-unauth.json`), which leaves this bean at its
/// defaults — an empty `id` is the "not logged in" signal.
@JsonSerializable()
class ShikimoriViewerQueryEntity {
	late ShikimoriViewerQueryEntityCurrentUser currentUser = ShikimoriViewerQueryEntityCurrentUser();

	ShikimoriViewerQueryEntity();

	factory ShikimoriViewerQueryEntity.fromJson(Map<String, dynamic> json) => $ShikimoriViewerQueryEntityFromJson(json);

	Map<String, dynamic> toJson() => $ShikimoriViewerQueryEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class ShikimoriViewerQueryEntityCurrentUser {
	late String id = '';
	late String nickname = '';
	late String avatarUrl = '';
	late String url = '';
	late String lastOnlineAt = '';

	ShikimoriViewerQueryEntityCurrentUser();

	factory ShikimoriViewerQueryEntityCurrentUser.fromJson(Map<String, dynamic> json) => $ShikimoriViewerQueryEntityCurrentUserFromJson(json);

	Map<String, dynamic> toJson() => $ShikimoriViewerQueryEntityCurrentUserToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

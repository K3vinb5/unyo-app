import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_viewer_query_entity.dart';

ShikimoriViewerQueryEntity $ShikimoriViewerQueryEntityFromJson(Map<String, dynamic> json) {
	final ShikimoriViewerQueryEntity shikimoriViewerQueryEntity = ShikimoriViewerQueryEntity();
	final ShikimoriViewerQueryEntityCurrentUser? currentUser = jsonConvert.convert<ShikimoriViewerQueryEntityCurrentUser>(json['currentUser']);
	if (currentUser != null) {
		shikimoriViewerQueryEntity.currentUser = currentUser;
	}
	return shikimoriViewerQueryEntity;
}

Map<String, dynamic> $ShikimoriViewerQueryEntityToJson(ShikimoriViewerQueryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['currentUser'] = entity.currentUser.toJson();
	return data;
}

extension ShikimoriViewerQueryEntityExtension on ShikimoriViewerQueryEntity {
	ShikimoriViewerQueryEntity copyWith({
	ShikimoriViewerQueryEntityCurrentUser? currentUser,
	}) {
		return ShikimoriViewerQueryEntity()
			..currentUser = currentUser ?? this.currentUser;
	}
}


ShikimoriViewerQueryEntityCurrentUser $ShikimoriViewerQueryEntityCurrentUserFromJson(Map<String, dynamic> json) {
	final ShikimoriViewerQueryEntityCurrentUser shikimoriViewerQueryEntityCurrentUser = ShikimoriViewerQueryEntityCurrentUser();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		shikimoriViewerQueryEntityCurrentUser.id = id;
	}
	final String? nickname = jsonConvert.convert<String>(json['nickname']);
	if (nickname != null) {
		shikimoriViewerQueryEntityCurrentUser.nickname = nickname;
	}
	final String? avatarUrl = jsonConvert.convert<String>(json['avatarUrl']);
	if (avatarUrl != null) {
		shikimoriViewerQueryEntityCurrentUser.avatarUrl = avatarUrl;
	}
	final String? url = jsonConvert.convert<String>(json['url']);
	if (url != null) {
		shikimoriViewerQueryEntityCurrentUser.url = url;
	}
	final String? lastOnlineAt = jsonConvert.convert<String>(json['lastOnlineAt']);
	if (lastOnlineAt != null) {
		shikimoriViewerQueryEntityCurrentUser.lastOnlineAt = lastOnlineAt;
	}
	return shikimoriViewerQueryEntityCurrentUser;
}

Map<String, dynamic> $ShikimoriViewerQueryEntityCurrentUserToJson(ShikimoriViewerQueryEntityCurrentUser entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['nickname'] = entity.nickname;
	data['avatarUrl'] = entity.avatarUrl;
	data['url'] = entity.url;
	data['lastOnlineAt'] = entity.lastOnlineAt;
	return data;
}

extension ShikimoriViewerQueryEntityCurrentUserExtension on ShikimoriViewerQueryEntityCurrentUser {
	ShikimoriViewerQueryEntityCurrentUser copyWith({
	String? id,
	String? nickname,
	String? avatarUrl,
	String? url,
	String? lastOnlineAt,
	}) {
		return ShikimoriViewerQueryEntityCurrentUser()
			..id = id ?? this.id
			..nickname = nickname ?? this.nickname
			..avatarUrl = avatarUrl ?? this.avatarUrl
			..url = url ?? this.url
			..lastOnlineAt = lastOnlineAt ?? this.lastOnlineAt;
	}
}

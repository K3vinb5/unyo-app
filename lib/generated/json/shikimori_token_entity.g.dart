import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_token_entity.dart';

ShikimoriTokenEntity $ShikimoriTokenEntityFromJson(Map<String, dynamic> json) {
	final ShikimoriTokenEntity shikimoriTokenEntity = ShikimoriTokenEntity();
	final String? accessToken = jsonConvert.convert<String>(json['access_token']);
	if (accessToken != null) {
		shikimoriTokenEntity.accessToken = accessToken;
	}
	final String? tokenType = jsonConvert.convert<String>(json['token_type']);
	if (tokenType != null) {
		shikimoriTokenEntity.tokenType = tokenType;
	}
	final int? expiresIn = jsonConvert.convert<int>(json['expires_in']);
	if (expiresIn != null) {
		shikimoriTokenEntity.expiresIn = expiresIn;
	}
	final String? refreshToken = jsonConvert.convert<String>(json['refresh_token']);
	if (refreshToken != null) {
		shikimoriTokenEntity.refreshToken = refreshToken;
	}
	final String? scope = jsonConvert.convert<String>(json['scope']);
	if (scope != null) {
		shikimoriTokenEntity.scope = scope;
	}
	final int? createdAt = jsonConvert.convert<int>(json['created_at']);
	if (createdAt != null) {
		shikimoriTokenEntity.createdAt = createdAt;
	}
	return shikimoriTokenEntity;
}

Map<String, dynamic> $ShikimoriTokenEntityToJson(ShikimoriTokenEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['access_token'] = entity.accessToken;
	data['token_type'] = entity.tokenType;
	data['expires_in'] = entity.expiresIn;
	data['refresh_token'] = entity.refreshToken;
	data['scope'] = entity.scope;
	data['created_at'] = entity.createdAt;
	return data;
}

extension ShikimoriTokenEntityExtension on ShikimoriTokenEntity {
	ShikimoriTokenEntity copyWith({
	String? accessToken,
	String? tokenType,
	int? expiresIn,
	String? refreshToken,
	String? scope,
	int? createdAt,
	}) {
		return ShikimoriTokenEntity()
			..accessToken = accessToken ?? this.accessToken
			..tokenType = tokenType ?? this.tokenType
			..expiresIn = expiresIn ?? this.expiresIn
			..refreshToken = refreshToken ?? this.refreshToken
			..scope = scope ?? this.scope
			..createdAt = createdAt ?? this.createdAt;
	}
}

import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/mal/mal_token_entity.dart';

MalTokenEntity $MalTokenEntityFromJson(Map<String, dynamic> json) {
	final MalTokenEntity malTokenEntity = MalTokenEntity();
	final String? tokenType = jsonConvert.convert<String>(json['token_type']);
	if (tokenType != null) {
		malTokenEntity.tokenType = tokenType;
	}
	final int? expiresIn = jsonConvert.convert<int>(json['expires_in']);
	if (expiresIn != null) {
		malTokenEntity.expiresIn = expiresIn;
	}
	final String? accessToken = jsonConvert.convert<String>(json['access_token']);
	if (accessToken != null) {
		malTokenEntity.accessToken = accessToken;
	}
	final String? refreshToken = jsonConvert.convert<String>(json['refresh_token']);
	if (refreshToken != null) {
		malTokenEntity.refreshToken = refreshToken;
	}
	return malTokenEntity;
}

Map<String, dynamic> $MalTokenEntityToJson(MalTokenEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['token_type'] = entity.tokenType;
	data['expires_in'] = entity.expiresIn;
	data['access_token'] = entity.accessToken;
	data['refresh_token'] = entity.refreshToken;
	return data;
}

extension MalTokenEntityExtension on MalTokenEntity {
	MalTokenEntity copyWith({
	String? tokenType,
	int? expiresIn,
	String? accessToken,
	String? refreshToken,
	}) {
		return MalTokenEntity()
			..tokenType = tokenType ?? this.tokenType
			..expiresIn = expiresIn ?? this.expiresIn
			..accessToken = accessToken ?? this.accessToken
			..refreshToken = refreshToken ?? this.refreshToken;
	}
}

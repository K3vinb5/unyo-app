//External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

//Internal dependencies
import 'package:unyo/data/adapters/adapters_names.dart' as names;
import 'package:unyo/data/adapters/adapters_types.dart' as types;
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

part 'mal_user_model.freezed.dart';
part 'mal_user_model.g.dart';

/// A MyAnimeList account (WP #156).
///
/// Mirrors [ShikimoriUserModel] so the login screen and the user drawer can
/// hold every account kind in one list, and carries the two facts MAL's OAuth2
/// needs that AniList's JWT already stores inside itself:
///
/// * `accessTokenExpiresAt` — the returned `expires_in` is trusted (docs say
///   1 h, historically drifted), so the expiry is stored next to the token
///   (ISO8601; empty means "unknown, treat as expired").
/// * `refreshToken` — refresh answers carry a new access token and (usually) a
///   new refresh token, so both are overwritten together by the auth service.
///
/// `bannerImage` is always empty: `GET /users/@me` has no banner field.
@freezed
@HiveType(typeId: types.malUserAdapterType, adapterName: names.malUserModelAdapterName)
abstract class MalUserModel with _$MalUserModel implements User {
  const MalUserModel._();

  const factory MalUserModel({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @SettingsConverter() @HiveField(2) required Settings settings,
    @HiveField(3) required String avatarImage,
    @HiveField(4) required String bannerImage,
    @HiveField(5) required String accessToken,
    @HiveField(6) required String refreshToken,
    @HiveField(7) required String accessTokenExpiresAt,
    @HiveField(8) required String profileUrl,
  }) = _MalUserModel;

  factory MalUserModel.fromJson(Map<String, dynamic> json) =>
      _$MalUserModelFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$MalUserModelToJson(this as _MalUserModel);
}

class MalUserModelConverter
    implements JsonConverter<User, Map<String, dynamic>> {
  const MalUserModelConverter();

  @override
  User fromJson(Map<String, dynamic> json) => MalUserModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(User object) =>
      (object as MalUserModel).toJson();
}

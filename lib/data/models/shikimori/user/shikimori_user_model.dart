//External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

//Internal dependencies
import 'package:unyo/data/adapters/adapters_names.dart' as names;
import 'package:unyo/data/adapters/adapters_types.dart' as types;
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

part 'shikimori_user_model.freezed.dart';
part 'shikimori_user_model.g.dart';

/// A Shikimori account (WP #64 subpart (c)).
///
/// Mirrors [AnilistUserModel] so the login screen and the user drawer can hold
/// both account kinds in one list, and adds the two facts Shikimori's OAuth
/// needs that AniList's JWT already carries inside itself:
///
/// * `accessTokenExpiresAt` — the access token lives **1 day**
///   (`raws/api/rest-oauth-guide-extracted.txt`), and there is no JWT to decode,
///   so the expiry is stored next to the token (ISO8601; empty means "unknown,
///   treat as expired").
/// * `refreshToken` — every refresh returns a **new access *and* a new refresh
///   token**, so both are overwritten together by the auth service.
///
/// `bannerImage` is always empty: `currentUser` has no banner field.
@freezed
@HiveType(typeId: types.shikimoriUserAdapterType, adapterName: names.shikimoriUserModelAdapterName)
abstract class ShikimoriUserModel with _$ShikimoriUserModel implements User {
  const ShikimoriUserModel._();

  const factory ShikimoriUserModel({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @SettingsConverter() @HiveField(2) required Settings settings,
    @HiveField(3) required String avatarImage,
    @HiveField(4) required String bannerImage,
    @HiveField(5) required String accessToken,
    @HiveField(6) required String refreshToken,
    @HiveField(7) required String accessTokenExpiresAt,
    @HiveField(8) required String profileUrl,
  }) = _ShikimoriUserModel;

  factory ShikimoriUserModel.fromJson(Map<String, dynamic> json) =>
      _$ShikimoriUserModelFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ShikimoriUserModelToJson(this as _ShikimoriUserModel);
}

class ShikimoriUserModelConverter
    implements JsonConverter<User, Map<String, dynamic>> {
  const ShikimoriUserModelConverter();

  @override
  User fromJson(Map<String, dynamic> json) => ShikimoriUserModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(User object) =>
      (object as ShikimoriUserModel).toJson();
}

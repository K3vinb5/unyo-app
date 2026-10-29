import 'package:unyo/core/services/api/dto/shikimori/shikimori_user_rate_entity.dart';
import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/shikimori_user_rate_list_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/shikimori_user_rate_list_entity.g.dart';

/// `GET /api/v2/user_rates?user_id=…&target_id=…&target_type=…` answers a
/// **top-level JSON array** of rates; `HttpService` wraps such a body as
/// `{"list": [...]}`, which is the field name here (same convention as
/// `ShikimoriCalendarQueryEntity`).
///
/// The endpoint takes no `status` filter requirement and always returns a list,
/// so "no entry for this title" is an empty [list], not a 404.
@JsonSerializable()
class ShikimoriUserRateListEntity {
	late List<ShikimoriUserRateEntity> list = [];

	ShikimoriUserRateListEntity();

	factory ShikimoriUserRateListEntity.fromJson(Map<String, dynamic> json) => $ShikimoriUserRateListEntityFromJson(json);

	Map<String, dynamic> toJson() => $ShikimoriUserRateListEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

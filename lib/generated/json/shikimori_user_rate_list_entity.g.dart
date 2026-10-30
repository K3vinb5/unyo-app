import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_user_rate_list_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_user_rate_entity.dart';

ShikimoriUserRateListEntity $ShikimoriUserRateListEntityFromJson(Map<String, dynamic> json) {
	final ShikimoriUserRateListEntity shikimoriUserRateListEntity = ShikimoriUserRateListEntity();
	final List<ShikimoriUserRateEntity>? list = (json['list'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<ShikimoriUserRateEntity>(e) as ShikimoriUserRateEntity).toList();
	if (list != null) {
		shikimoriUserRateListEntity.list = list;
	}
	return shikimoriUserRateListEntity;
}

Map<String, dynamic> $ShikimoriUserRateListEntityToJson(ShikimoriUserRateListEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['list'] =  entity.list.map((v) => v.toJson()).toList();
	return data;
}

extension ShikimoriUserRateListEntityExtension on ShikimoriUserRateListEntity {
	ShikimoriUserRateListEntity copyWith({
	List<ShikimoriUserRateEntity>? list,
	}) {
		return ShikimoriUserRateListEntity()
			..list = list ?? this.list;
	}
}

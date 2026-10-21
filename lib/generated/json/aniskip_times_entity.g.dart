import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/aniskip/aniskip_times_entity.dart';

AniskipTimesEntity $AniskipTimesEntityFromJson(Map<String, dynamic> json) {
	final AniskipTimesEntity aniskipTimesEntity = AniskipTimesEntity();
	final bool? found = jsonConvert.convert<bool>(json['found']);
	if (found != null) {
		aniskipTimesEntity.found = found;
	}
	final List<AniskipTimesResults>? results = (json['results'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AniskipTimesResults>(e) as AniskipTimesResults).toList();
	if (results != null) {
		aniskipTimesEntity.results = results;
	}
	final String? message = jsonConvert.convert<String>(json['message']);
	if (message != null) {
		aniskipTimesEntity.message = message;
	}
	final int? statusCode = jsonConvert.convert<int>(json['statusCode']);
	if (statusCode != null) {
		aniskipTimesEntity.statusCode = statusCode;
	}
	return aniskipTimesEntity;
}

Map<String, dynamic> $AniskipTimesEntityToJson(AniskipTimesEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['found'] = entity.found;
	data['results'] =  entity.results.map((v) => v.toJson()).toList();
	data['message'] = entity.message;
	data['statusCode'] = entity.statusCode;
	return data;
}

extension AniskipTimesEntityExtension on AniskipTimesEntity {
	AniskipTimesEntity copyWith({
	bool? found,
	List<AniskipTimesResults>? results,
	String? message,
	int? statusCode,
	}) {
		return AniskipTimesEntity()
			..found = found ?? this.found
			..results = results ?? this.results
			..message = message ?? this.message
			..statusCode = statusCode ?? this.statusCode;
	}
}


AniskipTimesResults $AniskipTimesResultsFromJson(Map<String, dynamic> json) {
	final AniskipTimesResults aniskipTimesResults = AniskipTimesResults();
	final AniskipTimesResultsInterval? interval = jsonConvert.convert<AniskipTimesResultsInterval>(json['interval']);
	if (interval != null) {
		aniskipTimesResults.interval = interval;
	}
	final String? skipType = jsonConvert.convert<String>(json['skipType']);
	if (skipType != null) {
		aniskipTimesResults.skipType = skipType;
	}
	final String? skipId = jsonConvert.convert<String>(json['skipId']);
	if (skipId != null) {
		aniskipTimesResults.skipId = skipId;
	}
	final double? episodeLength = jsonConvert.convert<double>(json['episodeLength']);
	if (episodeLength != null) {
		aniskipTimesResults.episodeLength = episodeLength;
	}
	return aniskipTimesResults;
}

Map<String, dynamic> $AniskipTimesResultsToJson(AniskipTimesResults entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['interval'] = entity.interval.toJson();
	data['skipType'] = entity.skipType;
	data['skipId'] = entity.skipId;
	data['episodeLength'] = entity.episodeLength;
	return data;
}

extension AniskipTimesResultsExtension on AniskipTimesResults {
	AniskipTimesResults copyWith({
	AniskipTimesResultsInterval? interval,
	String? skipType,
	String? skipId,
	double? episodeLength,
	}) {
		return AniskipTimesResults()
			..interval = interval ?? this.interval
			..skipType = skipType ?? this.skipType
			..skipId = skipId ?? this.skipId
			..episodeLength = episodeLength ?? this.episodeLength;
	}
}


AniskipTimesResultsInterval $AniskipTimesResultsIntervalFromJson(Map<String, dynamic> json) {
	final AniskipTimesResultsInterval aniskipTimesResultsInterval = AniskipTimesResultsInterval();
	final double? startTime = jsonConvert.convert<double>(json['startTime']);
	if (startTime != null) {
		aniskipTimesResultsInterval.startTime = startTime;
	}
	final double? endTime = jsonConvert.convert<double>(json['endTime']);
	if (endTime != null) {
		aniskipTimesResultsInterval.endTime = endTime;
	}
	return aniskipTimesResultsInterval;
}

Map<String, dynamic> $AniskipTimesResultsIntervalToJson(AniskipTimesResultsInterval entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['startTime'] = entity.startTime;
	data['endTime'] = entity.endTime;
	return data;
}

extension AniskipTimesResultsIntervalExtension on AniskipTimesResultsInterval {
	AniskipTimesResultsInterval copyWith({
	double? startTime,
	double? endTime,
	}) {
		return AniskipTimesResultsInterval()
			..startTime = startTime ?? this.startTime
			..endTime = endTime ?? this.endTime;
	}
}

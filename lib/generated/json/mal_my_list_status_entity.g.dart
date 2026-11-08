import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/mal/mal_my_list_status_entity.dart';

MalMyListStatusEntity $MalMyListStatusEntityFromJson(Map<String, dynamic> json) {
	final MalMyListStatusEntity malMyListStatusEntity = MalMyListStatusEntity();
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		malMyListStatusEntity.status = status;
	}
	final int? score = jsonConvert.convert<int>(json['score']);
	if (score != null) {
		malMyListStatusEntity.score = score;
	}
	final int? numEpisodesWatched = jsonConvert.convert<int>(json['num_episodes_watched']);
	if (numEpisodesWatched != null) {
		malMyListStatusEntity.numEpisodesWatched = numEpisodesWatched;
	}
	final bool? isRewatching = jsonConvert.convert<bool>(json['is_rewatching']);
	if (isRewatching != null) {
		malMyListStatusEntity.isRewatching = isRewatching;
	}
	final int? numTimesRewatched = jsonConvert.convert<int>(json['num_times_rewatched']);
	if (numTimesRewatched != null) {
		malMyListStatusEntity.numTimesRewatched = numTimesRewatched;
	}
	final int? numVolumesRead = jsonConvert.convert<int>(json['num_volumes_read']);
	if (numVolumesRead != null) {
		malMyListStatusEntity.numVolumesRead = numVolumesRead;
	}
	final int? numChaptersRead = jsonConvert.convert<int>(json['num_chapters_read']);
	if (numChaptersRead != null) {
		malMyListStatusEntity.numChaptersRead = numChaptersRead;
	}
	final bool? isRereading = jsonConvert.convert<bool>(json['is_rereading']);
	if (isRereading != null) {
		malMyListStatusEntity.isRereading = isRereading;
	}
	final int? numTimesReread = jsonConvert.convert<int>(json['num_times_reread']);
	if (numTimesReread != null) {
		malMyListStatusEntity.numTimesReread = numTimesReread;
	}
	final int? rewatchValue = jsonConvert.convert<int>(json['rewatch_value']);
	if (rewatchValue != null) {
		malMyListStatusEntity.rewatchValue = rewatchValue;
	}
	final int? rereadValue = jsonConvert.convert<int>(json['reread_value']);
	if (rereadValue != null) {
		malMyListStatusEntity.rereadValue = rereadValue;
	}
	final int? priority = jsonConvert.convert<int>(json['priority']);
	if (priority != null) {
		malMyListStatusEntity.priority = priority;
	}
	final List<String>? tags = (json['tags'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<String>(e) as String).toList();
	if (tags != null) {
		malMyListStatusEntity.tags = tags;
	}
	final String? comments = jsonConvert.convert<String>(json['comments']);
	if (comments != null) {
		malMyListStatusEntity.comments = comments;
	}
	final String? startDate = jsonConvert.convert<String>(json['start_date']);
	if (startDate != null) {
		malMyListStatusEntity.startDate = startDate;
	}
	final String? finishDate = jsonConvert.convert<String>(json['finish_date']);
	if (finishDate != null) {
		malMyListStatusEntity.finishDate = finishDate;
	}
	final String? updatedAt = jsonConvert.convert<String>(json['updated_at']);
	if (updatedAt != null) {
		malMyListStatusEntity.updatedAt = updatedAt;
	}
	return malMyListStatusEntity;
}

Map<String, dynamic> $MalMyListStatusEntityToJson(MalMyListStatusEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['status'] = entity.status;
	data['score'] = entity.score;
	data['num_episodes_watched'] = entity.numEpisodesWatched;
	data['is_rewatching'] = entity.isRewatching;
	data['num_times_rewatched'] = entity.numTimesRewatched;
	data['num_volumes_read'] = entity.numVolumesRead;
	data['num_chapters_read'] = entity.numChaptersRead;
	data['is_rereading'] = entity.isRereading;
	data['num_times_reread'] = entity.numTimesReread;
	data['rewatch_value'] = entity.rewatchValue;
	data['reread_value'] = entity.rereadValue;
	data['priority'] = entity.priority;
	data['tags'] =  entity.tags;
	data['comments'] = entity.comments;
	data['start_date'] = entity.startDate;
	data['finish_date'] = entity.finishDate;
	data['updated_at'] = entity.updatedAt;
	return data;
}

extension MalMyListStatusEntityExtension on MalMyListStatusEntity {
	MalMyListStatusEntity copyWith({
	String? status,
	int? score,
	int? numEpisodesWatched,
	bool? isRewatching,
	int? numTimesRewatched,
	int? numVolumesRead,
	int? numChaptersRead,
	bool? isRereading,
	int? numTimesReread,
	int? rewatchValue,
	int? rereadValue,
	int? priority,
	List<String>? tags,
	String? comments,
	String? startDate,
	String? finishDate,
	String? updatedAt,
	}) {
		return MalMyListStatusEntity()
			..status = status ?? this.status
			..score = score ?? this.score
			..numEpisodesWatched = numEpisodesWatched ?? this.numEpisodesWatched
			..isRewatching = isRewatching ?? this.isRewatching
			..numTimesRewatched = numTimesRewatched ?? this.numTimesRewatched
			..numVolumesRead = numVolumesRead ?? this.numVolumesRead
			..numChaptersRead = numChaptersRead ?? this.numChaptersRead
			..isRereading = isRereading ?? this.isRereading
			..numTimesReread = numTimesReread ?? this.numTimesReread
			..rewatchValue = rewatchValue ?? this.rewatchValue
			..rereadValue = rereadValue ?? this.rereadValue
			..priority = priority ?? this.priority
			..tags = tags ?? this.tags
			..comments = comments ?? this.comments
			..startDate = startDate ?? this.startDate
			..finishDate = finishDate ?? this.finishDate
			..updatedAt = updatedAt ?? this.updatedAt;
	}
}


MalMyListStatusMediaEntity $MalMyListStatusMediaEntityFromJson(Map<String, dynamic> json) {
	final MalMyListStatusMediaEntity malMyListStatusMediaEntity = MalMyListStatusMediaEntity();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		malMyListStatusMediaEntity.id = id;
	}
	final String? title = jsonConvert.convert<String>(json['title']);
	if (title != null) {
		malMyListStatusMediaEntity.title = title;
	}
	final MalMyListStatusEntity? myListStatus = jsonConvert.convert<MalMyListStatusEntity>(json['my_list_status']);
	if (myListStatus != null) {
		malMyListStatusMediaEntity.myListStatus = myListStatus;
	}
	return malMyListStatusMediaEntity;
}

Map<String, dynamic> $MalMyListStatusMediaEntityToJson(MalMyListStatusMediaEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['title'] = entity.title;
	data['my_list_status'] = entity.myListStatus.toJson();
	return data;
}

extension MalMyListStatusMediaEntityExtension on MalMyListStatusMediaEntity {
	MalMyListStatusMediaEntity copyWith({
	int? id,
	String? title,
	MalMyListStatusEntity? myListStatus,
	}) {
		return MalMyListStatusMediaEntity()
			..id = id ?? this.id
			..title = title ?? this.title
			..myListStatus = myListStatus ?? this.myListStatus;
	}
}

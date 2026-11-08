import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/mal_my_list_status_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/mal_my_list_status_entity.g.dart';

/// The `my_list_status` object (WP #156) as returned by `PUT
/// /{anime|manga}/{id}/my_list_status`, by `GET /{kind}/{id}?fields=my_list_status`,
/// and by every `list_status` on a user-list node.
///
/// The response keys differ **per kind** and from the request keys
/// (`research/unyo-156-mal-tracker-proof/SPEC.md` §3):
///
/// * request `num_watched_episodes` ↔ response `num_episodes_watched` (anime);
/// * manga answers `num_volumes_read` + `num_chapters_read` and no episode
///   counter;
/// * `is_rewatching`/`num_times_rewatched` (anime) ↔ `is_rereading`/
///   `num_times_reread` (manga).
///
/// One class covers both answers: the kind that lacks a field simply leaves the
/// default in place.
@JsonSerializable()
class MalMyListStatusEntity {
	late String status = '';
	late int score = 0;
	@JSONField(name: 'num_episodes_watched')
	late int numEpisodesWatched = 0;
	@JSONField(name: 'is_rewatching')
	late bool isRewatching = false;
	@JSONField(name: 'num_times_rewatched')
	late int numTimesRewatched = 0;
	@JSONField(name: 'num_volumes_read')
	late int numVolumesRead = 0;
	@JSONField(name: 'num_chapters_read')
	late int numChaptersRead = 0;
	@JSONField(name: 'is_rereading')
	late bool isRereading = false;
	@JSONField(name: 'num_times_reread')
	late int numTimesReread = 0;
	@JSONField(name: 'rewatch_value')
	late int rewatchValue = 0;
	@JSONField(name: 'reread_value')
	late int rereadValue = 0;
	late int priority = 0;
	late List<String> tags = [];
	late String comments = '';
	@JSONField(name: 'start_date')
	late String startDate = '';
	@JSONField(name: 'finish_date')
	late String finishDate = '';
	@JSONField(name: 'updated_at')
	late String updatedAt = '';

	MalMyListStatusEntity();

	factory MalMyListStatusEntity.fromJson(Map<String, dynamic> json) => $MalMyListStatusEntityFromJson(json);

	Map<String, dynamic> toJson() => $MalMyListStatusEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

/// `GET /{anime|manga}/{id}?fields=my_list_status` (WP #156): the media node
/// with the caller's entry attached. This is the only single-entry read MAL
/// exposes (there is no `GET /my_list_status`); when the user has no entry the
/// `my_list_status` key is **absent** and the default-constructed child is
/// detected by its empty `status`.
@JsonSerializable()
class MalMyListStatusMediaEntity {
	late int id = 0;
	late String title = '';
	@JSONField(name: 'my_list_status')
	late MalMyListStatusEntity myListStatus = MalMyListStatusEntity();

	MalMyListStatusMediaEntity();

	factory MalMyListStatusMediaEntity.fromJson(Map<String, dynamic> json) => $MalMyListStatusMediaEntityFromJson(json);

	Map<String, dynamic> toJson() => $MalMyListStatusMediaEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

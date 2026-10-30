import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/shikimori_calendar_query_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/shikimori_calendar_query_entity.g.dart';

@JsonSerializable()
class ShikimoriCalendarQueryEntity {
	late List<ShikimoriCalendarQueryList> list = [];

	ShikimoriCalendarQueryEntity();

	factory ShikimoriCalendarQueryEntity.fromJson(Map<String, dynamic> json) => $ShikimoriCalendarQueryEntityFromJson(json);

	Map<String, dynamic> toJson() => $ShikimoriCalendarQueryEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class ShikimoriCalendarQueryList {
	@JSONField(name: 'next_episode')
	late int nextEpisode = 0;
	@JSONField(name: 'next_episode_at')
	late String nextEpisodeAt = '';
	late int duration = 0;
	late ShikimoriCalendarQueryListAnime anime = ShikimoriCalendarQueryListAnime();

	ShikimoriCalendarQueryList();

	factory ShikimoriCalendarQueryList.fromJson(Map<String, dynamic> json) => $ShikimoriCalendarQueryListFromJson(json);

	Map<String, dynamic> toJson() => $ShikimoriCalendarQueryListToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class ShikimoriCalendarQueryListAnime {
	late int id = 0;
	late String name = '';
	late String russian = '';
	late ShikimoriCalendarQueryListAnimeImage image = ShikimoriCalendarQueryListAnimeImage();
	late String url = '';
	late String kind = '';
	late String score = '';
	late String status = '';
	late int episodes = 0;
	@JSONField(name: 'episodes_aired')
	late int episodesAired = 0;
	@JSONField(name: 'aired_on')
	late String airedOn = '';
	/// `null` when the show has not finished; a nullable field must not be
	/// `late`, otherwise a JSON `null` leaves it uninitialized.
	@JSONField(name: 'released_on')
	String? releasedOn;

	ShikimoriCalendarQueryListAnime();

	factory ShikimoriCalendarQueryListAnime.fromJson(Map<String, dynamic> json) => $ShikimoriCalendarQueryListAnimeFromJson(json);

	Map<String, dynamic> toJson() => $ShikimoriCalendarQueryListAnimeToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class ShikimoriCalendarQueryListAnimeImage {
	late String original = '';
	late String preview = '';
	late String x96 = '';
	late String x48 = '';

	ShikimoriCalendarQueryListAnimeImage();

	factory ShikimoriCalendarQueryListAnimeImage.fromJson(Map<String, dynamic> json) => $ShikimoriCalendarQueryListAnimeImageFromJson(json);

	Map<String, dynamic> toJson() => $ShikimoriCalendarQueryListAnimeImageToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
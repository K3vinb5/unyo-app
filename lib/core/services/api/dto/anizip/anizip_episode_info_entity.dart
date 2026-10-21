import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/anizip_episode_info_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/anizip_episode_info_entity.g.dart';

@JsonSerializable()
class AnizipEpisodeInfoEntity {
	late int tvdbShowId = 0;
	late int tvdbId = 0;
	late int seasonNumber = 0;
	late int episodeNumber = 0;
	late int absoluteEpisodeNumber = 0;
	late AnizipEpisodeInfoTitle title = AnizipEpisodeInfoTitle();
	late String airDate = '';
	late String airDateUtc = '';
	late int runtime = 0;
	late String overview = '';
	late String image = '';
	late String episode = '';
	late int anidbEid = 0;
	late int length = 0;
	late String airdate = '';
	late String rating = '';
	late String summary = '';

	AnizipEpisodeInfoEntity();

	factory AnizipEpisodeInfoEntity.fromJson(Map<String, dynamic> json) => $AnizipEpisodeInfoEntityFromJson(json);

	Map<String, dynamic> toJson() => $AnizipEpisodeInfoEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AnizipEpisodeInfoTitle {
	late String ja = '';
	late String en = '';
	late String fr = '';
	@JSONField(name: "x-jat")
	late String xJat = '';

	AnizipEpisodeInfoTitle();

	factory AnizipEpisodeInfoTitle.fromJson(Map<String, dynamic> json) => $AnizipEpisodeInfoTitleFromJson(json);

	Map<String, dynamic> toJson() => $AnizipEpisodeInfoTitleToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
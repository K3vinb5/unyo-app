import 'package:unyo/generated/json/base/json_field.dart';
import 'package:unyo/generated/json/github_release_entity.g.dart';
import 'dart:convert';
export 'package:unyo/generated/json/github_release_entity.g.dart';

@JsonSerializable()
class GithubReleaseEntity {
	@JSONField(name: 'tag_name')
	late String tagName;
	late String name;
	@JSONField(name: 'html_url')
	late String htmlUrl;
	late String body;
	late bool prerelease;
	@JSONField(name: 'published_at')
	late String publishedAt;

	GithubReleaseEntity();

	factory GithubReleaseEntity.fromJson(Map<String, dynamic> json) => $GithubReleaseEntityFromJson(json);

	Map<String, dynamic> toJson() => $GithubReleaseEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
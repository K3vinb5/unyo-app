import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/github/github_release_entity.dart';

GithubReleaseEntity $GithubReleaseEntityFromJson(Map<String, dynamic> json) {
	final GithubReleaseEntity githubReleaseEntity = GithubReleaseEntity();
	final String? tagName = jsonConvert.convert<String>(json['tag_name']);
	if (tagName != null) {
		githubReleaseEntity.tagName = tagName;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		githubReleaseEntity.name = name;
	}
	final String? htmlUrl = jsonConvert.convert<String>(json['html_url']);
	if (htmlUrl != null) {
		githubReleaseEntity.htmlUrl = htmlUrl;
	}
	final String? body = jsonConvert.convert<String>(json['body']);
	if (body != null) {
		githubReleaseEntity.body = body;
	}
	final bool? prerelease = jsonConvert.convert<bool>(json['prerelease']);
	if (prerelease != null) {
		githubReleaseEntity.prerelease = prerelease;
	}
	final String? publishedAt = jsonConvert.convert<String>(json['published_at']);
	if (publishedAt != null) {
		githubReleaseEntity.publishedAt = publishedAt;
	}
	return githubReleaseEntity;
}

Map<String, dynamic> $GithubReleaseEntityToJson(GithubReleaseEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['tag_name'] = entity.tagName;
	data['name'] = entity.name;
	data['html_url'] = entity.htmlUrl;
	data['body'] = entity.body;
	data['prerelease'] = entity.prerelease;
	data['published_at'] = entity.publishedAt;
	return data;
}

extension GithubReleaseEntityExtension on GithubReleaseEntity {
	GithubReleaseEntity copyWith({
	String? tagName,
	String? name,
	String? htmlUrl,
	String? body,
	bool? prerelease,
	String? publishedAt,
	}) {
		return GithubReleaseEntity()
			..tagName = tagName ?? this.tagName
			..name = name ?? this.name
			..htmlUrl = htmlUrl ?? this.htmlUrl
			..body = body ?? this.body
			..prerelease = prerelease ?? this.prerelease
			..publishedAt = publishedAt ?? this.publishedAt;
	}
}

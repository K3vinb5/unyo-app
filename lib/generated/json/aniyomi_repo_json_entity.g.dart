import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/extensions/aniyomi_repo_json_entity.dart';

AniyomiRepoJsonEntity $AniyomiRepoJsonEntityFromJson(Map<String, dynamic> json) {
	final AniyomiRepoJsonEntity aniyomiRepoJsonEntity = AniyomiRepoJsonEntity();
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		aniyomiRepoJsonEntity.name = name;
	}
	final String? pkg = jsonConvert.convert<String>(json['pkg']);
	if (pkg != null) {
		aniyomiRepoJsonEntity.pkg = pkg;
	}
	final String? apk = jsonConvert.convert<String>(json['apk']);
	if (apk != null) {
		aniyomiRepoJsonEntity.apk = apk;
	}
	final String? lang = jsonConvert.convert<String>(json['lang']);
	if (lang != null) {
		aniyomiRepoJsonEntity.lang = lang;
	}
	final double? code = jsonConvert.convert<double>(json['code']);
	if (code != null) {
		aniyomiRepoJsonEntity.code = code;
	}
	final String? version = jsonConvert.convert<String>(json['version']);
	if (version != null) {
		aniyomiRepoJsonEntity.version = version;
	}
	final double? nsfw = jsonConvert.convert<double>(json['nsfw']);
	if (nsfw != null) {
		aniyomiRepoJsonEntity.nsfw = nsfw;
	}
	final List<AniyomiRepoJsonSources>? sources = (json['sources'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<AniyomiRepoJsonSources>(e) as AniyomiRepoJsonSources).toList();
	if (sources != null) {
		aniyomiRepoJsonEntity.sources = sources;
	}
	return aniyomiRepoJsonEntity;
}

Map<String, dynamic> $AniyomiRepoJsonEntityToJson(AniyomiRepoJsonEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['name'] = entity.name;
	data['pkg'] = entity.pkg;
	data['apk'] = entity.apk;
	data['lang'] = entity.lang;
	data['code'] = entity.code;
	data['version'] = entity.version;
	data['nsfw'] = entity.nsfw;
	data['sources'] =  entity.sources.map((v) => v.toJson()).toList();
	return data;
}

extension AniyomiRepoJsonEntityExtension on AniyomiRepoJsonEntity {
	AniyomiRepoJsonEntity copyWith({
	String? name,
	String? pkg,
	String? apk,
	String? lang,
	double? code,
	String? version,
	double? nsfw,
	List<AniyomiRepoJsonSources>? sources,
	}) {
		return AniyomiRepoJsonEntity()
			..name = name ?? this.name
			..pkg = pkg ?? this.pkg
			..apk = apk ?? this.apk
			..lang = lang ?? this.lang
			..code = code ?? this.code
			..version = version ?? this.version
			..nsfw = nsfw ?? this.nsfw
			..sources = sources ?? this.sources;
	}
}


AniyomiRepoJsonSources $AniyomiRepoJsonSourcesFromJson(Map<String, dynamic> json) {
	final AniyomiRepoJsonSources aniyomiRepoJsonSources = AniyomiRepoJsonSources();
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		aniyomiRepoJsonSources.name = name;
	}
	final String? lang = jsonConvert.convert<String>(json['lang']);
	if (lang != null) {
		aniyomiRepoJsonSources.lang = lang;
	}
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		aniyomiRepoJsonSources.id = id;
	}
	final String? baseUrl = jsonConvert.convert<String>(json['baseUrl']);
	if (baseUrl != null) {
		aniyomiRepoJsonSources.baseUrl = baseUrl;
	}
	return aniyomiRepoJsonSources;
}

Map<String, dynamic> $AniyomiRepoJsonSourcesToJson(AniyomiRepoJsonSources entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['name'] = entity.name;
	data['lang'] = entity.lang;
	data['id'] = entity.id;
	data['baseUrl'] = entity.baseUrl;
	return data;
}

extension AniyomiRepoJsonSourcesExtension on AniyomiRepoJsonSources {
	AniyomiRepoJsonSources copyWith({
	String? name,
	String? lang,
	String? id,
	String? baseUrl,
	}) {
		return AniyomiRepoJsonSources()
			..name = name ?? this.name
			..lang = lang ?? this.lang
			..id = id ?? this.id
			..baseUrl = baseUrl ?? this.baseUrl;
	}
}

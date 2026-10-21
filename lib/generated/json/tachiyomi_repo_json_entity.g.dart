import 'package:unyo/generated/json/base/json_convert_content.dart';
import 'package:unyo/core/services/api/dto/extensions/tachiyomi_repo_json_entity.dart';

TachiyomiRepoJsonEntity $TachiyomiRepoJsonEntityFromJson(Map<String, dynamic> json) {
	final TachiyomiRepoJsonEntity tachiyomiRepoJsonEntity = TachiyomiRepoJsonEntity();
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		tachiyomiRepoJsonEntity.name = name;
	}
	final String? pkg = jsonConvert.convert<String>(json['pkg']);
	if (pkg != null) {
		tachiyomiRepoJsonEntity.pkg = pkg;
	}
	final String? apk = jsonConvert.convert<String>(json['apk']);
	if (apk != null) {
		tachiyomiRepoJsonEntity.apk = apk;
	}
	final String? lang = jsonConvert.convert<String>(json['lang']);
	if (lang != null) {
		tachiyomiRepoJsonEntity.lang = lang;
	}
	final double? code = jsonConvert.convert<double>(json['code']);
	if (code != null) {
		tachiyomiRepoJsonEntity.code = code;
	}
	final String? version = jsonConvert.convert<String>(json['version']);
	if (version != null) {
		tachiyomiRepoJsonEntity.version = version;
	}
	final double? nsfw = jsonConvert.convert<double>(json['nsfw']);
	if (nsfw != null) {
		tachiyomiRepoJsonEntity.nsfw = nsfw;
	}
	final List<TachiyomiRepoJsonSources>? sources = (json['sources'] as List<dynamic>?)?.map(
	(e) => jsonConvert.convert<TachiyomiRepoJsonSources>(e) as TachiyomiRepoJsonSources).toList();
	if (sources != null) {
		tachiyomiRepoJsonEntity.sources = sources;
	}
	return tachiyomiRepoJsonEntity;
}

Map<String, dynamic> $TachiyomiRepoJsonEntityToJson(TachiyomiRepoJsonEntity entity) {
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

extension TachiyomiRepoJsonEntityExtension on TachiyomiRepoJsonEntity {
	TachiyomiRepoJsonEntity copyWith({
	String? name,
	String? pkg,
	String? apk,
	String? lang,
	double? code,
	String? version,
	double? nsfw,
	List<TachiyomiRepoJsonSources>? sources,
	}) {
		return TachiyomiRepoJsonEntity()
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


TachiyomiRepoJsonSources $TachiyomiRepoJsonSourcesFromJson(Map<String, dynamic> json) {
	final TachiyomiRepoJsonSources tachiyomiRepoJsonSources = TachiyomiRepoJsonSources();
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		tachiyomiRepoJsonSources.name = name;
	}
	final String? lang = jsonConvert.convert<String>(json['lang']);
	if (lang != null) {
		tachiyomiRepoJsonSources.lang = lang;
	}
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		tachiyomiRepoJsonSources.id = id;
	}
	final String? baseUrl = jsonConvert.convert<String>(json['baseUrl']);
	if (baseUrl != null) {
		tachiyomiRepoJsonSources.baseUrl = baseUrl;
	}
	return tachiyomiRepoJsonSources;
}

Map<String, dynamic> $TachiyomiRepoJsonSourcesToJson(TachiyomiRepoJsonSources entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['name'] = entity.name;
	data['lang'] = entity.lang;
	data['id'] = entity.id;
	data['baseUrl'] = entity.baseUrl;
	return data;
}

extension TachiyomiRepoJsonSourcesExtension on TachiyomiRepoJsonSources {
	TachiyomiRepoJsonSources copyWith({
	String? name,
	String? lang,
	String? id,
	String? baseUrl,
	}) {
		return TachiyomiRepoJsonSources()
			..name = name ?? this.name
			..lang = lang ?? this.lang
			..id = id ?? this.id
			..baseUrl = baseUrl ?? this.baseUrl;
	}
}

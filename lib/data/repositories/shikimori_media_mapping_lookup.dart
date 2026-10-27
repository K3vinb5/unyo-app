// External dependencies
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/graphql/graphql_response.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/services/media_id_resolver.dart';

/// Query used both for the pivot probe (`ids`) and the heuristic title search
/// (`search`). `animes` covers anime; the manga leg lands with WP #64.
const String shikimoriMediaMappingQuery = '''
query MediaMapping(\$ids: String, \$search: String, \$limit: PositiveInt) {
  animes(ids: \$ids, search: \$search, limit: \$limit) {
    id
    malId
    name
    russian
    english
    kind
    airedOn {
      year
    }
  }
}
''';

/// One `animes` row reduced to what the mapping chain needs.
class ShikimoriMediaMappingEntry {
  final String id;
  final String? malId;
  final String title;
  final String kind;
  final int? year;

  const ShikimoriMediaMappingEntry({
    required this.id,
    required this.title,
    required this.kind,
    this.malId,
    this.year,
  });

  factory ShikimoriMediaMappingEntry.fromJson(Map<String, dynamic> json) {
    final Object? airedOn = json['airedOn'];
    final Object? rawYear = airedOn is Map ? airedOn['year'] : null;
    final String? rawMalId = json['malId']?.toString();
    return ShikimoriMediaMappingEntry(
      id: '${json['id'] ?? ''}',
      malId: rawMalId == null || rawMalId.isEmpty || rawMalId == 'null' ? null : rawMalId,
      title: '${json['name'] ?? json['english'] ?? json['russian'] ?? ''}',
      kind: '${json['kind'] ?? ''}',
      year: rawYear == null ? null : int.tryParse('$rawYear'),
    );
  }

  static const Set<String> _mangaKinds = <String>{
    'manga',
    'manhwa',
    'manhua',
    'one_shot',
    'doujin',
    'light_novel',
    'novel',
  };

  bool get isManga => _mangaKinds.contains(kind);

  MediaLinkCandidate toCandidate() => MediaLinkCandidate(
        service: Service.shikimori,
        nativeId: id,
        malId: malId == null ? null : int.tryParse(malId!),
        title: title,
        year: year,
        format: kind,
        isAnime: !isManga,
      );
}

class ShikimoriMediaMappingResponse {
  final List<ShikimoriMediaMappingEntry> animes;

  const ShikimoriMediaMappingResponse({required this.animes});

  factory ShikimoriMediaMappingResponse.fromJson(Map<String, dynamic> json) {
    final Object? animes = json['animes'];
    if (animes is! List) return const ShikimoriMediaMappingResponse(animes: <ShikimoriMediaMappingEntry>[]);
    return ShikimoriMediaMappingResponse(
      animes: animes
          .whereType<Map>()
          .map((entry) => ShikimoriMediaMappingEntry.fromJson(Map<String, dynamic>.from(entry)))
          .where((entry) => entry.id.isNotEmpty)
          .toList(),
    );
  }
}

/// Target-provider queries against Shikimori's GraphQL API.
///
/// Shikimori's `malId` is only accepted after verifying it against the record
/// the API returned: the native id is never assumed to be the MAL id even
/// though they happen to match on MAL-linked entries today.
class ShikimoriMediaMappingLookup implements MediaMappingLookup {
  final GraphQLService _graphQLService = sl<GraphQLService>(
    instanceName: config.shikimoriGraphQlService,
  );
  final Logger _logger = sl<Logger>();

  @override
  Future<MediaLinkCandidate?> lookupByMalId(Service target, int malId) async {
    if (target != Service.shikimori) return null;
    final List<ShikimoriMediaMappingEntry> entries = await _query(
      variables: <String, dynamic>{'ids': "$malId", 'limit': 5},
    );
    for (final ShikimoriMediaMappingEntry entry in entries) {
      final int? recordMalId = entry.malId == null ? null : int.tryParse(entry.malId!);
      if (recordMalId == malId) return entry.toCandidate();
    }
    if (entries.isNotEmpty) {
      _logger.w("Shikimori probe for MAL $malId returned ${entries.first.id} whose malId field is ${entries.first.malId}, refusing the guess");
    }
    return null;
  }

  @override
  Future<List<MediaLinkCandidate>> searchCandidates(Service target, MediaLinkQuery query) async {
    if (target != Service.shikimori) return const <MediaLinkCandidate>[];
    if (query.title.trim().isEmpty) return const <MediaLinkCandidate>[];
    final List<ShikimoriMediaMappingEntry> entries = await _query(
      variables: <String, dynamic>{'search': query.title, 'limit': MediaIdResolver.maxTitleSearchCandidates},
    );
    return entries
        .map((entry) => entry.toCandidate())
        .where((candidate) => candidate.isAnime == query.isAnime)
        .toList();
  }

  Future<List<ShikimoriMediaMappingEntry>> _query({required Map<String, dynamic> variables}) async {
    try {
      final ApiGraphQLResponse<ShikimoriMediaMappingResponse> response =
          await _graphQLService.query<ShikimoriMediaMappingResponse>(
        query: shikimoriMediaMappingQuery,
        fromJson: ShikimoriMediaMappingResponse.fromJson,
        variables: variables,
        ignoreCache: true,
      );
      if (response.errors != null && response.errors!.isNotEmpty) {
        _logger.w("Shikimori mapping query failed: ${response.errors!.first.message}");
        return const <ShikimoriMediaMappingEntry>[];
      }
      return response.data.animes;
    } catch (e) {
      _logger.w("Shikimori mapping query failed: $e");
      return const <ShikimoriMediaMappingEntry>[];
    }
  }
}

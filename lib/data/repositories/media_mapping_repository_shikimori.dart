// External dependencies
import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_mapping_query_entity.dart';
import 'package:unyo/core/services/api/graphql/graphql_response.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/graphql/queries/shikimori_queries.dart' as shikimori_queries;
import 'package:unyo/core/services/media/media_id_service.dart';
import 'package:unyo/core/services/media/media_link_candidate.dart';

/// Shikimori leg of the MAL pivot.
///
/// Shikimori's `malId` is only accepted after verifying it against the record
/// the API returned: the native id is never assumed to be the MAL id even
/// though they happen to match on MAL-linked entries today.
class MediaMappingRepositoryShikimori implements MediaMappingLookup {
  final GraphQLService _shikimoriGraphQLService = sl<GraphQLService>(
    instanceName: config.shikimoriGraphQlService,
  );
  final Logger _logger = sl<Logger>();

  /// Every Shikimori request carries the shared header map (User-Agent).
  Map<String, String> get _requestHeaders => config.shikimoriRequestHeaders;

  @override
  Future<MediaLinkCandidate?> lookupByMalId(Service target, int malId) async {
    if (target != Service.shikimori) return null;
    final List<AnimeMappingQueryAnimes> animes = await _animes(<String, dynamic>{'ids': '$malId', 'limit': 5});
    final MediaLinkCandidate? verified =
        animes.map(_toCandidate).where((candidate) => candidate.malId == malId).firstOrNull;
    if (verified == null && animes.isNotEmpty) {
      _logger.w(
        "Shikimori probe for MAL $malId returned ${animes.first.id} whose malId is ${animes.first.malId}, refusing the guess",
      );
    }
    return verified;
  }

  @override
  Future<List<MediaLinkCandidate>> searchCandidates(Service target, String title) async {
    if (target != Service.shikimori || title.trim().isEmpty) return const <MediaLinkCandidate>[];
    final List<AnimeMappingQueryAnimes> animes = await _animes(<String, dynamic>{
      'search': title,
      'limit': MediaIdService.maxTitleSearchCandidates,
    });
    return animes.map(_toCandidate).toList();
  }

  MediaLinkCandidate _toCandidate(AnimeMappingQueryAnimes anime) => MediaLinkCandidate(
        service: Service.shikimori,
        nativeId: anime.id,
        malId: int.tryParse(anime.malId),
        title: anime.name.isNotEmpty ? anime.name : (anime.english.isNotEmpty ? anime.english : anime.russian),
        year: anime.airedOn.year > 0 ? anime.airedOn.year : null,
        format: anime.kind,
      );

  /// A mapping miss must degrade to the user-provider fallback, never surface as
  /// an error: the details page still has something to render.
  Future<List<AnimeMappingQueryAnimes>> _animes(Map<String, dynamic> variables) async {
    try {
      ApiGraphQLResponse<AnimeMappingQueryEntity> response = await _shikimoriGraphQLService
          .query<AnimeMappingQueryEntity>(
        query: shikimori_queries.animeMappingQuery,
        fromJson: AnimeMappingQueryEntity.fromJson,
        variables: variables,
        headers: _requestHeaders,
        ignoreCache: true,
      );
      if (response.errors != null && response.errors!.isNotEmpty) {
        _logger.w("Shikimori mapping query failed: ${response.errors!.first.message}");
        return const <AnimeMappingQueryAnimes>[];
      }
      return response.data.animes;
    } catch (e) {
      _logger.w("Shikimori mapping query failed: $e");
      return const <AnimeMappingQueryAnimes>[];
    }
  }
}

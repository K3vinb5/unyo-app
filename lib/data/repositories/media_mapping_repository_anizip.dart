// External dependencies
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/dto/anizip/anizip_id_mappings_entity.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/media/media_id_service.dart';

/// AniZip leg of the MAL pivot.
class MediaMappingRepositoryAnizip implements AniZipIdLookup {
  final HttpService _httpService = sl<HttpService>();
  final Logger _logger = sl<Logger>();

  @override
  Future<int?> malIdForAnilistId(int anilistId) async {
    final AnizipIdMappingsMappings? mappings = await _mappings(
      'anilist_id=$anilistId',
      "AniList $anilistId",
    );
    final int malId = mappings?.malId ?? 0;
    if (malId <= 0) return null;
    return malId;
  }

  @override
  Future<int?> anilistIdForMalId(int malId) async {
    final AnizipIdMappingsMappings? mappings = await _mappings(
      'mal_id=$malId',
      "MAL $malId",
    );
    final int anilistId = mappings?.anilistId ?? 0;
    if (anilistId <= 0) return null;
    return anilistId;
  }

  /// One `/mappings` call; the payload carries both id directions, so the two
  /// public methods differ only in the query field and the field they read.
  Future<AnizipIdMappingsMappings?> _mappings(String query, String label) async {
    _logger.i("Resolving the AniZip mapping of $label");
    try {
      ApiResponse<AnizipIdMappingsEntity> response = await _httpService.get<AnizipIdMappingsEntity>(
        "${config.anizipBaseEndpoint}/mappings?$query",
        fromJson: AnizipIdMappingsEntity.fromJson,
      );
      if (response.statusCode > 299) {
        _logger.e("AniZip mapping lookup failed for $label: status ${response.statusCode}");
        return null;
      }
      return response.data.mappings;
    } catch (e) {
      // A transient AniZip failure (network, timeout, bad payload) must degrade
      // to a mapping miss, not abort the details flow: the caller's chain still
      // has the title search and the unresolved fallback to fall back on.
      _logger.w("AniZip mapping lookup failed for $label: $e");
      return null;
    }
  }
}

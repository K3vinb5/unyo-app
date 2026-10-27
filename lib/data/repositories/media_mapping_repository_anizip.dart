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
    _logger.i("Resolving the MAL pivot of AniList $anilistId through AniZip");
    try {
      ApiResponse<AnizipIdMappingsEntity> response = await _httpService.get<AnizipIdMappingsEntity>(
        "${config.anizipBaseEndpoint}/mappings?anilist_id=$anilistId",
        fromJson: AnizipIdMappingsEntity.fromJson,
      );
      if (response.statusCode > 299) {
        _logger.e("AniZip mapping lookup failed for AniList $anilistId: status ${response.statusCode}");
        return null;
      }
      final int malId = response.data.mappings.malId;
      return malId > 0 ? malId : null;
    } catch (e) {
      // A transient AniZip failure (network, timeout, bad payload) must degrade
      // to a mapping miss, not abort the details flow: the caller's chain still
      // has the title search and the unresolved fallback to fall back on.
      _logger.w("AniZip mapping lookup failed for AniList $anilistId: $e");
      return null;
    }
  }
}

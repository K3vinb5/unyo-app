// External dependencies
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/domain/services/media_id_resolver.dart' show AniZipIdLookup, AniZipIds;

/// AniZip `/mappings` leg of the MAL-pivot chain.
class AniZipIdLookupRepository implements AniZipIdLookup {
  final HttpService _httpService = sl<HttpService>();
  final Logger _logger = sl<Logger>();

  @override
  Future<AniZipIds?> lookup({int? anilistId, int? malId}) async {
    final String? query = anilistId != null && anilistId > 0
        ? 'anilist_id=$anilistId'
        : (malId != null && malId > 0 ? 'mal_id=$malId' : null);
    if (query == null) return null;
    _logger.i("Resolving MAL pivot through AniZip ($query)");
    final ApiResponse<AniZipIds?> response = await _httpService.get<AniZipIds?>(
      "${config.anizipBaseEndpoint}/mappings?$query",
      fromJson: _parseMappings,
    );
    if (response.statusCode > 299) {
      _logger.w("AniZip mapping lookup failed for $query: status ${response.statusCode}");
      return null;
    }
    return response.data;
  }

  static AniZipIds? _parseMappings(Map<String, dynamic> json) {
    final Object? mappings = json['mappings'];
    if (mappings is! Map) return null;
    final Object? anilistId = mappings['anilist_id'];
    final Object? malId = mappings['mal_id'];
    final int? parsedAnilistId = int.tryParse('${anilistId ?? ''}');
    final int? parsedMalId = int.tryParse('${malId ?? ''}');
    if (parsedAnilistId == null && parsedMalId == null) return null;
    return AniZipIds(anilistId: parsedAnilistId, malId: parsedMalId);
  }
}

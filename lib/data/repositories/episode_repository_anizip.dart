import 'package:logger/logger.dart';
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/dto/anizip/anizip_mappings.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/domain/entities/media/episode_info.dart';
import 'package:unyo/domain/repositories/episode_repository.dart';

class EpisodeRepositoryAnizip implements EpisodeRepository {

  final HttpService _httpService = sl<HttpService>();
  final Logger _logger = sl<Logger>();

  @override
  Future<List<EpisodeInfo>> getEpisodeInfo({
    required int malId,
    required int anilistId,
    bool ignoreCache = false,
  }) async {
    if (anilistId >= 0) {
      return _fetchEpisodesFromAnilistId(anilistId, ignoreCache: ignoreCache);
    } else {
      return _fetchEpisodesFromMalId(malId, ignoreCache: ignoreCache);
    }
  }

  @override
  Future<String> getAlternativeImage({
    required int malId,
    required int anilistId,
    bool ignoreCache = false,
  }) async{
    if (anilistId >= 0) {
      return _fetchAlternativeImageFromAnilistId(anilistId, ignoreCache: ignoreCache);
    } else {
      return _fetchAlternativeImageFromMalId(malId, ignoreCache: ignoreCache);
    }
  }

  Future<List<EpisodeInfo>> _fetchEpisodesFromAnilistId(int anilistId, {required bool ignoreCache}) async {
    _logger.i("Fetching episodes from Anizip for Anilist ID $anilistId");
    ApiResponse<AnizipMappings> anizipResponse = await _httpService.get(
        "${config.anizipBaseEndpoint}/mappings?anilist_id=$anilistId",
        fromJson: AnizipMappings.fromJson,
        ignoreCache: ignoreCache);
    if (anizipResponse.statusCode > 299) {
      _logger.e("Failed to fetch episodes from Anizip for Anilist ID $anilistId: Status Code ${anizipResponse.statusCode}");
      return [];
    }
    return anizipResponse.data.episodesInfo;
  }

  Future<List<EpisodeInfo>> _fetchEpisodesFromMalId(int malId, {required bool ignoreCache}) async {
    _logger.i("Fetching episodes from Anizip for MAL ID $malId");
    ApiResponse<AnizipMappings> anizipResponse = await _httpService.get(
        "${config.anizipBaseEndpoint}/mappings?mal_id=$malId",
        fromJson: AnizipMappings.fromJson,
        ignoreCache: ignoreCache);
    if (anizipResponse.statusCode > 299) {
      _logger.e("Failed to fetch episodes from Anizip for MAL ID $malId: Status Code ${anizipResponse.statusCode}");
      return [];
    }
    return anizipResponse.data.episodesInfo;
  }

  Future<String> _fetchAlternativeImageFromAnilistId(int anilistId, {required bool ignoreCache}) async {
    _logger.i("Fetching alternative image from Anizip for Anilist ID $anilistId");
    ApiResponse<AnizipMappings> anizipResponse = await _httpService.get(
        "${config.anizipBaseEndpoint}/mappings?anilist_id=$anilistId",
        fromJson: AnizipMappings.fromJson,
        ignoreCache: ignoreCache);
    if (anizipResponse.statusCode > 299) {
      _logger.e("Failed to fetch alternative image from Anizip for Anilist ID $anilistId: Status Code ${anizipResponse.statusCode}");
      return "";
    }
    return anizipResponse.data.mediaImage;
  }

  Future<String> _fetchAlternativeImageFromMalId(int malId, {required bool ignoreCache}) async {
    _logger.i("Fetching alternative image from Anizip for MAL ID $malId");
    ApiResponse<AnizipMappings> anizipResponse = await _httpService.get(
        "${config.anizipBaseEndpoint}/mappings?mal_id=$malId",
        fromJson: AnizipMappings.fromJson,
        ignoreCache: ignoreCache);
    if (anizipResponse.statusCode > 299) {
      _logger.e("Failed to fetch alternative image from Anizip for MAL ID $malId: Status Code ${anizipResponse.statusCode}");
      return "";
    }
    return anizipResponse.data.mediaImage;
  }

}

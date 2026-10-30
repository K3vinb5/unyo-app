import 'package:unyo/domain/entities/media/episode_info.dart';

abstract class EpisodeRepository {
  /// [ignoreCache] forces a network read, bypassing the HTTP response cache.
  /// Callers use it when the episode provider itself changed: a cached payload
  /// would otherwise be served for up to the cache TTL.
  Future<List<EpisodeInfo>> getEpisodeInfo({
    required int malId,
    required int anilistId,
    bool ignoreCache = false,
  });
  Future<String> getAlternativeImage({
    required int malId,
    required int anilistId,
    bool ignoreCache = false,
  });
}

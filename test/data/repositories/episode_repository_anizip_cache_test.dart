// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/api/http/response_cache_scope.dart';
import 'package:unyo/data/repositories/episode_repository_anizip.dart';
import 'package:unyo/domain/entities/media/episode_info.dart';

void main() {
  late ResponseCacheScope cacheScope;
  late EpisodeRepositoryAnizip episodeRepository;
  late int requests;

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));
    cacheScope = ResponseCacheScope();
    sl.registerSingleton<ResponseCacheScope>(cacheScope);
    requests = 0;

    final MockClient client = MockClient((http.Request request) async {
      requests++;
      return http.Response(
        '{"titles": {}, "episodeCount": 0, "episodes": {}, "images": ['
        '{"url": "https://img.test/first"}, {"url": "https://img.test/middle"}, '
        '{"url": "https://img.test/$requests"}]}',
        200,
        headers: <String, String>{'content-type': 'application/json'},
      );
    });
    sl.registerSingleton<HttpService>(HttpService(client: client));
    episodeRepository = EpisodeRepositoryAnizip();
  });

  test('an episode-provider switch is not served from the pre-switch cache', () async {
    await episodeRepository.getEpisodeInfo(malId: 1, anilistId: -1);
    await episodeRepository.getEpisodeInfo(malId: 1, anilistId: -1);
    expect(requests, 1, reason: 'an unchanged provider keeps serving the cached AniZip payload');

    // SettingsCubit invalidates the scope when the episode provider changes.
    cacheScope.invalidate();
    final List<EpisodeInfo> afterSwitch = await episodeRepository.getEpisodeInfo(malId: 1, anilistId: -1);
    expect(afterSwitch, isEmpty);
    expect(requests, 2, reason: 'the scope bump alone must miss the pre-switch entry');

    // The reload's own fetch bypasses the cache even for an entry cached a
    // moment ago under the new scope, so a provider change can never be served
    // 20-minute-old rows.
    final String alternativeImage = await episodeRepository.getAlternativeImage(
      malId: 1,
      anilistId: -1,
      ignoreCache: true,
    );
    expect(requests, 3, reason: 'ignoreCache must reach the AniZip GET');
    expect(alternativeImage, 'https://img.test/3');
  });
}

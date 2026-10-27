// External dependencies
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/media/media_id_service.dart';
import 'package:unyo/core/services/media/media_link_candidate.dart';
import 'package:unyo/data/repositories/media_mapping_repository_anizip.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/title.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/media_id_cache.dart';

/// A transient AniZip outage: `HttpService.get` throws instead of returning a
/// response, which is exactly what the repository has to absorb.
class ThrowingHttpService extends HttpService {
  ThrowingHttpService(this.error);

  final Object error;
  int calls = 0;

  @override
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    bool ignoreCache = false,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    calls++;
    throw error;
  }
}

class StatusHttpService extends HttpService {
  StatusHttpService(this.statusCode);

  final int statusCode;
  int calls = 0;

  @override
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    bool ignoreCache = false,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    calls++;
    return ApiResponse<T>(
      data: fromJson(<String, dynamic>{}),
      bodyBytes: Uint8List(0),
      statusCode: statusCode,
      headers: const <String, String>{},
    );
  }
}

class FakeMediaMappingLookup implements MediaMappingLookup {
  FakeMediaMappingLookup(this.searchResults);

  final List<MediaLinkCandidate> searchResults;
  int searchCalls = 0;

  @override
  Future<MediaLinkCandidate?> lookupByMalId(Service target, int malId) async => null;

  @override
  Future<List<MediaLinkCandidate>> searchCandidates(Service target, String title) async {
    searchCalls++;
    return searchResults;
  }
}

void main() {
  final GetIt sl = GetIt.instance;

  const String title = 'Kusuriya no Hitorigoto';

  Anime anilistAnimeWithoutMalId() => AnimeModel.empty().copyWith(
        id: 170942,
        idMal: 0,
        title: const TitleModel(
          romaji: title,
          english: '',
          nativeTitle: '',
          userPreferred: title,
        ),
      );

  User user() => UserModel.empty().copyWith(
        settings: SettingsModel.empty().copyWith(
          userService: Service.anilist,
          metadataService: Service.shikimori,
        ),
      );

  // NB: no `reset()` here — get_it 9's reset is deferred, so a registration made
  // right after it is swept away by the first await, and the fakes below resolve
  // `sl<Logger>()` while the test body is running.
  setUp(() {
    sl.allowReassignment = true;
    sl.registerSingleton<Logger>(Logger(level: Level.off));
    if (sl.isRegistered<HttpService>()) sl.unregister<HttpService>();
  });

  group('MediaMappingRepositoryAnizip', () {
    test('a throwing http service is a mapping miss, not an exception', () async {
      final ThrowingHttpService http = ThrowingHttpService(HttpNetworkException());
      sl.registerSingleton<HttpService>(http);
      final MediaMappingRepositoryAnizip repository = MediaMappingRepositoryAnizip();

      expect(await repository.malIdForAnilistId(170942), isNull);
      expect(http.calls, 1);
    });

    test('a parse failure is a mapping miss too', () async {
      final ThrowingHttpService http = ThrowingHttpService(const FormatException('not json'));
      sl.registerSingleton<HttpService>(http);
      final MediaMappingRepositoryAnizip repository = MediaMappingRepositoryAnizip();

      expect(await repository.malIdForAnilistId(170942), isNull);
      expect(http.calls, 1);
    });

    test('a non-2xx response is a mapping miss', () async {
      final StatusHttpService http = StatusHttpService(503);
      sl.registerSingleton<HttpService>(http);
      final MediaMappingRepositoryAnizip repository = MediaMappingRepositoryAnizip();

      expect(await repository.malIdForAnilistId(170942), isNull);
      expect(http.calls, 1);
    });

    test('the resolution chain continues into the title search after the lookup fails', () async {
      final ThrowingHttpService http = ThrowingHttpService(HttpTimeoutException());
      sl.registerSingleton<HttpService>(http);
      final FakeMediaMappingLookup lookup = FakeMediaMappingLookup(
        const <MediaLinkCandidate>[
          MediaLinkCandidate(service: Service.shikimori, nativeId: '55555', malId: 58514, title: title),
        ],
      );
      final MediaIdService service = MediaIdService(
        cache: InMemoryMediaIdCache(),
        aniZipLookup: MediaMappingRepositoryAnizip(),
        mappingLookup: lookup,
      );

      final MediaDetailsSource source = await service.detailsSource(anilistAnimeWithoutMalId(), user());

      expect(http.calls, 1, reason: 'AniZip was tried');
      expect(lookup.searchCalls, 1, reason: 'the chain degrades to the title search');
      expect(source.proposal, isNotNull);
      expect(source.isUnresolved, isTrue);
    });
  });
}

// External dependencies
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_list_query_entity.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/media/media_id_service.dart';
import 'package:unyo/core/services/media/media_link_candidate.dart';
import 'package:unyo/data/repositories/media_mapping_repository_anizip.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';
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

/// Returns a fixed AniZip `/mappings` payload and records the endpoint it was
/// asked for, so the query field of each direction is asserted.
class PayloadHttpService extends HttpService {
  PayloadHttpService(this.payload);

  final Map<String, dynamic> payload;
  final List<String> endpoints = <String>[];

  @override
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    bool ignoreCache = false,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    endpoints.add(endpoint);
    return ApiResponse<T>(
      data: fromJson(payload),
      bodyBytes: Uint8List(0),
      statusCode: 200,
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

    test('anilistIdForMalId reads the AniList id of the MAL-keyed payload', () async {
      final PayloadHttpService http = PayloadHttpService(<String, dynamic>{
        'mappings': <String, dynamic>{'mal_id': 58514, 'anilist_id': 170942},
      });
      sl.registerSingleton<HttpService>(http);
      final MediaMappingRepositoryAnizip repository = MediaMappingRepositoryAnizip();

      expect(await repository.anilistIdForMalId(58514), 170942);
      expect(http.endpoints.single, endsWith('/mappings?mal_id=58514'));
    });

    test('malIdForAnilistId still reads the MAL id of the AniList-keyed payload', () async {
      final PayloadHttpService http = PayloadHttpService(<String, dynamic>{
        'mappings': <String, dynamic>{'mal_id': 58514, 'anilist_id': 170942},
      });
      sl.registerSingleton<HttpService>(http);
      final MediaMappingRepositoryAnizip repository = MediaMappingRepositoryAnizip();

      expect(await repository.malIdForAnilistId(170942), 58514);
      expect(http.endpoints.single, endsWith('/mappings?anilist_id=170942'));
    });

    test('an AniZip payload without an AniList id is a mapping miss', () async {
      final PayloadHttpService http = PayloadHttpService(<String, dynamic>{
        'mappings': <String, dynamic>{'mal_id': 58514, 'anilist_id': 0},
      });
      sl.registerSingleton<HttpService>(http);

      expect(await MediaMappingRepositoryAnizip().anilistIdForMalId(58514), isNull);
    });

    test('anizip outage in the MAL to AniList direction is a miss too', () async {
      final ThrowingHttpService http = ThrowingHttpService(HttpNetworkException());
      sl.registerSingleton<HttpService>(http);

      expect(await MediaMappingRepositoryAnizip().anilistIdForMalId(58514), isNull);
      expect(http.calls, 1);
    });

    test('a Shikimori record with a known malId reaches AniList through the real AniZip leg', () async {
      final PayloadHttpService http = PayloadHttpService(<String, dynamic>{
        'mappings': <String, dynamic>{'mal_id': 58514, 'anilist_id': 170942},
      });
      sl.registerSingleton<HttpService>(http);
      final MediaIdService service = MediaIdService(
        cache: InMemoryMediaIdCache(),
        aniZipLookup: MediaMappingRepositoryAnizip(),
        mappingLookup: FakeMediaMappingLookup(const <MediaLinkCandidate>[]),
      );
      final Anime record = ShikimoriAnimeModel.fromListEntry(
        AnimeListQueryAnimes.fromJson(<String, dynamic>{
          'id': '65261',
          'malId': '58514',
          'name': title,
          'english': '',
          'russian': '',
          'japanese': '',
          'poster': <String, dynamic>{'originalUrl': '', 'mainAlt2xUrl': ''},
          'description': '',
          'duration': 24,
          'airedOn': <String, dynamic>{'year': 2026},
          'releasedOn': <String, dynamic>{'year': 2026},
          'episodes': 12,
          'nextEpisodeAt': null,
          'genres': <Map<String, dynamic>>[],
          'kind': 'tv',
          'isCensored': false,
          'score': 8.0,
          'season': 'winter_2026',
          'status': 'ongoing',
        }),
      );

      final MediaDetailsSource source = await service.detailsSource(
        record,
        UserModel.empty().copyWith(
          settings: SettingsModel.empty().copyWith(
            userService: Service.anilist,
            metadataService: Service.anilist,
          ),
        ),
      );

      expect(http.endpoints.single, endsWith('/mappings?mal_id=58514'));
      expect(source.service, Service.anilist);
      expect(source.anime.id, 170942);
      expect(source.isUnresolved, isFalse);
    });
  });
}

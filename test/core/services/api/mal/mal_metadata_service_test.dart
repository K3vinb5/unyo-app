// External dependencies
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/api/jikan/jikan_rate_limiter.dart';
import 'package:unyo/core/services/api/mal/mal_auth_service.dart';
import 'package:unyo/core/services/api/mal/mal_metadata_service.dart';
import 'package:unyo/core/services/api/mal/mal_rate_limiter.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/domain/entities/user/settings.dart';

/// Budget double: the real limiter's spacing/window is covered by its own
/// tests, here we only prove every MAL read takes a grant and Jikan takes none.
class CountingMalRateLimiter extends MalRateLimiter {
  CountingMalRateLimiter() : super(logger: Logger(level: Level.off));

  int acquires = 0;
  final List<String> reasons = <String>[];

  @override
  Future<void> acquire({String reason = 'request'}) async {
    acquires++;
    reasons.add(reason);
  }
}

/// Jikan budget double: records grants and backoffs without spending real time.
class CountingJikanRateLimiter extends JikanRateLimiter {
  CountingJikanRateLimiter() : super(wait: (_) async {}, logger: Logger(level: Level.off));

  int acquires = 0;
  int backoffs = 0;
  final List<String> reasons = <String>[];

  @override
  Future<void> acquire({String reason = 'request'}) async {
    acquires++;
    reasons.add(reason);
  }

  @override
  Future<void> backoff({String reason = 'request'}) async {
    backoffs++;
  }
}

/// Transport-level harness: records the request the service produced and
/// answers with one scripted `(status, body)`.
void main() {
  late List<http.Request> requests;
  late int status;
  late String body;
  late CountingMalRateLimiter limiter;
  late CountingJikanRateLimiter jikanLimiter;
  late MalMetadataService service;

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));
    limiter = CountingMalRateLimiter();
    sl.registerSingleton<MalRateLimiter>(limiter);
    jikanLimiter = CountingJikanRateLimiter();
    sl.registerSingleton<MalAuthService>(MalAuthService(client: MockClient((http.Request request) async {
      return http.Response('{}', 200);
    })));
    requests = <http.Request>[];
    status = 200;
    body = jsonEncode(<String, dynamic>{'data': <Object>[], 'paging': <String, dynamic>{}});
    service = MalMetadataService(
      client: MockClient((http.Request request) async {
        requests.add(request);
        return http.Response(body, status);
      }),
      jikanRateLimiter: jikanLimiter,
    );
  });

  MalUserModel malUser() {
    return MalUserModel(
      id: '1',
      name: 'tester',
      settings: SettingsModel.empty(),
      avatarImage: '',
      bannerImage: '',
      accessToken: 'access-token-1',
      refreshToken: 'refresh-1',
      accessTokenExpiresAt: '2099-01-01T00:00:00.000',
      profileUrl: '',
    );
  }

  http.Request single() => requests.single;

  group('X-MAL-CLIENT-ID (public-client auth)', () {
    test('an anonymous ranking read always carries the client id', () async {
      await service.getAnimeRanking('airing');

      final http.Request request = single();
      expect(request.headers['X-MAL-CLIENT-ID'], config.malClientId,
          reason: 'MAL v2 answers 403 to an anonymous read without the client id');
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(limiter.acquires, 1);
    });

    test('an anonymous details read carries the client id and no bearer token', () async {
      body = jsonEncode(<String, dynamic>{'id': 5114, 'title': 'Fullmetal Alchemist: Brotherhood'});
      await service.getAnimeDetails(5114);

      final http.Request request = single();
      expect(request.headers['X-MAL-CLIENT-ID'], config.malClientId);
      expect(request.headers.containsKey('Authorization'), isFalse);
    });

    test('an anonymous manga read carries the client id and no bearer token', () async {
      body = jsonEncode(<String, dynamic>{'id': 2, 'title': 'Berserk'});
      await service.getMangaDetails(2);

      final http.Request request = single();
      expect(request.headers['X-MAL-CLIENT-ID'], config.malClientId);
      expect(request.headers.containsKey('Authorization'), isFalse);
    });

    test('a logged account sends the client id AND the bearer token', () async {
      await service.getAnimeRanking('airing', user: malUser());

      final http.Request request = single();
      expect(request.headers['X-MAL-CLIENT-ID'], config.malClientId);
      expect(request.headers['Authorization'], 'Bearer access-token-1');
    });
  });

  group('getAnimeRanking', () {
    test('asks /v2/anime/ranking with ranking_type, paging and explicit fields', () async {
      await service.getAnimeRanking('airing');

      final http.Request request = single();
      expect(request.method, 'GET');
      expect(request.url.host, 'api.myanimelist.net');
      expect(request.url.path, '/v2/anime/ranking');
      expect(request.url.queryParameters['ranking_type'], 'airing');
      expect(request.url.queryParameters['limit'], '50');
      expect(request.url.queryParameters['offset'], '0');
      expect(request.url.queryParameters['fields'], MalMetadataService.animeListFields);
      expect(request.url.queryParameters.containsKey('nsfw'), isFalse, reason: 'the ranking endpoint has no nsfw parameter');
      expect(limiter.acquires, 1);
    });

    test('maps page/limit onto offset = (page - 1) * limit', () async {
      await service.getAnimeRanking('bypopularity', page: 3, limit: 20);

      final Map<String, String> query = single().url.queryParameters;
      expect(query['limit'], '20');
      expect(query['offset'], '40');
    });

    test('accepts the probed upcoming ranking type and rejects one MAL does not define', () async {
      await service.getAnimeRanking('upcoming');
      expect(single().url.queryParameters['ranking_type'], 'upcoming');

      requests.clear();
      expect(() => service.getAnimeRanking('trending'), throwsArgumentError);
      expect(requests, isEmpty);
    });
  });

  group('getAnimeDetails', () {
    test('asks /v2/anime/{id} with the details field set', () async {
      body = jsonEncode(<String, dynamic>{'id': 5114, 'title': 'Fullmetal Alchemist: Brotherhood'});
      final dynamic node = await service.getAnimeDetails(5114);

      final http.Request request = single();
      expect(request.url.host, 'api.myanimelist.net');
      expect(request.url.path, '/v2/anime/5114');
      final String fields = request.url.queryParameters['fields']!;
      for (final String required in <String>[
        'my_list_status',
        'related_anime',
        'alternative_titles',
        'studios',
        'main_picture',
        'start_date',
        'end_date',
        'synopsis',
        'mean',
        'media_type',
        'status',
        'num_episodes',
        'average_episode_duration',
        'rating',
        'popularity',
        'broadcast',
      ]) {
        expect(fields, contains(required), reason: 'details fields must request $required');
      }
      expect(node.id, 5114);
      expect(limiter.acquires, 1);
    });

    test('throws HttpServerException on a non-2xx answer', () async {
      status = 404;
      body = jsonEncode(<String, dynamic>{'error': 'not_found'});

      await expectLater(service.getAnimeDetails(1), throwsA(isA<HttpServerException>()));
      expect(limiter.acquires, 1, reason: 'the grant is taken before the call is attempted');
    });

    test('rejects non-positive ids without a request', () async {
      expect(() => service.getAnimeDetails(0), throwsArgumentError);
      expect(requests, isEmpty);
    });
  });

  group('manga ranking / details', () {
    test('getMangaRanking asks /v2/manga/ranking with the manga field set', () async {
      await service.getMangaRanking('bypopularity');

      final http.Request request = single();
      expect(request.url.path, '/v2/manga/ranking');
      expect(request.url.queryParameters['ranking_type'], 'bypopularity');
      expect(request.url.queryParameters['fields'], MalMetadataService.mangaListFields);
      expect(request.url.queryParameters['fields'], isNot(contains('rating')));
      expect(request.url.queryParameters.containsKey('nsfw'), isFalse, reason: 'the ranking endpoint has no nsfw parameter');
      expect(request.headers['X-MAL-CLIENT-ID'], config.malClientId);
      expect(limiter.acquires, 1);
    });

    test('rejects the manga ranking types that probe as 400', () async {
      expect(() => service.getMangaRanking('publishing'), throwsArgumentError);
      expect(() => service.getMangaRanking('upcoming'), throwsArgumentError);
      expect(requests, isEmpty);
    });

    test('getMangaDetails asks /v2/manga/{id} with chapter/volume and list-status fields', () async {
      body = jsonEncode(<String, dynamic>{'id': 2, 'title': 'Berserk'});
      await service.getMangaDetails(2);

      final http.Request request = single();
      expect(request.url.path, '/v2/manga/2');
      final String fields = request.url.queryParameters['fields']!;
      expect(fields, contains('my_list_status'));
      expect(fields, contains('related_manga'));
      expect(fields, contains('num_volumes'));
      expect(fields, contains('num_chapters'));
      expect(limiter.acquires, 1);
    });
  });

  group('getJikanAnimeList', () {
    test('asks api.jikan.moe/v4/anime with the filter set, no MAL headers and no MAL grant', () async {
      body = jsonEncode(<String, dynamic>{'data': <Object>[], 'pagination': <String, dynamic>{}});
      await service.getJikanAnimeList(
        status: 'airing',
        orderBy: 'start_date',
        sort: 'desc',
        page: 2,
        limit: 10,
      );

      final http.Request request = single();
      expect(request.url.host, 'api.jikan.moe');
      expect(request.url.path, '/v4/anime');
      final Map<String, String> query = request.url.queryParameters;
      expect(query['status'], 'airing');
      expect(query['order_by'], 'start_date');
      expect(query['sort'], 'desc');
      expect(query['page'], '2');
      expect(query['limit'], '10');
      expect(query.containsKey('q'), isFalse, reason: 'an empty query means browse');
      expect(query.containsKey('sfw'), isFalse, reason: 'Jikan includes adult entries unless sfw=true');
      expect(query.containsKey('fields'), isFalse, reason: 'Jikan has no fields= parameter');
      expect(request.headers.containsKey('X-MAL-CLIENT-ID'), isFalse, reason: 'not a MAL host');
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(limiter.acquires, 0, reason: 'Jikan has its own budget');
      expect(jikanLimiter.acquires, 1);
      expect(jikanLimiter.reasons.single, contains('anime'));
    });

    test('sends q, type, rating and genre ids, and sfw=true when adult titles are forbidden', () async {
      await service.getJikanAnimeList(
        q: 'hitorigoto',
        type: 'tv',
        rating: 'pg13',
        genreIds: <int>[1, 4],
        nsfwAllowed: false,
      );

      final Map<String, String> query = single().url.queryParameters;
      expect(query['q'], 'hitorigoto');
      expect(query['type'], 'tv');
      expect(query['rating'], 'pg13');
      expect(query['genres'], '1,4');
      expect(query['sfw'], 'true');
      expect(query['limit'], '25', reason: "Jikan's list cap");
    });

    test('omits sfw when adult titles are allowed', () async {
      await service.getJikanAnimeList(nsfwAllowed: true);
      expect(single().url.queryParameters.containsKey('sfw'), isFalse);
      expect(jikanLimiter.acquires, 1);
    });

    test('clamps the limit to Jikan 25 and never sends a zero page', () async {
      await service.getJikanAnimeList(limit: 100, page: 0);
      final Map<String, String> query = single().url.queryParameters;
      expect(query['limit'], '25');
      expect(query['page'], '1');
    });

    test('retries once after a 429, then succeeds', () async {
      final List<int> statuses = <int>[429, 200];
      service = MalMetadataService(
        client: MockClient((http.Request request) async {
          requests.add(request);
          final int answer = statuses.removeAt(0);
          return http.Response(jsonEncode(<String, dynamic>{'data': <Object>[]}), answer);
        }),
        jikanRateLimiter: jikanLimiter,
      );

      await service.getJikanAnimeList(status: 'airing');

      expect(requests, hasLength(2), reason: 'one backoff, one retry');
      expect(jikanLimiter.backoffs, 1);
      expect(jikanLimiter.acquires, 2);
    });

    test('a second 429 surfaces as HttpServerException so the caller can degrade', () async {
      status = 429;
      body = '{"message":"rate limited"}';

      await expectLater(service.getJikanAnimeList(), throwsA(isA<HttpServerException>()));
      expect(requests, hasLength(2));
      expect(jikanLimiter.backoffs, 1);
    });
  });

  group('getJikanMangaList', () {
    test('asks api.jikan.moe/v4/manga without the anime-only rating filter', () async {
      await service.getJikanMangaList(
        status: 'publishing',
        orderBy: 'members',
        sort: 'desc',
        genreIds: <int>[1],
        nsfwAllowed: false,
      );

      final http.Request request = single();
      expect(request.url.path, '/v4/manga');
      final Map<String, String> query = request.url.queryParameters;
      expect(query['status'], 'publishing');
      expect(query['order_by'], 'members');
      expect(query['sort'], 'desc');
      expect(query['genres'], '1');
      expect(query['sfw'], 'true');
      expect(query.containsKey('rating'), isFalse, reason: 'manga has no rating filter');
      expect(limiter.acquires, 0);
      expect(jikanLimiter.acquires, 1);
    });
  });

  group('getSchedules (Jikan)', () {
    test('asks api.jikan.moe/v4/schedules with the day filter, on the Jikan budget', () async {
      body = jsonEncode(<String, dynamic>{'data': <Object>[], 'pagination': <String, dynamic>{}});
      await service.getSchedules(day: 'Monday');

      final http.Request request = single();
      expect(request.url.host, 'api.jikan.moe');
      expect(request.url.path, '/v4/schedules');
      expect(request.url.queryParameters['filter'], 'monday');
      expect(request.url.queryParameters['limit'], '25');
      expect(request.url.queryParameters['page'], '1');
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(limiter.acquires, 0, reason: 'Jikan must not spend MAL budget');
      expect(limiter.reasons, isEmpty);
      expect(jikanLimiter.acquires, 1, reason: 'Jikan has its own 60/min budget');
    });

    test('clamps the limit to Jikan\'s 25', () async {
      await service.getSchedules(limit: 100);
      expect(single().url.queryParameters['limit'], '25');
      expect(single().url.queryParameters.containsKey('filter'), isFalse);
    });

    test('throws HttpServerException on a non-2xx answer', () async {
      status = 500;
      body = '{"message":"server error"}';
      await expectLater(service.getSchedules(), throwsA(isA<HttpServerException>()));
    });
  });
}

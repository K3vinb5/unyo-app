// External dependencies
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/services/api/http/http_exception.dart';
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

/// Transport-level harness: records the request the service produced and
/// answers with one scripted `(status, body)`.
void main() {
  late List<http.Request> requests;
  late int status;
  late String body;
  late CountingMalRateLimiter limiter;
  late MalMetadataService service;

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));
    limiter = CountingMalRateLimiter();
    sl.registerSingleton<MalRateLimiter>(limiter);
    sl.registerSingleton<MalAuthService>(MalAuthService(client: MockClient((http.Request request) async {
      return http.Response('{}', 200);
    })));
    requests = <http.Request>[];
    status = 200;
    body = jsonEncode(<String, dynamic>{'data': <Object>[], 'paging': <String, dynamic>{}});
    service = MalMetadataService(client: MockClient((http.Request request) async {
      requests.add(request);
      return http.Response(body, status);
    }));
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

  group('getAnimeRanking', () {
    test('asks /v2/anime/ranking with ranking_type, paging and explicit fields, anonymously', () async {
      await service.getAnimeRanking('airing');

      final http.Request request = single();
      expect(request.method, 'GET');
      expect(request.url.path, '/v2/anime/ranking');
      expect(request.url.queryParameters['ranking_type'], 'airing');
      expect(request.url.queryParameters['limit'], '50');
      expect(request.url.queryParameters['offset'], '0');
      expect(request.url.queryParameters['fields'], MalMetadataService.animeListFields);
      expect(request.url.queryParameters.containsKey('nsfw'), isFalse, reason: 'the ranking endpoint has no nsfw parameter');
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(limiter.acquires, 1);
    });

    test('maps page/limit onto offset = (page - 1) * limit', () async {
      await service.getAnimeRanking('bypopularity', page: 3, limit: 20);

      final Map<String, String> query = single().url.queryParameters;
      expect(query['limit'], '20');
      expect(query['offset'], '40');
    });

    test('rejects a ranking type MAL does not define instead of sending it', () async {
      expect(() => service.getAnimeRanking('trending'), throwsArgumentError);
      expect(requests, isEmpty);
    });
  });

  group('getAnimeCatalog', () {
    test('sends every filter the caller set, and nsfw=false when adult titles are forbidden', () async {
      await service.getAnimeCatalog(
        status: 'currently_airing',
        sort: '-anime_start_date',
        q: 'hitorigoto',
        mediaType: 'tv',
        rating: 'pg_13',
        genreIds: <int>[1, 4],
        nsfwAllowed: false,
        page: 2,
        limit: 10,
      );

      final http.Request request = single();
      final Map<String, String> query = request.url.queryParameters;
      expect(request.url.path, '/v2/anime');
      expect(query['status'], 'currently_airing');
      expect(query['sort'], '-anime_start_date');
      expect(query['q'], 'hitorigoto');
      expect(query['type'], 'tv');
      expect(query['rating'], 'pg_13');
      expect(query['genre'], '1,4');
      expect(query['nsfw'], 'false');
      expect(query['limit'], '10');
      expect(query['offset'], '10');
      expect(query['fields'], MalMetadataService.animeListFields);
      expect(limiter.acquires, 1);
    });

    test('sends nsfw=true when adult titles are allowed and omits empty filters', () async {
      await service.getAnimeCatalog(nsfwAllowed: true, genreIds: const <int>[]);

      final Map<String, String> query = single().url.queryParameters;
      expect(query['nsfw'], 'true', reason: 'MAL defaults to the safe catalog, so opt-in must be explicit');
      expect(query.containsKey('genre'), isFalse);
      expect(query.containsKey('status'), isFalse);
      expect(query.containsKey('q'), isFalse);
    });

    test('omits nsfw only when the caller has no preference', () async {
      await service.getAnimeCatalog();

      expect(single().url.queryParameters.containsKey('nsfw'), isFalse);
    });

    test('logs and drops season/year (MAL /anime has no such filter)', () async {
      await service.getAnimeCatalog(season: 'spring', year: 2024);

      final Map<String, String> query = single().url.queryParameters;
      expect(query.containsKey('season'), isFalse);
      expect(query.containsKey('year'), isFalse);
      expect(query.containsKey('start_date'), isFalse);
    });

    test('sends the caller token only when a user is passed', () async {
      await service.getAnimeCatalog(user: malUser());
      expect(single().headers['Authorization'], 'Bearer access-token-1');
    });
  });

  group('getAnimeDetails', () {
    test('asks /v2/anime/{id} with the details field set', () async {
      body = jsonEncode(<String, dynamic>{'id': 5114, 'title': 'Fullmetal Alchemist: Brotherhood'});
      final dynamic node = await service.getAnimeDetails(5114);

      final http.Request request = single();
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
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(node.id, 5114);
      expect(limiter.acquires, 1);
    });

    test('adds the auth header when a user is passed', () async {
      await service.getAnimeDetails(5114, malUser());
      expect(single().headers['Authorization'], 'Bearer access-token-1');
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

  group('manga', () {
    test('getMangaRanking asks /v2/manga/ranking with the manga field set', () async {
      await service.getMangaRanking('all');

      final http.Request request = single();
      expect(request.url.path, '/v2/manga/ranking');
      expect(request.url.queryParameters['ranking_type'], 'all');
      expect(request.url.queryParameters['fields'], MalMetadataService.mangaListFields);
      expect(request.url.queryParameters['fields'], isNot(contains('rating')));
      expect(request.url.queryParameters.containsKey('nsfw'), isFalse, reason: 'the ranking endpoint has no nsfw parameter');
      expect(limiter.acquires, 1);
    });

    test('getMangaCatalog sends nsfw=true when adult titles are allowed', () async {
      await service.getMangaCatalog(nsfwAllowed: true);

      final Map<String, String> query = single().url.queryParameters;
      expect(query['nsfw'], 'true', reason: 'MAL defaults to the safe catalog, so opt-in must be explicit');
      expect(query['fields'], isNot(contains('rating')), reason: 'manga has no rating field; adult comes from nsfw');
    });

    test('getMangaCatalog sends nsfw=false when adult titles are forbidden', () async {
      await service.getMangaCatalog(nsfwAllowed: false);

      expect(single().url.queryParameters['nsfw'], 'false');
    });

    test('getMangaCatalog sends manga filters and keeps nsfw absent by default', () async {
      await service.getMangaCatalog(
        status: 'publishing',
        sort: '-manga_start_date',
        q: 'berserk',
        mediaType: 'manga',
        page: 2,
        limit: 50,
      );

      final Map<String, String> query = single().url.queryParameters;
      expect(single().url.path, '/v2/manga');
      expect(query['status'], 'publishing');
      expect(query['sort'], '-manga_start_date');
      expect(query['q'], 'berserk');
      expect(query['type'], 'manga');
      expect(query['offset'], '50');
      expect(query.containsKey('nsfw'), isFalse);
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

  group('getSchedules (Jikan)', () {
    test('asks api.jikan.moe/v4/schedules with the day filter and takes no MAL grant', () async {
      body = jsonEncode(<String, dynamic>{'data': <Object>[], 'pagination': <String, dynamic>{}});
      await service.getSchedules(day: 'Monday');

      final http.Request request = single();
      expect(request.url.host, 'api.jikan.moe');
      expect(request.url.path, '/v4/schedules');
      expect(request.url.queryParameters['filter'], 'monday');
      expect(request.url.queryParameters['limit'], '25');
      expect(request.url.queryParameters['page'], '1');
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(limiter.acquires, 0, reason: 'Jikan has its own limits and must not spend MAL budget');
      expect(limiter.reasons, isEmpty);
    });

    test('clamps the limit to Jikan\'s 25', () async {
      await service.getSchedules(limit: 100);
      expect(single().url.queryParameters['limit'], '25');
      expect(single().url.queryParameters.containsKey('filter'), isFalse);
    });

    test('throws HttpServerException on a non-2xx answer', () async {
      status = 429;
      body = '{"message":"rate limited"}';
      await expectLater(service.getSchedules(), throwsA(isA<HttpServerException>()));
    });
  });
}

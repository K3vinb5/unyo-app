// External dependencies
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/api/mal/mal_auth_service.dart';
import 'package:unyo/core/services/api/mal/mal_rate_limiter.dart';
import 'package:unyo/data/adapters/type_adapters/color_adapter.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/data/repositories/user_repository_mal.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/hive_registrar.g.dart';

import '../../core/services/api/shikimori/support/fake_rate_limiter_clock.dart';

class MockLogger extends Mock implements Logger {}

/// The PKCE pair of a login is random per flow; this double pins it so the test
/// can play the OAuth redirect. `exchangeAuthorizationCode` stays **real** —
/// the form-urlencoded, no-client_secret request shape is the contract.
class FixedPkceMalAuthService extends MalAuthService {
  FixedPkceMalAuthService({required super.client});

  static const String verifier = 'fixed-verifier-0123456789012345678901234567890123456789012';
  static const String state = 'the-state';

  @override
  String generateCodeVerifier() => verifier;

  @override
  String generateState() => state;
}

/// WP #156: `UserRepositoryMal` — OAuth login (own shelf port + PKCE), Hive
/// persistence keyed by user name, and the `@me` list fetches mapped onto the
/// same `Anime`/`Manga` shapes the Shikimori repository produces.
void main() {
  late Directory tempDir;
  bool adaptersRegistered = false;

  setUpAll(() async {
    registerFallbackValue(MalUserModel(
      id: '0',
      name: 'fallback',
      settings: SettingsModel.empty(),
      avatarImage: '',
      bannerImage: '',
      accessToken: '',
      refreshToken: '',
      accessTokenExpiresAt: '',
      profileUrl: '',
    ));
  });

  /// Swaps the registered auth service for one with a scripted token endpoint.
  void replaceAuth(MalAuthService auth) {
    if (sl.isRegistered<MalAuthService>()) sl.unregister<MalAuthService>();
    sl.registerSingleton<MalAuthService>(auth);
  }

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(MockLogger());
    final FakeRateLimiterClock clock = FakeRateLimiterClock();
    sl.registerLazySingleton<MalRateLimiter>(
      () => MalRateLimiter(clock: clock.now, wait: clock.wait),
    );
    tempDir = await Directory.systemTemp.createTemp('unyo_mal_user_repo_');
    Hive.init(tempDir.path);
    if (!adaptersRegistered) {
      Hive
        ..registerAdapter(ColorAdapter())
        ..registerAdapters();
      adaptersRegistered = true;
    }
    // Every UserRepositoryMal construction resolves the auth service from the
    // locator; a placeholder covers the tests that never touch the token
    // endpoint.
    replaceAuth(FixedPkceMalAuthService(
      client: MockClient((http.Request request) async => http.Response('{}', 200, headers: <String, String>{'content-type': 'application/json; charset=utf-8'})),
    ));
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  MalUserModel account({String expiresAt = '2099-01-01T00:00:00.000'}) {
    return MalUserModel(
      id: '56789',
      name: 'tester',
      settings: SettingsModel.empty().copyWith(userService: Service.mal),
      avatarImage: '',
      bannerImage: '',
      accessToken: 'stored-access',
      refreshToken: 'stored-refresh',
      accessTokenExpiresAt: expiresAt,
      profileUrl: '',
    );
  }

  Map<String, dynamic> animeNode(int id) {
    return <String, dynamic>{
      'id': id,
      'title': 'Anime $id',
      'main_picture': <String, dynamic>{
        'medium': 'https://cdn.myanimelist.net/images/anime/${id}m.jpg',
        'large': 'https://cdn.myanimelist.net/images/anime/${id}l.jpg',
      },
      'alternative_titles': <String, dynamic>{
        'synonyms': <String>[],
        'en': 'English $id',
        'ja': 'アニメ$id',
      },
      'start_date': '2012-07-01',
      'end_date': '2012-09-30',
      'mean': 7.5,
      'num_episodes': 13,
      'media_type': 'tv',
      'status': 'finished_airing',
      'genres': <Map<String, dynamic>>[
        <String, dynamic>{'id': 1, 'name': 'Drama'},
      ],
      'nsfw': 'white',
      'popularity': 40,
    };
  }

  Map<String, dynamic> mangaNode(int id) {
    return <String, dynamic>{
      'id': id,
      'title': 'Manga $id',
      'main_picture': <String, dynamic>{
        'medium': 'https://cdn.myanimelist.net/images/manga/${id}m.jpg',
        'large': 'https://cdn.myanimelist.net/images/manga/${id}l.jpg',
      },
      'alternative_titles': <String, dynamic>{
        'synonyms': <String>[],
        'en': 'English $id',
        'ja': '漫画$id',
      },
      'start_date': '2011-10-20',
      'end_date': '2012-12-08',
      'mean': 8,
      'num_volumes': 12,
      'num_chapters': 178,
      'media_type': 'manga',
      'status': 'finished_publishing',
      'genres': <Map<String, dynamic>>[
        <String, dynamic>{'id': 2, 'name': 'Action'},
      ],
      'nsfw': 'white',
      'popularity': 20,
    };
  }

  Map<String, dynamic> listEntry(Map<String, dynamic> node, {String status = 'watching'}) {
    return <String, dynamic>{
      'node': node,
      'list_status': <String, dynamic>{'status': status, 'score': 0},
    };
  }

  group('login flow (shelf :9998 + PKCE + Hive persist)', () {
    test('the redirect code is exchanged form-urlencoded without a client_secret and the account persists', () async {
      late http.Request tokenRequest;
      late http.Request profileRequest;
      final MalAuthService auth = FixedPkceMalAuthService(
        client: MockClient((http.Request request) async {
          tokenRequest = request;
          return http.Response(
            jsonEncode(<String, dynamic>{
              'token_type': 'Bearer',
              'expires_in': 3600,
              'access_token': 'access-1',
              'refresh_token': 'refresh-1',
            }),
            200,
            headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      replaceAuth(auth);
      final UserNotifier newUser = UserNotifier();
      final UserNotifier loggedUser = UserNotifier();
      final UserRepositoryMal repository = UserRepositoryMal(
        newUser,
        loggedUser,
        client: MockClient((http.Request request) async {
          profileRequest = request;
          return http.Response(
            jsonEncode(<String, dynamic>{
              'id': 56789,
              'name': 'tester',
              'picture': 'https://cdn.myanimelist.net/images/user/56789.jpg',
            }),
            200,
            headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      addTearDown(repository.closeLoginServer);

      await repository.attemptCreateUser();
      final http.Response redirect = await http.get(
        Uri.parse('http://localhost:9998/mal-auth?code=the-code&state=${FixedPkceMalAuthService.state}'),
      );
      expect(redirect.statusCode, 200, reason: redirect.body);

      expect(tokenRequest.method, 'POST');
      expect(tokenRequest.url.toString(), config.malTokenEndpoint);
      expect(
        tokenRequest.headers['content-type'],
        startsWith('application/x-www-form-urlencoded'),
        reason: 'JSON answers unsupported_grant_type on the token endpoint',
      );
      final Map<String, String> fields = tokenRequest.bodyFields;
      expect(fields['grant_type'], 'authorization_code');
      expect(fields['code'], 'the-code');
      expect(fields['client_id'], config.malClientId);
      expect(fields['redirect_uri'], config.malRedirectUri);
      expect(fields['code_verifier'], FixedPkceMalAuthService.verifier,
          reason: 'PKCE plain: the verifier goes to the token endpoint as-is');
      expect(fields.containsKey('client_secret'), isFalse,
          reason: 'MAL "Other" apps are public clients');
      expect(fields.containsKey('code_challenge'), isFalse);

      expect(profileRequest.method, 'GET');
      expect(profileRequest.url.toString(), '${config.malApiBase}/users/@me');
      expect(profileRequest.headers['authorization'], 'Bearer access-1');

      final Box<MalUserModel> box = await Hive.openBox<MalUserModel>(UserRepositoryMal.usersBoxName);
      final MalUserModel? stored = box.get('tester');
      expect(stored, isNotNull, reason: 'the box is keyed by user.name');
      expect(stored!.id, '56789');
      expect(stored.accessToken, 'access-1');
      expect(stored.refreshToken, 'refresh-1');
      expect(stored.accessTokenExpiresAt, isNotEmpty);
      expect(stored.avatarImage, 'https://cdn.myanimelist.net/images/user/56789.jpg');
      expect((stored.settings as SettingsModel).userService, Service.mal);
      expect((stored.settings as SettingsModel).metadataService, Service.mal,
          reason: 'WP #166: metadata defaults to the account service (WP #164 rule), '
              'and MAL is a metadata provider now that its details/browse reads are real');
      expect(stored.profileUrl, 'https://myanimelist.net/profile/tester');

      expect(newUser.currentUser.name, 'tester', reason: 'the new-user notifier carries the account');
      expect(loggedUser.currentUser.name, 'tester', reason: 'updateUserInfo notifies the logged-user notifier');

      final List<MalUserModel> all = (await repository.fetchAllLoggedInUsers()).cast<MalUserModel>();
      expect(all.map((MalUserModel user) => user.name), <String>['tester']);
    });

    test('a state mismatch is rejected before any token exchange and keeps the server up', () async {
      int tokenCalls = 0;
      final MalAuthService auth = FixedPkceMalAuthService(
        client: MockClient((http.Request request) async {
          tokenCalls++;
          return http.Response('{}', 200, headers: <String, String>{'content-type': 'application/json; charset=utf-8'});
        }),
      );
      replaceAuth(auth);
      final UserRepositoryMal repository = UserRepositoryMal(
        UserNotifier(),
        UserNotifier(),
        client: MockClient((http.Request request) async => http.Response('{}', 200, headers: <String, String>{'content-type': 'application/json; charset=utf-8'})),
      );
      addTearDown(repository.closeLoginServer);

      await repository.attemptCreateUser();
      final http.Response redirect = await http.get(
        Uri.parse('http://localhost:9998/mal-auth?code=the-code&state=not-the-state'),
      );

      expect(redirect.statusCode, 400);
      expect(tokenCalls, 0);

      // WP #163: the mismatch is not a fatal request — the real redirect can
      // still arrive on the same server.
      final http.Response again = await http.get(
        Uri.parse('http://localhost:9998/mal-auth?code=the-code&state=not-the-state'),
      );
      expect(again.statusCode, 400);
      expect(tokenCalls, 0);
    });

    test('a redirect without a code is a bad request and keeps the server up', () async {
      final MalAuthService auth = FixedPkceMalAuthService(
        client: MockClient((http.Request request) async => http.Response('{}', 200, headers: <String, String>{'content-type': 'application/json; charset=utf-8'})),
      );
      replaceAuth(auth);
      final UserRepositoryMal repository = UserRepositoryMal(
        UserNotifier(),
        UserNotifier(),
        client: MockClient((http.Request request) async => http.Response('{}', 200, headers: <String, String>{'content-type': 'application/json; charset=utf-8'})),
      );
      addTearDown(repository.closeLoginServer);

      await repository.attemptCreateUser();
      final http.Response redirect = await http.get(
        Uri.parse('http://localhost:9998/mal-auth?state=${FixedPkceMalAuthService.state}'),
      );

      expect(redirect.statusCode, 400);

      // WP #163: a favicon/probe/mistyped URL must not close the callback
      // server, or the OAuth redirect that follows can never be answered.
      final http.Response again = await http.get(
        Uri.parse('http://localhost:9998/mal-auth?state=${FixedPkceMalAuthService.state}'),
      );
      expect(again.statusCode, 400, reason: 'the server must still be listening');
    });

    test('a code-less probe followed by the real redirect logs in and then closes the server', () async {
      late http.Request tokenRequest;
      late http.Request profileRequest;
      final MalAuthService auth = FixedPkceMalAuthService(
        client: MockClient((http.Request request) async {
          tokenRequest = request;
          return http.Response(
            jsonEncode(<String, dynamic>{
              'token_type': 'Bearer',
              'expires_in': 3600,
              'access_token': 'access-1',
              'refresh_token': 'refresh-1',
            }),
            200,
            headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      replaceAuth(auth);
      final UserNotifier newUser = UserNotifier();
      final UserNotifier loggedUser = UserNotifier();
      final UserRepositoryMal repository = UserRepositoryMal(
        newUser,
        loggedUser,
        client: MockClient((http.Request request) async {
          profileRequest = request;
          return http.Response(
            jsonEncode(<String, dynamic>{
              'id': 56789,
              'name': 'tester',
              'picture': 'https://cdn.myanimelist.net/images/user/56789.jpg',
            }),
            200,
            headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      addTearDown(repository.closeLoginServer);

      await repository.attemptCreateUser();
      final http.Response probe = await http.get(Uri.parse('http://localhost:9998/mal-auth'));
      expect(probe.statusCode, 400);

      final http.Response redirect = await http.get(
        Uri.parse('http://localhost:9998/mal-auth?code=the-code&state=${FixedPkceMalAuthService.state}'),
      );
      expect(redirect.statusCode, 200, reason: redirect.body);

      expect(tokenRequest.url.toString(), config.malTokenEndpoint);
      expect(tokenRequest.bodyFields['code'], 'the-code');
      expect(tokenRequest.bodyFields['code_verifier'], FixedPkceMalAuthService.verifier);
      expect(profileRequest.url.toString(), '${config.malApiBase}/users/@me');
      expect(profileRequest.headers['authorization'], 'Bearer access-1');

      final Box<MalUserModel> box = await Hive.openBox<MalUserModel>(UserRepositoryMal.usersBoxName);
      expect(box.get('tester')?.name, 'tester');
      expect(loggedUser.currentUser.name, 'tester');

      // A successful login is the one request that does close the callback.
      await expectLater(
        http.get(Uri.parse('http://localhost:9998/mal-auth')),
        throwsA(anyOf(isA<http.ClientException>(), isA<SocketException>())),
      );
    });

    test('a second attemptCreateUser replaces the previous listener instead of failing', () async {
      final MalAuthService auth = FixedPkceMalAuthService(
        client: MockClient((http.Request request) async => http.Response('{}', 200, headers: <String, String>{'content-type': 'application/json; charset=utf-8'})),
      );
      replaceAuth(auth);
      final UserRepositoryMal repository = UserRepositoryMal(
        UserNotifier(),
        UserNotifier(),
        client: MockClient((http.Request request) async => http.Response('{}', 200, headers: <String, String>{'content-type': 'application/json; charset=utf-8'})),
      );
      addTearDown(repository.closeLoginServer);

      await repository.attemptCreateUser();
      expect((await http.get(Uri.parse('http://localhost:9998/mal-auth'))).statusCode, 400);

      // LoginCubit re-invokes the login on every dialog confirm: :9998 is not
      // `shared`, so the previous listener must be closed first or this bind
      // throws "address in use" and the old handler keeps answering.
      await repository.attemptCreateUser();
      expect((await http.get(Uri.parse('http://localhost:9998/mal-auth'))).statusCode, 400);
    });

    test('an abandoned login server is reaped by the timeout', () async {
      final MalAuthService auth = FixedPkceMalAuthService(
        client: MockClient((http.Request request) async => http.Response('{}', 200, headers: <String, String>{'content-type': 'application/json; charset=utf-8'})),
      );
      replaceAuth(auth);
      final UserRepositoryMal repository = UserRepositoryMal(
        UserNotifier(),
        UserNotifier(),
        loginServerTimeout: const Duration(milliseconds: 100),
        client: MockClient((http.Request request) async => http.Response('{}', 200, headers: <String, String>{'content-type': 'application/json; charset=utf-8'})),
      );
      addTearDown(repository.closeLoginServer);

      await repository.attemptCreateUser();
      final Uri callback = Uri.parse('http://localhost:9998/mal-auth');
      expect((await http.get(callback)).statusCode, 400, reason: 'the server is up before the timeout');

      Object? closedBy;
      final DateTime deadline = DateTime.now().add(const Duration(seconds: 3));
      while (DateTime.now().isBefore(deadline)) {
        try {
          await http.get(callback);
          await Future<void>.delayed(const Duration(milliseconds: 50));
        } catch (e) {
          closedBy = e;
          break;
        }
      }
      expect(closedBy, isA<Object>(), reason: 'the timer must close a login nobody finishes');
      expect(closedBy, anyOf(isA<http.ClientException>(), isA<SocketException>()));
    });
  });

  group('list fetches', () {
    test('the anime list is fetched with the mandatory fields and mapped onto Anime', () async {
      late Uri requested;
      final UserRepositoryMal repository = UserRepositoryMal(
        UserNotifier(),
        UserNotifier(),
        client: MockClient((http.Request request) async {
          requested = request.url;
          return http.Response(
            jsonEncode(<String, dynamic>{
              'data': <Map<String, dynamic>>[listEntry(animeNode(16001))],
              'paging': <String, dynamic>{'previous': '', 'next': ''},
            }),
            200,
            headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final List<Anime> watching = await repository.getUserWatchingList(account());

      expect(requested.path, '/v2/users/@me/animelist');
      expect(requested.queryParameters['status'], 'watching');
      expect(requested.queryParameters['limit'], '1000');
      expect(requested.queryParameters['offset'], '0');
      expect(requested.queryParameters['fields'], contains('list_status'),
          reason: 'without fields=list_status the status object is omitted');
      expect(requested.queryParameters['fields'], contains('num_episodes'));

      final Anime anime = watching.single;
      expect(anime.id, 16001);
      expect(anime.idMal, 16001, reason: 'a MAL list entry carries MAL ids (D3 maps them in wave 6)');
      expect(anime.title.romaji, 'Anime 16001');
      expect(anime.title.english, 'English 16001');
      expect(anime.title.nativeTitle, 'アニメ16001');
      expect(anime.title.userPreferred, 'Anime 16001');
      expect(anime.averageScore, 75, reason: 'MAL mean is 0-10, the domain score is 0-100');
      expect(anime.meanScore, 75);
      expect(anime.episodes, 13);
      expect(anime.format, 'TV');
      expect(anime.status, 'FINISHED');
      expect(anime.genres, <String>['Drama']);
      expect(anime.coverImage, 'https://cdn.myanimelist.net/images/anime/16001l.jpg');
      expect(anime.startDate, '1/7/2012');
      expect(anime.endDate, '30/9/2012');
      expect(anime.isAdult, isFalse);
      expect(anime.popularity, 40);
    });

    test('the manga reading list uses /mangalist and maps chapters', () async {
      late Uri requested;
      final UserRepositoryMal repository = UserRepositoryMal(
        UserNotifier(),
        UserNotifier(),
        client: MockClient((http.Request request) async {
          requested = request.url;
          return http.Response(
            jsonEncode(<String, dynamic>{
              'data': <Map<String, dynamic>>[listEntry(mangaNode(105), status: 'reading')],
              'paging': <String, dynamic>{'previous': '', 'next': ''},
            }),
            200,
            headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final List<Manga> reading = await repository.getUserReadingList(account());

      expect(requested.path, '/v2/users/@me/mangalist');
      expect(requested.queryParameters['status'], 'reading');
      expect(requested.queryParameters['fields'], contains('num_chapters'));
      expect(reading.single.id, 105);
      expect(reading.single.chapters, 178);
      expect(reading.single.format, 'MANGA');
      expect(reading.single.status, 'FINISHED');
    });

    test('nsfw tiers gray/black map onto isAdult', () async {
      final UserRepositoryMal repository = UserRepositoryMal(
        UserNotifier(),
        UserNotifier(),
        client: MockClient((http.Request request) async {
          final Map<String, dynamic> node = animeNode(2)..['nsfw'] = 'black';
          return http.Response(
            jsonEncode(<String, dynamic>{
              'data': <Map<String, dynamic>>[listEntry(node)],
              'paging': <String, dynamic>{'previous': '', 'next': ''},
            }),
            200,
            headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final List<Anime> watching = await repository.getUserWatchingList(account());

      expect(watching.single.isAdult, isTrue);
    });

    test('pages are read 1000 at a time until a short page arrives', () async {
      final List<Map<String, dynamic>> fullPage = List<Map<String, dynamic>>.generate(
        UserRepositoryMal.pageSize,
        (int index) => listEntry(animeNode(10000 + index)),
      );
      final List<Uri> calls = <Uri>[];
      final UserRepositoryMal repository = UserRepositoryMal(
        UserNotifier(),
        UserNotifier(),
        client: MockClient((http.Request request) async {
          calls.add(request.url);
          final int offset = int.parse(request.url.queryParameters['offset']!);
          final List<Map<String, dynamic>> page =
              offset == 0 ? fullPage : <Map<String, dynamic>>[listEntry(animeNode(20001))];
          return http.Response(
            jsonEncode(<String, dynamic>{
              'data': page,
              'paging': <String, dynamic>{
                'previous': '',
                'next': offset == 0 ? 'https://api.myanimelist.net/v2/users/@me/animelist?offset=1000' : '',
              },
            }),
            200,
            headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final List<Anime> watching = await repository.getUserWatchingList(account());

      expect(watching, hasLength(UserRepositoryMal.pageSize + 1));
      expect(calls, hasLength(2));
      expect(calls[0].queryParameters['offset'], '0');
      expect(calls[1].queryParameters['offset'], '1000');
    });

    test('runaway pagination stops at the safety cap instead of looping', () async {
      final List<Map<String, dynamic>> fullPage = List<Map<String, dynamic>>.generate(
        UserRepositoryMal.pageSize,
        (int index) => listEntry(animeNode(30000 + index)),
      );
      int calls = 0;
      final UserRepositoryMal repository = UserRepositoryMal(
        UserNotifier(),
        UserNotifier(),
        client: MockClient((http.Request request) async {
          calls++;
          return http.Response(
            jsonEncode(<String, dynamic>{
              'data': fullPage,
              'paging': <String, dynamic>{'previous': '', 'next': 'next'},
            }),
            200,
            headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final List<Anime> watching = await repository.getUserWatchingList(account());

      expect(watching, hasLength(UserRepositoryMal.pageSize * UserRepositoryMal.maxPagesPerStatus));
      expect(calls, UserRepositoryMal.maxPagesPerStatus);
    });

    test('five MAL statuses collapse into five AniList buckets, in tab order', () async {
      final UserRepositoryMal repository = UserRepositoryMal(
        UserNotifier(),
        UserNotifier(),
        client: MockClient((http.Request request) async {
          final String status = request.url.queryParameters['status']!;
          final Map<String, dynamic> node = switch (status) {
            'watching' => animeNode(1),
            'plan_to_watch' => animeNode(2),
            'completed' => animeNode(3),
            'on_hold' => animeNode(4),
            'dropped' => animeNode(5),
            _ => animeNode(6),
          };
          return http.Response(
            jsonEncode(<String, dynamic>{
              'data': <Map<String, dynamic>>[listEntry(node, status: status)],
              'paging': <String, dynamic>{'previous': '', 'next': ''},
            }),
            200,
            headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final Map<String, List<Anime>> lists = await repository.getUserAnimeLists(account());

      expect(
        lists.keys,
        <String>['Watching', 'Planning', 'Completed', 'Paused', 'Dropped'],
        reason: 'REPEATING never appears: is_rewatching folds into Watching',
      );
      expect(lists['Watching']!.single.id, 1);
      expect(lists['Planning']!.single.id, 2);
      expect(lists['Completed']!.single.id, 3);
      expect(lists['Paused']!.single.id, 4);
      expect(lists['Dropped']!.single.id, 5);
    });

    test('an empty bucket is omitted instead of rendering an empty tab', () async {
      final UserRepositoryMal repository = UserRepositoryMal(
        UserNotifier(),
        UserNotifier(),
        client: MockClient((http.Request request) async {
          if (request.url.queryParameters['status'] != 'reading') {
            return http.Response(
              jsonEncode(<String, dynamic>{
                'data': <Map<String, dynamic>>[],
                'paging': <String, dynamic>{'previous': '', 'next': ''},
              }),
              200,
              headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
            );
          }
          return http.Response(
            jsonEncode(<String, dynamic>{
              'data': <Map<String, dynamic>>[listEntry(mangaNode(105), status: 'reading')],
              'paging': <String, dynamic>{'previous': '', 'next': ''},
            }),
            200,
            headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final Map<String, List<Manga>> lists = await repository.getUserMangaLists(account());

      expect(lists.keys, <String>['Watching']);
    });

    test('an account with nothing on any list yields no buckets at all', () async {
      final UserRepositoryMal repository = UserRepositoryMal(
        UserNotifier(),
        UserNotifier(),
        client: MockClient((http.Request request) async {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'data': <Map<String, dynamic>>[],
              'paging': <String, dynamic>{'previous': '', 'next': ''},
            }),
            200,
            headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final Map<String, List<Manga>> lists = await repository.getUserMangaLists(account());

      expect(lists, isEmpty);
    });

    test('a forced reload is not served from a cache (every read is fresh)', () async {
      int calls = 0;
      final UserRepositoryMal repository = UserRepositoryMal(
        UserNotifier(),
        UserNotifier(),
        client: MockClient((http.Request request) async {
          calls++;
          return http.Response(
            jsonEncode(<String, dynamic>{
              'data': <Map<String, dynamic>>[listEntry(animeNode(calls))],
              'paging': <String, dynamic>{'previous': '', 'next': ''},
            }),
            200,
            headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      await repository.getUserWatchingList(account(), ignoreCache: true);
      await repository.getUserWatchingList(account());

      expect(calls, 2, reason: 'there is no response cache under MAL reads, so ignoreCache is trivially honoured');
    });
  });

  group('token refresh', () {
    test('ensureFreshAccessToken rotates an expired pair and re-persists it', () async {
      int refreshes = 0;
      final MalAuthService auth = FixedPkceMalAuthService(
        client: MockClient((http.Request request) async {
          refreshes++;
          return http.Response(
            jsonEncode(<String, dynamic>{
              'token_type': 'Bearer',
              'expires_in': 3600,
              'access_token': 'fresh-access',
              'refresh_token': 'fresh-refresh',
            }),
            200,
            headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      replaceAuth(auth);
      final UserRepositoryMal repository = UserRepositoryMal(
        UserNotifier(),
        UserNotifier(),
        client: MockClient((http.Request request) async => http.Response('{}', 200, headers: <String, String>{'content-type': 'application/json; charset=utf-8'})),
      );
      await repository.updateUserInfo(account(expiresAt: '2000-01-01T00:00:00.000'));

      final MalUserModel fresh = await repository.ensureFreshAccessToken(
        account(expiresAt: '2000-01-01T00:00:00.000'),
      );

      expect(refreshes, 1);
      expect(fresh.accessToken, 'fresh-access');
      expect(fresh.refreshToken, 'fresh-refresh');
      final Box<MalUserModel> box = await Hive.openBox<MalUserModel>(UserRepositoryMal.usersBoxName);
      expect(box.get('tester')!.accessToken, 'fresh-access',
          reason: 'the rotated pair must be what the next launch reads');
    });

    test('updateUserInfo rejects a foreign user type instead of persisting it', () async {
      replaceAuth(FixedPkceMalAuthService(
        client: MockClient((http.Request request) async => http.Response('{}', 200, headers: <String, String>{'content-type': 'application/json; charset=utf-8'})),
      ));
      final UserRepositoryMal repository = UserRepositoryMal(
        UserNotifier(),
        UserNotifier(),
        client: MockClient((http.Request request) async => http.Response('{}', 200, headers: <String, String>{'content-type': 'application/json; charset=utf-8'})),
      );

      await expectLater(
        repository.updateUserInfo(UserModel.empty()),
        throwsA(isA<StateError>()),
      );
    });
  });
}

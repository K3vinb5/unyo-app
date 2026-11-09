// External dependencies
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show MethodCall, MethodChannel;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retry/retry.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_token_entity.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/api/shikimori/shikimori_auth_service.dart';
import 'package:unyo/data/adapters/type_adapters/color_adapter.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/user_repository_shikimori.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/hive_registrar.g.dart';

class MockLogger extends Mock implements Logger {}

/// Answers each GraphQL page from a per-status script and records the variables,
/// so the pagination contract (50/page, page numbers, target type) is asserted
/// on the wire instead of inferred from the model.
class PagedUserRatesHttpService implements HttpService {
  PagedUserRatesHttpService(this.pagesByStatus);

  /// status → pages of `userRates` entries (index 0 is page 1).
  final Map<String, List<List<Map<String, dynamic>>>> pagesByStatus;
  final List<Map<String, dynamic>> variablesLog = <Map<String, dynamic>>[];
  final List<Map<String, String>?> headersLog = <Map<String, String>?>[];
  final List<String> endpoints = <String>[];
  /// `ignoreCache` of every read, so the cache-busting contract is asserted.
  final List<bool> ignoreCacheLog = <bool>[];

  @override
  http.Client get client => throw UnimplementedError('the fake answers post() only');

  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  RetryOptions get retryOptions => const RetryOptions(maxAttempts: 1);

  @override
  Duration get cacheTtl => const Duration(minutes: 20);

  @override
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    bool ignoreCache = false,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    throw UnimplementedError('the list reads are GraphQL posts');
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool ignoreCache = false,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    endpoints.add(endpoint);
    headersLog.add(headers);
    ignoreCacheLog.add(ignoreCache);
    final Map<String, dynamic> request = jsonDecode(jsonEncode(body)) as Map<String, dynamic>;
    final Map<String, dynamic> variables = request['variables'] as Map<String, dynamic>;
    variablesLog.add(variables);
    final String status = variables['status'] as String;
    final int page = variables['page'] as int;
    final List<List<Map<String, dynamic>>> pages = pagesByStatus[status] ?? <List<Map<String, dynamic>>>[];
    final List<Map<String, dynamic>> rates =
        page <= pages.length ? pages[page - 1] : const <Map<String, dynamic>>[];
    return ApiResponse<T>(
      data: fromJson(<String, dynamic>{
        'data': <String, dynamic>{'userRates': rates},
      }),
      bodyBytes: Uint8List(0),
      statusCode: 200,
      headers: const <String, String>{},
    );
  }

  @override
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    throw UnimplementedError('the lists are read-only');
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    throw UnimplementedError('the lists are read-only');
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    throw UnimplementedError('the lists are read-only');
  }
}

class FakeShikimoriAuthService extends ShikimoriAuthService {
  int refreshes = 0;

  @override
  bool isAccessTokenExpired(ShikimoriUserModel user, {DateTime? at}) => false;

  @override
  Future<ShikimoriUserModel> withFreshAccessToken(ShikimoriUserModel user) async {
    refreshes++;
    return user;
  }
}

/// The login flow swaps the redirect code for a real token; the endpoint shape
/// is `ShikimoriAuthService`'s own contract, so the double only pins the answer.
class LoginShikimoriAuthService extends ShikimoriAuthService {
  int exchanges = 0;
  final List<String> codes = <String>[];

  @override
  Future<ShikimoriTokenEntity> exchangeAuthorizationCode(String code) async {
    exchanges++;
    codes.add(code);
    return ShikimoriTokenEntity()
      ..accessToken = 'access-1'
      ..refreshToken = 'refresh-1'
      ..tokenType = 'Bearer'
      ..expiresIn = 3600;
  }
}

/// Answers the single `currentUser` viewer query the login flow sends, and
/// records the headers so the fresh Bearer token is asserted on the wire.
class ViewerHttpService implements HttpService {
  final List<Map<String, String>?> headersLog = <Map<String, String>?>[];
  final List<String> endpoints = <String>[];

  @override
  http.Client get client => throw UnimplementedError('the fake answers post() only');

  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  RetryOptions get retryOptions => const RetryOptions(maxAttempts: 1);

  @override
  Duration get cacheTtl => const Duration(minutes: 20);

  @override
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    bool ignoreCache = false,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    throw UnimplementedError('the viewer is a GraphQL post');
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool ignoreCache = false,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    endpoints.add(endpoint);
    headersLog.add(headers);
    return ApiResponse<T>(
      data: fromJson(<String, dynamic>{
        'data': <String, dynamic>{
          'currentUser': <String, dynamic>{
            'id': '23456789',
            'nickname': 'tester',
            'avatarUrl': 'https://shikimori.io/avatars/23456789.jpg',
            'url': 'https://shikimori.io/tester',
            'lastOnlineAt': '2026-01-01T00:00:00.000+00:00',
          },
        },
      }),
      bodyBytes: Uint8List(0),
      statusCode: 200,
      headers: const <String, String>{},
    );
  }

  @override
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    throw UnimplementedError('the login flow never patches');
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    throw UnimplementedError('the login flow never puts');
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    throw UnimplementedError('the login flow never deletes');
  }
}

/// Both the Shikimori and the AniList suite drive the shared `:9999` callback,
/// and `flutter test` runs suites concurrently. Two listeners on a `shared` port
/// load-balance incoming requests between them, so a probe could land on the
/// other provider's handler. This file lock keeps only one suite bound at a
/// time, which is what makes the per-handler assertions meaningful.
Future<RandomAccessFile> lockCallbackPort() async {
  final File file = File('${Directory.systemTemp.path}/unyo_oauth_callback_9999.lock');
  final RandomAccessFile handle = await file.open(mode: FileMode.write);
  while (true) {
    try {
      await handle.lock(FileLock.exclusive);
      return handle;
    } on FileSystemException {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
  }
}

/// A sibling suite (`user_repository_anilist_test`) drives the very same shared
/// `:9999` callback and `flutter test` runs test files concurrently, so a bind
/// can race the other suite's live listener. Retry briefly instead of failing:
/// the winner's teardown releases the port in milliseconds.
Future<void> bindLoginServer(Future<void> Function() attemptCreateUser) async {
  final DateTime deadline = DateTime.now().add(const Duration(seconds: 20));
  while (true) {
    try {
      await attemptCreateUser();
      return;
    } on SocketException {
      if (DateTime.now().isAfter(deadline)) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
  }
}

void main() {
  // The login-flow group drives `attemptCreateUser`, which launches the OAuth
  // page through `url_launcher` — a platform channel, so the binding must exist.
  TestWidgetsFlutterBinding.ensureInitialized();
  // ...but the test binding also installs an HttpOverrides that answers every
  // request with an empty 400. These tests drive the real shelf server on
  // :9999, so the real client is restored.
  HttpOverrides.global = null;

  late PagedUserRatesHttpService http;
  late FakeShikimoriAuthService auth;
  late UserRepositoryShikimori repository;

  ShikimoriUserModel account() {
    return ShikimoriUserModel(
      id: '23456789',
      name: 'tester',
      settings: SettingsModel.empty().copyWith(
        userService: Service.shikimori,
        metadataService: Service.shikimori,
      ),
      avatarImage: '',
      bannerImage: '',
      accessToken: 'stored-access',
      refreshToken: 'stored-refresh',
      accessTokenExpiresAt: '2099-01-01T00:00:00.000',
      profileUrl: '',
    );
  }

  Map<String, dynamic> animeNode(int id) {
    return <String, dynamic>{
      'id': '$id',
      'malId': '$id',
      'name': 'Anime $id',
      'english': 'Anime $id',
      'japanese': 'アニメ $id',
      'russian': 'Аниме $id',
      'poster': <String, dynamic>{
        'originalUrl': 'https://shikimori.io/animes/$id.jpg',
        'mainAlt2xUrl': 'https://shikimori.io/animes/$id@2x.jpg',
      },
      'description': 'Описание',
      'duration': 24,
      'airedOn': <String, dynamic>{'date': '2012-07-01', 'day': 1, 'month': 7, 'year': 2012},
      'releasedOn': <String, dynamic>{'date': '2012-09-30', 'day': 30, 'month': 9, 'year': 2012},
      'episodes': 13,
      'episodesAired': 13,
      'nextEpisodeAt': null,
      'genres': <Map<String, dynamic>>[
        <String, dynamic>{'id': '1', 'name': 'Drama', 'kind': 'genre', 'russian': 'Драма'},
      ],
      'kind': 'tv',
      'isCensored': false,
      'score': 7.5,
      'season': 'summer',
      'status': 'released',
    };
  }

  Map<String, dynamic> mangaNode(int id) {
    return <String, dynamic>{
      'id': '$id',
      'malId': '$id',
      'name': 'Manga $id',
      'english': 'Manga $id',
      'japanese': '漫画 $id',
      'russian': 'Манга $id',
      'poster': <String, dynamic>{
        'originalUrl': 'https://shikimori.io/mangas/$id.jpg',
        'mainAlt2xUrl': 'https://shikimori.io/mangas/$id@2x.jpg',
      },
      'description': 'Описание',
      'airedOn': <String, dynamic>{'date': '2011-10-20', 'day': 20, 'month': 10, 'year': 2011},
      'releasedOn': <String, dynamic>{'date': '2012-12-08', 'day': 8, 'month': 12, 'year': 2012},
      'volumes': 12,
      'chapters': 178,
      'genres': <Map<String, dynamic>>[
        <String, dynamic>{'id': '2', 'name': 'Action', 'kind': 'genre', 'russian': 'Экшен'},
      ],
      'kind': 'manga',
      'isCensored': false,
      'score': 8,
      'status': 'released',
      'publishers': <Map<String, dynamic>>[
        <String, dynamic>{'id': '1', 'name': 'Shogakukan'},
      ],
    };
  }

  Map<String, dynamic> animeRate({required int id, required int animeId, required String status, int rewatches = 0}) {
    return <String, dynamic>{
      'id': '$id',
      'status': status,
      'score': 0,
      'episodes': 4,
      'rewatches': rewatches,
      'volumes': 0,
      'chapters': 0,
      'text': null,
      'createdAt': '2012-12-21T16:58:12+04:00',
      'updatedAt': '2013-01-29T00:10:04+04:00',
      'anime': animeNode(animeId),
    };
  }

  Map<String, dynamic> mangaRate({required int id, required int mangaId, required String status}) {
    return <String, dynamic>{
      'id': '$id',
      'status': status,
      'score': 0,
      'episodes': 0,
      'rewatches': 0,
      'volumes': 4,
      'chapters': 178,
      'text': null,
      'createdAt': '2011-10-20T07:18:57+04:00',
      'updatedAt': '2012-12-08T00:49:07+04:00',
      'manga': mangaNode(mangaId),
    };
  }

  Future<UserRepositoryShikimori> repositoryWith(
    Map<String, List<List<Map<String, dynamic>>>> pagesByStatus,
  ) async {
    await sl.reset();
    sl.registerSingleton<Logger>(MockLogger());
    http = PagedUserRatesHttpService(pagesByStatus);
    sl.registerSingleton<HttpService>(http);
    sl.registerLazySingleton<GraphQLService>(
      () => GraphQLService(
        httpService: sl<HttpService>(),
        endpoint: config.shikimoriGraphQLEndpoint,
      ),
      instanceName: config.shikimoriGraphQlService,
    );
    auth = FakeShikimoriAuthService();
    sl.registerSingleton<ShikimoriAuthService>(auth);
    return UserRepositoryShikimori(UserNotifier(), UserNotifier());
  }

  group('userRates lists', () {
    test('watching and rewatching fold into one current list', () async {
      repository = await repositoryWith(<String, List<List<Map<String, dynamic>>>>{
        'watching': <List<Map<String, dynamic>>>[
          <Map<String, dynamic>>[animeRate(id: 1, animeId: 16001, status: 'watching')],
        ],
        'rewatching': <List<Map<String, dynamic>>>[
          <Map<String, dynamic>>[animeRate(id: 2, animeId: 16002, status: 'rewatching', rewatches: 2)],
        ],
      });

      final List<Anime> watching = await repository.getUserWatchingList(account());

      expect(watching.map((Anime anime) => anime.id), <int>[16001, 16002]);
      expect(
        http.variablesLog.map((Map<String, dynamic> variables) => variables['status']),
        <String>['watching', 'rewatching'],
        reason: 'rewatching is a status, so it needs its own page',
      );
      expect(
        http.variablesLog.map((Map<String, dynamic> variables) => variables['targetType']).toSet(),
        <String>{'Anime'},
      );
      expect(http.variablesLog.every((Map<String, dynamic> v) => v['userId'] == '23456789'), isTrue);
      expect(http.variablesLog.every((Map<String, dynamic> v) => v['limit'] == 50), isTrue);
      expect(http.headersLog.first!['Authorization'], 'Bearer stored-access');
      expect(http.endpoints.first, config.shikimoriGraphQLEndpoint);
    });
    test('a forced reload busts the HTTP cache for every page (WP #110 home refresh)', () async {
      repository = await repositoryWith(<String, List<List<Map<String, dynamic>>>>{
        'watching': <List<Map<String, dynamic>>>[
          <Map<String, dynamic>>[animeRate(id: 1, animeId: 16001, status: 'watching')],
        ],
        'rewatching': <List<Map<String, dynamic>>>[
          <Map<String, dynamic>>[animeRate(id: 2, animeId: 16002, status: 'rewatching')],
        ],
      });

      await repository.getUserWatchingList(account(), ignoreCache: true);

      expect(http.ignoreCacheLog, isNotEmpty);
      expect(
        http.ignoreCacheLog.every((bool value) => value),
        isTrue,
        reason: 'home reloads after a list write; dropping the flag served the pre-write list out of the 20-minute cache',
      );

      http.ignoreCacheLog.clear();
      await repository.getUserWatchingList(account());

      expect(http.ignoreCacheLog.every((bool value) => value), isFalse);
      expect(http.ignoreCacheLog, hasLength(2), reason: 'a plain read still reads both current buckets');
    });


    test('pages are read 50 at a time until a short page arrives', () async {
      final List<Map<String, dynamic>> firstPage = List<Map<String, dynamic>>.generate(
        50,
        (int index) => animeRate(id: index + 1, animeId: 10000 + index, status: 'watching'),
      );
      repository = await repositoryWith(<String, List<List<Map<String, dynamic>>>>{
        'watching': <List<Map<String, dynamic>>>[
          firstPage,
          <Map<String, dynamic>>[animeRate(id: 51, animeId: 10500, status: 'watching')],
        ],
        'rewatching': <List<Map<String, dynamic>>>[],
      });

      final List<Anime> watching = await repository.getUserWatchingList(account());

      expect(watching, hasLength(51));
      final List<Map<String, dynamic>> watchingCalls = http.variablesLog
          .where((Map<String, dynamic> variables) => variables['status'] == 'watching')
          .toList();
      expect(watchingCalls, hasLength(2));
      expect(watchingCalls[0]['page'], 1);
      expect(watchingCalls[1]['page'], 2);
      expect(watchingCalls.every((Map<String, dynamic> v) => v['limit'] == 50), isTrue);
    });

    test('runaway pagination stops at the safety cap instead of looping', () async {
      final List<Map<String, dynamic>> fullPage = List<Map<String, dynamic>>.generate(
        50,
        (int index) => animeRate(id: index + 1, animeId: 20000 + index, status: 'watching'),
      );
      repository = await repositoryWith(<String, List<List<Map<String, dynamic>>>>{
        'watching': List<List<Map<String, dynamic>>>.generate(
          UserRepositoryShikimori.maxPagesPerStatus,
          (int index) => fullPage,
        ),
        'rewatching': <List<Map<String, dynamic>>>[],
      });

      final List<Anime> watching = await repository.getUserWatchingList(account());

      expect(watching, hasLength(50 * UserRepositoryShikimori.maxPagesPerStatus));
      final int watchingCalls =
          http.variablesLog.where((Map<String, dynamic> v) => v['status'] == 'watching').length;
      expect(watchingCalls, UserRepositoryShikimori.maxPagesPerStatus);
    });

    test('the manga reading list uses the manga document', () async {
      repository = await repositoryWith(<String, List<List<Map<String, dynamic>>>>{
        'watching': <List<Map<String, dynamic>>>[
          <Map<String, dynamic>>[mangaRate(id: 26019, mangaId: 105, status: 'watching')],
        ],
      });

      final List<Manga> reading = await repository.getUserReadingList(account());

      expect(reading.single.id, 105);
      expect(reading.single.chapters, 178);
      expect(http.variablesLog.first['targetType'], 'Manga');
    });
  });

  group('list buckets', () {
    test('six Shikimori statuses collapse into five AniList buckets, in tab order', () async {
      repository = await repositoryWith(<String, List<List<Map<String, dynamic>>>>{
        'watching': <List<Map<String, dynamic>>>[
          <Map<String, dynamic>>[animeRate(id: 1, animeId: 1, status: 'watching')],
        ],
        'rewatching': <List<Map<String, dynamic>>>[
          <Map<String, dynamic>>[animeRate(id: 2, animeId: 2, status: 'rewatching')],
        ],
        'planned': <List<Map<String, dynamic>>>[
          <Map<String, dynamic>>[animeRate(id: 3, animeId: 3, status: 'planned')],
        ],
        'completed': <List<Map<String, dynamic>>>[
          <Map<String, dynamic>>[animeRate(id: 4, animeId: 4, status: 'completed')],
        ],
        'on_hold': <List<Map<String, dynamic>>>[
          <Map<String, dynamic>>[animeRate(id: 5, animeId: 5, status: 'on_hold')],
        ],
        'dropped': <List<Map<String, dynamic>>>[
          <Map<String, dynamic>>[animeRate(id: 6, animeId: 6, status: 'dropped')],
        ],
      });

      final Map<String, List<Anime>> lists = await repository.getUserAnimeLists(account());

      expect(
        lists.keys,
        <String>['Watching', 'Planning', 'Completed', 'Paused', 'Dropped'],
        reason: 'rewatching folds into Watching, and Repeating never appears',
      );
      expect(lists['Watching'], hasLength(2));
      expect(lists['Watching']!.map((Anime anime) => anime.id), <int>[1, 2]);
      expect(lists['Planning']!.single.id, 3);
      expect(lists['Completed']!.single.id, 4);
      expect(lists['Paused']!.single.id, 5);
      expect(lists['Dropped']!.single.id, 6);
      expect(lists.containsKey('Repeating'), isFalse);
    });

    test('an empty list is omitted instead of rendering an empty tab', () async {
      repository = await repositoryWith(<String, List<List<Map<String, dynamic>>>>{
        'watching': <List<Map<String, dynamic>>>[
          <Map<String, dynamic>>[animeRate(id: 1, animeId: 1, status: 'watching')],
        ],
      });

      final Map<String, List<Anime>> lists = await repository.getUserAnimeLists(account());

      expect(lists.keys, <String>['Watching']);
    });

    test('an account with nothing on any list yields no buckets at all', () async {
      repository = await repositoryWith(<String, List<List<Map<String, dynamic>>>>{});

      final Map<String, List<Manga>> lists = await repository.getUserMangaLists(account());

      expect(lists, isEmpty);
    });
  });

  /// WP #163: the callback handler used to close the shared `:9999` server on
  /// the first request of any kind, so a favicon/probe/mistyped URL killed the
  /// in-flight OAuth redirect. These tests drive the real shelf server.
  group('login flow (shared shelf :9999)', () {
    late Directory tempDir;
    late ViewerHttpService viewer;
    late LoginShikimoriAuthService loginAuth;
    late RandomAccessFile callbackLock;
    bool adaptersRegistered = false;

    setUp(() async {
      callbackLock = await lockCallbackPort();
      await sl.reset();
      sl.registerSingleton<Logger>(MockLogger());
      viewer = ViewerHttpService();
      sl.registerSingleton<HttpService>(viewer);
      sl.registerLazySingleton<GraphQLService>(
        () => GraphQLService(
          httpService: sl<HttpService>(),
          endpoint: config.shikimoriGraphQLEndpoint,
        ),
        instanceName: config.shikimoriGraphQlService,
      );
      loginAuth = LoginShikimoriAuthService();
      sl.registerSingleton<ShikimoriAuthService>(loginAuth);
      // `attemptCreateUser` opens the browser after binding the callback; under
      // `flutter test` there is none, so the channel answers "cannot launch".
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/url_launcher'),
        (MethodCall call) async => call.method != 'canLaunch',
      );
      tempDir = await Directory.systemTemp.createTemp('unyo_shikimori_login_');
      Hive.init(tempDir.path);
      if (!adaptersRegistered) {
        Hive
          ..registerAdapter(ColorAdapter())
          ..registerAdapters();
        adaptersRegistered = true;
      }
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/url_launcher'), null);
      await Hive.close();
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
      await callbackLock.unlock();
      await callbackLock.close();
    });

    Future<UserRepositoryShikimori> startLogin() async {
      final UserRepositoryShikimori loginRepository =
          UserRepositoryShikimori(UserNotifier(), UserNotifier());
      await bindLoginServer(loginRepository.attemptCreateUser);
      return loginRepository;
    }

    /// Raw `dart:io` GET: the `package:http` prefix is shadowed by the
    /// `PagedUserRatesHttpService http` field declared at the top of `main`.
    Future<(int, String)> getCallback(Uri uri) async {
      final HttpClient client = HttpClient();
      try {
        final HttpClientRequest request = await client.getUrl(uri);
        final HttpClientResponse response = await request.close();
        final String body = await response.transform(utf8.decoder).join();
        return (response.statusCode, body);
      } finally {
        client.close(force: true);
      }
    }

    test('a code-less request is a bad request and keeps the shared server up', () async {
      final UserRepositoryShikimori loginRepository = await startLogin();
      addTearDown(loginRepository.closeLoginServer);

      final Uri callback = Uri.parse(config.shikimoriRedirectUri);
      final (int first, String firstBody) = await getCallback(callback);
      expect(first, 400, reason: firstBody);
      expect(firstBody, contains('authorization code'),
          reason: 'the repository handler answered, not an HTTP mock');

      final (int second, String secondBody) = await getCallback(callback);
      expect(second, 400, reason: 'the server must still be listening: $secondBody');
      expect(loginAuth.exchanges, 0);
    });

    test('a valid code reaches the viewer query, returns 200 and then closes the server', () async {
      final UserRepositoryShikimori loginRepository = await startLogin();
      addTearDown(loginRepository.closeLoginServer);

      final Uri callback = Uri.parse('${config.shikimoriRedirectUri}?code=the-code');
      final (int status, String body) = await getCallback(callback);
      expect(status, 200, reason: body);

      expect(loginAuth.exchanges, 1);
      expect(loginAuth.codes.single, 'the-code');
      expect(viewer.headersLog.single!['Authorization'], 'Bearer access-1');
      expect(viewer.endpoints.single, config.shikimoriGraphQLEndpoint);

      final Box<ShikimoriUserModel> box =
          await Hive.openBox<ShikimoriUserModel>(UserRepositoryShikimori.usersBoxName);
      final ShikimoriUserModel? stored = box.get('tester');
      expect(stored, isNotNull, reason: 'the box is keyed by user.name');
      expect(stored!.accessToken, 'access-1');
      expect(stored.refreshToken, 'refresh-1');
      final SettingsModel storedSettings = stored.settings as SettingsModel;
      expect(storedSettings.userService, Service.shikimori);
      expect(storedSettings.metadataService, Service.shikimori,
          reason: 'WP #164: a new Shikimori account browses Shikimori metadata, '
              'not the AniList default');

      // A successful login is the one request that does close the callback.
      await expectLater(getCallback(callback), throwsA(isA<SocketException>()));
    });
  });
}
// External dependencies
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retry/retry.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/api/shikimori/shikimori_auth_service.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/user_repository_shikimori.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/user/settings.dart';

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

void main() {
  late PagedUserRatesHttpService http;
  late FakeShikimoriAuthService auth;
  late UserRepositoryShikimori repository;

  ShikimoriUserModel account() {
    return ShikimoriUserModel(
      id: '23456789',
      name: 'tester',
      settings: SettingsModel.empty().copyWith(userService: Service.shikimori),
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
}
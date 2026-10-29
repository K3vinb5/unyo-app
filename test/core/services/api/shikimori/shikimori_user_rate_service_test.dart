// External dependencies
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retry/retry.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/api/shikimori/shikimori_auth_service.dart';
import 'package:unyo/core/services/api/shikimori/shikimori_rate_limiter.dart';
import 'package:unyo/core/services/api/shikimori/shikimori_user_rate_service.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/user_repository_shikimori.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

import 'support/fake_rate_limiter_clock.dart';

class MockLogger extends Mock implements Logger {}

class MockUserRepositoryShikimori extends Mock implements UserRepositoryShikimori {}

/// One recorded HTTP exchange, so the assertions can read the real wire shape.
class RecordedRequest {
  final String method;
  final String url;
  final Map<String, String>? headers;
  final Map<String, dynamic>? body;

  const RecordedRequest({
    required this.method,
    required this.url,
    required this.headers,
    required this.body,
  });

  @override
  String toString() => '$method $url body=$body';
}

/// [HttpService] at its public boundary: answers from a queue and records every
/// call (method, URL, headers, decoded body). The DTO/bean chain runs for real on
/// the answers, so a field-name mistake still fails the test.
class RecordingHttpService implements HttpService {
  RecordingHttpService({this.rate, this.getQueue = const <Object>[]});

  /// JSON answered by POST/PATCH/PUT (a single rate object).
  Map<String, dynamic>? rate;

  /// JSON answered by GET, consumed in order (a list of rates or an exception).
  List<Object> getQueue;

  final List<RecordedRequest> requests = <RecordedRequest>[];

  @override
  http.Client get client => throw UnimplementedError('the fake records requests instead');

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
  }) async {
    requests.add(RecordedRequest(method: 'GET', url: endpoint, headers: headers, body: null));
    final Object answer = getQueue.isEmpty ? <dynamic>[] : getQueue.removeAt(0);
    if (answer is Exception) throw answer;
    return ApiResponse<T>(
      data: fromJson(<String, dynamic>{'list': answer}),
      bodyBytes: Uint8List(0),
      statusCode: 200,
      headers: const <String, String>{},
    );
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool ignoreCache = false,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return _answer<T>('POST', endpoint, headers: headers, body: body, fromJson: fromJson);
  }

  @override
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return _answer<T>('PATCH', endpoint, headers: headers, body: body, fromJson: fromJson);
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return _answer<T>('PUT', endpoint, headers: headers, body: body, fromJson: fromJson);
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    requests.add(RecordedRequest(method: 'DELETE', url: endpoint, headers: headers, body: null));
    return ApiResponse<T>(
      data: fromJson(const <String, dynamic>{}),
      bodyBytes: Uint8List(0),
      statusCode: 204,
      headers: const <String, String>{},
    );
  }

  ApiResponse<T> _answer<T>(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    final Map<String, dynamic>? decoded = body is Map<String, dynamic> ? body : null;
    requests.add(RecordedRequest(method: method, url: endpoint, headers: headers, body: decoded));
    return ApiResponse<T>(
      data: fromJson(rate ?? const <String, dynamic>{}),
      bodyBytes: Uint8List(0),
      statusCode: method == 'POST' ? 201 : 200,
      headers: const <String, String>{},
    );
  }
}

/// Auth double: the refresh seam is already injectable on the real service, and
/// here it is replaced outright so the rate tests stay about the rate service.
class FakeShikimoriAuthService extends ShikimoriAuthService {
  FakeShikimoriAuthService({this.expired = false});

  bool expired;
  int refreshes = 0;

  @override
  bool isAccessTokenExpired(ShikimoriUserModel user, {DateTime? at}) => expired;

  @override
  Future<ShikimoriUserModel> withFreshAccessToken(ShikimoriUserModel user) async {
    refreshes++;
    expired = false;
    return user.copyWith(
      accessToken: 'fresh-access',
      refreshToken: 'fresh-refresh',
      accessTokenExpiresAt: '2099-01-01T00:00:00.000',
    );
  }
}

void main() {
  late RecordingHttpService http;
  late FakeShikimoriAuthService auth;
  late MockUserRepositoryShikimori userRepository;
  late ShikimoriUserRateService service;

  ShikimoriUserModel userWith({String expiresAt = '2099-01-01T00:00:00.000'}) {
    return ShikimoriUserModel(
      id: '23456789',
      name: 'tester',
      settings: SettingsModel.empty(),
      avatarImage: '',
      bannerImage: '',
      accessToken: 'stored-access',
      refreshToken: 'stored-refresh',
      accessTokenExpiresAt: expiresAt,
      profileUrl: '',
    );
  }

  Map<String, dynamic> rateJson({
    int id = 16,
    String status = 'watching',
    int score = 0,
    int episodes = 2,
    int rewatches = 0,
    int volumes = 0,
    int chapters = 0,
  }) {
    return <String, dynamic>{
      'id': id,
      'user_id': 23456789,
      'target_id': 15,
      'target_type': 'Anime',
      'score': score,
      'status': status,
      'rewatches': rewatches,
      'episodes': episodes,
      'volumes': volumes,
      'chapters': chapters,
      'text': null,
      'text_html': '',
      'created_at': '2022-11-26T17:19:28.773+03:00',
      'updated_at': '2022-11-26T17:19:28.773+03:00',
    };
  }

  MediaListEntry entry({
    int progress = 0,
    int progressVolumes = 0,
    double score = 0,
    int repeat = 0,
    String status = 'Current',
  }) {
    return MediaListEntryModel(
      progress: progress,
      progressVolumes: progressVolumes,
      score: score,
      repeat: repeat,
      status: status,
      startedAt: const <String>['~', '~', '~'],
      completedAt: const <String>['~', '~', '~'],
    );
  }

  setUpAll(() {
    registerFallbackValue(UserModel.empty());
  });

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(MockLogger());
    final FakeRateLimiterClock clock = FakeRateLimiterClock();
    sl.registerLazySingleton<ShikimoriRateLimiter>(
      () => ShikimoriRateLimiter(clock: clock.now, wait: clock.wait),
    );
    http = RecordingHttpService();
    sl.registerSingleton<HttpService>(http);
    auth = FakeShikimoriAuthService();
    sl.registerSingleton<ShikimoriAuthService>(auth);
    userRepository = MockUserRepositoryShikimori();
    sl.registerSingleton<UserRepositoryShikimori>(userRepository);
    when(() => userRepository.updateUserInfo(any())).thenAnswer((_) async {});
    service = ShikimoriUserRateService();
  });

  group('getEntry', () {
    test('no stored rate degrades to the empty entry and sends the real query', () async {
      final MediaListEntry read = await service.getEntry(
        user: userWith(),
        targetId: 15,
        target: ShikimoriUserRateTarget.anime,
      );

      expect(read.status, MediaListEntryModel.empty().status);
      expect(http.requests, hasLength(1));
      final RecordedRequest request = http.requests.single;
      expect(request.method, 'GET');
      expect(request.url, contains(config.shikimoriUserRatesEndpoint));
      expect(request.url, contains('user_id=23456789'));
      expect(request.url, contains('target_id=15'));
      expect(request.url, contains('target_type=Anime'));
      expect(request.headers!['Authorization'], 'Bearer stored-access');
      expect(request.headers!['User-Agent'], config.shikimoriRequestHeaders['User-Agent']);
    });

    test('rewatching folds into CURRENT and feeds repeat from rewatches', () async {
      http.getQueue = <Object>[
        <Map<String, dynamic>>[rateJson(status: 'rewatching', rewatches: 3, episodes: 7, score: 9, volumes: 1)],
      ];

      final MediaListEntry read = await service.getEntry(
        user: userWith(),
        targetId: 15,
        target: ShikimoriUserRateTarget.anime,
      );

      expect(read.status, 'CURRENT');
      expect(read.repeat, 3, reason: 'rewatching contributes its own rewatches count');
      expect(read.progress, 7);
      expect(read.progressVolumes, 1);
      expect(read.score, 9);
    });

    test('manga progress is read from chapters, not episodes', () async {
      http.getQueue = <Object>[
        <Map<String, dynamic>>[rateJson(status: 'watching', episodes: 0, chapters: 178, volumes: 4)],
      ];

      final MediaListEntry read = await service.getEntry(
        user: userWith(),
        targetId: 105,
        target: ShikimoriUserRateTarget.manga,
      );

      expect(read.progress, 178);
      expect(read.progressVolumes, 4);
    });
  });

  group('updateEntry', () {
    test('no stored rate creates it with POST user_rate{…} and no target guess', () async {
      http.rate = rateJson(id: 17, status: 'watching', episodes: 2, score: 8, rewatches: 2);

      final MediaListEntry written = await service.updateEntry(
        user: userWith(),
        targetId: 15,
        target: ShikimoriUserRateTarget.anime,
        entry: entry(progress: 2, score: 8, repeat: 2, status: 'Current'),
      );

      final RecordedRequest create = http.requests.last;
      expect(create.method, 'POST');
      expect(create.url, config.shikimoriUserRatesEndpoint);
      expect(create.body!['user_rate'], <String, dynamic>{
        'status': 'watching',
        'score': 8,
        'rewatches': 2,
        'volumes': 0,
        'episodes': 2,
        'user_id': 23456789,
        'target_id': 15,
        'target_type': 'Anime',
      });
      expect(written.status, 'CURRENT');
      expect(written.progress, 2);
    });

    test('an existing rate is updated with PATCH on its own id (no user/target fields)', () async {
      http.getQueue = <Object>[
        <Map<String, dynamic>>[rateJson(id: 16, status: 'watching', episodes: 2)],
      ];
      http.rate = rateJson(id: 16, status: 'completed', episodes: 12, score: 10);

      await service.updateEntry(
        user: userWith(),
        targetId: 15,
        target: ShikimoriUserRateTarget.anime,
        entry: entry(progress: 12, score: 10, status: 'Completed'),
      );

      final RecordedRequest update = http.requests.last;
      expect(update.method, 'PATCH');
      expect(update.url, '${config.shikimoriUserRatesEndpoint}/16');
      expect(update.body!['user_rate'], <String, dynamic>{
        'status': 'completed',
        'score': 10,
        'rewatches': 0,
        'volumes': 0,
        'episodes': 12,
      });
      expect(update.body!['user_rate'].containsKey('user_id'), isFalse);
      expect(update.body!['user_rate'].containsKey('target_id'), isFalse);
    });

    test('a single-step progress bump uses the increment endpoint', () async {
      http.getQueue = <Object>[
        <Map<String, dynamic>>[rateJson(id: 16, status: 'watching', episodes: 2, score: 7)],
      ];
      http.rate = rateJson(id: 16, status: 'watching', episodes: 3, score: 7);

      final MediaListEntry written = await service.updateEntry(
        user: userWith(),
        targetId: 15,
        target: ShikimoriUserRateTarget.anime,
        entry: entry(progress: 3, score: 7, status: 'Current'),
      );

      final RecordedRequest increment = http.requests.last;
      expect(increment.method, 'POST');
      expect(increment.url, '${config.shikimoriUserRatesEndpoint}/16/increment');
      expect(increment.body, isEmpty);
      expect(written.progress, 3);
    });

    test('a two-step jump does not use increment (it would only add one)', () async {
      http.getQueue = <Object>[
        <Map<String, dynamic>>[rateJson(id: 16, status: 'watching', episodes: 2)],
      ];
      http.rate = rateJson(id: 16, status: 'watching', episodes: 4);

      await service.updateEntry(
        user: userWith(),
        targetId: 15,
        target: ShikimoriUserRateTarget.anime,
        entry: entry(progress: 4, status: 'Current'),
      );

      expect(http.requests.last.method, 'PATCH');
    });

    test('the empty "add to list" status deletes the stored rate', () async {
      http.getQueue = <Object>[
        <Map<String, dynamic>>[rateJson(id: 16)],
      ];

      final MediaListEntry written = await service.updateEntry(
        user: userWith(),
        targetId: 15,
        target: ShikimoriUserRateTarget.anime,
        entry: MediaListEntryModel.empty(),
      );

      final RecordedRequest delete = http.requests.last;
      expect(delete.method, 'DELETE');
      expect(delete.url, '${config.shikimoriUserRatesEndpoint}/16');
      expect(written.status, MediaListEntryModel.empty().status);
    });

    test('deleting a rate that does not exist sends nothing', () async {
      final MediaListEntry written = await service.updateEntry(
        user: userWith(),
        targetId: 15,
        target: ShikimoriUserRateTarget.anime,
        entry: MediaListEntryModel.empty(),
      );

      expect(http.requests, hasLength(1), reason: 'only the lookup GET');
      expect(http.requests.single.method, 'GET');
      expect(written.status, MediaListEntryModel.empty().status);
    });
  });

  group('token lifetime', () {
    test('an expired token is refreshed before the call and re-persisted', () async {
      auth.expired = true;
      http.rate = rateJson(id: 17);

      await service.updateEntry(
        user: userWith(expiresAt: '2000-01-01T00:00:00.000'),
        targetId: 15,
        target: ShikimoriUserRateTarget.anime,
        entry: entry(progress: 1, status: 'Current'),
      );

      expect(auth.refreshes, 1);
      verify(() => userRepository.updateUserInfo(any())).called(1);
      expect(http.requests.first.headers!['Authorization'], 'Bearer fresh-access',
          reason: 'the refreshed token must be the one on the wire');
    });

    test('a 401 mid-flight refreshes once and retries with the new token', () async {
      http.getQueue = <Object>[
        HttpServerException(401, 'invalid_token'),
        <Map<String, dynamic>>[rateJson(id: 16, status: 'watching', episodes: 5)],
      ];

      final MediaListEntry read = await service.getEntry(
        user: userWith(),
        targetId: 15,
        target: ShikimoriUserRateTarget.anime,
      );

      expect(http.requests, hasLength(2));
      expect(auth.refreshes, 1);
      expect(http.requests[0].headers!['Authorization'], 'Bearer stored-access');
      expect(http.requests[1].headers!['Authorization'], 'Bearer fresh-access');
      expect(read.progress, 5);
    });

    test('a second 401 is not retried again (no hot loop)', () async {
      http.getQueue = <Object>[
        HttpServerException(401, 'invalid_token'),
        HttpServerException(401, 'invalid_token'),
      ];

      await expectLater(
        service.getEntry(user: userWith(), targetId: 15, target: ShikimoriUserRateTarget.anime),
        throwsA(isA<HttpServerException>()),
      );
      expect(http.requests, hasLength(2));
      expect(auth.refreshes, 1);
    });
  });
}

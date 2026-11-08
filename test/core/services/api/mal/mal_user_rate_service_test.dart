// External dependencies
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/api/mal/mal_auth_service.dart';
import 'package:unyo/data/models/mal/media/mal_list_status_policy.dart';
import 'package:unyo/core/services/api/mal/mal_rate_limiter.dart';
import 'package:unyo/core/services/api/mal/mal_user_rate_service.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/data/repositories/user_repository_mal.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

import '../shikimori/support/fake_rate_limiter_clock.dart';

class MockLogger extends Mock implements Logger {}

class MockUserRepositoryMal extends Mock implements UserRepositoryMal {}

/// One recorded HTTP exchange, so the assertions can read the real wire shape.
class RecordedRequest {
  final String method;
  final Uri url;
  final Map<String, String> headers;
  final String body;

  const RecordedRequest({
    required this.method,
    required this.url,
    required this.headers,
    required this.body,
  });

  Map<String, String> get bodyFields {
    final Map<String, String> fields = <String, String>{};
    for (final String pair in body.split('&')) {
      if (pair.isEmpty) continue;
      final int eq = pair.indexOf('=');
      if (eq < 0) continue;
      fields[Uri.decodeQueryComponent(pair.substring(0, eq))] =
          Uri.decodeQueryComponent(pair.substring(eq + 1));
    }
    return fields;
  }

  @override
  String toString() => '$method $url body=$body';
}

/// Auth double: the refresh seam is already injectable on the real service, and
/// here it is replaced outright so the rate tests stay about the rate service.
class FakeMalAuthService extends MalAuthService {
  FakeMalAuthService({this.expired = false});

  bool expired;
  int refreshes = 0;

  @override
  bool isAccessTokenExpired(MalUserModel user, {DateTime? at}) => expired;

  @override
  Future<MalUserModel> withFreshAccessToken(MalUserModel user) async {
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
  late List<RecordedRequest> requests;
  late FakeMalAuthService auth;
  late MockUserRepositoryMal userRepository;
  late MalUserRateService service;

  /// Scripted answers consumed in order: `http.Response` sentinels via status
  /// codes + body strings, or exceptions.
  late List<Object> answers;

  MalUserModel userWith({String expiresAt = '2099-01-01T00:00:00.000'}) {
    return MalUserModel(
      id: '56789',
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
    sl.registerLazySingleton<MalRateLimiter>(
      () => MalRateLimiter(clock: clock.now, wait: clock.wait),
    );
    auth = FakeMalAuthService();
    sl.registerSingleton<MalAuthService>(auth);
    userRepository = MockUserRepositoryMal();
    sl.registerSingleton<UserRepositoryMal>(userRepository);
    when(() => userRepository.updateUserInfo(any())).thenAnswer((_) async {});
    requests = <RecordedRequest>[];
    answers = <Object>[];
    service = MalUserRateService(
      client: MockClient((http.Request request) async {
        requests.add(RecordedRequest(
          method: request.method,
          url: request.url,
          headers: request.headers,
          body: request.body,
        ));
        if (answers.isEmpty) {
          return http.Response('{}', 200);
        }
        final Object answer = answers.removeAt(0);
        if (answer is Exception) throw answer;
        final (int status, String body) = answer as (int, String);
        return http.Response(body, status);
      }),
    );
  });

  group('getEntry', () {
    test('no my_list_status degrades to the empty entry and asks for the field', () async {
      answers = <Object>[(200, '{"id": 15, "title": "Cowboy Bebop"}')];

      final MediaListEntry read = await service.getEntry(
        user: userWith(),
        targetId: 15,
        target: MalListTarget.anime,
      );

      expect(read.status, MediaListEntryModel.empty().status);
      final RecordedRequest request = requests.single;
      expect(request.method, 'GET');
      expect(request.url.toString(), '${config.malApiBase}/anime/15?fields=my_list_status');
      expect(request.headers['authorization'], 'Bearer stored-access');
    });

    test('anime reads num_episodes_watched (the response key) as progress', () async {
      answers = <Object>[
        (
          200,
          jsonEncode(<String, dynamic>{
            'id': 15,
            'my_list_status': <String, dynamic>{
              'status': 'watching',
              'score': 9,
              'num_episodes_watched': 7,
              'is_rewatching': true,
              'num_times_rewatched': 3,
              'updated_at': '2022-11-26T17:19:28+00:00',
            },
          }),
        ),
      ];

      final MediaListEntry read = await service.getEntry(
        user: userWith(),
        targetId: 15,
        target: MalListTarget.anime,
      );

      expect(read.status, 'CURRENT', reason: 'is_rewatching folds into CURRENT, like Shikimori rewatching');
      expect(read.progress, 7);
      expect(read.repeat, 3, reason: 'num_times_rewatched feeds repeat without adding one');
      expect(read.score, 9);
      expect(read.progressVolumes, 0, reason: 'anime has no volume progress');
    });

    test('manga reads num_chapters_read/num_volumes_read/num_times_reread', () async {
      answers = <Object>[
        (
          200,
          jsonEncode(<String, dynamic>{
            'id': 105,
            'my_list_status': <String, dynamic>{
              'status': 'reading',
              'score': 8,
              'num_chapters_read': 178,
              'num_volumes_read': 4,
              'num_times_reread': 1,
            },
          }),
        ),
      ];

      final MediaListEntry read = await service.getEntry(
        user: userWith(),
        targetId: 105,
        target: MalListTarget.manga,
      );

      expect(read.progress, 178);
      expect(read.progressVolumes, 4);
      expect(read.repeat, 1);
      expect(read.status, 'CURRENT');
    });

    test('plan_to_watch maps to PLANNING and start/finish dates map onto the entry', () async {
      answers = <Object>[
        (
          200,
          jsonEncode(<String, dynamic>{
            'id': 30230,
            'my_list_status': <String, dynamic>{
              'status': 'plan_to_watch',
              'score': 0,
              'start_date': '2022-11-26',
              'finish_date': '2023-01-28',
            },
          }),
        ),
      ];

      final MediaListEntry read = await service.getEntry(
        user: userWith(),
        targetId: 30230,
        target: MalListTarget.anime,
      );

      expect(read.status, 'PLANNING');
      expect(read.score, 0, reason: '0 is MAL\'s "unscored" value and round trips as 0');
      expect(read.startedAt, <String>['26', '11', '2022']);
      expect(read.completedAt, <String>['28', '1', '2023']);
    });

    test('a 404 media id degrades to the empty entry (the editor shows "add to list")', () async {
      answers = <Object>[(404, '{"error":"not_found"}')];

      final MediaListEntry read = await service.getEntry(
        user: userWith(),
        targetId: 999999,
        target: MalListTarget.anime,
      );

      expect(read.status, MediaListEntryModel.empty().status);
    });

    test('a non-positive id is rejected before any request', () async {
      await expectLater(
        service.getEntry(user: userWith(), targetId: 0, target: MalListTarget.anime),
        throwsA(isA<ArgumentError>()),
      );
      expect(requests, isEmpty);
    });
  });

  group('updateEntry', () {
    test('an anime write sends num_watched_episodes (the request key) and nothing else', () async {
      answers = <Object>[
        (
          200,
          jsonEncode(<String, dynamic>{
            'status': 'completed',
            'score': 10,
            'num_episodes_watched': 12,
            'is_rewatching': false,
            'num_times_rewatched': 1,
          }),
        ),
      ];

      final MediaListEntry written = await service.updateEntry(
        user: userWith(),
        targetId: 15,
        target: MalListTarget.anime,
        entry: entry(progress: 12, score: 10, repeat: 1, status: 'Completed'),
      );

      final RecordedRequest update = requests.single;
      expect(update.method, 'PUT');
      expect(update.url.toString(), '${config.malApiBase}/anime/15/my_list_status');
      expect(
        update.headers['content-type'],
        startsWith('application/x-www-form-urlencoded'),
        reason: 'the my_list_status endpoint takes form fields, not JSON',
      );
      expect(update.bodyFields, <String, String>{
        'status': 'completed',
        'score': '10',
        'num_watched_episodes': '12',
        'is_rewatching': 'false',
        'num_times_rewatched': '1',
      });
      expect(update.bodyFields.containsKey('num_episodes_watched'), isFalse,
          reason: 'the response key on a request is bad_request "extra fields"');
      expect(update.bodyFields.containsKey('num_volumes_read'), isFalse);
      expect(written.status, 'COMPLETED');
      expect(written.progress, 12);
      expect(written.repeat, 1);
    });

    test('a manga write sends the manga counters, including volumes', () async {
      answers = <Object>[
        (
          200,
          jsonEncode(<String, dynamic>{
            'status': 'reading',
            'score': 8,
            'num_chapters_read': 178,
            'num_volumes_read': 4,
            'is_rereading': true,
            'num_times_reread': 2,
          }),
        ),
      ];

      await service.updateEntry(
        user: userWith(),
        targetId: 105,
        target: MalListTarget.manga,
        entry: entry(progress: 178, progressVolumes: 4, score: 8, repeat: 2, status: 'Current'),
      );

      expect(requests.single.bodyFields, <String, String>{
        'status': 'reading',
        'score': '8',
        'num_chapters_read': '178',
        'num_volumes_read': '4',
        'is_rereading': 'false',
        'num_times_reread': '2',
      }, reason: 'only REPEATING owns the rewatch flag; a Current write keeps it off');
    });

    test('REPEATING writes the current status plus the rewatch flag', () async {
      answers = <Object>[
        (
          200,
          jsonEncode(<String, dynamic>{'status': 'watching', 'num_episodes_watched': 1}),
        ),
      ];

      await service.updateEntry(
        user: userWith(),
        targetId: 15,
        target: MalListTarget.anime,
        entry: entry(progress: 1, status: 'Repeating'),
      );

      expect(requests.single.bodyFields['status'], 'watching');
      expect(requests.single.bodyFields['is_rewatching'], 'true');
    });

    test('the empty "add to list" status deletes the stored entry', () async {
      answers = <Object>[(200, '')];

      final MediaListEntry written = await service.updateEntry(
        user: userWith(),
        targetId: 15,
        target: MalListTarget.anime,
        entry: MediaListEntryModel.empty(),
      );

      final RecordedRequest delete = requests.single;
      expect(delete.method, 'DELETE');
      expect(delete.url.toString(), '${config.malApiBase}/anime/15/my_list_status');
      expect(written.status, MediaListEntryModel.empty().status);
    });

    test('a 404 on delete is the desired end state, not an error', () async {
      answers = <Object>[(404, '{"error":"not_found"}')];

      final MediaListEntry written = await service.updateEntry(
        user: userWith(),
        targetId: 15,
        target: MalListTarget.anime,
        entry: MediaListEntryModel.empty(),
      );

      expect(written.status, MediaListEntryModel.empty().status);
      expect(requests, hasLength(1));
    });
  });

  group('token lifetime', () {
    test('an expired token is refreshed before the call and re-persisted', () async {
      auth.expired = true;
      answers = <Object>[
        (200, jsonEncode(<String, dynamic>{'status': 'watching', 'num_episodes_watched': 1})),
      ];

      await service.updateEntry(
        user: userWith(expiresAt: '2000-01-01T00:00:00.000'),
        targetId: 15,
        target: MalListTarget.anime,
        entry: entry(progress: 1, status: 'Current'),
      );

      expect(auth.refreshes, 1);
      verify(() => userRepository.updateUserInfo(any())).called(1);
      expect(requests.single.headers['authorization'], 'Bearer fresh-access',
          reason: 'the refreshed token must be the one on the wire');
    });

    test('a 401 mid-flight refreshes once and retries with the new token', () async {
      answers = <Object>[
        (401, '{"error":"invalid_token"}'),
        (
          200,
          jsonEncode(<String, dynamic>{
            'id': 15,
            'my_list_status': <String, dynamic>{'status': 'watching', 'num_episodes_watched': 5},
          }),
        ),
      ];

      final MediaListEntry read = await service.getEntry(
        user: userWith(),
        targetId: 15,
        target: MalListTarget.anime,
      );

      expect(requests, hasLength(2));
      expect(auth.refreshes, 1);
      expect(requests[0].headers['authorization'], 'Bearer stored-access');
      expect(requests[1].headers['authorization'], 'Bearer fresh-access');
      expect(read.progress, 5);
    });

    test('a second 401 is not retried again (no hot loop)', () async {
      answers = <Object>[
        (401, '{"error":"invalid_token"}'),
        (401, '{"error":"invalid_token"}'),
      ];

      await expectLater(
        service.getEntry(user: userWith(), targetId: 15, target: MalListTarget.anime),
        throwsA(isA<HttpServerException>()),
      );
      expect(requests, hasLength(2));
      expect(auth.refreshes, 1);
    });

    test('a 403 is throttling, not an auth failure: no refresh and no retry', () async {
      answers = <Object>[
        (403, '{"error":"too_many_requests"}'),
        (200, jsonEncode(<String, dynamic>{'status': 'watching'})),
      ];

      await expectLater(
        service.getEntry(user: userWith(), targetId: 15, target: MalListTarget.anime),
        throwsA(isA<HttpServerException>().having((HttpServerException e) => e.statusCode, 'statusCode', 403)),
      );
      expect(auth.refreshes, 0, reason: '403 must never trigger the 401 token-refresh path');
      expect(requests, hasLength(1), reason: 'a throttled call is surfaced, never re-fired');
    });
  });
}

// External dependencies
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/services/api/mal/mal_auth_service.dart';
import 'package:unyo/core/services/api/mal/mal_rate_limiter.dart';
import 'package:unyo/core/services/api/mal/mal_user_rate_service.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/data/repositories/anime_repository_mal.dart';
import 'package:unyo/data/repositories/user_repository_mal.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/title.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

import '../../core/services/api/shikimori/support/fake_rate_limiter_clock.dart';
import 'support/fake_mal_wire.dart';

/// Repository-level tests for [AnimeRepositoryMal].
///
/// The real [MalUserRateService] runs under the repository (the wire is faked
/// at the `http.Client` boundary), so every assertion sees the request the
/// repository+service chain actually produced — the same layering the
/// Shikimori repository tests use.
void main() {
  late MalWireDouble wire;
  late FakeMalAuthService auth;
  late MockUserRepositoryMal userRepository;
  late AnimeRepositoryMal repository;

  setUpAll(() {
    registerFallbackValue(UserModel.empty());
  });

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));
    final FakeRateLimiterClock clock = FakeRateLimiterClock();
    sl.registerLazySingleton<MalRateLimiter>(
      () => MalRateLimiter(clock: clock.now, wait: clock.wait),
    );
    auth = FakeMalAuthService();
    sl.registerSingleton<MalAuthService>(auth);
    userRepository = MockUserRepositoryMal();
    sl.registerSingleton<UserRepositoryMal>(userRepository);
    when(() => userRepository.updateUserInfo(any())).thenAnswer((_) async {});
    wire = MalWireDouble();
    sl.registerSingleton<MalUserRateService>(MalUserRateService(client: wire.createClient()));
    repository = AnimeRepositoryMal();
  });

  MalUserModel malUser() {
    return MalUserModel(
      id: '56789',
      name: 'tester',
      settings: SettingsModel.empty(),
      avatarImage: '',
      bannerImage: '',
      accessToken: 'stored-access',
      refreshToken: 'stored-refresh',
      accessTokenExpiresAt: '2099-01-01T00:00:00.000',
      profileUrl: '',
    );
  }

  Anime anime({int id = 58514}) {
    return AnimeModel.empty().copyWith(
      id: id,
      idMal: id,
      title: const TitleModel(
        romaji: 'Kusuriya no Hitorigoto',
        english: '',
        nativeTitle: '',
        userPreferred: 'Kusuriya no Hitorigoto',
      ),
    );
  }

  MediaListEntry entry({
    int progress = 0,
    double score = 0,
    int repeat = 0,
    String status = 'CURRENT',
  }) {
    return MediaListEntryModel(
      progress: progress,
      progressVolumes: 0,
      score: score,
      repeat: repeat,
      status: status,
      startedAt: const <String>['~', '~', '~'],
      completedAt: const <String>['~', '~', '~'],
    );
  }

  group('AnimeRepositoryMal list entries', () {
    test('getMediaListEntry passes the record id and the anime kind to MAL', () async {
      wire.answers = <Object>[
        (
          200,
          jsonEncode(<String, dynamic>{
            'id': 58514,
            'my_list_status': <String, dynamic>{
              'status': 'watching',
              'score': 9,
              'num_episodes_watched': 7,
              'is_rewatching': false,
              'num_times_rewatched': 1,
            },
          }),
        ),
      ];

      final MediaListEntry read = await repository.getMediaListEntry(anime(), malUser());

      expect(read.status, 'CURRENT');
      expect(read.progress, 7);
      expect(read.score, 9);
      expect(read.repeat, 1);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.method, 'GET');
      expect(request.url.toString(), '${config.malApiBase}/anime/58514?fields=my_list_status');
      expect(request.headers['authorization'], 'Bearer stored-access');
    });

    test('updateMediaListEntry writes through the anime my_list_status upsert', () async {
      wire.answers = <Object>[
        (
          200,
          jsonEncode(<String, dynamic>{
            'status': 'watching',
            'score': 8,
            'num_episodes_watched': 3,
            'is_rewatching': false,
            'num_times_rewatched': 0,
          }),
        ),
      ];

      final MediaListEntry written = await repository.updateMediaListEntry(
        entry(progress: 3, score: 8),
        anime(),
        malUser(),
      );

      expect(written.progress, 3);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.method, 'PUT');
      expect(request.url.toString(), '${config.malApiBase}/anime/58514/my_list_status');
      expect(request.headers['authorization'], 'Bearer stored-access');
      expect(request.headers['content-type'], contains('application/x-www-form-urlencoded'));
      // The write key is num_watched_episodes; the response key is
      // num_episodes_watched (SPEC §3 quirk) — only the write key may be sent.
      expect(request.bodyFields['num_watched_episodes'], '3');
      expect(request.bodyFields.containsKey('num_episodes_watched'), isFalse);
      expect(request.bodyFields['num_chapters_read'], isNull);
      expect(request.bodyFields['status'], 'watching');
      expect(request.bodyFields['score'], '8');
    });

    test('a title with no list status reads as the empty entry', () async {
      wire.answers = <Object>[(200, jsonEncode(<String, dynamic>{'id': 58514, 'title': 'x'}))];

      final MediaListEntry read = await repository.getMediaListEntry(anime(), malUser());

      expect(read.status, MediaListEntryModel.empty().status);
    });

    test('a 404 media id reads as the empty entry', () async {
      wire.answers = <Object>[(404, '{}')];

      final MediaListEntry read = await repository.getMediaListEntry(anime(id: 1), malUser());

      expect(read.status, MediaListEntryModel.empty().status);
    });

    test('an empty-status entry is the delete and returns the empty entry', () async {
      wire.answers = <Object>[(204, '')];

      final MediaListEntry written = await repository.updateMediaListEntry(
        MediaListEntryModel.empty(),
        anime(),
        malUser(),
      );

      expect(written.status, MediaListEntryModel.empty().status);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.method, 'DELETE');
      expect(request.url.toString(), '${config.malApiBase}/anime/58514/my_list_status');
    });

    test('a non-MyAnimeList account degrades to the empty entry without any request', () async {
      final MediaListEntry read = await repository.getMediaListEntry(anime(), UserModel.empty());
      final MediaListEntry written = await repository.updateMediaListEntry(
        entry(progress: 1),
        anime(),
        UserModel.empty(),
      );

      expect(read.status, MediaListEntryModel.empty().status);
      expect(written.status, MediaListEntryModel.empty().status);
      expect(wire.requests, isEmpty);
      expect(auth.refreshes, 0);
    });

    test('metadata methods are deliberate stubs, not fabricated data', () async {
      await expectLater(
        repository.getAnimeDetails(anime(), malUser()),
        throwsA(isA<UnimplementedError>().having(
          (UnimplementedError e) => e.message,
          'message',
          contains('tracker-only provider'),
        )),
      );
      await expectLater(
        repository.getTrendingAnimes(1, malUser()),
        throwsA(isA<UnimplementedError>()),
      );
      await expectLater(
        repository.getMediaCoverImages(malUser()),
        throwsA(isA<UnimplementedError>()),
      );
      expect(wire.requests, isEmpty);
    });
  });
}

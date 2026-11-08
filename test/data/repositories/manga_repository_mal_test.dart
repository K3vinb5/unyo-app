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
import 'package:unyo/data/repositories/manga_repository_mal.dart';
import 'package:unyo/data/repositories/user_repository_mal.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/title.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

import '../../core/services/api/shikimori/support/fake_rate_limiter_clock.dart';
import 'support/fake_mal_wire.dart';

/// Repository-level tests for [MangaRepositoryMal].
///
/// The real [MalUserRateService] runs under the repository (wire faked at the
/// `http.Client` boundary) — mirror of the anime repository suite, on the
/// manga kind and its chapter/volume counters.
void main() {
  late MalWireDouble wire;
  late FakeMalAuthService auth;
  late MockUserRepositoryMal userRepository;
  late MangaRepositoryMal repository;

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
    repository = MangaRepositoryMal();
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

  Manga manga({int id = 30002}) {
    return MangaModel.empty().copyWith(
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
    int progressVolumes = 0,
    double score = 0,
    int repeat = 0,
    String status = 'CURRENT',
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

  group('MangaRepositoryMal list entries', () {
    test('getMediaListEntry passes the record id and the manga kind to MAL', () async {
      wire.answers = <Object>[
        (
          200,
          jsonEncode(<String, dynamic>{
            'id': 30002,
            'my_list_status': <String, dynamic>{
              'status': 'reading',
              'score': 7,
              'num_chapters_read': 12,
              'num_volumes_read': 2,
              'is_rereading': false,
              'num_times_reread': 1,
            },
          }),
        ),
      ];

      final MediaListEntry read = await repository.getMediaListEntry(manga(), malUser());

      expect(read.status, 'CURRENT');
      expect(read.progress, 12);
      expect(read.progressVolumes, 2);
      expect(read.score, 7);
      expect(read.repeat, 1);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.method, 'GET');
      expect(request.url.toString(), '${config.malApiBase}/manga/30002?fields=my_list_status');
      expect(request.headers['authorization'], 'Bearer stored-access');
    });

    test('updateMediaListEntry writes the manga counters, never the anime ones', () async {
      wire.answers = <Object>[
        (
          200,
          jsonEncode(<String, dynamic>{
            'status': 'reading',
            'score': 8,
            'num_chapters_read': 5,
            'num_volumes_read': 1,
            'is_rereading': false,
            'num_times_reread': 0,
          }),
        ),
      ];

      final MediaListEntry written = await repository.updateMediaListEntry(
        entry(progress: 5, progressVolumes: 1, score: 8),
        manga(),
        malUser(),
      );

      expect(written.progress, 5);
      expect(written.progressVolumes, 1);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.method, 'PUT');
      expect(request.url.toString(), '${config.malApiBase}/manga/30002/my_list_status');
      expect(request.headers['content-type'], contains('application/x-www-form-urlencoded'));
      expect(request.bodyFields['num_chapters_read'], '5');
      expect(request.bodyFields['num_volumes_read'], '1');
      expect(request.bodyFields.containsKey('num_watched_episodes'), isFalse);
      expect(request.bodyFields['status'], 'reading');
      expect(request.bodyFields['score'], '8');
    });

    test('a title with no list status reads as the empty entry', () async {
      wire.answers = <Object>[(200, jsonEncode(<String, dynamic>{'id': 30002, 'title': 'x'}))];

      final MediaListEntry read = await repository.getMediaListEntry(manga(), malUser());

      expect(read.status, MediaListEntryModel.empty().status);
    });

    test('an empty-status entry is the delete and returns the empty entry', () async {
      wire.answers = <Object>[(204, '')];

      final MediaListEntry written = await repository.updateMediaListEntry(
        MediaListEntryModel.empty(),
        manga(),
        malUser(),
      );

      expect(written.status, MediaListEntryModel.empty().status);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.method, 'DELETE');
      expect(request.url.toString(), '${config.malApiBase}/manga/30002/my_list_status');
    });

    test('a non-MyAnimeList account degrades to the empty entry without any request', () async {
      final MediaListEntry read = await repository.getMediaListEntry(manga(), UserModel.empty());
      final MediaListEntry written = await repository.updateMediaListEntry(
        entry(progress: 1),
        manga(),
        UserModel.empty(),
      );

      expect(read.status, MediaListEntryModel.empty().status);
      expect(written.status, MediaListEntryModel.empty().status);
      expect(wire.requests, isEmpty);
    });

    test('metadata methods are deliberate stubs, not fabricated data', () async {
      await expectLater(
        repository.getMangaDetails(manga(), malUser()),
        throwsA(isA<UnimplementedError>().having(
          (UnimplementedError e) => e.message,
          'message',
          contains('tracker-only provider'),
        )),
      );
      await expectLater(
        repository.getPopularMangas(1, malUser()),
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

// External dependencies
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/anime_cubit.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/notification/anime_genres_notifier.dart';
import 'package:unyo/core/notification/anime_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';

class MockAnimeRepository extends Mock implements AnimeRepository {}

class MockUserNotifier extends Mock implements UserNotifier {}

class MockAnimeNotifier extends Mock implements AnimeNotifier {}

class MockAnimeGenresNotifier extends Mock implements AnimeGenresNotifier {}

class MockMediaListNotifier extends Mock implements MediaListNotifier {}

class MockReloadNotifier extends Mock implements ReloadNotifier {}

void main() {
  late AnimeCubit cubit;
  late MockAnimeRepository animeRepository;
  late MockUserNotifier userNotifier;
  late MockAnimeNotifier animeNotifier;
  late MockAnimeGenresNotifier animeGenresNotifier;
  late MockMediaListNotifier mediaListNotifier;
  late MockReloadNotifier reloadNotifier;
  late StreamController<User> userStreamController;
  late StreamController<ReloadType> reloadStreamController;

  final AnilistUserModel loggedUser = AnilistUserModel(
    id: '1',
    name: 'test',
    settings: SettingsModel.empty(),
    avatarImage: '',
    bannerImage: '',
    accessCode: '',
    accessToken: '',
    refreshToken: '',
  );

  void stubLists() {
    when(() => animeRepository.getRecentlyReleasedAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => (true, <Anime>[]));
    when(() => animeRepository.getTrendingAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => (true, <Anime>[]));
    when(() => animeRepository.getRecentlyCompletedAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => (true, <Anime>[]));
    when(() => animeRepository.getPopularAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => (true, <Anime>[]));
    when(() => animeRepository.getUpcomingAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => (true, <Anime>[]));
  }

  void verifyEachListCalledOnce({required bool ignoreCache}) {
    verify(() => animeRepository.getRecentlyReleasedAnimes(1, any(), ignoreCache: ignoreCache)).called(1);
    verify(() => animeRepository.getTrendingAnimes(1, any(), ignoreCache: ignoreCache)).called(1);
    verify(() => animeRepository.getRecentlyCompletedAnimes(1, any(), ignoreCache: ignoreCache)).called(1);
    verify(() => animeRepository.getPopularAnimes(1, any(), ignoreCache: ignoreCache)).called(1);
    verify(() => animeRepository.getUpcomingAnimes(1, any(), ignoreCache: ignoreCache)).called(1);
  }

  setUpAll(() {
    registerFallbackValue(UserModel.empty());
  });

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));

    animeRepository = MockAnimeRepository();
    userNotifier = MockUserNotifier();
    animeNotifier = MockAnimeNotifier();
    animeGenresNotifier = MockAnimeGenresNotifier();
    mediaListNotifier = MockMediaListNotifier();
    reloadNotifier = MockReloadNotifier();

    userStreamController = StreamController<User>.broadcast();
    reloadStreamController = StreamController<ReloadType>.broadcast();
    addTearDown(userStreamController.close);
    addTearDown(reloadStreamController.close);
    when(() => userNotifier.userStream).thenAnswer((_) => userStreamController.stream);
    when(() => reloadNotifier.reloadStream).thenAnswer((_) => reloadStreamController.stream);

    stubLists();
  });

  tearDown(() async {
    await cubit.close();
  });

  group('AnimeCubit metadata-service reload', () {
    test('a reload on a loaded screen refetches the five lists with ignoreCache: true', () async {
      cubit = AnimeCubit(
        animeRepository,
        userNotifier,
        animeNotifier,
        animeGenresNotifier,
        mediaListNotifier,
        reloadNotifier,
      );
      userStreamController.add(loggedUser);
      await pumpEventQueue();

      expect(cubit.state.userLoaded, isTrue);
      verifyEachListCalledOnce(ignoreCache: false);

      reloadStreamController.add(ReloadType.newMetadataService);
      await pumpEventQueue();

      verifyEachListCalledOnce(ignoreCache: true);
    });

    test('a reload while the initial load is still running does not fetch twice', () async {
      final Completer<(bool, List<Anime>)> pendingRecentlyReleased = Completer<(bool, List<Anime>)>();
      when(() => animeRepository.getRecentlyReleasedAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) => pendingRecentlyReleased.future);

      cubit = AnimeCubit(
        animeRepository,
        userNotifier,
        animeNotifier,
        animeGenresNotifier,
        mediaListNotifier,
        reloadNotifier,
      );
      userStreamController.add(loggedUser);
      await pumpEventQueue();
      expect(cubit.state.userLoaded, isFalse, reason: 'the initial load is still awaiting its first fetch');

      reloadStreamController.add(ReloadType.newMetadataService);
      await pumpEventQueue();

      verifyNever(() => animeRepository.getRecentlyReleasedAnimes(1, any(), ignoreCache: true));
      verifyNever(() => animeRepository.getTrendingAnimes(any(), any(), ignoreCache: true));
      verifyNever(() => animeRepository.getRecentlyCompletedAnimes(any(), any(), ignoreCache: true));
      verifyNever(() => animeRepository.getPopularAnimes(any(), any(), ignoreCache: true));
      verifyNever(() => animeRepository.getUpcomingAnimes(any(), any(), ignoreCache: true));

      pendingRecentlyReleased.complete((true, <Anime>[]));
      await pumpEventQueue();
      verifyEachListCalledOnce(ignoreCache: false);
    });
  });
}

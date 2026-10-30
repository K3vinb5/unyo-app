// External dependencies
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/manga_cubit.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/notification/manga_genres_notifier.dart';
import 'package:unyo/core/notification/manga_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';

class MockMangaRepository extends Mock implements MangaRepository {}

class MockUserNotifier extends Mock implements UserNotifier {}

class MockMangaNotifier extends Mock implements MangaNotifier {}

class MockMangaGenresNotifier extends Mock implements MangaGenresNotifier {}

class MockMediaListNotifier extends Mock implements MediaListNotifier {}

class MockReloadNotifier extends Mock implements ReloadNotifier {}

void main() {
  late MangaCubit cubit;
  late MockMangaRepository mangaRepository;
  late MockUserNotifier userNotifier;
  late MockMangaNotifier mangaNotifier;
  late MockMangaGenresNotifier mangaGenresNotifier;
  late MockMediaListNotifier mediaListNotifier;
  late MockReloadNotifier reloadNotifier;
  late StreamController<User> userStreamController;
  late StreamController<ReloadType> reloadStreamController;

  AnilistUserModel userWith(Service metadataService) {
    return AnilistUserModel(
      id: '1',
      name: 'test',
      settings: SettingsModel.empty().copyWith(metadataService: metadataService),
      avatarImage: '',
      bannerImage: '',
      accessCode: '',
      accessToken: '',
      refreshToken: '',
    );
  }

  MangaCubit buildCubit() {
    return MangaCubit(
      mangaRepository,
      userNotifier,
      mangaNotifier,
      mangaGenresNotifier,
      mediaListNotifier,
      reloadNotifier,
    );
  }

  void stubLists() {
    when(() => mangaRepository.getTrendingMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => (true, <Manga>[]));
    when(() => mangaRepository.getRecentlyCompletedMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => (true, <Manga>[]));
    when(() => mangaRepository.getPopularMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => (true, <Manga>[]));
    when(() => mangaRepository.getUpcomingMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => (true, <Manga>[]));
  }

  setUpAll(() {
    registerFallbackValue(UserModel.empty());
  });

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));

    mangaRepository = MockMangaRepository();
    userNotifier = MockUserNotifier();
    mangaNotifier = MockMangaNotifier();
    mangaGenresNotifier = MockMangaGenresNotifier();
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

  group('MangaCubit unsupported metadata provider', () {
    test('an unimplemented provider settles into the explicit unavailable state instead of an empty list', () async {
      cubit = buildCubit();
      userStreamController.add(userWith(Service.mal));
      await pumpEventQueue();

      expect(cubit.state.metadataServiceSupported, isFalse);
      expect(cubit.state.userLoaded, isTrue, reason: 'the screen must stop shimmering');
      expect(cubit.state.trending.$2, isEmpty);
      verifyNever(() => mangaRepository.getTrendingMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')));
      verifyNever(() => mangaRepository.getPopularMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')));
    });

    test('a reload after switching back to AniList clears the unavailable state and fetches', () async {
      cubit = buildCubit();
      userStreamController.add(userWith(Service.mal));
      await pumpEventQueue();
      expect(cubit.state.metadataServiceSupported, isFalse);

      userStreamController.add(userWith(Service.anilist));
      await pumpEventQueue();
      reloadStreamController.add(ReloadType.newMetadataService);
      await pumpEventQueue();

      expect(cubit.state.metadataServiceSupported, isTrue);
      verify(() => mangaRepository.getTrendingMangas(1, any(), ignoreCache: true)).called(1);
      verify(() => mangaRepository.getRecentlyCompletedMangas(1, any(), ignoreCache: true)).called(1);
      verify(() => mangaRepository.getPopularMangas(1, any(), ignoreCache: true)).called(1);
      verify(() => mangaRepository.getUpcomingMangas(1, any(), ignoreCache: true)).called(1);
    });

    test('a provider switch during the initial load lands on the new provider', () async {
      final Completer<(bool, List<Manga>)> initialFetch = Completer<(bool, List<Manga>)>();
      bool gated = false;
      when(() => mangaRepository.getTrendingMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((Invocation invocation) {
        bool ignoreCache = invocation.namedArguments[#ignoreCache] as bool;
        if (!ignoreCache && !gated) {
          gated = true;
          return initialFetch.future;
        }
        return Future<(bool, List<Manga>)>.value((true, <Manga>[MangaModel.empty()]));
      });

      cubit = buildCubit();
      userStreamController.add(userWith(Service.anilist));
      await pumpEventQueue();
      expect(cubit.state.userLoaded, isFalse, reason: 'the initial load is still awaiting its first fetch');

      // MAL has no manga implementation, and it is picked mid-load.
      userStreamController.add(userWith(Service.mal));
      await pumpEventQueue();
      reloadStreamController.add(ReloadType.newMetadataService);
      await pumpEventQueue();

      initialFetch.complete((true, <Manga>[MangaModel.empty()]));
      await pumpEventQueue();

      expect(cubit.state.userLoaded, isTrue);
      expect(
        cubit.state.metadataServiceSupported,
        isFalse,
        reason: 'the queued switch must re-run against MAL, not the provider the load captured',
      );
      expect(cubit.state.trending.$2, isEmpty, reason: 'the previous provider\'s rows must not survive the switch');
      verifyNever(() => mangaRepository.getPopularMangas(1, any(), ignoreCache: true));
    });
  });
}

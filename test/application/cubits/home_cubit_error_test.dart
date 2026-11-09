// External dependencies
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/home_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/notification/anime_notifier.dart';
import 'package:unyo/core/notification/manga_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/menu_bar_notifier.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/domain/repositories/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockAnimeRepository extends Mock implements AnimeRepository {}

class MockUserNotifier extends Mock implements UserNotifier {}

class MockAnimeNotifier extends Mock implements AnimeNotifier {}

class MockMangaNotifier extends Mock implements MangaNotifier {}

class MockMediaListNotifier extends Mock implements MediaListNotifier {}

class MockMenuBarNotifier extends Mock implements MenuBarNotifier {}

class MockReloadNotifier extends Mock implements ReloadNotifier {}

/// Boots [HomeCubit] against mocked notifiers. `_init` subscribes to the user
/// and reload streams at construction, so the controllers must be stubbed
/// before the cubit is built.
void main() {
  late HomeCubit cubit;
  late MockUserRepository userRepository;
  late MockAnimeRepository animeRepository;
  late MockUserNotifier userNotifier;
  late MockAnimeNotifier animeNotifier;
  late MockMangaNotifier mangaNotifier;
  late MockMediaListNotifier mediaListNotifier;
  late MockMenuBarNotifier menuBarNotifier;
  late MockReloadNotifier reloadNotifier;
  late StreamController<User> userStreamController;
  late StreamController<ReloadType> reloadStreamController;

  final Anime watchingRow = AnimeModel.empty().copyWith(id: 1);
  final Manga readingRow = MangaModel.empty().copyWith(id: 2);

  AnilistUserModel anilistUser() {
    return AnilistUserModel(
      id: '1',
      name: 'test',
      settings: SettingsModel.empty().copyWith(metadataService: Service.anilist),
      avatarImage: '',
      bannerImage: '',
      accessCode: '',
      accessToken: '',
      refreshToken: '',
    );
  }

  HomeCubit buildCubit() {
    return HomeCubit(
      userNotifier,
      animeNotifier,
      mangaNotifier,
      mediaListNotifier,
      userRepository,
      animeRepository,
      menuBarNotifier,
      reloadNotifier,
    );
  }

  setUpAll(() {
    registerFallbackValue(UserModel.empty());
  });

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));

    userRepository = MockUserRepository();
    animeRepository = MockAnimeRepository();
    userNotifier = MockUserNotifier();
    animeNotifier = MockAnimeNotifier();
    mangaNotifier = MockMangaNotifier();
    mediaListNotifier = MockMediaListNotifier();
    menuBarNotifier = MockMenuBarNotifier();
    reloadNotifier = MockReloadNotifier();

    userStreamController = StreamController<User>.broadcast();
    reloadStreamController = StreamController<ReloadType>.broadcast();
    addTearDown(userStreamController.close);
    addTearDown(reloadStreamController.close);
    when(() => userNotifier.userStream).thenAnswer((_) => userStreamController.stream);
    when(() => reloadNotifier.reloadStream).thenAnswer((_) => reloadStreamController.stream);

    // Happy-path defaults; individual tests override the ones they break.
    when(() => userRepository.getUserWatchingList(any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => <Anime>[watchingRow]);
    when(() => userRepository.getUserReadingList(any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => <Manga>[readingRow]);
    when(() => animeRepository.getMediaCoverImages(any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => <String>[]);
  });

  tearDown(() async {
    if (!cubit.isClosed) {
      await cubit.close();
    }
  });

  group('HomeCubit error handling', () {
    test('a failing user-list fetch degrades silently instead of bouncing to /login', () async {
      when(() => userRepository.getUserWatchingList(any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) async => throw Exception('network down'));

      cubit = buildCubit();
      userStreamController.add(anilistUser());
      await pumpEventQueue();

      expect(cubit.state.continueWatching, isEmpty);
      expect(cubit.state.continueReading, isEmpty);
      expect(
        cubit.state.userLoaded,
        isTrue,
        reason: 'the user still lands on Home, just with empty Continue rows',
      );
      expect(
        cubit.state.effects.whereType<ReplaceRouteEffect>(),
        isEmpty,
        reason: 'a transient fetch failure must never redirect a logged-in user',
      );
      expect(
        cubit.state.effects.where((AppEffect effect) =>
            effect is ReplaceRouteEffect || effect is NavigateRouteEffect || effect is PushRouteEffect),
        isEmpty,
        reason: 'no navigation effect of any kind may be queued by a failed fetch',
      );
      expect(
        cubit.state.effects.whereType<ShowSnackbarEffect>(),
        isNotEmpty,
        reason: 'the failure is still reported to the user, only without navigating',
      );
    });

    test('closing the cubit mid-fetch emits nothing and raises no unhandled exception', () async {
      final Completer<List<Anime>> watchingFetch = Completer<List<Anime>>();
      when(() => userRepository.getUserWatchingList(any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) => watchingFetch.future);

      final List<Object> unhandledErrors = <Object>[];
      await runZonedGuarded<Future<void>>(() async {
        cubit = buildCubit();
        userStreamController.add(anilistUser());
        await pumpEventQueue();
        expect(cubit.state.userLoaded, isFalse, reason: 'the list fetch is still in flight');

        await cubit.close();
        watchingFetch.complete(<Anime>[watchingRow]);
        await pumpEventQueue();

        expect(cubit.isClosed, isTrue);
        expect(cubit.state.continueWatching, isEmpty, reason: 'a closed cubit must not emit');
      }, (Object error, StackTrace stackTrace) => unhandledErrors.add(error));

      expect(
        unhandledErrors,
        isEmpty,
        reason: 'the stream listeners outlive the cubit; every emit must check isClosed first',
      );
    });

    test('a successful fetch still populates the Continue rows', () async {
      cubit = buildCubit();
      userStreamController.add(anilistUser());
      await pumpEventQueue();

      expect(cubit.state.continueWatching.single, same(watchingRow));
      expect(cubit.state.continueReading.single, same(readingRow));
      expect(cubit.state.userLoaded, isTrue);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.effects, isEmpty);
    });
  });
}

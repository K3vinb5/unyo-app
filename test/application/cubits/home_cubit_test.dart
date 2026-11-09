// External dependencies
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/home_cubit.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/notification/anime_notifier.dart';
import 'package:unyo/core/notification/manga_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/menu_bar_notifier.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
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

  MalUserModel malUser() {
    return MalUserModel(
      id: '56789',
      name: 'tester',
      settings: SettingsModel.empty().copyWith(userService: Service.mal),
      avatarImage: '',
      bannerImage: '',
      accessToken: 'access-token',
      refreshToken: 'stored-refresh',
      accessTokenExpiresAt: '2099-01-01T00:00:00.000',
      profileUrl: '',
    );
  }

  LocalUserModel localUser() {
    return LocalUserModel(
      id: '',
      name: 'alice',
      settings: SettingsModel.empty(),
      avatarImage: '',
      bannerImage: '',
    );
  }

  /// Rows that carry their list's marker id, so assertions can tell the
  /// watching rows from the reading rows.
  List<Anime> watchingRows() => <Anime>[AnimeModel.empty().copyWith(id: 42)];
  List<Manga> readingRows() => <Manga>[MangaModel.empty().copyWith(id: 43)];

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

  void stubLists() {
    when(() => userRepository.getUserWatchingList(any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => watchingRows());
    when(() => userRepository.getUserReadingList(any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => readingRows());
    // The user-stream listener always fetches cover images after the lists,
    // whichever user kind arrived.
    when(() => animeRepository.getMediaCoverImages(any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => <String>['cover.png']);
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

    stubLists();
  });

  tearDown(() async {
    await cubit.close();
  });

  group('HomeCubit continue watching/reading', () {
    test('a MalUserModel on the logged-user stream fetches both lists and fills the rows', () async {
      cubit = buildCubit();
      userStreamController.add(malUser());
      await pumpEventQueue();

      expect(cubit.state.userLoaded, isTrue);
      final List<User> watchedFor = verify(
        () => userRepository.getUserWatchingList(captureAny(), ignoreCache: false),
      ).captured.cast<User>();
      expect(watchedFor.single, isA<MalUserModel>());
      verify(() => userRepository.getUserReadingList(any(), ignoreCache: false)).called(1);
      expect(cubit.state.continueWatching.single.id, 42);
      expect(cubit.state.continueReading.single.id, 43);
    });

    test('a LocalUserModel triggers no list fetch and leaves the rows empty', () async {
      cubit = buildCubit();
      userStreamController.add(localUser());
      await pumpEventQueue();

      expect(cubit.state.userLoaded, isTrue);
      verifyNever(() => userRepository.getUserWatchingList(any(), ignoreCache: any(named: 'ignoreCache')));
      verifyNever(() => userRepository.getUserReadingList(any(), ignoreCache: any(named: 'ignoreCache')));
      expect(cubit.state.continueWatching, isEmpty);
      expect(cubit.state.continueReading, isEmpty);
    });
  });
}

// External dependencies
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/media_list_cubit.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/notification/anime_notifier.dart';
import 'package:unyo/core/notification/manga_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockUserNotifier extends Mock implements UserNotifier {}

class MockAnimeNotifier extends Mock implements AnimeNotifier {}

class MockMangaNotifier extends Mock implements MangaNotifier {}

class MockMediaListNotifier extends Mock implements MediaListNotifier {}

void main() {
  late MediaListCubit cubit;
  late MockUserRepository userRepository;
  late MockUserNotifier userNotifier;
  late MockAnimeNotifier animeNotifier;
  late MockMangaNotifier mangaNotifier;
  late MockMediaListNotifier mediaListNotifier;
  late StreamController<User> userStreamController;

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

  AnilistUserModel anilistUser() {
    return AnilistUserModel(
      id: '1',
      name: 'kevin',
      settings: SettingsModel.empty(),
      avatarImage: '',
      bannerImage: '',
      accessCode: '',
      accessToken: 'anilist-token',
      refreshToken: '',
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

  Map<String, List<Anime>> animeLists() => <String, List<Anime>>{
        'Watching': <Anime>[AnimeModel.empty().copyWith(id: 42)],
      };

  Map<String, List<Manga>> mangaLists() => <String, List<Manga>>{
        'Reading': <Manga>[MangaModel.empty().copyWith(id: 43)],
      };

  MediaListCubit buildCubit() {
    return MediaListCubit(
      userNotifier,
      userRepository,
      animeNotifier,
      mangaNotifier,
      mediaListNotifier,
    );
  }

  void stubLists() {
    when(() => userRepository.getUserAnimeLists(any())).thenAnswer((_) async => animeLists());
    when(() => userRepository.getUserMangaLists(any())).thenAnswer((_) async => mangaLists());
  }

  setUpAll(() {
    registerFallbackValue(UserModel.empty());
  });

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));

    userRepository = MockUserRepository();
    userNotifier = MockUserNotifier();
    animeNotifier = MockAnimeNotifier();
    mangaNotifier = MockMangaNotifier();
    mediaListNotifier = MockMediaListNotifier();

    userStreamController = StreamController<User>.broadcast();
    addTearDown(userStreamController.close);
    when(() => userNotifier.userStream).thenAnswer((_) => userStreamController.stream);

    stubLists();
  });

  tearDown(() async {
    await cubit.close();
  });

  group('MediaListCubit user lists', () {
    test('a MalUserModel on the logged-user stream fetches both list maps', () async {
      cubit = buildCubit();
      userStreamController.add(malUser());
      await pumpEventQueue();

      final List<User> animeListUsers = verify(
        () => userRepository.getUserAnimeLists(captureAny()),
      ).captured.cast<User>();
      expect(animeListUsers.single, isA<MalUserModel>());
      final List<User> mangaListUsers = verify(
        () => userRepository.getUserMangaLists(captureAny()),
      ).captured.cast<User>();
      expect(mangaListUsers.single, isA<MalUserModel>());
      expect(cubit.state.userAnimeLists['Watching']?.single.id, 42);
      expect(cubit.state.userMangaLists['Reading']?.single.id, 43);
      expect(cubit.state.isLoading, isFalse);
    });

    test('an AnilistUserModel keeps fetching both list maps', () async {
      cubit = buildCubit();
      userStreamController.add(anilistUser());
      await pumpEventQueue();

      verify(() => userRepository.getUserAnimeLists(any())).called(1);
      verify(() => userRepository.getUserMangaLists(any())).called(1);
      expect(cubit.state.isLoading, isFalse);
    });

    test('a LocalUserModel triggers no list fetch and leaves the maps empty', () async {
      cubit = buildCubit();
      userStreamController.add(localUser());
      await pumpEventQueue();

      verifyNever(() => userRepository.getUserAnimeLists(any()));
      verifyNever(() => userRepository.getUserMangaLists(any()));
      expect(cubit.state.userAnimeLists, isEmpty);
      expect(cubit.state.userMangaLists, isEmpty);
      expect(cubit.state.isLoading, isFalse);
    });
  });
}

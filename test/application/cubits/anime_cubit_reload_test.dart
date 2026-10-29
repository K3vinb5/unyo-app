// External dependencies
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/anime_cubit.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
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

  /// A row that says which provider produced it, so assertions can tell the
  /// previous provider's data from the new provider's.
  List<Anime> rowsFrom(User user) => <Anime>[
    AnimeModel.empty().copyWith(id: user.settings.metadataService.index),
  ];

  AnimeCubit buildCubit() {
    return AnimeCubit(
      animeRepository,
      userNotifier,
      animeNotifier,
      animeGenresNotifier,
      mediaListNotifier,
      reloadNotifier,
    );
  }

  void stubLists() {
    when(() => animeRepository.getRecentlyReleasedAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((Invocation invocation) async => (true, rowsFrom(invocation.positionalArguments[1] as User)));
    when(() => animeRepository.getTrendingAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((Invocation invocation) async => (true, rowsFrom(invocation.positionalArguments[1] as User)));
    when(() => animeRepository.getRecentlyCompletedAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((Invocation invocation) async => (true, rowsFrom(invocation.positionalArguments[1] as User)));
    when(() => animeRepository.getPopularAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((Invocation invocation) async => (true, rowsFrom(invocation.positionalArguments[1] as User)));
    when(() => animeRepository.getUpcomingAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((Invocation invocation) async => (true, rowsFrom(invocation.positionalArguments[1] as User)));
  }

  /// Gates only the first `getRecentlyReleasedAnimes` call that matches
  /// [gatedOnIgnoreCache], so the rest of the fetches still resolve.
  void stubRecentlyReleased({
    required bool gatedOnIgnoreCache,
    required Completer<(bool, List<Anime>)> gate,
  }) {
    bool gated = false;
    when(() => animeRepository.getRecentlyReleasedAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((Invocation invocation) {
      bool ignoreCache = invocation.namedArguments[#ignoreCache] as bool;
      User user = invocation.positionalArguments[1] as User;
      if (ignoreCache == gatedOnIgnoreCache && !gated) {
        gated = true;
        return gate.future;
      }
      return Future<(bool, List<Anime>)>.value((true, rowsFrom(user)));
    });
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
      cubit = buildCubit();
      userStreamController.add(userWith(Service.anilist));
      await pumpEventQueue();

      expect(cubit.state.userLoaded, isTrue);
      verifyEachListCalledOnce(ignoreCache: false);

      reloadStreamController.add(ReloadType.newMetadataService);
      await pumpEventQueue();

      verifyEachListCalledOnce(ignoreCache: true);
      expect(cubit.state.trending.$2.single.id, Service.anilist.index);
    });

    test('a provider switch during the initial load refetches with the new provider', () async {
      final Completer<(bool, List<Anime>)> initialFetch = Completer<(bool, List<Anime>)>();
      stubRecentlyReleased(gatedOnIgnoreCache: false, gate: initialFetch);

      cubit = buildCubit();
      userStreamController.add(userWith(Service.anilist));
      await pumpEventQueue();
      expect(cubit.state.userLoaded, isFalse, reason: 'the initial load is still awaiting its first fetch');

      // Shikimori is persisted while that first fetch is still in flight.
      userStreamController.add(userWith(Service.shikimori));
      await pumpEventQueue();
      reloadStreamController.add(ReloadType.newMetadataService);
      await pumpEventQueue();

      initialFetch.complete((true, rowsFrom(userWith(Service.anilist))));
      await pumpEventQueue();

      expect(cubit.state.userLoaded, isTrue);
      expect(
        cubit.state.recentlyReleased.$2.single.id,
        Service.shikimori.index,
        reason: 'the queued switch must refetch the list the previous provider already answered',
      );
      expect(cubit.state.trending.$2.single.id, Service.shikimori.index);
      final List<User> switchFetches = verify(
        () => animeRepository.getTrendingAnimes(1, captureAny(), ignoreCache: true),
      ).captured.cast<User>();
      expect(
        switchFetches.map((User user) => user.settings.metadataService),
        <Service>[Service.shikimori],
        reason: 'the replay must run against the newest provider, not the one the load captured',
      );
    });

    test('a second provider switch during a refetch still ends on the newest provider', () async {
      final Completer<(bool, List<Anime>)> firstSwitchFetch = Completer<(bool, List<Anime>)>();
      stubRecentlyReleased(gatedOnIgnoreCache: true, gate: firstSwitchFetch);

      cubit = buildCubit();
      userStreamController.add(userWith(Service.anilist));
      await pumpEventQueue();

      reloadStreamController.add(ReloadType.newMetadataService);
      await pumpEventQueue();
      expect(cubit.state.trending.$1, isFalse, reason: 'the refetch cleared the previous rows');

      // A second switch arrives while that refetch is still running: the rows
      // are already empty, so nothing may be dropped here.
      userStreamController.add(userWith(Service.shikimori));
      await pumpEventQueue();
      reloadStreamController.add(ReloadType.newMetadataService);
      await pumpEventQueue();

      firstSwitchFetch.complete((true, rowsFrom(userWith(Service.anilist))));
      await pumpEventQueue();

      expect(cubit.state.recentlyReleased.$2.single.id, Service.shikimori.index);
      expect(cubit.state.trending.$2.single.id, Service.shikimori.index);
      verify(() => animeRepository.getRecentlyReleasedAnimes(1, any(), ignoreCache: true)).called(2);
      final List<User> ignoreCacheFetches = verify(
        () => animeRepository.getTrendingAnimes(1, captureAny(), ignoreCache: true),
      ).captured.cast<User>();
      expect(
        ignoreCacheFetches.map((User user) => user.settings.metadataService),
        <Service>[Service.anilist, Service.shikimori],
        reason: 'the wiped rows must be refetched for the newest provider',
      );
    });
  });
}

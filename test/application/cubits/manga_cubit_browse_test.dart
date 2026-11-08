// External dependencies
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/manga_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/manga_state.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

import '../../support/fakes.dart';
import '../../support/fixtures.dart';
import '../../support/test_deps.dart';

void main() {
  late TestDeps deps;
  late MockMangaRepository mangaRepository;
  late StreamController<User> loggedUsers;

  setUp(() async {
    loggedUsers = StreamController<User>.broadcast();
    deps = await TestDeps.setUp();
    mangaRepository = MockMangaRepository();
    deps.mangaRepository = mangaRepository;
    when(() => deps.loggedUserNotifier.userStream).thenAnswer(
      (_) => loggedUsers.stream,
    );
  });

  tearDown(() async {
    await loggedUsers.close();
    await TestDeps.tearDown();
  });

  setUpAll(() => registerFallbackValue(Fixtures.emptyUser()));

  void stubBrowse() {
    when(
      () => mangaRepository.getTrendingMangas(
        any(),
        any(),
        ignoreCache: any(named: 'ignoreCache'),
      ),
    ).thenAnswer(
      (_) async => (
        true,
        <Manga>[
          Fixtures.manga(id: 2, bannerImage: 'banner.png'),
          Fixtures.manga(id: 3),
        ],
      ),
    );
    when(
      () => mangaRepository.getRecentlyCompletedMangas(
        any(),
        any(),
        ignoreCache: any(named: 'ignoreCache'),
      ),
    ).thenAnswer((_) async => (true, <Manga>[Fixtures.manga(id: 4)]));
    when(
      () => mangaRepository.getPopularMangas(
        any(),
        any(),
        ignoreCache: any(named: 'ignoreCache'),
      ),
    ).thenAnswer((_) async => (true, <Manga>[]));
    when(
      () => mangaRepository.getUpcomingMangas(
        any(),
        any(),
        ignoreCache: any(named: 'ignoreCache'),
      ),
    ).thenAnswer((_) async => (true, <Manga>[]));
  }

  Future<void> signIn(MangaCubit cubit, {User? user}) async {
    loggedUsers.add(user ?? Fixtures.anilistUser());
    await pumpEventQueue();
  }

  blocTest<MangaCubit, MangaState>(
    'loads every supported browse row and derives banners',
    build: () => deps.cubit<MangaCubit>(),
    setUp: stubBrowse,
    act: signIn,
    verify: (MangaCubit cubit) {
      expect(cubit.state.metadataServiceSupported, isTrue);
      expect(cubit.state.trending.$2, hasLength(2));
      expect(cubit.state.banners.single.id, 2);
      expect(cubit.state.recentlyCompleted.$2.single.id, 4);
      expect(cubit.state.userLoaded, isTrue);
    },
  );

  blocTest<MangaCubit, MangaState>(
    'an unsupported provider is stated instead of fetched',
    build: () => deps.cubit<MangaCubit>(),
    act: (MangaCubit cubit) => signIn(
      cubit,
      user: Fixtures.anilistUser(
        settings: SettingsModel.empty().copyWith(metadataService: Service.mal),
      ),
    ),
    verify: (MangaCubit cubit) {
      expect(cubit.state.metadataServiceSupported, isFalse);
      verifyNever(
        () => mangaRepository.getTrendingMangas(
          any(),
          any(),
          ignoreCache: any(named: 'ignoreCache'),
        ),
      );
    },
  );

  blocTest<MangaCubit, MangaState>(
    'one failing row reports an error without blocking the rest',
    build: () => deps.cubit<MangaCubit>(),
    setUp: () {
      stubBrowse();
      when(
        () => mangaRepository.getTrendingMangas(
          any(),
          any(),
          ignoreCache: any(named: 'ignoreCache'),
        ),
      ).thenThrow(Exception('offline'));
    },
    act: signIn,
    verify: (MangaCubit cubit) {
      expect(cubit.state.effects.whereType<ShowSnackbarEffect>(), isNotEmpty);
      expect(cubit.state.recentlyCompleted.$2, isNotEmpty);
    },
  );
}

// External dependencies
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/anime_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/anime_state.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/user/user.dart';

import '../../support/fakes.dart';
import '../../support/fixtures.dart';
import '../../support/test_deps.dart';

void main() {
  late TestDeps deps;
  late MockAnimeRepository animeRepository;
  late StreamController<User> loggedUsers;

  setUp(() async {
    loggedUsers = StreamController<User>.broadcast();
    deps = await TestDeps.setUp();
    animeRepository = MockAnimeRepository();
    deps.animeRepository = animeRepository;
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
      () => animeRepository.getRecentlyReleasedAnimes(
        any(),
        any(),
        ignoreCache: any(named: 'ignoreCache'),
      ),
    ).thenAnswer((_) async => (true, <Anime>[Fixtures.anime(id: 1)]));
    when(
      () => animeRepository.getTrendingAnimes(
        any(),
        any(),
        ignoreCache: any(named: 'ignoreCache'),
      ),
    ).thenAnswer(
      (_) async => (
        true,
        <Anime>[
          Fixtures.anime(id: 2, bannerImage: 'banner.png'),
          Fixtures.anime(id: 3),
        ],
      ),
    );
    when(
      () => animeRepository.getRecentlyCompletedAnimes(
        any(),
        any(),
        ignoreCache: any(named: 'ignoreCache'),
      ),
    ).thenAnswer((_) async => (true, <Anime>[]));
    when(
      () => animeRepository.getPopularAnimes(
        any(),
        any(),
        ignoreCache: any(named: 'ignoreCache'),
      ),
    ).thenAnswer((_) async => (true, <Anime>[]));
    when(
      () => animeRepository.getUpcomingAnimes(
        any(),
        any(),
        ignoreCache: any(named: 'ignoreCache'),
      ),
    ).thenAnswer((_) async => (true, <Anime>[]));
  }

  Future<void> signIn(AnimeCubit cubit) async {
    loggedUsers.add(Fixtures.anilistUser());
    await pumpEventQueue();
  }

  blocTest<AnimeCubit, AnimeState>(
    'loads every browse row and derives banners from trending',
    build: () => deps.cubit<AnimeCubit>(),
    setUp: stubBrowse,
    act: signIn,
    verify: (AnimeCubit cubit) {
      expect(cubit.state.recentlyReleased.$2.single.id, 1);
      expect(cubit.state.banners.single.id, 2);
      expect(cubit.state.userLoaded, isTrue);
      expect(cubit.state.isLoading, isFalse);
    },
  );

  blocTest<AnimeCubit, AnimeState>(
    'one failing row reports an error without blocking the rest',
    build: () => deps.cubit<AnimeCubit>(),
    setUp: () {
      stubBrowse();
      when(
        () => animeRepository.getPopularAnimes(
          any(),
          any(),
          ignoreCache: any(named: 'ignoreCache'),
        ),
      ).thenThrow(Exception('offline'));
    },
    act: signIn,
    verify: (AnimeCubit cubit) {
      expect(cubit.state.effects.whereType<ShowSnackbarEffect>(), isNotEmpty);
      expect(cubit.state.recentlyReleased.$2, isNotEmpty);
      expect(cubit.state.userLoaded, isTrue);
    },
  );

  test('navigateToCalendar pushes the calendar route', () async {
    final AnimeCubit cubit = deps.cubit<AnimeCubit>();
    addTearDown(cubit.close);

    cubit.navigateToCalendar(_FakeBuildContext());

    expect(
      cubit.state.effects.whereType<PushRouteEffect>().single.routeName,
      '/calendar',
    );
  });
}

class _FakeBuildContext extends Mock implements BuildContext {}

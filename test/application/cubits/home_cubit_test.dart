// External dependencies
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/home_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/home_state.dart';
import 'package:unyo/core/enums/selected_menu_option.dart';
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/user/user.dart';

import '../../support/fakes.dart';
import '../../support/fixtures.dart';
import '../../support/test_deps.dart';

void main() {
  late TestDeps deps;
  late MockUserRepository userRepository;
  late MockAnimeRepository animeRepository;
  late MockMenuBarNotifier menuBarNotifier;
  late MockReloadNotifier reloadNotifier;
  late StreamController<User> loggedUsers;
  late StreamController<ReloadType> reloads;

  setUp(() async {
    loggedUsers = StreamController<User>.broadcast();
    reloads = StreamController<ReloadType>.broadcast();
    deps = await TestDeps.setUp();
    userRepository = MockUserRepository();
    animeRepository = MockAnimeRepository();
    menuBarNotifier = MockMenuBarNotifier();
    reloadNotifier = MockReloadNotifier();
    deps
      ..userRepository = userRepository
      ..animeRepository = animeRepository
      ..menuBarNotifier = menuBarNotifier
      ..reloadNotifier = reloadNotifier;
    when(() => deps.loggedUserNotifier.userStream).thenAnswer(
      (_) => loggedUsers.stream,
    );
    when(() => reloadNotifier.reloadStream).thenAnswer((_) => reloads.stream);
  });

  tearDown(() async {
    await loggedUsers.close();
    await reloads.close();
    await TestDeps.tearDown();
  });

  setUpAll(() => registerFallbackValue(Fixtures.emptyUser()));

  void stubLists() {
    when(
      () => userRepository.getUserWatchingList(
        any(),
        ignoreCache: any(named: 'ignoreCache'),
      ),
    ).thenAnswer((_) async => <Anime>[Fixtures.anime(id: 10)]);
    when(
      () => userRepository.getUserReadingList(
        any(),
        ignoreCache: any(named: 'ignoreCache'),
      ),
    ).thenAnswer((_) async => <Manga>[Fixtures.manga(id: 20)]);
    when(
      () => animeRepository.getMediaCoverImages(
        any(),
        ignoreCache: any(named: 'ignoreCache'),
      ),
    ).thenAnswer((_) async => <String>['cover.png']);
  }

  Future<void> signIn(HomeCubit cubit, User user) async {
    loggedUsers.add(user);
    await pumpEventQueue();
  }

  blocTest<HomeCubit, HomeState>(
    'loads the continue-watching and continue-reading lists on login',
    build: () => deps.cubit<HomeCubit>(),
    setUp: stubLists,
    act: (HomeCubit cubit) => signIn(cubit, Fixtures.anilistUser()),
    verify: (HomeCubit cubit) {
      expect(cubit.state.continueWatching.single.id, 10);
      expect(cubit.state.continueReading.single.id, 20);
      expect(cubit.state.mediaCoverImages, <String>['cover.png']);
      expect(cubit.state.userLoaded, isTrue);
      expect(cubit.state.isLoading, isFalse);
    },
  );

  blocTest<HomeCubit, HomeState>(
    'sends the user to the login screen when the list fetch fails',
    build: () => deps.cubit<HomeCubit>(),
    setUp: () {
      stubLists();
      when(
        () => userRepository.getUserWatchingList(
          any(),
          ignoreCache: any(named: 'ignoreCache'),
        ),
      ).thenThrow(Exception('offline'));
    },
    act: (HomeCubit cubit) => signIn(cubit, Fixtures.anilistUser()),
    verify: (HomeCubit cubit) {
      final List<ReplaceRouteEffect> routes =
          cubit.state.effects.whereType<ReplaceRouteEffect>().toList();
      expect(routes.single.routeName, '/login');
      expect(cubit.state.effects.whereType<ShowSnackbarEffect>(), isNotEmpty);
    },
  );

  blocTest<HomeCubit, HomeState>(
    'a metadata-service reload refetches the cover images ignoring the cache',
    build: () => deps.cubit<HomeCubit>(),
    setUp: stubLists,
    act: (HomeCubit cubit) async {
      await signIn(cubit, Fixtures.anilistUser());
      reloads.add(ReloadType.newMetadataService);
      await pumpEventQueue();
    },
    verify: (HomeCubit cubit) {
      verify(
        () => animeRepository.getMediaCoverImages(any(), ignoreCache: true),
      ).called(1);
    },
  );

  test('selectMenuOption moves the selected tab', () async {
    final HomeCubit cubit = deps.cubit<HomeCubit>();
    addTearDown(cubit.close);

    cubit.selectMenuOption(SelectedMenuOption.manga);

    expect(cubit.state.selectedMenuOption, SelectedMenuOption.manga);
  });

  test('navigateToAnimeDetails selects the media and pushes the route', () async {
    final HomeCubit cubit = deps.cubit<HomeCubit>();
    addTearDown(cubit.close);
    cubit.navigateToAnimeDetails(Fixtures.anime(), _MediaListFake.value());

    expect(
      cubit.state.effects.whereType<PushRouteEffect>().single.routeName,
      '/animedetails',
    );
  });
}

/// Minimal media-list value; the cubit only forwards it.
class _MediaListFake {
  static MediaList value() => MediaListModel.empty();
}

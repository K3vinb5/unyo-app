// External dependencies
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/media_list_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/media_list_state.dart';
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
  late StreamController<User> loggedUsers;

  setUp(() async {
    loggedUsers = StreamController<User>.broadcast();
    deps = await TestDeps.setUp();
    userRepository = MockUserRepository();
    deps.userRepository = userRepository;
    when(() => deps.loggedUserNotifier.userStream).thenAnswer(
      (_) => loggedUsers.stream,
    );
  });

  tearDown(() async {
    await loggedUsers.close();
    await TestDeps.tearDown();
  });

  setUpAll(() => registerFallbackValue(Fixtures.emptyUser()));

  void stubLists() {
    when(() => userRepository.getUserAnimeLists(any())).thenAnswer(
      (_) async => <String, List<Anime>>{
        'Watching': <Anime>[Fixtures.anime(id: 3)],
      },
    );
    when(() => userRepository.getUserMangaLists(any())).thenAnswer(
      (_) async => <String, List<Manga>>{
        'Reading': <Manga>[Fixtures.manga(id: 4)],
      },
    );
  }

  Future<void> signIn(MediaListCubit cubit, User user) async {
    loggedUsers.add(user);
    await pumpEventQueue();
  }

  blocTest<MediaListCubit, MediaListState>(
    'fetches both list kinds for a remote account',
    build: () => deps.cubit<MediaListCubit>(),
    setUp: stubLists,
    act: (MediaListCubit cubit) => signIn(cubit, Fixtures.anilistUser()),
    verify: (MediaListCubit cubit) {
      expect(cubit.state.userAnimeLists['Watching']!.single.id, 3);
      expect(cubit.state.userMangaLists['Reading']!.single.id, 4);
      expect(cubit.state.isLoading, isFalse);
    },
  );

  blocTest<MediaListCubit, MediaListState>(
    'a local account has no remote lists to fetch',
    build: () => deps.cubit<MediaListCubit>(),
    act: (MediaListCubit cubit) => signIn(cubit, Fixtures.localUser()),
    verify: (MediaListCubit cubit) {
      verifyNever(() => userRepository.getUserAnimeLists(any()));
      expect(cubit.state.isLoading, isFalse);
    },
  );

  blocTest<MediaListCubit, MediaListState>(
    'a failed fetch reports a snackbar and stops loading',
    build: () => deps.cubit<MediaListCubit>(),
    setUp: () {
      when(
        () => userRepository.getUserAnimeLists(any()),
      ).thenThrow(Exception('offline'));
    },
    act: (MediaListCubit cubit) => signIn(cubit, Fixtures.anilistUser()),
    verify: (MediaListCubit cubit) {
      expect(cubit.state.effects.whereType<ShowSnackbarEffect>(), isNotEmpty);
      expect(cubit.state.isLoading, isFalse);
    },
  );

  test('navigateToMediaDetails routes anime and manga separately', () async {
    final MediaListCubit cubit = deps.cubit<MediaListCubit>();
    addTearDown(cubit.close);

    cubit.navigateToMediaDetails(Fixtures.anime(), MediaListModel.empty());
    cubit.navigateToMediaDetails(Fixtures.manga(), MediaListModel.empty());

    expect(
      cubit.state.effects
          .whereType<PushRouteEffect>()
          .map((PushRouteEffect effect) => effect.routeName),
      <String>['/animedetails', '/mangadetails'],
    );
  });
}

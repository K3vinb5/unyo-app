// External dependencies
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/calendar_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/calendar_state.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
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

  Future<void> signIn(CalendarCubit cubit, User user) async {
    loggedUsers.add(user);
    await pumpEventQueue();
  }

  blocTest<CalendarCubit, CalendarState>(
    'fetches the release calendar for the signed-in user',
    build: () => deps.cubit<CalendarCubit>(),
    setUp: () {
      when(
        () => animeRepository.getCalendarReleases(1, any()),
      ).thenAnswer(
        (_) async => <String, List<Anime>>{
          'Monday': <Anime>[Fixtures.anime(id: 5)],
        },
      );
    },
    act: (CalendarCubit cubit) => signIn(cubit, Fixtures.anilistUser()),
    verify: (CalendarCubit cubit) {
      expect(cubit.state.animeCalendarReleases['Monday']!.single.id, 5);
      expect(cubit.state.isLoading, isFalse);
    },
  );

  blocTest<CalendarCubit, CalendarState>(
    'a failed fetch reports a snackbar and still stops loading',
    build: () => deps.cubit<CalendarCubit>(),
    setUp: () {
      when(
        () => animeRepository.getCalendarReleases(1, any()),
      ).thenThrow(Exception('offline'));
    },
    act: (CalendarCubit cubit) => signIn(cubit, Fixtures.anilistUser()),
    verify: (CalendarCubit cubit) {
      expect(cubit.state.effects.whereType<ShowSnackbarEffect>(), isNotEmpty);
      expect(cubit.state.isLoading, isFalse);
    },
  );

  test('navigateToAnimeDetails pushes the details route', () async {
    final CalendarCubit cubit = deps.cubit<CalendarCubit>();
    addTearDown(cubit.close);

    cubit.navigateToAnimeDetails(
      Fixtures.anime(),
      MediaListModel.empty(),
    );

    expect(
      cubit.state.effects.whereType<PushRouteEffect>().single.routeName,
      '/animedetails',
    );
  });
}

// External dependencies
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/anime_advanced_search_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/anime_advanced_search_state.dart';
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
    when(
      () => animeRepository.getUserAnimeAdvancedSearchFilters(any()),
    ).thenAnswer(
      (_) async => <String, (bool, List<String>)>{
        'genres': (true, <String>['Action']),
        'seasons': (false, <String>['WINTER']),
        'formats': (true, <String>['TV']),
        'airingStatuses': (true, <String>['RELEASING']),
        'years': (true, <String>['2026']),
        'sortOptions': (true, <String>['Popularity']),
        'sortOrders': (true, <String>['Descending']),
      },
    );
    when(
      () => animeRepository.performAnimeAdvancedSearch(
        any(),
        any(),
        any(),
        any(),
        any(),
        any(),
        any(),
        any(),
        any(),
      ),
    ).thenAnswer((_) async => <Anime>[Fixtures.anime(id: 42)]);
  });

  tearDown(() async {
    await loggedUsers.close();
    await TestDeps.tearDown();
  });

  setUpAll(() {
    registerFallbackValue(Fixtures.emptyUser());
    registerFallbackValue(<String>[]);
  });

  Future<void> signIn(AnimeAdvancedSearchCubit cubit) async {
    loggedUsers.add(Fixtures.anilistUser());
    await pumpEventQueue();
  }

  blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
    'maps the account capability filters and runs the first search',
    build: () => deps.cubit<AnimeAdvancedSearchCubit>(),
    act: signIn,
    verify: (AnimeAdvancedSearchCubit cubit) {
      expect(cubit.state.genresFilters.$1, isTrue);
      expect(cubit.state.genresFilters.$2, <String>['Action']);
      expect(cubit.state.selectedSearchSortOption, 'Popularity');
      expect(cubit.state.searchResults.single.id, 42);
      expect(cubit.state.isSearching, isFalse);
    },
  );

  blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
    'a query change re-runs the search with the new text',
    build: () => deps.cubit<AnimeAdvancedSearchCubit>(),
    act: (AnimeAdvancedSearchCubit cubit) async {
      await signIn(cubit);
      await cubit.updateSearchQuery('frieren');
      await pumpEventQueue();
    },
    verify: (AnimeAdvancedSearchCubit cubit) {
      expect(cubit.state.searchQuery, 'frieren');
      verify(
        () => animeRepository.performAnimeAdvancedSearch(
          'frieren',
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).called(1);
      expect(cubit.state.isSearching, isFalse);
    },
  );

  blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
    'a failing search surfaces an error and clears the loading flag',
    build: () => deps.cubit<AnimeAdvancedSearchCubit>(),
    setUp: () {
      when(
        () => animeRepository.performAnimeAdvancedSearch(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception('offline'));
    },
    act: signIn,
    verify: (AnimeAdvancedSearchCubit cubit) {
      expect(cubit.state.effects.whereType<ShowSnackbarEffect>(), isNotEmpty);
      expect(cubit.state.isSearching, isFalse);
    },
  );

  test('updating a filter emits it before the next search', () async {
    final AnimeAdvancedSearchCubit cubit = deps.cubit<AnimeAdvancedSearchCubit>();
    addTearDown(cubit.close);

    cubit.updateGenres(<String>['Comedy']);

    expect(cubit.state.selectedGenres, <String>['Comedy']);
  });
}

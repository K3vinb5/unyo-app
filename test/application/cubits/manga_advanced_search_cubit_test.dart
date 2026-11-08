// External dependencies
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/manga_advanced_search_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/manga_advanced_search_state.dart';
import 'package:unyo/domain/entities/media/manga.dart';
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
    when(
      () => mangaRepository.getUserMangaAdvancedSearchFilters(any()),
    ).thenAnswer(
      (_) async => <String, (bool, List<String>)>{
        'genres': (true, <String>['Drama']),
        'formats': (true, <String>['MANGA']),
        'countries': (true, <String>['JP']),
        'airingStatuses': (true, <String>['RELEASING']),
        'sortOptions': (true, <String>['Popularity']),
        'sortOrders': (true, <String>['Descending']),
      },
    );
    when(
      () => mangaRepository.performMangaAdvancedSearch(
        any(),
        any(),
        any(),
        any(),
        any(),
        any(),
        any(),
        any(),
      ),
    ).thenAnswer((_) async => <Manga>[Fixtures.manga(id: 43)]);
  });

  tearDown(() async {
    await loggedUsers.close();
    await TestDeps.tearDown();
  });

  setUpAll(() {
    registerFallbackValue(Fixtures.emptyUser());
    registerFallbackValue(<String>[]);
  });

  Future<void> signIn(MangaAdvancedSearchCubit cubit) async {
    loggedUsers.add(Fixtures.anilistUser());
    await pumpEventQueue();
  }

  blocTest<MangaAdvancedSearchCubit, MangaAdvancedSearchState>(
    'maps the account capability filters and runs the first search',
    build: () => deps.cubit<MangaAdvancedSearchCubit>(),
    act: signIn,
    verify: (MangaAdvancedSearchCubit cubit) {
      expect(cubit.state.genresFilters.$2, <String>['Drama']);
      expect(cubit.state.countryFilters.$2, <String>['JP']);
      expect(cubit.state.searchResults.single.id, 43);
      expect(cubit.state.isSearching, isFalse);
    },
  );

  blocTest<MangaAdvancedSearchCubit, MangaAdvancedSearchState>(
    'a query change re-runs the search with the new text',
    build: () => deps.cubit<MangaAdvancedSearchCubit>(),
    act: (MangaAdvancedSearchCubit cubit) async {
      await signIn(cubit);
      await cubit.updateSearchQuery('berserk');
      await pumpEventQueue();
    },
    verify: (MangaAdvancedSearchCubit cubit) {
      expect(cubit.state.searchQuery, 'berserk');
      verify(
        () => mangaRepository.performMangaAdvancedSearch(
          'berserk',
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

  blocTest<MangaAdvancedSearchCubit, MangaAdvancedSearchState>(
    'a failing search surfaces an error and clears the loading flag',
    build: () => deps.cubit<MangaAdvancedSearchCubit>(),
    setUp: () {
      when(
        () => mangaRepository.performMangaAdvancedSearch(
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
    verify: (MangaAdvancedSearchCubit cubit) {
      expect(cubit.state.effects.whereType<ShowSnackbarEffect>(), isNotEmpty);
      expect(cubit.state.isSearching, isFalse);
    },
  );
}

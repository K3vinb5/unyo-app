// External dependencies
import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/application/cubits/anime_advanced_search_cubit.dart';
import 'package:unyo/application/states/anime_advanced_search_state.dart';
import 'package:unyo/data/repositories/anime_repository_anilist.dart';
import 'package:unyo/core/notification/anime_genres_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/anime_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/domain/entities/media/airing_episode.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/core/enums/media_type.dart';
import 'package:unyo/domain/entities/media/title.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/core/enums/service.dart';
import '../../core/di/locator.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late AnimeAdvancedSearchCubit cubit;
  late AnimeRepositoryAnilist mockAnimeRepository;
  late UserNotifier mockUserNotifier;
  late AnimeNotifier mockAnimeNotifier;
  late AnimeGenresNotifier mockAnimeGenresNotifier;
  late MediaListNotifier mockMediaListNotifier;
  late StreamController<User> userStreamController;
  late StreamController<String> genreStreamController;

  final testUser = const UserModel(
    id: '123',
    name: 'Test User',
    settings: SettingsModel(service: Service.anilist),
    avatarImage: 'avatar.png',
    bannerImage: 'banner.png',
  );

  final testAnime = const AnimeModel(
    id: 1,
    idMal: 1,
    title: TitleModel(
      romaji: 'Test Anime',
      english: 'Test Anime',
      nativeTitle: 'テストアニメ',
      userPreferred: 'Test Anime',
    ),
    coverImage: 'cover.png',
    bannerImage: 'banner.png',
    startDate: '01/01/2026',
    endDate: '01/01/2026',
    description: 'Test description',
    season: 'WINTER',
    format: 'TV',
    status: 'FINISHED',
    episodes: 12,
    duration: 24,
    countryOfOrigin: 'JP',
    genres: ['Action', 'Adventure'],
    averageScore: 85,
    meanScore: 84,
    popularity: 1000,
    isFavourite: false,
    isAdult: false,
    nextAiringEpisode: AiringEpisodeModel(episode: 1, airingAt: "")
  );

  final testMediaList = const MediaListModel(
    name: "list",
    mediaType: MediaType.anime
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    await setupTestLocator();
    // Register fallback values for Mocktail
    registerFallbackValue(testUser);
    registerFallbackValue(testAnime);
    registerFallbackValue(testMediaList);

    mockUserNotifier = sl<UserNotifier>(instanceName: config.loggedUserNotifier);
    mockAnimeNotifier = sl<AnimeNotifier>();
    mockAnimeGenresNotifier = sl<AnimeGenresNotifier>();
    mockMediaListNotifier = sl<MediaListNotifier>();
    mockAnimeRepository = sl<AnimeRepositoryAnilist>();

    userStreamController = StreamController<User>.broadcast();
    genreStreamController = StreamController<String>.broadcast();

    when(() => mockUserNotifier.userStream).thenAnswer((_) => userStreamController.stream);
    when(() => mockAnimeGenresNotifier.animeGenreStream).thenAnswer((_) => genreStreamController.stream);

    when(() => mockAnimeRepository.getUserAnimeAdvancedSearchFilters(any())).thenAnswer(
      (_) async => {
        'genres': (true, ['Action', 'Adventure', 'Comedy']),
        'seasons': (true, ['WINTER', 'SPRING', 'SUMMER', 'FALL']),
        'formats': (true, ['TV', 'MOVIE', 'OVA']),
        'airingStatuses': (true, ['FINISHED', 'RELEASING', 'NOT_YET_RELEASED']),
        'years': (true, ['2024', '2023', '2022']),
        'sortOptions': (true, ['Popularity', 'Score', 'Trending']),
        'sortOrders': (true, ['Desc', 'Asc']),
      },
    );

    when(() => mockAnimeRepository.performAnimeAdvancedSearch(
      any(),
      any(),
      any(),
      any(),
      any(),
      any(),
      any(),
      any(),
      any(),
    )).thenAnswer((_) async => [testAnime]);

    cubit = sl<AnimeAdvancedSearchCubit>();

  });

  tearDown(() {
    cubit.close();
    userStreamController.close();
    genreStreamController.close();
  });

  group('AnimeAdvancedSearchCubit', () {
    test('initial state is correct', () {
      expect(cubit.state.loggedUser, equals(UserModel.empty()));
      expect(cubit.state.searchQuery, equals(''));
      expect(cubit.state.selectedGenres, equals([]));
      expect(cubit.state.selectedYear, isNull);
      expect(cubit.state.selectedSeason, isNull);
      expect(cubit.state.selectedFormat, isNull);
      expect(cubit.state.selectedAiringStatus, isNull);
      expect(cubit.state.searchResults, equals([]));
      expect(cubit.state.selectedSearchOrder, equals('Desc'));
      expect(cubit.state.selectedSearchSortOption, equals('Popularity'));
    });

    blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
      'emits updated state when user stream emits new user',
      build: () => cubit,
      act: (cubit) {
        userStreamController.add(testUser);
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        predicate<AnimeAdvancedSearchState>((state) => state.loggedUser == testUser),
        predicate<AnimeAdvancedSearchState>((state) =>
          state.genresFilters.$2.isNotEmpty &&
          state.yearFilters.$2.isNotEmpty
        ),
        predicate<AnimeAdvancedSearchState>((state) => state.searchResults.isNotEmpty),
      ],
      verify: (_) {
        verify(() => mockAnimeRepository.getUserAnimeAdvancedSearchFilters(any())).called(1);
        verify(() => mockAnimeRepository.performAnimeAdvancedSearch(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        )).called(1);
      },
    );

    blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
      'updateSearchQuery updates search query and performs search',
      build: () {
        userStreamController.add(testUser);
        return cubit;
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 100));
        await cubit.updateSearchQuery('naruto');
      },
      skip: 3, // Skip initial user, filters, and search emissions
      wait: const Duration(milliseconds: 100),
      expect: () => [
        predicate<AnimeAdvancedSearchState>((state) => state.searchQuery == 'naruto'),
        predicate<AnimeAdvancedSearchState>((state) => state.searchResults.isNotEmpty),
      ],
      verify: (_) {
        verify(() => mockAnimeRepository.performAnimeAdvancedSearch(
          'naruto',
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        )).called(greaterThan(0));
      },
    );

    blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
      'updateGenres updates selected genres and performs search',
      build: () {
        userStreamController.add(testUser);
        return cubit;
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 100));
        cubit.updateGenres(['Action', 'Adventure']);
      },
      skip: 3,
      wait: const Duration(milliseconds: 100),
      expect: () => [
        predicate<AnimeAdvancedSearchState>((state) =>
          state.selectedGenres.contains('Action') &&
          state.selectedGenres.contains('Adventure')),
        predicate<AnimeAdvancedSearchState>((state) => state.searchResults.isNotEmpty),
      ],
      verify: (_) {
        verify(() => mockAnimeRepository.performAnimeAdvancedSearch(
          any(),
          ['Action', 'Adventure'],
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        )).called(greaterThan(0));
      },
    );

    blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
      'updateSearchSortOption updates sort option and performs search',
      build: () {
        userStreamController.add(testUser);
        return cubit;
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 100));
        cubit.updateSearchSortOption('Score');
      },
      skip: 3,
      wait: const Duration(milliseconds: 100),
      expect: () => [
        predicate<AnimeAdvancedSearchState>((state) => state.selectedSearchSortOption == 'Score'),
        predicate<AnimeAdvancedSearchState>((state) => state.searchResults.isNotEmpty),
      ],
      verify: (_) {
        verify(() => mockAnimeRepository.performAnimeAdvancedSearch(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          'SCORE_DESC',
          any(),
          any(),
        )).called(greaterThan(0));
      },
    );

    blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
      'updateSearchSortOrder updates sort order and performs search',
      build: () {
        userStreamController.add(testUser);
        return cubit;
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 100));
        cubit.updateSearchSortOrder('Asc');
      },
      skip: 3,
      wait: const Duration(milliseconds: 100),
      expect: () => [
        predicate<AnimeAdvancedSearchState>((state) => state.selectedSearchOrder == 'Asc'),
        predicate<AnimeAdvancedSearchState>((state) => state.searchResults.isNotEmpty),
      ],
      verify: (_) {
        verify(() => mockAnimeRepository.performAnimeAdvancedSearch(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          'POPULARITY_ASC',
          any(),
          any(),
        )).called(greaterThan(0));
      },
    );

    blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
      'updateSelectedYear updates year and performs search',
      build: () {
        userStreamController.add(testUser);
        return cubit;
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 100));
        await cubit.updateSelectedYear('2024');
      },
      skip: 3,
      wait: const Duration(milliseconds: 100),
      expect: () => [
        predicate<AnimeAdvancedSearchState>((state) => state.selectedYear == '2024'),
        predicate<AnimeAdvancedSearchState>((state) => state.searchResults.isNotEmpty),
      ],
      verify: (_) {
        verify(() => mockAnimeRepository.performAnimeAdvancedSearch(
          any(),
          any(),
          any(),
          any(),
          2024,
          any(),
          any(),
          any(),
          any(),
        )).called(greaterThan(0));
      },
    );

    blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
      'updateSelectedSeason updates season and performs search',
      build: () {
        userStreamController.add(testUser);
        return cubit;
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 100));
        await cubit.updateSelectedSeason('WINTER');
      },
      skip: 3,
      wait: const Duration(milliseconds: 100),
      expect: () => [
        predicate<AnimeAdvancedSearchState>((state) => state.selectedSeason == 'WINTER'),
        predicate<AnimeAdvancedSearchState>((state) => state.searchResults.isNotEmpty),
      ],
      verify: (_) {
        verify(() => mockAnimeRepository.performAnimeAdvancedSearch(
          any(),
          any(),
          'WINTER',
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        )).called(greaterThan(0));
      },
    );

    blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
      'updateSelectedFormat updates format and performs search',
      build: () {
        userStreamController.add(testUser);
        return cubit;
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 100));
        await cubit.updateSelectedFormat('TV');
      },
      skip: 3,
      wait: const Duration(milliseconds: 100),
      expect: () => [
        predicate<AnimeAdvancedSearchState>((state) => state.selectedFormat == 'TV'),
        predicate<AnimeAdvancedSearchState>((state) => state.searchResults.isNotEmpty),
      ],
      verify: (_) {
        verify(() => mockAnimeRepository.performAnimeAdvancedSearch(
          any(),
          any(),
          any(),
          'TV',
          any(),
          any(),
          any(),
          any(),
          any(),
        )).called(greaterThan(0));
      },
    );

    blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
      'updateSelectedAiringStatus updates airing status and performs search',
      build: () {
        userStreamController.add(testUser);
        return cubit;
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 100));
        await cubit.updateSelectedAiringStatus('RELEASING');
      },
      skip: 3,
      wait: const Duration(milliseconds: 100),
      expect: () => [
        predicate<AnimeAdvancedSearchState>((state) => state.selectedAiringStatus == 'RELEASING'),
        predicate<AnimeAdvancedSearchState>((state) => state.searchResults.isNotEmpty),
      ],
      verify: (_) {
        verify(() => mockAnimeRepository.performAnimeAdvancedSearch(
          any(),
          any(),
          any(),
          any(),
          any(),
          'RELEASING',
          any(),
          any(),
          any(),
        )).called(greaterThan(0));
      },
    );

    blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
      'genre stream updates selected genres',
      build: () {
        userStreamController.add(testUser);
        return cubit;
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 100));
        genreStreamController.add('Comedy');
      },
      skip: 3,
      wait: const Duration(milliseconds: 100),
      expect: () => [
        predicate<AnimeAdvancedSearchState>((state) => state.selectedGenres.contains('Comedy')),
        predicate<AnimeAdvancedSearchState>((state) => state.searchResults.isNotEmpty),
      ],
    );

    blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
      'genre stream ignores empty strings',
      build: () {
        userStreamController.add(testUser);
        return cubit;
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 100));
        genreStreamController.add('');
      },
      skip: 3,
      expect: () => [],
    );

    test('navigateToAnimeDetails updates notifiers and triggers navigation effect', () async {
      final mockContext = MockBuildContext();

      when(() => mockAnimeNotifier.updateSelectedAnime(any())).thenReturn(null);
      when(() => mockMediaListNotifier.updateSelectedMediaList(any())).thenReturn(null);

      userStreamController.add(testUser);
      await Future.delayed(const Duration(milliseconds: 50));

      cubit.navigateToAnimeDetails(mockContext, testAnime, testMediaList);

      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockAnimeNotifier.updateSelectedAnime(testAnime)).called(1);
      verify(() => mockMediaListNotifier.updateSelectedMediaList(testMediaList)).called(1);
      expect(cubit.state.effects.isNotEmpty, isTrue);
    });

    test('popScreen triggers pop effect', () async {
      final mockContext = MockBuildContext();

      userStreamController.add(testUser);
      await Future.delayed(const Duration(milliseconds: 50));

      cubit.popScreen(mockContext);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.effects.isNotEmpty, isTrue);
    });

    blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
      'loads filters when user is emitted',
      build: () => cubit,
      act: (cubit) {
        userStreamController.add(testUser);
      },
      wait: const Duration(milliseconds: 100),
      verify: (_) {
        verify(() => mockAnimeRepository.getUserAnimeAdvancedSearchFilters(any())).called(1);
      },
    );

    blocTest<AnimeAdvancedSearchCubit, AnimeAdvancedSearchState>(
      'combines multiple filters in search',
      build: () {
        userStreamController.add(testUser);
        return cubit;
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 100));
        await cubit.updateSearchQuery('naruto');
        cubit.updateGenres(['Action']);
        await cubit.updateSelectedYear('2024');
        await cubit.updateSelectedSeason('WINTER');
        await cubit.updateSelectedFormat('TV');
        await cubit.updateSelectedAiringStatus('RELEASING');
        cubit.updateSearchSortOption('Score');
        cubit.updateSearchSortOrder('Asc');
      },
      skip: 3,
      verify: (_) {
        verify(() => mockAnimeRepository.performAnimeAdvancedSearch(
          'naruto',
          ['Action'],
          'WINTER',
          'TV',
          2024,
          'RELEASING',
          'SCORE_ASC',
          1,
          testUser,
        )).called(1);
      },
    );
  });
}

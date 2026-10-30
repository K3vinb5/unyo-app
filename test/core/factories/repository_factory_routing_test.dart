// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/factories/anime_repository_factory.dart';
import 'package:unyo/core/factories/manga_repository_factory.dart';
import 'package:unyo/core/factories/user_repository_factory.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/data/repositories/user_repository_shikimori.dart';
import 'package:unyo/data/repositories/anime_repository_anilist.dart';
import 'package:unyo/data/repositories/anime_repository_shikimori.dart';
import 'package:unyo/data/repositories/manga_repository_anilist.dart';
import 'package:unyo/data/repositories/manga_repository_shikimori.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/airing_episode.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/media/title.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/domain/repositories/media_id_cache.dart';
import 'package:unyo/core/services/media/media_id_service.dart';
import 'package:unyo/core/services/media/media_link_candidate.dart';
import 'package:unyo/core/services/media/media_link_exception.dart';

class MockLogger extends Mock implements Logger {}

class MockAnimeRepositoryAnilist extends Mock implements AnimeRepositoryAnilist {}

class MockAnimeRepositoryShikimori extends Mock implements AnimeRepositoryShikimori {}

class MockMangaRepositoryAnilist extends Mock implements MangaRepositoryAnilist {}

class MockMangaRepositoryShikimori extends Mock implements MangaRepositoryShikimori {}

class MockUserRepositoryShikimori extends Mock implements UserRepositoryShikimori {}

class MockUserRepositoryAnilist extends Mock implements UserRepositoryAnilist {}

/// Target-provider leg of the MAL-pivot chain, stubbed per test.
class FakeMediaMappingLookup implements MediaMappingLookup {
  MediaLinkCandidate? probeResult;
  List<MediaLinkCandidate> searchResults = <MediaLinkCandidate>[];
  int probeCalls = 0;
  int searchCalls = 0;

  @override
  Future<MediaLinkCandidate?> lookupByMalId(Service target, int malId) async {
    probeCalls++;
    return probeResult;
  }

  @override
  Future<List<MediaLinkCandidate>> searchCandidates(Service target, String title) async {
    searchCalls++;
    return searchResults;
  }
}

void main() {
  late AnimeRepositoryFactory animeFactory;
  late MangaRepositoryFactory mangaFactory;
  late UserRepositoryFactory userFactory;
  late MockAnimeRepositoryAnilist anilistAnime;
  late MockAnimeRepositoryShikimori shikimoriAnime;
  late MockMangaRepositoryAnilist anilistManga;
  late MockMangaRepositoryShikimori shikimoriManga;
  late MockUserRepositoryShikimori shikimoriUser;
  late MockUserRepositoryAnilist anilistUser;
  late FakeMediaMappingLookup mappingLookup;

  AnilistUserModel userWith({Service userService = Service.anilist, Service metadataService = Service.anilist}) {
    return AnilistUserModel(
      id: '1',
      name: 'test',
      settings: SettingsModel.empty().copyWith(userService: userService, metadataService: metadataService),
      avatarImage: '',
      bannerImage: '',
      accessCode: '',
      accessToken: '',
      refreshToken: '',
    );
  }

  setUpAll(() {
    registerFallbackValue(AnimeModel.empty());
    registerFallbackValue(MangaModel.empty());
    registerFallbackValue(MediaListEntryModel.empty());
    registerFallbackValue(UserModel.empty());
  });

  setUp(() {
    sl.reset();
    sl.registerSingleton<Logger>(MockLogger());
    anilistAnime = MockAnimeRepositoryAnilist();
    shikimoriAnime = MockAnimeRepositoryShikimori();
    anilistManga = MockMangaRepositoryAnilist();
    shikimoriManga = MockMangaRepositoryShikimori();
    sl.registerSingleton<AnimeRepositoryAnilist>(anilistAnime);
    sl.registerSingleton<AnimeRepositoryShikimori>(shikimoriAnime);
    sl.registerSingleton<MangaRepositoryAnilist>(anilistManga);
    sl.registerSingleton<MangaRepositoryShikimori>(shikimoriManga);
    shikimoriUser = MockUserRepositoryShikimori();
    anilistUser = MockUserRepositoryAnilist();
    sl.registerSingleton<UserRepositoryShikimori>(shikimoriUser);
    sl.registerSingleton<UserRepositoryAnilist>(anilistUser);
    mappingLookup = FakeMediaMappingLookup();
    sl.registerLazySingleton<MediaIdService>(
      () => MediaIdService(cache: InMemoryMediaIdCache(), mappingLookup: mappingLookup),
    );
    animeFactory = AnimeRepositoryFactory();
    mangaFactory = MangaRepositoryFactory();
    userFactory = UserRepositoryFactory();
  });

  group('AnimeRepositoryFactory routing', () {
    test('browse reads follow the metadata provider, not the account provider', () async {
      when(() => shikimoriAnime.getTrendingAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) async => (true, <Anime>[AnimeModel.empty()]));

      final (bool ok, List<Anime> animes) = await animeFactory.getTrendingAnimes(
        1,
        userWith(metadataService: Service.shikimori),
      );

      expect(ok, isTrue);
      expect(animes, hasLength(1));
      verify(() => shikimoriAnime.getTrendingAnimes(1, any(), ignoreCache: false)).called(1);
      verifyNever(() => anilistAnime.getTrendingAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')));
    });

    test('details reads follow the metadata provider', () async {
      when(() => shikimoriAnime.getAnimeDetails(any(), any()))
          .thenAnswer((_) async => (true, AnimeDetailsModel.empty()));

      final (bool ok, AnimeDetails details) = await animeFactory.getAnimeDetails(
        AnimeModel.empty(),
        userWith(metadataService: Service.shikimori),
      );

      expect(ok, isTrue);
      expect(details, isNotNull);
      verify(() => shikimoriAnime.getAnimeDetails(any(), any())).called(1);
      verifyNever(() => anilistAnime.getAnimeDetails(any(), any()));
    });

    test('list entry reads and writes follow the user provider', () async {
      when(() => anilistAnime.getMediaListEntry(any(), any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) async => MediaListEntryModel.empty());
      when(() => anilistAnime.updateMediaListEntry(any(), any(), any()))
          .thenAnswer((_) async => MediaListEntryModel.empty());

      // Shikimori supplies the details, AniList still owns the list.
      final AnilistUserModel user = userWith(metadataService: Service.shikimori);
      await animeFactory.getMediaListEntry(AnimeModel.empty(), user);
      await animeFactory.updateMediaListEntry(MediaListEntryModel.empty(), AnimeModel.empty(), user);

      verify(() => anilistAnime.getMediaListEntry(any(), any(), ignoreCache: false)).called(1);
      verify(() => anilistAnime.updateMediaListEntry(any(), any(), any())).called(1);
      verifyNever(() => shikimoriAnime.getMediaListEntry(any(), any(), ignoreCache: any(named: 'ignoreCache')));
      verifyNever(() => shikimoriAnime.updateMediaListEntry(any(), any(), any()));
    });

    test('account and metadata on the same provider takes the identity path', () async {
      when(() => anilistAnime.getAnimeDetails(any(), any()))
          .thenAnswer((_) async => (true, AnimeDetailsModel.empty()));

      await animeFactory.getAnimeDetails(AnimeModel.empty(), userWith());

      verify(() => anilistAnime.getAnimeDetails(any(), any())).called(1);
      verifyNever(() => shikimoriAnime.getAnimeDetails(any(), any()));
    });
  });

  group('MangaRepositoryFactory routing', () {
    test('details reads follow the metadata provider', () async {
      when(() => shikimoriManga.getMangaDetails(any(), any()))
          .thenAnswer((_) async => (true, MangaDetailsModel.empty()));

      final (bool ok, MangaDetails details) = await mangaFactory.getMangaDetails(
        MangaModel.empty(),
        userWith(metadataService: Service.shikimori),
      );

      expect(ok, isTrue);
      expect(details, isNotNull);
      verify(() => shikimoriManga.getMangaDetails(any(), any())).called(1);
      verifyNever(() => anilistManga.getMangaDetails(any(), any()));
    });

    test('browse reads and covers reach the Shikimori repository', () async {
      when(() => shikimoriManga.getPopularMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) async => (true, <Manga>[MangaModel.empty()]));
      when(() => shikimoriManga.getMediaCoverImages(any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) async => <String>['cover']);

      final (bool ok, List<Manga> mangas) = await mangaFactory.getPopularMangas(
        1,
        userWith(metadataService: Service.shikimori),
      );
      final List<String> covers = await mangaFactory.getMediaCoverImages(
        userWith(metadataService: Service.shikimori),
      );

      expect(ok, isTrue);
      expect(mangas, hasLength(1));
      expect(covers, <String>['cover']);
      verify(() => shikimoriManga.getPopularMangas(1, any(), ignoreCache: false)).called(1);
      verify(() => shikimoriManga.getMediaCoverImages(any(), ignoreCache: false)).called(1);
      verifyNever(() => anilistManga.getPopularMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')));
    });

    test('trending reads follow the metadata provider', () async {
      when(() => anilistManga.getTrendingMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) async => (true, <Manga>[MangaModel.empty()]));

      final (bool ok, List<Manga> mangas) = await mangaFactory.getTrendingMangas(1, userWith());

      expect(ok, isTrue);
      expect(mangas, hasLength(1));
      verify(() => anilistManga.getTrendingMangas(1, any(), ignoreCache: false)).called(1);
    });

    test('browse lists route to the AniList repository when AniList is the metadata provider', () async {
      when(() => anilistManga.getPopularMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) async => (true, <Manga>[MangaModel.empty()]));

      final (bool ok, List<Manga> mangas) = await mangaFactory.getPopularMangas(1, userWith());

      expect(ok, isTrue);
      expect(mangas, hasLength(1));
      verify(() => anilistManga.getPopularMangas(1, any(), ignoreCache: false)).called(1);
    });

    test('mal, kitsu and simkl are explicitly unsupported metadata providers', () async {
      const List<Service> unsupported = <Service>[
        Service.mal,
        Service.kitsu,
        Service.simkl,
      ];
      expect(MangaRepositoryFactory.supportsMetadataService(Service.anilist), isTrue);
      expect(MangaRepositoryFactory.supportsMetadataService(Service.shikimori), isTrue);

      for (final Service service in unsupported) {
        expect(
          MangaRepositoryFactory.supportsMetadataService(service),
          isFalse,
          reason: '${service.name} has no manga implementation',
        );
        final AnilistUserModel user = userWith(metadataService: service);

        for (final (bool ok, List<Manga> mangas) in <(bool, List<Manga>)>[
          await mangaFactory.getTrendingMangas(1, user),
          await mangaFactory.getPopularMangas(1, user),
          await mangaFactory.getRecentlyCompletedMangas(1, user),
          await mangaFactory.getUpcomingMangas(1, user),
        ]) {
          expect(ok, isFalse, reason: '${service.name} must not look like a successful load');
          expect(mangas, isEmpty);
        }
      }

      verifyNever(() => anilistManga.getTrendingMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')));
      verifyNever(() => anilistManga.getPopularMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')));
      verifyNever(
        () => anilistManga.getRecentlyCompletedMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')),
      );
      verifyNever(() => anilistManga.getUpcomingMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')));
    });
  });

  group('Shikimori as the user provider', () {
    ShikimoriUserModel shikimoriAccount({Service metadataService = Service.anilist}) {
      return ShikimoriUserModel(
        id: '23456789',
        name: 'shikimori-tester',
        settings: SettingsModel.empty().copyWith(
          userService: Service.shikimori,
          metadataService: metadataService,
        ),
        avatarImage: '',
        bannerImage: '',
        accessToken: 'stored-access',
        refreshToken: 'stored-refresh',
        accessTokenExpiresAt: '2099-01-01T00:00:00.000',
        profileUrl: '',
      );
    }

    ShikimoriAnimeModel shikimoriRecord() => ShikimoriAnimeModel(
          id: 16001,
          idMal: 16001,
          title: const TitleModel(
            romaji: 'Kokoro Connect',
            english: 'Kokoro Connect',
            nativeTitle: '',
            userPreferred: 'Kokoro Connect',
          ),
          averageScore: 75,
          bannerImage: '',
          countryOfOrigin: 'JP',
          coverImage: '',
          description: '',
          duration: 24,
          endDate: '',
          startDate: '',
          episodes: 13,
          genres: const <String>[],
          format: 'tv',
          isAdult: false,
          popularity: 0,
          meanScore: 75,
          season: 'summer',
          status: 'FINISHED',
          isFavourite: false,
          nextAiringEpisode: AiringEpisodeModel.empty(),
        );

    test('list entry writes reach the Shikimori repository instead of an empty stub', () async {
      when(() => shikimoriAnime.updateMediaListEntry(any(), any(), any()))
          .thenAnswer((_) async => MediaListEntryModel.empty());

      await animeFactory.updateMediaListEntry(
        MediaListEntryModel.empty(),
        shikimoriRecord(),
        shikimoriAccount(),
      );

      verify(() => shikimoriAnime.updateMediaListEntry(any(), any(), any())).called(1);
      verifyNever(() => anilistAnime.updateMediaListEntry(any(), any(), any()));
    });

    test('list entry reads reach the Shikimori repository too', () async {
      when(() => shikimoriAnime.getMediaListEntry(any(), any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) async => MediaListEntryModel.empty());

      final MediaListEntry entry = await animeFactory.getMediaListEntry(shikimoriRecord(), shikimoriAccount());

      expect(entry.status, MediaListEntryModel.empty().status);
      verify(() => shikimoriAnime.getMediaListEntry(any(), any(), ignoreCache: false)).called(1);
      verifyNever(() => anilistAnime.getMediaListEntry(any(), any(), ignoreCache: any(named: 'ignoreCache')));
    });

    test('account reads follow settings.userService', () async {
      when(() => shikimoriUser.getUserWatchingList(any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) async => <Anime>[AnimeModel.empty()]);
      when(() => shikimoriUser.getUserAnimeLists(any()))
          .thenAnswer((_) async => <String, List<Anime>>{'Watching': <Anime>[AnimeModel.empty()]});
      when(() => shikimoriUser.getUserMangaLists(any()))
          .thenAnswer((_) async => <String, List<Manga>>{'Reading': <Manga>[MangaModel.empty()]});

      final List<Anime> watching = await userFactory.getUserWatchingList(shikimoriAccount());
      final Map<String, List<Anime>> animeLists = await userFactory.getUserAnimeLists(shikimoriAccount());
      final Map<String, List<Manga>> mangaLists = await userFactory.getUserMangaLists(shikimoriAccount());

      expect(watching, hasLength(1));
      expect(animeLists.keys, <String>['Watching']);
      expect(mangaLists.keys, <String>['Reading']);
      verify(() => shikimoriUser.getUserWatchingList(any(), ignoreCache: false)).called(1);
      verify(() => shikimoriUser.getUserAnimeLists(any())).called(1);
      verify(() => shikimoriUser.getUserMangaLists(any())).called(1);
      verifyNever(() => anilistUser.getUserWatchingList(any(), ignoreCache: any(named: 'ignoreCache')));
      verifyNever(() => anilistUser.getUserAnimeLists(any()));
    });

    test('an AniList account still routes to the AniList repository', () async {
      when(() => anilistUser.getUserMangaLists(any()))
          .thenAnswer((_) async => <String, List<Manga>>{});

      await userFactory.getUserMangaLists(userWith());

      verify(() => anilistUser.getUserMangaLists(any())).called(1);
      verifyNever(() => shikimoriUser.getUserMangaLists(any()));
    });
  });

  group('cross-provider list entry translation', () {
    ShikimoriAnimeModel shikimoriRecord({int id = 65261, int idMal = 58514}) => ShikimoriAnimeModel(
          id: id,
          idMal: idMal,
          title: const TitleModel(
            romaji: 'Kusuriya no Hitorigoto',
            english: 'The Apothecary Diaries',
            nativeTitle: '',
            userPreferred: 'Kusuriya no Hitorigoto',
          ),
          averageScore: 85,
          bannerImage: '',
          countryOfOrigin: 'JP',
          coverImage: '',
          description: '',
          duration: 24,
          endDate: '',
          startDate: '21/10/2023',
          episodes: 24,
          genres: const <String>[],
          format: 'tv',
          isAdult: false,
          popularity: 0,
          meanScore: 85,
          season: 'fall',
          status: 'releasing',
          isFavourite: false,
          nextAiringEpisode: AiringEpisodeModel.empty(),
        );

    const MediaLinkCandidate anilistCandidate = MediaLinkCandidate(
      service: Service.anilist,
      nativeId: '170942',
      malId: 58514,
      title: 'Kusuriya no Hitorigoto',
      year: 2023,
      format: 'tv',
    );

    test('a metadata-provider record is re-addressed to the user provider before the write', () async {
      mappingLookup.probeResult = anilistCandidate;
      when(() => anilistAnime.updateMediaListEntry(any(), any(), any()))
          .thenAnswer((_) async => MediaListEntryModel.empty());

      await animeFactory.updateMediaListEntry(
        MediaListEntryModel.empty(),
        shikimoriRecord(),
        userWith(metadataService: Service.shikimori),
      );

      final Anime written = verify(() => anilistAnime.updateMediaListEntry(any(), captureAny(), any())).captured.single as Anime;
      expect(written.id, 170942,
          reason: 'the AniList repository must receive the AniList id, never the Shikimori native id');
      expect(written.idMal, 58514);
      expect(mappingLookup.probeCalls, 1, reason: 'the MAL pivot is what translated the id');
      verifyNever(() => shikimoriAnime.updateMediaListEntry(any(), any(), any()));
    });

    test('a metadata-provider record is re-addressed for entry reads too', () async {
      mappingLookup.probeResult = anilistCandidate;
      when(() => anilistAnime.getMediaListEntry(any(), any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) async => MediaListEntryModel.empty());

      await animeFactory.getMediaListEntry(
        shikimoriRecord(),
        userWith(metadataService: Service.shikimori),
      );

      final Anime read = verify(
        () => anilistAnime.getMediaListEntry(captureAny(), any(), ignoreCache: any(named: 'ignoreCache')),
      ).captured.single as Anime;
      expect(read.id, 170942);
      verifyNever(() => shikimoriAnime.getMediaListEntry(any(), any(), ignoreCache: any(named: 'ignoreCache')));
    });

    test('a record already owned by the user provider is passed through untouched', () async {
      final Anime record = AnimeModel.empty().copyWith(id: 170942, idMal: 58514);
      when(() => anilistAnime.updateMediaListEntry(any(), any(), any()))
          .thenAnswer((_) async => MediaListEntryModel.empty());

      await animeFactory.updateMediaListEntry(
        MediaListEntryModel.empty(),
        record,
        userWith(metadataService: Service.shikimori),
      );

      final Anime written = verify(() => anilistAnime.updateMediaListEntry(any(), captureAny(), any())).captured.single as Anime;
      expect(written, same(record), reason: 'the identity path must not re-address or copy the record');
      expect(mappingLookup.probeCalls, 0);
      expect(mappingLookup.searchCalls, 0);
    });

    test('an unverifiable record performs no write at all', () async {
      await expectLater(
        animeFactory.updateMediaListEntry(
          MediaListEntryModel.empty(),
          shikimoriRecord(idMal: 0),
          userWith(metadataService: Service.shikimori),
        ),
        throwsA(isA<MediaLinkUnresolvedException>()),
      );

      verifyNever(() => anilistAnime.updateMediaListEntry(any(), any(), any()));
      verifyNever(() => shikimoriAnime.updateMediaListEntry(any(), any(), any()));
    });

    test('an unverifiable record degrades an entry read to the empty entry', () async {
      final MediaListEntry entry = await animeFactory.getMediaListEntry(
        shikimoriRecord(idMal: 0),
        userWith(metadataService: Service.shikimori),
      );

      expect(entry.status, MediaListEntryModel.empty().status);
      expect(entry.progress, MediaListEntryModel.empty().progress);
      verifyNever(() => anilistAnime.getMediaListEntry(any(), any(), ignoreCache: any(named: 'ignoreCache')));
      verifyNever(() => shikimoriAnime.getMediaListEntry(any(), any(), ignoreCache: any(named: 'ignoreCache')));
    });
  });

  group('calendar and advanced search follow the metadata provider', () {
    test('the calendar route is not short-circuited for Shikimori', () async {
      when(() => shikimoriAnime.getCalendarReleases(any(), any()))
          .thenAnswer((_) async => <String, List<Anime>>{});

      await animeFactory.getCalendarReleases(1, userWith(metadataService: Service.shikimori));

      verify(() => shikimoriAnime.getCalendarReleases(1, any())).called(1);
      verifyNever(() => anilistAnime.getCalendarReleases(any(), any()));
    });

    test('advanced search and its filters reach the Shikimori repository', () async {
      when(() => shikimoriAnime.getUserAnimeAdvancedSearchFilters(any()))
          .thenAnswer((_) async => <String, (bool, List<String>)>{
                'genres': (true, <String>['Action']),
              });
      when(() => shikimoriAnime.performAnimeAdvancedSearch(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => <Anime>[AnimeModel.empty()]);

      final AnilistUserModel user = userWith(metadataService: Service.shikimori);
      final Map<String, (bool, List<String>)> filters =
          await animeFactory.getUserAnimeAdvancedSearchFilters(user);
      final List<Anime> results = await animeFactory.performAnimeAdvancedSearch(
        'Frieren',
        <String>['Action'],
        null,
        null,
        null,
        null,
        'Popularity_Desc',
        1,
        user,
      );

      expect(filters['genres']!.$2, <String>['Action']);
      expect(results, hasLength(1));
      verify(() => shikimoriAnime.getUserAnimeAdvancedSearchFilters(any())).called(1);
      verify(() => shikimoriAnime.performAnimeAdvancedSearch(
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
      verifyNever(() => anilistAnime.getUserAnimeAdvancedSearchFilters(any()));
      verifyNever(() => anilistAnime.performAnimeAdvancedSearch(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ));
    });

    test('manga advanced search and filters reach the Shikimori repository', () async {
      when(() => shikimoriManga.getUserMangaAdvancedSearchFilters(any()))
          .thenAnswer((_) async => <String, (bool, List<String>)>{
                'genres': (true, <String>['Shounen']),
              });
      when(() => shikimoriManga.performMangaAdvancedSearch(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => <Manga>[MangaModel.empty()]);

      final AnilistUserModel user = userWith(metadataService: Service.shikimori);
      final Map<String, (bool, List<String>)> filters =
          await mangaFactory.getUserMangaAdvancedSearchFilters(user);
      final List<Manga> results = await mangaFactory.performMangaAdvancedSearch(
        'Berserk',
        <String>['Shounen'],
        null,
        null,
        null,
        'Popularity_Desc',
        1,
        user,
      );

      expect(filters['genres']!.$2, <String>['Shounen']);
      expect(results, hasLength(1));
      verify(() => shikimoriManga.getUserMangaAdvancedSearchFilters(any())).called(1);
      verify(() => shikimoriManga.performMangaAdvancedSearch(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          )).called(1);
      verifyNever(() => anilistManga.getUserMangaAdvancedSearchFilters(any()));
    });
  });
}

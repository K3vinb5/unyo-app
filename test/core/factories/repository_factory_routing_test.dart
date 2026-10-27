// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/factories/anime_repository_factory.dart';
import 'package:unyo/core/factories/manga_repository_factory.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/repositories/anime_repository_anilist.dart';
import 'package:unyo/data/repositories/anime_repository_shikimori.dart';
import 'package:unyo/data/repositories/manga_repository_anilist.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/core/di/locator.dart' show sl;

class MockLogger extends Mock implements Logger {}

class MockAnimeRepositoryAnilist extends Mock implements AnimeRepositoryAnilist {}

class MockAnimeRepositoryShikimori extends Mock implements AnimeRepositoryShikimori {}

class MockMangaRepositoryAnilist extends Mock implements MangaRepositoryAnilist {}

void main() {
  late AnimeRepositoryFactory animeFactory;
  late MangaRepositoryFactory mangaFactory;
  late MockAnimeRepositoryAnilist anilistAnime;
  late MockAnimeRepositoryShikimori shikimoriAnime;
  late MockMangaRepositoryAnilist anilistManga;

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
    sl.registerSingleton<AnimeRepositoryAnilist>(anilistAnime);
    sl.registerSingleton<AnimeRepositoryShikimori>(shikimoriAnime);
    sl.registerSingleton<MangaRepositoryAnilist>(anilistManga);
    animeFactory = AnimeRepositoryFactory();
    mangaFactory = MangaRepositoryFactory();
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
      // Shikimori manga details are still a known stub; the factory must not
      // silently fall back to AniList for them.
      final (bool ok, MangaDetails details) = await mangaFactory.getMangaDetails(
        MangaModel.empty(),
        userWith(metadataService: Service.shikimori),
      );

      expect(ok, isFalse);
      expect(details, isNotNull);
      verifyNever(() => anilistManga.getMangaDetails(any(), any()));
    });

    test('trending reads follow the metadata provider', () async {
      when(() => anilistManga.getTrendingMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) async => (true, <Manga>[MangaModel.empty()]));

      final (bool ok, List<Manga> mangas) = await mangaFactory.getTrendingMangas(1, userWith());

      expect(ok, isTrue);
      expect(mangas, hasLength(1));
      verify(() => anilistManga.getTrendingMangas(1, any(), ignoreCache: false)).called(1);
    });
  });
}

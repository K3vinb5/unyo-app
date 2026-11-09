// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/media/media_provenance.dart';
import 'package:unyo/data/models/mal/media/mal_anime_model.dart';
import 'package:unyo/data/models/mal/media/mal_manga_model.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';
import 'package:unyo/domain/entities/media/airing_episode.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/title.dart';

class MockShikimoriAnimeModel extends Mock implements ShikimoriAnimeModel {}

void main() {
  Anime anilistAnime({int id = 170942, int idMal = 58514}) =>
      AnimeModel.empty().copyWith(id: id, idMal: idMal);

  Anime shikimoriAnime({int id = 65261, int idMal = 65261}) {
    final MockShikimoriAnimeModel anime = MockShikimoriAnimeModel();
    when(() => anime.id).thenReturn(id);
    when(() => anime.idMal).thenReturn(idMal);
    return anime;
  }

  const TitleModel title = TitleModel(romaji: 'x', english: '', nativeTitle: '', userPreferred: 'x');

  Anime malAnime({int id = 58514, int idMal = 58514}) => MalAnimeModel(
        id: id,
        idMal: idMal,
        title: title,
        averageScore: 0,
        bannerImage: '',
        countryOfOrigin: 'JP',
        coverImage: '',
        description: '',
        duration: 0,
        endDate: '0/0/0',
        startDate: '0/0/0',
        episodes: 0,
        genres: const <String>[],
        format: 'TV',
        isAdult: false,
        popularity: 0,
        meanScore: 0,
        season: '',
        status: 'RELEASING',
        isFavourite: false,
        nextAiringEpisode: AiringEpisodeModel.empty(),
      );

  Manga malManga({int id = 2, int idMal = 2}) => MalMangaModel(
        id: id,
        idMal: idMal,
        title: title,
        averageScore: 0,
        bannerImage: '',
        chapters: 0,
        countryOfOrigin: 'JP',
        coverImage: '',
        description: '',
        endDate: '0/0/0',
        startDate: '0/0/0',
        genres: const <String>[],
        format: 'MANGA',
        isAdult: false,
        popularity: 0,
        meanScore: 0,
        status: 'RELEASING',
        isFavourite: false,
      );

  group('serviceOfAnime', () {
    test('the plain domain model is AniList-sourced', () {
      expect(MediaProvenance.ofAnime(anilistAnime()), Service.anilist);
    });

    test('a Shikimori record keeps its own provenance regardless of settings', () {
      expect(MediaProvenance.ofAnime(shikimoriAnime()), Service.shikimori);
    });

    test('a MAL record is MAL-sourced, not the AniList default', () {
      expect(MediaProvenance.ofAnime(malAnime()), Service.mal);
    });

    test('a MAL record keeps its type (and therefore its provenance) when re-addressed', () {
      final Anime reAddressed = MediaFields.withNativeId(malAnime(id: 58514), 170942);

      expect(reAddressed, isA<MalAnimeModel>());
      expect(reAddressed.id, 170942, reason: 'the target native id is applied');
      expect(MediaProvenance.ofAnime(reAddressed), Service.mal,
          reason: 'the record is still the MAL record the user opened');
    });
  });

  group('serviceOfManga', () {
    test('a MAL manga record is MAL-sourced', () {
      expect(MediaProvenance.ofManga(malManga()), Service.mal);
    });

    test('the AniList manga model stays the AniList default', () {
      expect(MediaProvenance.ofManga(MangaModel.empty()), Service.anilist);
    });
  });

  group('aniZipIdsForAnime', () {
    test('prefers the MAL pivot whenever the record publishes one', () {
      final AniZipLookupIds? ids = AniZipLookupIds.forAnime(shikimoriAnime(idMal: 58514));

      expect(ids!.malId, 58514);
      expect(ids.anilistId, -1);
    });

    test('sends the AniList id only for AniList-sourced records without a MAL id', () {
      final AniZipLookupIds? ids = AniZipLookupIds.forAnime(anilistAnime(id: 170942, idMal: 0));

      expect(ids!.malId, -1);
      expect(ids.anilistId, 170942);
    });

    test('never sends a Shikimori native id as an AniList id', () {
      expect(
        AniZipLookupIds.forAnime(shikimoriAnime(id: 65261, idMal: 0)),
        isNull,
        reason: 'a record with no pivot and non-AniList provenance is not AniZip-addressable',
      );
    });
  });
}

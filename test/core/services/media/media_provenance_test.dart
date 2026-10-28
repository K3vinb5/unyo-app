// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/media/media_provenance.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';
import 'package:unyo/domain/entities/media/anime.dart';

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

  group('serviceOfAnime', () {
    test('the plain domain model is AniList-sourced', () {
      expect(MediaProvenance.ofAnime(anilistAnime()), Service.anilist);
    });

    test('a Shikimori record keeps its own provenance regardless of settings', () {
      expect(MediaProvenance.ofAnime(shikimoriAnime()), Service.shikimori);
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

// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_details_query_entity.dart';

// Internal dependencies
import 'package:unyo/data/models/shikimori/media/shikimori_anime_details.dart';

/// Preconditions are real Shikimori GraphQL payloads (https://shikimori.io/api/graphql,
/// captured 2026-10-26): `related { anime { ... } }` returns `anime: null` for
/// every non-anime relation — a manga relation on an anime's details page came
/// back as `{"id":null,"malId":null,"name":null}`. The DTOs eagerly
/// default-construct their children (`late ... anime = ...Anime()`), so that
/// null arrives as an `AnimeDetailsQueryAnimesRelatedAnime` whose `id` is `''`.
/// Mapping it blindly produced a phantom recommended card
/// `Anime(id: 0, idMal: 0, title: '')` that the details screen rendered and
/// whose ids then fed AniZip/Aniskip.
///
/// The mapping must therefore only surface related entries that carry a real
/// anime payload, while still mapping real ones unchanged.
void main() {
  AnimeDetailsQueryAnimesRelatedAnime realAnime({String id = '42'}) {
    return AnimeDetailsQueryAnimesRelatedAnime()
      ..id = id
      ..malId = id
      ..name = 'Kenpuu Denki Berserk'
      ..russian = 'Берсерк'
      ..english = 'Berserk'
      ..japanese = '剣風伝奇ベルセルク'
      ..kind = 'tv'
      ..episodes = 25
      ..duration = 25
      ..score = 8.5
      ..status = 'released'
      ..season = 'autumn_1997'
      ..genres = [AnimeDetailsQueryAnimesRelatedAnimeGenres()..name = 'Action'];
  }

  /// A manga relation: the API returned `anime: null`, so every field of the
  /// eagerly default-constructed anime stays at its default.
  AnimeDetailsQueryAnimesRelated mangaRelation() {
    return AnimeDetailsQueryAnimesRelated()..relationKind = 'manga';
  }

  AnimeDetailsQueryAnimesRelated animeRelation(AnimeDetailsQueryAnimesRelatedAnime anime) {
    return AnimeDetailsQueryAnimesRelated()
      ..relationKind = 'sequel'
      ..anime = anime;
  }

  ShikimoriAnimeDetailsModel mapRelated(List<AnimeDetailsQueryAnimesRelated> related) {
    final animeDetails = AnimeDetailsQueryAnimes()..related = related;
    final query = AnimeDetailsQueryEntity()..animes = [animeDetails];
    return ShikimoriAnimeDetailsModel.fromAnimeDetailsQuery(query);
  }

  group('ShikimoriAnimeDetailsModel related mapping', () {
    test('keeps real anime relations and drops manga relations', () {
      final details = mapRelated([mangaRelation(), animeRelation(realAnime())]);

      expect(details.recommendedAnimes, hasLength(1));
      expect(details.recommendedAnimes.single.id, 42);
      expect(details.recommendedAnimes.single.idMal, 42);
      expect(details.recommendedAnimes.single.title.romaji, 'Берсерк');
    });

    test('manga-only relations produce no recommended anime at all', () {
      final details = mapRelated([mangaRelation(), mangaRelation()]);

      expect(details.recommendedAnimes, isEmpty);
    });

    test('legacy "0" id snapshot is skipped', () {
      final details = mapRelated([
        animeRelation(realAnime(id: '0')),
        animeRelation(realAnime()),
      ]);

      expect(details.recommendedAnimes, hasLength(1));
      expect(details.recommendedAnimes.single.id, 42);
    });

    test('whitespace-only id is treated as an absent anime payload', () {
      final details = mapRelated([animeRelation(realAnime(id: '   '))]);

      expect(details.recommendedAnimes, isEmpty);
    });

    test('default DTOs still map a usable media list entry and characters', () {
      final details = mapRelated([mangaRelation()]);

      expect(details.mediaListEntry.progress, 0);
      expect(details.characters, isEmpty);
    });
  });
}

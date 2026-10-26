// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_details_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_popular_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_recently_released_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_trending_query_entity.dart';

// Internal dependencies
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';

/// Preconditions are real Shikimori GraphQL payloads (https://shikimori.io/api/graphql,
/// captured 2026-10-26 with the same field selection as
/// `animeUpcomingOrPopularQuery` in shikimori_queries.dart):
///
/// * MAL-linked entry — `animes(order: popularity)` first hit,
///   `{"malId":"16498","id":"16498","name":"Shingeki no Kyojin", ...}`.
///   For every MAL-linked record Shikimori's `id` equals the MAL id, so the
///   mapping is only exercised by the unlinked cases below.
/// * Entry without a MAL link — schema-true shape verified on
///   `mangas(search: "After School Recipes")` ->
///   `{"id":"10156404","malId":null,"name":"After School Recipes", ...}`:
///   `malId` is a nullable `ID` returned as JSON `null`, and the native id
///   lives in a separate sequence (10 156 xxx). Native manga entries are
///   plentiful (`mangas(order: id_desc)` head is all `malId: null`), native
///   anime entries use the same payload shape.
///
/// `idMal` "unset" means `0`: the same sentinel `AnimeModel.empty()` and the
/// AniList DTOs (`late int idMal = 0`) use, and the one WP #61 keys its
/// fallback rules on. A missing MAL id must never be backfilled from the
/// Shikimori id — the two id spaces collide with unrelated records.
void main() {
  Map<String, dynamic> animePayload({String id = '16498', Object? malId = '16498', bool omitMalId = false}) {
    final json = <String, dynamic>{
      'id': id,
      'english': 'Attack on Titan',
      'name': 'Shingeki no Kyojin',
      'russian': 'Атака титанов',
      'japanese': '進撃の巨人',
      'poster': <String, dynamic>{
        'originalUrl': 'https://shikimori.io/uploads/poster/animes/16498/7a452aa20f27318bd8d87e3d70c2ccca.jpeg',
        'mainAlt2xUrl': 'https://shikimori.io/uploads/poster/animes/16498/main_alt_2x-4a7f2177dd66d87dedf9271415452512.jpeg',
      },
      'description': 'С давних времён человечество ведёт свою борьбу с титанами.',
      'duration': 24,
      'airedOn': <String, dynamic>{'day': 7, 'month': 4, 'year': 2013},
      'releasedOn': <String, dynamic>{'day': 29, 'month': 9, 'year': 2013},
      'episodes': 25,
      'nextEpisodeAt': null,
      'genres': <Map<String, dynamic>>[
        <String, dynamic>{'kind': 'demographic', 'name': 'Shounen'},
        <String, dynamic>{'kind': 'genre', 'name': 'Action'},
      ],
      'kind': 'tv',
      'isCensored': false,
      'score': 8.58,
      'season': 'spring_2013',
      'status': 'released',
    };
    if (!omitMalId) {
      json['malId'] = malId;
    }
    return json;
  }

  group('ShikimoriAnimeModel idMal mapping', () {
    test('MAL-linked entry keeps its real MAL id', () {
      final model = ShikimoriAnimeModel.fromAnimesPopularQuery(
        AnimePopularQueryAnimes.fromJson(animePayload()),
      );
      expect(model.idMal, 16498);
      expect(model.id, 16498);
    });

    test('unlinked entry (malId: null) keeps idMal unset', () {
      final model = ShikimoriAnimeModel.fromAnimesPopularQuery(
        AnimePopularQueryAnimes.fromJson(animePayload(id: '10156404', malId: null)),
      );
      expect(model.id, 10156404);
      expect(model.idMal, 0);
    });

    test('unlinked entry (malId key absent) keeps idMal unset', () {
      final model = ShikimoriAnimeModel.fromAnimesPopularQuery(
        AnimePopularQueryAnimes.fromJson(animePayload(id: '10156404', omitMalId: true)),
      );
      expect(model.idMal, 0);
    });

    test('legacy "0" sentinel never falls back to the Shikimori id', () {
      final model = ShikimoriAnimeModel.fromAnimesPopularQuery(
        AnimePopularQueryAnimes.fromJson(animePayload(id: '10156404', malId: '0')),
      );
      expect(model.id, 10156404);
      expect(model.idMal, 0);
    });

    test('every factory shares the policy', () {
      final unlinked = animePayload(id: '10156404', malId: null);
      final legacyZero = animePayload(id: '10156404', malId: '0');

      ShikimoriAnimeModel popular() => ShikimoriAnimeModel.fromAnimesPopularQuery(
            AnimePopularQueryAnimes.fromJson(unlinked),
          );
      ShikimoriAnimeModel trending() => ShikimoriAnimeModel.fromAnimesTrendingQuery(
            AnimeTrendingQueryAnimes.fromJson(unlinked),
          );
      ShikimoriAnimeModel recentlyReleased() => ShikimoriAnimeModel.fromAnimesRecentlyReleasedQuery(
            AnimeRecentlyReleasedQueryAnimes.fromJson(unlinked),
          );
      ShikimoriAnimeModel related() => ShikimoriAnimeModel.fromRelatedEntry(
            AnimeDetailsQueryAnimesRelatedAnime.fromJson(unlinked),
          );
      ShikimoriAnimeModel relatedLegacyZero() => ShikimoriAnimeModel.fromRelatedEntry(
            AnimeDetailsQueryAnimesRelatedAnime.fromJson(legacyZero),
          );

      for (final model in [popular(), trending(), recentlyReleased(), related(), relatedLegacyZero()]) {
        expect(model.id, 10156404, reason: 'the Shikimori id stays the provider-native id');
        expect(model.idMal, 0, reason: 'a missing MAL id must stay unset, never mirror the Shikimori id');
      }

      final linked = animePayload();
      expect(
        ShikimoriAnimeModel.fromAnimesPopularQuery(AnimePopularQueryAnimes.fromJson(linked)).idMal,
        16498,
      );
      expect(
        ShikimoriAnimeModel.fromAnimesTrendingQuery(AnimeTrendingQueryAnimes.fromJson(linked)).idMal,
        16498,
      );
      expect(
        ShikimoriAnimeModel.fromAnimesRecentlyReleasedQuery(
          AnimeRecentlyReleasedQueryAnimes.fromJson(linked),
        ).idMal,
        16498,
      );
      expect(
        ShikimoriAnimeModel.fromRelatedEntry(
          AnimeDetailsQueryAnimesRelatedAnime.fromJson(linked),
        ).idMal,
        16498,
      );
    });
  });
}

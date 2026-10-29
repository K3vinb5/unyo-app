// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/shikimori/anime_details_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_list_query_entity.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';

/// Preconditions are real Shikimori GraphQL payloads (https://shikimori.io/api/graphql,
/// captured 2026-10-29; see `research/unyo-64-shikimori-parity-proof/raws/api/`):
///
/// * MAL-linked entry — `{"malId":"16498","id":"16498","name":"Shingeki no Kyojin", …}`.
///   For every MAL-linked record Shikimori's `id` equals the MAL id, so the
///   mapping is only exercised by the unlinked cases below.
/// * Entry without a MAL link — `malId` is a nullable `ID` returned as JSON
///   `null`, and the native id lives in a separate sequence (10 156 xxx).
/// * `nextEpisodeAt` is ISO8601 with an offset for airing entries and `null`
///   otherwise; `episodesAired` is the count already aired.
///
/// `idMal` "unset" means `0`: the same sentinel `AnimeModel.empty()` and the
/// AniList DTOs (`late int idMal = 0`) use, and the one WP #61 keys its
/// fallback rules on. A missing MAL id must never be backfilled from the
/// Shikimori id — the two id spaces collide with unrelated records (WP #63).
void main() {
  Map<String, dynamic> animePayload({
    String id = '16498',
    Object? malId = '16498',
    bool omitMalId = false,
    String? nextEpisodeAt,
    int episodesAired = 0,
    String season = 'spring_2013',
  }) {
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
      'airedOn': <String, dynamic>{'date': '2013-04-07', 'day': 7, 'month': 4, 'year': 2013},
      'releasedOn': <String, dynamic>{'date': '2013-09-29', 'day': 29, 'month': 9, 'year': 2013},
      'episodes': 25,
      'episodesAired': episodesAired,
      'nextEpisodeAt': nextEpisodeAt,
      'genres': <Map<String, dynamic>>[
        <String, dynamic>{'id': '27', 'kind': 'demographic', 'name': 'Shounen', 'russian': 'Сёнен'},
        <String, dynamic>{'id': '1', 'kind': 'genre', 'name': 'Action', 'russian': 'Экшен'},
      ],
      'kind': 'tv',
      'isCensored': false,
      'score': 8.58,
      'season': season,
      'status': 'released',
    };
    if (!omitMalId) {
      json['malId'] = malId;
    }
    return json;
  }

  ShikimoriAnimeModel fromList(Map<String, dynamic> json) {
    return ShikimoriAnimeModel.fromListEntry(AnimeListQueryAnimes.fromJson(json));
  }

  ShikimoriAnimeModel fromRelated(Map<String, dynamic> json) {
    return ShikimoriAnimeModel.fromRelatedEntry(AnimeDetailsQueryAnimesRelatedAnime.fromJson(json));
  }

  group('ShikimoriAnimeModel idMal mapping', () {
    test('MAL-linked entry keeps its real MAL id', () {
      final ShikimoriAnimeModel model = fromList(animePayload());
      expect(model.idMal, 16498);
      expect(model.id, 16498);
    });

    test('unlinked entry (malId: null) keeps idMal unset', () {
      final ShikimoriAnimeModel model = fromList(animePayload(id: '10156404', malId: null));
      expect(model.id, 10156404);
      expect(model.idMal, 0);
    });

    test('unlinked entry (malId key absent) keeps idMal unset', () {
      final ShikimoriAnimeModel model = fromList(animePayload(id: '10156404', omitMalId: true));
      expect(model.idMal, 0);
    });

    test('legacy "0" sentinel never falls back to the Shikimori id', () {
      final ShikimoriAnimeModel model = fromList(animePayload(id: '10156404', malId: '0'));
      expect(model.id, 10156404);
      expect(model.idMal, 0);
    });

    test('junk malId never falls back to the Shikimori id', () {
      final ShikimoriAnimeModel model = fromList(animePayload(id: '10156404', malId: 'not-a-number'));
      expect(model.id, 10156404);
      expect(model.idMal, 0);
    });

    test('both factories share the policy', () {
      final Map<String, dynamic> unlinked = animePayload(id: '10156404', malId: null);
      final Map<String, dynamic> linked = animePayload();

      for (final ShikimoriAnimeModel model in <ShikimoriAnimeModel>[fromList(unlinked), fromRelated(unlinked)]) {
        expect(model.id, 10156404, reason: 'the Shikimori id stays the provider-native id');
        expect(model.idMal, 0, reason: 'a missing MAL id must stay unset, never mirror the Shikimori id');
      }
      for (final ShikimoriAnimeModel model in <ShikimoriAnimeModel>[fromList(linked), fromRelated(linked)]) {
        expect(model.idMal, 16498);
      }
    });
  });

  group('ShikimoriAnimeModel titles', () {
    test('russian never occupies the romaji slot', () {
      final ShikimoriAnimeModel model = fromList(animePayload());

      expect(model.title.romaji, 'Shingeki no Kyojin');
      expect(model.title.english, 'Attack on Titan');
      expect(model.title.nativeTitle, '進撃の巨人');
      expect(model.title.userPreferred, 'Shingeki no Kyojin');
      expect(model.title.romaji, isNot('Атака титанов'));
    });

    test('the display title falls back to russian when romaji and english are empty', () {
      final Map<String, dynamic> payload = animePayload()
        ..['name'] = ''
        ..['english'] = '';
      final ShikimoriAnimeModel model = fromList(payload);

      expect(model.title.userPreferred, 'Атака титанов',
          reason: 'an entry with only a Russian title must not render an empty card');
    });
  });

  group('ShikimoriAnimeModel airing and scores', () {
    test('nextEpisodeAt becomes the domain next airing episode', () {
      final ShikimoriAnimeModel model = fromList(
        animePayload(nextEpisodeAt: '2026-10-31T17:00:00+03:00', episodesAired: 4),
      );

      expect(model.nextAiringEpisode.episode, 5);
      expect(
        model.nextAiringEpisode.airingAt,
        (DateTime.parse('2026-10-31T17:00:00+03:00').millisecondsSinceEpoch ~/ 1000).toString(),
      );
    });

    test('no upcoming episode keeps the empty airing sentinel', () {
      final ShikimoriAnimeModel model = fromList(animePayload(nextEpisodeAt: null));

      expect(model.nextAiringEpisode.episode, -1);
      expect(model.nextAiringEpisode.airingAt, '');
    });

    test('score scales to the 0-100 domain scale', () {
      final ShikimoriAnimeModel model = fromList(animePayload());

      expect(model.averageScore, 86);
      expect(model.meanScore, 86);
    });

    test('popularity stays the documented unset sentinel', () {
      final ShikimoriAnimeModel model = fromList(animePayload());

      expect(model.popularity, ShikimoriAnimeModel.unavailablePopularity);
      expect(model.popularity, 0);
    });

    test('season and status use the AniList vocabulary', () {
      final ShikimoriAnimeModel model = fromList(animePayload());

      expect(model.season, 'SPRING');
      expect(model.status, 'FINISHED');
      expect(fromList(animePayload(season: '?')).season, '');
    });
  });
}

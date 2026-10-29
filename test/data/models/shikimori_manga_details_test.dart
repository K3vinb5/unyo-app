// External dependencies
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/shikimori/manga_details_query_entity.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_manga_details.dart';

/// Preconditions are real Shikimori GraphQL payloads
/// (`research/unyo-64-shikimori-parity-proof/raws/api/gql-manga-details-2.json`
/// and the live 2026-10-29 capture behind `test/data/fixtures/shikimori/manga_details.json`).
///
/// `related { manga { … } }` is `null` for anime adaptations: Berserk (id 2)
/// returns nine such relations and nothing else. The DTOs eagerly
/// default-construct their children, so a null relation arrives as a
/// `MangaDetailsQueryMangasRelatedManga` whose `id` is `''` — mapping it would
/// render a phantom `Manga(id: 0, title: '')` card and feed id 0 to every
/// downstream lookup (the #78/#77 phantom-media family).
void main() {
  MangaDetailsQueryMangasRelatedManga realManga({String id = '3009'}) {
    return MangaDetailsQueryMangasRelatedManga()
      ..id = id
      ..malId = id
      ..name = 'JoJo no Kimyou na Bouken Part 6: Stone Ocean'
      ..english = 'JoJo Part 6'
      ..russian = 'Невероятное приключение ДжоДжо — Часть 6'
      ..japanese = 'ジョジョの奇妙な冒険 ストーンオーシャン'
      ..kind = 'manga'
      ..chapters = 158
      ..score = 8.9
      ..status = 'released'
      ..genres = <MangaDetailsQueryMangasRelatedMangaGenres>[
        MangaDetailsQueryMangasRelatedMangaGenres()..name = 'Action',
      ];
  }

  /// An anime adaptation: the API returns `manga: null`, so every field of the
  /// eagerly default-constructed manga stays at its default.
  MangaDetailsQueryMangasRelated animeRelation() {
    return MangaDetailsQueryMangasRelated()..relationKind = 'adaptation';
  }

  MangaDetailsQueryMangasRelated mangaRelation(MangaDetailsQueryMangasRelatedManga manga) {
    return MangaDetailsQueryMangasRelated()
      ..relationKind = 'prequel'
      ..manga = manga;
  }

  ShikimoriMangaDetailsModel mapRelated(List<MangaDetailsQueryMangasRelated> related) {
    final MangaDetailsQueryMangas details = MangaDetailsQueryMangas()..related = related;
    final MangaDetailsQueryEntity query = MangaDetailsQueryEntity()..mangas = <MangaDetailsQueryMangas>[details];
    return ShikimoriMangaDetailsModel.fromMangaDetailsQuery(query);
  }

  group('ShikimoriMangaDetailsModel related mapping', () {
    test('keeps real manga relations and drops anime adaptations', () {
      final ShikimoriMangaDetailsModel details = mapRelated(<MangaDetailsQueryMangasRelated>[
        animeRelation(),
        mangaRelation(realManga()),
      ]);

      expect(details.recommendedMangas, hasLength(1));
      expect(details.recommendedMangas.single.id, 3009);
      expect(details.recommendedMangas.single.idMal, 3009);
      expect(details.recommendedMangas.single.chapters, 158);
      expect(details.recommendedMangas.single.title.romaji, contains('Stone Ocean'));
    });

    test('anime-only relations produce no phantom manga', () {
      final ShikimoriMangaDetailsModel details = mapRelated(<MangaDetailsQueryMangasRelated>[
        animeRelation(),
        animeRelation(),
      ]);

      expect(details.recommendedMangas, isEmpty);
    });

    test('legacy "0" id snapshot is skipped', () {
      final ShikimoriMangaDetailsModel details = mapRelated(<MangaDetailsQueryMangasRelated>[
        mangaRelation(realManga(id: '0')),
        mangaRelation(realManga()),
      ]);

      expect(details.recommendedMangas, hasLength(1));
      expect(details.recommendedMangas.single.id, 3009);
    });
  });

  group('ShikimoriMangaDetailsModel list entry', () {
    test('an absent userRate degrades to the add-to-list sentinel', () {
      final ShikimoriMangaDetailsModel details = mapRelated(<MangaDetailsQueryMangasRelated>[]);

      expect(details.mediaListEntry.status, 'ADD TO LIST');
      expect(details.mediaListEntry.progress, -1);
    });

    test('a real userRate becomes the list entry', () {
      final MangaDetailsQueryMangas entry = MangaDetailsQueryMangas()
        ..userRate = (MangaDetailsQueryMangasUserRate()
          ..episodes = 42
          ..score = 9
          ..rewatches = 2
          ..status = 'on_hold'
          ..createdAt = '2026-01-02T03:04:05.000+03:00'
          ..updatedAt = '2026-02-03T04:05:06.000+03:00');
      final MangaDetailsQueryEntity query = MangaDetailsQueryEntity()..mangas = <MangaDetailsQueryMangas>[entry];

      final ShikimoriMangaDetailsModel details = ShikimoriMangaDetailsModel.fromMangaDetailsQuery(query);

      expect(details.mediaListEntry.progress, 42);
      expect(details.mediaListEntry.score, 9);
      expect(details.mediaListEntry.repeat, 2);
      expect(details.mediaListEntry.status, 'ON HOLD');
    });
  });

  group('ShikimoriMangaDetailsModel characters', () {
    test('characters with a real id are mapped, empty ones dropped', () {
      final MangaDetailsQueryMangas entry = MangaDetailsQueryMangas()
        ..characterRoles = <MangaDetailsQueryMangasCharacterRoles>[
          MangaDetailsQueryMangasCharacterRoles()
            ..character = (MangaDetailsQueryMangasCharacterRolesCharacter()
              ..id = '423'
              ..name = 'Casca'),
          MangaDetailsQueryMangasCharacterRoles(),
        ];
      final MangaDetailsQueryEntity query = MangaDetailsQueryEntity()..mangas = <MangaDetailsQueryMangas>[entry];

      final ShikimoriMangaDetailsModel details = ShikimoriMangaDetailsModel.fromMangaDetailsQuery(query);

      expect(details.characters, hasLength(1));
      expect(details.characters.single.id, 423);
      expect(details.characters.single.name, 'Casca');
    });
  });

  group('ShikimoriMangaDetailsModel captured payload', () {
    test('the captured details payload maps its two real manga relations only', () {
      final Map<String, dynamic> payload =
          jsonDecode(File('test/data/fixtures/shikimori/manga_details.json').readAsStringSync())
              as Map<String, dynamic>;
      final ShikimoriMangaDetailsModel details = ShikimoriMangaDetailsModel.fromMangaDetailsQuery(
        MangaDetailsQueryEntity.fromJson(payload['data'] as Map<String, dynamic>),
      );

      expect(details.recommendedMangas, hasLength(2));
      expect(details.characters, isNotEmpty);
    });
  });
}

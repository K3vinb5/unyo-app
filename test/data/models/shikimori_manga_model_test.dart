// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/shikimori/manga_details_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/manga_list_query_entity.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_manga_model.dart';

/// Preconditions are real Shikimori GraphQL payloads (`mangas`, captured
/// 2026-10-29; `research/unyo-64-shikimori-parity-proof/raws/api/`).
///
/// Manga natives genuinely diverge from MAL ids: `malId` is a nullable `ID`
/// (JSON string when present) and unlinked manga sit in the `1015xxxxx`
/// sequence. WP #63's rule therefore applies here too — `idMal` comes strictly
/// from `malId`, `0` means unset, and the Shikimori id is never a fallback.
void main() {
  Map<String, dynamic> mangaPayload({
    String id = '2',
    Object? malId = '2',
    bool omitMalId = false,
    int volumes = 24,
    int chapters = 96,
    String kind = 'manga',
    String status = 'released',
  }) {
    final json = <String, dynamic>{
      'id': id,
      'name': 'Berserk',
      'english': 'Berserk',
      'japanese': 'ベルセルク',
      'russian': 'Берсерк',
      'poster': <String, dynamic>{
        'originalUrl': 'https://shikimori.io/uploads/poster/mangas/2/3dfe28c5b305092615012a4acdecb992.jpeg',
        'mainAlt2xUrl': 'https://shikimori.io/uploads/poster/mangas/2/main_alt_2x-b4d793a8466e7e46cd8cb958d7dd5bd6.jpeg',
      },
      'description': 'Наёмник Гатс, по прозвищу Чёрный Мечник…',
      'airedOn': <String, dynamic>{'date': '1989-08-25', 'day': 25, 'month': 8, 'year': 1989},
      'releasedOn': <String, dynamic>{'date': null, 'day': null, 'month': null, 'year': null},
      'volumes': volumes,
      'chapters': chapters,
      'genres': <Map<String, dynamic>>[
        <String, dynamic>{'id': '52', 'kind': 'genre', 'name': 'Seinen', 'russian': 'Сэйнэн'},
      ],
      'kind': kind,
      'isCensored': false,
      'score': 9.46,
      'status': status,
      'publishers': <Map<String, dynamic>>[
        <String, dynamic>{'id': '2', 'name': 'Young Animal'},
      ],
    };
    if (!omitMalId) {
      json['malId'] = malId;
    }
    return json;
  }

  ShikimoriMangaModel fromList(Map<String, dynamic> json) {
    return ShikimoriMangaModel.fromListEntry(MangaListQueryMangas.fromJson(json));
  }

  ShikimoriMangaModel fromDetails(Map<String, dynamic> json) {
    return ShikimoriMangaModel.fromDetailsEntry(MangaDetailsQueryMangas.fromJson(json));
  }

  ShikimoriMangaModel fromRelated(Map<String, dynamic> json) {
    return ShikimoriMangaModel.fromRelatedEntry(MangaDetailsQueryMangasRelatedManga.fromJson(json));
  }

  group('ShikimoriMangaModel idMal mapping', () {
    test('MAL-linked manga keeps its real MAL id', () {
      final ShikimoriMangaModel model = fromList(mangaPayload());

      expect(model.id, 2);
      expect(model.idMal, 2);
    });

    test('unlinked native manga (malId: null) keeps idMal unset', () {
      final ShikimoriMangaModel model = fromList(mangaPayload(id: '10156404', malId: null));

      expect(model.id, 10156404);
      expect(model.idMal, 0, reason: 'never backfill idMal from the Shikimori id');
    });

    test('absent and "0" malId stay unset', () {
      expect(fromList(mangaPayload(id: '10156404', omitMalId: true)).idMal, 0);
      expect(fromList(mangaPayload(id: '10156404', malId: '0')).idMal, 0);
    });

    test('junk malId stays unset', () {
      expect(fromList(mangaPayload(id: '10156404', malId: 'n/a')).idMal, 0);
    });

    test('all three factories share the policy', () {
      final Map<String, dynamic> unlinked = mangaPayload(id: '10156404', malId: null);

      for (final ShikimoriMangaModel model in <ShikimoriMangaModel>[
        fromList(unlinked),
        fromDetails(unlinked),
        fromRelated(unlinked),
      ]) {
        expect(model.id, 10156404);
        expect(model.idMal, 0);
      }
    });
  });

  group('ShikimoriMangaModel mapping', () {
    test('chapters, titles, genres and format come from the document', () {
      final ShikimoriMangaModel model = fromList(mangaPayload());

      expect(model.chapters, 96);
      expect(model.title.romaji, 'Berserk');
      expect(model.title.nativeTitle, 'ベルセルク');
      expect(model.title.userPreferred, 'Berserk');
      expect(model.genres, <String>['Seinen']);
      expect(model.format, 'MANGA');
      expect(model.status, 'FINISHED');
      expect(model.averageScore, 95);
    });

    test('the volume count has no slot in the domain entity', () {
      final ShikimoriMangaModel model = fromList(mangaPayload(volumes: 24, chapters: 96));

      expect(model.chapters, 96,
          reason: 'Manga carries one counter; volumes rides on the DTO for the details work');
    });

    test('manga-only statuses map to the AniList vocabulary', () {
      expect(fromList(mangaPayload(status: 'paused')).status, 'HIATUS');
      expect(fromList(mangaPayload(status: 'discontinued')).status, 'CANCELLED');
      expect(fromList(mangaPayload(status: 'anons')).status, 'NOT_YET_RELEASED');
    });

    test('kind maps to the AniList format vocabulary', () {
      expect(fromList(mangaPayload(kind: 'manhwa')).format, 'MANHWA');
      expect(fromList(mangaPayload(kind: 'light_novel')).format, 'NOVEL');
      expect(fromList(mangaPayload(kind: 'one_shot')).format, 'ONE_SHOT');
      expect(fromList(mangaPayload(kind: 'doujin')).format, 'DOUJINSHI');
    });

    test('a missing releasedOn date keeps the 0/0/0 sentinel', () {
      expect(fromList(mangaPayload()).endDate, '0/0/0');
      expect(fromList(mangaPayload()).startDate, '25/8/1989');
    });
  });
}

// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/media/media_id_service.dart';
import 'package:unyo/core/services/media/media_link_candidate.dart';
import 'package:unyo/core/services/media/media_link_proposal.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_popular_query_entity.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/title.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/media_id_cache.dart';

class FakeAniZipIdLookup implements AniZipIdLookup {
  int? response;
  int? anilistResponse;
  int calls = 0;
  int anilistCalls = 0;
  int? lastAnilistId;
  int? lastMalId;

  @override
  Future<int?> malIdForAnilistId(int anilistId) async {
    calls++;
    lastAnilistId = anilistId;
    return response;
  }

  @override
  Future<int?> anilistIdForMalId(int malId) async {
    anilistCalls++;
    lastMalId = malId;
    return anilistResponse;
  }
}

class FakeMediaMappingLookup implements MediaMappingLookup {
  MediaLinkCandidate? probeResult;
  List<MediaLinkCandidate> searchResults = <MediaLinkCandidate>[];
  int probeCalls = 0;
  int searchCalls = 0;
  int? lastProbedMalId;
  String? lastSearchTitle;

  @override
  Future<MediaLinkCandidate?> lookupByMalId(Service target, int malId) async {
    probeCalls++;
    lastProbedMalId = malId;
    return probeResult;
  }

  @override
  Future<List<MediaLinkCandidate>> searchCandidates(Service target, String title) async {
    searchCalls++;
    lastSearchTitle = title;
    return searchResults;
  }
}

final sl = GetIt.instance;

void main() {
  late InMemoryMediaIdCache cache;
  late FakeAniZipIdLookup aniZip;
  late FakeMediaMappingLookup lookup;
  late MediaIdService service;

  const String title = 'Kusuriya no Hitorigoto';

  Anime anilistAnime({int id = 170942, int idMal = 58514}) => AnimeModel.empty().copyWith(
        id: id,
        idMal: idMal,
        title: const TitleModel(
          romaji: title,
          english: '',
          nativeTitle: '',
          userPreferred: title,
        ),
      );

  /// A real Shikimori record, built from a schema-true `animes` payload (see
  /// test/data/models/shikimori_anime_model_test.dart for the captured shape).
  Anime shikimoriAnime({String id = '65261', String? malId = '58514'}) {
    return ShikimoriAnimeModel.fromAnimesPopularQuery(
      AnimePopularQueryAnimes.fromJson(<String, dynamic>{
        'id': id,
        'malId': malId,
        'name': title,
        'english': title,
        'russian': title,
        'japanese': title,
        'poster': <String, dynamic>{'originalUrl': '', 'mainAlt2xUrl': ''},
        'description': '',
        'duration': 24,
        'airedOn': <String, dynamic>{'year': 2026},
        'releasedOn': <String, dynamic>{'year': 2026},
        'episodes': 12,
        'nextEpisodeAt': null,
        'genres': <Map<String, dynamic>>[],
        'kind': 'tv',
        'isCensored': false,
        'score': 8.0,
        'season': 'winter_2026',
        'status': 'ongoing',
      }),
    );
  }

  User userWith({Service userService = Service.anilist, Service metadataService = Service.anilist}) =>
      UserModel.empty().copyWith(
        settings: SettingsModel.empty().copyWith(
          userService: userService,
          metadataService: metadataService,
        ),
      );

  MediaLinkCandidate candidate(
    String nativeId, {
    int? malId,
    String? candidateTitle,
    Service service = Service.shikimori,
  }) =>
      MediaLinkCandidate(
        service: service,
        nativeId: nativeId,
        malId: malId,
        title: candidateTitle ?? '$title $nativeId',
        year: 2026,
        format: 'tv',
      );

  setUp(() {
    sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));
    cache = InMemoryMediaIdCache();
    aniZip = FakeAniZipIdLookup();
    lookup = FakeMediaMappingLookup();
    service = MediaIdService(cache: cache, aniZipLookup: aniZip, mappingLookup: lookup);
  });

  group('details source', () {
    test('the record\'s own provider is the identity path with zero lookups', () async {
      final MediaDetailsSource source = await service.detailsSource(
        anilistAnime(),
        userWith(metadataService: Service.anilist),
      );

      expect(source.service, Service.anilist);
      expect(source.anime.id, 170942);
      expect(source.isUnresolved, isFalse);
      expect(source.proposal, isNull);
      expect(aniZip.calls, 0);
      expect(lookup.probeCalls, 0);
      expect(lookup.searchCalls, 0);
    });

    test('the provider malId field is the pivot: no AniZip call, the probed record is used', () async {
      lookup.probeResult = candidate('55555', malId: 58514);

      final MediaDetailsSource source = await service.detailsSource(
        anilistAnime(),
        userWith(metadataService: Service.shikimori),
      );

      expect(source.service, Service.shikimori);
      expect(source.anime.id, 55555);
      expect(source.isUnresolved, isFalse);
      expect(aniZip.calls, 0);
      expect((await cache.getByNativeId(Service.anilist, '170942'))!.malId, 58514);
    });

    test('AniZip is the second step and is applied silently', () async {
      aniZip.response = 58514;
      lookup.probeResult = candidate('55555', malId: 58514);

      final MediaDetailsSource source = await service.detailsSource(
        anilistAnime(idMal: 0),
        userWith(metadataService: Service.shikimori),
      );

      expect(source.service, Service.shikimori);
      expect(source.anime.id, 55555);
      expect(source.proposal, isNull, reason: 'AniZip results never trigger the confirmation dialog');
      expect(aniZip.lastAnilistId, 170942);
    });

    test('a probe-and-verify hit is accepted only when the record\'s own malId matches', () async {
      lookup.probeResult = candidate('55555', malId: 58514);

      final MediaDetailsSource source = await service.detailsSource(
        anilistAnime(),
        userWith(metadataService: Service.shikimori),
      );

      expect(source.service, Service.shikimori);
      expect(source.anime.id, 55555);
      expect(lookup.lastProbedMalId, 58514);
      expect(lookup.searchCalls, 0);
      expect((await cache.getByNativeId(Service.anilist, '170942'))!.malId, 58514);
    });

    test('a failed probe proposes title-search hits and keeps the record\'s own details', () async {
      lookup.searchResults = <MediaLinkCandidate>[candidate('55555')];

      final MediaDetailsSource source = await service.detailsSource(
        anilistAnime(),
        userWith(metadataService: Service.shikimori),
      );

      expect(source.service, Service.anilist, reason: 'nothing is linked before the user confirms');
      expect(source.anime.id, 170942);
      expect(source.isUnresolved, isTrue);
      expect(source.proposal!.candidates, hasLength(1));
      expect(source.proposal!.metadataService, Service.shikimori);
      expect(lookup.lastSearchTitle, title);
      expect(
        await cache.getByNativeId(Service.shikimori, '55555'),
        isNull,
        reason: 'a fuzzy match must never be applied silently',
      );
    });

    test('the same entry is never proposed twice in a session', () async {
      lookup.searchResults = <MediaLinkCandidate>[candidate('55555')];

      final MediaDetailsSource first = await service.detailsSource(
        anilistAnime(),
        userWith(metadataService: Service.shikimori),
      );
      final MediaDetailsSource second = await service.detailsSource(
        anilistAnime(),
        userWith(metadataService: Service.shikimori),
      );

      expect(first.proposal, isNotNull);
      expect(second.proposal, isNull, reason: 'the prompt is gated per entry, per session');
      expect(second.isUnresolved, isTrue);
    });

    test('at most five candidates are proposed', () async {
      lookup.searchResults = List<MediaLinkCandidate>.generate(7, (index) => candidate('5555$index'));

      final MediaDetailsSource source = await service.detailsSource(
        anilistAnime(),
        userWith(metadataService: Service.shikimori),
      );

      expect(source.proposal!.candidates, hasLength(MediaIdService.maxTitleSearchCandidates));
      expect(source.proposal!.candidates.first.nativeId, '55550');
    });

    test('a total miss is cached as unresolved so the page falls back', () async {
      lookup.searchResults = const <MediaLinkCandidate>[];

      final MediaDetailsSource source = await service.detailsSource(
        anilistAnime(idMal: 0),
        userWith(metadataService: Service.shikimori),
      );

      expect(source.isUnresolved, isTrue);
      expect(source.service, Service.anilist);
      final IdMapping row = (await cache.getByNativeId(Service.anilist, '170942'))!;
      expect(row.state, IdMappingState.unresolved);
      expect(row.malId, isNull, reason: 'the native id key must exist even with no MAL pivot');
    });

    for (final (String junk, String label) in <(String, String)>[
      ('', 'empty'),
      ('null', 'null'),
      ('abc', 'non-numeric'),
      ('0', 'zero'),
      ('-5', 'negative'),
    ]) {
      test('a junk metadata native id ($label) is a miss, not a re-addressed metadata fetch', () async {
        await cache.put(IdMapping(
          service: Service.shikimori,
          nativeId: junk,
          malId: 58514,
          state: IdMappingState.authoritative,
          source: IdMappingSource.aniZip,
        ));

        final MediaDetailsSource source = await service.detailsSource(
          anilistAnime(),
          userWith(metadataService: Service.shikimori),
        );

        expect(
          source.service,
          Service.anilist,
          reason: 'junk "$junk" must never address the metadata provider',
        );
        expect(
          source.anime.id,
          170942,
          reason: 'the source id must not be recycled as a metadata id',
        );
        expect(
          source.isUnresolved,
          isTrue,
          reason: 'junk "$junk" is a miss: user-provider details plus the relink action',
        );
        expect(
          await cache.getByNativeId(Service.shikimori, junk),
          isNull,
          reason: 'the unusable row must not shadow the chain forever',
        );
      });
    }

    test('after a junk row the manual relink still proposes a verified entry', () async {
      await cache.put(const IdMapping(
        service: Service.shikimori,
        nativeId: 'abc',
        malId: 58514,
        state: IdMappingState.authoritative,
        source: IdMappingSource.aniZip,
      ));
      final MediaDetailsSource broken = await service.detailsSource(
        anilistAnime(),
        userWith(metadataService: Service.shikimori),
      );
      expect(broken.isUnresolved, isTrue);

      // What the page's "Link metadata entry…" action does: forget the link,
      // then run the chain again.
      await service.resetLink(source: Service.anilist, nativeId: '170942', target: Service.shikimori);
      lookup.searchResults = <MediaLinkCandidate>[candidate('55555')];
      final MediaDetailsSource relinked = await service.detailsSource(
        anilistAnime(),
        userWith(metadataService: Service.shikimori),
      );

      expect(relinked.proposal, isNotNull, reason: 'the relink action must still offer entries');
      expect(relinked.proposal!.candidates.single.nativeId, '55555');
      expect(relinked.isUnresolved, isTrue, reason: 'nothing is linked before the user confirms');
    });

    for (final (String junk, String label) in <(String, String)>[
      ('0', 'zero'),
      ('-5', 'negative'),
      ('abc', 'non-numeric'),
      ('', 'empty'),
    ]) {
      test('a poisoned link ($label) is cleaned on both rows and the next lookup searches titles', () async {
        // Box state a pre-fix build could write: an unusable target row plus the
        // source row's link to it. `_confirmedLink` used to rebuild the target
        // row from that link, so the entry never reached the title search again.
        await cache.put(IdMapping(
          service: Service.shikimori,
          nativeId: junk,
          malId: 58514,
          state: IdMappingState.confirmed,
          source: IdMappingSource.titleSearch,
        ));
        await cache.put(IdMapping(
          service: Service.anilist,
          nativeId: '170942',
          malId: 58514,
          state: IdMappingState.confirmed,
          source: IdMappingSource.titleSearch,
          linkedService: Service.shikimori,
          linkedNativeId: junk,
        ));

        final MediaDetailsSource first = await service.detailsSource(
          anilistAnime(),
          userWith(metadataService: Service.shikimori),
        );

        expect(first.service, Service.anilist, reason: 'unusable "$junk" must never address the metadata provider');
        expect(first.anime.id, 170942);
        expect(first.isUnresolved, isTrue);
        expect(await cache.getByNativeId(Service.shikimori, junk), isNull);
        expect(
          (await cache.getByNativeId(Service.anilist, '170942'))!.linkedNativeId,
          isNull,
          reason: 'the stale source link must be cleared, or _confirmedLink resurrects the row',
        );

        lookup.searchResults = <MediaLinkCandidate>[candidate('55555')];
        final MediaDetailsSource second = await service.detailsSource(
          anilistAnime(),
          userWith(metadataService: Service.shikimori),
        );

        expect(lookup.searchCalls, 1, reason: 'the entry must reach the title-search stage again');
        expect(second.isUnresolved, isTrue, reason: 'nothing is linked before the user confirms');
        expect(second.proposal!.candidates.single.nativeId, '55555');
        expect(
          await cache.getByNativeId(Service.shikimori, junk),
          isNull,
          reason: '_confirmedLink must not recreate the unusable row',
        );
      });
    }

    test('a Shikimori record resolves to AniList through its own malId', () async {
      lookup.probeResult = candidate('170942', malId: 58514, service: Service.anilist);

      final MediaDetailsSource source = await service.detailsSource(
        shikimoriAnime(),
        userWith(metadataService: Service.anilist),
      );

      expect(source.service, Service.anilist);
      expect(source.anime.id, 170942);
      expect(aniZip.calls, 0, reason: 'Shikimori never has an AniZip id space');
    });
  });

  group('AniZip MAL to AniList', () {
    test('a Shikimori record with a known malId resolves to AniList through AniZip, without a dialog', () async {
      aniZip.anilistResponse = 170942;

      final MediaDetailsSource source = await service.detailsSource(
        shikimoriAnime(),
        userWith(metadataService: Service.anilist),
      );

      expect(aniZip.lastMalId, 58514);
      expect(aniZip.calls, 0, reason: 'a Shikimori record has no AniZip id space of its own');
      expect(lookup.probeCalls, 1, reason: 'the target-provider probe is still tried first');
      expect(lookup.searchCalls, 0);
      expect(source.service, Service.anilist);
      expect(source.anime.id, 170942);
      expect(source.isUnresolved, isFalse);
      expect(source.proposal, isNull, reason: 'AniZip is authoritative: nothing to confirm');

      final IdMapping target = (await cache.getByNativeId(Service.anilist, '170942'))!;
      expect(target.malId, 58514);
      expect(target.state, IdMappingState.authoritative);
      expect(target.source, IdMappingSource.aniZip);
      final IdMapping sourceRow = (await cache.getByNativeId(Service.shikimori, '65261'))!;
      expect(sourceRow.malId, 58514);
      expect(sourceRow.state, IdMappingState.authoritative);
      expect(sourceRow.source, IdMappingSource.aniZip);
    });

    test('the AniZip link serves the list read and write path instead of an unresolved row', () async {
      aniZip.anilistResponse = 170942;
      final Anime record = shikimoriAnime();

      await service.detailsSource(record, userWith(metadataService: Service.anilist));
      final int? userNativeId = await service.userNativeIdFor(record, Service.anilist);

      expect(userNativeId, 170942, reason: 'a null here is the list-write MediaLinkUnresolvedException');
      expect(aniZip.anilistCalls, 1, reason: 'the cached link is reused, AniZip is not asked again');
      expect(cache.entries.where((IdMapping mapping) => !mapping.isResolved), isEmpty);
    });

    test('AniZip without an AniList entry falls through to the title search unchanged', () async {
      aniZip.anilistResponse = null;
      lookup.searchResults = <MediaLinkCandidate>[candidate('170942', service: Service.anilist)];

      final MediaDetailsSource source = await service.detailsSource(
        shikimoriAnime(),
        userWith(metadataService: Service.anilist),
      );

      expect(aniZip.lastMalId, 58514, reason: 'the AniZip leg was tried before giving up');
      expect(lookup.searchCalls, 1, reason: 'the heuristic stage is still reached');
      expect(source.proposal, isNotNull);
      expect(source.isUnresolved, isTrue);
      expect(source.service, Service.shikimori);
      expect(
        await cache.getByNativeId(Service.anilist, '170942'),
        isNull,
        reason: 'nothing is applied before the user confirms',
      );
    });
  });

  group('user provider translation', () {
    test('the identity path passes the id through untouched', () async {
      expect(await service.userNativeIdFor(anilistAnime(), Service.anilist), 170942);
      expect(aniZip.calls, 0);
      expect(lookup.probeCalls, 0);
    });

    test('null instead of a guessed id when no step of the chain verifies one', () async {
      lookup.searchResults = <MediaLinkCandidate>[candidate('55555')];

      expect(await service.userNativeIdFor(shikimoriAnime(malId: null), Service.anilist), isNull);
      expect(lookup.probeCalls, 0, reason: 'a MAL probe cannot run without a pivot');
      expect(cache.entries, isEmpty);
    });
  });

  group('confirming a link', () {
    test('confirming caches the link and skips the search on the next open', () async {
      lookup.searchResults = <MediaLinkCandidate>[candidate('55555')];
      final MediaDetailsSource proposal = await service.detailsSource(
        anilistAnime(),
        userWith(metadataService: Service.shikimori),
      );

      await service.confirmLink(
        source: Service.anilist,
        nativeId: '170942',
        candidate: proposal.proposal!.candidates.first,
      );
      final MediaDetailsSource linked = await service.detailsSource(
        anilistAnime(),
        userWith(metadataService: Service.shikimori),
      );

      expect(lookup.searchCalls, 1, reason: 'the confirmed link must be reused, not re-searched');
      expect(linked.service, Service.shikimori);
      expect(linked.anime.id, 55555);
      expect(linked.isUnresolved, isFalse);
      expect((await cache.getByNativeId(Service.shikimori, '55555'))!.state, IdMappingState.confirmed);
    });

    for (final (String junk, String label) in <(String, String)>[
      ('0', 'zero'),
      ('-5', 'negative'),
      ('abc', 'non-numeric'),
      ('', 'empty'),
    ]) {
      test('a confirmed candidate with an unusable id ($label) is never cached', () async {
        lookup.searchResults = <MediaLinkCandidate>[candidate('55555')];
        await service.detailsSource(anilistAnime(), userWith(metadataService: Service.shikimori));

        await service.confirmLink(
          source: Service.anilist,
          nativeId: '170942',
          candidate: candidate(junk),
        );

        expect(
          await cache.getByNativeId(Service.shikimori, junk),
          isNull,
          reason: 'a confirmed "$junk" must never become a cached mapping',
        );
        expect(
          (await cache.getByNativeId(Service.anilist, '170942'))?.linkedNativeId,
          isNull,
          reason: 'the source row must not be linked to an unusable target id',
        );

        final MediaDetailsSource after = await service.detailsSource(
          anilistAnime(),
          userWith(metadataService: Service.shikimori),
        );

        expect(after.service, Service.anilist, reason: 'no metadata fetch may be re-addressed with "$junk"');
        expect(after.anime.id, 170942);
        expect(after.isUnresolved, isTrue);
      });
    }

    test('declining leaves the entry unresolved and stops the dialog for the session', () async {
      lookup.searchResults = <MediaLinkCandidate>[candidate('55555')];
      await service.detailsSource(anilistAnime(), userWith(metadataService: Service.shikimori));
      await service.declineLink(source: Service.anilist, nativeId: '170942');

      final MediaDetailsSource after = await service.detailsSource(
        anilistAnime(),
        userWith(metadataService: Service.shikimori),
      );

      expect(after.proposal, isNull);
      expect(after.isUnresolved, isTrue);
      expect(lookup.searchCalls, 1);
      expect((await cache.getByNativeId(Service.anilist, '170942'))!.state, IdMappingState.unresolved);
    });

    test('a declined entry is proposed again after a relink reset', () async {
      lookup.searchResults = <MediaLinkCandidate>[candidate('55555')];
      await service.detailsSource(anilistAnime(), userWith(metadataService: Service.shikimori));
      await service.declineLink(source: Service.anilist, nativeId: '170942');

      await service.resetLink(source: Service.anilist, nativeId: '170942', target: Service.shikimori);
      final MediaDetailsSource after = await service.detailsSource(
        anilistAnime(),
        userWith(metadataService: Service.shikimori),
      );

      expect(after.proposal, isNotNull);
      expect(lookup.searchCalls, 2);
    });

    test('last session\'s misses are dropped by the first lookup of a session', () async {
      await cache.put(const IdMapping(
        service: Service.anilist,
        nativeId: '170942',
        state: IdMappingState.unresolved,
        source: IdMappingSource.titleSearch,
      ));
      lookup.probeResult = candidate('55555', malId: 58514);

      final MediaDetailsSource source = await service.detailsSource(
        anilistAnime(),
        userWith(metadataService: Service.shikimori),
      );

      expect(source.service, Service.shikimori, reason: 'the stale miss must not shadow this session');
      expect(source.isUnresolved, isFalse);
    });
  });

  group('cache rows', () {
    test('round-trip through toMap/fromMap keeps every field', () {
      const IdMapping mapping = IdMapping(
        service: Service.shikimori,
        nativeId: '65261',
        malId: 58514,
        state: IdMappingState.confirmed,
        source: IdMappingSource.titleSearch,
        linkedService: Service.anilist,
        linkedNativeId: '170942',
      );

      final IdMapping restored = IdMapping.fromMap(mapping.toMap());

      expect(restored, mapping);
      expect(restored.linkedService, Service.anilist);
      expect(restored.linkedNativeId, '170942');
    });

    test('a rewritten row drops the stale pivot index', () async {
      await cache.put(const IdMapping(
        service: Service.anilist,
        nativeId: '1',
        malId: 100,
        state: IdMappingState.authoritative,
        source: IdMappingSource.providerField,
      ));
      await cache.put(const IdMapping(
        service: Service.anilist,
        nativeId: '1',
        malId: 200,
        state: IdMappingState.authoritative,
        source: IdMappingSource.aniZip,
      ));

      expect(await cache.getByMalId(Service.anilist, 100), isNull);
      expect((await cache.getByMalId(Service.anilist, 200))!.malId, 200);
    });
  });

  group('proposal keys', () {
    test('the prompt key is per entry and per provider pair', () {
      expect(
        mediaLinkEntryKey(source: Service.anilist, nativeId: '170942', target: Service.shikimori),
        'anilist:170942->shikimori',
      );
    });
  });
}

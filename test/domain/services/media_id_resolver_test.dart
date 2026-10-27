// Internal dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/services/id_mapping.dart';
import 'package:unyo/domain/services/media_id_cache.dart';
import 'package:unyo/domain/services/media_id_resolver.dart';

class FakeAniZipIdLookup implements AniZipIdLookup {
  AniZipIds? response;
  int calls = 0;
  int? lastAnilistId;

  @override
  Future<AniZipIds?> lookup({int? anilistId, int? malId}) async {
    calls++;
    lastAnilistId = anilistId;
    return response;
  }
}

class FakeMediaMappingLookup implements MediaMappingLookup {
  MediaLinkCandidate? probeResult;
  List<MediaLinkCandidate> searchResults = <MediaLinkCandidate>[];
  int probeCalls = 0;
  int searchCalls = 0;
  int? lastProbedMalId;
  MediaLinkQuery? lastQuery;

  @override
  Future<MediaLinkCandidate?> lookupByMalId(Service target, int malId) async {
    probeCalls++;
    lastProbedMalId = malId;
    return probeResult;
  }

  @override
  Future<List<MediaLinkCandidate>> searchCandidates(Service target, MediaLinkQuery query) async {
    searchCalls++;
    lastQuery = query;
    return searchResults;
  }
}

void main() {
  late InMemoryMediaIdCache cache;
  late FakeAniZipIdLookup aniZip;
  late FakeMediaMappingLookup lookup;
  late MediaIdResolver resolver;

  const MediaLinkQuery query = MediaLinkQuery(title: 'Kusuriya no Hitorigoto', year: 2023);

  MediaLinkCandidate candidate(String nativeId, {String? title, int? malId, int? year}) => MediaLinkCandidate(
        service: Service.shikimori,
        nativeId: nativeId,
        malId: malId,
        title: title ?? 'Kusuriya no Hitorigoto $nativeId',
        year: year ?? 2023,
        format: 'tv',
      );

  setUp(() {
    cache = InMemoryMediaIdCache();
    aniZip = FakeAniZipIdLookup();
    lookup = FakeMediaMappingLookup();
    resolver = MediaIdResolver(cache: cache, aniZipLookup: aniZip, mappingLookup: lookup);
  });

  group('chain order and authority tiers', () {
    test('the provider malId field wins and is cached as authoritative without asking AniZip', () async {
      final MediaIdResolution resolution = await resolver.resolveMalId(
        Service.anilist,
        '170942',
        knownMalId: 58514,
      );

      expect(resolution.isResolved, isTrue);
      expect(resolution.mapping!.malId, 58514);
      expect(resolution.mapping!.state, IdMappingState.authoritative);
      expect(resolution.mapping!.source, IdMappingSource.providerField);
      expect(aniZip.calls, 0);
      expect((await cache.getByNativeId(Service.anilist, '170942'))!.malId, 58514);
      expect((await cache.getByMalId(Service.anilist, 58514))!.nativeId, '170942');
    });

    test('AniZip is the second step and is applied automatically', () async {
      aniZip.response = const AniZipIds(anilistId: 170942, malId: 58514);

      final MediaIdResolution resolution = await resolver.resolveMalId(Service.anilist, '170942');

      expect(resolution.mapping!.malId, 58514);
      expect(resolution.mapping!.source, IdMappingSource.aniZip);
      expect(resolution.mapping!.state, IdMappingState.authoritative);
      expect(aniZip.lastAnilistId, 170942);
      expect(lookup.searchCalls, 0, reason: 'AniZip results never trigger the confirmation dialog');
    });

    test('a cached authoritative mapping short-circuits the rest of the chain', () async {
      await resolver.resolveMalId(Service.anilist, '170942', knownMalId: 58514);
      aniZip.response = const AniZipIds(anilistId: 170942, malId: 999);

      final MediaIdResolution resolution = await resolver.resolveMalId(Service.anilist, '170942');

      expect(resolution.mapping!.malId, 58514);
      expect(aniZip.calls, 0);
    });

    test('never derives a malId from a native id when nothing authoritative exists', () async {
      aniZip.response = null;

      final MediaIdResolution resolution = await resolver.resolveMalId(Service.anilist, '170942');

      expect(resolution.isUnresolved, isTrue);
      expect(resolution.mapping, isNull);
      expect(await cache.getByNativeId(Service.anilist, '170942'), isNull);
    });

    test('Shikimori sources have no AniZip leg and never self-derive a pivot', () async {
      final MediaIdResolution resolution = await resolver.resolveMalId(Service.shikimori, '65261');

      expect(resolution.isUnresolved, isTrue);
      expect(aniZip.calls, 0);
      expect((await cache.getByNativeId(Service.shikimori, '65261')), isNull);
    });
  });

  group('target translation', () {
    test('same provider is the identity path with zero lookups', () async {
      final MediaIdResolution resolution = await resolver.resolveTarget(
        source: Service.anilist,
        nativeId: '170942',
        target: Service.anilist,
        query: query,
        knownMalId: 58514,
      );

      expect(resolution.isResolved, isTrue);
      expect(resolution.mapping!.source, IdMappingSource.identity);
      expect(aniZip.calls, 0);
      expect(lookup.probeCalls, 0);
      expect(lookup.searchCalls, 0);
    });

    test('probe-and-verify accepts only a record whose own malId matches', () async {
      lookup.probeResult = candidate('55555', malId: 58514);

      final MediaIdResolution resolution = await resolver.resolveTarget(
        source: Service.anilist,
        nativeId: '170942',
        target: Service.shikimori,
        query: query,
        knownMalId: 58514,
      );

      expect(resolution.isResolved, isTrue);
      expect(resolution.mapping!.service, Service.shikimori);
      expect(resolution.mapping!.nativeId, '55555');
      expect(resolution.mapping!.state, IdMappingState.authoritative);
      expect(lookup.lastProbedMalId, 58514);
      expect(lookup.searchCalls, 0);
      // The source pivot is cached too, so the next open skips step 1/2.
      expect((await cache.getByNativeId(Service.anilist, '170942'))!.malId, 58514);
    });

    test('a failed probe falls through to the title search instead of guessing', () async {
      lookup.probeResult = null;
      lookup.searchResults = <MediaLinkCandidate>[candidate('55555')];

      final MediaIdResolution resolution = await resolver.resolveTarget(
        source: Service.anilist,
        nativeId: '170942',
        target: Service.shikimori,
        query: query,
        knownMalId: 58514,
      );

      expect(resolution.needsConfirmation, isTrue);
      expect(resolution.mapping, isNull);
      expect(lookup.searchCalls, 1);
      expect(lookup.lastQuery!.title, 'Kusuriya no Hitorigoto');
    });

    test('idMal=0 records are still addressable and degrade without a pivot', () async {
      lookup.searchResults = const <MediaLinkCandidate>[];

      final MediaIdResolution resolution = await resolver.resolveTarget(
        source: Service.anilist,
        nativeId: '424242',
        target: Service.shikimori,
        query: query,
        knownMalId: 0,
      );

      expect(resolution.isUnresolved, isTrue);
      final IdMapping? row = await cache.getByNativeId(Service.anilist, '424242');
      expect(row, isNotNull, reason: 'the native id key must exist even with no MAL pivot');
      expect(row!.malId, isNull);
      expect(row.state, IdMappingState.unresolved);
    });

    test('a total miss is cached as unresolved for a later retry', () async {
      lookup.searchResults = const <MediaLinkCandidate>[];

      await resolver.resolveTarget(
        source: Service.anilist,
        nativeId: '170942',
        target: Service.shikimori,
        query: query,
      );

      expect((await cache.getByNativeId(Service.anilist, '170942'))!.state, IdMappingState.unresolved);
    });
  });

  group('confirmation gating', () {
    setUp(() {
      lookup.searchResults = List<MediaLinkCandidate>.generate(7, (index) => candidate('5555$index'));
    });

    test('a heuristic hit is proposed but never cached before the user confirms', () async {
      final MediaIdResolution resolution = await resolver.resolveTarget(
        source: Service.anilist,
        nativeId: '170942',
        target: Service.shikimori,
        query: query,
      );

      expect(resolution.needsConfirmation, isTrue);
      expect(lookup.searchCalls, 1);
      expect(cache.entries, isEmpty, reason: 'a fuzzy match must never be applied silently');
    });

    test('at most five candidates are proposed, best-first', () async {
      final MediaIdResolution resolution = await resolver.resolveTarget(
        source: Service.anilist,
        nativeId: '170942',
        target: Service.shikimori,
        query: query,
      );

      expect(resolution.candidates, hasLength(MediaIdResolver.maxTitleSearchCandidates));
      expect(resolution.candidates.map((candidate) => candidate.nativeId).toList(), <String>[
        '55550',
        '55551',
        '55552',
        '55553',
        '55554',
      ]);
    });

    test('confirming caches the link and skips the search on the next resolve', () async {
      final MediaIdResolution proposal = await resolver.resolveTarget(
        source: Service.anilist,
        nativeId: '170942',
        target: Service.shikimori,
        query: query,
      );
      final MediaLinkCandidate chosen = proposal.candidates.first;

      await resolver.confirmLink(source: Service.anilist, nativeId: '170942', candidate: chosen);
      final MediaIdResolution second = await resolver.resolveTarget(
        source: Service.anilist,
        nativeId: '170942',
        target: Service.shikimori,
        query: query,
      );

      expect(lookup.searchCalls, 1, reason: 'the confirmed link must be reused, not re-searched');
      expect(second.isResolved, isTrue);
      expect(second.mapping!.service, Service.shikimori);
      expect(second.mapping!.nativeId, chosen.nativeId);
      expect(second.mapping!.state, IdMappingState.confirmed);
    });

    test('declining leaves the entry unresolved and skips the dialog for the rest of the session', () async {
      await resolver.resolveTarget(
        source: Service.anilist,
        nativeId: '170942',
        target: Service.shikimori,
        query: query,
      );
      await resolver.declineLink(source: Service.anilist, nativeId: '170942');

      final MediaIdResolution second = await resolver.resolveTarget(
        source: Service.anilist,
        nativeId: '170942',
        target: Service.shikimori,
        query: query,
      );

      expect(second.needsConfirmation, isFalse);
      expect(second.isUnresolved, isTrue);
      expect(lookup.searchCalls, 1);
      expect((await cache.getByNativeId(Service.anilist, '170942'))!.state, IdMappingState.unresolved);
    });

    test('purgeUnresolved forgets the decline so the next session retries', () async {
      await resolver.declineLink(source: Service.anilist, nativeId: '170942');
      await resolver.purgeUnresolved();

      final MediaIdResolution retry = await resolver.resolveTarget(
        source: Service.anilist,
        nativeId: '170942',
        target: Service.shikimori,
        query: query,
      );

      expect(retry.needsConfirmation, isTrue);
      expect(lookup.searchCalls, 1);
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
}

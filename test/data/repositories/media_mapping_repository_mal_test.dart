// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/media/media_link_candidate.dart';
import 'package:unyo/data/repositories/media_mapping_repository_mal.dart';
import 'package:unyo/domain/repositories/media_id_cache.dart';

/// Repository-level tests for [MediaMappingRepositoryMal] (WP #156 D3).
///
/// The mapping is the AniList media id <-> MAL id pair taken from the AniList
/// media models' `idMal` field; these tests pin the validation rule (never
/// guess an identity) and the cache round-trip through the shared
/// [MediaIdCache].
void main() {
  late InMemoryMediaIdCache cache;
  late MediaMappingRepositoryMal repository;

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));
    cache = InMemoryMediaIdCache();
    sl.registerSingleton<MediaIdCache>(cache);
    repository = MediaMappingRepositoryMal();
  });

  group('MediaMappingRepositoryMal mapping validation', () {
    test('a valid idMal pair maps and is accepted', () async {
      final int? malId = await repository.malIdForAniListMedia(anilistId: 170942, idMal: 58514);

      expect(malId, 58514);
    });

    test('idMal 0 identifies no MAL entry and yields no mapping', () async {
      final int? malId = await repository.malIdForAniListMedia(anilistId: 170942, idMal: 0);

      expect(malId, isNull);
      expect(await cache.getByNativeId(Service.anilist, '170942'), isNull);
    });

    test('a negative idMal yields no mapping', () async {
      final int? malId = await repository.malIdForAniListMedia(anilistId: 170942, idMal: -1);

      expect(malId, isNull);
      expect(await cache.getByNativeId(Service.anilist, '170942'), isNull);
    });

    test('an absent idMal yields no mapping, never a title-search fallback', () async {
      final int? malId = await repository.malIdForAniListMedia(anilistId: 170942, idMal: null);

      expect(malId, isNull);
      expect(await cache.getByNativeId(Service.anilist, '170942'), isNull);
      expect(await cache.getByMalId(Service.anilist, 58514), isNull);
      expect(
        await repository.searchCandidates(Service.mal, 'Kusuriya no Hitorigoto'),
        isEmpty,
        reason: 'D3: a title search must never establish an identity',
      );
    });

    test('a non-positive AniList id is refused before anything is cached', () async {
      expect(await repository.malIdForAniListMedia(anilistId: 0, idMal: 58514), isNull);
      expect(await repository.malIdForAniListMedia(anilistId: -3, idMal: 58514), isNull);
      expect(await cache.getByMalId(Service.anilist, 58514), isNull);
    });
  });

  group('MediaMappingRepositoryMal cache round-trip', () {
    test('the pair is readable in both directions after one mapping', () async {
      await repository.malIdForAniListMedia(anilistId: 170942, idMal: 58514);

      final IdMapping? byNative = await cache.getByNativeId(Service.anilist, '170942');
      expect(byNative, isNotNull);
      expect(byNative!.malId, 58514);
      expect(byNative.state, IdMappingState.authoritative);
      expect(byNative.source, IdMappingSource.providerField);

      final IdMapping? byPivot = await cache.getByMalId(Service.anilist, 58514);
      expect(byPivot, isNotNull);
      expect(byPivot!.nativeId, '170942');

      expect(await repository.anilistIdForMalId(58514), 170942);
    });

    test('a repeated mapping is idempotent', () async {
      await repository.malIdForAniListMedia(anilistId: 170942, idMal: 58514);
      await repository.malIdForAniListMedia(anilistId: 170942, idMal: 58514);

      expect((await cache.getByNativeId(Service.anilist, '170942'))!.malId, 58514);
    });

    test('an uncached or malformed MAL id has no AniList translation', () async {
      expect(await repository.anilistIdForMalId(999), isNull);
      expect(await repository.anilistIdForMalId(0), isNull);
      expect(await repository.anilistIdForMalId(-5), isNull);
    });
  });

  group('MediaMappingRepositoryMal lookup leg', () {
    test('the MAL record for a MAL id is the id itself, never a guess', () async {
      final MediaLinkCandidate? candidate = await repository.lookupByMalId(Service.mal, 58514);

      expect(candidate, isNotNull);
      expect(candidate!.service, Service.mal);
      expect(candidate.nativeId, '58514');
      expect(candidate.malId, 58514);
    });

    test('a non-positive MAL id identifies no record and is refused', () async {
      expect(await repository.lookupByMalId(Service.mal, 0), isNull);
      expect(await repository.lookupByMalId(Service.mal, -1), isNull);
    });

    test('the leg only speaks for its own provider', () async {
      expect(await repository.lookupByMalId(Service.shikimori, 58514), isNull);
      expect(await repository.lookupByMalId(Service.anilist, 58514), isNull);
    });
  });
}

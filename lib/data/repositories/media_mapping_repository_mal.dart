// External dependencies
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/media/media_id_service.dart';
import 'package:unyo/core/services/media/media_link_candidate.dart';
import 'package:unyo/domain/repositories/media_id_cache.dart';

/// MyAnimeList leg of the MAL pivot (WP #156 D3): the AniList media id <->
/// MAL id mapping.
///
/// Mirrors `MediaMappingRepositoryShikimori` (the Shikimori leg of the same
/// pivot), adapted to the one difference that matters: **MAL's native id space
/// IS the MAL id space**. The Shikimori leg has to probe its API because a
/// Shikimori native id is not assumed to be a MAL id (they only coincide on
/// MAL-linked entries); on MyAnimeList the native id of the record for MAL id
/// `X` is `X` by definition — the mapping is an identity, never a guess, and
/// the only question is whether `X` is a well-formed id at all.
///
/// The authoritative link between the two id spaces is the AniList media
/// models' `idMal` field (present on `AnilistAnimeModel`/`AnilistMangaModel`
/// and carried on the domain `Anime`/`Manga` entities — SPEC §9 Q4 verified,
/// no GraphQL change needed). Per dart-code-style §7 the field is only trusted
/// after validation: `idMal` absent (null), `0` or negative identifies no MAL
/// entry and yields **no mapping** — loudly, never a title-search fallback
/// (D3: a title search must never establish an identity).
///
/// Mappings are cached in the shared [MediaIdCache] (`mediaIdCache` hive box)
/// as provider-field rows on the AniList side, so both directions of the pair
/// round-trip through `getByNativeId`/`getByMalId`.
class MediaMappingRepositoryMal implements MediaMappingLookup {
  final MediaIdCache _cache = sl<MediaIdCache>();
  final Logger _logger = sl<Logger>();

  /// The MAL id of one AniList media record, from the record's own [idMal]
  /// field (the primary source).
  ///
  /// Both ids are validated before anything is cached (dart-code-style §7):
  /// `anilistId` must be positive, and [idMal] must be a positive integer —
  /// `null` (absent), `0` and negative values are "the provider publishes no
  /// MAL id" and return no mapping. Never falls back to a title search (D3).
  Future<int?> malIdForAniListMedia({required int anilistId, required int? idMal}) async {
    if (anilistId <= 0) {
      _logger.w("Refusing to map AniList id '$anilistId': ids must be positive integers");
      return null;
    }
    if (idMal == null) {
      _logger.w("AniList $anilistId publishes no idMal (absent), no MAL mapping");
      return null;
    }
    if (idMal <= 0) {
      _logger.w("AniList $anilistId publishes idMal $idMal, which identifies no MAL entry: no mapping");
      return null;
    }
    await _cache.put(IdMapping(
      service: Service.anilist,
      nativeId: '$anilistId',
      malId: idMal,
      state: IdMappingState.authoritative,
      source: IdMappingSource.providerField,
    ));
    return idMal;
  }

  /// The AniList media id of [malId], read back from the cached pair this class
  /// (or the pivot chain) wrote. Null when nothing verified one — the caller
  /// keeps its own record instead of re-addressing it to a guessed id.
  Future<int?> anilistIdForMalId(int malId) async {
    if (malId <= 0) {
      _logger.w("Refusing to map MAL id '$malId': ids must be positive integers");
      return null;
    }
    final IdMapping? mapping = await _cache.getByMalId(Service.anilist, malId);
    if (mapping == null || !mapping.isResolved || mapping.malId != malId) return null;
    final int? anilistId = int.tryParse(mapping.nativeId);
    if (anilistId == null || anilistId <= 0) {
      _logger.w("Cached AniList row '${mapping.nativeId}' for MAL $malId has no usable native id, ignoring it");
      return null;
    }
    return anilistId;
  }

  /// The MAL record for [malId]: native id `'$malId'` (the identity of MAL's id
  /// space — see the class doc), accepted only for a well-formed id. A `0` or
  /// negative [malId] identifies no entry and is refused, loudly, instead of
  /// being re-addressed or title-searched (dart-code-style §7, D3).
  @override
  Future<MediaLinkCandidate?> lookupByMalId(Service target, int malId) async {
    if (target != Service.mal) return null;
    if (malId <= 0) {
      _logger.w("Refusing MAL lookup for '$malId': ids must be positive integers");
      return null;
    }
    return MediaLinkCandidate(
      service: Service.mal,
      nativeId: '$malId',
      malId: malId,
      title: '',
    );
  }

  /// Deliberately empty for every target: a title search must never establish
  /// an identity (D3), so the MAL leg contributes no proposal candidates to
  /// the chain's user-confirmation stage. An unresolved record stays
  /// unresolved — and the "add manually" path — instead of being glued to a
  /// same-title entry.
  @override
  Future<List<MediaLinkCandidate>> searchCandidates(Service target, String title) async {
    return const <MediaLinkCandidate>[];
  }
}

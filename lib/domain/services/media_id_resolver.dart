import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/services/id_mapping.dart';
import 'package:unyo/domain/services/media_id_cache.dart';

/// What the caller wants to find a record for. Only the title search stage
/// needs it, but it always travels with the request so both stages see the same
/// input.
class MediaLinkQuery {
  final String title;
  final List<String> alternativeTitles;
  final int? year;
  final bool isAnime;
  final String? format;

  const MediaLinkQuery({
    required this.title,
    this.alternativeTitles = const <String>[],
    this.year,
    this.isAnime = true,
    this.format,
  });
}

/// One row a target-provider title search (or a pivot probe) produced.
class MediaLinkCandidate {
  final Service service;
  final String nativeId;
  final int? malId;
  final String title;
  final int? year;
  final String? format;
  final bool isAnime;

  const MediaLinkCandidate({
    required this.service,
    required this.nativeId,
    required this.title,
    this.malId,
    this.year,
    this.format,
    this.isAnime = true,
  });

  bool get hasPivot => malId != null && malId! > 0;

  @override
  bool operator ==(Object other) => other is MediaLinkCandidate && other.service == service && other.nativeId == nativeId;

  @override
  int get hashCode => Object.hash(service, nativeId);

  @override
  String toString() => 'MediaLinkCandidate(${service.name}:$nativeId "$title" $year ${format ?? ''})';
}

/// Result of a resolution attempt.
class MediaIdResolution {
  /// Non-null when the chain produced something usable — authoritative,
  /// confirmed, or an `unresolved` marker that the caller should treat as
  /// "fall back to the user provider".
  final IdMapping? mapping;

  /// Non-empty only when a heuristic title search proposed candidates. The
  /// caller must ask the user before anything is cached.
  final List<MediaLinkCandidate> candidates;

  const MediaIdResolution({this.mapping, this.candidates = const <MediaLinkCandidate>[]});

  bool get needsConfirmation => candidates.isNotEmpty;

  bool get isResolved => mapping != null && mapping!.isResolved;

  bool get isUnresolved => !isResolved && !needsConfirmation;
}

/// AniZip `/mappings` leg of the chain. Returns null when AniZip has no entry.
abstract class AniZipIdLookup {
  Future<AniZipIds?> lookup({int? anilistId, int? malId});
}

class AniZipIds {
  final int? anilistId;
  final int? malId;

  const AniZipIds({this.anilistId, this.malId});
}

/// Target-provider queries used by the mapping chain.
abstract class MediaMappingLookup {
  /// Probe-and-verify: returns the target provider's record for [malId] only if
  /// that record's **own** `malId` field equals [malId]. A native-id guess is
  /// never accepted.
  Future<MediaLinkCandidate?> lookupByMalId(Service target, int malId);

  /// Title search on [target], ranked best-first.
  Future<List<MediaLinkCandidate>> searchCandidates(Service target, MediaLinkQuery query);
}

/// Bridges providers through the MAL id pivot (WP #61 decision 1 + 4).
///
/// Chain, in authority order:
/// 1. the provider's own `malId`/`idMal` field — authoritative, auto-applied;
/// 2. AniZip — authoritative, auto-applied;
/// 3. target-provider title search — heuristic, needs a one-time user
///    confirmation before it is cached.
///
/// A total miss caches an `unresolved` row (retried next session via
/// [purgeUnresolved]) and the caller falls back to user-provider details.
class MediaIdResolver {
  static const int maxTitleSearchCandidates = 5;

  final MediaIdCache _cache;
  final AniZipIdLookup? _aniZipLookup;
  final MediaMappingLookup? _mappingLookup;

  MediaIdResolver({
    required MediaIdCache cache,
    AniZipIdLookup? aniZipLookup,
    MediaMappingLookup? mappingLookup,
  })  : _cache = cache,
        _aniZipLookup = aniZipLookup,
        _mappingLookup = mappingLookup;

  MediaIdCache get cache => _cache;

  /// Pivot only: `(service, nativeId) -> malId`.
  ///
  /// Runs chain steps 1 and 2; it never runs the title search, because a search
  /// needs the *other* provider to be meaningful — use [resolveTarget] for that.
  Future<MediaIdResolution> resolveMalId(
    Service service,
    String nativeId, {
    int? knownMalId,
  }) async {
    final IdMapping? cached = await _cache.getByNativeId(service, nativeId);
    if (cached != null) return MediaIdResolution(mapping: cached);

    if (knownMalId != null && knownMalId > 0) {
      final IdMapping mapping = IdMapping(
        service: service,
        nativeId: nativeId,
        malId: knownMalId,
        state: IdMappingState.authoritative,
        source: IdMappingSource.providerField,
      );
      await _cache.put(mapping);
      return MediaIdResolution(mapping: mapping);
    }

    final int? aniZipMalId = await _pivotFromAniZip(service, nativeId);
    if (aniZipMalId != null) {
      final IdMapping mapping = IdMapping(
        service: service,
        nativeId: nativeId,
        malId: aniZipMalId,
        state: IdMappingState.authoritative,
        source: IdMappingSource.aniZip,
      );
      await _cache.put(mapping);
      return MediaIdResolution(mapping: mapping);
    }

    // Nothing authoritative yet; do not cache — a title search may still come.
    return const MediaIdResolution();
  }

  /// Full translation: `(source, nativeId) -> target provider native id`.
  Future<MediaIdResolution> resolveTarget({
    required Service source,
    required String nativeId,
    required Service target,
    required MediaLinkQuery query,
    int? knownMalId,
  }) async {
    if (source == target) {
      final IdMapping mapping = IdMapping(
        service: target,
        nativeId: nativeId,
        malId: knownMalId != null && knownMalId > 0 ? knownMalId : null,
        state: IdMappingState.authoritative,
        source: IdMappingSource.identity,
      );
      await _cache.put(mapping);
      return MediaIdResolution(mapping: mapping);
    }

    final IdMapping? sourceMapping = await _cache.getByNativeId(source, nativeId);

    // An unresolved row written this session means "already asked / already
    // failed": do not nag again, just fall back.
    if (sourceMapping != null && !sourceMapping.isResolved) {
      return MediaIdResolution(mapping: sourceMapping);
    }

    // A link the user already confirmed for this target provider.
    if (sourceMapping != null &&
        sourceMapping.isResolved &&
        sourceMapping.linkedService == target &&
        sourceMapping.linkedNativeId != null) {
      final IdMapping? linked = await _cache.getByNativeId(target, sourceMapping.linkedNativeId!);
      if (linked != null && linked.isResolved) return MediaIdResolution(mapping: linked);
      final IdMapping fallback = IdMapping(
        service: target,
        nativeId: sourceMapping.linkedNativeId!,
        malId: sourceMapping.malId,
        state: sourceMapping.state,
        source: sourceMapping.source,
      );
      await _cache.put(fallback);
      return MediaIdResolution(mapping: fallback);
    }

    final int? knownPivot = knownMalId != null && knownMalId > 0 ? knownMalId : null;
    final IdMapping? sourcePivot = sourceMapping != null && sourceMapping.hasPivot ? sourceMapping : null;

    int? pivot = sourcePivot?.malId ?? knownPivot;
    IdMappingSource pivotSource = sourcePivot?.source ??
        (knownPivot != null ? IdMappingSource.providerField : IdMappingSource.aniZip);
    if (pivot == null) {
      final MediaIdResolution pivotResolution = await resolveMalId(source, nativeId, knownMalId: knownPivot);
      final IdMapping? pivotMapping = pivotResolution.mapping;
      if (pivotMapping != null && pivotMapping.hasPivot) {
        pivot = pivotMapping.malId;
        pivotSource = pivotMapping.source;
      }
    }

    if (pivot != null) {
      final IdMapping? cachedTarget = await _cache.getByMalId(target, pivot);
      if (cachedTarget != null && cachedTarget.isResolved) {
        await _cache.put(IdMapping(
          service: source,
          nativeId: nativeId,
          malId: pivot,
          state: cachedTarget.state,
          source: cachedTarget.source,
        ));
        return MediaIdResolution(mapping: cachedTarget);
      }

      final MediaLinkCandidate? probed = await _mappingLookup?.lookupByMalId(target, pivot);
      if (probed != null) {
        final IdMapping targetMapping = IdMapping(
          service: target,
          nativeId: probed.nativeId,
          malId: pivot,
          state: IdMappingState.authoritative,
          source: IdMappingSource.providerField,
        );
        await _cache.put(targetMapping);
        await _cache.put(IdMapping(
          service: source,
          nativeId: nativeId,
          malId: pivot,
          state: IdMappingState.authoritative,
          source: pivotSource,
        ));
        return MediaIdResolution(mapping: targetMapping);
      }
    }

    // Step 3: heuristic title search, gated behind a user confirmation.
    final List<MediaLinkCandidate> candidates = ((await _mappingLookup?.searchCandidates(target, query)) ??
            const <MediaLinkCandidate>[])
        .take(maxTitleSearchCandidates)
        .toList(growable: false);
    if (candidates.isNotEmpty) {
      return MediaIdResolution(candidates: candidates);
    }

    final IdMapping unresolved = IdMapping(
      service: source,
      nativeId: nativeId,
      state: IdMappingState.unresolved,
      source: IdMappingSource.titleSearch,
    );
    await _cache.put(unresolved);
    return MediaIdResolution(mapping: unresolved);
  }

  /// Caches a user-confirmed link between a source record and a search hit.
  Future<IdMapping> confirmLink({
    required Service source,
    required String nativeId,
    required MediaLinkCandidate candidate,
  }) async {
    final IdMapping targetMapping = IdMapping(
      service: candidate.service,
      nativeId: candidate.nativeId,
      malId: candidate.malId,
      state: IdMappingState.confirmed,
      source: IdMappingSource.titleSearch,
    );
    await _cache.put(targetMapping);
    await _cache.put(IdMapping(
      service: source,
      nativeId: nativeId,
      malId: candidate.malId,
      state: IdMappingState.confirmed,
      source: IdMappingSource.titleSearch,
      linkedService: candidate.service,
      linkedNativeId: candidate.nativeId,
    ));
    return targetMapping;
  }

  /// "None of these": the entry stays unresolved and nothing is linked.
  Future<IdMapping> declineLink({required Service source, required String nativeId}) async {
    final IdMapping unresolved = IdMapping(
      service: source,
      nativeId: nativeId,
      state: IdMappingState.unresolved,
      source: IdMappingSource.titleSearch,
    );
    await _cache.put(unresolved);
    return unresolved;
  }

  /// Called once at startup: `unresolved` rows from the previous session are
  /// forgotten so the chain gets another chance.
  Future<void> purgeUnresolved() => _cache.purgeUnresolved();

  /// Forget one record (used by the manual "link metadata entry" action) so the
  /// chain — and, when it gets there, the dialog — runs again.
  Future<void> forget(Service service, String nativeId) => _cache.remove(service, nativeId);

  Future<int?> _pivotFromAniZip(Service service, String nativeId) async {
    final AniZipIdLookup? lookup = _aniZipLookup;
    if (lookup == null) return null;
    switch (service) {
      case Service.anilist:
        final int? anilistId = int.tryParse(nativeId);
        if (anilistId == null) return null;
        final AniZipIds? ids = await lookup.lookup(anilistId: anilistId);
        final int? malId = ids?.malId;
        return malId != null && malId > 0 ? malId : null;
      case Service.mal:
        // A MAL record's native id *is* its MAL id; no cross-provider guess.
        final int? nativeMalId = int.tryParse(nativeId);
        return nativeMalId != null && nativeMalId > 0 ? nativeMalId : null;
      case Service.kitsu:
      case Service.shikimori:
      case Service.simkl:
        // AniZip has no id space for these providers.
        return null;
    }
  }
}

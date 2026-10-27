// External dependencies
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/media/media_link_candidate.dart';
import 'package:unyo/core/services/media/media_link_proposal.dart';
import 'package:unyo/core/services/media/media_provenance.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/media_id_cache.dart';

/// Where the details of an opened record come from.
class MediaDetailsSource {
  /// The record to query, re-addressed to [service]'s native id.
  final Anime anime;

  /// Provider the details are read from.
  final Service service;

  /// Set when the chain could only propose title-search hits: the user has to
  /// pick one before anything is cached.
  final MediaLinkProposal? proposal;

  /// No verified metadata-provider entry: the page renders the record's own
  /// details and offers the manual relink action.
  final bool isUnresolved;

  const MediaDetailsSource({
    required this.anime,
    required this.service,
    this.proposal,
    this.isUnresolved = false,
  });
}

/// AniZip `/mappings` leg of the chain: both directions of the MAL pivot.
abstract class AniZipIdLookup {
  /// The MAL id AniZip lists for [anilistId], or null when it has no entry.
  Future<int?> malIdForAnilistId(int anilistId);

  /// The AniList id AniZip lists for [malId], or null when it has no entry.
  Future<int?> anilistIdForMalId(int malId);
}

/// Target-provider queries used by the mapping chain.
abstract class MediaMappingLookup {
  /// Probe-and-verify: returns the target provider's record for [malId] only if
  /// that record's **own** `malId` field equals [malId]. A native-id guess is
  /// never accepted.
  Future<MediaLinkCandidate?> lookupByMalId(Service target, int malId);

  /// Title search on [target], ranked best-first.
  Future<List<MediaLinkCandidate>> searchCandidates(Service target, String title);
}

/// One run of the chain: either a mapping, or the title-search candidates the
/// user still has to choose from. Neither means "unresolved".
class _LinkResolution {
  final IdMapping? mapping;
  final List<MediaLinkCandidate> candidates;

  const _LinkResolution({this.mapping, this.candidates = const <MediaLinkCandidate>[]});
}

/// Bridges providers through the MAL id pivot (WP #61 decision 1 + 4).
///
/// Chain, in authority order:
/// 1. the provider's own `malId`/`idMal` field — authoritative, auto-applied;
/// 2. AniZip — authoritative, auto-applied. Both directions of the pivot: it
///    supplies the MAL pivot of an AniList record and the AniList record of a
///    MAL pivot (the target-provider probe has no AniList id space);
/// 3. target-provider title search — heuristic, needs a one-time user
///    confirmation before it is cached.
///
/// A total miss caches an `unresolved` row, which makes the caller fall back to
/// user-provider details and is retried once in the next session.
class MediaIdService {
  static const int maxTitleSearchCandidates = 5;

  final MediaIdCache _cache;
  final AniZipIdLookup? _aniZipLookup;
  final MediaMappingLookup? _mappingLookup;
  final Logger _logger = sl<Logger>();

  /// Entries already prompted in this app session, so reopening a details page
  /// does not ask again. Never a nag — the page keeps its manual relink action.
  final Set<String> _promptedLinks = <String>{};

  /// Unresolved rows only live for one session, so the first lookup of a
  /// session drops the previous session's misses and the chain retries them.
  Future<void>? _lastSessionPurge;

  MediaIdService({
    required MediaIdCache cache,
    AniZipIdLookup? aniZipLookup,
    MediaMappingLookup? mappingLookup,
  })  : _cache = cache,
        _aniZipLookup = aniZipLookup,
        _mappingLookup = mappingLookup;

  /// Which record the details page must query, and whether the entry still has
  /// to be linked by the user.
  Future<MediaDetailsSource> detailsSource(Anime anime, User loggedUser) async {
    await _purgeLastSessionMisses();
    final Service metadataService = loggedUser.settings.metadataService;
    final Service provenance = MediaProvenance.ofAnime(anime);
    if (provenance == metadataService) return MediaDetailsSource(anime: anime, service: provenance);

    final _LinkResolution resolution = await _resolveTarget(
      source: provenance,
      nativeId: '${anime.id}',
      target: metadataService,
      title: MediaFields.searchTitle(anime),
      knownMalId: anime.idMal,
    );
    final IdMapping? mapping = resolution.mapping;
    if (mapping != null && mapping.isResolved && mapping.service == metadataService) {
      final int? targetNativeId = _usableNativeId(mapping.nativeId);
      if (targetNativeId != null) {
        return MediaDetailsSource(
          anime: MediaFields.withNativeId(anime, targetNativeId),
          service: metadataService,
        );
      }
      // A resolved row whose native id is not a *positive* number is a miss, not
      // a licence to re-address the record: `0`, a negative id and junk all
      // address no entry — AniList 404s on them, Shikimori answers with default
      // junk details — so the page would open an unrelated entry instead of
      // falling back and offering the relink action. Reusing the source id
      // hides that action too. Same rule as [userNativeIdFor] returning null —
      // never guess an id.
      //
      // The unusable row is forgotten as well, **together with the source row's
      // link to it**: `_confirmedLink` rebuilds the target row from
      // `linkedNativeId`, so dropping the target alone would let the next lookup
      // resurrect it and the entry could never reach the title-search stage.
      _logger.w(
        "Cached ${mapping.service.name} row '${mapping.nativeId}' has no usable native id, "
        "treating the ${provenance.name}:${anime.id} link as unresolved",
      );
      await _forgetUnusableLink(provenance, '${anime.id}', mapping.service, mapping.nativeId);
    }

    // Unresolved, or waiting for a confirmation: the page keeps the record's own
    // details until a link exists.
    final MediaDetailsSource fallback = MediaDetailsSource(
      anime: anime,
      service: provenance,
      isUnresolved: true,
    );
    if (resolution.candidates.isEmpty) return fallback;
    final MediaLinkProposal proposal = MediaLinkProposal(
      userService: loggedUser.settings.userService,
      metadataService: metadataService,
      sourceService: provenance,
      sourceNativeId: '${anime.id}',
      candidates: resolution.candidates,
    );
    if (!_promptedLinks.add(proposal.entryKey)) return fallback;
    return MediaDetailsSource(
      anime: anime,
      service: provenance,
      proposal: proposal,
      isUnresolved: true,
    );
  }

  /// [anime]'s native id on the user provider, or null when the chain cannot
  /// verify one. Callers must skip the operation instead of guessing: writing to
  /// a guessed id would corrupt an unrelated entry.
  Future<int?> userNativeIdFor(Anime anime, Service userService) async {
    await _purgeLastSessionMisses();
    final Service provenance = MediaProvenance.ofAnime(anime);
    if (provenance == userService) return anime.id;

    final _LinkResolution resolution = await _resolveTarget(
      source: provenance,
      nativeId: '${anime.id}',
      target: userService,
      title: MediaFields.searchTitle(anime),
      knownMalId: anime.idMal,
    );
    final IdMapping? mapping = resolution.mapping;
    if (mapping == null || !mapping.isResolved || mapping.service != userService) {
      _logger.w("Cannot resolve ${provenance.name}:${anime.id} to ${userService.name}");
      return null;
    }
    _logger.i("Resolved ${provenance.name}:${anime.id} to ${userService.name}:${mapping.nativeId}");
    return _usableNativeId(mapping.nativeId);
  }

  /// Caches the link the user confirmed in the dialog.
  ///
  /// A candidate whose native id is empty, non-numeric, `0` or negative
  /// identifies no entry: caching it would poison the box forever (every later
  /// open would re-address the metadata provider with that id and never reach
  /// the title search again), so nothing is written and the entry stays
  /// unresolved — the page can run the chain, and the dialog, again.
  Future<void> confirmLink({
    required Service source,
    required String nativeId,
    required MediaLinkCandidate candidate,
  }) async {
    if (_usableNativeId(candidate.nativeId) == null) {
      _logger.w(
        "Refusing to cache confirmed ${candidate.service.name} candidate '${candidate.nativeId}' "
        "for ${source.name}:$nativeId: no usable native id",
      );
      return;
    }
    await _cache.put(IdMapping(
      service: candidate.service,
      nativeId: candidate.nativeId,
      malId: candidate.malId,
      state: IdMappingState.confirmed,
      source: IdMappingSource.titleSearch,
    ));
    await _cache.put(IdMapping(
      service: source,
      nativeId: nativeId,
      malId: candidate.malId,
      state: IdMappingState.confirmed,
      source: IdMappingSource.titleSearch,
      linkedService: candidate.service,
      linkedNativeId: candidate.nativeId,
    ));
  }

  /// "None of these": the entry stays unresolved and nothing is linked.
  Future<void> declineLink({required Service source, required String nativeId}) async {
    await _cache.put(IdMapping(
      service: source,
      nativeId: nativeId,
      state: IdMappingState.unresolved,
      source: IdMappingSource.titleSearch,
    ));
  }

  /// Drops a remembered miss (or link) and re-arms the prompt, so the manual
  /// "link metadata entry" action runs the chain — and its dialog — again.
  Future<void> resetLink({
    required Service source,
    required String nativeId,
    required Service target,
  }) async {
    await _cache.remove(source, nativeId);
    _promptedLinks.remove(MediaLinkProposal.entryKeyFor(source: source, nativeId: nativeId, target: target));
  }

  Future<void> _purgeLastSessionMisses() => _lastSessionPurge ??= _cache.purgeUnresolved();

  Future<_LinkResolution> _resolveTarget({
    required Service source,
    required String nativeId,
    required Service target,
    required String title,
    int? knownMalId,
  }) async {
    final IdMapping? sourceMapping = await _cache.getByNativeId(source, nativeId);

    // An unresolved row written this session means "already asked / already
    // failed": do not nag again, just fall back.
    if (sourceMapping != null && !sourceMapping.isResolved) {
      return _LinkResolution(mapping: sourceMapping);
    }

    // A link the user already confirmed for this target provider.
    if (sourceMapping != null && sourceMapping.linkedService == target && sourceMapping.linkedNativeId != null) {
      return _LinkResolution(mapping: await _confirmedLink(sourceMapping, target));
    }

    final int? pivot = await _pivotFor(source, nativeId, sourceMapping, knownMalId);
    if (pivot != null) {
      final IdMapping? targetMapping = await _mappingForPivot(source, nativeId, target, pivot);
      if (targetMapping != null) return _LinkResolution(mapping: targetMapping);
    }

    // Step 3: heuristic title search, gated behind a user confirmation.
    final List<MediaLinkCandidate> candidates = await _titleSearch(target, title);
    if (candidates.isNotEmpty) return _LinkResolution(candidates: candidates);

    final IdMapping unresolved = IdMapping(
      service: source,
      nativeId: nativeId,
      state: IdMappingState.unresolved,
      source: IdMappingSource.titleSearch,
    );
    await _cache.put(unresolved);
    return _LinkResolution(mapping: unresolved);
  }

  /// MAL pivot for a source record: cached row, the record's own `malId`, or
  /// AniZip. Null when no step of the chain knows one.
  Future<int?> _pivotFor(
    Service source,
    String nativeId,
    IdMapping? sourceMapping,
    int? knownMalId,
  ) async {
    if (sourceMapping != null && sourceMapping.hasPivot) return sourceMapping.malId;
    if (knownMalId != null && knownMalId > 0) {
      await _cache.put(IdMapping(
        service: source,
        nativeId: nativeId,
        malId: knownMalId,
        state: IdMappingState.authoritative,
        source: IdMappingSource.providerField,
      ));
      return knownMalId;
    }
    return _pivotFromAniZip(source, nativeId);
  }

  /// The target provider's row for [pivot] — cached, or a probe that verified
  /// the record's own `malId` field. Caches both sides of the pivot when it lands.
  Future<IdMapping?> _mappingForPivot(
    Service source,
    String nativeId,
    Service target,
    int pivot,
  ) async {
    IdMapping? targetMapping = await _cache.getByMalId(target, pivot);
    if (targetMapping == null || !targetMapping.isResolved) {
      targetMapping = await _probeTarget(target, pivot) ?? await _aniZipTarget(target, pivot);
      if (targetMapping == null) {
        _logger.w("No verified ${target.name} entry for MAL $pivot");
        return null;
      }
      await _cache.put(targetMapping);
    }
    await _cache.put(IdMapping(
      service: source,
      nativeId: nativeId,
      malId: pivot,
      state: targetMapping.state,
      source: targetMapping.source,
    ));
    return targetMapping;
  }

  /// The target provider's own record for [pivot]: a probe that verified the
  /// record's own `malId` field. Provider field, so the strongest step.
  Future<IdMapping?> _probeTarget(Service target, int pivot) async {
    final MediaLinkCandidate? probed = await _mappingLookup?.lookupByMalId(target, pivot);
    if (probed == null) return null;
    return IdMapping(
      service: target,
      nativeId: probed.nativeId,
      malId: pivot,
      state: IdMappingState.authoritative,
      source: IdMappingSource.providerField,
    );
  }

  /// AniZip's own MAL→AniList direction.
  ///
  /// The probe above cannot name an AniList id: the only [MediaMappingLookup]
  /// implementation speaks Shikimori. Without this leg a Shikimori record with a
  /// known MAL id could only reach AniList through an already-cached or a
  /// user-confirmed link, and the miss would be cached as unresolved — poisoning
  /// every later list read and write for that record.
  Future<IdMapping?> _aniZipTarget(Service target, int pivot) async {
    if (target != Service.anilist) return null;
    final int? anilistId = await _aniZipLookup?.anilistIdForMalId(pivot);
    if (anilistId == null) return null;
    return IdMapping(
      service: target,
      nativeId: '$anilistId',
      malId: pivot,
      state: IdMappingState.authoritative,
      source: IdMappingSource.aniZip,
    );
  }

  /// Rebuilds the target row of a link the user confirmed earlier.
  Future<IdMapping> _confirmedLink(IdMapping sourceMapping, Service target) async {
    final IdMapping linked = IdMapping(
      service: target,
      nativeId: sourceMapping.linkedNativeId!,
      malId: sourceMapping.malId,
      state: sourceMapping.state,
      source: sourceMapping.source,
    );
    final IdMapping? cached = await _cache.getByNativeId(target, linked.nativeId);
    if (cached != null && cached.isResolved) return cached;
    await _cache.put(linked);
    return linked;
  }

  /// Forgets an unusable target row **and** the source row's link to it.
  ///
  /// [detailsSource] drops the target row so it cannot shadow the chain, but
  /// `_confirmedLink` rebuilds that row from the source row's `linkedNativeId`.
  /// Leaving the link in place would therefore let the very next lookup
  /// resurrect the unusable row, and the entry could never reach the
  /// title-search stage again.
  Future<void> _forgetUnusableLink(
    Service source,
    String nativeId,
    Service target,
    String targetNativeId,
  ) async {
    final IdMapping? sourceRow = await _cache.getByNativeId(source, nativeId);
    if (sourceRow != null && sourceRow.linkedService == target && sourceRow.linkedNativeId != null) {
      await _cache.put(IdMapping(
        service: sourceRow.service,
        nativeId: sourceRow.nativeId,
        malId: sourceRow.malId,
        state: sourceRow.state,
        source: sourceRow.source,
      ));
    }
    await _cache.remove(target, targetNativeId);
  }

  Future<List<MediaLinkCandidate>> _titleSearch(Service target, String title) async {
    final MediaMappingLookup? lookup = _mappingLookup;
    if (lookup == null) return const <MediaLinkCandidate>[];
    final List<MediaLinkCandidate> candidates = await lookup.searchCandidates(target, title);
    return candidates.take(maxTitleSearchCandidates).toList(growable: false);
  }

  Future<int?> _pivotFromAniZip(Service service, String nativeId) async {
    switch (service) {
      case Service.anilist:
        final int? anilistId = _usableNativeId(nativeId);
        if (anilistId == null) return null;
        return _aniZipLookup?.malIdForAnilistId(anilistId);
      case Service.mal:
        // A MAL record's native id *is* its MAL id; no cross-provider guess.
        return _usableNativeId(nativeId);
      case Service.kitsu:
      case Service.shikimori:
      case Service.simkl:
        // AniZip has no id space for these providers.
        return null;
    }
  }

  /// A provider native id is usable only when it parses to a **positive** integer.
  ///
  /// `int.tryParse` happily accepts `0` and negative values, but neither
  /// identifies a record: sending one to a metadata provider yields a 404
  /// (AniList) or default junk details (Shikimori) instead of a clean miss.
  /// Empty and non-numeric ids fail the parse. Every place that turns a cached or
  /// proposed native id into a provider call or a stored row goes through here.
  static int? _usableNativeId(String? nativeId) {
    final int? parsed = nativeId == null ? null : int.tryParse(nativeId);
    return parsed != null && parsed > 0 ? parsed : null;
  }
}

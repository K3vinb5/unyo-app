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

/// AniZip `/mappings` leg of the chain.
abstract class AniZipIdLookup {
  /// The MAL id AniZip lists for [anilistId], or null when it has no entry.
  Future<int?> malIdForAnilistId(int anilistId);
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
/// 2. AniZip — authoritative, auto-applied;
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
    final Service provenance = serviceOfAnime(anime);
    if (provenance == metadataService) return MediaDetailsSource(anime: anime, service: provenance);

    final _LinkResolution resolution = await _resolveTarget(
      source: provenance,
      nativeId: '${anime.id}',
      target: metadataService,
      title: animeSearchTitle(anime),
      knownMalId: anime.idMal,
    );
    final IdMapping? mapping = resolution.mapping;
    if (mapping != null && mapping.isResolved && mapping.service == metadataService) {
      return MediaDetailsSource(
        anime: withAnimeNativeId(anime, int.tryParse(mapping.nativeId) ?? anime.id),
        service: metadataService,
      );
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
    final Service provenance = serviceOfAnime(anime);
    if (provenance == userService) return anime.id;

    final _LinkResolution resolution = await _resolveTarget(
      source: provenance,
      nativeId: '${anime.id}',
      target: userService,
      title: animeSearchTitle(anime),
      knownMalId: anime.idMal,
    );
    final IdMapping? mapping = resolution.mapping;
    if (mapping == null || !mapping.isResolved || mapping.service != userService) {
      _logger.w("Cannot resolve ${provenance.name}:${anime.id} to ${userService.name}");
      return null;
    }
    _logger.i("Resolved ${provenance.name}:${anime.id} to ${userService.name}:${mapping.nativeId}");
    return int.tryParse(mapping.nativeId);
  }

  /// Caches the link the user confirmed in the dialog.
  Future<void> confirmLink({
    required Service source,
    required String nativeId,
    required MediaLinkCandidate candidate,
  }) async {
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
    _promptedLinks.remove(mediaLinkEntryKey(source: source, nativeId: nativeId, target: target));
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
      final MediaLinkCandidate? probed = await _mappingLookup?.lookupByMalId(target, pivot);
      if (probed == null) {
        _logger.w("No verified ${target.name} entry for MAL $pivot");
        return null;
      }
      targetMapping = IdMapping(
        service: target,
        nativeId: probed.nativeId,
        malId: pivot,
        state: IdMappingState.authoritative,
        source: IdMappingSource.providerField,
      );
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

  Future<List<MediaLinkCandidate>> _titleSearch(Service target, String title) async {
    final MediaMappingLookup? lookup = _mappingLookup;
    if (lookup == null) return const <MediaLinkCandidate>[];
    final List<MediaLinkCandidate> candidates = await lookup.searchCandidates(target, title);
    return candidates.take(maxTitleSearchCandidates).toList(growable: false);
  }

  Future<int?> _pivotFromAniZip(Service service, String nativeId) async {
    switch (service) {
      case Service.anilist:
        final int? anilistId = int.tryParse(nativeId);
        if (anilistId == null) return null;
        return _aniZipLookup?.malIdForAnilistId(anilistId);
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

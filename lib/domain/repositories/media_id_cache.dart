import 'package:unyo/core/enums/service.dart';

/// How trustworthy the cached mapping between a provider record and a MAL id is.
enum IdMappingState {
  /// Derived from data the provider itself publishes (its `malId` field) or
  /// from AniZip. Applied without asking the user.
  authoritative,

  /// Proposed by a heuristic title search and accepted by the user once.
  confirmed,

  /// No pivot could be established. Remembered for the current session so the
  /// app does not keep asking, purged at the next session so it is retried.
  unresolved,
}

/// Which step of the resolution chain produced a mapping.
enum IdMappingSource {
  /// Source and target provider are the same: the native id is used as-is.
  identity,

  /// The provider's own `malId`/`idMal` field (or a probe that verified it).
  providerField,

  /// AniZip's `/mappings` payload.
  aniZip,

  /// A target-provider title search, user-confirmed before caching.
  titleSearch,
}

/// One row of the MAL-pivot cache.
///
/// Keyed by `(service, nativeId)` — never by `malId` alone, so records whose
/// provider publishes no MAL id (`idMal == 0`) stay addressable.
class IdMapping {
  final Service service;
  final String nativeId;

  /// The MAL id pivot. Null/0 when the provider does not publish one.
  final int? malId;

  final IdMappingState state;
  final IdMappingSource source;

  /// Set on a user-confirmed row so a later translation for the same target
  /// provider does not need another (already paid for) title search.
  final Service? linkedService;
  final String? linkedNativeId;

  const IdMapping({
    required this.service,
    required this.nativeId,
    required this.state,
    required this.source,
    this.malId,
    this.linkedService,
    this.linkedNativeId,
  });

  bool get hasPivot => malId != null && malId! > 0;

  /// Authoritative and confirmed mappings can be used to translate; unresolved
  /// ones mean "fall back to the user provider".
  bool get isResolved => state != IdMappingState.unresolved;

  IdMapping copyWith({
    int? malId,
    IdMappingState? state,
    IdMappingSource? source,
    Service? linkedService,
    String? linkedNativeId,
  }) {
    return IdMapping(
      service: service,
      nativeId: nativeId,
      malId: malId ?? this.malId,
      state: state ?? this.state,
      source: source ?? this.source,
      linkedService: linkedService ?? this.linkedService,
      linkedNativeId: linkedNativeId ?? this.linkedNativeId,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'service': service.name,
        'nativeId': nativeId,
        'malId': malId,
        'state': state.name,
        'source': source.name,
        'linkedService': linkedService?.name,
        'linkedNativeId': linkedNativeId,
      };

  static IdMapping fromMap(Map<dynamic, dynamic> map) {
    return IdMapping(
      service: Service.values.firstWhere(
        (service) => service.name == map['service'],
        orElse: () => Service.anilist,
      ),
      nativeId: '${map['nativeId']}',
      malId: map['malId'] is int ? map['malId'] as int : int.tryParse('${map['malId']}'),
      state: IdMappingState.values.firstWhere(
        (state) => state.name == map['state'],
        orElse: () => IdMappingState.unresolved,
      ),
      source: IdMappingSource.values.firstWhere(
        (source) => source.name == map['source'],
        orElse: () => IdMappingSource.titleSearch,
      ),
      linkedService: map['linkedService'] == null
          ? null
          : Service.values.firstWhere(
              (service) => service.name == map['linkedService'],
              orElse: () => Service.anilist,
            ),
      linkedNativeId: map['linkedNativeId']?.toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is IdMapping &&
      other.service == service &&
      other.nativeId == nativeId &&
      other.malId == malId &&
      other.state == state &&
      other.source == source &&
      other.linkedService == linkedService &&
      other.linkedNativeId == linkedNativeId;

  @override
  int get hashCode =>
      Object.hash(service, nativeId, malId, state, source, linkedService, linkedNativeId);

  @override
  String toString() =>
      'IdMapping(${service.name}:$nativeId -> mal:$malId, ${state.name}/${source.name})';
}

/// Persistence port for [IdMapping] rows.
///
/// Two indexes over the same rows: `(service, nativeId)` (primary, always
/// present) and `(service, malId)` (secondary, only when a pivot exists).
abstract class MediaIdCache {
  /// Primary cache key: the provider-native identity of a record.
  static String nativeKey(Service service, String nativeId) => '${service.name}:$nativeId';

  /// Secondary cache key: the MAL pivot, always scoped to one provider.
  static String pivotKey(Service service, int malId) => '${service.name}#mal:$malId';

  Future<IdMapping?> getByNativeId(Service service, String nativeId);

  Future<IdMapping?> getByMalId(Service service, int malId);

  Future<void> put(IdMapping mapping);

  /// Drops every `unresolved` row so the next session retries them.
  Future<void> purgeUnresolved();

  /// Forgets one record so the chain runs again (manual "link this entry").
  Future<void> remove(Service service, String nativeId);
}

/// Test/double implementation of [MediaIdCache]. Cheap, synchronous behind the
/// async port.
class InMemoryMediaIdCache implements MediaIdCache {
  final Map<String, IdMapping> _entries = <String, IdMapping>{};

  @override
  Future<IdMapping?> getByNativeId(Service service, String nativeId) async =>
      _entries[MediaIdCache.nativeKey(service, nativeId)];

  @override
  Future<IdMapping?> getByMalId(Service service, int malId) async =>
      _entries[MediaIdCache.pivotKey(service, malId)];

  @override
  Future<void> put(IdMapping mapping) async {
    final String nativeKey = MediaIdCache.nativeKey(mapping.service, mapping.nativeId);
    final IdMapping? previous = _entries[nativeKey];
    if (previous != null && previous.hasPivot) {
      _entries.remove(MediaIdCache.pivotKey(previous.service, previous.malId!));
    }
    _entries[nativeKey] = mapping;
    if (mapping.hasPivot) {
      _entries[MediaIdCache.pivotKey(mapping.service, mapping.malId!)] = mapping;
    }
  }

  @override
  Future<void> purgeUnresolved() async {
    final List<IdMapping> unresolved =
        _entries.values.where((mapping) => !mapping.isResolved).toList();
    for (final IdMapping mapping in unresolved) {
      _entries.remove(MediaIdCache.nativeKey(mapping.service, mapping.nativeId));
    }
  }

  @override
  Future<void> remove(Service service, String nativeId) async {
    final IdMapping? previous = _entries.remove(MediaIdCache.nativeKey(service, nativeId));
    if (previous != null && previous.hasPivot) {
      _entries.remove(MediaIdCache.pivotKey(previous.service, previous.malId!));
    }
  }

  /// Snapshot for assertions in tests.
  List<IdMapping> get entries => _entries.values.toSet().toList();
}

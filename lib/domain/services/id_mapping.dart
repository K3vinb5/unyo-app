import 'package:unyo/core/enums/service.dart';

/// How trustworthy the cached mapping between a provider record and a MAL id is.
enum IdMappingState {
  /// Derived from data the provider itself publishes (its `malId` field) or
  /// from AniZip. Applied without asking the user.
  authoritative,

  /// Proposed by a heuristic title search and accepted by the user once.
  confirmed,

  /// No pivot could be established. Remembered for the current session so the
  /// app does not keep asking, purged at the next startup so it is retried.
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

  /// Set on a user-confirmed row so a later `resolveTarget` for the same
  /// target provider does not need another (already paid for) title search.
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

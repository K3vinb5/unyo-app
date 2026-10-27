import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/services/id_mapping.dart';

/// Primary cache key: the provider-native identity of a record.
String mediaIdNativeKey(Service service, String nativeId) => '${service.name}:$nativeId';

/// Secondary cache key: the MAL pivot, always scoped to one provider.
String mediaIdPivotKey(Service service, int malId) => '${service.name}#mal:$malId';

/// Persistence port for [IdMapping] rows.
///
/// Two indexes over the same rows: `(service, nativeId)` (primary, always
/// present) and `(service, malId)` (secondary, only when a pivot exists).
abstract class MediaIdCache {
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
      _entries[mediaIdNativeKey(service, nativeId)];

  @override
  Future<IdMapping?> getByMalId(Service service, int malId) async =>
      _entries[mediaIdPivotKey(service, malId)];

  @override
  Future<void> put(IdMapping mapping) async {
    final String nativeKey = mediaIdNativeKey(mapping.service, mapping.nativeId);
    final IdMapping? previous = _entries[nativeKey];
    if (previous != null && previous.hasPivot) {
      _entries.remove(mediaIdPivotKey(previous.service, previous.malId!));
    }
    _entries[nativeKey] = mapping;
    if (mapping.hasPivot) {
      _entries[mediaIdPivotKey(mapping.service, mapping.malId!)] = mapping;
    }
  }

  @override
  Future<void> purgeUnresolved() async {
    final List<IdMapping> unresolved =
        _entries.values.where((mapping) => !mapping.isResolved).toList();
    for (final IdMapping mapping in unresolved) {
      _entries.remove(mediaIdNativeKey(mapping.service, mapping.nativeId));
    }
  }

  @override
  Future<void> remove(Service service, String nativeId) async {
    final IdMapping? previous = _entries.remove(mediaIdNativeKey(service, nativeId));
    if (previous != null && previous.hasPivot) {
      _entries.remove(mediaIdPivotKey(previous.service, previous.malId!));
    }
  }

  /// Snapshot for assertions in tests.
  List<IdMapping> get entries => _entries.values.toSet().toList();
}

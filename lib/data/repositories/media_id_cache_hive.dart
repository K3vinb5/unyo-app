// External dependencies
import 'package:hive_ce/hive.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/services/id_mapping.dart';
import 'package:unyo/domain/services/media_id_cache.dart';

/// Hive-backed [MediaIdCache]. Own box, opened on first use (the box is not
/// registered as an adapter-backed type — rows are plain maps so the cache can
/// be purged/rewritten freely).
class HiveMediaIdCache implements MediaIdCache {
  static const String boxName = 'mediaIdMappings';

  Box<dynamic>? _box;

  Future<Box<dynamic>> _openBox() async {
    final Box<dynamic>? existing = _box;
    if (existing != null && existing.isOpen) return existing;
    final Box<dynamic> opened = Hive.isBoxOpen(boxName)
        ? Hive.box<dynamic>(boxName)
        : await Hive.openBox<dynamic>(boxName);
    _box = opened;
    return opened;
  }

  @override
  Future<IdMapping?> getByNativeId(Service service, String nativeId) async {
    final Object? raw = (await _openBox()).get(mediaIdNativeKey(service, nativeId));
    return raw is Map ? IdMapping.fromMap(raw) : null;
  }

  @override
  Future<IdMapping?> getByMalId(Service service, int malId) async {
    final Object? raw = (await _openBox()).get(mediaIdPivotKey(service, malId));
    return raw is Map ? IdMapping.fromMap(raw) : null;
  }

  @override
  Future<void> put(IdMapping mapping) async {
    final Box<dynamic> box = await _openBox();
    final String nativeKey = mediaIdNativeKey(mapping.service, mapping.nativeId);
    final Object? rawPrevious = box.get(nativeKey);
    if (rawPrevious is Map) {
      final IdMapping previous = IdMapping.fromMap(rawPrevious);
      if (previous.hasPivot) {
        await box.delete(mediaIdPivotKey(previous.service, previous.malId!));
      }
    }
    await box.put(nativeKey, mapping.toMap());
    if (mapping.hasPivot) {
      await box.put(mediaIdPivotKey(mapping.service, mapping.malId!), mapping.toMap());
    }
  }

  @override
  Future<void> purgeUnresolved() async {
    final Box<dynamic> box = await _openBox();
    final List<dynamic> staleKeys = box
        .toMap()
        .entries
        .where((entry) => entry.value is Map && !IdMapping.fromMap(entry.value as Map).isResolved)
        .map((entry) => entry.key)
        .toList();
    if (staleKeys.isNotEmpty) await box.deleteAll(staleKeys);
  }
}

import 'dart:io';

// External dependencies
import 'package:hive_ce/hive.dart';
import 'package:logger/logger.dart';

/// Prunes frames left behind by another persisted-schema generation before any
/// typed read touches the user boxes (WP #122).
///
/// Hive deserialises **every** frame in a box file when it opens it, including
/// frames that a later write superseded. A superseded frame was written by
/// whatever build saved that value, so a user box that has seen two schema
/// generations — a dev and a stable build sharing one app-support directory, or
/// a rollback — can no longer be opened at all: an `unknown typeId` aborts the
/// whole user list instead of one value.
///
/// Opening the box lazily reads frame boundaries only, and `compact()` copies
/// the newest frame of each key verbatim, so the rebuild drops those stale
/// frames without deserialising anything. The newest frame of every key is kept
/// and must still be readable by the running build; if it is not, the box keeps
/// throwing rather than silently losing the account.
///
/// Why a typeId from a newer build reads as a different number: hive_ce 2.22.0
/// writes `resolved.typeId` in `RawObjectWriter`, and `TypeRegistryImpl`
/// resolves an external adapter's id through `calculateTypeId(adapter.typeId)`,
/// which is `typeId + reservedTypeIds` (32). A future adapter with typeId 12
/// therefore appears in the stream as 44, and a registry that does not know it
/// fails the whole open. That is the empirical 2026-10-31 `unknown typeId: 43`
/// (= 11 + 32) failure this migration exists to clear.
///
/// Pruning runs on every launch with no bookkeeping: the user boxes are a few
/// KB, so an unconditional `compact()` is negligible, and it keeps self-healing
/// across any number of schema skews, including the same box crossing the same
/// boundary twice. A marker that recorded "already pruned" would have to know
/// when the schema changed again — it cannot.
class UserBoxSchemaMigration {
  UserBoxSchemaMigration(this._logger);

  /// The user boxes read at login; a stale frame in any of them blocks them all.
  static const List<String> userBoxNames = ['anilistUsers', 'shikimoriUsers'];

  final Logger _logger;

  /// Compacts every user box. A box that cannot be opened or compacted throws,
  /// so callers on the startup path use [runOrReport] instead.
  Future<void> run() async {
    for (final String boxName in userBoxNames) {
      final LazyBox<dynamic> box = await Hive.openLazyBox<dynamic>(boxName);
      final int? sizeBefore = _fileLength(box.path);
      await box.compact();
      await box.close();
      final int? sizeAfter = _fileLength(box.path);
      // Only a file that actually shrank held superseded frames; a launch on a
      // clean box is silent instead of pretending it pruned something.
      if (sizeBefore != null && sizeAfter != null && sizeAfter < sizeBefore) {
        _logger.i('Pruned stale schema frames from $boxName');
      }
    }
  }

  /// Byte length of a box file, or null for an in-memory box or a box file that
  /// does not exist yet (a fresh install has nothing to prune).
  static int? _fileLength(String? path) {
    if (path == null) return null;
    final File file = File(path);
    return file.existsSync() ? file.lengthSync() : null;
  }

  /// Startup-safe wrapper: a migration failure must never keep the app from
  /// opening a window. A box that still throws here only breaks the user list
  /// it belongs to, which is the pre-#122 failure mode — a visible login error
  /// is better than no app at all.
  Future<void> runOrReport() async {
    try {
      await run();
    } catch (error, stackTrace) {
      _logger.e('User box schema migration failed', error: error, stackTrace: stackTrace);
    }
  }
}

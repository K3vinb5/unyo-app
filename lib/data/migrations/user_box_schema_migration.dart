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
/// One pass per schema generation: the marker box records the generation that
/// already pruned each user box, so repeated launches are no-ops.
class UserBoxSchemaMigration {
  UserBoxSchemaMigration(this._logger);

  /// Every user box is pruned once per generation, then skipped.
  static const int schemaGeneration = 1;

  static const String markerBoxName = 'schemaMigrations';

  /// The user boxes read at login; a stale frame in any of them blocks them all.
  static const List<String> userBoxNames = ['anilistUsers', 'shikimoriUsers'];

  final Logger _logger;

  Future<void> run() async {
    final Box<int> markers = await Hive.openBox<int>(markerBoxName);
    for (final String boxName in userBoxNames) {
      if (markers.get(boxName) == schemaGeneration) continue;
      final LazyBox<dynamic> box = await Hive.openLazyBox<dynamic>(boxName);
      await box.compact();
      await box.close();
      await markers.put(boxName, schemaGeneration);
      _logger.i("Pruned stale schema frames from $boxName (generation $schemaGeneration)");
    }
    await markers.close();
  }
}

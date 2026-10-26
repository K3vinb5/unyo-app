// External dependencies
import 'dart:io';

/// Environment variable that overrides the directory holding the app's data
/// (Hive boxes, logs, torrent downloads).
const String unyoDataDirEnvVar = 'UNYO_DATA_DIR';

/// Resolves the directory the app uses for its data.
///
/// When [unyoDataDirEnvVar] is set to a non-empty value, that directory is used
/// (and created if missing) instead of the platform default, so several
/// instances can run side by side from separate worktrees without fighting over
/// the single global Hive directory. Otherwise [fallback] wins.
Future<Directory> resolveAppSupportDir({
  required Map<String, String> environment,
  required Future<Directory> Function() fallback,
}) async {
  final String? override = environment[unyoDataDirEnvVar];
  if (override == null || override.isEmpty) {
    return fallback();
  }
  final Directory directory = Directory(override);
  directory.createSync(recursive: true);
  return directory;
}

import 'package:unyo/core/services/api/dto/github/github_release_entity.dart';

/// Outcome of a single in-app update check.
///
/// Every failure path (offline, non-200, 404 when there are no releases yet,
/// malformed JSON, timeout) collapses into [UpdateCheckFailed] so callers never
/// have to catch: the startup kick-off must never throw.
sealed class UpdateCheckResult {
  const UpdateCheckResult();
}

/// The running build is the newest published release.
class UpToDate extends UpdateCheckResult {
  const UpToDate();
}

/// A newer release exists. [releaseUrl] is the GitHub release page (or the
/// generic `/releases/latest` page when the payload has no usable `html_url`).
class UpdateAvailable extends UpdateCheckResult {
  final String latestVersion;
  final String releaseUrl;

  /// The release `body` markdown, as published on GitHub. Empty when the
  /// maintainer shipped a release without notes.
  final String releaseNotes;

  /// The release's published assets, used to offer the installer for the
  /// running platform. Empty when the payload carried none.
  final List<GithubReleaseAssets> assets;

  const UpdateAvailable({
    required this.latestVersion,
    required this.releaseUrl,
    this.releaseNotes = '',
    this.assets = const [],
  });
}

/// The check could not produce a verdict. Silent by design: it is only logged.
class UpdateCheckFailed extends UpdateCheckResult {
  final String reason;

  const UpdateCheckFailed(this.reason);
}

import 'package:unyo/core/services/api/dto/github/github_release_entity.dart';

/// Outcome of a single in-app update check.
///
/// Not a DTO: `api/dto/**` mirrors remote JSON, while these verdict states
/// ([UpToDate], [UpdateCheckFailed]) exist only on our side.
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

/// A newer release exists.
///
/// Carries the release payload the verdict was drawn from, so the dialog and the
/// Settings -> About rows read the published fields (`body`, `assets`,
/// `html_url`) straight off the bean. Nothing is copied field by field, so the
/// two can never drift; the only derived value kept here is [latestVersion],
/// the compared tag with its leading `v` stripped.
class UpdateAvailable extends UpdateCheckResult {
  final GithubReleaseEntity release;

  /// The release tag without its leading `v`, i.e. the version string that was
  /// compared against the running build.
  final String latestVersion;

  const UpdateAvailable({required this.release, required this.latestVersion});
}

/// The check could not produce a verdict. Silent by design: it is only logged.
class UpdateCheckFailed extends UpdateCheckResult {
  final String reason;

  const UpdateCheckFailed(this.reason);
}

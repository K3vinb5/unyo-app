// External dependencies
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/dto/github/github_release_entity.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/update/update_check_result.dart';
import 'package:unyo/core/services/update/version_comparator.dart';

/// Asks the GitHub Releases API for the latest published release and compares
/// it with the running build.
///
/// No self-install, no appcast: the verdict only feeds the release-notes dialog
/// and the Settings -> About rows (via [lastResult]). The check runs once per
/// process launch from the tabs shell cubit and never throws — every problem is
/// reported as [UpdateCheckFailed] and logged.
class UpdateCheckerService {
  static const String userAgent =
      'Unyo-Desktop-UpdateCheck/1.0 (+https://github.com/K3vinb5/Unyo)';

  static const Map<String, String> _headers = {
    'Accept': 'application/vnd.github+json',
    'User-Agent': userAgent,
  };

  final HttpService _httpService;
  final String endpoint;
  final Logger _logger;

  UpdateCheckResult? _lastResult;
  String? _lastCheckedVersion;

  /// Verdict of the last completed check, kept for the Settings -> About rows.
  UpdateCheckResult? get lastResult => _lastResult;

  /// The running version the last check compared against, or null when the
  /// build could not report one.
  String? get lastCheckedVersion => _lastCheckedVersion;

  UpdateCheckerService({
    required HttpService httpService,
    String? endpoint,
    Logger? logger,
  }) : _httpService = httpService,
       endpoint = endpoint ?? config.unyoReleasesEndpoint,
       _logger = logger ?? sl<Logger>();

  Future<UpdateCheckResult> checkForUpdate(String currentVersion) async {
    _logger.d(
      "Checking for updates at $endpoint (current version $currentVersion)",
    );
    _lastCheckedVersion = currentVersion;
    final UpdateCheckResult result = await _requestLatestRelease(currentVersion);
    _lastResult = result;
    return result;
  }

  Future<UpdateCheckResult> _requestLatestRelease(String currentVersion) async {
    try {
      final ApiResponse<GithubReleaseEntity> response = await _httpService.get<GithubReleaseEntity>(
        endpoint,
        headers: _headers,
        ignoreCache: true,
        fromJson: GithubReleaseEntity.fromJson,
      );
      return _evaluate(response.data, currentVersion);
    } on HttpServerException catch (e, stackTrace) {
      // 404 happens until the first release exists; 403 is rate limiting.
      _logger.e(
        "Update check received status ${e.statusCode} from $endpoint",
        stackTrace: stackTrace,
      );
      return UpdateCheckFailed('GitHub responded with status ${e.statusCode}');
    } on TimeoutException catch (e, stackTrace) {
      _logger.e("Update check timed out", stackTrace: stackTrace);
      return const UpdateCheckFailed('Timed out');
    } on SocketException catch (e, stackTrace) {
      _logger.e(
        "Update check failed to reach $endpoint: ${e.message}",
        stackTrace: stackTrace,
      );
      return const UpdateCheckFailed('Network unavailable');
    } on http.ClientException catch (e, stackTrace) {
      _logger.e(
        "Update check HTTP client error: ${e.message}",
        stackTrace: stackTrace,
      );
      return const UpdateCheckFailed('Network request failed');
    } on FormatException catch (e, stackTrace) {
      _logger.e(
        "Update check received malformed JSON: ${e.message}",
        stackTrace: stackTrace,
      );
      return const UpdateCheckFailed('Malformed releases payload');
    } catch (e, stackTrace) {
      // Also the shapes the generated bean rejects: a required field the payload
      // does not carry surfaces as a LateInitializationError here.
      _logger.e("Update check failed unexpectedly: $e", stackTrace: stackTrace);
      return const UpdateCheckFailed('Unexpected update check failure');
    }
  }

  UpdateCheckResult _evaluate(
    GithubReleaseEntity release,
    String currentVersion,
  ) {
    final String tagName = release.tagName.trim();
    if (tagName.isEmpty) {
      _logger.w("Update check payload has no tag_name");
      return const UpdateCheckFailed("Release payload has no tag_name");
    }
    final String latestVersion = _stripVersionPrefix(tagName);
    if (!VersionComparator.isNewer(latestVersion, currentVersion)) {
      _logger.d(
        "App is up to date (running $currentVersion, latest $latestVersion)",
      );
      return const UpToDate();
    }
    _logger.i(
      "Update available: running $currentVersion, latest $latestVersion",
    );
    // The verdict carries the whole bean: the dialog and the About rows read
    // the published fields from it, so there is nothing to map or copy here.
    return UpdateAvailable(release: release, latestVersion: latestVersion);
  }

  String _stripVersionPrefix(String tagName) =>
      tagName.startsWith('v') || tagName.startsWith('V')
      ? tagName.substring(1)
      : tagName;
}

// External dependencies
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/update/update_check_result.dart';
import 'package:unyo/core/services/update/version_comparator.dart';

/// Asks the GitHub Releases API for the latest published release and compares
/// it with the running build.
///
/// No self-install, no appcast: the only consumer is a notification. The check
/// is meant to run once per process launch and never throws — every problem is
/// reported as [UpdateCheckFailed] and logged.
class UpdateCheckerService {
  static const String userAgent =
      'Unyo-Desktop-UpdateCheck/1.0 (+https://github.com/K3vinb5/Unyo)';

  final http.Client? _client;
  final String endpoint;
  final Duration timeout;
  final Logger _logger;

  UpdateCheckerService({
    http.Client? client,
    String? endpoint,
    this.timeout = const Duration(seconds: 10),
    Logger? logger,
  }) : _client = client,
       endpoint = endpoint ?? config.unyoReleasesEndpoint,
       _logger = logger ?? sl<Logger>();

  Future<UpdateCheckResult> checkForUpdate(String currentVersion) async {
    final client = _client ?? http.Client();
    try {
      _logger.d("Checking for updates at $endpoint (current version $currentVersion)");
      final response = await client
          .get(
            Uri.parse(endpoint),
            headers: const {
              'Accept': 'application/vnd.github+json',
              'User-Agent': userAgent,
            },
          )
          .timeout(timeout);
      if (response.statusCode != 200) {
        // 404 happens until the first release exists; 403 is rate limiting.
        _logger.w("Update check received status ${response.statusCode} from $endpoint");
        return UpdateCheckFailed('GitHub responded with status ${response.statusCode}');
      }
      return _parseResponse(response.body, currentVersion);
    } on TimeoutException catch (e, stackTrace) {
      _logger.e("Update check timed out after ${timeout.inSeconds}s", stackTrace: stackTrace);
      return UpdateCheckFailed("Timed out after ${timeout.inSeconds}s");
    } on FormatException catch (e, stackTrace) {
      _logger.e("Update check received malformed JSON: ${e.message}", stackTrace: stackTrace);
      return const UpdateCheckFailed('Malformed releases payload');
    } on SocketException catch (e, stackTrace) {
      _logger.e("Update check failed to reach $endpoint: ${e.message}", stackTrace: stackTrace);
      return const UpdateCheckFailed('Network unavailable');
    } on http.ClientException catch (e, stackTrace) {
      _logger.e("Update check HTTP client error: ${e.message}", stackTrace: stackTrace);
      return const UpdateCheckFailed('Network request failed');
    } catch (e, stackTrace) {
      _logger.e("Update check failed unexpectedly: $e", stackTrace: stackTrace);
      return const UpdateCheckFailed('Unexpected update check failure');
    } finally {
      // Only close the client we created ourselves; injected clients belong to
      // the caller (and to tests).
      if (_client == null) client.close();
    }
  }

  UpdateCheckResult _parseResponse(String body, String currentVersion) {
    final decoded = json.decode(body);
    if (decoded is! Map<String, dynamic>) {
      _logger.w("Update check expected a release object but got ${decoded.runtimeType}");
      return const UpdateCheckFailed('Unexpected releases payload');
    }
    final tagName = decoded['tag_name'];
    if (tagName is! String || tagName.trim().isEmpty) {
      _logger.w("Update check payload has no tag_name");
      return const UpdateCheckFailed("Release payload has no tag_name");
    }
    final latestVersion = _stripVersionPrefix(tagName.trim());
    final releaseUrl = _releaseUrl(decoded['html_url']);
    if (!isVersionNewer(latestVersion, currentVersion)) {
      _logger.d("App is up to date (running $currentVersion, latest $latestVersion)");
      return const UpToDate();
    }
    _logger.i("Update available: running $currentVersion, latest $latestVersion");
    return UpdateAvailable(latestVersion: latestVersion, releaseUrl: releaseUrl);
  }

  String _stripVersionPrefix(String tagName) =>
      tagName.startsWith('v') || tagName.startsWith('V') ? tagName.substring(1) : tagName;

  String _releaseUrl(Object? htmlUrl) {
    if (htmlUrl is String && Uri.tryParse(htmlUrl)?.hasScheme == true) {
      return htmlUrl;
    }
    return config.unyoReleasesFallbackUrl;
  }
}

// External dependencies
import 'package:url_launcher/url_launcher.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;

/// Resolves the page to open for the "update available" call to action,
/// falling back to the generic releases page when the API payload has no
/// usable URL.
Uri releasePageUri(String? releaseUrl) {
  final candidate = releaseUrl?.trim();
  if (candidate != null && candidate.isNotEmpty) {
    final parsed = Uri.tryParse(candidate);
    if (parsed != null && parsed.hasScheme) return parsed;
  }
  return Uri.parse(config.unyoReleasesFallbackUrl);
}

/// Opens [releaseUrl] in the system browser. Never throws: the update notice is
/// not allowed to break the app if no browser is available.
Future<bool> openReleasePage(String? releaseUrl) async {
  try {
    return await launchUrl(releasePageUri(releaseUrl), mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

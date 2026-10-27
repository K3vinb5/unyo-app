// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/services/update/release_page_launcher.dart';
import 'package:unyo/core/services/update/update_check_result.dart';
import 'package:unyo/core/services/update/update_checker_service.dart';

/// Canned `GET /repos/K3vinb5/Unyo/releases/latest` payload.
const String releasesLatestFixture = '''
{
  "tag_name": "v1.2.3",
  "name": "1.2.3",
  "html_url": "https://github.com/K3vinb5/Unyo/releases/tag/v1.2.3",
  "draft": false,
  "prerelease": false
}
''';

void main() {
  UpdateCheckerService serviceFor(MockClient client, {Duration? timeout}) {
    return UpdateCheckerService(
      client: client,
      endpoint: 'https://stub.local/releases/latest',
      timeout: timeout ?? const Duration(seconds: 5),
      logger: Logger(level: Level.off),
    );
  }

  group('UpdateCheckerService.checkForUpdate', () {
    test('returns updateAvailable for a newer tag', () async {
      final service = serviceFor(MockClient((_) async => http.Response(releasesLatestFixture, 200)));

      final result = await service.checkForUpdate('1.0.0');

      expect(result, isA<UpdateAvailable>());
      final available = result as UpdateAvailable;
      expect(available.latestVersion, '1.2.3');
      expect(available.releaseUrl, 'https://github.com/K3vinb5/Unyo/releases/tag/v1.2.3');
    });

    test('strips the leading v from the tag before comparing', () async {
      final service = serviceFor(MockClient((_) async => http.Response(releasesLatestFixture, 200)));

      final result = await service.checkForUpdate('1.2.3');

      expect(result, isA<UpToDate>());
    });

    test('returns upToDate for an older published release', () async {
      final service = serviceFor(MockClient((_) async => http.Response(releasesLatestFixture, 200)));

      final result = await service.checkForUpdate('1.10.0');

      expect(result, isA<UpToDate>());
    });

    test('sends the GitHub API Accept header and a descriptive User-Agent', () async {
      late http.Request captured;
      final service = serviceFor(
        MockClient((request) async {
          captured = request;
          return http.Response(releasesLatestFixture, 200);
        }),
      );

      await service.checkForUpdate('1.0.0');

      expect(captured.headers['Accept'], 'application/vnd.github+json');
      expect(captured.headers['User-Agent'], contains('Unyo'));
    });

    test('falls back to the generic releases page when html_url is missing', () async {
      final service = serviceFor(
        MockClient((_) async => http.Response('{"tag_name": "v9.9.9"}', 200)),
      );

      final result = await service.checkForUpdate('1.0.0');

      expect(result, isA<UpdateAvailable>());
      expect((result as UpdateAvailable).releaseUrl, config.unyoReleasesFallbackUrl);
    });

    test('returns checkFailed for a 500 and does not throw', () async {
      final service = serviceFor(MockClient((_) async => http.Response('server error', 500)));

      final result = await service.checkForUpdate('1.0.0');

      expect(result, isA<UpdateCheckFailed>());
    });

    test('returns checkFailed for a 404 (no releases yet)', () async {
      final service = serviceFor(MockClient((_) async => http.Response('{"message":"Not Found"}', 404)));

      final result = await service.checkForUpdate('1.0.0');

      expect(result, isA<UpdateCheckFailed>());
    });

    test('returns checkFailed for malformed JSON and does not throw', () async {
      final service = serviceFor(MockClient((_) async => http.Response('<html>not json</html>', 200)));

      final result = await service.checkForUpdate('1.0.0');

      expect(result, isA<UpdateCheckFailed>());
    });

    test('returns checkFailed for a payload without tag_name', () async {
      final service = serviceFor(MockClient((_) async => http.Response('{"html_url": "https://x"}', 200)));

      final result = await service.checkForUpdate('1.0.0');

      expect(result, isA<UpdateCheckFailed>());
    });

    test('returns checkFailed on timeout and does not throw', () async {
      final service = serviceFor(
        MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return http.Response(releasesLatestFixture, 200);
        }),
        timeout: const Duration(milliseconds: 20),
      );

      final result = await service.checkForUpdate('1.0.0');

      expect(result, isA<UpdateCheckFailed>());
    });

    test('returns checkFailed when the network is unreachable', () async {
      final service = serviceFor(
        MockClient((_) async => throw http.ClientException('connection refused')),
      );

      final result = await service.checkForUpdate('1.0.0');

      expect(result, isA<UpdateCheckFailed>());
    });
  });

  group('releasePageUri', () {
    test('uses the API release url when it is a valid absolute uri', () {
      expect(
        releasePageUri('https://github.com/K3vinb5/Unyo/releases/tag/v1.2.3').toString(),
        'https://github.com/K3vinb5/Unyo/releases/tag/v1.2.3',
      );
    });

    test('falls back to the generic releases page for null, empty or relative values', () {
      expect(releasePageUri(null).toString(), config.unyoReleasesFallbackUrl);
      expect(releasePageUri('').toString(), config.unyoReleasesFallbackUrl);
      expect(releasePageUri('releases/tag/v1.2.3').toString(), config.unyoReleasesFallbackUrl);
    });
  });
}

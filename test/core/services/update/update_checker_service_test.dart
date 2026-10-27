// External dependencies
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/services/api/dto/github/github_release_entity.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/update/release_page_launcher.dart';
import 'package:unyo/core/services/update/update_check_result.dart';
import 'package:unyo/core/services/update/update_checker_service.dart';

class MockHttpService extends Mock implements HttpService {}

/// The payload the bean was generated from, committed next to it.
const String samplePayloadPath =
    'lib/core/services/api/dto/github/releases_latest_sample.json';

void main() {
  const endpoint = 'https://stub.local/releases/latest';

  late MockHttpService httpService;
  late Map<String, dynamic> samplePayload;

  UpdateCheckerService service() => UpdateCheckerService(
    httpService: httpService,
    endpoint: endpoint,
    logger: Logger(level: Level.off),
  );

  ApiResponse<GithubReleaseEntity> responseFor(GithubReleaseEntity release) =>
      ApiResponse(
        data: release,
        bodyBytes: Uint8List(0),
        statusCode: 200,
        headers: const {},
      );

  void stubRelease(GithubReleaseEntity release) {
    when(
      () => httpService.get<GithubReleaseEntity>(
        endpoint,
        headers: any(named: 'headers'),
        ignoreCache: true,
        fromJson: GithubReleaseEntity.fromJson,
      ),
    ).thenAnswer((_) async => responseFor(release));
  }

  void stubFailure(Object error) {
    when(
      () => httpService.get<GithubReleaseEntity>(
        endpoint,
        headers: any(named: 'headers'),
        ignoreCache: true,
        fromJson: GithubReleaseEntity.fromJson,
      ),
    ).thenAnswer((_) async => throw error);
  }

  setUpAll(() {
    samplePayload =
        jsonDecode(File(samplePayloadPath).readAsStringSync())
            as Map<String, dynamic>;
  });

  setUp(() {
    httpService = MockHttpService();
  });

  group('UpdateCheckerService.checkForUpdate', () {
    test(
      'returns updateAvailable with the release notes for a newer tag',
      () async {
        stubRelease(GithubReleaseEntity.fromJson(samplePayload));

        final result = await service().checkForUpdate('0.8.0');

        expect(result, isA<UpdateAvailable>());
        final available = result as UpdateAvailable;
        expect(available.latestVersion, '0.9.0');
        expect(
          available.releaseUrl,
          'https://github.com/K3vinb5/Unyo/releases/tag/v0.9.0',
        );
        expect(available.releaseNotes, startsWith("## What's changed"));
        expect(
          available.assets.map((a) => a.name),
          contains('Unyo-v0.9.0-linux.AppImage'),
        );
      },
    );

    test(
      'returns upToDate when the running build is the published release',
      () async {
        stubRelease(GithubReleaseEntity.fromJson(samplePayload));

        final result = await service().checkForUpdate('0.9.0');

        expect(result, isA<UpToDate>());
      },
    );

    test('returns upToDate for an older published release', () async {
      stubRelease(GithubReleaseEntity.fromJson(samplePayload));

      final result = await service().checkForUpdate('1.0.0');

      expect(result, isA<UpToDate>());
    });

    test(
      'asks the bundled HttpService with the GitHub API Accept header and a User-Agent',
      () async {
        stubRelease(GithubReleaseEntity.fromJson(samplePayload));

        await service().checkForUpdate('0.8.0');

        final headers =
            verify(
                  () => httpService.get<GithubReleaseEntity>(
                    endpoint,
                    headers: captureAny(named: 'headers'),
                    ignoreCache: true,
                    fromJson: GithubReleaseEntity.fromJson,
                  ),
                ).captured.single
                as Map<String, String>;
        expect(headers['Accept'], 'application/vnd.github+json');
        expect(headers['User-Agent'], contains('Unyo'));
      },
    );

    test(
      'falls back to the generic releases page when html_url is unusable',
      () async {
        stubRelease(
          GithubReleaseEntity.fromJson({
            ...samplePayload,
            'html_url': 'releases/tag/v0.9.0',
          }),
        );

        final result = await service().checkForUpdate('0.8.0');

        expect(result, isA<UpdateAvailable>());
        expect(
          (result as UpdateAvailable).releaseUrl,
          config.unyoReleasesFallbackUrl,
        );
      },
    );

    test(
      'keeps the verdict and the checked version for the About rows',
      () async {
        stubRelease(GithubReleaseEntity.fromJson(samplePayload));
        final updateCheckerService = service();

        expect(updateCheckerService.lastResult, isNull);
        expect(updateCheckerService.lastCheckedVersion, isNull);

        await updateCheckerService.checkForUpdate('0.8.0');

        expect(updateCheckerService.lastResult, isA<UpdateAvailable>());
        expect(updateCheckerService.lastCheckedVersion, '0.8.0');
      },
    );

    test('returns checkFailed for a 500 and does not throw', () async {
      stubFailure(HttpServerException(500, 'server error'));

      final result = await service().checkForUpdate('0.8.0');

      expect(result, isA<UpdateCheckFailed>());
    });

    test('returns checkFailed for a 404 (no releases yet)', () async {
      stubFailure(HttpServerException(404, 'Not Found'));

      final result = await service().checkForUpdate('0.8.0');

      expect(result, isA<UpdateCheckFailed>());
    });

    test('returns checkFailed for malformed JSON and does not throw', () async {
      stubFailure(const FormatException('<html>not json</html>'));

      final result = await service().checkForUpdate('0.8.0');

      expect(result, isA<UpdateCheckFailed>());
    });

    test('returns checkFailed for a payload without tag_name', () async {
      stubRelease(
        GithubReleaseEntity.fromJson({
          'html_url': 'https://github.com/K3vinb5/Unyo',
        }),
      );

      final result = await service().checkForUpdate('0.8.0');

      expect(result, isA<UpdateCheckFailed>());
    });

    test('returns checkFailed on timeout and does not throw', () async {
      stubFailure(TimeoutException('timed out'));

      final result = await service().checkForUpdate('0.8.0');

      expect(result, isA<UpdateCheckFailed>());
    });

    test('returns checkFailed when the network is unreachable', () async {
      stubFailure(const SocketException('connection refused'));

      final result = await service().checkForUpdate('0.8.0');

      expect(result, isA<UpdateCheckFailed>());
    });

    test('returns checkFailed when the HTTP client throws', () async {
      stubFailure(http.ClientException('connection closed'));

      final result = await service().checkForUpdate('0.8.0');

      expect(result, isA<UpdateCheckFailed>());
    });
  });

  group('releasePageUri', () {
    test('uses the API release url when it is a valid absolute uri', () {
      expect(
        releasePageUri(
          'https://github.com/K3vinb5/Unyo/releases/tag/v1.2.3',
        ).toString(),
        'https://github.com/K3vinb5/Unyo/releases/tag/v1.2.3',
      );
    });

    test(
      'falls back to the generic releases page for null, empty or relative values',
      () {
        expect(releasePageUri(null).toString(), config.unyoReleasesFallbackUrl);
        expect(releasePageUri('').toString(), config.unyoReleasesFallbackUrl);
        expect(
          releasePageUri('releases/tag/v1.2.3').toString(),
          config.unyoReleasesFallbackUrl,
        );
      },
    );
  });
}

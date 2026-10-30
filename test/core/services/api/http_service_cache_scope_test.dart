// External dependencies
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/api/http/response_cache_scope.dart';

void main() {
  late ResponseCacheScope cacheScope;

  const String endpoint = 'https://example.test/graphql';

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));
    cacheScope = ResponseCacheScope();
    sl.registerSingleton<ResponseCacheScope>(cacheScope);
  });

  int valueOf(Map<String, dynamic> json) => json['value'] as int;

  test('rows cached under the previous metadata provider are not served after a switch', () async {
    int requests = 0;
    final MockClient client = MockClient((http.Request request) async {
      requests++;
      return http.Response('{"value": $requests}', 200);
    });
    final HttpService httpService = HttpService(client: client);

    // The first provider populates the cache.
    final ApiResponse<int> first = await httpService.post<int>(
      endpoint,
      body: {'query': 'browse'},
      fromJson: valueOf,
    );
    final ApiResponse<int> cached = await httpService.post<int>(
      endpoint,
      body: {'query': 'browse'},
      fromJson: valueOf,
    );
    expect(first.data, 1);
    expect(cached.data, 1, reason: 'an unchanged provider serves its cached rows');
    expect(requests, 1);

    // Settings persisted the new metadata provider: the previously cached rows
    // belong to a provider that is no longer configured.
    cacheScope.invalidate();

    // A lazy tab created now asks with ignoreCache: false — its first load.
    final ApiResponse<int> afterSwitch = await httpService.post<int>(
      endpoint,
      body: {'query': 'browse'},
      fromJson: valueOf,
    );

    expect(afterSwitch.data, 2, reason: 'the previous provider\'s cached rows must never be served');
    expect(requests, 2);
  });

  test('a response that lands after two provider switches is not served under the newest scope', () async {
    final Completer<void> releaseStaleRequest = Completer<void>();
    int requests = 0;
    final MockClient client = MockClient((http.Request request) async {
      requests++;
      if (requests == 1) {
        await releaseStaleRequest.future;
      }
      return http.Response('{"value": $requests}', 200);
    });
    final HttpService httpService = HttpService(client: client);

    // AniList request is in flight (AniList → Shikimori → AniList happens while
    // it waits), so its key must be the one captured before the await.
    final Future<ApiResponse<int>> stale = httpService.post<int>(
      endpoint,
      body: {'query': 'browse'},
      fromJson: valueOf,
    );
    await Future<void>.delayed(Duration.zero);
    cacheScope.invalidate();
    cacheScope.invalidate();
    releaseStaleRequest.complete();

    expect((await stale).data, 1);

    // AniList is configured again; the response fetched for the earlier AniList
    // session was inserted before the switches and must not be reachable now.
    final ApiResponse<int> afterSwitch = await httpService.post<int>(
      endpoint,
      body: {'query': 'browse'},
      fromJson: valueOf,
    );

    expect(afterSwitch.data, 2, reason: 'a pre-switch response must not be inserted under the newest scope\'s key');
    expect(requests, 2);
  });
}

// External dependencies
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:shelf/shelf.dart' as shelf;

// Internal dependencies
import 'package:unyo/data/oauth/oauth_callback_handler.dart';
import 'package:unyo/data/oauth/oauth_callback_page.dart';

/// Keeps the logger quiet; the handler's log lines are not under test.
class _SilentLogger implements Logger {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

void main() {
  group('OAuthCallbackPage markup', () {
    test('success names the provider in the title and heading', () async {
      final shelf.Response response = OAuthCallbackPage.success(
        provider: OAuthCallbackPage.anilistProviderName,
      );
      final String body = await response.readAsString();

      expect(response.statusCode, 200);
      expect(body, contains('<title>Signed in · Unyo</title>'));
      expect(body, contains('<h1>Signed in to AniList</h1>'));
      expect(body, contains('You can close this tab and return to Unyo.'));
      expect(body, contains('lang="en"'));
      expect(body, startsWith('<!DOCTYPE html>'));
    });

    test('cancelled error has its own title and a non-technical reason', () async {
      final shelf.Response response = OAuthCallbackPage.error(
        provider: OAuthCallbackPage.shikimoriProviderName,
        failure: OAuthCallbackFailure.cancelled,
      );
      final String body = await response.readAsString();

      expect(response.statusCode, 500);
      expect(body, contains('<title>Sign-in cancelled · Unyo</title>'));
      expect(body, contains('<h1>Sign-in was cancelled</h1>'));
      expect(body, contains('Nothing changed'));
    });

    test('exchange-failure error names the provider', () async {
      final shelf.Response response = OAuthCallbackPage.error(
        provider: OAuthCallbackPage.anilistProviderName,
        failure: OAuthCallbackFailure.exchangeFailed,
      );
      final String body = await response.readAsString();

      expect(body, contains('<title>Sign-in failed · Unyo</title>'));
      expect(body, contains("<h1>Sign-in to AniList didn't finish</h1>"));
    });

    test('fallback says nothing happened without claiming a failure', () async {
      final shelf.Response response = OAuthCallbackPage.fallback(
        provider: OAuthCallbackPage.shikimoriProviderName,
      );
      final String body = await response.readAsString();

      expect(response.statusCode, 400);
      expect(body, contains('<title>Nothing to do here · Unyo</title>'));
      expect(body, contains("<h1>This page isn't a sign-in</h1>"));
      expect(body, contains('Shikimori'));
    });

    test('escapes a hostile provider name instead of executing it', () async {
      const String hostile = '"><script>alert(1)</script>';
      final String body = await OAuthCallbackPage.success(provider: hostile).readAsString();

      expect(body, contains('&quot;&gt;&lt;script&gt;alert(1)&lt;/script&gt;'));
      expect(body, isNot(contains('<script>')));
      expect(body, isNot(contains(hostile)));
    });

    test('sets exactly the HTML content type and no-store cache policy', () async {
      final shelf.Response response = OAuthCallbackPage.success(provider: 'AniList');

      expect(response.headers['content-type'], 'text/html; charset=utf-8');
      expect(response.headers['cache-control'], 'no-store');
      expect(
        response.headers.keys.toSet().difference(<String>{
          'content-type',
          'cache-control',
          'content-length',
        }),
        isEmpty,
        reason: 'shelf only adds content-length; nothing else may be attached',
      );
    });

    test('has no external asset or network reference', () async {
      final List<shelf.Response> responses = <shelf.Response>[
        OAuthCallbackPage.success(provider: 'AniList'),
        OAuthCallbackPage.error(provider: 'AniList', failure: OAuthCallbackFailure.exchangeFailed),
        OAuthCallbackPage.fallback(provider: 'AniList'),
      ];
      for (final shelf.Response response in responses) {
        final String body = await response.readAsString();
        for (final String forbidden in <String>[
          'http://',
          'https://',
          '<link',
          '<img',
          ' src=',
          '@import',
          'url(',
        ]) {
          expect(body, isNot(contains(forbidden)), reason: 'the page must render offline');
        }
      }
    });

    test('talks to prefers-color-scheme for light and dark surfaces', () async {
      final String body = await OAuthCallbackPage.success(provider: 'AniList').readAsString();

      expect(body, contains('prefers-color-scheme: dark'));
      expect(body, contains('color-scheme: light dark'));
      expect(body, contains('viewport'));
    });
  });

  group('OAuthCallbackHandler', () {
    late int finishedCalls;

    OAuthCallbackHandler handler({String provider = OAuthCallbackPage.anilistProviderName}) {
      finishedCalls = 0;
      return OAuthCallbackHandler(
        providerName: provider,
        logger: _SilentLogger(),
        onFinished: () {
          finishedCalls++;
        },
      );
    }

    shelf.Request request(String query) {
      return shelf.Request('GET', Uri.parse('http://localhost:9999/auth$query'));
    }

    test('a code exchange lands on the success page', () async {
      final OAuthCallbackHandler callback = handler();
      final List<String> exchangedCodes = <String>[];

      final shelf.Response response = await callback.handle(
        request('?code=fake-code'),
        (String code) async {
          exchangedCodes.add(code);
        },
      );

      expect(response.statusCode, 200);
      expect(await response.readAsString(), contains('<h1>Signed in to AniList</h1>'));
      expect(exchangedCodes, <String>['fake-code']);
      expect(finishedCalls, 1, reason: 'the callback server is closed once');
    });

    test('a provider error lands on the cancelled page without echoing it', () async {
      final OAuthCallbackHandler callback = handler(provider: OAuthCallbackPage.shikimoriProviderName);

      final shelf.Response response = await callback.handle(
        request('?error=access_denied&error_description=secret-detail'),
        (String code) async {
          fail('the exchange must not run without a code');
        },
      );
      final String body = await response.readAsString();

      expect(response.statusCode, 500);
      expect(body, contains('<h1>Sign-in was cancelled</h1>'));
      expect(body, isNot(contains('access_denied')));
      expect(body, isNot(contains('secret-detail')));
      expect(finishedCalls, 1);
    });

    test('a bare hit lands on the fallback page', () async {
      final OAuthCallbackHandler callback = handler();

      final shelf.Response response = await callback.handle(request(''), (String code) async {});

      expect(response.statusCode, 400);
      expect(await response.readAsString(), contains("<h1>This page isn't a sign-in</h1>"));
      expect(finishedCalls, 1);
    });

    test('a failed exchange lands on the error page, never on old plain text', () async {
      final OAuthCallbackHandler callback = handler();

      final shelf.Response response = await callback.handle(
        request('?code=fake-code'),
        (String code) async {
          throw StateError('AniList said no');
        },
      );
      final String body = await response.readAsString();

      expect(response.statusCode, 500);
      expect(body, contains('<h1>Sign-in to AniList didn\'t finish</h1>'));
      expect(body, isNot(contains('AniList said no')));
      expect(body, isNot(contains('Authorization successful')));
      expect(finishedCalls, 1);
    });

    test('never reflects the code, state, tokens or exception text', () async {
      const String accessToken = 'access-token-do-not-leak';
      const String refreshToken = 'refresh-token-do-not-leak';
      const String state = 'state-do-not-reflect';
      final OAuthCallbackHandler callback = handler();

      final shelf.Response response = await callback.handle(
        request('?code=code-do-not-reflect&state=$state'),
        (String code) async {
          throw StateError('exchange failed: $accessToken $refreshToken');
        },
      );
      final String body = await response.readAsString();

      for (final String secret in <String>[
        'code-do-not-reflect',
        state,
        accessToken,
        refreshToken,
        'exchange failed',
      ]) {
        expect(body, isNot(contains(secret)));
      }
    });
  });

  group('shared implementation', () {
    test('both repositories serve their callback through OAuthCallbackHandler', () {
      final List<String> sources = <String>[
        File('lib/data/repositories/user_repository_anilist.dart').readAsStringSync(),
        File('lib/data/repositories/user_repository_shikimori.dart').readAsStringSync(),
      ];

      for (final String source in sources) {
        expect(source, contains('OAuthCallbackHandler('));
        expect(source, isNot(contains('Authorization successful')));
        expect(source, isNot(contains('Something went wrong D:')));
        expect(source, isNot(contains('shelf.Response.ok(')));
      }
      expect(sources[0], contains('OAuthCallbackPage.anilistProviderName'));
      expect(sources[1], contains('OAuthCallbackPage.shikimoriProviderName'));
    });
  });
}

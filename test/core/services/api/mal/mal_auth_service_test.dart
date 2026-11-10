// External dependencies
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/services/api/dto/mal/mal_token_entity.dart';
import 'package:unyo/core/services/api/mal/mal_auth_service.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/domain/entities/user/settings.dart';

class MockLogger extends Mock implements Logger {}

/// MyAnimeList OAuth2: PKCE `plain` authorize URL, form-urlencoded public-client
/// token exchange (never a client_secret), refresh, and the expiry policy driven
/// by an injected clock. Mirrors the Shikimori auth suite (WP #64) plus the PKCE
/// surface MAL requires (WP #156).
void main() {
  final DateTime now = DateTime.utc(2026, 11, 8, 12);

  String tokenBody({
    String access = 'access-1',
    String refresh = 'refresh-1',
    String tokenType = 'Bearer',
    int expiresIn = 3600,
  }) {
    return jsonEncode(<String, dynamic>{
      'token_type': tokenType,
      'expires_in': expiresIn,
      'access_token': access,
      'refresh_token': refresh,
    });
  }

  MalUserModel userWith({String expiresAt = ''}) {
    return MalUserModel(
      id: '56789',
      name: 'tester',
      settings: SettingsModel.empty(),
      avatarImage: '',
      bannerImage: '',
      accessToken: 'stored-access',
      refreshToken: 'stored-refresh',
      accessTokenExpiresAt: expiresAt,
      profileUrl: '',
    );
  }

  // `sl.reset()` is asynchronous in get_it 9: awaiting it is what keeps it from
  // wiping the registration that follows.
  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(MockLogger());
  });

  group('authorization URL (PKCE plain)', () {
    test('the verifier honours the RFC 7636 43-128 range and unreserved charset', () {
      final MalAuthService auth = MalAuthService(clock: () => now, random: Random(7));

      final String verifier = auth.generateCodeVerifier();

      expect(verifier.length, greaterThanOrEqualTo(43));
      expect(verifier.length, lessThanOrEqualTo(128));
      expect(verifier.length, MalAuthService.codeVerifierLength);
      expect(
        RegExp(r'^[A-Za-z0-9\-._~]+$').hasMatch(verifier),
        isTrue,
        reason: 'PKCE verifiers are built from unreserved characters only',
      );
    });

    test('state is a non-empty random token', () {
      final MalAuthService auth = MalAuthService(clock: () => now, random: Random(7));

      final String state = auth.generateState();

      expect(state, isNotEmpty);
      expect(state.length, MalAuthService.stateLength);
      expect(RegExp(r'^[A-Za-z0-9\-._~]+$').hasMatch(state), isTrue);
    });

    test('the authorize URL is code+PKCE plain with challenge == verifier', () {
      final MalAuthService auth = MalAuthService(clock: () => now, random: Random(7));
      final String verifier = auth.generateCodeVerifier();

      final Uri url = auth.buildAuthorizationUrl(
        codeVerifier: verifier,
        state: 'the-state',
      );

      expect(url.toString(), startsWith(config.malAuthorizeEndpoint));
      expect(url.queryParameters['response_type'], 'code');
      expect(url.queryParameters['client_id'], config.malClientId);
      expect(url.queryParameters['redirect_uri'], config.malRedirectUri);
      expect(url.queryParameters['code_challenge'], verifier,
          reason: 'MAL only accepts PKCE plain: challenge IS the verifier');
      expect(url.queryParameters['code_challenge_method'], 'plain');
      expect(url.queryParameters['state'], 'the-state');
      expect(url.queryParameters['scope'], config.malOAuthScope);
    });
  });

  group('token endpoint', () {
    test('authorization_code exchange is form-urlencoded public-client PKCE', () async {
      late http.Request captured;
      final MalAuthService auth = MalAuthService(
        clock: () => now,
        client: MockClient((http.Request request) async {
          captured = request;
          return http.Response(tokenBody(), 200);
        }),
      );

      final MalTokenEntity token =
          await auth.exchangeAuthorizationCode('the-code', codeVerifier: 'the-verifier');

      expect(captured.method, 'POST');
      expect(captured.url.toString(), config.malTokenEndpoint);
      expect(captured.headers['content-type'], contains('application/x-www-form-urlencoded'));
      expect(captured.body, contains('grant_type=authorization_code'));
      expect(captured.body, contains('client_id=${Uri.encodeQueryComponent(config.malClientId)}'));
      expect(captured.body, contains('code=the-code'));
      expect(captured.body, contains('redirect_uri=${Uri.encodeQueryComponent(config.malRedirectUri)}'));
      expect(captured.body, contains('code_verifier=the-verifier'));
      expect(captured.body, isNot(contains('client_secret')),
          reason: 'MAL App Type "Other" is a public client: a secret breaks the grant');
      expect(token.accessToken, 'access-1');
      expect(token.refreshToken, 'refresh-1');
      expect(token.expiresIn, 3600);
      expect(token.tokenType, 'Bearer');
    });

    test('refresh_token exchange sends the stored refresh token and no secret', () async {
      late http.Request captured;
      final MalAuthService auth = MalAuthService(
        clock: () => now,
        client: MockClient((http.Request request) async {
          captured = request;
          return http.Response(tokenBody(access: 'access-2', refresh: 'refresh-2'), 200);
        }),
      );

      final MalTokenEntity token = await auth.exchangeRefreshToken('stored-refresh');

      expect(captured.headers['content-type'], contains('application/x-www-form-urlencoded'));
      expect(captured.body, contains('grant_type=refresh_token'));
      expect(captured.body, contains('client_id=${Uri.encodeQueryComponent(config.malClientId)}'));
      expect(captured.body, contains('refresh_token=stored-refresh'));
      expect(captured.body, isNot(contains('client_secret')));
      expect(token.accessToken, 'access-2');
      expect(token.refreshToken, 'refresh-2');
    });

    test('a rejected grant surfaces the server error, not a null token', () async {
      final MalAuthService auth = MalAuthService(
        clock: () => now,
        client: MockClient((http.Request request) async {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'error': 'invalid_grant',
              'error_description': 'The provided authorization grant is invalid',
            }),
            400,
          );
        }),
      );

      await expectLater(
        auth.exchangeAuthorizationCode('bad-code', codeVerifier: 'the-verifier'),
        throwsA(
          isA<MalAuthException>()
              .having((MalAuthException e) => e.statusCode, 'statusCode', 400)
              .having((MalAuthException e) => e.message, 'message', contains('invalid_grant')),
        ),
      );
    });

    test('a non-JSON error body is surfaced verbatim', () async {
      final MalAuthService auth = MalAuthService(
        clock: () => now,
        client: MockClient((http.Request request) async {
          return http.Response('<html>502 Bad Gateway</html>', 502);
        }),
      );

      await expectLater(
        auth.exchangeRefreshToken('stored-refresh'),
        throwsA(
          isA<MalAuthException>()
              .having((MalAuthException e) => e.statusCode, 'statusCode', 502)
              .having((MalAuthException e) => e.message, 'message', contains('502 Bad Gateway')),
        ),
      );
    });

    test('a transport failure maps to a typed exception with statusCode 0', () async {
      final MalAuthService auth = MalAuthService(
        clock: () => now,
        client: MockClient((http.Request request) async {
          throw const SocketException('connection refused');
        }),
      );

      await expectLater(
        auth.exchangeRefreshToken('stored-refresh'),
        throwsA(
          isA<MalAuthException>()
              .having((MalAuthException e) => e.statusCode, 'statusCode', 0)
              .having((MalAuthException e) => e.message, 'message', contains('connection refused')),
        ),
      );
    });

    test('a token answer without access_token is an auth error', () async {
      final MalAuthService auth = MalAuthService(
        clock: () => now,
        client: MockClient((http.Request request) async {
          return http.Response(jsonEncode(<String, dynamic>{'token_type': 'Bearer'}), 200);
        }),
      );

      await expectLater(
        auth.exchangeAuthorizationCode('the-code', codeVerifier: 'the-verifier'),
        throwsA(isA<MalAuthException>()),
      );
    });
  });

  group('expiry policy', () {
    test('expires_in is honoured and the safety margin is subtracted', () {
      final MalAuthService auth = MalAuthService(clock: () => now);
      final MalTokenEntity token =
          MalTokenEntity.fromJson(<String, dynamic>{'expires_in': 3600});

      final DateTime expiry = DateTime.parse(auth.expiresAtFor(token));

      expect(expiry, now.add(const Duration(hours: 1) - config.malAccessTokenExpiryMargin));
    });

    test('a token answer without expires_in falls back to the documented 1 hour', () {
      final MalAuthService auth = MalAuthService(clock: () => now);
      final MalTokenEntity token = MalTokenEntity.fromJson(<String, dynamic>{});

      final DateTime expiry = DateTime.parse(auth.expiresAtFor(token));

      expect(
        expiry,
        now.add(config.malAccessTokenTtl - config.malAccessTokenExpiryMargin),
      );
    });

    test('a stored expiry decides: past and empty are expired, future is not', () {
      final MalAuthService auth = MalAuthService(clock: () => now);

      expect(auth.isAccessTokenExpired(userWith(expiresAt: '')), isTrue);
      expect(auth.isAccessTokenExpired(userWith(expiresAt: '2026-11-08T11:00:00.000Z')), isTrue);
      expect(auth.isAccessTokenExpired(userWith(expiresAt: '2026-11-09T12:00:00.000Z')), isFalse);
      expect(auth.isAccessTokenExpired(userWith(expiresAt: 'junk')), isTrue);
    });
  });

  group('withFreshAccessToken', () {
    test('a valid token makes no HTTP call', () async {
      int calls = 0;
      final MalAuthService auth = MalAuthService(
        clock: () => now,
        client: MockClient((http.Request request) async {
          calls++;
          return http.Response(tokenBody(), 200);
        }),
      );

      final MalUserModel user = userWith(expiresAt: '2026-11-09T12:00:00.000Z');
      final MalUserModel result = await auth.withFreshAccessToken(user);

      expect(calls, 0);
      expect(identical(result, user), isTrue);
    });

    test('an expired token refreshes and applies the returned pair', () async {
      int calls = 0;
      final MalAuthService auth = MalAuthService(
        clock: () => now,
        client: MockClient((http.Request request) async {
          calls++;
          return http.Response(tokenBody(access: 'rotated-access', refresh: 'rotated-refresh'), 200);
        }),
      );

      final MalUserModel user = userWith(expiresAt: '2026-11-08T09:00:00.000Z');
      final MalUserModel result = await auth.withFreshAccessToken(user);

      expect(calls, 1);
      expect(result.accessToken, 'rotated-access');
      expect(result.refreshToken, 'rotated-refresh',
          reason: 'a MAL refresh answer rotates the refresh token too');
      expect(auth.isAccessTokenExpired(result), isFalse);
      expect(result.id, user.id, reason: 'the account identity is untouched');
    });

    test('an answer without a refresh token keeps the stored one', () async {
      final MalAuthService auth = MalAuthService(
        clock: () => now,
        client: MockClient((http.Request request) async {
          return http.Response(tokenBody(refresh: ''), 200);
        }),
      );

      final MalUserModel result =
          await auth.withFreshAccessToken(userWith(expiresAt: '2026-10-01T00:00:00.000Z'));

      expect(result.refreshToken, 'stored-refresh');
    });

    test('no refresh token stored is an auth error, not a silent success', () async {
      final MalAuthService auth = MalAuthService(clock: () => now);

      await expectLater(
        auth.withFreshAccessToken(userWith().copyWith(refreshToken: '')),
        throwsA(isA<MalAuthException>()),
      );
    });
  });
}

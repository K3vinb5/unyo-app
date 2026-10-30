// External dependencies
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/services/api/dto/shikimori/shikimori_token_entity.dart';
import 'package:unyo/core/services/api/shikimori/shikimori_auth_service.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/domain/entities/user/settings.dart';

class MockLogger extends Mock implements Logger {}

/// Shikimori OAuth2: multipart token exchange, 1-day tokens, rotating refresh
/// pair, and the expiry policy driven by an injected clock.
void main() {
  final DateTime now = DateTime.utc(2026, 10, 29, 12);

  String tokenBody({
    String access = 'access-1',
    String refresh = 'refresh-1',
    int expiresIn = 86400,
  }) {
    return jsonEncode(<String, dynamic>{
      'access_token': access,
      'token_type': 'Bearer',
      'expires_in': expiresIn,
      'refresh_token': refresh,
      'scope': 'user_rates',
      'created_at': now.millisecondsSinceEpoch ~/ 1000,
    });
  }

  ShikimoriUserModel userWith({String expiresAt = ''}) {
    return ShikimoriUserModel(
      id: '23456789',
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

  group('token endpoint', () {
    test('authorization_code exchange is multipart form with the app credentials', () async {
      late http.Request captured;
      final ShikimoriAuthService auth = ShikimoriAuthService(
        clock: () => now,
        client: MockClient((http.Request request) async {
          captured = request;
          return http.Response(tokenBody(), 200);
        }),
      );

      final ShikimoriTokenEntity token = await auth.exchangeAuthorizationCode('the-code');

      expect(captured.method, 'POST');
      expect(captured.url.toString(), config.shikimoriTokenEndpoint);
      expect(captured.headers['User-Agent'], config.shikimoriRequestHeaders['User-Agent']);
      expect(captured.headers['content-type'], contains('multipart/form-data'));
      expect(captured.body, contains('name="grant_type"'));
      expect(captured.body, contains('authorization_code'));
      expect(captured.body, contains('the-code'));
      expect(captured.body, contains(config.shikimoriRedirectUri));
      expect(token.accessToken, 'access-1');
      expect(token.refreshToken, 'refresh-1');
    });

    test('refresh_token exchange sends the stored refresh token', () async {
      late http.Request captured;
      final ShikimoriAuthService auth = ShikimoriAuthService(
        clock: () => now,
        client: MockClient((http.Request request) async {
          captured = request;
          return http.Response(tokenBody(access: 'access-2', refresh: 'refresh-2'), 200);
        }),
      );

      final ShikimoriTokenEntity token = await auth.exchangeRefreshToken('stored-refresh');

      expect(captured.body, contains('name="grant_type"'));
      expect(captured.body, contains('refresh_token'));
      expect(captured.body, contains('stored-refresh'));
      expect(token.accessToken, 'access-2');
      expect(token.refreshToken, 'refresh-2');
    });

    test('a rejected grant surfaces the server error, not a null token', () async {
      final ShikimoriAuthService auth = ShikimoriAuthService(
        clock: () => now,
        client: MockClient((http.Request request) async {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'error': 'invalid_grant',
              'error_description': 'The provided authorization grant is invalid',
            }),
            401,
          );
        }),
      );

      await expectLater(
        auth.exchangeAuthorizationCode('bad-code'),
        throwsA(
          isA<ShikimoriAuthException>()
              .having((ShikimoriAuthException e) => e.statusCode, 'statusCode', 401)
              .having((ShikimoriAuthException e) => e.message, 'message', contains('invalid_grant')),
        ),
      );
    });
  });

  group('expiry policy', () {
    test('expires_in is honoured and the safety margin is subtracted', () {
      final ShikimoriAuthService auth = ShikimoriAuthService(clock: () => now);
      final ShikimoriTokenEntity token = ShikimoriTokenEntity.fromJson(<String, dynamic>{'expires_in': 3600});

      final DateTime expiry = DateTime.parse(auth.expiresAtFor(token));

      expect(expiry, now.add(const Duration(hours: 1) - config.shikimoriAccessTokenExpiryMargin));
    });

    test('a token answer without expires_in falls back to the documented 1 day', () {
      final ShikimoriAuthService auth = ShikimoriAuthService(clock: () => now);
      final ShikimoriTokenEntity token = ShikimoriTokenEntity.fromJson(<String, dynamic>{});

      final DateTime expiry = DateTime.parse(auth.expiresAtFor(token));

      expect(
        expiry,
        now.add(config.shikimoriAccessTokenTtl - config.shikimoriAccessTokenExpiryMargin),
      );
    });

    test('a stored expiry decides: past and empty are expired, future is not', () {
      final ShikimoriAuthService auth = ShikimoriAuthService(clock: () => now);

      expect(auth.isAccessTokenExpired(userWith(expiresAt: '')), isTrue);
      expect(auth.isAccessTokenExpired(userWith(expiresAt: '2026-10-29T11:00:00.000Z')), isTrue);
      expect(auth.isAccessTokenExpired(userWith(expiresAt: '2026-10-30T12:00:00.000Z')), isFalse);
      expect(auth.isAccessTokenExpired(userWith(expiresAt: 'junk')), isTrue);
    });
  });

  group('withFreshAccessToken', () {
    test('a valid token makes no HTTP call', () async {
      int calls = 0;
      final ShikimoriAuthService auth = ShikimoriAuthService(
        clock: () => now,
        client: MockClient((http.Request request) async {
          calls++;
          return http.Response(tokenBody(), 200);
        }),
      );

      final ShikimoriUserModel user = userWith(expiresAt: '2026-10-30T12:00:00.000Z');
      final ShikimoriUserModel result = await auth.withFreshAccessToken(user);

      expect(calls, 0);
      expect(identical(result, user), isTrue);
    });

    test('an expired token refreshes and rotates BOTH tokens', () async {
      int calls = 0;
      final ShikimoriAuthService auth = ShikimoriAuthService(
        clock: () => now,
        client: MockClient((http.Request request) async {
          calls++;
          return http.Response(tokenBody(access: 'rotated-access', refresh: 'rotated-refresh'), 200);
        }),
      );

      final ShikimoriUserModel user = userWith(expiresAt: '2026-10-29T09:00:00.000Z');
      final ShikimoriUserModel result = await auth.withFreshAccessToken(user);

      expect(calls, 1);
      expect(result.accessToken, 'rotated-access');
      expect(result.refreshToken, 'rotated-refresh',
          reason: 'Shikimori returns a new refresh token, dropping it would lose the account');
      expect(auth.isAccessTokenExpired(result), isFalse);
      expect(result.id, user.id, reason: 'the account identity is untouched');
    });

    test('an answer without a refresh token keeps the stored one', () async {
      final ShikimoriAuthService auth = ShikimoriAuthService(
        clock: () => now,
        client: MockClient((http.Request request) async {
          return http.Response(tokenBody(refresh: ''), 200);
        }),
      );

      final ShikimoriUserModel result =
          await auth.withFreshAccessToken(userWith(expiresAt: '2026-10-01T00:00:00.000Z'));

      expect(result.refreshToken, 'stored-refresh');
    });

    test('no refresh token stored is an auth error, not a silent success', () async {
      final ShikimoriAuthService auth = ShikimoriAuthService(clock: () => now);

      await expectLater(
        auth.withFreshAccessToken(userWith().copyWith(refreshToken: '')),
        throwsA(isA<ShikimoriAuthException>()),
      );
    });
  });
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_token_entity.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';

/// The token endpoint refused the grant (bad/expired code, revoked refresh
/// token, or a client id/secret the application does not own).
class ShikimoriAuthException implements Exception {
  final int statusCode;
  final String message;

  const ShikimoriAuthException(this.statusCode, this.message);

  @override
  String toString() => 'ShikimoriAuthException($statusCode): $message';
}

/// Shikimori OAuth2 client (WP #64 subpart (c)).
///
/// Verified facts this class encodes (`raws/api/rest-oauth-guide-extracted.txt`):
///
/// * the token endpoint takes **multipart form** data, not JSON — which is why
///   it bypasses [HttpService], whose transport is JSON-only;
/// * `grant_type=authorization_code` exchanges the redirect `code`;
/// * `grant_type=refresh_token` returns a **new access token *and* a new refresh
///   token**;
/// * the access token expires in **1 day**, and an expired one answers `401`
///   with `{"error":"invalid_token"}`.
///
/// The clock is injectable so the expiry policy can be tested without sleeping.
class ShikimoriAuthService {
  final http.Client _client;
  final DateTime Function() _clock;
  final Logger _logger = sl<Logger>();

  ShikimoriAuthService({http.Client? client, DateTime Function()? clock})
      : _client = client ?? http.Client(),
        _clock = clock ?? DateTime.now;

  /// Step 3 of the OAuth guide: swap the redirect `code` for a token pair.
  Future<ShikimoriTokenEntity> exchangeAuthorizationCode(String code) {
    _logger.i("Exchanging Shikimori authorization code for a token pair");
    return _requestToken(<String, String>{
      'grant_type': 'authorization_code',
      'client_id': config.shikimoriClientId,
      'client_secret': config.shikimoriClientSecret,
      'redirect_uri': config.shikimoriRedirectUri,
      'code': code,
    });
  }

  /// Step 5 of the OAuth guide: refresh from a stored refresh token.
  Future<ShikimoriTokenEntity> exchangeRefreshToken(String refreshToken) {
    _logger.i("Refreshing Shikimori access token");
    return _requestToken(<String, String>{
      'grant_type': 'refresh_token',
      'client_id': config.shikimoriClientId,
      'client_secret': config.shikimoriClientSecret,
      'refresh_token': refreshToken,
    });
  }

  /// ISO8601 expiry for a token answer, anchored at the moment it was received.
  ///
  /// `expires_in` is honoured when the server sends it; otherwise the documented
  /// 1-day lifetime is used. A one-minute margin is subtracted so a token cannot
  /// expire between the check and the request it authorizes.
  String expiresAtFor(ShikimoriTokenEntity token, {DateTime? receivedAt}) {
    final DateTime issuedAt = receivedAt ?? _clock();
    final int seconds = token.expiresIn > 0
        ? token.expiresIn
        : config.shikimoriAccessTokenTtl.inSeconds;
    final Duration ttl = Duration(seconds: seconds) - config.shikimoriAccessTokenExpiryMargin;
    return issuedAt.add(ttl).toIso8601String();
  }

  /// `true` when [user]'s stored access token must be refreshed before use.
  /// An unparseable/empty expiry counts as expired: the refresh is cheap, a 401
  /// in the middle of a write is not.
  bool isAccessTokenExpired(ShikimoriUserModel user, {DateTime? at}) {
    final DateTime? expiresAt = DateTime.tryParse(user.accessTokenExpiresAt);
    if (expiresAt == null) return true;
    return !expiresAt.isAfter(at ?? _clock());
  }

  /// Returns a user whose access token is usable, refreshing and rotating the
  /// pair when the stored one has expired. The caller persists the result
  /// (the repository does, via `updateUserInfo`).
  Future<ShikimoriUserModel> withFreshAccessToken(ShikimoriUserModel user) async {
    if (!isAccessTokenExpired(user)) return user;
    if (user.refreshToken.isEmpty) {
      throw ShikimoriAuthException(401, "No refresh token stored for ${user.name}");
    }
    final ShikimoriTokenEntity token = await exchangeRefreshToken(user.refreshToken);
    return applyToken(user, token);
  }

  /// Applies a token answer to [user]. A refresh answer always carries a new
  /// refresh token; when a server omits it, the stored one is kept so the
  /// account is not bricked by a partial payload.
  ShikimoriUserModel applyToken(ShikimoriUserModel user, ShikimoriTokenEntity token) {
    return user.copyWith(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken.isEmpty ? user.refreshToken : token.refreshToken,
      accessTokenExpiresAt: expiresAtFor(token),
    );
  }

  /// `Authorization` (+ mandatory `User-Agent`) headers for one API call.
  Map<String, String> authorizationHeaders(String accessToken) {
    return <String, String>{
      ...config.shikimoriRequestHeaders,
      'Authorization': 'Bearer $accessToken',
    };
  }

  Future<ShikimoriTokenEntity> _requestToken(Map<String, String> fields) async {
    final http.MultipartRequest request = http.MultipartRequest(
      'POST',
      Uri.parse(config.shikimoriTokenEndpoint),
    )..headers.addAll(config.shikimoriRequestHeaders);
    request.fields.addAll(fields);
    try {
      final http.StreamedResponse streamed = await _client.send(request);
      final http.Response response = await http.Response.fromStream(streamed);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _logger.e("Shikimori token endpoint answered ${response.statusCode}");
        throw ShikimoriAuthException(response.statusCode, _errorMessage(response.body));
      }
      final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      final ShikimoriTokenEntity token = ShikimoriTokenEntity.fromJson(json);
      if (token.accessToken.isEmpty) {
        throw ShikimoriAuthException(response.statusCode, "Token answer carried no access_token");
      }
      return token;
    } on ShikimoriAuthException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.e("Shikimori token request failed: $e", stackTrace: stackTrace);
      throw ShikimoriAuthException(0, e.toString());
    }
  }

  String _errorMessage(String body) {
    try {
      final Object? decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return '${decoded['error']}: ${decoded['error_description']}';
      }
    } catch (_) {
      // Non-JSON error page (ddos-guard, 500 page): fall through to the raw body.
    }
    return body;
  }
}

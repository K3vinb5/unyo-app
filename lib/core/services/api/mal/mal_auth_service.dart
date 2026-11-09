import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/dto/mal/mal_token_entity.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';

/// The token endpoint refused the grant (bad/expired code, revoked refresh
/// token, or a client id the application does not own).
class MalAuthException implements Exception {
  final int statusCode;
  final String message;

  const MalAuthException(this.statusCode, this.message);

  @override
  String toString() => 'MalAuthException($statusCode): $message';
}

/// MyAnimeList OAuth2 client (WP #156).
///
/// Verified facts this class encodes (`research/unyo-156-mal-tracker-proof/SPEC.md` §3):
///
/// * auth-code + **PKCE `plain` only** — S256 is rejected, and
///   `code_challenge == code_verifier`;
/// * the token endpoint takes **application/x-www-form-urlencoded** — JSON
///   answers `unsupported_grant_type` — so it bypasses [HttpService], whose
///   transport is JSON-only;
/// * the app is a **public client** (App Type "Other"): `client_secret` must
///   never be sent;
/// * `grant_type=authorization_code` exchanges the redirect `code`;
/// * `grant_type=refresh_token` returns a new access token (and usually a new
///   refresh token); the returned pair replaces the stored one;
/// * `expires_in` is trusted (docs say 1 h, historically drifted), and an
///   expired access token answers `401`.
///
/// The clock is injectable so the expiry policy can be tested without sleeping;
/// the [Random] is injectable so the PKCE verifier/state can be tested
/// deterministically (production uses [Random.secure]).
class MalAuthService {
  final http.Client _client;
  final DateTime Function() _clock;
  final Random _random;
  final Logger _logger = sl<Logger>();

  /// Length of the generated PKCE verifier (RFC 7636 allows 43-128).
  static const int codeVerifierLength = 64;

  /// Length of the OAuth `state` (CSRF check).
  static const int stateLength = 32;

  /// RFC 7636 §4.1 unreserved characters: ALPHA / DIGIT / "-" / "." / "_" / "~".
  static const String _pkceCharset =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  MalAuthService({
    http.Client? client,
    DateTime Function()? clock,
    Random? random,
  })  : _client = client ?? http.Client(),
        _clock = clock ?? DateTime.now,
        _random = random ?? Random.secure();

  /// Step 1 of the OAuth flow: a PKCE `code_verifier` (43-128 chars).
  String generateCodeVerifier() {
    return _randomString(codeVerifierLength);
  }

  /// Step 1 of the OAuth flow: the `state` echoed back on the redirect.
  String generateState() {
    return _randomString(stateLength);
  }

  /// Step 2 of the OAuth flow: the authorization URL to open in the browser.
  ///
  /// `code_challenge_method=plain` means `code_challenge` **is** the verifier;
  /// MAL rejects S256.
  Uri buildAuthorizationUrl({
    required String codeVerifier,
    required String state,
  }) {
    return Uri.parse(config.malAuthorizeEndpoint).replace(
      queryParameters: <String, String>{
        'response_type': 'code',
        'client_id': config.malClientId,
        'redirect_uri': config.malRedirectUri,
        'code_challenge': codeVerifier,
        'code_challenge_method': 'plain',
        'state': state,
        'scope': config.malOAuthScope,
      },
    );
  }

  /// Step 4 of the OAuth flow: swap the redirect `code` for a token pair.
  ///
  /// [codeVerifier] must be the exact value used to build the authorize URL.
  /// No `client_secret`: this is a public client.
  Future<MalTokenEntity> exchangeAuthorizationCode(
    String code, {
    required String codeVerifier,
  }) {
    _logger.i("Exchanging MyAnimeList authorization code for a token pair");
    return _requestToken(<String, String>{
      'grant_type': 'authorization_code',
      'client_id': config.malClientId,
      'code': code,
      'redirect_uri': config.malRedirectUri,
      'code_verifier': codeVerifier,
    });
  }

  /// Refresh from a stored refresh token. No `client_secret`: public client.
  Future<MalTokenEntity> exchangeRefreshToken(String refreshToken) {
    _logger.i("Refreshing MyAnimeList access token");
    return _requestToken(<String, String>{
      'grant_type': 'refresh_token',
      'client_id': config.malClientId,
      'refresh_token': refreshToken,
    });
  }

  /// ISO8601 expiry for a token answer, anchored at the moment it was received.
  ///
  /// `expires_in` is trusted when the server sends it; otherwise the documented
  /// 1-hour lifetime is used. A one-minute margin is subtracted so a token
  /// cannot expire between the check and the request it authorizes.
  String expiresAtFor(MalTokenEntity token, {DateTime? receivedAt}) {
    final DateTime issuedAt = receivedAt ?? _clock();
    final int seconds = token.expiresIn > 0
        ? token.expiresIn
        : config.malAccessTokenTtl.inSeconds;
    final Duration ttl =
        Duration(seconds: seconds) - config.malAccessTokenExpiryMargin;
    return issuedAt.add(ttl).toIso8601String();
  }

  /// `true` when [user]'s stored access token must be refreshed before use.
  /// An unparseable/empty expiry counts as expired: the refresh is cheap, a 401
  /// in the middle of a write is not.
  bool isAccessTokenExpired(MalUserModel user, {DateTime? at}) {
    final DateTime? expiresAt = DateTime.tryParse(user.accessTokenExpiresAt);
    if (expiresAt == null) return true;
    return !expiresAt.isAfter(at ?? _clock());
  }

  /// Returns a user whose access token is usable, refreshing and rotating the
  /// pair when the stored one has expired. The caller persists the result
  /// (the repository does, via `updateUserInfo`).
  Future<MalUserModel> withFreshAccessToken(MalUserModel user) async {
    if (!isAccessTokenExpired(user)) return user;
    if (user.refreshToken.isEmpty) {
      throw MalAuthException(401, "No refresh token stored for ${user.name}");
    }
    final MalTokenEntity token = await exchangeRefreshToken(user.refreshToken);
    return applyToken(user, token);
  }

  /// Applies a token answer to [user]. When a server omits the new refresh
  /// token, the stored one is kept so the account is not bricked by a partial
  /// payload.
  MalUserModel applyToken(MalUserModel user, MalTokenEntity token) {
    return user.copyWith(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken.isEmpty
          ? user.refreshToken
          : token.refreshToken,
      accessTokenExpiresAt: expiresAtFor(token),
    );
  }

  /// `Authorization` header for one API call.
  Map<String, String> authorizationHeaders(String accessToken) {
    return <String, String>{
      'Authorization': 'Bearer $accessToken',
    };
  }

  String _randomString(int length) {
    final List<int> units = List<int>.generate(
      length,
      (int _) => _pkceCharset.codeUnitAt(_random.nextInt(_pkceCharset.length)),
    );
    return String.fromCharCodes(units);
  }

  Future<MalTokenEntity> _requestToken(Map<String, String> fields) async {
    // `bodyFields` encodes application/x-www-form-urlencoded, the only content
    // type MAL's token endpoint accepts.
    final http.Request request = http.Request(
      'POST',
      Uri.parse(config.malTokenEndpoint),
    )..bodyFields = fields;
    try {
      // Bounded like the metadata transport: a dead host must fail the grant
      // instead of hanging the login/refresh for the OS SYN-retry window.
      final http.StreamedResponse streamed =
          await _client.send(request).timeout(config.malRequestTimeout);
      final http.Response response = await http.Response.fromStream(streamed);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _logger.e("MyAnimeList token endpoint answered ${response.statusCode}");
        throw MalAuthException(
            response.statusCode, _errorMessage(response.body));
      }
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      final MalTokenEntity token = MalTokenEntity.fromJson(json);
      if (token.accessToken.isEmpty) {
        throw MalAuthException(
            response.statusCode, "Token answer carried no access_token");
      }
      return token;
    } on MalAuthException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.e("MyAnimeList token request failed: $e", stackTrace: stackTrace);
      throw MalAuthException(0, e.toString());
    }
  }

  String _errorMessage(String body) {
    try {
      final Object? decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return '${decoded['error']}: ${decoded['error_description']}';
      }
    } catch (_) {
      // Non-JSON error page (500 page, proxy error): fall through to the raw body.
    }
    return body;
  }
}

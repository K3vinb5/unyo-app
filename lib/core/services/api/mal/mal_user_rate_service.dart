import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/dto/mal/mal_my_list_status_entity.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/api/mal/mal_auth_service.dart';
import 'package:unyo/data/models/mal/media/mal_list_status_policy.dart';
import 'package:unyo/data/models/mal/media/mal_media_mapper.dart';
import 'package:unyo/core/services/api/mal/mal_rate_limiter.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/data/repositories/user_repository_mal.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';

/// List-entry reads and writes against the MyAnimeList REST API v2 (WP #156).
///
/// Mirrors `ShikimoriUserRateService` (same surface, same auth-retry shape),
/// adapted to MAL's upsert semantics and its form-urlencoded writes:
///
/// | intent | call |
/// | --- | --- |
/// | read one entry | `GET /{kind}/{id}?fields=my_list_status` (no `GET /my_list_status` exists) |
/// | create + update | `PUT /{kind}/{id}/my_list_status` (upsert, partial update) |
/// | remove from list | `DELETE /{kind}/{id}/my_list_status` (404 when absent) |
///
/// Verified quirks this class encodes (`research/unyo-156-mal-tracker-proof/SPEC.md` §3):
///
/// * the write body is **application/x-www-form-urlencoded** (the official
///   curl sample and every known client send form fields), so — like
///   [MalAuthService] — the calls bypass `HttpService`, whose transport is
///   JSON-only, and go through an injectable `http.Client` instead;
/// * request `num_watched_episodes` ↔ response `num_episodes_watched` (anime);
///   a wrong key answers `bad_request "extra fields"`, so only the kind's own
///   counters are ever sent;
/// * manga writes `num_chapters_read` + `num_volumes_read` and reads them back
///   under the same names;
/// * `score` is an int 0-10 and **0 means unscored**;
/// * `is_rewatching`/`is_rereading` + `num_times_rewatched`/`num_times_reread`
///   fold onto the shared `repeat` through [MalListStatusPolicy];
/// * MAL throttles with **403** (not 429): every call takes a grant from the
///   shared [MalRateLimiter] first, and a 403 is surfaced (never retried and
///   never mistaken for the 401 that triggers a token refresh).
class MalUserRateService {
  final http.Client _client;
  final Logger _logger = sl<Logger>();

  /// Shared MyAnimeList budget; resolved lazily so tests that only exercise the
  /// pure mapping logic do not need it registered.
  MalRateLimiter get _rateLimiter => sl<MalRateLimiter>();
  final MalAuthService _authService = sl<MalAuthService>();
  final UserRepositoryMal _userRepository = sl<UserRepositoryMal>();

  MalUserRateService({http.Client? client}) : _client = client ?? http.Client();

  /// One entry, or the empty entry when the user has no list status for the
  /// title (and when MAL 404s the media id itself — the editor treats both as
  /// "not on the list yet").
  Future<MediaListEntry> getEntry({
    required MalUserModel user,
    required int targetId,
    required MalListTarget target,
  }) async {
    _validateId(targetId);
    return _withAuthRetry(user, (MalUserModel authorized) async {
      final MalMyListStatusEntity? status = await _readStatus(authorized, targetId: targetId, target: target);
      if (status == null) return MediaListEntryModel.empty();
      return _toEntry(status, target);
    });
  }

  /// Applies [entry] to the user's list for `targetId`.
  ///
  /// * no unified status (the "add to list" empty entry) → `DELETE`
  ///   (a 404 means it was already gone — that is the desired end state);
  /// * anything else → `PUT` (MAL upserts: it creates the entry when absent and
  ///   updates only the keys sent).
  Future<MediaListEntry> updateEntry({
    required MalUserModel user,
    required int targetId,
    required MalListTarget target,
    required MediaListEntry entry,
  }) async {
    _validateId(targetId);
    return _withAuthRetry(user, (MalUserModel authorized) async {
      final String status = MalListStatusPolicy.toMal(entry.status, target: target);
      if (status.isEmpty) {
        _logger.i("Removing MyAnimeList list status for $targetId");
        await _delete(authorized, targetId: targetId, target: target);
        return MediaListEntryModel.empty();
      }
      _logger.i("Writing MyAnimeList list status for $targetId as $status");
      return _toEntry(await _update(authorized, targetId: targetId, target: target, entry: entry, status: status), target);
    });
  }

  /// Refreshes the stored token first when it expired, then runs [call]. A `401`
  /// (revoked/rotated token) forces one refresh and one retry; a `403` is the
  /// throttle signal and is rethrown untouched.
  Future<T> _withAuthRetry<T>(
    MalUserModel user,
    Future<T> Function(MalUserModel authorizedUser) call,
  ) async {
    final MalUserModel fresh = await _freshUser(user);
    try {
      return await call(fresh);
    } on HttpServerException catch (e) {
      if (e.statusCode != 401) rethrow;
      _logger.w("MyAnimeList answered 401, refreshing the token and retrying once");
      final MalUserModel retried = await _freshUser(fresh, force: true);
      return call(retried);
    }
  }

  /// The user whose access token is usable right now. A rotated token pair is
  /// written back to the account store so the next launch keeps working.
  Future<MalUserModel> _freshUser(MalUserModel user, {bool force = false}) async {
    final bool expired = force || _authService.isAccessTokenExpired(user);
    if (!expired) return user;
    final MalUserModel refreshed = await _authService.withFreshAccessToken(
      force ? user.copyWith(accessTokenExpiresAt: '') : user,
    );
    await _userRepository.updateUserInfo(refreshed);
    return refreshed;
  }

  /// `my_list_status` of one entry, or `null` when the user has none (MAL omits
  /// the key) or the media id does not exist (404).
  Future<MalMyListStatusEntity?> _readStatus(
    MalUserModel user, {
    required int targetId,
    required MalListTarget target,
  }) async {
    final Uri uri = Uri.parse('${config.malApiBase}/${target.wireValue}/$targetId')
        .replace(queryParameters: <String, String>{'fields': 'my_list_status'});
    await _rateLimiter.acquire(reason: "GET ${target.wireValue}/$targetId my_list_status");
    final http.Response response = await _send('GET', uri, headers: _headers(user));
    if (response.statusCode == 404) {
      _logger.w("MyAnimeList has no ${target.wireValue} $targetId (404), treating it as not on the list");
      return null;
    }
    _expectOk(response);
    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    final MalMyListStatusMediaEntity media = MalMyListStatusMediaEntity.fromJson(json);
    if (media.myListStatus.status.isEmpty) return null;
    return media.myListStatus;
  }

  /// The upsert write. Only the keys the entry actually owns are sent — MAL
  /// updates only specified parameters, and a wrong key is `bad_request`.
  Future<MalMyListStatusEntity> _update(
    MalUserModel user, {
    required int targetId,
    required MalListTarget target,
    required MediaListEntry entry,
    required String status,
  }) async {
    final Uri uri = Uri.parse('${config.malApiBase}/${target.wireValue}/$targetId/my_list_status');
    await _rateLimiter.acquire(reason: "PUT ${target.wireValue}/$targetId my_list_status");
    final http.Response response = await _send(
      'PUT',
      uri,
      headers: _headers(user),
      body: _payload(entry, target: target, status: status),
    );
    _expectOk(response);
    return MalMyListStatusEntity.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> _delete(
    MalUserModel user, {
    required int targetId,
    required MalListTarget target,
  }) async {
    final Uri uri = Uri.parse('${config.malApiBase}/${target.wireValue}/$targetId/my_list_status');
    await _rateLimiter.acquire(reason: "DELETE ${target.wireValue}/$targetId my_list_status");
    final http.Response response = await _send('DELETE', uri, headers: _headers(user));
    if (response.statusCode == 404) {
      _logger.i("MyAnimeList had no ${target.wireValue} $targetId entry to remove");
      return;
    }
    _expectOk(response);
  }

  /// Form-urlencoded request body of the upsert. Kind-specific counters only:
  /// anime sends `num_watched_episodes`, manga `num_chapters_read` +
  /// `num_volumes_read` — the response names differ (`num_episodes_watched`),
  /// the request names are these.
  Map<String, String> _payload(
    MediaListEntry entry, {
    required MalListTarget target,
    required String status,
  }) {
    final int progress = entry.progress < 0 ? 0 : entry.progress;
    final int volumes = entry.progressVolumes < 0 ? 0 : entry.progressVolumes;
    final int repeat = MalListStatusPolicy.rewatchCountFor(
      unifiedStatus: entry.status,
      repeat: entry.repeat,
    );
    final bool rewatching = MalListStatusPolicy.isRewatchingFor(entry.status);
    final Map<String, String> payload = <String, String>{
      'status': status,
    };
    // `-1.0` is the domain's "no score" sentinel and must never reach the wire
    // (mirror of anime_repository_anilist.dart, which omits the key at -1.0):
    // an explicit `0` on this partial upsert would clear a stored score, while
    // omitting the key leaves it alone. A real score is clamped into MAL's
    // 0-10 range before rounding.
    if (entry.score != -1.0) {
      payload['score'] = entry.score.clamp(0, 10).round().toString();
    }
    switch (target) {
      case MalListTarget.anime:
        payload['num_watched_episodes'] = progress.toString();
        payload['is_rewatching'] = rewatching.toString();
        payload['num_times_rewatched'] = repeat.toString();
      case MalListTarget.manga:
        payload['num_chapters_read'] = progress.toString();
        payload['num_volumes_read'] = volumes.toString();
        payload['is_rereading'] = rewatching.toString();
        payload['num_times_reread'] = repeat.toString();
    }
    return payload;
  }

  /// Fold shared with the metadata details models (`MalMediaMapper.listEntry`),
  /// so the tracker and the details page cannot disagree on an entry.
  MediaListEntry _toEntry(MalMyListStatusEntity status, MalListTarget target) {
    return MalMediaMapper.listEntry(status, target: target) ?? MediaListEntryModel.empty();
  }

  Future<http.Response> _send(
    String method,
    Uri uri, {
    required Map<String, String> headers,
    Map<String, String>? body,
  }) async {
    final http.Request request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) {
      request.bodyFields = body;
    }
    // Bounded like the metadata transport (`config.malRequestTimeout`): a dead
    // host must not hang a list read for the OS SYN-retry window.
    try {
      final http.StreamedResponse streamed =
          await _client.send(request).timeout(config.malRequestTimeout);
      return await http.Response.fromStream(streamed);
    } on TimeoutException {
      _logger.e("$method $uri timed out after ${config.malRequestTimeout.inSeconds} s");
      throw HttpTimeoutException("$method $uri timed out after ${config.malRequestTimeout.inSeconds} s");
    } on SocketException catch (e) {
      _logger.e("$method $uri hit a socket error: $e");
      throw HttpNetworkException("$method $uri failed: ${e.message}");
    } on http.ClientException catch (e) {
      _logger.e("$method $uri hit a client error: $e");
      throw HttpNetworkException("$method $uri failed: ${e.message}");
    }
  }

  void _expectOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpServerException(response.statusCode, response.body);
    }
  }

  void _validateId(int targetId) {
    if (targetId <= 0) {
      throw ArgumentError.value(targetId, 'targetId', 'MAL media ids are positive integers');
    }
  }

  Map<String, String> _headers(MalUserModel user) {
    return _authService.authorizationHeaders(user.accessToken);
  }
}

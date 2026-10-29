import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_user_rate_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_user_rate_list_entity.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/empty_api_response.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/api/shikimori/shikimori_auth_service.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_list_status_policy.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/user_repository_shikimori.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

/// Which media kind a `user_rate` addresses. Shikimori spells it PascalCase in
/// both surfaces (`UserRateTargetTypeEnum` = `Anime`/`Manga`, REST
/// `target_type` = `Anime`/`Manga`).
enum ShikimoriUserRateTarget {
  anime('Anime'),
  manga('Manga');

  const ShikimoriUserRateTarget(this.wireValue);

  final String wireValue;
}

/// List-entry reads and writes against Shikimori REST v2 (`/api/v2/user_rates`).
///
/// The GraphQL `Mutation` root is a stub (`testField`), so **every** write is
/// REST (`raws/api/rest-api-doc-extracted.txt`, WP #64 decision set):
///
/// | intent | call |
/// | --- | --- |
/// | read one entry | `GET /api/v2/user_rates?user_id&target_id&target_type` |
/// | create | `POST /api/v2/user_rates` body `user_rate{…}` → 201 |
/// | update | `PATCH /api/v2/user_rates/:id` body `user_rate{…}` → 200 |
/// | next episode | `POST /api/v2/user_rates/:id/increment` body `{}` → 201 |
/// | remove from list | `DELETE /api/v2/user_rates/:id` → 204 |
///
/// Every call carries the mandatory `User-Agent` and the OAuth `Bearer` token;
/// the token is refreshed first when the stored one passed its 1-day lifetime,
/// and a `401` mid-flight triggers one refresh + retry.
class ShikimoriUserRateService {
  static const String userRateField = 'user_rate';

  final HttpService _httpService = sl<HttpService>();
  final ShikimoriAuthService _authService = sl<ShikimoriAuthService>();
  final UserRepositoryShikimori _userRepository = sl<UserRepositoryShikimori>();
  final Logger _logger = sl<Logger>();

  /// One entry, or the empty entry when the user has no rate for the title.
  Future<MediaListEntry> getEntry({
    required ShikimoriUserModel user,
    required int targetId,
    required ShikimoriUserRateTarget target,
  }) async {
    final ShikimoriUserRateEntity? rate = await _withAuthRetry(
      user,
      (ShikimoriUserModel authorized) => _findRate(authorized, targetId: targetId, target: target),
    );
    if (rate == null) return MediaListEntryModel.empty();
    return _toEntry(rate, target);
  }

  /// Applies [entry] to the user's list for `targetId`.
  ///
  /// * no unified status (the "add to list" empty entry) → `DELETE`;
  /// * no stored rate → `POST` create;
  /// * progress bumped by exactly one with every other field unchanged →
  ///   `POST :id/increment` (the call Shikimori's own UI uses, it also advances
  ///   the status when the last episode is reached);
  /// * anything else → `PATCH`.
  Future<MediaListEntry> updateEntry({
    required ShikimoriUserModel user,
    required int targetId,
    required ShikimoriUserRateTarget target,
    required MediaListEntry entry,
  }) async {
    return _withAuthRetry(
      user,
      (ShikimoriUserModel authorized) => _applyUpdate(
        authorized,
        targetId: targetId,
        target: target,
        entry: entry,
      ),
    );
  }

  Future<MediaListEntry> _applyUpdate(
    ShikimoriUserModel user, {
    required int targetId,
    required ShikimoriUserRateTarget target,
    required MediaListEntry entry,
  }) async {
    final ShikimoriUserRateEntity? existing = await _findRate(user, targetId: targetId, target: target);
    final String status = ShikimoriListStatusPolicy.toShikimori(entry.status);
    if (status.isEmpty) {
      if (existing == null) {
        _logger.i("No Shikimori rate for $targetId to remove");
        return MediaListEntryModel.empty();
      }
      _logger.i("Removing Shikimori rate ${existing.id} for $targetId");
      await _delete(user, existing.id);
      return MediaListEntryModel.empty();
    }
    if (existing == null) {
      _logger.i("Creating Shikimori rate for $targetId as $status");
      return _toEntry(await _create(user, targetId: targetId, target: target, entry: entry, status: status), target);
    }
    if (_isPureProgressIncrement(existing, entry, target)) {
      _logger.i("Incrementing Shikimori rate ${existing.id} for $targetId");
      return _toEntry(await _increment(user, existing.id), target);
    }
    _logger.i("Updating Shikimori rate ${existing.id} for $targetId");
    return _toEntry(
      await _update(user, existing.id, target: target, entry: entry, status: status),
      target,
    );
  }

  /// Refreshes the stored token first when it expired, then runs [call]. A `401`
  /// (revoked/rotated token) forces one refresh and one retry.
  Future<T> _withAuthRetry<T>(
    ShikimoriUserModel user,
    Future<T> Function(ShikimoriUserModel authorizedUser) call,
  ) async {
    final ShikimoriUserModel fresh = await _freshUser(user);
    try {
      return await call(fresh);
    } on HttpServerException catch (e) {
      if (e.statusCode != 401) rethrow;
      _logger.w("Shikimori answered 401, refreshing the token and retrying once");
      final ShikimoriUserModel retried = await _freshUser(fresh, force: true);
      return call(retried);
    }
  }

  /// The user whose access token is usable right now. A rotated token pair is
  /// written back to the account store so the next launch keeps working.
  Future<ShikimoriUserModel> _freshUser(ShikimoriUserModel user, {bool force = false}) async {
    final bool expired = force || _authService.isAccessTokenExpired(user);
    if (!expired) return user;
    final ShikimoriUserModel refreshed = await _authService.withFreshAccessToken(
      force ? user.copyWith(accessTokenExpiresAt: '') : user,
    );
    await _userRepository.updateUserInfo(refreshed);
    return refreshed;
  }

  Future<ShikimoriUserRateEntity?> _findRate(
    ShikimoriUserModel user, {
    required int targetId,
    required ShikimoriUserRateTarget target,
  }) async {
    final Uri uri = Uri.parse(config.shikimoriUserRatesEndpoint).replace(
      queryParameters: <String, String>{
        'user_id': user.id,
        'target_id': targetId.toString(),
        'target_type': target.wireValue,
      },
    );
    final ApiResponse<ShikimoriUserRateListEntity> response =
        await _httpService.get<ShikimoriUserRateListEntity>(
      uri.toString(),
      headers: _headers(user),
      // A list entry is read right before a write; a 20-minute cache would make
      // the editor act on a stale progress value.
      ignoreCache: true,
      fromJson: ShikimoriUserRateListEntity.fromJson,
    );
    return response.data.list.isEmpty ? null : response.data.list.first;
  }

  Future<ShikimoriUserRateEntity> _create(
    ShikimoriUserModel user, {
    required int targetId,
    required ShikimoriUserRateTarget target,
    required MediaListEntry entry,
    required String status,
  }) async {
    final Map<String, dynamic> payload = _payload(entry, target: target, status: status)
      ..['user_id'] = _userId(user)
      ..['target_id'] = targetId
      ..['target_type'] = target.wireValue;
    final ApiResponse<ShikimoriUserRateEntity> response = await _httpService.post<ShikimoriUserRateEntity>(
      config.shikimoriUserRatesEndpoint,
      headers: _headers(user),
      body: <String, dynamic>{userRateField: payload},
      ignoreCache: true,
      fromJson: ShikimoriUserRateEntity.fromJson,
    );
    return response.data;
  }

  Future<ShikimoriUserRateEntity> _update(
    ShikimoriUserModel user,
    int rateId, {
    required ShikimoriUserRateTarget target,
    required MediaListEntry entry,
    required String status,
  }) async {
    final ApiResponse<ShikimoriUserRateEntity> response = await _httpService.patch<ShikimoriUserRateEntity>(
      _rateEndpoint(rateId),
      headers: _headers(user),
      body: <String, dynamic>{
        userRateField: _payload(entry, target: target, status: status),
      },
      fromJson: ShikimoriUserRateEntity.fromJson,
    );
    return response.data;
  }

  Future<ShikimoriUserRateEntity> _increment(ShikimoriUserModel user, int rateId) async {
    final ApiResponse<ShikimoriUserRateEntity> response = await _httpService.post<ShikimoriUserRateEntity>(
      '${_rateEndpoint(rateId)}/increment',
      headers: _headers(user),
      body: const <String, dynamic>{},
      ignoreCache: true,
      fromJson: ShikimoriUserRateEntity.fromJson,
    );
    return response.data;
  }

  Future<void> _delete(ShikimoriUserModel user, int rateId) async {
    await _httpService.delete<EmptyApiResponse>(
      _rateEndpoint(rateId),
      headers: _headers(user),
      fromJson: EmptyApiResponse.fromJson,
    );
  }

  String _rateEndpoint(int rateId) => '${config.shikimoriUserRatesEndpoint}/$rateId';

  Map<String, String> _headers(ShikimoriUserModel user) {
    return _authService.authorizationHeaders(user.accessToken);
  }

  int _userId(ShikimoriUserModel user) => int.tryParse(user.id) ?? 0;

  /// Request body of a create/update. Shikimori's manga progress is `chapters`
  /// and its anime progress is `episodes`; only the kind-specific counter is
  /// sent, so a stale value in the other one is never overwritten with a guess.
  Map<String, dynamic> _payload(
    MediaListEntry entry, {
    required ShikimoriUserRateTarget target,
    required String status,
  }) {
    final int progress = entry.progress < 0 ? 0 : entry.progress;
    final int volumes = entry.progressVolumes < 0 ? 0 : entry.progressVolumes;
    final Map<String, dynamic> payload = <String, dynamic>{
      'status': status,
      'score': entry.score.round(),
      'rewatches': ShikimoriListStatusPolicy.rewatchesFor(unifiedStatus: entry.status, repeat: entry.repeat),
      'volumes': volumes,
    };
    switch (target) {
      case ShikimoriUserRateTarget.anime:
        payload['episodes'] = progress;
      case ShikimoriUserRateTarget.manga:
        payload['chapters'] = progress;
    }
    return payload;
  }

  MediaListEntry _toEntry(ShikimoriUserRateEntity rate, ShikimoriUserRateTarget target) {
    return MediaListEntryModel(
      progress: target == ShikimoriUserRateTarget.manga ? rate.chapters : rate.episodes,
      progressVolumes: rate.volumes,
      score: rate.score.toDouble(),
      repeat: ShikimoriListStatusPolicy.repeatFor(shikimoriStatus: rate.status, rewatches: rate.rewatches),
      status: ShikimoriListStatusPolicy.toUnified(rate.status),
      startedAt: TextUtils.formatISO8601DateTime(rate.createdAt),
      completedAt: TextUtils.formatISO8601DateTime(rate.updatedAt),
    );
  }

  /// True when the only change is `+1` progress, which is what the increment
  /// endpoint models (it also moves the status to `completed` on the last
  /// episode, which a plain PATCH would not do).
  bool _isPureProgressIncrement(
    ShikimoriUserRateEntity existing,
    MediaListEntry entry,
    ShikimoriUserRateTarget target,
  ) {
    final int stored = target == ShikimoriUserRateTarget.manga ? existing.chapters : existing.episodes;
    final int storedVolumes = existing.volumes;
    return entry.progress == stored + 1 &&
        entry.progressVolumes == storedVolumes &&
        entry.score.round() == existing.score &&
        ShikimoriListStatusPolicy.toShikimori(entry.status) == existing.status &&
        ShikimoriListStatusPolicy.rewatchesFor(unifiedStatus: entry.status, repeat: entry.repeat) ==
            existing.rewatches;
  }
}

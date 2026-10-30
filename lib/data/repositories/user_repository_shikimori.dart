// External dependencies
import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:logger/logger.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelfio;
import 'package:url_launcher/url_launcher.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_token_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_user_rates_anime_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_user_rates_manga_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_viewer_query_entity.dart';
import 'package:unyo/core/services/api/graphql/graphql_response.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/graphql/queries/shikimori_queries.dart' as shikimori_queries;
import 'package:unyo/core/services/api/shikimori/shikimori_auth_service.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_list_status_policy.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_manga_model.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/repository_mixin.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/user_repository.dart';

/// Shikimori **account** provider (WP #64 subpart (c)).
///
/// Mirrors [UserRepositoryAnilist]: a localhost shelf server catches the OAuth
/// redirect on the same `:9999/auth` callback AniList uses, the code is swapped
/// for a token pair, `currentUser` names the account, and the model goes to its
/// own Hive box. Lists come from GraphQL `userRates` (one document per target
/// type), writes from REST v2 through [ShikimoriUserRateService].
///
/// Status folding (decision 5) lives in [ShikimoriListStatusPolicy]:
/// `watching` + `rewatching` → `Watching`, `planned` → `Planning`,
/// `completed` → `Completed`, `on_hold` → `Paused`, `dropped` → `Dropped`.
class UserRepositoryShikimori with RepositoryMixin implements UserRepository {
  /// Shikimori's GraphQL `limit` cap, and the page size of every list read.
  static const int pageSize = 50;

  /// Safety stop so a runaway pagination can never turn into a hot loop
  /// (the API allows 90 requests/minute): 40 pages = 2 000 entries per status.
  static const int maxPagesPerStatus = 40;

  static const String usersBoxName = "shikimoriUsers";

  final Logger _logger = sl<Logger>();
  final GraphQLService _shikimoriGraphQLService = sl<GraphQLService>(
    instanceName: config.shikimoriGraphQlService,
  );
  final ShikimoriAuthService _authService = sl<ShikimoriAuthService>();
  final UserNotifier _newUserNotifier;
  final UserNotifier _loggedUserNotifier;
  late Box<ShikimoriUserModel> _shikimoriUsersBox;
  late HttpServer _server;

  UserRepositoryShikimori(this._newUserNotifier, this._loggedUserNotifier);

  @override
  Future<List<User>> fetchAllLoggedInUsers() async {
    _shikimoriUsersBox = await Hive.openBox<ShikimoriUserModel>(usersBoxName);
    return [..._shikimoriUsersBox.values];
  }

  /// Opens the same localhost callback AniList uses and sends the user to the
  /// Shikimori authorization page (`scope=user_rates`, mandatory for writes).
  @override
  Future<void> attemptCreateUser() async {
    _logger.i("Creating Shikimori user");
    try {
      _logger.d("Opening Shikimori login server at ${config.shikimoriRedirectUri}");
      _server = await shelfio.serve(_handleLoginRequest, 'localhost', 9999, shared: true);
    } catch (e, stackTrace) {
      _logger.e("Error attempting to open server: $e", stackTrace: stackTrace);
      await _launchAuthorizationPage();
      rethrow;
    }
    await _launchAuthorizationPage();
  }

  @override
  Future<void> updateUserInfo(User user) async {
    if (user is! ShikimoriUserModel) {
      throw StateError("UserRepositoryShikimori only stores ShikimoriUserModel, got ${user.runtimeType}");
    }
    _shikimoriUsersBox = await Hive.openBox<ShikimoriUserModel>(usersBoxName);
    if (_shikimoriUsersBox.containsKey(user.name)) {
      _logger.w("User ${user.name} already exists in the registered shikimori users, updating info");
    } else {
      _logger.i("Adding new user ${user.name} to the registered shikimori users");
    }
    await _shikimoriUsersBox.put(user.name, user);
    _loggedUserNotifier.updateUser(user);
  }

  @override
  Future<List<Anime>> getUserWatchingList(User user, {bool ignoreCache = false}) async {
    final ShikimoriUserModel account = await _authorized(user);
    final List<Anime> watching = <Anime>[];
    for (final String status in ShikimoriListStatusPolicy.shikimoriStatusesFor(ShikimoriListStatusPolicy.current)) {
      watching.addAll(await _fetchAnimeStatus(account, status));
    }
    return watching;
  }

  @override
  Future<List<Manga>> getUserReadingList(User user, {bool ignoreCache = false}) async {
    final ShikimoriUserModel account = await _authorized(user);
    final List<Manga> reading = <Manga>[];
    for (final String status in ShikimoriListStatusPolicy.shikimoriStatusesFor(ShikimoriListStatusPolicy.current)) {
      reading.addAll(await _fetchMangaStatus(account, status));
    }
    return reading;
  }

  /// Every anime bucket, in the AniList tab order. Empty buckets are omitted: a
  /// tab that cannot hold an entry is noise, and AniList only returns lists the
  /// user actually created.
  @override
  Future<Map<String, List<Anime>>> getUserAnimeLists(User user) async {
    final ShikimoriUserModel account = await _authorized(user);
    final Map<String, List<Anime>> lists = <String, List<Anime>>{};
    for (final String unified in ShikimoriListStatusPolicy.displayOrder) {
      final List<Anime> entries = <Anime>[];
      for (final String status in ShikimoriListStatusPolicy.shikimoriStatusesFor(unified)) {
        entries.addAll(await _fetchAnimeStatus(account, status));
      }
      if (entries.isNotEmpty) {
        lists[ShikimoriListStatusPolicy.displayName(unified)] = entries;
      }
    }
    return lists;
  }

  @override
  Future<Map<String, List<Manga>>> getUserMangaLists(User user) async {
    final ShikimoriUserModel account = await _authorized(user);
    final Map<String, List<Manga>> lists = <String, List<Manga>>{};
    for (final String unified in ShikimoriListStatusPolicy.displayOrder) {
      final List<Manga> entries = <Manga>[];
      for (final String status in ShikimoriListStatusPolicy.shikimoriStatusesFor(unified)) {
        entries.addAll(await _fetchMangaStatus(account, status));
      }
      if (entries.isNotEmpty) {
        lists[ShikimoriListStatusPolicy.displayName(unified)] = entries;
      }
    }
    return lists;
  }

  /// A usable token pair, refreshed (and re-persisted) when the stored access
  /// token passed its 1-day lifetime. Called by the login flow too.
  Future<ShikimoriUserModel> ensureFreshAccessToken(ShikimoriUserModel user) async {
    if (!_authService.isAccessTokenExpired(user)) return user;
    if (user.refreshToken.isEmpty) {
      _logger.w("Shikimori user ${user.name} has no refresh token, keeping the stored token");
      return user;
    }
    final ShikimoriUserModel refreshed = await _authService.withFreshAccessToken(user);
    await updateUserInfo(refreshed);
    return refreshed;
  }

  Future<ShikimoriUserModel> _authorized(User user) async {
    final ShikimoriUserModel account = _requireShikimori(user);
    return ensureFreshAccessToken(account);
  }

  ShikimoriUserModel _requireShikimori(User user) {
    if (user is ShikimoriUserModel) return user;
    throw StateError("UserRepositoryShikimori got a ${user.runtimeType}; route the call by settings.userService");
  }

  Map<String, String> _headers(ShikimoriUserModel user) {
    if (user.accessToken.isEmpty) return config.shikimoriRequestHeaders;
    return _authService.authorizationHeaders(user.accessToken);
  }

  Future<List<Anime>> _fetchAnimeStatus(ShikimoriUserModel user, String status) async {
    final List<Anime> entries = <Anime>[];
    for (int page = 1; page <= maxPagesPerStatus; page++) {
      final ApiGraphQLResponse<ShikimoriUserRatesAnimeQueryEntity> response = await _queryAnimePage(
        user,
        status: status,
        page: page,
      );
      final List<ShikimoriUserRatesAnimeQueryUserRates> rates = response.data.userRates;
      entries.addAll(rates.map((ShikimoriUserRatesAnimeQueryUserRates rate) {
        return ShikimoriAnimeModel.fromListEntry(rate.anime);
      }));
      if (rates.length < pageSize) break;
    }
    return entries;
  }

  Future<List<Manga>> _fetchMangaStatus(ShikimoriUserModel user, String status) async {
    final List<Manga> entries = <Manga>[];
    for (int page = 1; page <= maxPagesPerStatus; page++) {
      final ApiGraphQLResponse<ShikimoriUserRatesMangaQueryEntity> response = await _queryMangaPage(
        user,
        status: status,
        page: page,
      );
      final List<ShikimoriUserRatesMangaQueryUserRates> rates = response.data.userRates;
      entries.addAll(rates.map((ShikimoriUserRatesMangaQueryUserRates rate) {
        return ShikimoriMangaModel.fromListEntry(rate.manga);
      }));
      if (rates.length < pageSize) break;
    }
    return entries;
  }

  Future<ApiGraphQLResponse<ShikimoriUserRatesAnimeQueryEntity>> _queryAnimePage(
    ShikimoriUserModel user, {
    required String status,
    required int page,
  }) async {
    final ApiGraphQLResponse<ShikimoriUserRatesAnimeQueryEntity> response =
        await _shikimoriGraphQLService.query<ShikimoriUserRatesAnimeQueryEntity>(
      query: shikimori_queries.shikimoriAnimeUserRatesQuery,
      fromJson: ShikimoriUserRatesAnimeQueryEntity.fromJson,
      headers: _headers(user),
      variables: <String, dynamic>{
        "userId": user.id,
        "targetType": "Anime",
        "status": status,
        "page": page,
        "limit": pageSize,
      },
    );
    throwIfGraphQlError(response);
    return response;
  }

  Future<ApiGraphQLResponse<ShikimoriUserRatesMangaQueryEntity>> _queryMangaPage(
    ShikimoriUserModel user, {
    required String status,
    required int page,
  }) async {
    final ApiGraphQLResponse<ShikimoriUserRatesMangaQueryEntity> response =
        await _shikimoriGraphQLService.query<ShikimoriUserRatesMangaQueryEntity>(
      query: shikimori_queries.shikimoriMangaUserRatesQuery,
      fromJson: ShikimoriUserRatesMangaQueryEntity.fromJson,
      headers: _headers(user),
      variables: <String, dynamic>{
        "userId": user.id,
        "targetType": "Manga",
        "status": status,
        "page": page,
        "limit": pageSize,
      },
    );
    throwIfGraphQlError(response);
    return response;
  }

  Future<void> _launchAuthorizationPage() async {
    _logger.i("Launching Shikimori authorization URL: ${config.shikimoriOAuthUrl}");
    if (await canLaunchUrl(Uri.parse(config.shikimoriOAuthUrl))) {
      await launchUrl(Uri.parse(config.shikimoriOAuthUrl));
    } else {
      _logger.e("Could not launch ${config.shikimoriOAuthUrl}");
    }
  }

  Future<shelf.Response> _handleLoginRequest(shelf.Request request) async {
    try {
      _logger.i("Handling login request from Shikimori at ${request.requestedUri.path}");
      final String? code = request.requestedUri.queryParameters['code'];
      if (code == null || code.isEmpty) {
        return shelf.Response.badRequest(
          body: "Shikimori did not send an authorization code: ${request.requestedUri.query}",
        );
      }
      await _createUser(code);
      return shelf.Response.ok('Authorization successful. You can close this window.');
    } catch (e, stackTrace) {
      _logger.e("Error Handling login request: $e", stackTrace: stackTrace);
      return shelf.Response.internalServerError(
        body: "Something went wrong D:, please verify your internet connection and try again",
      );
    } finally {
      _logger.i("Closing Shikimori login server");
      _server.close();
    }
  }

  Future<void> _createUser(String accessCode) async {
    _logger.i("Exchanging the Shikimori authorization code");
    final ShikimoriTokenEntity token = await _authService.exchangeAuthorizationCode(accessCode);
    final ShikimoriUserModel viewer = await _viewer(
      token: token,
      expiresAt: _authService.expiresAtFor(token),
    );
    await updateUserInfo(viewer);
    _newUserNotifier.updateUser(viewer);
  }

  Future<ShikimoriUserModel> _viewer({required ShikimoriTokenEntity token, required String expiresAt}) async {
    final ApiGraphQLResponse<ShikimoriViewerQueryEntity> response =
        await _shikimoriGraphQLService.query<ShikimoriViewerQueryEntity>(
      query: shikimori_queries.shikimoriViewerQuery,
      fromJson: ShikimoriViewerQueryEntity.fromJson,
      headers: _authService.authorizationHeaders(token.accessToken),
    );
    throwIfGraphQlError(response);
    final ShikimoriViewerQueryEntityCurrentUser currentUser = response.data.currentUser;
    if (currentUser.id.isEmpty) {
      throw const ShikimoriAuthException(401, "currentUser was null: the token is not a viewer token");
    }
    return ShikimoriUserModel(
      id: currentUser.id,
      name: currentUser.nickname,
      // The account provider setting is what every factory routes on; a
      // Shikimori account must carry it from the moment it is created.
      settings: SettingsModel.empty().copyWith(userService: Service.shikimori),
      avatarImage: currentUser.avatarUrl,
      bannerImage: '',
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      accessTokenExpiresAt: expiresAt,
      profileUrl: currentUser.url,
    );
  }
}

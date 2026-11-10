// External dependencies
import 'dart:async';
import 'dart:io';
import 'package:hive_ce/hive.dart';
import 'package:logger/logger.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelfio;
import 'package:unyo/core/services/api/dto/anilist/auth_token_dto.dart';
import 'package:unyo/core/services/api/dto/anilist/media_collection_graphql_entity.dart';
import 'package:unyo/data/models/anilist/media/anilist_anime_model.dart';
import 'package:unyo/data/models/anilist/media/anilist_manga_model.dart';
import 'package:unyo/data/repositories/repository_mixin.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:url_launcher/url_launcher.dart';

//Internal dependencies
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/api/graphql/queries/anilist_queries.dart' as anilist_queries;
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/services/api/dto/anilist/viewer_graphql_entity.dart';
import 'package:unyo/core/services/api/graphql/graphql_response.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/domain/repositories/repositories.dart';
import 'package:unyo/domain/entities/user/user.dart';

class UserRepositoryAnilist with RepositoryMixin implements UserRepository {
  final Logger _logger = sl<Logger>();
  final HttpService _httpService = sl<HttpService>();
  final GraphQLService _anilistGraphQLService = sl<GraphQLService>(
    instanceName: config.anilistGraphQlService,
  );
  final UserNotifier _newUserNotifier;
  final UserNotifier _loggedUserNotifier;
  late Box<AnilistUserModel> _anilistUsersBox;

  /// The callback listener while a login is in flight, `null` once it is closed
  /// (or before the first login).
  HttpServer? _server;

  /// The last listener's close, kept so a later [closeLoginServer] or
  /// [attemptCreateUser] can await it: the success path closes fire-and-forget.
  Future<void>? _serverClose;

  /// How long the shared `:9999` callback may sit without a successful login
  /// before it closes itself (WP #163). An abandoned login must not keep the
  /// port bound for the Shikimori twin.
  final Duration _loginServerTimeout;

  /// Reaps the login that owns the current [_server]. Cancelled by
  /// [_closeLoginServer], and replaced by the next [attemptCreateUser].
  Timer? _loginServerTimer;

  UserRepositoryAnilist(
    this._newUserNotifier,
    this._loggedUserNotifier, {
    Duration loginServerTimeout = const Duration(minutes: 10),
  }) : _loginServerTimeout = loginServerTimeout;

  @override
  Future<List<User>> fetchAllLoggedInUsers() async {
    _anilistUsersBox = await Hive.openBox<AnilistUserModel>("anilistUsers");
    return [..._anilistUsersBox.values];
  }

  @override
  Future<void> attemptCreateUser() async {
    _logger.i("Creating Anilist user");
    // LoginCubit re-invokes this on every dialog confirm: close the previous
    // shared listener first, or it stays bound forever and its timer would
    // later close the new one.
    await _closeLoginServer();
    try {
      _logger.d("Opening Anilist login server at http://localhost:9999");
      _server = await shelfio.serve(_handleLoginRequest, 'localhost', 9999, shared: true);
      _loginServerTimer = Timer(_loginServerTimeout, () {
        _logger.i("Anilist login server timed out, closing it");
        unawaited(_closeLoginServer());
      });
    } catch (e, stackTrace) {
      _logger.e("Error attempting to open server: $e", stackTrace: stackTrace);
      if (await canLaunchUrl(Uri.parse(config.anilistAuthUrl))) {
        await launchUrl(Uri.parse(config.anilistAuthUrl));
      } else {
        _logger.e("Could not launch ${config.anilistAuthUrl}");
      }
      rethrow;
    }

    _logger.i("Launching Anilist authorization URL: ${config.anilistAuthUrl}");
    if (await canLaunchUrl(Uri.parse(config.anilistAuthUrl))) {
      await launchUrl(Uri.parse(config.anilistAuthUrl));
    } else {
      _logger.e("Could not launch ${config.anilistAuthUrl}");
    }
  }

  @override
  Future<void> updateUserInfo(User user) async {
    _anilistUsersBox = await Hive.openBox<AnilistUserModel>("anilistUsers");
    if (_anilistUsersBox.containsKey(user.name)) {
      _logger.w("User ${user.name} already exists in the registered anilist users, updating info");
      await _anilistUsersBox.put(user.name, user as AnilistUserModel);
    } else {
      _logger.i("Adding new user ${user.name} to the registered anilist users");
      await _anilistUsersBox.put(user.name, user as AnilistUserModel);
    }
    _loggedUserNotifier.updateUser(user);
  }

  @override
  Future<List<Anime>> getUserWatchingList(User user, {bool ignoreCache = false}) async {
    Map<String, String> graphQlHeaders = {
      "Authorization": "Bearer ${(user as AnilistUserModel).accessToken}",
    };
    ApiGraphQLResponse<MediaCollectionGraphqlDtoData> mediaCollection = await _anilistGraphQLService
        .query<MediaCollectionGraphqlDtoData>(
          query: anilist_queries.mediaListCollectionQuery,
          fromJson: MediaCollectionGraphqlDtoData.fromJson,
          variables: {"userName": user.name, "userId": user.id, "type": "ANIME"},
          headers: graphQlHeaders,
          ignoreCache: ignoreCache
        );
    throwIfGraphQlError(mediaCollection);
    MediaCollectionGraphqlDtoDataMediaListCollectionLists? watchingList =
        mediaCollection.data.mediaListCollection.lists
            .where((collection) => collection.name == "Watching")
            .firstOrNull;
    List<MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia> mediaEntries =
        watchingList?.entries
            .map((entry) => entry.media)
            .toList() ?? [];
    return mediaEntries.map((mediaEntry) => AnilistAnimeModel.fromUserMediaEntry(mediaEntry)).toList();
  }

  @override
  Future<List<Manga>> getUserReadingList(User user, {bool ignoreCache = false}) async {
    Map<String, String> graphQlHeaders = {
      "Authorization": "Bearer ${(user as AnilistUserModel).accessToken}",
    };
    ApiGraphQLResponse<MediaCollectionGraphqlDtoData> mediaCollection = await _anilistGraphQLService
        .query<MediaCollectionGraphqlDtoData>(
          query: anilist_queries.mediaListCollectionQuery,
          fromJson: MediaCollectionGraphqlDtoData.fromJson,
          variables: {"userName": user.name, "userId": user.id, "type": "MANGA"},
          headers: graphQlHeaders,
          ignoreCache: ignoreCache
        );
    throwIfGraphQlError(mediaCollection);
    MediaCollectionGraphqlDtoDataMediaListCollectionLists? readingList =
        mediaCollection.data.mediaListCollection.lists
            .where((collection) => collection.name == "Reading")
            .firstOrNull;
    List<MediaCollectionGraphqlDtoDataMediaListCollectionListsEntriesMedia> mediaEntries =
        readingList?.entries
            .map((entry) => entry.media)
            .toList() ?? [];
    return mediaEntries.map((mediaEntry) => AnilistMangaModel.fromUserMediaEntry(mediaEntry)).toList();
  }

  @override
  Future<Map<String, List<Anime>>> getUserAnimeLists(User user) async {
    Map<String, String> graphQlHeaders = {
      "Authorization": "Bearer ${(user as AnilistUserModel).accessToken}",
    };
    ApiGraphQLResponse<MediaCollectionGraphqlDtoData> mediaCollection = await _anilistGraphQLService
        .query<MediaCollectionGraphqlDtoData>(
          query: anilist_queries.mediaListCollectionQuery,
          fromJson: MediaCollectionGraphqlDtoData.fromJson,
          variables: {"userName": user.name, "userId": user.id, "type": "ANIME"},
          headers: graphQlHeaders,
        );
    throwIfGraphQlError(mediaCollection);
    Map<String, List<Anime>> userAnimeLists = Map.fromEntries(
      mediaCollection.data.mediaListCollection.lists.map(
        (collection) => MapEntry(
          collection.name,
          collection.entries.map((entry) => AnilistAnimeModel.fromUserMediaEntry(entry.media)).toList()
              as List<Anime>,
        ),
      ),
    );
    return userAnimeLists;
  }

  @override
  Future<Map<String, List<Manga>>> getUserMangaLists(User user) async {
    Map<String, String> graphQlHeaders = {
      "Authorization": "Bearer ${(user as AnilistUserModel).accessToken}",
    };
    ApiGraphQLResponse<MediaCollectionGraphqlDtoData> mediaCollection = await _anilistGraphQLService
        .query<MediaCollectionGraphqlDtoData>(
          query: anilist_queries.mediaListCollectionQuery,
          fromJson: MediaCollectionGraphqlDtoData.fromJson,
          variables: {"userName": user.name, "userId": user.id, "type": "MANGA"},
          headers: graphQlHeaders,
        );
    throwIfGraphQlError(mediaCollection);
    Map<String, List<Manga>> userMangaLists = Map.fromEntries(
      mediaCollection.data.mediaListCollection.lists.map(
        (collection) => MapEntry(
          collection.name,
          collection.entries.map((entry) => AnilistMangaModel.fromUserMediaEntry(entry.media)).toList()
              as List<Manga>,
        ),
      ),
    );
    return userMangaLists;
  }

  Future<ApiResponse<AuthTokenEntity>> getAuthToken(String accessCode) async {
    Map<String, dynamic> body = {
      "grant_type": "authorization_code",
      "client_id": config.anilistClientId,
      "client_secret": config.anilistClientSecret,
      "redirect_uri": config.anilistRedirectUri,
      "code": accessCode,
    };
    return _httpService.post<AuthTokenEntity>(
      config.anilistOAuthEndpoint,
      fromJson: AuthTokenEntity.fromJson,
      body: body,
    );
  }

  /// Closes the OAuth callback server and cancels the abandonment timer.
  ///
  /// Safe before a server was ever started and safe to call any number of
  /// times. The socket close is returned rather than awaited by the callers
  /// inside [_handleLoginRequest]/the timer: `HttpServer.close()` (force: false)
  /// waits for the in-flight response, so awaiting it from the handler would
  /// deadlock until the client gave up.
  Future<void> _closeLoginServer() {
    _loginServerTimer?.cancel();
    _loginServerTimer = null;
    final HttpServer? server = _server;
    if (server != null) {
      _server = null;
      _serverClose = server.close();
    }
    return _serverClose ?? Future<void>.value();
  }

  /// Closes the OAuth callback server early. Safe before the login server was
  /// started and idempotent; used by tests/teardown.
  Future<void> closeLoginServer() => _closeLoginServer();

  Future<shelf.Response> _handleLoginRequest(shelf.Request request) async {
    try {
      _logger.i("Handling login request from Anilist at ${request.requestedUri.path}");
      final String? accessCode = request.requestedUri.queryParameters['code'];
      if (accessCode == null || accessCode.isEmpty) {
        // WP #163: a favicon/probe/mistyped URL is not a login attempt. Answer
        // 400 and keep serving — a code-less GET used to throw into the 500
        // path and close the server, killing the OAuth redirect.
        return shelf.Response.badRequest(
          body: "Anilist did not send an authorization code: ${request.requestedUri.query}",
        );
      }
      await _createUser(accessCode);
    } catch (e, stackTrace) {
      // Keep serving on a failed exchange: the redirect can be replayed.
      _logger.e("Error Handling login request: $e", stackTrace: stackTrace);
      return shelf.Response.internalServerError(
        body: "Something went wrong D:, please verify your internet connection and try again",
      );
    }
    _logger.i("Closing Anilist login server");
    unawaited(_closeLoginServer());
    return shelf.Response.ok('Authorization successful. You can close this window.');
  }

  Future<void> _createUser(String accessCode) async {
    _anilistUsersBox = await Hive.openBox<AnilistUserModel>("anilistUsers");
    ApiResponse<AuthTokenEntity> authToken = await getAuthToken(accessCode);
    Map<String, String> graphQlHeaders = {"Authorization": "Bearer ${authToken.data.accessToken}"};
    ApiGraphQLResponse<ViewerGraphqlEntity> viewerDto = await _anilistGraphQLService
        .query<ViewerGraphqlEntity>(
          query: anilist_queries.viewerQuery,
          fromJson: ViewerGraphqlEntity.fromJson,
          headers: graphQlHeaders,
        );
    throwIfGraphQlError(viewerDto);
    AnilistUserModel newAnilistUser = AnilistUserModel(
      id: viewerDto.data.viewer.id.toString(),
      name: viewerDto.data.viewer.name,
      // WP #164: a new account browses through its own provider. AniList is in
      // ProviderCapabilities.metadataProviders, so both roles are the same.
      settings: SettingsModel.empty().copyWith(
        userService: Service.anilist,
        metadataService: Service.anilist,
      ),
      avatarImage: viewerDto.data.viewer.avatar.medium,
      bannerImage: viewerDto.data.viewer.bannerImage,
      accessCode: accessCode,
      accessToken: authToken.data.accessToken,
      refreshToken: authToken.data.refreshToken,
    );
    await updateUserInfo(newAnilistUser);
    _newUserNotifier.updateUser(newAnilistUser);
  }
}

// External dependencies
import 'dart:convert';
import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelfio;
import 'package:url_launcher/url_launcher.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/api/dto/mal/mal_token_entity.dart';
import 'package:unyo/core/services/api/dto/mal/mal_user_entity.dart';
import 'package:unyo/core/services/api/dto/mal/mal_user_list_entity.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/api/mal/mal_auth_service.dart';
import 'package:unyo/data/models/mal/media/mal_list_status_policy.dart';
import 'package:unyo/core/services/api/mal/mal_rate_limiter.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/airing_episode.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/title.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/user_repository.dart';

/// MyAnimeList **account** provider (WP #156).
///
/// Mirrors `UserRepositoryShikimori`: a localhost shelf server catches the
/// OAuth redirect, the code is swapped for a token pair, `GET /users/@me` names
/// the account, and the model goes to its own Hive box. Lists come from
/// `GET /users/@me/{animelist,mangalist}`; entry writes go through
/// `MalUserRateService`.
///
/// Differences from the Shikimori twin, deliberate:
///
/// * **own port** (D1): the redirect is `http://localhost:9998/mal-auth` —
///   AniList + Shikimori share `:9999`, a third shelf on that port risks the
///   kernel delivering the redirect to the wrong handler;
/// * **PKCE** (D2): the authorize URL carries a generated `code_verifier`
///   (`plain`) and a CSRF `state`, both verified on the way back;
/// * the read transport is `package:http` (JSON GETs), not `HttpService`:
///   `ignoreCache` is trivially satisfied (there is no 20-minute cache), which
///   is exactly the WP #110 cache-busting contract the home reload needs, and
///   it keeps one transport across the MAL stack (`MalAuthService` bypasses
///   `HttpService` too, its token endpoint is form-urlencoded).
///
/// Status folding lives in [MalListStatusPolicy]; the shared request budget in
/// [MalRateLimiter] (≤ 2 req/s — MAL answers 403 when throttled).
class UserRepositoryMal implements UserRepository {
  /// MAL's `limit` cap (the docs default to 100), so one page is one request.
  static const int pageSize = 1000;

  /// Safety stop so a runaway pagination can never turn into a hot loop:
  /// 40 pages = 40 000 entries per status.
  static const int maxPagesPerStatus = 40;

  static const String usersBoxName = "malUsers";

  /// Node fields the list fetches request (the default payload is only
  /// id/title/main_picture). `list_status` is mandatory — without it the
  /// status object is omitted from every node.
  static const String animeListFields =
      'list_status,alternative_titles,start_date,end_date,mean,num_episodes,media_type,status,genres,nsfw,popularity';
  static const String mangaListFields =
      'list_status,alternative_titles,start_date,end_date,mean,num_volumes,num_chapters,media_type,status,genres,nsfw,popularity';

  final Logger _logger = sl<Logger>();
  final MalAuthService _authService = sl<MalAuthService>();
  MalRateLimiter get _rateLimiter => sl<MalRateLimiter>();
  final UserNotifier _newUserNotifier;
  final UserNotifier _loggedUserNotifier;
  final http.Client _client;
  late Box<MalUserModel> _malUsersBox;
  late HttpServer _server;

  /// The PKCE pair of the login currently in flight (D2). Kept on the instance
  /// because the authorize URL and the token exchange must agree on it.
  String _codeVerifier = '';
  String _state = '';

  UserRepositoryMal(this._newUserNotifier, this._loggedUserNotifier, {http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<User>> fetchAllLoggedInUsers() async {
    _malUsersBox = await Hive.openBox<MalUserModel>(usersBoxName);
    return [..._malUsersBox.values];
  }

  /// Opens the MAL callback on its own port and sends the user to the
  /// authorization page (`scope=write:users`, mandatory for list writes).
  @override
  Future<void> attemptCreateUser() async {
    _logger.i("Creating MyAnimeList user");
    _codeVerifier = _authService.generateCodeVerifier();
    _state = _authService.generateState();
    final Uri redirect = Uri.parse(config.malRedirectUri);
    try {
      _logger.d("Opening MyAnimeList login server at ${config.malRedirectUri}");
      // D1: own port, no `shared` — the AniList/Shikimori shelf owns :9999.
      _server = await shelfio.serve(_handleLoginRequest, redirect.host, redirect.port);
    } catch (e, stackTrace) {
      _logger.e("Error attempting to open server: $e", stackTrace: stackTrace);
      await _launchAuthorizationPage();
      rethrow;
    }
    await _launchAuthorizationPage();
  }

  @override
  Future<void> updateUserInfo(User user) async {
    if (user is! MalUserModel) {
      throw StateError("UserRepositoryMal only stores MalUserModel, got ${user.runtimeType}");
    }
    _malUsersBox = await Hive.openBox<MalUserModel>(usersBoxName);
    if (_malUsersBox.containsKey(user.name)) {
      _logger.w("User ${user.name} already exists in the registered MyAnimeList users, updating info");
    } else {
      _logger.i("Adding new user ${user.name} to the registered MyAnimeList users");
    }
    await _malUsersBox.put(user.name, user);
    _loggedUserNotifier.updateUser(user);
  }

  @override
  /// [ignoreCache] is accepted for interface parity: these reads never cache
  /// (see the class comment), so a forced reload is the default behaviour.
  Future<List<Anime>> getUserWatchingList(User user, {bool ignoreCache = false}) async {
    final MalUserModel account = await _authorized(user);
    final List<Anime> watching = <Anime>[];
    for (final String status in MalListStatusPolicy.malStatusesFor(
      MalListStatusPolicy.current,
      target: MalListTarget.anime,
    )) {
      watching.addAll(await _fetchAnimeStatus(account, status));
    }
    return watching;
  }

  @override
  Future<List<Manga>> getUserReadingList(User user, {bool ignoreCache = false}) async {
    final MalUserModel account = await _authorized(user);
    final List<Manga> reading = <Manga>[];
    for (final String status in MalListStatusPolicy.malStatusesFor(
      MalListStatusPolicy.current,
      target: MalListTarget.manga,
    )) {
      reading.addAll(await _fetchMangaStatus(account, status));
    }
    return reading;
  }

  /// Every anime bucket, in the AniList tab order. Empty buckets are omitted: a
  /// tab that cannot hold an entry is noise, and AniList only returns lists the
  /// user actually created.
  @override
  Future<Map<String, List<Anime>>> getUserAnimeLists(User user) async {
    final MalUserModel account = await _authorized(user);
    final Map<String, List<Anime>> lists = <String, List<Anime>>{};
    for (final String unified in MalListStatusPolicy.displayOrder) {
      final List<Anime> entries = <Anime>[];
      for (final String status in MalListStatusPolicy.malStatusesFor(
        unified,
        target: MalListTarget.anime,
      )) {
        entries.addAll(await _fetchAnimeStatus(account, status));
      }
      if (entries.isNotEmpty) {
        lists[MalListStatusPolicy.displayName(unified)] = entries;
      }
    }
    return lists;
  }

  @override
  Future<Map<String, List<Manga>>> getUserMangaLists(User user) async {
    final MalUserModel account = await _authorized(user);
    final Map<String, List<Manga>> lists = <String, List<Manga>>{};
    for (final String unified in MalListStatusPolicy.displayOrder) {
      final List<Manga> entries = <Manga>[];
      for (final String status in MalListStatusPolicy.malStatusesFor(
        unified,
        target: MalListTarget.manga,
      )) {
        entries.addAll(await _fetchMangaStatus(account, status));
      }
      if (entries.isNotEmpty) {
        lists[MalListStatusPolicy.displayName(unified)] = entries;
      }
    }
    return lists;
  }

  /// A usable token pair, refreshed (and re-persisted) when the stored access
  /// token passed its lifetime. Called by the login flow too.
  Future<MalUserModel> ensureFreshAccessToken(MalUserModel user) async {
    if (!_authService.isAccessTokenExpired(user)) return user;
    if (user.refreshToken.isEmpty) {
      _logger.w("MyAnimeList user ${user.name} has no refresh token, keeping the stored token");
      return user;
    }
    final MalUserModel refreshed = await _authService.withFreshAccessToken(user);
    await updateUserInfo(refreshed);
    return refreshed;
  }

  Future<MalUserModel> _authorized(User user) async {
    final MalUserModel account = _requireMal(user);
    return ensureFreshAccessToken(account);
  }

  MalUserModel _requireMal(User user) {
    if (user is MalUserModel) return user;
    throw StateError("UserRepositoryMal got a ${user.runtimeType}; route the call by settings.userService");
  }

  Future<List<Anime>> _fetchAnimeStatus(MalUserModel user, String status) async {
    final List<Anime> entries = <Anime>[];
    for (int page = 0; page < maxPagesPerStatus; page++) {
      final MalUserListEntity response = await _queryListPage(
        user,
        target: MalListTarget.anime,
        status: status,
        offset: page * pageSize,
      );
      entries.addAll(response.data.map((MalUserListEntityData entry) => _toAnime(entry.node)));
      if (response.data.length < pageSize) break;
      if (response.paging.next.isEmpty) break;
    }
    return entries;
  }

  Future<List<Manga>> _fetchMangaStatus(MalUserModel user, String status) async {
    final List<Manga> entries = <Manga>[];
    for (int page = 0; page < maxPagesPerStatus; page++) {
      final MalUserListEntity response = await _queryListPage(
        user,
        target: MalListTarget.manga,
        status: status,
        offset: page * pageSize,
      );
      entries.addAll(response.data.map((MalUserListEntityData entry) => _toManga(entry.node)));
      if (response.data.length < pageSize) break;
      if (response.paging.next.isEmpty) break;
    }
    return entries;
  }

  Future<MalUserListEntity> _queryListPage(
    MalUserModel user, {
    required MalListTarget target,
    required String status,
    required int offset,
  }) async {
    final String fields =
        target == MalListTarget.anime ? animeListFields : mangaListFields;
    final Uri uri = Uri.parse('${config.malApiBase}/users/@me/${target.wireValue}list')
        .replace(queryParameters: <String, String>{
      'status': status,
      'fields': fields,
      'limit': pageSize.toString(),
      'offset': offset.toString(),
    });
    await _rateLimiter.acquire(reason: "GET users/@me/${target.wireValue}list $status");
    return MalUserListEntity.fromJson(await _getJson(uri, _authService.authorizationHeaders(user.accessToken)));
  }

  Future<Map<String, dynamic>> _getJson(Uri uri, Map<String, String> headers) async {
    final http.Request request = http.Request('GET', uri)..headers.addAll(headers);
    final http.StreamedResponse streamed = await _client.send(request);
    final http.Response response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpServerException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> _launchAuthorizationPage() async {
    final Uri url = _authService.buildAuthorizationUrl(codeVerifier: _codeVerifier, state: _state);
    _logger.i("Launching MyAnimeList authorization URL: $url");
    // A missing browser (or a headless CI) must not fail the login flow: the
    // loopback server stays open either way (style rule: degrade silently).
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
        return;
      }
      _logger.e("Could not launch $url");
    } catch (e, stackTrace) {
      _logger.e("Could not launch $url: $e", stackTrace: stackTrace);
    }
  }

  Future<shelf.Response> _handleLoginRequest(shelf.Request request) async {
    try {
      _logger.i("Handling login request from MyAnimeList at ${request.requestedUri.path}");
      final String? code = request.requestedUri.queryParameters['code'];
      if (code == null || code.isEmpty) {
        return shelf.Response.badRequest(
          body: "MyAnimeList did not send an authorization code: ${request.requestedUri.query}",
        );
      }
      final String? state = request.requestedUri.queryParameters['state'];
      if (state != _state) {
        return shelf.Response.badRequest(
          body: "MyAnimeList login state did not match the one this login started with",
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
      _logger.i("Closing MyAnimeList login server");
      _server.close();
    }
  }

  Future<void> _createUser(String accessCode) async {
    _logger.i("Exchanging the MyAnimeList authorization code");
    final MalTokenEntity token = await _authService.exchangeAuthorizationCode(
      accessCode,
      codeVerifier: _codeVerifier,
    );
    final MalUserModel account = await _profile(
      token: token,
      expiresAt: _authService.expiresAtFor(token),
    );
    await updateUserInfo(account);
    _newUserNotifier.updateUser(account);
  }

  /// `GET /users/@me` with the fresh Bearer token: the account identity the
  /// model stores (id/name/avatar; MAL has no banner).
  Future<MalUserModel> _profile({required MalTokenEntity token, required String expiresAt}) async {
    await _rateLimiter.acquire(reason: "GET users/@me");
    final Map<String, dynamic> json = await _getJson(
      Uri.parse('${config.malApiBase}/users/@me'),
      _authService.authorizationHeaders(token.accessToken),
    );
    final MalUserEntity me = MalUserEntity.fromJson(json);
    if (me.name.isEmpty) {
      throw const MalAuthException(401, "users/@me was empty: the token is not a viewer token");
    }
    return MalUserModel(
      id: me.id.toString(),
      name: me.name,
      // The account provider setting is what every factory routes on; a
      // MyAnimeList account must carry it from the moment it is created.
      settings: SettingsModel.empty().copyWith(userService: Service.mal),
      avatarImage: me.picture,
      bannerImage: '',
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      accessTokenExpiresAt: expiresAt,
      profileUrl: 'https://myanimelist.net/profile/${me.name}',
    );
  }

  Anime _toAnime(MalUserListEntityDataNode node) {
    return AnimeModel(
      // WP #156 D3: the list carries MAL ids; MediaMappingRepositoryMal (wave 6)
      // is what translates to the metadata provider's id space for details.
      id: node.id,
      idMal: node.id,
      title: _title(node),
      averageScore: _scoreOutOfHundred(node.mean),
      bannerImage: '',
      countryOfOrigin: 'JP',
      coverImage: _coverImage(node),
      description: '',
      duration: 0,
      endDate: _date(node.endDate),
      startDate: _date(node.startDate),
      episodes: node.numEpisodes,
      genres: node.genres.map((MalUserListEntityDataNodeGenres genre) => genre.name).toList(),
      format: _format(node.mediaType),
      isAdult: _isAdult(node.nsfw),
      popularity: node.popularity,
      meanScore: _scoreOutOfHundred(node.mean),
      season: '',
      isFavourite: false,
      status: _status(node.status),
      nextAiringEpisode: AiringEpisodeModel.empty(),
    );
  }

  Manga _toManga(MalUserListEntityDataNode node) {
    return MangaModel(
      id: node.id,
      idMal: node.id,
      title: _title(node),
      averageScore: _scoreOutOfHundred(node.mean),
      bannerImage: '',
      chapters: node.numChapters,
      countryOfOrigin: 'JP',
      coverImage: _coverImage(node),
      description: '',
      endDate: _date(node.endDate),
      startDate: _date(node.startDate),
      genres: node.genres.map((MalUserListEntityDataNodeGenres genre) => genre.name).toList(),
      format: _format(node.mediaType),
      isAdult: _isAdult(node.nsfw),
      popularity: node.popularity,
      meanScore: _scoreOutOfHundred(node.mean),
      status: _status(node.status),
      isFavourite: false,
    );
  }

  TitleModel _title(MalUserListEntityDataNode node) {
    final String english = node.alternativeTitles.en.trim();
    final String native = node.alternativeTitles.ja.trim();
    String preferred = node.title.trim();
    if (preferred.isEmpty) preferred = english;
    if (preferred.isEmpty) preferred = native;
    return TitleModel(
      romaji: node.title,
      english: english,
      nativeTitle: native,
      userPreferred: preferred,
    );
  }

  String _coverImage(MalUserListEntityDataNode node) {
    if (node.mainPicture.large.trim().isNotEmpty) return node.mainPicture.large;
    return node.mainPicture.medium;
  }

  /// MAL scores are 0–10 floats; the domain's `averageScore`/`meanScore` are
  /// 0–100 ints (AniList scale), same as the Shikimori mapper.
  int _scoreOutOfHundred(double score) {
    if (score <= 0) return 0;
    return (score * 10).round();
  }

  /// `2012-07-01` → `1/7/2012`, the shape the Shikimori/AniList mappers produce.
  String _date(String isoDate) {
    final DateTime? parsed = DateTime.tryParse(isoDate.trim());
    if (parsed == null) return "0/0/0";
    return "${parsed.day}/${parsed.month}/${parsed.year}";
  }

  /// MAL `media_type` (`tv`/`movie`/`ova`/`manga`/`novel`/…) → the AniList
  /// format vocabulary the domain uses (same normalisation as
  /// `ShikimoriMediaMapper.animeFormat`).
  String _format(String mediaType) {
    switch (mediaType.trim().toLowerCase()) {
      case 'tv':
        return 'TV';
      case 'movie':
        return 'MOVIE';
      case 'ova':
        return 'OVA';
      case 'ona':
        return 'ONA';
      case 'special':
        return 'SPECIAL';
      case 'music':
        return 'MUSIC';
      case 'manga':
        return 'MANGA';
      case 'novel':
        return 'NOVEL';
      case 'one_shot':
        return 'ONE_SHOT';
      default:
        return mediaType.toUpperCase();
    }
  }

  /// MAL airing/publishing status → the AniList vocabulary
  /// (`finished_airing` → `FINISHED`, `not_yet_published` → `NOT_YET_RELEASED`).
  String _status(String status) {
    switch (status.trim().toLowerCase()) {
      case 'finished_airing':
      case 'finished_publishing':
        return 'FINISHED';
      case 'currently_airing':
      case 'currently_publishing':
        return 'RELEASING';
      case 'not_yet_aired':
      case 'not_yet_published':
        return 'NOT_YET_RELEASED';
      default:
        return status.toUpperCase();
    }
  }

  /// MAL `nsfw` is a tier: `white` is safe, `gray`/`black` are not.
  bool _isAdult(String nsfw) {
    final String tier = nsfw.trim().toLowerCase();
    return tier == 'gray' || tier == 'black';
  }
}

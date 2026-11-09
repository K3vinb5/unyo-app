import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/dto/jikan/jikan_media_entity.dart';
import 'package:unyo/core/services/api/dto/jikan/jikan_schedule_entity.dart';
import 'package:unyo/core/services/api/dto/mal/mal_anime_node.dart';
import 'package:unyo/core/services/api/dto/mal/mal_manga_node.dart';
import 'package:unyo/core/services/api/dto/mal/mal_media_list_entity.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/api/jikan/jikan_rate_limiter.dart';
import 'package:unyo/core/services/api/mal/mal_auth_service.dart';
import 'package:unyo/core/services/api/mal/mal_metadata_vocabularies.dart';
import 'package:unyo/core/services/api/mal/mal_rate_limiter.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';

/// Read-only MyAnimeList metadata transport (WP #166).
///
/// Mirrors `MalUserRateService`'s shape: injectable `http.Client`, lazy
/// `sl<>` lookups for the auth service and the shared [MalRateLimiter], plain
/// JSON GETs, non-2xx surfaced through [HttpServerException].
///
/// ## Rules this class encodes (SPEC §2/§4)
///
/// * **every** `api.myanimelist.net` read carries `X-MAL-CLIENT-ID` — MAL's v2
///   answers **403** to an anonymous read without it (probed live), so the
///   public client id is not optional, and `Authorization: Bearer` is added
///   **only** when a [MalUserModel] with a token is passed (personalises
///   `my_list_status`);
/// * **every** `api.myanimelist.net` read takes a grant from [MalRateLimiter]
///   first — the same budget the tracker writes use (2 rps, 403 = throttle);
/// * `fields=` is always explicit. The constants below are the only field sets,
///   so a metadata read never depends on MAL's trimmed-by-default answer;
/// * `/anime` and `/manga` are **not called at all**: their only accepted
///   input is a required `q` (probed: `400 {"message":"invalid q"}`) plus
///   paging and `fields`, and status/type/genre/sort are silently ignored
///   (probed: `status=not_yet_aired` answered `finished_airing` rows). Catalog
///   browse and search therefore run on Jikan, which filters;
/// * adult content is excluded by `sfw=true` on the Jikan reads when the caller
///   forbids it and left to Jikan's own default when it allows it, and is
///   additionally gated client-side per node (`rating`/`explicit_genres`); the
///   ranking endpoints have no such parameter, so that gate is the only one
///   there;
/// * `page`/`limit` are the caller's units: `offset = (page - 1) * limit` on
///   MAL, a 1-based `page` and a 25-capped `limit` on Jikan.
///
/// ## Jikan
///
/// MAL v2 has no schedule endpoint and cannot filter or order a catalog, so
/// [getSchedules] and the [getJikanAnimeList]/[getJikanMangaList] feeds are
/// served by Jikan — a third-party mirror of MyAnimeList — which can filter
/// (`q`, `type`, `status`, `rating`, `genres`, `order_by`, `sort`). Jikan is
/// **not** MyAnimeList: it has its own rate limits (3/s, 60/min) and serves
/// public data anonymously, so it takes a [JikanRateLimiter] grant (never a
/// [MalRateLimiter] one) and no MAL headers. It is read-only and every call is
/// listed here — nothing else may use it (SPEC §2/§4).
class MalMetadataService {
  static const int defaultLimit = 50;

  /// MAL's documented hard cap for `/anime` and `/manga`.
  static const int maxLimit = 100;

  /// Jikan's `/v4/schedules` endpoint — the weekly calendar.
  static const String jikanScheduleEndpoint = 'https://api.jikan.moe/v4/schedules';

  /// Jikan's filtered anime catalog (`/v4/anime`).
  static const String jikanAnimeEndpoint = 'https://api.jikan.moe/v4/anime';

  /// Jikan's filtered manga catalog (`/v4/manga`).
  static const String jikanMangaEndpoint = 'https://api.jikan.moe/v4/manga';

  /// Jikan caps `limit` at 25 on every list endpoint.
  static const int jikanMaxLimit = 25;

  /// Carousel/search node fields: exactly what [MalAnimeModel] fills.
  static const String animeListFields =
      'id,title,main_picture,alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,'
      'media_type,status,genres,nsfw,rating,num_episodes,start_season,average_episode_duration,broadcast';

  /// Details fields: the list set plus `my_list_status`, relations and studios
  /// (the official sample field list).
  static const String animeDetailsFields =
      'id,title,main_picture,alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,'
      'num_list_users,num_scoring_users,nsfw,created_at,updated_at,media_type,status,genres,'
      'my_list_status,num_episodes,start_season,broadcast,source,average_episode_duration,rating,'
      'pictures,background,related_anime,related_manga,recommendations,studios,statistics';

  /// Manga carousel/search node fields (no season/broadcast, chapter counters).
  ///
  /// No `rating`: that field is anime-only in the v2 reference (manga details
  /// sample omits it), so requesting it risks a 400 on every manga list call.
  /// Adult titles are read from `nsfw` (`black`) instead.
  static const String mangaListFields =
      'id,title,main_picture,alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,'
      'media_type,status,genres,nsfw,num_volumes,num_chapters';

  /// Manga details fields: the list set plus `my_list_status` and relations.
  static const String mangaDetailsFields =
      'id,title,main_picture,alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,'
      'num_list_users,num_scoring_users,nsfw,created_at,updated_at,media_type,status,genres,'
      'my_list_status,num_volumes,num_chapters,authors{first_name,last_name},pictures,background,'
      'related_anime,related_manga,recommendations,serialization{name}';

  final http.Client _client;
  final Logger _logger = sl<Logger>();

  /// Jikan's own budget; one instance per service (see [JikanRateLimiter]).
  final JikanRateLimiter _jikanRateLimiter;

  /// Shared MyAnimeList budget; lazy so pure-mapping tests need not register it.
  MalRateLimiter get _rateLimiter => sl<MalRateLimiter>();
  MalAuthService get _authService => sl<MalAuthService>();

  MalMetadataService({http.Client? client, JikanRateLimiter? jikanRateLimiter})
      : _client = client ?? http.Client(),
        _jikanRateLimiter = jikanRateLimiter ?? JikanRateLimiter();

  // ------------------------------------------------------------------ anime

  /// `GET /anime/ranking?ranking_type=…` — `airing` is the closest MAL
  /// equivalent of AniList's trending feed (SPEC §2).
  Future<MalAnimeListEntity> getAnimeRanking(
    String rankingType, {
    int page = 1,
    int limit = defaultLimit,
    MalUserModel? user,
  }) async {
    _validateRankingType(rankingType, MalMetadataVocabularies.animeRankingTypes);
    final Uri uri = _listUri(
      path: 'anime/ranking',
      query: <String, String>{
        'ranking_type': rankingType,
        ..._pagingQuery(page, limit),
        'fields': animeListFields,
      },
    );
    return MalAnimeListEntity.fromJson(
      await _getJson(uri, user: user, reason: 'GET anime/ranking $rankingType'),
    );
  }

  /// `GET /anime/{id}` with the full details field set.
  Future<MalAnimeNode> getAnimeDetails(int id, [MalUserModel? user]) async {
    _validateId(id);
    final Uri uri = Uri.parse('${config.malApiBase}/anime/$id')
        .replace(queryParameters: <String, String>{'fields': animeDetailsFields});
    return MalAnimeNode.fromJson(
      await _getJson(uri, user: user, reason: 'GET anime/$id details'),
    );
  }

  // ------------------------------------------------------------------ manga

  /// `GET /manga/ranking?ranking_type=…`.
  ///
  /// The reference table lists nine ranking types; `publishing` and `upcoming`
  /// are **not** among them (probed live: `400 invalid ranking_type`), so no
  /// method here asks for them — the manga browse feeds that would need those
  /// filters are served by [getJikanMangaList] (SPEC §2).
  Future<MalMangaListEntity> getMangaRanking(
    String rankingType, {
    int page = 1,
    int limit = defaultLimit,
    MalUserModel? user,
  }) async {
    _validateRankingType(rankingType, MalMetadataVocabularies.mangaRankingTypes);
    final Uri uri = _listUri(
      path: 'manga/ranking',
      query: <String, String>{
        'ranking_type': rankingType,
        ..._pagingQuery(page, limit),
        'fields': mangaListFields,
      },
    );
    return MalMangaListEntity.fromJson(
      await _getJson(uri, user: user, reason: 'GET manga/ranking $rankingType'),
    );
  }

  /// `GET /manga/{id}` with the full details field set.
  Future<MalMangaNode> getMangaDetails(int id, [MalUserModel? user]) async {
    _validateId(id);
    final Uri uri = Uri.parse('${config.malApiBase}/manga/$id')
        .replace(queryParameters: <String, String>{'fields': mangaDetailsFields});
    return MalMangaNode.fromJson(
      await _getJson(uri, user: user, reason: 'GET manga/$id details'),
    );
  }

  // ----------------------------------------------------------------- Jikan

  /// One `GET https://api.jikan.moe/v4/anime` page — the only place the app can
  /// **filter and order** a catalog (MAL v2 `/anime` accepts `q` + paging only;
  /// SPEC §2).
  ///
  /// Every argument is optional and an absent/blank one is simply not sent, so
  /// `q` empty means "browse". `page` is 1-based, `limit` is clamped to
  /// [jikanMaxLimit]. `nsfwAllowed == false` adds `sfw=true`, which excludes
  /// adult entries server-side; when the user allows them the parameter is
  /// omitted (Jikan's default includes every entry).
  Future<JikanMediaListEntity> getJikanAnimeList({
    String? q,
    String? status,
    String? type,
    String? rating,
    List<int>? genreIds,
    String? orderBy,
    String? sort,
    bool? nsfwAllowed,
    int page = 1,
    int limit = jikanMaxLimit,
  }) {
    return _getJikanList(
      jikanAnimeEndpoint,
      reason: 'GET jikan anime',
      filters: <String, String?>{
        'q': q,
        'type': type,
        'status': status,
        'rating': rating,
        'order_by': orderBy,
        'sort': sort,
        'genres': _genreQuery(genreIds),
      },
      nsfwAllowed: nsfwAllowed,
      page: page,
      limit: limit,
    );
  }

  /// One `GET https://api.jikan.moe/v4/manga` page (see [getJikanAnimeList]).
  /// Manga has no `rating` filter — adult entries are excluded by `sfw` only.
  Future<JikanMediaListEntity> getJikanMangaList({
    String? q,
    String? status,
    String? type,
    List<int>? genreIds,
    String? orderBy,
    String? sort,
    bool? nsfwAllowed,
    int page = 1,
    int limit = jikanMaxLimit,
  }) {
    return _getJikanList(
      jikanMangaEndpoint,
      reason: 'GET jikan manga',
      filters: <String, String?>{
        'q': q,
        'type': type,
        'status': status,
        'order_by': orderBy,
        'sort': sort,
        'genres': _genreQuery(genreIds),
      },
      nsfwAllowed: nsfwAllowed,
      page: page,
      limit: limit,
    );
  }

  /// `GET https://api.jikan.moe/v4/schedules` — the calendar feed.
  ///
  /// [day] is a Jikan weekday filter (`monday` … `sunday`, or `unknown`/
  /// `other`); omit it for the whole week.
  Future<JikanScheduleEntity> getSchedules({
    String? day,
    int page = 1,
    int limit = jikanMaxLimit,
  }) async {
    final Uri uri = Uri.parse(jikanScheduleEndpoint).replace(
      queryParameters: <String, String>{
        'page': page < 1 ? '1' : page.toString(),
        'limit': limit.clamp(1, jikanMaxLimit).toString(),
        ..._optional(<String, String?>{'filter': day?.toLowerCase()}),
      },
    );
    _logger.i("Fetching the weekly schedule from Jikan (day=${day ?? 'all'})");
    return JikanScheduleEntity.fromJson(
      await _getJikanJson(uri, reason: 'GET jikan schedules ${day ?? 'all'}'),
    );
  }

  // --------------------------------------------------------------- internal

  Future<JikanMediaListEntity> _getJikanList(
    String endpoint, {
    required String reason,
    required Map<String, String?> filters,
    required bool? nsfwAllowed,
    required int page,
    required int limit,
  }) async {
    final Uri uri = Uri.parse(endpoint).replace(
      queryParameters: <String, String>{
        ..._optional(filters),
        'page': page < 1 ? '1' : page.toString(),
        'limit': limit.clamp(1, jikanMaxLimit).toString(),
        if (nsfwAllowed == false) 'sfw': 'true',
      },
    );
    return JikanMediaListEntity.fromJson(await _getJikanJson(uri, reason: reason));
  }

  Uri _listUri({required String path, required Map<String, String> query}) {
    return Uri.parse('${config.malApiBase}/$path').replace(queryParameters: query);
  }

  /// `page`/`limit` → `limit`/`offset` (offset is `(page - 1) * limit`).
  Map<String, String> _pagingQuery(int page, int limit) {
    final int safePage = page < 1 ? 1 : page;
    final int safeLimit = limit.clamp(1, maxLimit);
    return <String, String>{
      'limit': safeLimit.toString(),
      'offset': ((safePage - 1) * safeLimit).toString(),
    };
  }

  String? _genreQuery(List<int>? genreIds) {
    if (genreIds == null || genreIds.isEmpty) return null;
    return genreIds.where((int id) => id > 0).join(',');
  }

  Map<String, String> _optional(Map<String, String?> candidates) {
    final Map<String, String> present = <String, String>{};
    candidates.forEach((String key, String? value) {
      if (value != null && value.trim().isNotEmpty) present[key] = value.trim();
    });
    return present;
  }

  /// MAL v2 headers: the public client id **always** (an anonymous v2 read
  /// without it is a 403), plus the account token when there is one.
  Map<String, String> _headers(MalUserModel? user) {
    final Map<String, String> headers = <String, String>{
      'X-MAL-CLIENT-ID': config.malClientId,
    };
    if (user == null || user.accessToken.trim().isEmpty) return headers;
    headers.addAll(_authService.authorizationHeaders(user.accessToken));
    return headers;
  }

  Future<Map<String, dynamic>> _getJson(
    Uri uri, {
    required String reason,
    MalUserModel? user,
  }) async {
    await _rateLimiter.acquire(reason: reason);
    final http.Response response = await _client.get(uri, headers: _headers(user));
    _expectOk(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// One Jikan read: a [JikanRateLimiter] grant, no MAL headers, and a single
  /// retry after Jikan's 429 (its documented failure mode). A second 429 is
  /// surfaced as an ordinary [HttpServerException] and the caller degrades to
  /// an empty page — never a hot retry loop.
  Future<Map<String, dynamic>> _getJikanJson(Uri uri, {required String reason}) async {
    await _jikanRateLimiter.acquire(reason: reason);
    http.Response response = await _client.get(uri);
    if (response.statusCode == 429) {
      await _jikanRateLimiter.backoff(reason: reason);
      await _jikanRateLimiter.acquire(reason: reason);
      response = await _client.get(uri);
    }
    _expectOk(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void _expectOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpServerException(response.statusCode, response.body);
    }
  }

  void _validateId(int id) {
    if (id <= 0) {
      throw ArgumentError.value(id, 'id', 'MAL media ids are positive integers');
    }
  }

  void _validateRankingType(String rankingType, List<String> allowed) {
    if (!allowed.contains(rankingType)) {
      throw ArgumentError.value(
        rankingType,
        'rankingType',
        'expected one of ${allowed.join(", ")}',
      );
    }
  }
}

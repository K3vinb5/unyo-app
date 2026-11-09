import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/dto/jikan/jikan_schedule_entity.dart';
import 'package:unyo/core/services/api/dto/mal/mal_anime_node.dart';
import 'package:unyo/core/services/api/dto/mal/mal_manga_node.dart';
import 'package:unyo/core/services/api/dto/mal/mal_media_list_entity.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
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
/// * **every** `api.myanimelist.net` read takes a grant from [MalRateLimiter]
///   first — the same budget the tracker writes use (2 rps, 403 = throttle);
/// * `fields=` is always explicit. The constants below are the only field sets,
///   so a metadata read never depends on MAL's trimmed-by-default answer;
/// * the `Authorization` header is added **only** when a [MalUserModel] is
///   passed (personalises `my_list_status`); public reads go out anonymously;
/// * `nsfw` is sent both ways: `false` when the caller forbids adult titles and
///   `true` when it allows them. MAL's documented default is the **safe**
///   catalogue ("By default, some APIs don't return nsfw content"), so omitting
///   the parameter would leave the account's opt-in inert. Only a `null`
///   preference (no setting at all) omits it. The ranking endpoints have no
///   such parameter, so they never get it;
/// * `page`/`limit` are the caller's units: `offset = (page - 1) * limit`.
///
/// ## Jikan
///
/// [getSchedules] is the **only** Jikan call in the app (MAL v2 has no
/// schedule endpoint). Jikan is not MyAnimeList: it has its own rate limits
/// (3/s, 60/min) and serves public data anonymously, so it deliberately does
/// **not** acquire [MalRateLimiter]. Nothing else may use Jikan (SPEC §4).
class MalMetadataService {
  static const int defaultLimit = 50;

  /// MAL's documented hard cap for `/anime` and `/manga`.
  static const int maxLimit = 100;

  /// Jikan's `/v4/schedules` endpoint — calendar only (see class doc).
  static const String jikanScheduleEndpoint = 'https://api.jikan.moe/v4/schedules';

  /// Jikan caps `limit` at 25 on the schedules endpoint.
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

  /// Shared MyAnimeList budget; lazy so pure-mapping tests need not register it.
  MalRateLimiter get _rateLimiter => sl<MalRateLimiter>();
  MalAuthService get _authService => sl<MalAuthService>();

  MalMetadataService({http.Client? client}) : _client = client ?? http.Client();

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

  /// `GET /anime` — one browse/search page.
  ///
  /// `sort` takes a MAL sort key ([MalMetadataVocabularies.animeSorts]) with an
  /// optional `-` prefix for descending. `season`/`year` have **no** filter on
  /// this endpoint (MAL only offers `/anime/season/{year}/{season}`), so they
  /// are logged and ignored here rather than sent as a made-up parameter.
  Future<MalAnimeListEntity> getAnimeCatalog({
    String? status,
    String? sort,
    String? q,
    String? mediaType,
    String? rating,
    String? season,
    int? year,
    List<int>? genreIds,
    bool? nsfwAllowed,
    int page = 1,
    int limit = defaultLimit,
    MalUserModel? user,
  }) async {
    if (season != null || year != null) {
      _logger.w(
        "MAL /anime has no season/year filter (season=$season, year=$year); "
        "the seasonal endpoint /anime/season/{year}/{season} is a separate call",
      );
    }
    final Map<String, String> query = <String, String>{
      ..._pagingQuery(page, limit),
      'fields': animeListFields,
      ..._optional(<String, String?>{
        'status': status,
        'sort': sort,
        'q': q,
        'type': mediaType,
        'rating': rating,
        'genre': _genreQuery(genreIds),
      }),
      ..._nsfwQuery(nsfwAllowed),
    };
    return MalAnimeListEntity.fromJson(
      await _getJson(_listUri(path: 'anime', query: query), user: user, reason: 'GET anime'),
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

  /// `GET /manga` — one browse/search page. `sort` takes a
  /// [MalMetadataVocabularies.mangaSorts] key with an optional `-` prefix.
  Future<MalMangaListEntity> getMangaCatalog({
    String? status,
    String? sort,
    String? q,
    String? mediaType,
    String? rating,
    List<int>? genreIds,
    bool? nsfwAllowed,
    int page = 1,
    int limit = defaultLimit,
    MalUserModel? user,
  }) async {
    final Map<String, String> query = <String, String>{
      ..._pagingQuery(page, limit),
      'fields': mangaListFields,
      ..._optional(<String, String?>{
        'status': status,
        'sort': sort,
        'q': q,
        'type': mediaType,
        'rating': rating,
        'genre': _genreQuery(genreIds),
      }),
      ..._nsfwQuery(nsfwAllowed),
    };
    return MalMangaListEntity.fromJson(
      await _getJson(_listUri(path: 'manga', query: query), user: user, reason: 'GET manga'),
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

  // --------------------------------------------------------------- calendar

  /// `GET https://api.jikan.moe/v4/schedules` — the calendar feed.
  ///
  /// [day] is a Jikan weekday filter (`monday` … `sunday`, or `unknown`/
  /// `other`); omit it for the whole week. This is the only Jikan call in the
  /// app, and it does **not** take a [MalRateLimiter] grant: Jikan has its own
  /// limits and is read anonymously (SPEC §4).
  Future<JikanScheduleEntity> getSchedules({
    String? day,
    int page = 1,
    int limit = jikanMaxLimit,
  }) async {
    final Uri uri = Uri.parse(jikanScheduleEndpoint).replace(
      queryParameters: <String, String>{
        'page': page.toString(),
        'limit': limit.clamp(1, jikanMaxLimit).toString(),
        ..._optional(<String, String?>{'filter': day?.toLowerCase()}),
      },
    );
    _logger.i("Fetching the weekly schedule from Jikan (day=${day ?? 'all'})");
    final http.Response response = await _client.get(uri);
    _expectOk(response);
    return JikanScheduleEntity.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // --------------------------------------------------------------- internal

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

  /// `nsfw=false` when adult titles are forbidden, `nsfw=true` when they are
  /// allowed, absent for a `null` preference. MAL's default is the safe
  /// catalogue, so `true` must be explicit — the Shikimori
  /// `censored: enableNsfw ? null : false` trick does not carry over.
  Map<String, String> _nsfwQuery(bool? nsfwAllowed) {
    if (nsfwAllowed == null) return const <String, String>{};
    return <String, String>{'nsfw': nsfwAllowed ? 'true' : 'false'};
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

  Map<String, String> _headers(MalUserModel? user) {
    if (user == null || user.accessToken.trim().isEmpty) return const <String, String>{};
    return _authService.authorizationHeaders(user.accessToken);
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

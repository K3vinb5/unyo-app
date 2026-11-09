// External dependencies
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/api/dto/jikan/jikan_media_entity.dart';
import 'package:unyo/core/services/api/dto/mal/mal_manga_node.dart';
import 'package:unyo/core/services/api/dto/mal/mal_media_list_entity.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/api/mal/mal_metadata_service.dart';
import 'package:unyo/core/services/api/mal/mal_metadata_vocabularies.dart';
import 'package:unyo/core/services/api/mal/mal_user_rate_service.dart';
import 'package:unyo/data/models/mal/media/mal_list_status_policy.dart';
import 'package:unyo/data/models/mal/media/mal_manga_details_model.dart';
import 'package:unyo/data/models/mal/media/mal_manga_model.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/data/repositories/repository_mixin.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';

/// MyAnimeList manga repository: metadata (`GET /manga/ranking`, `/manga/{id}`
/// and the Jikan v4 `/manga` API through [MalMetadataService]) plus the WP #156
/// list-entry tracker half ([MalUserRateService]).
///
/// Mirror of `MangaRepositoryShikimori` method-by-method. The amended SPEC §2
/// map is hybrid: MAL v2 serves the popularity ranking, details and covers,
/// while the Jikan v4 API (Tenrai by default; a self-hosted Jikan compatible)
/// serves the status-ordered feeds and the advanced search (v2
/// `/manga` has no `publishing`/`upcoming` ranking type — probed 400 — and
/// ignores `status`/`sort` on `/manga`). Details fold `my_list_status` onto the
/// shared entry and `related_manga` onto `recommendedMangas`; covers come from
/// the popular page. List reads are anonymous (MAL needs no token for catalog
/// data); the details call carries the logged account so `my_list_status` is
/// populated, and a non-MAL user simply reads anonymously.
///
/// Record ids are MAL native ids (SPEC §3), so `id`/`idMal` both carry the node
/// id; cross-service addressing rides `MediaMappingRepositoryMal`'s
/// identity/AniList-`idMal` pivot before a record reaches the tracker methods.
/// [MalUserRateService] rejects non-positive ids.
class MangaRepositoryMal with RepositoryMixin implements MangaRepository {
  /// MAL's documented hard cap for `/manga` is 100; 50 matches Shikimori's page
  /// size so the shared carousels advance the same way.
  static const int pageSize = MalMetadataService.defaultLimit;

  /// One Jikan feed/search page. Jikan caps `limit` at 25 on every list
  /// endpoint, so a Jikan page is smaller than a MAL one by contract.
  static const int jikanPageSize = MalMetadataService.jikanMaxLimit;

  /// Resolved on first use so metadata-only tests can build this repository
  /// without the rate service registered (mirror of the Shikimori repos).
  MalUserRateService get _userRateService => sl<MalUserRateService>();
  /// Resolved lazily: no metadata read touches the tracker service.
  MalMetadataService get _metadataService => sl<MalMetadataService>();
  final Logger _logger = sl<Logger>();

  // ----------------------------------------------------------------- tracker

  /// WP #156: manga writes go to `PUT /manga/{id}/my_list_status` (chapters +
  /// volumes counters), and an empty-status entry is the delete.
  ///
  /// Deliberately **not** on [MangaRepository]: the interface has no list-entry
  /// API yet (manga entries are not editable in the v1 UI), so this stays a
  /// concrete capability the factory does not route to — exactly like
  /// `MangaRepositoryShikimori`.
  Future<MediaListEntry> updateMediaListEntry(
    MediaListEntry newMediaListEntry,
    Manga selectedManga,
    User loggedUser,
  ) async {
    _logger.i("Updating Media List Entry to $newMediaListEntry on MyAnimeList");
    final MalUserModel? account = _malAccount(loggedUser);
    if (account == null) return MediaListEntryModel.empty();
    return _userRateService.updateEntry(
      user: account,
      targetId: selectedManga.id,
      target: MalListTarget.manga,
      entry: newMediaListEntry,
    );
  }

  /// The reader is `GET /manga/{id}?fields=my_list_status`; no status (or a
  /// 404 media id) reads as the empty entry.
  Future<MediaListEntry> getMediaListEntry(
    Manga selectedManga,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching User Media List Entry from MyAnimeList for ${selectedManga.title.userPreferred}");
    final MalUserModel? account = _malAccount(loggedUser);
    if (account == null) return MediaListEntryModel.empty();
    return _userRateService.getEntry(
      user: account,
      targetId: selectedManga.id,
      target: MalListTarget.manga,
    );
  }

  /// The logged user, when it is a MyAnimeList account. A non-MAL user has no
  /// token to send, so the caller degrades instead of writing anonymously.
  MalUserModel? _malAccount(User loggedUser) {
    if (loggedUser is MalUserModel) return loggedUser;
    _logger.w("Logged user ${loggedUser.name} is not a MyAnimeList account, skipping the list call");
    return null;
  }

  // ---------------------------------------------------------------- metadata
  // SPEC §2 (amended): `/manga/ranking` has no `publishing` or `upcoming`
  // ranking type (probed live: `400 invalid ranking_type`), and `/manga` cannot
  // filter by `status`/`sort` (only a required `q` plus paging). So the three
  // status-ordered feeds are Jikan reads and only the popularity ranking stays
  // on v2.

  /// Jikan `/v4/manga?status=publishing&order_by=members&sort=desc` — the set of
  /// series people are reading right now. MAL has no `airing` ranking type for
  /// manga, and `status=publishing` on v2 `/manga` is ignored, so this feed
  /// needs Jikan (SPEC §2).
  @override
  Future<(bool, List<Manga>)> getTrendingMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching MyAnimeList trending mangas (Jikan)");
    return _jikanMangas(
      page: page,
      loggedUser: loggedUser,
      status: 'publishing',
      orderBy: 'members',
      direction: 'desc',
      reason: 'trending mangas',
    );
  }

  /// `GET /manga/ranking?ranking_type=bypopularity` — MAL's own popularity
  /// ranking, the direct counterpart of Shikimori's `order: popularity`.
  @override
  Future<(bool, List<Manga>)> getPopularMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching MyAnimeList popular mangas");
    return _fetchRanking(
      rankingType: 'bypopularity',
      page: page,
      loggedUser: loggedUser,
      reason: 'popular mangas',
    );
  }

  /// Jikan `/v4/manga?status=complete&order_by=end_date&sort=desc` — finished
  /// series, most recently ended first (mirror of the anime feed).
  @override
  Future<(bool, List<Manga>)> getRecentlyCompletedMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching MyAnimeList recently completed mangas (Jikan)");
    return _jikanMangas(
      page: page,
      loggedUser: loggedUser,
      status: 'complete',
      orderBy: 'end_date',
      direction: 'desc',
      reason: 'recently completed mangas',
    );
  }

  /// Jikan `/v4/manga?status=upcoming&order_by=start_date&sort=asc` — the shape
  /// SPEC §2 keeps for announced manga. **Disposition (WP #169, probed
  /// 2026-11-09): this source carries no upcoming manga, so the row is empty on
  /// purpose, not broken.** `status=upcoming` answers 200 with `total: 0` for
  /// every variant (`order_by=members|start_date` × `sort=asc|desc`, `sfw=true`,
  /// `type=manga`, page 2), `status=not_yet_published` is also 0, and
  /// `/top/manga?filter=upcoming` is 0. Controls prove the filter is honoured:
  /// `publishing` 13 417, `complete` 71 870, `hiatus` 520, `discontinued` 266,
  /// while anime `status=upcoming` returns 538 — so 0 is data, not a rejected
  /// parameter. The catalog's latest `published.from` across all 86 073 manga is
  /// today+1, so filtering future start dates client-side would be empty too.
  ///
  /// No proxy replaces it: `publishing` sorted by newest `start_date` is the
  /// manga analogue of the anime Recently Released row
  /// (`status=airing&order_by=start_date&sort=desc`), i.e. "already serializing",
  /// which is not "upcoming" — it would put a different claim under this label.
  /// The call itself is kept — one request, ~0.4 s, `(true, <Manga>[])` — so a
  /// backfilled catalog starts filling the row with no code change, and a
  /// failed request still degrades to `(false, [])`.
  @override
  Future<(bool, List<Manga>)> getUpcomingMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching MyAnimeList upcoming mangas (Jikan)");
    return _jikanMangas(
      page: page,
      loggedUser: loggedUser,
      status: 'upcoming',
      orderBy: 'start_date',
      direction: 'asc',
      reason: 'upcoming mangas',
    );
  }

  /// `GET /manga/{id}` with the details field set.
  ///
  /// The logged MAL account is sent so `my_list_status` is populated; any other
  /// user reads anonymously and degrades to the empty entry. Scalar media
  /// fields stay on the [Manga] the caller already holds — [MangaDetails] only
  /// carries the entry, [MangaDetails.recommendedMangas] (from `related_manga`)
  /// and characters (MAL v2 has none — SPEC §4).
  @override
  Future<(bool, MangaDetails)> getMangaDetails(
    Manga selectedManga,
    User loggedUser, {
    Service? service,
  }) async {
    _logger.i("Fetching Manga Details from MyAnimeList for ${selectedManga.title.userPreferred}");
    if (selectedManga.id <= 0) {
      _logger.w("MyAnimeList details need a positive native id (got ${selectedManga.id}), skipping the call");
      return (false, MalMangaDetailsModel.empty());
    }
    try {
      final MalMangaNode node = await _metadataService.getMangaDetails(selectedManga.id, _malAccount(loggedUser));
      if (node.id <= 0) {
        _logger.w("MyAnimeList answered no manga payload for id ${selectedManga.id}");
        return (false, MalMangaDetailsModel.empty());
      }
      return (true, MalMangaDetailsModel.fromNode(node));
    } on HttpServerException catch (e) {
      _logger.e("MyAnimeList details for ${selectedManga.id} failed: $e");
      return (false, MalMangaDetailsModel.empty());
    } on HttpException catch (e) {
      _logger.e("MyAnimeList details for ${selectedManga.id} failed (${e.message})");
      return (false, MalMangaDetailsModel.empty());
    }
  }

  /// Jikan's manga filter vocabulary shaped exactly like Shikimori's filter map
  /// (see [AnimeRepositoryMal] for why the filters are Jikan's).
  ///
  /// `countries` stays hidden: neither Jikan nor MAL has a country filter. The
  /// search never reads a `ratings` entry (Jikan's codes differ from MAL's and
  /// manga has no `rating=` axis at all), so none is exposed. `sortOrders` stays
  /// hidden because the direction rides the sort string the screen already
  /// sends (`SCORE_DESC` → `order_by=score&sort=desc`).
  @override
  Future<Map<String, (bool, List<String>)>> getUserMangaAdvancedSearchFilters(User loggedUser) async {
    final Map<String, (bool, List<String>)> filters = MalMetadataVocabularies.mangaFilterMap();
    filters['countries'] = (false, <String>[]);
    return filters;
  }

  /// One Jikan `/v4/manga` search page.
  ///
  /// `selectedCountry` has no counterpart on Jikan either, so the value is
  /// logged and dropped rather than mapped onto an unrelated parameter — the
  /// same degradation Shikimori's repository documents.
  @override
  Future<List<Manga>> performMangaAdvancedSearch(
    String query,
    List<String> selectedGenres,
    String? selectedFormat,
    String? selectedCountry,
    String? selectedAiringStatus,
    String sort,
    int page,
    User loggedUser,
  ) async {
    _logger.i("Performing advanced manga search on MyAnimeList (Jikan)");
    if (selectedCountry != null && selectedCountry.trim().isNotEmpty) {
      _logger.w("MyAnimeList has no manga country filter; ignoring '$selectedCountry'");
    }
    final ({String orderBy, String direction})? order = MalMetadataVocabularies.orderFor(sort);
    final (bool _, List<Manga> results) = await _jikanMangas(
      q: query.trim().isEmpty ? null : query.trim(),
      status: _wireValue(selectedAiringStatus, MalMetadataVocabularies.mangaStatusLabels),
      type: _wireValue(selectedFormat, MalMetadataVocabularies.mangaFormatLabels),
      genreIds: _genreIds(selectedGenres),
      orderBy: order?.orderBy,
      direction: order?.direction,
      page: page,
      loggedUser: loggedUser,
      reason: 'manga search',
    );
    return results;
  }

  /// Mirror of Shikimori: the popular page's covers, empty strings dropped and
  /// the order shuffled so the grid does not look static.
  @override
  Future<List<String>> getMediaCoverImages(User loggedUser, {bool ignoreCache = false}) async {
    _logger.i("Fetching Media Cover Images from MyAnimeList");
    final (bool hasNext, List<Manga> mangas) = await getPopularMangas(1, loggedUser, ignoreCache: ignoreCache);
    return mangas
        .map((Manga manga) => manga.coverImage)
        .where((String coverImage) => coverImage != "")
        .shuffled(Random())
        .toList();
  }

  // ---------------------------------------------------------------- internal

  /// One Jikan `/v4/manga` page (browse feed or search); a non-2xx answer —
  /// including a 429 that survived the transport's single backoff — degrades to
  /// `(false, [])` like the other provider repositories.
  Future<(bool, List<Manga>)> _jikanMangas({
    required int page,
    required User loggedUser,
    required String reason,
    String? status,
    String? type,
    String? orderBy,
    String? direction,
    String? q,
    List<int>? genreIds,
  }) async {
    try {
      final JikanMediaListEntity feed = await _metadataService.getJikanMangaList(
        q: q,
        status: status,
        type: type,
        genreIds: genreIds,
        orderBy: orderBy,
        sort: direction,
        nsfwAllowed: loggedUser.settings.enableNsfwContent,
        page: page,
        limit: jikanPageSize,
      );
      return (true, _visible(_mapJikanNodes(feed), loggedUser));
    } on HttpServerException catch (e) {
      _logger.e("Jikan $reason failed (${e.statusCode}), status=$status type=$type");
      return (false, <Manga>[]);
    } on HttpException catch (e) {
      _logger.e("Jikan $reason failed (${e.message}), status=$status type=$type");
      return (false, <Manga>[]);
    }
  }

  /// One anonymous `/manga/ranking` page (see [_jikanMangas] for degradation).
  Future<(bool, List<Manga>)> _fetchRanking({
    required String rankingType,
    required int page,
    required User loggedUser,
    required String reason,
  }) async {
    try {
      final MalMangaListEntity response = await _metadataService.getMangaRanking(
        rankingType,
        page: page,
        limit: pageSize,
      );
      return (true, _visible(_mapNodes(response), loggedUser));
    } on HttpServerException catch (e) {
      _logger.e("MyAnimeList $reason failed: $e");
      return (false, const <Manga>[]);
    } on HttpException catch (e) {
      // Dead host / timed-out call (WP #166 live evidence): degrade exactly
      // like a server error instead of letting the exception escape.
      _logger.e("MyAnimeList $reason failed (${e.message})");
      return (false, const <Manga>[]);
    }
  }

  /// Jikan page → domain records. The node id is the MAL-native `mal_id`, so a
  /// Jikan-sourced record addresses exactly like a v2 one (SPEC §3).
  List<Manga> _mapJikanNodes(JikanMediaListEntity entity) {
    return entity.data
        .where((JikanMediaData node) => node.malId > 0)
        .map((JikanMediaData node) => MalMangaModel.fromJikanNode(node))
        .toList();
  }

  List<Manga> _mapNodes(MalMangaListEntity response) {
    return response.data
        .where((MalMangaListEntityData entry) => entry.node.id > 0)
        .map((MalMangaListEntityData entry) => MalMangaModel.fromNode(entry.node))
        .toList();
  }

  /// The NSFW gate every manga list applies: adult titles only when the user
  /// opted in. `/manga/ranking` has no `nsfw` parameter, and Jikan's `sfw=true`
  /// is a request-side filter rather than a guarantee on a mapped node, so the
  /// mapped `isAdult` (v2 `nsfw: black`, Jikan's `explicit_genres: Hentai`) is
  /// the final word, mirroring `AnimeRepositoryMal._visible`.
  List<Manga> _visible(List<Manga> mangas, User loggedUser) {
    return mangas
        .where((Manga manga) => !manga.isAdult || loggedUser.settings.enableNsfwContent)
        .toList();
  }

  /// UI label ("One Shot") or wire value ("oneshot") → the Jikan wire value; an
  /// unknown selection is dropped instead of guessed.
  String? _wireValue(String? selected, Map<String, String> labels) {
    if (selected == null) return null;
    final String trimmed = selected.trim();
    if (trimmed.isEmpty) return null;
    final String lower = trimmed.toLowerCase();
    for (final MapEntry<String, String> entry in labels.entries) {
      if (entry.key.toLowerCase() == lower) return entry.value;
    }
    final String normalized = _normalize(lower);
    for (final String wire in labels.values) {
      if (wire == normalized) return wire;
    }
    _logger.w("Unknown MyAnimeList manga filter value '$selected'; sending no filter");
    return null;
  }

  /// Genre labels (or numeric ids) → the Jikan `genres=` id list.
  List<int>? _genreIds(List<String> selectedGenres) {
    final List<int> ids = <int>[];
    for (final String selected in selectedGenres) {
      final String trimmed = selected.trim();
      if (trimmed.isEmpty) continue;
      final String? joined = MalMetadataVocabularies.genreIdsFor(<String>[trimmed], manga: true);
      final int? id = int.tryParse(trimmed) ?? (joined == null ? null : int.tryParse(joined));
      if (id != null && id > 0 && !ids.contains(id)) ids.add(id);
    }
    return ids.isEmpty ? null : ids;
  }

  String _normalize(String value) => value.trim().replaceAll(RegExp(r'[\s-]+'), '_');
}

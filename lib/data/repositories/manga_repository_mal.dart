// External dependencies
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
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

/// MyAnimeList manga repository: metadata (`GET /manga`, `/manga/ranking`,
/// `/manga/{id}` through [MalMetadataService]) plus the WP #156 list-entry
/// tracker half ([MalUserRateService]).
///
/// Mirror of `MangaRepositoryShikimori` method-by-method: browse lists map one
/// `/manga` page, details fold `my_list_status` onto the shared entry and
/// `related_manga` onto `recommendedMangas`, advanced search reuses the same
/// `/manga` catalog with MAL's static [MalMetadataVocabularies] filters, and
/// covers come from the popular page. List reads are anonymous (MAL needs no
/// token for catalog data); the details call carries the logged account so
/// `my_list_status` is populated, and a non-MAL user simply reads anonymously.
///
/// Record ids are MAL native ids (SPEC §3), so `id`/`idMal` both carry the node
/// id; cross-service addressing rides `MediaMappingRepositoryMal`'s
/// identity/AniList-`idMal` pivot before a record reaches the tracker methods.
/// [MalUserRateService] rejects non-positive ids.
class MangaRepositoryMal with RepositoryMixin implements MangaRepository {
  /// MAL's documented hard cap for `/manga` is 100; 50 matches Shikimori's page
  /// size so the shared carousels advance the same way.
  static const int pageSize = MalMetadataService.defaultLimit;

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

  /// `GET /manga?status=publishing&sort=-manga_num_list_users`.
  ///
  /// MAL has no `airing` ranking type for manga (the anime feed's "hot now"
  /// equivalent), so trending is the currently-publishing catalog ordered by
  /// member count — the set of series people are reading right now.
  @override
  Future<(bool, List<Manga>)> getTrendingMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching MyAnimeList trending mangas");
    return _fetchCatalog(
      page: page,
      loggedUser: loggedUser,
      status: 'publishing',
      sort: MalMetadataVocabularies.sortFor('manga_num_list_users', descending: true),
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

  /// `GET /manga?status=finished&sort=-manga_end_date` — finished series, most
  /// recently ended first (mirror of the anime `finished_airing` feed).
  @override
  Future<(bool, List<Manga>)> getRecentlyCompletedMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching MyAnimeList recently completed mangas");
    return _fetchCatalog(
      page: page,
      loggedUser: loggedUser,
      status: 'finished',
      sort: MalMetadataVocabularies.sortFor('manga_end_date', descending: true),
      reason: 'recently completed mangas',
    );
  }

  /// `GET /manga?status=not_yet_published&sort=manga_start_date` — announced
  /// series, nearest start date first.
  @override
  Future<(bool, List<Manga>)> getUpcomingMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching MyAnimeList upcoming mangas");
    return _fetchCatalog(
      page: page,
      loggedUser: loggedUser,
      status: 'not_yet_published',
      sort: MalMetadataVocabularies.sortFor('manga_start_date', descending: false),
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
    }
  }

  /// MAL's static manga vocabulary shaped exactly like Shikimori's filter map.
  ///
  /// `countries` stays hidden: MAL has no country filter on `/manga` (the value
  /// is dropped by [performMangaAdvancedSearch]). `sortOrders` stays hidden
  /// because MAL expresses direction with the `-` prefix on the sort field, so
  /// there is no second list to pick from.
  @override
  Future<Map<String, (bool, List<String>)>> getUserMangaAdvancedSearchFilters(User loggedUser) async {
    final Map<String, (bool, List<String>)> filters = MalMetadataVocabularies.mangaFilterMap();
    filters['countries'] = (false, <String>[]);
    return filters;
  }

  /// One `GET /manga` page with every filter MAL accepts.
  ///
  /// `selectedCountry` has no counterpart in MAL v2 (SPEC §2), so the value is
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
    _logger.i("Performing advanced manga search on MyAnimeList");
    if (selectedCountry != null && selectedCountry.trim().isNotEmpty) {
      _logger.w("MyAnimeList has no manga country filter; ignoring '$selectedCountry'");
    }
    final MalMangaListEntity response = await _metadataService.getMangaCatalog(
      q: query.trim().isEmpty ? null : query.trim(),
      status: _wireValue(selectedAiringStatus, MalMetadataVocabularies.mangaStatusLabels),
      sort: _sortFor(sort),
      mediaType: _wireValue(selectedFormat, MalMetadataVocabularies.mangaFormatLabels),
      genreIds: _genreIds(selectedGenres),
      nsfwAllowed: loggedUser.settings.enableNsfwContent,
      page: page,
      limit: pageSize,
    );
    return _visible(
      response.data.map((MalMangaListEntityData entry) => MalMangaModel.fromNode(entry.node)).toList(),
      loggedUser,
    );
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

  /// One anonymous (metadata is public) `/manga` page; a non-2xx answer
  /// degrades to `(false, [])` like the other provider repositories.
  Future<(bool, List<Manga>)> _fetchCatalog({
    required int page,
    required User loggedUser,
    required String reason,
    String? status,
    String? sort,
  }) async {
    try {
      final MalMangaListEntity response = await _metadataService.getMangaCatalog(
        status: status,
        sort: sort,
        nsfwAllowed: loggedUser.settings.enableNsfwContent,
        page: page,
        limit: pageSize,
      );
      return (true, _visible(_mapNodes(response), loggedUser));
    } on HttpServerException catch (e) {
      _logger.e("MyAnimeList $reason failed: $e");
      return (false, const <Manga>[]);
    }
  }

  /// One anonymous `/manga/ranking` page (see [_fetchCatalog] for degradation).
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
    }
  }

  List<Manga> _mapNodes(MalMangaListEntity response) {
    return response.data
        .where((MalMangaListEntityData entry) => entry.node.id > 0)
        .map((MalMangaListEntityData entry) => MalMangaModel.fromNode(entry.node))
        .toList();
  }

  /// The NSFW gate every manga list applies: adult titles only when the user
  /// opted in. `/manga/ranking` has no `nsfw` parameter, and `nsfw` on
  /// `/manga` is a request hint rather than a guarantee, so the mapped
  /// `isAdult` (from `nsfw: black` — manga has no `rating` field) is the final
  /// word, mirroring `AnimeRepositoryMal._visible`.
  List<Manga> _visible(List<Manga> mangas, User loggedUser) {
    return mangas
        .where((Manga manga) => !manga.isAdult || loggedUser.settings.enableNsfwContent)
        .toList();
  }

  /// UI label ("One Shot") or wire value ("one_shot") → the MAL wire value; an
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

  /// `"Score_Desc"` / `"START_DATE_ASC"` → the MAL sort key with the `-`
  /// descending prefix; unknown options are dropped.
  String? _sortFor(String sort) {
    final String normalized = _normalize(sort.toLowerCase());
    if (normalized.isEmpty) return null;
    final bool descending = normalized.endsWith('_desc');
    final String base = normalized.replaceAll(RegExp(r'_(asc|desc)$'), '');
    if (base.isEmpty) return null;
    final String? field = _sortFieldFor(base);
    if (field == null) {
      _logger.w("Unknown MyAnimeList manga sort '$sort'; sending no sort");
      return null;
    }
    return MalMetadataVocabularies.sortFor(field, descending: descending);
  }

  /// Label ("Start Date") or wire key ("manga_start_date") → the MAL sort key.
  String? _sortFieldFor(String base) {
    for (final MapEntry<String, String> entry in MalMetadataVocabularies.mangaSortLabels.entries) {
      if (_normalize(entry.key.toLowerCase()) == base) return entry.value;
    }
    return MalMetadataVocabularies.mangaSorts.contains(base) ? base : null;
  }

  /// Genre labels (or numeric ids) → the MAL `genre=` id list.
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

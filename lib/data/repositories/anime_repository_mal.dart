// External dependencies
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/api/dto/jikan/jikan_schedule_entity.dart';
import 'package:unyo/core/services/api/dto/mal/mal_anime_node.dart';
import 'package:unyo/core/services/api/dto/mal/mal_media_list_entity.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/core/services/api/mal/mal_metadata_service.dart';
import 'package:unyo/core/services/api/mal/mal_metadata_vocabularies.dart';
import 'package:unyo/core/services/api/mal/mal_user_rate_service.dart';
import 'package:unyo/data/models/mal/media/mal_anime_details_model.dart';
import 'package:unyo/data/models/mal/media/mal_anime_model.dart';
import 'package:unyo/data/models/mal/media/mal_list_status_policy.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/data/repositories/repository_mixin.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';

/// MyAnimeList anime provider: metadata **and** tracker (WP #156 + WP #166).
///
/// Metadata reads go through [MalMetadataService] (MAL API v2; Jikan only for
/// the weekly calendar, because MAL v2 has no schedule endpoint), mirroring
/// `AnimeRepositoryShikimori`'s method-by-method shape: browse lists are one
/// page of nodes, search is `/anime` with the selected filters, details is
/// `GET /anime/{id}`, covers come from the popular ranking. The transport owns
/// the rate-limiter grant, the explicit `fields=` sets and the `nsfw` parameter,
/// so every read here shares the tracker's budget and honours the app's
/// NSFW preference (SPEC §2/§4).
///
/// List-entry reads/writes stay on [MalUserRateService]; the logged account has
/// to be a [MalUserModel] or the call degrades to the empty entry instead of
/// writing anonymously. The details read sends that account too, so
/// `my_list_status` comes back personalized; with a non-MAL account it goes
/// out anonymously and the entry is empty, like the tracker.
///
/// A record passed to the list-entry methods must already carry the MAL native
/// id: [AnimeRepositoryFactory] re-addresses it through the MAL-pivot chain
/// (or passes it through on the identity path) before delegating, and
/// [MalUserRateService] rejects non-positive ids. Metadata results carry the
/// same MAL-native id in both `id` and `idMal` (SPEC §3).
class AnimeRepositoryMal with RepositoryMixin implements AnimeRepository {
  /// One MAL `/anime` page. MAL's documented default is 50.
  static const int pageSize = MalMetadataService.defaultLimit;

  /// Jikan weekday filters, in calendar order. `/v4/schedules` returns at most
  /// 25 entries per page, so a full week is seven filtered pages.
  static const List<String> _weekdays = <String>[
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  /// Resolved on first use so metadata-only tests can build this repository
  /// without the rate service registered (mirror of the Shikimori repos).
  MalUserRateService get _userRateService => sl<MalUserRateService>();
  /// The read transport; it takes the shared `MalRateLimiter` grant itself, so
  /// the repository never acquires the budget twice.
  MalMetadataService get _metadataService => sl<MalMetadataService>();
  final Logger _logger = sl<Logger>();

  /// WP #156: writes go to `PUT /anime/{id}/my_list_status` (MAL upserts), and
  /// an empty-status entry is the delete — [MalUserRateService] owns that fold.
  @override
  Future<MediaListEntry> updateMediaListEntry(
    MediaListEntry newMediaListEntry,
    Anime selectedAnime,
    User loggedUser,
  ) async {
    _logger.i("Updating Media List Entry to $newMediaListEntry on MyAnimeList");
    final MalUserModel? account = _malAccount(loggedUser);
    if (account == null) return MediaListEntryModel.empty();
    return _userRateService.updateEntry(
      user: account,
      targetId: selectedAnime.id,
      target: MalListTarget.anime,
      entry: newMediaListEntry,
    );
  }

  /// The reader is `GET /anime/{id}?fields=my_list_status`: MAL has no
  /// dedicated entry endpoint, and a title the user has no status for (or a
  /// 404 media id) reads as the empty entry.
  @override
  Future<MediaListEntry> getMediaListEntry(
    Anime selectedAnime,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching User Media List Entry from MyAnimeList for ${selectedAnime.title.userPreferred}");
    final MalUserModel? account = _malAccount(loggedUser);
    if (account == null) return MediaListEntryModel.empty();
    return _userRateService.getEntry(
      user: account,
      targetId: selectedAnime.id,
      target: MalListTarget.anime,
    );
  }

  /// The logged user, when it is a MyAnimeList account. A non-MAL user has no
  /// token to send, so the caller degrades instead of reading/writing
  /// anonymously.
  MalUserModel? _malAccount(User loggedUser) {
    if (loggedUser is MalUserModel) return loggedUser;
    _logger.w("Logged user ${loggedUser.name} is not a MyAnimeList account, skipping the list call");
    return null;
  }

  // ------------------------------------------------------------- browse
  // SPEC §2: hot-now ≈ AniList trending, `bypopularity` ≈ popular. The ranking
  // endpoint has no `nsfw` parameter (unlike `/anime`), so adult entries are
  // dropped client-side with the AniList calendar's expression.

  @override
  Future<(bool, List<Anime>)> getTrendingAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching MyAnimeList trending animes");
    return _rankingAnimes('airing', page, loggedUser);
  }

  @override
  Future<(bool, List<Anime>)> getPopularAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching MyAnimeList popular animes");
    return _rankingAnimes('bypopularity', page, loggedUser);
  }

  @override
  Future<(bool, List<Anime>)> getRecentlyReleasedAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching MyAnimeList recently released animes");
    return _catalogAnimes(
      page: page,
      loggedUser: loggedUser,
      status: 'currently_airing',
      sort: '-anime_start_date',
    );
  }

  @override
  Future<(bool, List<Anime>)> getRecentlyCompletedAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching MyAnimeList recently completed animes");
    return _catalogAnimes(
      page: page,
      loggedUser: loggedUser,
      status: 'finished_airing',
      sort: '-anime_end_date',
    );
  }

  @override
  Future<(bool, List<Anime>)> getUpcomingAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching MyAnimeList upcoming animes");
    return _catalogAnimes(
      page: page,
      loggedUser: loggedUser,
      status: 'not_yet_aired',
      sort: 'anime_start_date',
    );
  }

  Future<(bool, List<Anime>)> _rankingAnimes(String rankingType, int page, User loggedUser) async {
    try {
      final MalAnimeListEntity ranking = await _metadataService.getAnimeRanking(
        rankingType,
        page: page,
        limit: pageSize,
      );
      return (true, _visible(_mapNodes(ranking), loggedUser));
    } on HttpServerException catch (e) {
      _logger.e("MyAnimeList ranking $rankingType failed (${e.statusCode})");
      return (false, <Anime>[]);
    }
  }

  Future<(bool, List<Anime>)> _catalogAnimes({
    required int page,
    required User loggedUser,
    String? status,
    String? sort,
  }) async {
    try {
      final MalAnimeListEntity catalog = await _metadataService.getAnimeCatalog(
        status: status,
        sort: sort,
        nsfwAllowed: loggedUser.settings.enableNsfwContent,
        page: page,
        limit: pageSize,
      );
      return (true, _visible(_mapNodes(catalog), loggedUser));
    } on HttpServerException catch (e) {
      _logger.e("MyAnimeList browse page failed (${e.statusCode}), status=$status sort=$sort");
      return (false, <Anime>[]);
    }
  }

  List<Anime> _mapNodes(MalAnimeListEntity entity) {
    return entity.data
        .where((MalAnimeListEntityData entry) => entry.node.id > 0)
        .map((MalAnimeListEntityData entry) => MalAnimeModel.fromNode(entry.node))
        .toList();
  }

  /// The NSFW gate the AniList/Shikimori feeds apply: adult titles only when
  /// the user opted in.
  List<Anime> _visible(List<Anime> animes, User loggedUser) {
    return animes
        .where((Anime anime) => !anime.isAdult || loggedUser.settings.enableNsfwContent)
        .toList();
  }

  // ------------------------------------------------------------ details

  /// `GET /anime/{id}?fields=…` — one call. Scalar media fields live on the
  /// record the caller already holds ([AnimeDetails] only carries the extras).
  @override
  Future<(bool, AnimeDetails)> getAnimeDetails(
    Anime selectedAnime,
    User loggedUser, {
    Service? service,
  }) async {
    _logger.i("Fetching Anime Details from MyAnimeList for ${selectedAnime.title.userPreferred}");
    if (selectedAnime.id <= 0) {
      _logger.w("MyAnimeList details need a positive native id (got ${selectedAnime.id}), skipping the call");
      return (false, MalAnimeDetailsModel.empty());
    }
    final MalUserModel? account = _malAccount(loggedUser);
    try {
      final MalAnimeNode node = await _metadataService.getAnimeDetails(selectedAnime.id, account);
      if (node.id <= 0) {
        _logger.w("MyAnimeList answered no anime for ${selectedAnime.id}");
        return (false, MalAnimeDetailsModel.empty());
      }
      return (true, MalAnimeDetailsModel.fromNode(node));
    } on HttpServerException catch (e) {
      _logger.e("MyAnimeList details for ${selectedAnime.id} failed (${e.statusCode})");
      return (false, MalAnimeDetailsModel.empty());
    }
  }

  // ------------------------------------------------------------- search

  /// MAL's filter values are fixed enums (no genre-dictionary endpoint), so the
  /// dictionary is the static [MalMetadataVocabularies] map — same
  /// `(isVisible, values)` shape the shared search screen renders. There is no
  /// season/year entry: `/anime` cannot filter by either (SPEC §2).
  @override
  Future<Map<String, (bool, List<String>)>> getUserAnimeAdvancedSearchFilters(User loggedUser) async {
    return MalMetadataVocabularies.animeFilterMap();
  }

  @override
  Future<List<Anime>> performAnimeAdvancedSearch(
    String query,
    List<String> selectedGenres,
    String? selectedSeason,
    String? selectedFormat,
    int? selectedYear,
    String? selectedAiringStatus,
    String sort,
    int page,
    User loggedUser,
  ) async {
    _logger.i("Performing advanced anime search on MyAnimeList");
    if (selectedSeason != null || selectedYear != null) {
      _logger.w(
        "MyAnimeList /anime has no season/year filter (season=$selectedSeason, year=$selectedYear); "
        "ignoring both — the seasonal endpoint /anime/season/{year}/{season} is a separate call",
      );
    }
    final String? genreIds = selectedGenres.isEmpty
        ? null
        : MalMetadataVocabularies.genreIdsFor(selectedGenres, manga: false);
    final List<int>? genreIdList = genreIds?.split(',').map(int.parse).toList();
    try {
      final MalAnimeListEntity catalog = await _metadataService.getAnimeCatalog(
        q: query.trim().isEmpty ? null : query.trim(),
        status: _wireChoice(selectedAiringStatus, MalMetadataVocabularies.animeStatusLabels,
            MalMetadataVocabularies.animeStatuses),
        mediaType: _wireChoice(
            selectedFormat, MalMetadataVocabularies.animeFormatLabels, MalMetadataVocabularies.animeFormats),
        sort: _searchSort(sort),
        genreIds: genreIdList,
        nsfwAllowed: loggedUser.settings.enableNsfwContent,
        page: page,
        limit: pageSize,
      );
      return _mapNodes(catalog);
    } on HttpServerException catch (e) {
      _logger.e("MyAnimeList search failed (${e.statusCode})");
      return <Anime>[];
    }
  }

  /// Label → wire value, keeping the shared screen's display strings out of the
  /// query string. A value already in the wire vocabulary is accepted too.
  String? _wireChoice(String? selected, Map<String, String> labels, List<String> allowed) {
    if (selected == null) return null;
    final String trimmed = selected.trim();
    if (trimmed.isEmpty) return null;
    final String? labelled = labels[trimmed];
    if (labelled != null) return labelled;
    final String normalized = trimmed.toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
    return allowed.contains(normalized) ? normalized : null;
  }

  /// `SCORE_DESC` (what the shared screen sends) → MAL's `-anime_score`. An
  /// unknown field drops the sort entirely and lets MAL's own default order
  /// stand, mirroring the "do not filter" rule for the other parameters.
  String? _searchSort(String sort) {
    final String normalized = sort.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
    final bool descending = normalized.endsWith('_desc');
    final String base = normalized.replaceAll(RegExp(r'_(asc|desc)$'), '');
    String? wireField;
    for (final MapEntry<String, String> entry in MalMetadataVocabularies.animeSortLabels.entries) {
      final String label = entry.key.toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
      if (label == base) {
        wireField = entry.value;
        break;
      }
    }
    if (wireField == null) return null;
    return MalMetadataVocabularies.sortFor(wireField, descending: descending);
  }

  // -------------------------------------------------------------- covers

  /// Mirror of the Shikimori/AniList carousel: popular page 1 → cover images,
  /// empty covers dropped, shuffled.
  @override
  Future<List<String>> getMediaCoverImages(User loggedUser, {bool ignoreCache = false}) async {
    _logger.i("Fetching Media Cover Images from MyAnimeList");
    final (_, List<Anime> animes) = await getPopularAnimes(1, loggedUser, ignoreCache: ignoreCache);
    return animes
        .map((Anime anime) => anime.coverImage)
        .where((String coverImage) => coverImage != "")
        .shuffled(Random())
        .toList();
  }

  // ------------------------------------------------------------ calendar

  /// The weekly schedule. MAL v2 has **no** schedule endpoint, so this is the
  /// one Jikan read in the app (SPEC §4; the transport documents why nothing
  /// else may use it). Jikan's `/v4/schedules` exposes a broadcast *weekday*
  /// (`Mondays`) and an `HH:mm` slot, but never a per-episode airing timestamp
  /// — `anime.aired` is the series range, not the next episode — so dated keys
  /// could only be produced by fabricating data. The buckets therefore stay
  /// weekday names, Monday → Sunday, which is also how MAL's own calendar is
  /// shaped. AniList and Shikimori bucket by dated key because their payloads
  /// carry per-episode timestamps; this feed does not. Each bucket is ordered
  /// by broadcast time, and the calendar tab renders the key as its label, so
  /// the key is user-visible text (do not rename it casually).
  ///
  /// Jikan pages at 25 entries, so the week is fetched one weekday filter at a
  /// time; a day that fails keeps the rest of the week. `page > 1` is empty for
  /// the same reason as Shikimori's unpaginated calendar.
  @override
  Future<Map<String, List<Anime>>> getCalendarReleases(int page, User loggedUser) async {
    if (page > 1) return <String, List<Anime>>{};
    _logger.i("Fetching MyAnimeList calendar releases (Jikan schedules)");
    final List<({String day, String time, Anime anime})> dated = <({String day, String time, Anime anime})>[];
    final Set<int> seen = <int>{};
    for (final String weekday in _weekdays) {
      try {
        final JikanScheduleEntity schedule = await _metadataService.getSchedules(day: weekday);
        for (final JikanScheduleData entry in schedule.data) {
          if (entry.malId <= 0 || !seen.add(entry.malId)) continue;
          final String? day = _weekdayName(entry.broadcast.day);
          if (day == null) continue;
          dated.add((day: day, time: entry.broadcast.time.trim(), anime: _calendarAnime(entry)));
        }
      } on HttpServerException catch (e) {
        _logger.w("Jikan schedules for $weekday failed (${e.statusCode}); keeping the rest of the week");
      }
    }
    return _groupByWeekday(dated, loggedUser);
  }

  /// `Mondays` / `Monday` → the display key, or `null` when the payload has no
  /// usable weekday (an undated card in a day-grid is worse than none).
  String? _weekdayName(String day) {
    String normalized = day.trim().toLowerCase();
    if (normalized.endsWith('s')) normalized = normalized.substring(0, normalized.length - 1);
    if (!_weekdays.contains(normalized)) return null;
    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }

  /// Jikan schedule node → the domain record. Genres/popularity/season/duration
  /// are not part of the trimmed schedule node, so they stay unset rather than
  /// invented; the id is the MAL-native id like every other MAL record.
  Anime _calendarAnime(JikanScheduleData entry) {
    final String medium =
        entry.images.jpg.imageUrl.isNotEmpty ? entry.images.jpg.imageUrl : entry.images.jpg.smallImageUrl;
    return MalAnimeModel.fromParts(
      id: entry.malId,
      title: entry.title,
      english: '',
      nativeTitle: '',
      largePicture: entry.images.jpg.largeImageUrl,
      mediumPicture: medium,
      description: entry.synopsis,
      mean: entry.score,
      startDate: entry.aired.from,
      endDate: '',
      episodes: entry.episodes,
      genres: const <String>[],
      mediaType: entry.type.toLowerCase(),
      status: _jikanStatus(entry.status),
      rating: _jikanRating(entry.rating),
      nsfw: '',
      popularity: 0,
      season: '',
      duration: 0,
    );
  }

  /// Jikan spells statuses as prose (`Currently Airing`) while the mapper reads
  /// MAL's wire enum; fold the prose back onto the wire value first.
  String _jikanStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'currently airing':
        return 'currently_airing';
      case 'finished airing':
        return 'finished_airing';
      case 'not yet aired':
        return 'not_yet_aired';
      default:
        return status.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    }
  }

  /// Jikan ratings are prose (`Rx - Hentai`, `PG-13 - Teens 13 or older`); the
  /// mapper's adult test reads MAL's short code, so take the prefix.
  String _jikanRating(String rating) {
    final String normalized = rating.trim().toLowerCase();
    if (normalized.startsWith('rx')) return 'rx';
    if (normalized.startsWith('r+')) return 'r+';
    if (normalized.startsWith('pg-13')) return 'pg_13';
    if (normalized.startsWith('pg')) return 'pg';
    if (normalized.startsWith('r')) return 'r';
    if (normalized.startsWith('g')) return 'g';
    return '';
  }

  /// Groups by weekday (Monday → Sunday, chronological) and sorts each bucket by
  /// the broadcast time; the NSFW gate runs before bucketing.
  Map<String, List<Anime>> _groupByWeekday(
    List<({String day, String time, Anime anime})> dated,
    User loggedUser,
  ) {
    final Map<String, List<({String time, Anime anime})>> byDay =
        <String, List<({String time, Anime anime})>>{};
    for (final ({String day, String time, Anime anime}) entry in dated) {
      if (entry.anime.isAdult && !loggedUser.settings.enableNsfwContent) continue;
      (byDay[entry.day] ??= <({String time, Anime anime})>[])
          .add((time: entry.time, anime: entry.anime));
    }
    final Map<String, List<Anime>> calendar = <String, List<Anime>>{};
    for (final String weekday in _weekdays) {
      final String key = '${weekday[0].toUpperCase()}${weekday.substring(1)}';
      final List<({String time, Anime anime})>? entries = byDay[key];
      if (entries == null || entries.isEmpty) continue;
      entries.sort((({String time, Anime anime}) a, ({String time, Anime anime}) b) {
        // Empty slots sort last; `HH:mm` compares correctly as a string.
        final String left = a.time.isEmpty ? '99:99' : a.time;
        final String right = b.time.isEmpty ? '99:99' : b.time;
        return left.compareTo(right);
      });
      calendar[key] = entries.map((({String time, Anime anime}) entry) => entry.anime).toList();
    }
    return calendar;
  }
}

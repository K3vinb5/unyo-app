// External dependencies
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_details_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_list_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_calendar_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_genres_list_query_entity.dart';
import 'package:unyo/core/services/api/graphql/graphql_response.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/graphql/queries/shikimori_queries.dart' as shikimori_queries;
import 'package:unyo/core/services/api/graphql/queries/shikimori_search_parameters.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_anime_details.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';
import 'package:unyo/data/repositories/repository_mixin.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';

/// Shikimori metadata provider.
///
/// GraphQL (`https://shikimori.io/api/graphql`) for every list, the advanced
/// search and the details; REST (`GET /api/calendar`) for the calendar, because
/// the schema has no calendar root field (WP #64 §5). List-entry writes/reads
/// are subpart (c) and stay honest stubs here.
class AnimeRepositoryShikimori with RepositoryMixin implements AnimeRepository {
  /// Shikimori caps `limit` at 50.
  static const int pageSize = 50;

  final GraphQLService _shikimoriGraphQLService = sl<GraphQLService>(
    instanceName: config.shikimoriGraphQlService,
  );
  final HttpService _httpService = sl<HttpService>();
  final Logger _logger = sl<Logger>();

  /// `graphql` genre **names** (lower-cased) → genre ids, filled by
  /// [getUserAnimeAdvancedSearchFilters] and lazily by the search itself.
  /// The anime and manga genre id spaces differ, so each repository keeps its
  /// own map.
  final Map<String, String> _genreIdsByName = <String, String>{};


  /// The API bans IPs that call it without a meaningful `User-Agent`
  /// (`/api/doc` § Requirements), so it goes on every request.
  Map<String, String> get _requestHeaders => config.shikimoriRequestHeaders;

  @override
  Future<(bool, AnimeDetails)> getAnimeDetails(Anime selectedAnime, User loggedUser, {Service? service}) async {
    _logger.i("Fetching Anime Details from Shikimori for ${selectedAnime.title.userPreferred}");
    final ApiGraphQLResponse<AnimeDetailsQueryEntity> animeDetailsQueryResponse =
        await _shikimoriGraphQLService.query<AnimeDetailsQueryEntity>(
      query: shikimori_queries.shikimoriAnimeDetailsQuery,
      fromJson: AnimeDetailsQueryEntity.fromJson,
      headers: _requestHeaders,
      variables: {"ids": selectedAnime.id.toString(), "page": 1, "limit": 20},
    );
    throwIfGraphQlError(animeDetailsQueryResponse);
    if (animeDetailsQueryResponse.data.animes.isEmpty) {
      return (false, ShikimoriAnimeDetailsModel.empty());
    }
    final AnimeDetails animeDetails = ShikimoriAnimeDetailsModel.fromAnimeDetailsQuery(
      animeDetailsQueryResponse.data,
    );
    return (true, animeDetails);
  }

  /// WP #64 subpart (b): Shikimori has no GraphQL calendar; the only real source
  /// is REST `GET /api/calendar` — a **flat, unpaginated** array of up to ~100
  /// upcoming episodes (`raws/api/rest-calendar.json`, 94 entries), one object
  /// per episode, no per-day grouping and no `mal_id`. Day-grouping therefore
  /// happens here, with the same `DateFormat` key the AniList calendar emits so
  /// the screen never branches on the provider.
  ///
  /// `page` exists only because the repository interface has it: `/api/calendar`
  /// answers everything in one call, so any page but the first is empty.
  @override
  Future<Map<String, List<Anime>>> getCalendarReleases(int page, User loggedUser) async {
    if (page > 1) return <String, List<Anime>>{};
    _logger.i("Fetching Shikimori calendar releases");
    final ApiResponse<ShikimoriCalendarQueryEntity> response = await _httpService.get<ShikimoriCalendarQueryEntity>(
      config.shikimoriCalendarEndpoint,
      headers: _requestHeaders,
      fromJson: ShikimoriCalendarQueryEntity.fromJson,
    );
    final List<Anime> releases = response.data.list
        .where((ShikimoriCalendarQueryList entry) => entry.anime.id > 0)
        .map((ShikimoriCalendarQueryList entry) => ShikimoriAnimeModel.fromCalendarEntry(entry))
        // An entry without a parseable `next_episode_at` cannot be placed on a
        // day, and an undated card in a date-grouped grid is worse than none.
        .where((Anime anime) => anime.nextAiringEpisode.airingAt.isNotEmpty)
        .toList();
    if (!loggedUser.settings.enableNsfwContent && releases.isNotEmpty) {
      _logger.w(
        "Shikimori /api/calendar carries no adult marker, so this feed cannot be "
        "NSFW-filtered (${releases.length} entries left unfiltered)",
      );
    }
    return _groupByDay(visibleCalendarEntries(releases, loggedUser));
  }

  /// Groups by local calendar day and orders both axes — days ascending,
  /// episodes inside a day by airing time.
  ///
  /// The key uses the same `EEEE, MMMM d, y` pattern as the AniList calendar so
  /// the screen renders provider-agnostic buckets. It deliberately does **not**
  /// pass a locale tag: the app never calls `initializeDateFormatting`, so a
  /// tagged `DateFormat` throws `LocaleDataException` and the default (en_US)
  /// symbols are the only ones guaranteed to be registered.
  Map<String, List<Anime>> _groupByDay(List<Anime> releases) {
    final Map<DateTime, List<Anime>> byDay = <DateTime, List<Anime>>{};
    for (final Anime anime in releases) {
      final DateTime airingAt = DateTime.fromMillisecondsSinceEpoch(
        int.parse(anime.nextAiringEpisode.airingAt) * 1000,
      );
      final DateTime day = DateTime(airingAt.year, airingAt.month, airingAt.day);
      (byDay[day] ??= <Anime>[]).add(anime);
    }
    final DateFormat formatter = DateFormat('EEEE, MMMM d, y');
    final Map<String, List<Anime>> calendarReleases = <String, List<Anime>>{};
    final List<DateTime> days = byDay.keys.toList()..sort();
    for (final DateTime day in days) {
      final List<Anime> animes = byDay[day]!
        ..sort((Anime a, Anime b) => int.parse(a.nextAiringEpisode.airingAt)
            .compareTo(int.parse(b.nextAiringEpisode.airingAt)));
      calendarReleases[formatter.format(day)] = animes;
    }
    return calendarReleases;
  }

  @override
  Future<(bool, List<Anime>)> getPopularAnimes(int page, User loggedUser, {bool ignoreCache = false}) async {
    _logger.i("Fetching Shikimori popular animes");
    return _fetchAnimes(page: page, order: 'popularity', loggedUser: loggedUser, ignoreCache: ignoreCache);
  }

  /// Finished releases, newest update first. Deliberately **no** `season`
  /// filter: a show that ended last season is still a recent completion, and
  /// the old season filter hid every long-running title.
  @override
  Future<(bool, List<Anime>)> getRecentlyCompletedAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching Shikimori recently completed animes");
    return _fetchAnimes(
      page: page,
      order: 'updated_at_desc',
      status: 'released',
      loggedUser: loggedUser,
      ignoreCache: ignoreCache,
    );
  }

  /// Currently airing shows, newest update first — the Shikimori counterpart of
  /// the AniList airing-schedule feed. No `season` filter, otherwise ongoing
  /// shows from previous seasons (long-runners) disappear.
  @override
  Future<(bool, List<Anime>)> getRecentlyReleasedAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching Shikimori recently released animes");
    return _fetchAnimes(
      page: page,
      order: 'updated_at_desc',
      status: 'ongoing',
      loggedUser: loggedUser,
      ignoreCache: ignoreCache,
    );
  }

  @override
  Future<(bool, List<Anime>)> getTrendingAnimes(int page, User loggedUser, {bool ignoreCache = false}) async {
    _logger.i("Fetching Shikimori trending animes");
    return _fetchAnimes(
      page: page,
      order: 'popularity',
      season: _getCurrentSeason(DateTime.now()),
      loggedUser: loggedUser,
      ignoreCache: ignoreCache,
    );
  }

  /// Announced, not yet aired (`status: anons`). The previous implementation
  /// sorted by `aired_on` without any status filter, so it returned old shows.
  @override
  Future<(bool, List<Anime>)> getUpcomingAnimes(int page, User loggedUser, {bool ignoreCache = false}) async {
    _logger.i("Fetching Shikimori upcoming animes");
    return _fetchAnimes(
      page: page,
      order: 'popularity',
      status: 'anons',
      loggedUser: loggedUser,
      ignoreCache: ignoreCache,
    );
  }

  /// Generated from `genres(entryType: Anime)` (PascalCase enum value) plus the
  /// kind/status/season/sort dictionaries.
  ///
  /// Every implemented capability is exposed as `(true, …)` so the UI can
  /// render it: `years` is a real choice list because the schema's
  /// `SeasonString` accepts `fall_2023`, i.e. season **plus** year
  /// ([ShikimoriSearchParameters.seasonFor]). A year without a season is still
  /// not expressible — there is no year argument — so the repository logs and
  /// ignores a year-only selection ([performAnimeAdvancedSearch]).
  ///
  /// `sortOrders` stays hidden (`false`): `OrderEnum` has exactly two `_desc`
  /// twins, `id_desc` and `updated_at_desc`, and neither `id` nor `updated_at`
  /// is an option of [ShikimoriSortOptions], so no direction the user could pick
  /// would reach the server. The sort FIELD picker is unaffected — the screens
  /// gate the two dictionaries independently ([AdvancedSearchSortRow]).
  @override
  Future<Map<String, (bool, List<String>)>> getUserAnimeAdvancedSearchFilters(User loggedUser) async {
    final List<ShikimoriGenresListQueryGenres> genres = await _loadGenres(ShikimoriGenreEntryType.anime);
    final List<String> genreNames = genres
        .map((ShikimoriGenresListQueryGenres genre) => genre.name.trim())
        .where((String name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return <String, (bool, List<String>)>{
      'genres': (true, genreNames),
      'seasons': (true, ShikimoriSeasonFilters.values.map((ShikimoriSeasonFilters value) => ShikimoriSearchParameters.label(value.name)).toList()),
      'formats': (true, ShikimoriFormatFilters.values.map((ShikimoriFormatFilters value) => ShikimoriSearchParameters.label(value.name)).toList()),
      'airingStatuses': (true, ShikimoriAiringStatusFilters.values.map((ShikimoriAiringStatusFilters value) => ShikimoriSearchParameters.label(value.name)).toList()),
      'sortOptions': (true, ShikimoriSortOptions.values.map((ShikimoriSortOptions value) => ShikimoriSearchParameters.label(value.name)).toList()),
      'sortOrders': (false, <String>[]),
      'years': (true, ShikimoriSearchParameters.years()),
    };
  }

  /// One `animes(...)` page with every filter the schema accepts.
  ///
  /// Only the filters the user actually set are sent: an omitted variable means
  /// "do not filter". Genre labels are translated to genre ids (the server
  /// matches ids only — `genre: "action"` returns an empty list), `score` is an
  /// `Int`, and `order` is collapsed onto the accepted `OrderEnum` literals.
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
    _logger.i("Performing advanced anime search on Shikimori");
    final String? genre = selectedGenres.isEmpty
        ? null
        : ShikimoriSearchParameters.genreIdsFor(selectedGenres, await _genreIds());
    final String? season = ShikimoriSearchParameters.seasonFor(
      selectedSeason,
      selectedYear,
      ShikimoriSeasonFilters.values.map((ShikimoriSeasonFilters value) => value.name),
    );
    if (season == null && selectedYear != null) {
      _logger.w("Shikimori cannot filter by year alone (no year argument); ignoring $selectedYear");
    }
    final ApiGraphQLResponse<AnimeListQueryEntity> response =
        await _shikimoriGraphQLService.query<AnimeListQueryEntity>(
      query: shikimori_queries.shikimoriAnimeListQuery,
      fromJson: AnimeListQueryEntity.fromJson,
      headers: _requestHeaders,
      variables: <String, dynamic>{
        'page': page,
        'limit': pageSize,
        'order': ShikimoriSearchParameters.orderFor(sort),
        'kind': ShikimoriSearchParameters.choiceFor(
          selectedFormat,
          ShikimoriFormatFilters.values.map((ShikimoriFormatFilters value) => value.name),
        ),
        'status': ShikimoriSearchParameters.choiceFor(
          selectedAiringStatus,
          ShikimoriAiringStatusFilters.values.map((ShikimoriAiringStatusFilters value) => value.name),
        ),
        'season': season,
        'search': query.trim().isEmpty ? null : query.trim(),
        'genre': genre,
        'censored': loggedUser.settings.enableNsfwContent ? null : false,
      },
    );
    throwIfGraphQlError(response);
    return response.data.animes
        .map((AnimeListQueryAnimes entry) => ShikimoriAnimeModel.fromListEntry(entry))
        .toList();
  }

  /// `genres(entryType: Anime|Manga)` — the values are PascalCase
  /// (`GenreEntryTypeEnum`), lowercase and SCREAMING_CASE are rejected.
  Future<List<ShikimoriGenresListQueryGenres>> _fetchGenres(ShikimoriGenreEntryType entryType) async {
    final ApiGraphQLResponse<ShikimoriGenresListQueryEntity> response =
        await _shikimoriGraphQLService.query<ShikimoriGenresListQueryEntity>(
      query: shikimori_queries.shikimoriGenresListQuery,
      fromJson: ShikimoriGenresListQueryEntity.fromJson,
      headers: _requestHeaders,
      variables: <String, dynamic>{'entryType': entryType.graphqlValue},
    );
    throwIfGraphQlError(response);
    return response.data.genres;
  }

  /// The name→id map, fetched on first use when the filter dictionary has not
  /// been requested yet (the search must not depend on screen init order).
  Future<Map<String, String>> _genreIds() async {
    if (_genreIdsByName.isEmpty) {
      await _loadGenres(ShikimoriGenreEntryType.anime);
    }
    return _genreIdsByName;
  }

  /// Fetches one genre dictionary and remembers the name→id map.
  Future<List<ShikimoriGenresListQueryGenres>> _loadGenres(ShikimoriGenreEntryType entryType) async {
    final List<ShikimoriGenresListQueryGenres> genres = await _fetchGenres(entryType);
    _genreIdsByName
      ..clear()
      ..addEntries(
        genres.map((ShikimoriGenresListQueryGenres genre) => MapEntry<String, String>(
              genre.name.trim().toLowerCase(),
              genre.id,
            )),
      );
    return genres;
  }

  @override
  Future<List<String>> getMediaCoverImages(User loggedUser, {bool ignoreCache = false}) async {
    _logger.i("Fetching Media Cover Images from Shikimori");
    final (bool hasNext, List<Anime> animes) = await getPopularAnimes(1, loggedUser, ignoreCache: ignoreCache);
    return animes
        .map((Anime anime) => anime.coverImage)
        .where((String coverImage) => coverImage != "")
        .shuffled(Random())
        .toList();
  }

  /// WP #64 subpart (c): writes go to REST v2 `/api/v2/user_rates` once the
  /// Shikimori OAuth token exists.
  @override
  Future<MediaListEntry> updateMediaListEntry(
    MediaListEntry newMediaListEntry,
    Anime selectedAnime,
    User loggedUser,
  ) async {
    _logger.i("Updating Media List Entry to $newMediaListEntry on Shikimori");
    return MediaListEntryModel.empty();
  }

  /// WP #64 subpart (c). The details query already carries the viewer's own
  /// `userRate`; without an OAuth token it is `null`.
  @override
  Future<MediaListEntry> getMediaListEntry(
    Anime selectedAnime,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching User Media List Entry from Shikimori for ${selectedAnime.title.userPreferred}");
    return MediaListEntryModel.empty();
  }

  /// One page of `animes(...)` with only the filters the carousel asked for.
  Future<(bool, List<Anime>)> _fetchAnimes({
    required int page,
    required String order,
    required User loggedUser,
    required bool ignoreCache,
    String? status,
    String? season,
  }) async {
    final ApiGraphQLResponse<AnimeListQueryEntity> animeListQueryResponse =
        await _shikimoriGraphQLService.query<AnimeListQueryEntity>(
      query: shikimori_queries.shikimoriAnimeListQuery,
      fromJson: AnimeListQueryEntity.fromJson,
      headers: _requestHeaders,
      variables: {
        "page": page,
        "limit": pageSize,
        "order": order,
        "status": status,
        "season": season,
        "censored": loggedUser.settings.enableNsfwContent ? null : false,
      },
      ignoreCache: ignoreCache,
    );
    throwIfGraphQlError(animeListQueryResponse);
    final List<Anime> animes = animeListQueryResponse.data.animes
        .map((AnimeListQueryAnimes entry) => ShikimoriAnimeModel.fromListEntry(entry))
        .toList();
    return (true, animes);
  }

  String _getCurrentSeason(DateTime date) {
    final int month = date.month;
    String season;
    if (month >= 1 && month <= 3) {
      season = 'winter';
    } else if (month >= 4 && month <= 6) {
      season = 'spring';
    } else if (month >= 7 && month <= 9) {
      season = 'summer';
    } else {
      season = 'fall';
    }
    return "${season}_${date.year}";
  }
}

enum ShikimoriSeasonFilters { winter, spring, summer, fall }

enum ShikimoriFormatFilters { tv, movie, tv_special, special, ova, ona, music }

enum ShikimoriAiringStatusFilters { ongoing, released, anons }

enum ShikimoriSortOptions {
  popularity,
  ranked,
  name,
  aired_on,
  episodes,
  status,
}

/// NSFW gate for the Shikimori calendar, the same shape
/// `AnimeRepositoryAnilist.getCalendarReleases` applies
/// (`isAdult && !enableNsfwContent` → dropped).
///
/// `/api/calendar` carries **no** adult marker: the live capture
/// (`research/unyo-64-shikimori-parity-proof/raws/api/rest-calendar.json`, 94
/// entries) has exactly `id, name, russian, image, url, kind, score, status,
/// episodes, episodes_aired, aired_on, released_on` per anime — no `rating`, no
/// `is_censored`. [ShikimoriAnimeModel.fromCalendarEntry] therefore maps
/// [Anime.isAdult] to its only honest value (`false`) and this filter is a
/// no-op for the feed as mapped today: the expression is here so the moment the
/// payload (or a companion lookup) yields a real flag, the calendar honours
/// `settings.enableNsfwContent` without another call-site change. The residual
/// gap — adult calendar entries are not filtered — is documented in PR #156.
List<Anime> visibleCalendarEntries(List<Anime> entries, User loggedUser) {
  return entries
      .where((Anime anime) => !anime.isAdult || loggedUser.settings.enableNsfwContent)
      .toList();
}

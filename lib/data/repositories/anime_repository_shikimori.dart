// External dependencies
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_details_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_list_query_entity.dart';
import 'package:unyo/core/services/api/graphql/graphql_response.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/graphql/queries/shikimori_queries.dart' as shikimori_queries;
import 'package:unyo/data/models/shikimori/media/shikimori_anime_details.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';
import 'package:unyo/data/repositories/repository_mixin.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';

/// Shikimori metadata provider (GraphQL, <https://shikimori.io/api/graphql>).
///
/// Every list is one document ([shikimori_queries.shikimoriAnimeListQuery]) with
/// different server-side filters; the mappers live in
/// `data/models/shikimori/media/`. Calendar and advanced search are WP #64
/// subpart (b), list-entry writes/reads subpart (c) — they stay honest stubs
/// here.
class AnimeRepositoryShikimori with RepositoryMixin implements AnimeRepository {
  /// Shikimori caps `limit` at 50.
  static const int pageSize = 50;

  final GraphQLService _shikimoriGraphQLService = sl<GraphQLService>(
    instanceName: config.shikimoriGraphQlService,
  );
  final Logger _logger = sl<Logger>();

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
  /// is REST `/api/calendar` (94-entry flat array, evidence in
  /// `research/unyo-64-shikimori-parity-proof/raws/api/rest-calendar.json`).
  @override
  Future<Map<String, List<Anime>>> getCalendarReleases(int page, User loggedUser) async {
    return {};
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

  /// WP #64 subpart (b): generated from `genres(entryType: Anime)` plus the
  /// kind/status/season dictionaries.
  @override
  Future<Map<String, (bool, List<String>)>> getUserAnimeAdvancedSearchFilters() async {
    return {};
  }

  /// WP #64 subpart (b).
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
    return <Anime>[];
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

enum ShikimoriSortOrder { asc, desc }

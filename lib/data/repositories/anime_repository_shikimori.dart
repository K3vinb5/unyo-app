// External dependencies
import 'package:unyo/core/enums/service.dart';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_details_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_popular_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_recently_released_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_trending_query_entity.dart';
import 'package:unyo/core/services/api/graphql/graphql_response.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/graphql/queries/shikimori_queries.dart' as shikimori_queries;
import 'package:unyo/data/models/shikimori/media/shikimori_anime_details.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';
import 'package:unyo/data/repositories/repository_mixin.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';

class AnimeRepositoryShikimori with RepositoryMixin implements AnimeRepository {
  final GraphQLService _shikimoriGraphQLService = sl<GraphQLService>(
    instanceName: config.shikimoriGraphQlService,
  );
  final Logger _logger = sl<Logger>();

  @override
  Future<(bool, AnimeDetails)> getAnimeDetails(Anime selectedAnime, User loggedUser, {Service? service}) async {
    // TODO uncomment when ShikimoriUserModel exists
    // Map<String, String>? graphQlHeaders = loggedUser is ShikimoriUserModel
    //     ? {"Authorization": "Bearer ${(loggedUser).accessToken}"}
    //     : null;
    ApiGraphQLResponse<AnimeDetailsQueryEntity> animeDetailsQueryResponse = await _shikimoriGraphQLService
        .query<AnimeDetailsQueryEntity>(
          query: shikimori_queries.shikimoriAnimeDetailsQuery,
          fromJson: AnimeDetailsQueryEntity.fromJson,
          variables: {"ids": selectedAnime.id.toString(), "page": 1, "limit": 20},
          // headers: graphQlHeaders,
        );
    throwIfGraphQlError(animeDetailsQueryResponse);
    AnimeDetails animeDetails = ShikimoriAnimeDetailsModel.fromAnimeDetailsQuery(
      animeDetailsQueryResponse.data,
    );
    return (true, animeDetails);
  }

  @override
  Future<Map<String, List<Anime>>> getCalendarReleases(int page, User loggedUser) async {
    // TODO: implement getCalendarReleases
    return {};
  }

  @override
  Future<(bool, List<Anime>)> getPopularAnimes(int page, User loggedUser, {bool ignoreCache = false}) async {
    // TODO uncomment when ShikimoriUserModel exists
    // Map<String, String>? graphQlHeaders = loggedUser is ShikimoriUserModel
    //     ? {"Authorization": "Bearer ${(loggedUser).accessToken}"}
    //     : null;
    ApiGraphQLResponse<AnimePopularQueryEntity> animePopularQueryResponse = await _shikimoriGraphQLService
        .query<AnimePopularQueryEntity>(
          query: shikimori_queries.animeUpcomingOrPopularQuery,
          fromJson: AnimePopularQueryEntity.fromJson,
          variables: {"page": page, "limit": 50, "order": "popularity"},
          // headers: graphQlHeaders,
          ignoreCache: ignoreCache,
        );
    throwIfGraphQlError(animePopularQueryResponse);
    List<Anime> animes = animePopularQueryResponse.data.animes
        .map((anime) => ShikimoriAnimeModel.fromAnimesPopularQuery(anime))
        .toList();
    return (true, animes);
  }

  @override
  Future<(bool, List<Anime>)> getRecentlyCompletedAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    // TODO uncomment when ShikimoriUserModel exists
    // Map<String, String>? graphQlHeaders = loggedUser is ShikimoriUserModel
    //     ? {"Authorization": "Bearer ${(loggedUser).accessToken}"}
    //     : null;
    ApiGraphQLResponse<AnimeRecentlyReleasedQueryEntity> animeRecentlyCompletedQueryResponse = await _shikimoriGraphQLService
        .query<AnimeRecentlyReleasedQueryEntity>(
      query: shikimori_queries.animeRecentlyReleasedOrRecentlyCompletedQuery,
      fromJson: AnimeRecentlyReleasedQueryEntity.fromJson,
      variables: {
        "page": page,
        "limit": 50,
        "order": "popularity",
        "season": _getCurrentSeason(DateTime.now()),
        "status": "released"
      },
      // headers: graphQlHeaders,
      ignoreCache: ignoreCache,
    );
    throwIfGraphQlError(animeRecentlyCompletedQueryResponse);
    List<Anime> animes = animeRecentlyCompletedQueryResponse.data.animes
        .map((anime) => ShikimoriAnimeModel.fromAnimesRecentlyReleasedQuery(anime))
        .toList();
    return (true, animes);
  }

  @override
  Future<(bool, List<Anime>)> getRecentlyReleasedAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    // TODO uncomment when ShikimoriUserModel exists
    // Map<String, String>? graphQlHeaders = loggedUser is ShikimoriUserModel
    //     ? {"Authorization": "Bearer ${(loggedUser).accessToken}"}
    //     : null;
    ApiGraphQLResponse<AnimeRecentlyReleasedQueryEntity> animeRecentlyCompletedQueryResponse = await _shikimoriGraphQLService
        .query<AnimeRecentlyReleasedQueryEntity>(
      query: shikimori_queries.animeRecentlyReleasedOrRecentlyCompletedQuery,
      fromJson: AnimeRecentlyReleasedQueryEntity.fromJson,
      variables: {
        "page": page,
        "limit": 50,
        "order": "updated_at",
        "season": _getCurrentSeason(DateTime.now()),
        "status": "ongoing"
      },
      // headers: graphQlHeaders,
      ignoreCache: ignoreCache,
    );
    throwIfGraphQlError(animeRecentlyCompletedQueryResponse);
    List<Anime> animes = animeRecentlyCompletedQueryResponse.data.animes
        .map((anime) => ShikimoriAnimeModel.fromAnimesRecentlyReleasedQuery(anime))
        .toList();
    return (true, animes);
  }

  @override
  Future<(bool, List<Anime>)> getTrendingAnimes(int page, User loggedUser, {bool ignoreCache = false}) async {
    // TODO uncomment when ShikimoriUserModel exists
    // Map<String, String>? graphQlHeaders = loggedUser is ShikimoriUserModel
    //     ? {"Authorization": "Bearer ${(loggedUser).accessToken}"}
    //     : null;
    print("THIS: ${_getCurrentSeason(DateTime.now())}");
    ApiGraphQLResponse<AnimeTrendingQueryEntity> animeTrendingQueryResponse = await _shikimoriGraphQLService
        .query<AnimeTrendingQueryEntity>(
      query: shikimori_queries.animeTrendingQuery,
      fromJson: AnimeTrendingQueryEntity.fromJson,
      variables: {
        "page": page,
        "limit": 50,
        "order": "popularity",
        "season": _getCurrentSeason(DateTime.now())
      },
      // headers: graphQlHeaders,
      ignoreCache: ignoreCache,
    );
    throwIfGraphQlError(animeTrendingQueryResponse);
    List<Anime> animes = animeTrendingQueryResponse.data.animes
        .map((anime) => ShikimoriAnimeModel.fromAnimesTrendingQuery(anime))
        .toList();
    return (true, animes);
  }

  @override
  Future<(bool, List<Anime>)> getUpcomingAnimes(int page, User loggedUser, {bool ignoreCache = false}) async {
    // TODO uncomment when ShikimoriUserModel exists
    // Map<String, String>? graphQlHeaders = loggedUser is ShikimoriUserModel
    //     ? {"Authorization": "Bearer ${(loggedUser).accessToken}"}
    //     : null;
    ApiGraphQLResponse<AnimePopularQueryEntity> animeUpcomingQueryResponse = await _shikimoriGraphQLService
        .query<AnimePopularQueryEntity>(
      query: shikimori_queries.animeUpcomingOrPopularQuery,
      fromJson: AnimePopularQueryEntity.fromJson,
      variables: {"page": page, "limit": 50, "order": "aired_on"},
      // headers: graphQlHeaders,
      ignoreCache: ignoreCache,
    );
    throwIfGraphQlError(animeUpcomingQueryResponse);
    List<Anime> animes = animeUpcomingQueryResponse.data.animes
        .map((anime) => ShikimoriAnimeModel.fromAnimesPopularQuery(anime))
        .toList();
    return (true, animes);
  }

  @override
  Future<Map<String, (bool, List<String>)>> getUserAnimeAdvancedSearchFilters() async {
    return {};
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
    // TODO: implement performAnimeAdvancedSearch
    return <Anime>[];
  }

  // @override
  // Future<Map<String, List<Anime>>> getCalendarReleases(int page, User loggedUser) async {
  //   _logger.i("Fetching Shikimori calendar releases");
  //   final response = await _shikimoriGraphQLService.query<ShikimoriAnimeListGraphqlEntity>(
  //     query: shikimori_queries.shikimoriAnimeListQuery,
  //     fromJson: ShikimoriAnimeListGraphqlEntity.fromJson,
  //     variables: {
  //       "page": page,
  //       "limit": 50,
  //       "order": "ranked",
  //       "status": "ongoing",
  //       "censored": loggedUser.settings.enableNsfwContent ? null : false,
  //     },
  //   );
  //   throwIfGraphQlError(response);
  //   final localeTag = loggedUser.settings.language;
  //   final calendarReleases = <String, List<Anime>>{};
  //   for (final entry in response.data.animes) {
  //     final anime = ShikimoriAnimeModel.fromListEntry(entry);
  //     if (anime.isAdult && !loggedUser.settings.enableNsfwContent) continue;
  //     if (entry.nextEpisodeAt != null) {
  //       final episodeRelease = DateTime.parse(entry.nextEpisodeAt.toString());
  //       final dateKey = DateFormat('EEEE, MMMM d, y', localeTag).format(episodeRelease);
  //       if (!calendarReleases.containsKey(dateKey)) {
  //         calendarReleases[dateKey] = [anime];
  //       } else {
  //         calendarReleases[dateKey]!.add(anime);
  //       }
  //     }
  //   }
  //   // Sort each list by airing time
  //   calendarReleases.forEach((date, animeList) {
  //     animeList.sort((a, b) => a.nextAiringEpisode.airingAt.compareTo(b.nextAiringEpisode.airingAt));
  //   });
  //   // Sort map entries by date
  //   final sortedEntries = calendarReleases.entries.toList()
  //     ..sort((a, b) {
  //       final dateA = DateFormat('EEEE, MMMM d, y', localeTag).parse(a.key);
  //       final dateB = DateFormat('EEEE, MMMM d, y', localeTag).parse(b.key);
  //       return dateA.millisecondsSinceEpoch.compareTo(dateB.millisecondsSinceEpoch);
  //     });
  //   return Map.fromEntries(sortedEntries);
  // }

  @override
  Future<List<String>> getMediaCoverImages(User loggedUser, {bool ignoreCache = false}) async {
    _logger.i("Fetching Media Cover Images from Shikimori");
    final (hasNext, animes) = await getPopularAnimes(1, loggedUser, ignoreCache: ignoreCache);
    return animes
        .map((anime) => anime.coverImage)
        .where((coverImage) => coverImage != "")
        .shuffled(Random())
        .toList();
  }

  @override
  Future<MediaListEntry> updateMediaListEntry(
    MediaListEntry newMediaListEntry,
    Anime selectedAnime,
    User loggedUser,
  ) async {
    _logger.i("Updating Media List Entry to $newMediaListEntry on Shikimori");
    return MediaListEntryModel.empty();
  }

  @override
  Future<MediaListEntry> getMediaListEntry(
    Anime selectedAnime,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching User Media List Entry from Shikimori for ${selectedAnime.title.userPreferred}");
    return MediaListEntryModel.empty();
  }

  String _getCurrentSeason(DateTime date) {
    final month = date.month;
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

  String _mapSortToShikimori(String sort) {
    // sort comes as "popularity_desc" or "score_desc" etc.
    final parts = sort.toLowerCase().split('_');
    if (parts.length < 2) return 'popularity';
    final field = parts.first;
    switch (field) {
      case 'popularity':
        return 'popularity';
      case 'score':
        return 'ranked';
      case 'startdate':
      case 'start_date':
        return 'aired_on';
      case 'enddate':
      case 'end_date':
        return 'aired_on';
      case 'title':
        return 'name';
      case 'episodes':
        return 'episodes';
      case 'status':
        return 'status';
      case 'trending':
        return 'popularity';
      default:
        return 'popularity';
    }
  }

  String _mapAiringStatusToShikimori(String status) {
    switch (status.toLowerCase().replaceAll(' ', '_')) {
      case 'releasing':
        return 'ongoing';
      case 'finished':
        return 'released';
      case 'not_yet_released':
        return 'anons';
      case 'cancelled':
        return 'released'; // Shikimori doesn't have cancelled
      default:
        return status.toLowerCase();
    }
  }

  String _mapFormatToShikimoriKind(String format) {
    switch (format.toLowerCase().replaceAll(' ', '_')) {
      case 'tv':
        return 'tv';
      case 'tv_short':
        return 'tv_special';
      case 'movie':
        return 'movie';
      case 'special':
        return 'special';
      case 'ova':
        return 'ova';
      case 'ona':
        return 'ona';
      case 'music':
        return 'music';
      default:
        return format.toLowerCase().replaceAll(' ', '_');
    }
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

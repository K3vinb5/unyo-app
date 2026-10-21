// External dependencies
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:logger/logger.dart';
import 'package:unyo/core/di/locator.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/services/api/dto/anilist/media_advanced_search_query_graphql_entity.dart';
import 'package:unyo/core/services/api/dto/anilist/media_collection_recently_completed_graphql_entity.dart';
import 'package:unyo/core/services/api/dto/anilist/media_collection_trendingOrPopular_graphql_entity.dart';
import 'package:unyo/core/services/api/dto/anilist/media_collection_upcoming_graphql_entity.dart';
import 'package:unyo/core/services/api/dto/anilist/media_details_graphql_entity.dart';
import 'package:unyo/core/services/api/dto/anilist/media_details_media_list_entry_entity.dart';
import 'package:unyo/core/services/api/dto/anilist/save_media_list_entry_entity.dart';
import 'package:unyo/core/services/api/graphql/queries/anilist_queries.dart' as anilist_queries;
import 'package:unyo/core/services/api/dto/anilist/media_collection_recently_released_graphql_entity.dart';
import 'package:unyo/core/services/api/graphql/graphql_response.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/data/models/anilist/media/anilist_anime_details.dart';
import 'package:unyo/data/models/anilist/media/anilist_anime_model.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/repositories/repository_mixin.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

class AnimeRepositoryAnilist with RepositoryMixin implements AnimeRepository {
  final GraphQLService _anilistGraphQLService = sl<GraphQLService>(
    instanceName: config.anilistGraphQlService,
  );
  final Logger _logger = sl<Logger>();

  @override
  Future<(bool, List<Anime>)> getPopularAnimes(int page, User loggedUser, {bool ignoreCache = false}) async {
    ApiGraphQLResponse<MediaCollectionTrendingOrPopularGraphqlEntity> popularMediaCollection =
        await _anilistGraphQLService.query(
          query: anilist_queries.mediaTrendingOrPopularQuery,
          fromJson: MediaCollectionTrendingOrPopularGraphqlEntity.fromJson,
          variables: {
            "sort": "POPULARITY_DESC",
            "page": page,
            "perPage": 30,
            "type": "ANIME",
          },
          ignoreCache: ignoreCache,
        );
    throwIfGraphQlError(popularMediaCollection);
    List<Anime> popularAnimes =
        popularMediaCollection.data.page.media
            .map((mediaEntry) => AnilistAnimeModel.fromPopularOrTrendingMediaEntry(mediaEntry))
            .toList();
    return (true, popularAnimes);
  }

  @override
  Future<(bool, List<Anime>)> getRecentlyCompletedAnimes(int page, User loggedUser, {bool ignoreCache = false}) async {
    DateTime now = DateTime.now();
    DateTime monthAgo = now.subtract(const Duration(days: 30));
    ApiGraphQLResponse<MediaCollectionRecentlyCompletedGraphqlEntity>
    recentlyCompleted = await _anilistGraphQLService.query(
      query: anilist_queries.mediaRecentlyCompletedQuery,
      fromJson: MediaCollectionRecentlyCompletedGraphqlEntity.fromJson,
      variables: {
        "sort": "POPULARITY_DESC",
        "page": page,
        "perPage": 30,
        "endDateGreater":
            "${monthAgo.year.toString().padLeft(4, '0')}${monthAgo.month.toString().padLeft(2, '0')}${monthAgo.day.toString().padLeft(2, '0')}",
        "endDateLesser":
            "${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}",
        "type": "ANIME",
      },
      ignoreCache: ignoreCache,
    );
    throwIfGraphQlError(recentlyCompleted);
    List<Anime> recentlyCompletedAnimes =
        recentlyCompleted.data.page.media
            .map((mediaEntry) => AnilistAnimeModel.fromRecentlyCompletedMediaEntry(mediaEntry))
            .toList();
    return (true, recentlyCompletedAnimes);
  }

  @override
  Future<(bool, List<Anime>)> getRecentlyReleasedAnimes(int page, User loggedUser, {bool ignoreCache = false}) async {
    ApiGraphQLResponse<MediaCollectionRecentlyReleasedGraphqlEntity> airingSchedules =
        await _anilistGraphQLService.query(
          query: anilist_queries.animeRecentlyReleasedQuery,
          fromJson: MediaCollectionRecentlyReleasedGraphqlEntity.fromJson,
          variables: {"sort": "TIME_DESC", "page": page, "perPage": 40, "notYetAired": false},
          ignoreCache: ignoreCache,
        );
    throwIfGraphQlError(airingSchedules);
    List<Anime> recentlyReleasedAnimes =
        airingSchedules.data.page.airingSchedules
            .map((schedule) => AnilistAnimeModel.fromScheduleEntry(schedule))
            .toList();
    Map<int, Anime> uniqueRecentlyReleasedAnimes = {};
    for (var anime in recentlyReleasedAnimes) {
      if (!uniqueRecentlyReleasedAnimes.containsKey(anime.id)) {
        uniqueRecentlyReleasedAnimes[anime.id] = anime;
      }
    }
    return (true, uniqueRecentlyReleasedAnimes.values.where((anime) => !anime.isAdult || loggedUser.settings.enableNsfwContent).toList());
  }

  @override
  Future<(bool, List<Anime>)> getTrendingAnimes(int page, User loggedUser, {bool ignoreCache = false}) async {
    ApiGraphQLResponse<MediaCollectionTrendingOrPopularGraphqlEntity> trendingMediaCollection =
        await _anilistGraphQLService.query(
          query: anilist_queries.mediaTrendingOrPopularQuery,
          fromJson: MediaCollectionTrendingOrPopularGraphqlEntity.fromJson,
          variables: {
            "sort": "TRENDING_DESC",
            "page": page,
            "perPage": 30,
            "type": "ANIME",
          },
          ignoreCache: ignoreCache,
        );
    throwIfGraphQlError(trendingMediaCollection);
    List<Anime> trendingAnimes =
        trendingMediaCollection.data.page.media
            .map((mediaEntry) => AnilistAnimeModel.fromPopularOrTrendingMediaEntry(mediaEntry))
            .toList();
    return (true, trendingAnimes);
  }

  @override
  Future<(bool, List<Anime>)> getUpcomingAnimes(int page, User loggedUser, {bool ignoreCache = false}) async {
    DateTime now = DateTime.now();
    ApiGraphQLResponse<MediaCollectionUpcomingGraphqlEntity> upcoming = await _anilistGraphQLService.query(
      query: anilist_queries.mediaUpcomingQuery,
      fromJson: MediaCollectionUpcomingGraphqlEntity.fromJson,
      variables: {
        "sort": "POPULARITY_DESC",
        "page": page,
        "perPage": 30,
        "startDateGreater":
            "${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}",
        "type": "ANIME",
      },
      ignoreCache: ignoreCache
    );
    throwIfGraphQlError(upcoming);
    List<Anime> upcomingAnimes =
        upcoming.data.page.media
            .map((mediaEntry) => AnilistAnimeModel.fromUpcomingMediaEntry(mediaEntry))
            .toList();
    return (true, upcomingAnimes);
  }

  @override
  Future<Map<String, List<Anime>>> getCalendarReleases(
    int page,
    User loggedUser, {
    List<Anime>? calendarReleasePortion,
  }) async {
    List<Anime> calendarReleasesList = await _getCalendarReleasesPage(page);
    if (calendarReleasesList.length == 50) {
      // has next page
      return await getCalendarReleases(
        page + 1,
        loggedUser,
        calendarReleasePortion: [...calendarReleasesList, ...(calendarReleasePortion ?? [])],
      );
    }
    String localeTag = loggedUser.settings.language;
    Map<String, List<Anime>> calendarReleases = {};
    for (Anime anime in calendarReleasePortion ?? calendarReleasesList) {
      DateTime episodeRelease = DateTime.fromMillisecondsSinceEpoch(
        int.parse(anime.nextAiringEpisode.airingAt) * 1000,
      );
      String dateKey = DateFormat('EEEE, MMMM d, y', localeTag).format(episodeRelease);
      if (!calendarReleases.containsKey(dateKey)) {
        calendarReleases.addAll({
          dateKey: [anime],
        });
      } else {
        calendarReleases[dateKey]!.add(anime);
      }
    }
    // Sort each list by airing time
    calendarReleases.forEach((date, animeList) {
      animeList.sort((a, b) {
        return a.nextAiringEpisode.airingAt.compareTo(b.nextAiringEpisode.airingAt);
      });
    });
    // Sort the map entries by weekday and create a new ordered map
    final sortedEntries =
        calendarReleases.entries.toList()..sort((a, b) {
          // Parse the date strings to get the DateTime objects
          final dateA = DateFormat('EEEE, MMMM d, y', localeTag).parse(a.key);
          final dateB = DateFormat('EEEE, MMMM d, y', localeTag).parse(b.key);
          // Sort by the weekday (1 = Monday, 7 = Sunday)
          return dateA.millisecondsSinceEpoch.compareTo(dateB.millisecondsSinceEpoch);
        });

    // Remove isAdult animes if loggedUser.settings.enableNsfwContent is false
    for (MapEntry<String, List<Anime>> entry in sortedEntries) {
      entry.value.removeWhere((anime) => anime.isAdult && !loggedUser.settings.enableNsfwContent);
    }

    return Map.fromEntries(sortedEntries);
  }

  @override
  Future<List<String>> getMediaCoverImages(User loggedUser, {bool ignoreCache = false}) async {
    (bool, List<Anime>) popularAnimes = await getPopularAnimes(1, loggedUser, ignoreCache: ignoreCache);
    return popularAnimes.$2
        .map((anime) => anime.coverImage)
        .where((coverImage) => coverImage != "")
        .shuffled(Random())
        .toList();
  }

  @override
  Future<(bool, AnimeDetails)> getAnimeDetails(Anime selectedAnime, User loggedUser) async {
    Map<String, String>? graphQlHeaders =
        loggedUser is AnilistUserModel ? {"Authorization": "Bearer ${(loggedUser).accessToken}"} : null;
    ApiGraphQLResponse<MediaDetailsGraphqlEntity> animeDetailsData = await _anilistGraphQLService
        .query<MediaDetailsGraphqlEntity>(
          query: anilist_queries.mediaDetailsQuery,
          fromJson: MediaDetailsGraphqlEntity.fromJson,
          variables: {
            "type": "ANIME",
            "mediaId": selectedAnime.id,
            "page": 1,
            "perPage": 20,
          },
          headers: graphQlHeaders,
        );
    throwIfGraphQlError(animeDetailsData);
    ApiGraphQLResponse<MediaDetailsMediaListEntryEntity> mediaDetailsMediaListEntry =
    await _anilistGraphQLService.query<MediaDetailsMediaListEntryEntity>(
      query: anilist_queries.mediaListEntryQuery,
      fromJson: MediaDetailsMediaListEntryEntity.fromJson,
      variables: {
        "mediaId": selectedAnime.id,
      },
      headers: graphQlHeaders,
    );
    throwIfGraphQlError(mediaDetailsMediaListEntry);
    AnimeDetails animeDetails = AnilistAnimeDetailsModel.fromAnimeDetailsMediaList(
      animeDetailsData.data.media,
      mediaDetailsMediaListEntry.data,
    );
    return (true, animeDetails);
  }

  @override
  Future<Map<String, (bool, List<String>)>> getUserAnimeAdvancedSearchFilters() async {
    Map<String, (bool, List<String>)> filters = {};
    filters.addAll({
      'genres': (
        true,
        TextUtils.capitalizeList(
          AnilistGenreFilters.values
              .map((enumElement) {
                // Special handling for sci_fi to display as "Sci-fi"
                if (enumElement.name == 'sci_fi') {
                  return 'Sci-Fi';
                }
                return enumElement.name.replaceAll('_', ' ');
              })
              .toList(),
        ),
      ),
    });
    filters.addAll({
      'seasons': (
        true,
        TextUtils.capitalizeList(
          AnilistSeasonFilters.values.map((enumElement) => enumElement.name).toList(),
        ),
      ),
    });
    filters.addAll({
      'formats': (
        true,
        TextUtils.capitalizeList(
          AnilistFormatFilters.values.map((enumElement) => enumElement.name.replaceAll('_', ' ')).toList(),
        ),
      ),
    });
    filters.addAll({
      'airingStatuses': (
        true,
        TextUtils.capitalizeList(
          AnilistAiringStatusFilters.values
              .map((enumElement) => enumElement.name.replaceAll('_', ' '))
              .toList(),
        ),
      ),
    });
    filters.addAll({
      'years': (
        true,
        List<String>.generate(
          DateTime.now().year - 1939,
          (index) => (1940 + index).toString(),
        ).reversed.toList(),
      ),
    });
    filters.addAll({
      'sortOptions': (
        true,
        TextUtils.capitalizeList(
          AnilistSortOptions.values.map((enumElement) => enumElement.name.replaceAll('_', ' ')).toList(),
        ),
      ),
    });
    filters.addAll({
      'sortOrders': (
        true,
        TextUtils.capitalizeList(
          AnilistSortOrder.values.map((enumElement) => enumElement.name.replaceAll('_', ' ')).toList(),
        ),
      ),
    });
    return filters;
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
    ApiGraphQLResponse<MediaAdvancedSearchQueryGraphqlEntity> animeAdvancedSearchData =
        await _anilistGraphQLService.query<MediaAdvancedSearchQueryGraphqlEntity>(
          query: anilist_queries.mediaAdvancedSearchQuery,
          fromJson: MediaAdvancedSearchQueryGraphqlEntity.fromJson,
          variables: {
            "type": "ANIME",
            "page": 1,
            "perPage": 50,
            "sort": sort.replaceAll("_ASC", ""),
            if (query.isNotEmpty) "search": query,
            if (selectedGenres.isNotEmpty) "genres": selectedGenres,
            if (selectedSeason != null && selectedSeason.isNotEmpty) "season": selectedSeason.toUpperCase(),
            "seasonYear": ?selectedYear,
            if (selectedAiringStatus != null && selectedAiringStatus.isNotEmpty)
              "status": selectedAiringStatus.toUpperCase().replaceAll(' ', '_'),
            if (selectedFormat != null && selectedFormat.isNotEmpty)
              "format": selectedFormat.toUpperCase().replaceAll(' ', '_'),
          },
        );
    throwIfGraphQlError(animeAdvancedSearchData);
    List<Anime> searchResults =
        animeAdvancedSearchData.data.page.media
            .map((mediaEntry) => AnilistAnimeModel.fromAdvancedSearchMediaEntry(mediaEntry))
            .toList();
    return searchResults;
  }

  Future<List<Anime>> _getCalendarReleasesPage(int page) async {
    DateTime now = DateTime.now();
    // Calculate yesterday 00:00:00
    DateTime start = DateTime(now.year, now.month, now.day, 0, 0, 0, 0).subtract(const Duration(days: 1));

    // Calculate today + 6 days
    DateTime end = start.add(const Duration(days: 6));
    end = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);

    // Unix timestamps
    int startTimestamp = start.millisecondsSinceEpoch ~/ 1000;
    int endTimestamp = end.millisecondsSinceEpoch ~/ 1000;
    ApiGraphQLResponse<MediaCollectionRecentlyReleasedGraphqlEntity> airingSchedules =
        await _anilistGraphQLService.query(
          query: anilist_queries.calendarQuery,
          fromJson: MediaCollectionRecentlyReleasedGraphqlEntity.fromJson,
          variables: {
            "sort": "TIME_DESC",
            "page": page,
            "perPage": 50,
            "airingAtGreater": startTimestamp,
            "airingAtLesser": endTimestamp,
          },
        );
    throwIfGraphQlError(airingSchedules);
    return airingSchedules.data.page.airingSchedules
        .map((schedule) => AnilistAnimeModel.fromScheduleEntry(schedule))
        .toList();
  }

  @override
    Future<MediaListEntry> updateMediaListEntry(MediaListEntry newMediaListEntry, Anime selectedAnime, User loggedUser) async {
      Map<String, String>? graphQlHeaders =
      loggedUser is AnilistUserModel ? {"Authorization": "Bearer ${(loggedUser).accessToken}"} : null;
      ApiGraphQLResponse<SaveMediaListEntryEntity> saveMediaListEntry = await _anilistGraphQLService
          .mutation<SaveMediaListEntryEntity>(
        query: anilist_queries.updateMediaEntryQuery,
        fromJson: SaveMediaListEntryEntity.fromJson,
        variables: {
          "mediaId": selectedAnime.id,
          "status": newMediaListEntry.status.toUpperCase() != "ADD TO LIST" ? newMediaListEntry.status.toUpperCase() : null,
          if (newMediaListEntry.progress != -1)
            "progress": newMediaListEntry.progress,
          if (newMediaListEntry.score != -1.0)
            "score": newMediaListEntry.score,
          "startedAt": {
            "day": int.tryParse(newMediaListEntry.startedAt[0]),
            "month": int.tryParse(newMediaListEntry.startedAt[1]),
            "year": int.tryParse(newMediaListEntry.startedAt[2]),
          },
          "completedAt": {
            "day": int.tryParse(newMediaListEntry.completedAt[0]),
            "month": int.tryParse(newMediaListEntry.completedAt[1]),
            "year": int.tryParse(newMediaListEntry.completedAt[2]),
          },
        },
        headers: graphQlHeaders,
      );
      throwIfGraphQlError(saveMediaListEntry);
      return MediaListEntryModel.fromSaveMediaListEntryEntity(saveMediaListEntry.data.saveMediaListEntry);
    }

  @override
  Future<MediaListEntry> getMediaListEntry(Anime selectedAnime, User loggedUser, {bool ignoreCache = false}) async {
    Map<String, String>? graphQlHeaders =
    loggedUser is AnilistUserModel ? {"Authorization": "Bearer ${(loggedUser).accessToken}"} : null;
    ApiGraphQLResponse<MediaDetailsMediaListEntryEntity> mediaDetailsMediaListEntry =
    await _anilistGraphQLService.query<MediaDetailsMediaListEntryEntity>(
        query: anilist_queries.mediaListEntryQuery,
        fromJson: MediaDetailsMediaListEntryEntity.fromJson,
        variables: {
         "mediaId": selectedAnime.id,
        },
        headers: graphQlHeaders,
        ignoreCache: ignoreCache,
      );
    throwIfGraphQlError(mediaDetailsMediaListEntry);
    return MediaListEntryModel.fromMediaDetailsMediaListEntryEntity(mediaDetailsMediaListEntry.data);
  }
}

enum AnilistGenreFilters {
  action,
  adventure,
  comedy,
  drama,
  ecchi,
  fantasy,
  horror,
  mahou_shoujo,
  mecha,
  music,
  mystery,
  psychological,
  romance,
  sci_fi,
  slice_of_Life,
  sports,
  supernatural,
  thriller,
}

enum AnilistSeasonFilters { winter, spring, summer, fall }

enum AnilistFormatFilters { tv, movie, tv_short, special, ova, ona, music }

enum AnilistAiringStatusFilters { releasing, finished, not_yet_released, cancelled }

enum AnilistSortOptions {
  title_romaji,
  title_english,
  title_native,
  format,
  start_date,
  end_date,
  score,
  popularity,
  trending,
  episodes,
  duration,
  status,
  updated_at,
  favourites,
}

enum AnilistSortOrder { asc, desc }

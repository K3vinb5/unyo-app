// External dependencies
import 'package:unyo/core/enums/service.dart';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:logger/logger.dart';
// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/dto/anilist/media_advanced_search_query_graphql_entity.dart';
import 'package:unyo/core/services/api/dto/anilist/media_collection_recently_completed_graphql_entity.dart';
import 'package:unyo/core/services/api/dto/anilist/media_collection_trendingOrPopular_graphql_entity.dart';
import 'package:unyo/core/services/api/dto/anilist/media_collection_upcoming_graphql_entity.dart';
import 'package:unyo/core/services/api/dto/anilist/media_details_graphql_entity.dart';
import 'package:unyo/core/services/api/dto/anilist/media_details_media_list_entry_entity.dart';
import 'package:unyo/core/services/api/graphql/graphql_response.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/data/models/anilist/media/anilist_manga_details.dart';
import 'package:unyo/data/models/anilist/media/anilist_manga_model.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/repositories/repository_mixin.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

import '../../core/services/api/graphql/queries/anilist_queries.dart' as anilist_queries;

class MangaRepositoryAnilist with RepositoryMixin implements MangaRepository {
  final GraphQLService _anilistGraphQLService = sl<GraphQLService>(
    instanceName: config.anilistGraphQlService,
  );
  final Logger _logger = sl<Logger>();

  @override
  Future<(bool, List<Manga>)> getPopularMangas(int page, User loggedUser, {bool ignoreCache = false}) async {
    ApiGraphQLResponse<MediaCollectionTrendingOrPopularGraphqlEntity>
    popularMediaCollection = await _anilistGraphQLService.query(
      query: anilist_queries.mediaTrendingOrPopularQuery,
      fromJson: MediaCollectionTrendingOrPopularGraphqlEntity.fromJson,
      variables: {
        "sort": "POPULARITY_DESC",
        "page": page,
        "perPage": 30,
        "type": "MANGA",
      },
      ignoreCache: ignoreCache,
    );
    throwIfGraphQlError(popularMediaCollection);
    List<Manga> popularMangas =
        popularMediaCollection.data.page.media
            .map(
              (mediaEntry) =>
                  AnilistMangaModel.fromPopularOrTrendingMediaEntry(mediaEntry),
            )
            .toList();
    return (true, popularMangas);
  }

  @override
  Future<(bool, List<Manga>)> getRecentlyCompletedMangas(int page, User loggedUser, {bool ignoreCache = false}) async {
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
        "endDateGreater": "${monthAgo.year.toString().padLeft(4, '0')}${monthAgo.month.toString().padLeft(2, '0')}${monthAgo.day.toString().padLeft(2, '0')}",
        "endDateLesser": "${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}",
        "type" : "MANGA",
      },
      ignoreCache: ignoreCache,
    );
    throwIfGraphQlError(recentlyCompleted);
    List<Manga> recentlyCompletedMangas =
        recentlyCompleted.data.page.media
            .map((mediaEntry) => AnilistMangaModel.fromRecentlyCompletedMediaEntry(mediaEntry))
            .toList();
    return (true, recentlyCompletedMangas);
  }

  @override
  Future<(bool, List<Manga>)> getTrendingMangas(int page, User loggedUser, {bool ignoreCache = false}) async {
    ApiGraphQLResponse<MediaCollectionTrendingOrPopularGraphqlEntity>
    trendingMediaCollection = await _anilistGraphQLService.query(
      query: anilist_queries.mediaTrendingOrPopularQuery,
      fromJson: MediaCollectionTrendingOrPopularGraphqlEntity.fromJson,
      variables: {
        "sort": "TRENDING_DESC",
        "page": page,
        "perPage": 30,
        "type": "MANGA",
      },
      ignoreCache: ignoreCache,
    );
    throwIfGraphQlError(trendingMediaCollection);
    List<Manga> trendingMangas =
    trendingMediaCollection.data.page.media
        .map(
          (mediaEntry) =>
          AnilistMangaModel.fromPopularOrTrendingMediaEntry(mediaEntry),
    )
        .toList();
    return (true, trendingMangas);
  }

  @override
  Future<(bool, List<Manga>)> getUpcomingMangas(int page, User loggedUser, {bool ignoreCache = false}) async {
    DateTime now = DateTime.now();
    ApiGraphQLResponse<MediaCollectionUpcomingGraphqlEntity>
    upcoming = await _anilistGraphQLService.query(
      query: anilist_queries.mediaUpcomingQuery,
      fromJson: MediaCollectionUpcomingGraphqlEntity.fromJson,
      variables: {
        "sort": "POPULARITY_DESC",
        "page": page,
        "perPage": 30,
        "startDateGreater": "${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}",
        "type" : "MANGA",
      },
      ignoreCache: ignoreCache,
    );
    throwIfGraphQlError(upcoming);
    List<Manga> upcomingMangas =
    upcoming.data.page.media
        .map((mediaEntry) => AnilistMangaModel.fromUpcomingMediaEntry(mediaEntry))
        .toList();
    return (true, upcomingMangas);
  }

  @override
  Future<Map<String, (bool, List<String>)>> getUserMangaAdvancedSearchFilters() async {
    Map<String, (bool, List<String>)> filters = {};
    filters.addAll({
      'genres': (
        true,
        TextUtils.capitalizeList(
          AnlistGenreFilters.values
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
      'countries': (
      true,
      TextUtils.capitalizeList(
        AnilistCountryFilters.values.map((enumElement) => enumElement.name.replaceAll('_', ' ')).toList(),
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
      'sortOptions': (
      true,
      TextUtils.capitalizeList(
        AnilistSortOptions.values
            .map((enumElement) => enumElement.name.replaceAll('_', ' '))
            .toList(),
      ),
      ),
    });
    filters.addAll({
      'sortOrders': (
      true,
      TextUtils.capitalizeList(
        AnilistSortOrder.values
            .map((enumElement) => enumElement.name.replaceAll('_', ' '))
            .toList(),
      ),
      ),
    });
    return filters;
  }

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
    // Helper function to map country names to codes
    String mapCountryToCode(String country) {
      switch (country.toLowerCase().replaceAll(' ', '_')) {
        case 'japan':
          return 'JP';
        case 'south_korea':
          return 'KR';
        case 'china':
          return 'CN';
        case 'taiwan':
          return 'TW';
        default:
          return country.toUpperCase().replaceAll(' ', '_');
      }
    }

    ApiGraphQLResponse<MediaAdvancedSearchQueryGraphqlEntity> mangaAdvancedSearchData =
        await _anilistGraphQLService.query<MediaAdvancedSearchQueryGraphqlEntity>(
      query: anilist_queries.mediaAdvancedSearchQuery,
      fromJson: MediaAdvancedSearchQueryGraphqlEntity.fromJson,
      variables: {
        "type": "MANGA",
        "page": page,
        "perPage": 50,
        "sort": sort.replaceAll("_ASC", ""),
        if (query.isNotEmpty) "search": query,
        if (selectedGenres.isNotEmpty) 
          "genres": selectedGenres.map((g) => g.toUpperCase().replaceAll(' ', '_')).toList(),
        if (selectedAiringStatus != null && selectedAiringStatus.isNotEmpty)
          "status": selectedAiringStatus.toUpperCase().replaceAll(' ', '_'),
        if (selectedFormat != null && selectedFormat.isNotEmpty)
          "format": selectedFormat.toUpperCase().replaceAll(' ', '_'),
        if (selectedCountry != null && selectedCountry.isNotEmpty)
          "countryOfOrigin": mapCountryToCode(selectedCountry),
      },
    );
    
    throwIfGraphQlError(mangaAdvancedSearchData);
    
    List<Manga> searchResults =
        mangaAdvancedSearchData.data.page.media
            .map((mediaEntry) => AnilistMangaModel.fromAdvancedSearchMediaEntry(mediaEntry))
            .toList();
    
    return searchResults;
  }

  @override
  Future<List<String>> getMediaCoverImages(User loggedUser, {bool ignoreCache = false}) async {
    (bool, List<Manga>) popularMangas = await getPopularMangas(1, loggedUser, ignoreCache: ignoreCache);
    return popularMangas.$2.map((manga) => manga.coverImage).where((coverImage) => coverImage != "").shuffled(Random()).toList();
  }

  @override
  Future<(bool, MangaDetails)> getMangaDetails(Manga selectedManga, User loggedUser, {Service? service}) async {
    Map<String, String>? graphQlHeaders = loggedUser is AnilistUserModel ? {
      "Authorization": "Bearer ${(loggedUser).accessToken}",
    }: null;
    ApiGraphQLResponse<MediaDetailsGraphqlEntity> mangaDetailsData =
    await _anilistGraphQLService.query<MediaDetailsGraphqlEntity>(
      query: anilist_queries.mediaDetailsQuery,
      fromJson: MediaDetailsGraphqlEntity.fromJson,
      variables: {
        "type": "MANGA",
        "mediaId": selectedManga.id,
        "page" : 1,
        "perPage": 20,
      },
      headers: graphQlHeaders,
    );
    throwIfGraphQlError(mangaDetailsData);
    ApiGraphQLResponse<MediaDetailsMediaListEntryEntity> mediaDetailsMediaListEntry =
    await _anilistGraphQLService.query<MediaDetailsMediaListEntryEntity>(
      query: anilist_queries.mediaListEntryQuery,
      fromJson: MediaDetailsMediaListEntryEntity.fromJson,
      variables: {
        "mediaId": selectedManga.id,
      },
      headers: graphQlHeaders,
    );
    throwIfGraphQlError(mediaDetailsMediaListEntry);
    MangaDetails mangaDetails = AnilistMangaDetailsModel.fromMangaDetailsMediaList(
      mangaDetailsData.data.media,
      mediaDetailsMediaListEntry.data,
    );
    return (true, mangaDetails);
  }
}

enum AnlistGenreFilters {
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

enum AnilistCountryFilters {
  japan,
  south_korea,
  china,
  taiwan,
}

enum AnilistSeasonFilters { winter, spring, summer, fall }

enum AnilistFormatFilters { manga, novel, one_shot }

enum AnilistAiringStatusFilters { releasing, finished, not_yet_released, hiatus, cancelled }

enum AnilistSortOptions { title_romaji, title_english, title_native, format, start_date, end_date, score, popularity, trending, episodes, duration, status, updated_at, favourites }

enum AnilistSortOrder { asc, desc }

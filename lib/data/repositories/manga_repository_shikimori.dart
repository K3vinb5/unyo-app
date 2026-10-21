// External dependencies
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/data/repositories/repository_mixin.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';

class MangaRepositoryShikimori with RepositoryMixin implements MangaRepository {
  final GraphQLService _shikimoriGraphQLService = sl<GraphQLService>(
    instanceName: config.shikimoriGraphQlService,
  );
  final Logger _logger = sl<Logger>();

  @override
  Future<(bool, MangaDetails)> getMangaDetails(Manga selectedManga, User loggedUser) {
    // TODO: implement getMangaDetails
    throw UnimplementedError();
  }

  @override
  Future<(bool, List<Manga>)> getPopularMangas(int page, User loggedUser, {bool ignoreCache = false}) {
    // TODO: implement getPopularMangas
    throw UnimplementedError();
  }

  @override
  Future<(bool, List<Manga>)> getRecentlyCompletedMangas(int page, User loggedUser, {bool ignoreCache = false}) {
    // TODO: implement getRecentlyCompletedMangas
    throw UnimplementedError();
  }

  @override
  Future<(bool, List<Manga>)> getTrendingMangas(int page, User loggedUser, {bool ignoreCache = false}) {
    // TODO: implement getTrendingMangas
    throw UnimplementedError();
  }

  @override
  Future<(bool, List<Manga>)> getUpcomingMangas(int page, User loggedUser, {bool ignoreCache = false}) {
    // TODO: implement getUpcomingMangas
    throw UnimplementedError();
  }

  @override
  Future<Map<String, (bool, List<String>)>> getUserMangaAdvancedSearchFilters() {
    // TODO: implement getUserMangaAdvancedSearchFilters
    throw UnimplementedError();
  }

  @override
  Future<List<Manga>> performMangaAdvancedSearch(String query, List<String> selectedGenres, String? selectedFormat, String? selectedCountry, String? selectedAiringStatus, String sort, int page, User loggedUser) {
    // TODO: implement performMangaAdvancedSearch
    throw UnimplementedError();
  }

  // @override
  // Future<(bool, List<Manga>)> getPopularMangas(int page, User loggedUser, {bool ignoreCache = false}) async {
  //   _logger.i("Fetching Shikimori popular manga");
  //   final response = await _shikimoriGraphQLService.query<ShikimoriMangaListGraphqlEntity>(
  //     query: shikimori_queries.shikimoriMangaListQuery,
  //     fromJson: ShikimoriMangaListGraphqlEntity.fromJson,
  //     variables: {
  //       "page": page,
  //       "limit": 31,
  //       "order": "popularity",
  //       "censored": loggedUser.settings.enableNsfwContent ? null : false,
  //     },
  //     ignoreCache: ignoreCache,
  //   );
  //   throwIfGraphQlError(response);
  //   final mangas = _processPaginatedResponse(response.data.mangas, 30);
  //   return (mangas.$1, mangas.$2.map((e) => ShikimoriMangaModel.fromListEntry(e)).toList());
  // }
  //
  // @override
  // Future<(bool, List<Manga>)> getTrendingMangas(int page, User loggedUser, {bool ignoreCache = false}) async {
  //   _logger.i("Fetching Shikimori trending manga");
  //   final response = await _shikimoriGraphQLService.query<ShikimoriMangaListGraphqlEntity>(
  //     query: shikimori_queries.shikimoriMangaListQuery,
  //     fromJson: ShikimoriMangaListGraphqlEntity.fromJson,
  //     variables: {
  //       "page": page,
  //       "limit": 31,
  //       "order": "popularity",
  //       "censored": loggedUser.settings.enableNsfwContent ? null : false,
  //     },
  //     ignoreCache: ignoreCache,
  //   );
  //   throwIfGraphQlError(response);
  //   final mangas = _processPaginatedResponse(response.data.mangas, 30);
  //   return (mangas.$1, mangas.$2.map((e) => ShikimoriMangaModel.fromListEntry(e)).toList());
  // }
  //
  // @override
  // Future<(bool, List<Manga>)> getRecentlyCompletedMangas(int page, User loggedUser, {bool ignoreCache = false}) async {
  //   _logger.i("Fetching Shikimori recently completed manga");
  //   final response = await _shikimoriGraphQLService.query<ShikimoriMangaListGraphqlEntity>(
  //     query: shikimori_queries.shikimoriMangaListQuery,
  //     fromJson: ShikimoriMangaListGraphqlEntity.fromJson,
  //     variables: {
  //       "page": page,
  //       "limit": 31,
  //       "order": "aired_on",
  //       "status": "released",
  //       "censored": loggedUser.settings.enableNsfwContent ? null : false,
  //     },
  //     ignoreCache: ignoreCache,
  //   );
  //   throwIfGraphQlError(response);
  //   final mangas = _processPaginatedResponse(response.data.mangas, 30);
  //   return (mangas.$1, mangas.$2.map((e) => ShikimoriMangaModel.fromListEntry(e)).toList());
  // }
  //
  // @override
  // Future<(bool, List<Manga>)> getUpcomingMangas(int page, User loggedUser, {bool ignoreCache = false}) async {
  //   _logger.i("Fetching Shikimori upcoming manga");
  //   final response = await _shikimoriGraphQLService.query<ShikimoriMangaListGraphqlEntity>(
  //     query: shikimori_queries.shikimoriMangaListQuery,
  //     fromJson: ShikimoriMangaListGraphqlEntity.fromJson,
  //     variables: {
  //       "page": page,
  //       "limit": 31,
  //       "order": "popularity",
  //       "status": "anons",
  //       "censored": loggedUser.settings.enableNsfwContent ? null : false,
  //     },
  //     ignoreCache: ignoreCache,
  //   );
  //   throwIfGraphQlError(response);
  //   final mangas = _processPaginatedResponse(response.data.mangas, 30);
  //   return (mangas.$1, mangas.$2.map((e) => ShikimoriMangaModel.fromListEntry(e)).toList());
  // }
  //
  // @override
  // Future<(bool, MangaDetails)> getMangaDetails(Manga selectedManga, User loggedUser) async {
  //   _logger.i("Fetching Manga Details from Shikimori for ${selectedManga.title.userPreferred}");
  //   final response = await _shikimoriGraphQLService.query<ShikimoriMangaDetailsGraphqlEntity>(
  //     query: shikimori_queries.shikimoriMangaDetailsQuery,
  //     fromJson: ShikimoriMangaDetailsGraphqlEntity.fromJson,
  //     variables: {"ids": selectedManga.id.toString()},
  //   );
  //   throwIfGraphQlError(response);
  //   if (response.data.manga.isEmpty) {
  //     return (false, MangaDetailsModel.empty());
  //   }
  //   final mangaDetails = ShikimoriMangaDetailsModel.fromDetailsEntry(response.data.manga.first);
  //   return (true, mangaDetails);
  // }
  //
  // @override
  // Future<Map<String, (bool, List<String>)>> getUserMangaAdvancedSearchFilters() async {
  //   _logger.i("Fetching Shikimori manga advanced search filters");
  //   final filters = <String, (bool, List<String>)>{};
  //   final genresResponse = await _shikimoriGraphQLService.query<ShikimoriGenresGraphqlEntity>(
  //     query: shikimori_queries.shikimoriGenresListQuery,
  //     fromJson: ShikimoriGenresGraphqlEntity.fromJson,
  //     variables: {"entryType": "Manga"},
  //   );
  //   throwIfGraphQlError(genresResponse);
  //   final genreNames = genresResponse.data.genres.map((g) => g.name).toList();
  //   filters.addAll({
  //     'genres': (true, TextUtils.capitalizeList(genreNames)),
  //   });
  //   filters.addAll({
  //     'formats': (
  //       true,
  //       TextUtils.capitalizeList(
  //         ShikimoriMangaFormatFilters.values.map((e) => e.name.replaceAll('_', ' ')).toList(),
  //       ),
  //     ),
  //   });
  //   filters.addAll({
  //     'airingStatuses': (
  //       true,
  //       TextUtils.capitalizeList(
  //         ShikimoriMangaStatusFilters.values.map((e) => e.name.replaceAll('_', ' ')).toList(),
  //       ),
  //     ),
  //   });
  //   filters.addAll({
  //     'years': (
  //       true,
  //       List<String>.generate(
  //         DateTime.now().year - 1939,
  //         (index) => (1940 + index).toString(),
  //       ).reversed.toList(),
  //     ),
  //   });
  //   filters.addAll({
  //     'sortOptions': (
  //       true,
  //       TextUtils.capitalizeList(
  //         ShikimoriMangaSortOptions.values.map((e) => e.name.replaceAll('_', ' ')).toList(),
  //       ),
  //     ),
  //   });
  //   filters.addAll({
  //     'sortOrders': (
  //       true,
  //       TextUtils.capitalizeList(
  //         ShikimoriMangaSortOrder.values.map((e) => e.name).toList(),
  //       ),
  //     ),
  //   });
  //   return filters;
  // }
  //
  // @override
  // Future<List<Manga>> performMangaAdvancedSearch(
  //   String query,
  //   List<String> selectedGenres,
  //   String? selectedFormat,
  //   String? selectedCountry,
  //   String? selectedAiringStatus,
  //   String sort,
  //   int page,
  //   User loggedUser,
  // ) async {
  //   _logger.i("Performing Shikimori manga advanced search");
  //   final genreIds = await _mapGenreNamesToIds(selectedGenres, "Manga");
  //   final response = await _shikimoriGraphQLService.query<ShikimoriMangaListGraphqlEntity>(
  //     query: shikimori_queries.shikimoriMangaListQuery,
  //     fromJson: ShikimoriMangaListGraphqlEntity.fromJson,
  //     variables: {
  //       "page": page,
  //       "limit": 50,
  //       "order": _mapSortToShikimori(sort),
  //       if (query.isNotEmpty) "search": query,
  //       if (genreIds.isNotEmpty) "genre": genreIds.join(','),
  //       if (selectedAiringStatus != null && selectedAiringStatus.isNotEmpty)
  //         "status": _mapAiringStatusToShikimori(selectedAiringStatus),
  //       if (selectedFormat != null && selectedFormat.isNotEmpty)
  //         "kind": _mapFormatToShikimoriKind(selectedFormat),
  //       "censored": loggedUser.settings.enableNsfwContent ? null : false,
  //     },
  //   );
  //   throwIfGraphQlError(response);
  //   return response.data.mangas.map((e) => ShikimoriMangaModel.fromListEntry(e)).toList();
  // }

  @override
  Future<List<String>> getMediaCoverImages(User loggedUser, {bool ignoreCache = false}) async {
    _logger.i("Fetching Media Cover Images from Shikimori");
    final (hasNext, mangas) = await getPopularMangas(1, loggedUser, ignoreCache: ignoreCache);
    return mangas.map((manga) => manga.coverImage).where((coverImage) => coverImage != "").shuffled(Random()).toList();
  }

  // Helper methods

  // (bool, List<ShikimoriMangaListGraphqlMangas>) _processPaginatedResponse(
  //   List<ShikimoriMangaListGraphqlMangas> results,
  //   int limit,
  // ) {
  //   final hasNextPage = results.length > limit;
  //   final items = hasNextPage ? results.take(limit).toList() : results;
  //   return (hasNextPage, items);
  // }
  //
  // Future<List<String>> _mapGenreNamesToIds(List<String> genreNames, String entryType) async {
  //   if (genreNames.isEmpty) return [];
  //   final genresResponse = await _shikimoriGraphQLService.query<ShikimoriGenresGraphqlEntity>(
  //     query: shikimori_queries.shikimoriGenresListQuery,
  //     fromJson: ShikimoriGenresGraphqlEntity.fromJson,
  //     variables: {"entryType": entryType},
  //   );
  //   throwIfGraphQlError(genresResponse);
  //   final genreMap = <String, String>{};
  //   for (final genre in genresResponse.data.genres) {
  //     genreMap[genre.name.toLowerCase()] = genre.id;
  //   }
  //   return genreNames
  //       .map((name) => genreMap[name.toLowerCase()])
  //       .whereType<String>()
  //       .toList();
  // }

  String _mapSortToShikimori(String sort) {
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
      case 'title':
        return 'name';
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
      case 'hiatus':
        return 'paused';
      case 'cancelled':
        return 'discontinued';
      default:
        return status.toLowerCase();
    }
  }

  String _mapFormatToShikimoriKind(String format) {
    switch (format.toLowerCase().replaceAll(' ', '_')) {
      case 'manga':
        return 'manga';
      case 'manhwa':
        return 'manhwa';
      case 'manhua':
        return 'manhua';
      case 'novel':
        return 'light_novel';
      case 'one_shot':
        return 'one_shot';
      case 'doujinshi':
        return 'doujin';
      default:
        return format.toLowerCase().replaceAll(' ', '_');
    }
  }
}

enum ShikimoriMangaFormatFilters { manga, manhwa, manhua, light_novel, one_shot, doujin }

enum ShikimoriMangaStatusFilters { ongoing, released, anons, paused, discontinued }

enum ShikimoriMangaSortOptions { popularity, ranked, name, aired_on }

enum ShikimoriMangaSortOrder { asc, desc }

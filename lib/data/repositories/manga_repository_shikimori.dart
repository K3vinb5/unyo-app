// External dependencies
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/api/dto/shikimori/manga_details_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/manga_list_query_entity.dart';
import 'package:unyo/core/services/api/graphql/graphql_response.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/graphql/queries/shikimori_queries.dart' as shikimori_queries;
import 'package:unyo/data/models/shikimori/media/shikimori_manga_details.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_manga_model.dart';
import 'package:unyo/data/repositories/repository_mixin.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';

/// Shikimori manga metadata provider (GraphQL, <https://shikimori.io/api/graphql>).
///
/// Mirrors [AnimeRepositoryShikimori]: one list document with server-side
/// filters, `mangas(ids:)` for details. Advanced search + filters are WP #64
/// subpart (b) and stay honest stubs.
class MangaRepositoryShikimori with RepositoryMixin implements MangaRepository {
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
  Future<(bool, MangaDetails)> getMangaDetails(Manga selectedManga, User loggedUser, {Service? service}) async {
    _logger.i("Fetching Manga Details from Shikimori for ${selectedManga.title.userPreferred}");
    final ApiGraphQLResponse<MangaDetailsQueryEntity> mangaDetailsQueryResponse =
        await _shikimoriGraphQLService.query<MangaDetailsQueryEntity>(
      query: shikimori_queries.shikimoriMangaDetailsQuery,
      fromJson: MangaDetailsQueryEntity.fromJson,
      headers: _requestHeaders,
      variables: {"ids": selectedManga.id.toString(), "page": 1, "limit": 20},
    );
    throwIfGraphQlError(mangaDetailsQueryResponse);
    if (mangaDetailsQueryResponse.data.mangas.isEmpty) {
      return (false, ShikimoriMangaDetailsModel.empty());
    }
    final MangaDetails mangaDetails = ShikimoriMangaDetailsModel.fromMangaDetailsQuery(
      mangaDetailsQueryResponse.data,
    );
    return (true, mangaDetails);
  }

  @override
  Future<(bool, List<Manga>)> getPopularMangas(int page, User loggedUser, {bool ignoreCache = false}) async {
    _logger.i("Fetching Shikimori popular mangas");
    return _fetchMangas(page: page, order: 'popularity', loggedUser: loggedUser, ignoreCache: ignoreCache);
  }

  /// Finished manga, newest update first — no `season` filter (a series that
  /// ended a while ago is still a recent completion).
  @override
  Future<(bool, List<Manga>)> getRecentlyCompletedMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching Shikimori recently completed mangas");
    return _fetchMangas(
      page: page,
      order: 'updated_at_desc',
      status: 'released',
      loggedUser: loggedUser,
      ignoreCache: ignoreCache,
    );
  }

  @override
  Future<(bool, List<Manga>)> getTrendingMangas(int page, User loggedUser, {bool ignoreCache = false}) async {
    _logger.i("Fetching Shikimori trending mangas");
    return _fetchMangas(page: page, order: 'popularity', loggedUser: loggedUser, ignoreCache: ignoreCache);
  }

  /// Announced manga (`status: anons`), the manga counterpart of the anime
  /// upcoming carousel.
  @override
  Future<(bool, List<Manga>)> getUpcomingMangas(int page, User loggedUser, {bool ignoreCache = false}) async {
    _logger.i("Fetching Shikimori upcoming mangas");
    return _fetchMangas(
      page: page,
      order: 'popularity',
      status: 'anons',
      loggedUser: loggedUser,
      ignoreCache: ignoreCache,
    );
  }

  /// WP #64 subpart (b): generated from `genres(entryType: Manga)` plus the
  /// kind/status dictionaries.
  @override
  Future<Map<String, (bool, List<String>)>> getUserMangaAdvancedSearchFilters() {
    throw UnimplementedError();
  }

  /// WP #64 subpart (b).
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
  ) {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getMediaCoverImages(User loggedUser, {bool ignoreCache = false}) async {
    _logger.i("Fetching Media Cover Images from Shikimori");
    final (bool hasNext, List<Manga> mangas) = await getPopularMangas(1, loggedUser, ignoreCache: ignoreCache);
    return mangas
        .map((Manga manga) => manga.coverImage)
        .where((String coverImage) => coverImage != "")
        .shuffled(Random())
        .toList();
  }

  /// One page of `mangas(...)` with only the filters the carousel asked for.
  Future<(bool, List<Manga>)> _fetchMangas({
    required int page,
    required String order,
    required User loggedUser,
    required bool ignoreCache,
    String? status,
    String? season,
  }) async {
    final ApiGraphQLResponse<MangaListQueryEntity> mangaListQueryResponse =
        await _shikimoriGraphQLService.query<MangaListQueryEntity>(
      query: shikimori_queries.shikimoriMangaListQuery,
      fromJson: MangaListQueryEntity.fromJson,
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
    throwIfGraphQlError(mangaListQueryResponse);
    final List<Manga> mangas = mangaListQueryResponse.data.mangas
        .map((MangaListQueryMangas entry) => ShikimoriMangaModel.fromListEntry(entry))
        .toList();
    return (true, mangas);
  }
}

/// Filter value sets consumed by the manga advanced search (WP #64 subpart (b)).
enum ShikimoriMangaFormatFilters { manga, manhwa, manhua, light_novel, one_shot, doujin }

enum ShikimoriMangaStatusFilters { ongoing, released, anons, paused, discontinued }

enum ShikimoriMangaSortOptions { popularity, ranked, name, aired_on }

enum ShikimoriMangaSortOrder { asc, desc }

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
import 'package:unyo/core/services/api/dto/shikimori/shikimori_genres_list_query_entity.dart';
import 'package:unyo/core/services/api/graphql/graphql_response.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/graphql/queries/shikimori_queries.dart' as shikimori_queries;
import 'package:unyo/core/services/api/graphql/queries/shikimori_search_parameters.dart';
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
/// filters, `mangas(ids:)` for details, and advanced search over the same
/// document. The manga genre ids differ from the anime ones, so this repository
/// keeps its own genre map.
class MangaRepositoryShikimori with RepositoryMixin implements MangaRepository {
  /// Shikimori caps `limit` at 50.
  static const int pageSize = 50;

  final GraphQLService _shikimoriGraphQLService = sl<GraphQLService>(
    instanceName: config.shikimoriGraphQlService,
  );
  final Logger _logger = sl<Logger>();

  /// Genre **name** (lower-cased) → genre id for `genres(entryType: Manga)`.
  final Map<String, String> _genreIdsByName = <String, String>{};

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

  /// Generated from `genres(entryType: Manga)` (PascalCase enum value) plus the
  /// kind/status/sort dictionaries.
  ///
  /// Hidden (`false`) instead of faked: `countries` — `Manga` has no
  /// country-of-origin field and `mangas(...)` has no origin argument;
  /// `sortOrders` — `OrderEnum` has no general `_desc` twin.
  @override
  Future<Map<String, (bool, List<String>)>> getUserMangaAdvancedSearchFilters(User loggedUser) async {
    final List<ShikimoriGenresListQueryGenres> genres = await _loadGenres(ShikimoriGenreEntryType.manga);
    final List<String> genreNames = genres
        .map((ShikimoriGenresListQueryGenres genre) => genre.name.trim())
        .where((String name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return <String, (bool, List<String>)>{
      'genres': (true, genreNames),
      'formats': (true, ShikimoriMangaFormatFilters.values.map((ShikimoriMangaFormatFilters value) => ShikimoriSearchParameters.label(value.name)).toList()),
      'airingStatuses': (true, ShikimoriMangaStatusFilters.values.map((ShikimoriMangaStatusFilters value) => ShikimoriSearchParameters.label(value.name)).toList()),
      'sortOptions': (true, ShikimoriMangaSortOptions.values.map((ShikimoriMangaSortOptions value) => ShikimoriSearchParameters.label(value.name)).toList()),
      'countries': (false, <String>[]),
      'sortOrders': (false, <String>[]),
    };
  }

  /// One `mangas(...)` page with every filter the manga schema accepts.
  ///
  /// `selectedCountry` has no counterpart: the manga type carries no
  /// country-of-origin and `mangas(...)` has no origin argument, so the value is
  /// dropped rather than mapped onto `publisher` (a publisher id is not a
  /// country). The countries dropdown is hidden by
  /// [getUserMangaAdvancedSearchFilters] for the same reason.
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
    _logger.i("Performing advanced manga search on Shikimori");
    if (selectedCountry != null && selectedCountry.trim().isNotEmpty) {
      _logger.w("Shikimori has no manga country filter; ignoring '$selectedCountry'");
    }
    final String? genre = selectedGenres.isEmpty
        ? null
        : ShikimoriSearchParameters.genreIdsFor(selectedGenres, await _genreIds());
    final ApiGraphQLResponse<MangaListQueryEntity> response =
        await _shikimoriGraphQLService.query<MangaListQueryEntity>(
      query: shikimori_queries.shikimoriMangaListQuery,
      fromJson: MangaListQueryEntity.fromJson,
      headers: _requestHeaders,
      variables: <String, dynamic>{
        'page': page,
        'limit': pageSize,
        'order': ShikimoriSearchParameters.orderFor(sort),
        'kind': ShikimoriSearchParameters.choiceFor(
          selectedFormat,
          ShikimoriMangaFormatFilters.values.map((ShikimoriMangaFormatFilters value) => value.name),
        ),
        'status': ShikimoriSearchParameters.choiceFor(
          selectedAiringStatus,
          ShikimoriMangaStatusFilters.values.map((ShikimoriMangaStatusFilters value) => value.name),
        ),
        'search': query.trim().isEmpty ? null : query.trim(),
        'genre': genre,
        'censored': loggedUser.settings.enableNsfwContent ? null : false,
      },
    );
    throwIfGraphQlError(response);
    return response.data.mangas
        .map((MangaListQueryMangas entry) => ShikimoriMangaModel.fromListEntry(entry))
        .toList();
  }

  /// `genres(entryType: Manga)` — PascalCase wire value only.
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

  Future<Map<String, String>> _genreIds() async {
    if (_genreIdsByName.isEmpty) {
      await _loadGenres(ShikimoriGenreEntryType.manga);
    }
    return _genreIdsByName;
  }

  /// Fetches the manga genre dictionary and remembers the name→id map.
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

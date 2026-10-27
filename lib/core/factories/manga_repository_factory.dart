// External dependencies
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/data/repositories/manga_repository_anilist.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';

/// Factory that resolves the correct [MangaRepository] implementation
/// based on the metadata provider (`settings.metadataService`).
///
/// Currently supports:
/// - [Service.anilist] → delegates to [MangaRepositoryAnilist]
/// - All other services → returns safe empty defaults
class MangaRepositoryFactory implements MangaRepository {
  final MangaRepositoryAnilist _mangaRepositoryAnilist = sl<MangaRepositoryAnilist>();
  final Logger _logger = sl<Logger>();

  @override
  Future<(bool, List<Manga>)> getTrendingMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Anilist trending manga");
        return _mangaRepositoryAnilist.getTrendingMangas(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
      case Service.simkl:
        return (false, <Manga>[]);
    }
  }

  @override
  Future<(bool, List<Manga>)> getPopularMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Anilist popular manga");
        return _mangaRepositoryAnilist.getPopularMangas(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
      case Service.simkl:
        return (false, <Manga>[]);
    }
  }

  @override
  Future<(bool, List<Manga>)> getRecentlyCompletedMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Anilist recently completed manga");
        return _mangaRepositoryAnilist.getRecentlyCompletedMangas(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
      case Service.simkl:
        return (false, <Manga>[]);
    }
  }

  @override
  Future<(bool, List<Manga>)> getUpcomingMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Anilist upcoming manga");
        return _mangaRepositoryAnilist.getUpcomingMangas(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
      case Service.simkl:
        return (false, <Manga>[]);
    }
  }

  @override
  Future<(bool, MangaDetails)> getMangaDetails(Manga selectedManga, User loggedUser) async {
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Manga Details from AniList for ${selectedManga.title.userPreferred}");
        return _mangaRepositoryAnilist.getMangaDetails(selectedManga, loggedUser);
      case Service.mal:
        _logger.i("Fetching Manga Details from MyMangaList for ${selectedManga.title.userPreferred}");
        return (false, MangaDetailsModel.empty());
      case Service.shikimori:
        _logger.i("Fetching Manga Details from Shikimori for ${selectedManga.title.userPreferred}");
        return (false, MangaDetailsModel.empty());
      case Service.kitsu:
        _logger.i("Fetching Manga Details from Kitsu for ${selectedManga.title.userPreferred}");
        return (false, MangaDetailsModel.empty());
      case Service.simkl:
        _logger.i("Fetching Manga Details from Simkl for ${selectedManga.title.userPreferred}");
        return (false, MangaDetailsModel.empty());
    }
  }

  @override
  Future<Map<String, (bool, List<String>)>> getUserMangaAdvancedSearchFilters() async {
    return _mangaRepositoryAnilist.getUserMangaAdvancedSearchFilters();
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
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        return _mangaRepositoryAnilist.performMangaAdvancedSearch(
          query,
          selectedGenres,
          selectedFormat,
          selectedCountry,
          selectedAiringStatus,
          sort,
          page,
          loggedUser,
        );
      case Service.mal:
      case Service.shikimori:
      case Service.simkl:
      case Service.kitsu:
        return [];
    }
  }

  @override
  Future<List<String>> getMediaCoverImages(User loggedUser, {bool ignoreCache = false}) async {
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Manga Banners from AniList for ...");
        return _mangaRepositoryAnilist.getMediaCoverImages(
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
        _logger.i("Fetching Manga Banners from MyMangaList for ...");
        return [];
      case Service.shikimori:
        _logger.i("Fetching Manga Banners from Shikimori for ...");
        return [];
      case Service.kitsu:
        _logger.i("Fetching Manga Banners from Kitsu for ...");
        return [];
      case Service.simkl:
        _logger.i("Fetching Manga Banners from Simkl for ...");
        return [];
    }
  }
}

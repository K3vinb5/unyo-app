// External dependencies
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/data/repositories/manga_repository_anilist.dart';
import 'package:unyo/data/repositories/manga_repository_shikimori.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';

/// Factory that resolves the correct [MangaRepository] implementation
/// based on the metadata provider (`settings.metadataService`).
///
/// [supportsMetadataService] is the single routing table deciding support:
/// - [Service.anilist] → delegates to [MangaRepositoryAnilist]
/// - [Service.shikimori] → delegates to [MangaRepositoryShikimori]
/// - All other services → returns safe empty defaults
class MangaRepositoryFactory implements MangaRepository {
  final MangaRepositoryAnilist _mangaRepositoryAnilist = sl<MangaRepositoryAnilist>();
  final MangaRepositoryShikimori _mangaRepositoryShikimori = sl<MangaRepositoryShikimori>();
  final Logger _logger = sl<Logger>();

  /// Whether [service] can serve manga browse lists at all.
  ///
  /// The cubit asks this before fetching so an unsupported provider renders an
  /// explicit "Manga isn't available with …" state instead of an empty list
  /// that is indistinguishable from a load result.
  static bool supportsMetadataService(Service service) {
    switch (service) {
      case Service.anilist:
      case Service.shikimori:
        return true;
      case Service.mal:
      case Service.kitsu:
      case Service.simkl:
        return false;
    }
  }

  @override
  Future<(bool, List<Manga>)> getTrendingMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    if (!MangaRepositoryFactory.supportsMetadataService(loggedUser.settings.metadataService)) {
      return (false, <Manga>[]);
    }
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Anilist trending manga");
        return _mangaRepositoryAnilist.getTrendingMangas(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.shikimori:
        _logger.i("Fetching Shikimori trending mangas");
        return _mangaRepositoryShikimori.getTrendingMangas(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
      case Service.kitsu:
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
    if (!MangaRepositoryFactory.supportsMetadataService(loggedUser.settings.metadataService)) {
      return (false, <Manga>[]);
    }
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Anilist popular manga");
        return _mangaRepositoryAnilist.getPopularMangas(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.shikimori:
        _logger.i("Fetching Shikimori popular mangas");
        return _mangaRepositoryShikimori.getPopularMangas(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
      case Service.kitsu:
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
    if (!MangaRepositoryFactory.supportsMetadataService(loggedUser.settings.metadataService)) {
      return (false, <Manga>[]);
    }
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Anilist recently completed manga");
        return _mangaRepositoryAnilist.getRecentlyCompletedMangas(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.shikimori:
        _logger.i("Fetching Shikimori recently completed mangas");
        return _mangaRepositoryShikimori.getRecentlyCompletedMangas(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
      case Service.kitsu:
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
    if (!MangaRepositoryFactory.supportsMetadataService(loggedUser.settings.metadataService)) {
      return (false, <Manga>[]);
    }
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Anilist upcoming manga");
        return _mangaRepositoryAnilist.getUpcomingMangas(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.shikimori:
        _logger.i("Fetching Shikimori upcoming mangas");
        return _mangaRepositoryShikimori.getUpcomingMangas(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
      case Service.kitsu:
      case Service.simkl:
        return (false, <Manga>[]);
    }
  }

  @override
  Future<(bool, MangaDetails)> getMangaDetails(Manga selectedManga, User loggedUser, {Service? service}) async {
    Service metadataService = service ?? loggedUser.settings.metadataService;
    if (!MangaRepositoryFactory.supportsMetadataService(metadataService)) {
      _logger.i("Manga Details are not available with ${metadataService.name} for ${selectedManga.title.userPreferred}");
      return (false, MangaDetailsModel.empty());
    }
    switch (metadataService) {
      case Service.anilist:
        _logger.i("Fetching Manga Details from AniList for ${selectedManga.title.userPreferred}");
        return _mangaRepositoryAnilist.getMangaDetails(selectedManga, loggedUser);
      case Service.shikimori:
        _logger.i("Fetching Manga Details from Shikimori for ${selectedManga.title.userPreferred}");
        return _mangaRepositoryShikimori.getMangaDetails(selectedManga, loggedUser);
      case Service.mal:
      case Service.kitsu:
      case Service.simkl:
        return (false, MangaDetailsModel.empty());
    }
  }

  @override
  Future<Map<String, (bool, List<String>)>> getUserMangaAdvancedSearchFilters(User loggedUser) async {
    switch (loggedUser.settings.metadataService) {
      case Service.shikimori:
        _logger.i("Fetching Shikimori manga advanced search filters");
        return _mangaRepositoryShikimori.getUserMangaAdvancedSearchFilters(loggedUser);
      case Service.anilist:
      case Service.mal:
      case Service.kitsu:
      case Service.simkl:
        _logger.i("Fetching Anilist manga advanced search filters");
        return _mangaRepositoryAnilist.getUserMangaAdvancedSearchFilters(loggedUser);
    }
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
    if (!MangaRepositoryFactory.supportsMetadataService(loggedUser.settings.metadataService)) {
      return [];
    }
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
      case Service.shikimori:
        return _mangaRepositoryShikimori.performMangaAdvancedSearch(
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
      case Service.simkl:
      case Service.kitsu:
        return [];
    }
  }

  @override
  Future<List<String>> getMediaCoverImages(User loggedUser, {bool ignoreCache = false}) async {
    if (!MangaRepositoryFactory.supportsMetadataService(loggedUser.settings.metadataService)) {
      _logger.i("Manga banners are not available with ${loggedUser.settings.metadataService.name}");
      return [];
    }
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Manga Banners from AniList for ...");
        return _mangaRepositoryAnilist.getMediaCoverImages(
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.shikimori:
        _logger.i("Fetching Manga Banners from Shikimori for ...");
        return _mangaRepositoryShikimori.getMediaCoverImages(
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
      case Service.kitsu:
      case Service.simkl:
        return [];
    }
  }
}

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
/// [supportsMetadataService] is the single routing table deciding support:
/// - [Service.anilist] → delegates to [MangaRepositoryAnilist]
/// - All other services → returns safe empty defaults
class MangaRepositoryFactory implements MangaRepository {
  final MangaRepositoryAnilist _mangaRepositoryAnilist = sl<MangaRepositoryAnilist>();
  final Logger _logger = sl<Logger>();

  /// Whether [service] can serve manga browse lists at all.
  ///
  /// The cubit asks this before fetching so an unsupported provider renders an
  /// explicit "Manga isn't available with …" state instead of an empty list
  /// that is indistinguishable from a load result.
  static bool supportsMetadataService(Service service) {
    switch (service) {
      case Service.anilist:
        return true;
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
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
    _logger.i("Fetching Anilist trending manga");
    return _mangaRepositoryAnilist.getTrendingMangas(
      page,
      loggedUser,
      ignoreCache: ignoreCache,
    );
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
    _logger.i("Fetching Anilist popular manga");
    return _mangaRepositoryAnilist.getPopularMangas(
      page,
      loggedUser,
      ignoreCache: ignoreCache,
    );
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
    _logger.i("Fetching Anilist recently completed manga");
    return _mangaRepositoryAnilist.getRecentlyCompletedMangas(
      page,
      loggedUser,
      ignoreCache: ignoreCache,
    );
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
    _logger.i("Fetching Anilist upcoming manga");
    return _mangaRepositoryAnilist.getUpcomingMangas(
      page,
      loggedUser,
      ignoreCache: ignoreCache,
    );
  }

  @override
  Future<(bool, MangaDetails)> getMangaDetails(Manga selectedManga, User loggedUser, {Service? service}) async {
    Service metadataService = service ?? loggedUser.settings.metadataService;
    if (!MangaRepositoryFactory.supportsMetadataService(metadataService)) {
      _logger.i("Manga Details are not available with ${metadataService.name} for ${selectedManga.title.userPreferred}");
      return (false, MangaDetailsModel.empty());
    }
    _logger.i("Fetching Manga Details from AniList for ${selectedManga.title.userPreferred}");
    return _mangaRepositoryAnilist.getMangaDetails(selectedManga, loggedUser);
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
    if (!MangaRepositoryFactory.supportsMetadataService(loggedUser.settings.metadataService)) {
      return [];
    }
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
  }

  @override
  Future<List<String>> getMediaCoverImages(User loggedUser, {bool ignoreCache = false}) async {
    if (!MangaRepositoryFactory.supportsMetadataService(loggedUser.settings.metadataService)) {
      _logger.i("Manga banners are not available with ${loggedUser.settings.metadataService.name}");
      return [];
    }
    _logger.i("Fetching Manga Banners from AniList for ...");
    return _mangaRepositoryAnilist.getMediaCoverImages(
      loggedUser,
      ignoreCache: ignoreCache,
    );
  }
}

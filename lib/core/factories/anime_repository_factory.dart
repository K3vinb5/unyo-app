// External dependencies
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/media/media_provenance.dart';
import 'package:unyo/data/repositories/anime_repository_anilist.dart';
import 'package:unyo/data/repositories/anime_repository_shikimori.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/core/services/media/media_id_service.dart';
import 'package:unyo/core/services/media/media_link_exception.dart';

/// Factory that resolves the correct [AnimeRepository] implementation.
///
/// Reads are routed by the metadata provider (`settings.metadataService`):
/// - [Service.anilist] → delegates to [AnimeRepositoryAnilist]
/// - [Service.shikimori] → delegates to [AnimeRepositoryShikimori]
/// - All other services → returns safe empty defaults
///
/// List-entry reads/writes are routed by the user provider
/// (`settings.userService`) — the metadata provider is presentation-only
/// (WP #61 field ownership).
class AnimeRepositoryFactory implements AnimeRepository {
  final AnimeRepositoryAnilist _animeRepositoryAnilist = sl<AnimeRepositoryAnilist>();
  final AnimeRepositoryShikimori _animeRepositoryShikimori = sl<AnimeRepositoryShikimori>();
  final Logger _logger = sl<Logger>();
  final MediaIdService _mediaIdService = sl<MediaIdService>();

  @override
  Future<(bool, List<Anime>)> getRecentlyReleasedAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Anilist recently released anime");
        return _animeRepositoryAnilist.getRecentlyReleasedAnimes(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
        _logger.i("Fetching Shikimori recently released anime");
        return _animeRepositoryShikimori.getRecentlyReleasedAnimes(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.simkl:
        return (false, <Anime>[]);
    }
  }

  @override
  Future<(bool, List<Anime>)> getTrendingAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Anilist trending anime");
        return _animeRepositoryAnilist.getTrendingAnimes(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
        _logger.i("Fetching Shikimori trending anime");
        return _animeRepositoryShikimori.getTrendingAnimes(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.simkl:
        return (false, <Anime>[]);
    }
  }

  @override
  Future<(bool, List<Anime>)> getPopularAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Anilist popular anime");
        return _animeRepositoryAnilist.getPopularAnimes(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
        _logger.i("Fetching Shikimori popular anime");
        return _animeRepositoryShikimori.getPopularAnimes(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.simkl:
        return (false, <Anime>[]);
    }
  }

  @override
  Future<(bool, List<Anime>)> getRecentlyCompletedAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Anilist recently completed anime");
        return _animeRepositoryAnilist.getRecentlyCompletedAnimes(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
        _logger.i("Fetching Shikimori recently completed anime");
        return _animeRepositoryShikimori.getRecentlyCompletedAnimes(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.simkl:
        return (false, <Anime>[]);
    }
  }

  @override
  Future<(bool, List<Anime>)> getUpcomingAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Anilist upcoming anime");
        return _animeRepositoryAnilist.getUpcomingAnimes(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
        _logger.i("Fetching Shikimori upcoming anime");
        return _animeRepositoryShikimori.getUpcomingAnimes(
          page,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.simkl:
        return (false, <Anime>[]);
    }
  }

  @override
  Future<Map<String, List<Anime>>> getCalendarReleases(int page, User loggedUser) async {
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Anilist calendar releases");
        return _animeRepositoryAnilist.getCalendarReleases(page, loggedUser);
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
      case Service.simkl:
        return {};
    }
  }

  @override
  Future<(bool, AnimeDetails)> getAnimeDetails(Anime selectedAnime, User loggedUser, {Service? service}) async {
    switch (service ?? loggedUser.settings.metadataService) {
      case Service.anilist:
        _logger.i("Fetching Anime Details from AniList for ${selectedAnime.title.userPreferred}");
        return _animeRepositoryAnilist.getAnimeDetails(selectedAnime, loggedUser);
      case Service.mal:
        _logger.i("Fetching Anime Details from MyAnimeList for ${selectedAnime.title.userPreferred}");
        return (false, AnimeDetailsModel.empty());
      case Service.shikimori:
        _logger.i("Fetching Anime Details from Shikimori for ${selectedAnime.title.userPreferred}");
        return _animeRepositoryShikimori.getAnimeDetails(selectedAnime, loggedUser);
      case Service.kitsu:
        _logger.i("Fetching Anime Details from Kitsu for ${selectedAnime.title.userPreferred}");
        return (false, AnimeDetailsModel.empty());
      case Service.simkl:
        _logger.i("Fetching Anime Details from Simkl for ${selectedAnime.title.userPreferred}");
        return (false, AnimeDetailsModel.empty());
    }
  }

  @override
  Future<Map<String, (bool, List<String>)>> getUserAnimeAdvancedSearchFilters() async {
    return _animeRepositoryAnilist.getUserAnimeAdvancedSearchFilters();
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
    switch (loggedUser.settings.metadataService) {
      case Service.anilist:
        return _animeRepositoryAnilist.performAnimeAdvancedSearch(
          query,
          selectedGenres,
          selectedSeason,
          selectedFormat,
          selectedYear,
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
        _logger.i("Fetching Media Cover Images from AniList");
        return _animeRepositoryAnilist.getMediaCoverImages(
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
        _logger.i("Fetching Media Cover Images from MyAnimeList");
        return [];
      case Service.shikimori:
        _logger.i("Fetching Media Cover Images from Shikimori");
        return _animeRepositoryShikimori.getMediaCoverImages(
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.kitsu:
        _logger.i("Fetching Media Cover Images from Kitsu");
        return [];
      case Service.simkl:
        _logger.i("Fetching Media Cover Images from Simkl");
        return [];
    }
  }

  @override
  Future<MediaListEntry> updateMediaListEntry(
    MediaListEntry newMediaListEntry,
    Anime selectedAnime,
    User loggedUser,
  ) async {
    // Writes only ever go to the user provider, and only to an id we could
    // verify: a metadata-provider record carries a foreign native id.
    final Anime userRecord = await _asUserProviderRecord(selectedAnime, loggedUser, operation: "update");
    switch (loggedUser.settings.userService) {
      case Service.anilist:
        _logger.i("Updating Media List Entry to $newMediaListEntry on Anilist");
        return _animeRepositoryAnilist.updateMediaListEntry(
          newMediaListEntry,
          userRecord,
          loggedUser,
        );
      case Service.mal:
        _logger.i("Updating Media List Entry to $newMediaListEntry on MyAnimeList");
        return MediaListEntryModel.empty();
      case Service.shikimori:
        _logger.i("Updating Media List Entry to $newMediaListEntry on Shikimori");
        return MediaListEntryModel.empty();
      case Service.kitsu:
        _logger.i("Updating Media List Entry to $newMediaListEntry on Kitsu");
        return MediaListEntryModel.empty();
      case Service.simkl:
        _logger.i("Updating Media List Entry to $newMediaListEntry on Simkl");
        return MediaListEntryModel.empty();
    }
  }

  @override
  Future<MediaListEntry> getMediaListEntry(
    Anime selectedAnime,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    final Anime? userRecord = await _asUserProviderRecordOrNull(selectedAnime, loggedUser, operation: "read");
    if (userRecord == null) {
      // Reads may degrade to an empty entry; nothing is guessed.
      return MediaListEntryModel.empty();
    }
    switch (loggedUser.settings.userService) {
      case Service.anilist:
        _logger.i("Fetching User Media List Entry from AniList for ${selectedAnime.title.userPreferred}");
        return _animeRepositoryAnilist.getMediaListEntry(
          userRecord,
          loggedUser,
          ignoreCache: ignoreCache,
        );
      case Service.mal:
        _logger.i("Fetching User Media List Entry from MyAnimeList for ${selectedAnime.title.userPreferred}");
        return MediaListEntryModel.empty();
      case Service.shikimori:
        _logger.i("Fetching User Media List Entry from Shikimori for ${selectedAnime.title.userPreferred}");
        return MediaListEntryModel.empty();
      case Service.kitsu:
        _logger.i("Fetching User Media List Entry from Kitsu for ${selectedAnime.title.userPreferred}");
        return MediaListEntryModel.empty();
      case Service.simkl:
        _logger.i("Fetching User Media List Entry from Simkl for ${selectedAnime.title.userPreferred}");
        return MediaListEntryModel.empty();
    }
  }

  /// Re-addresses a record to the user provider's native id through the MAL
  /// pivot. The identity path passes the record through untouched (zero lookups).
  ///
  /// Throws [MediaLinkUnresolvedException] instead of guessing when the chain
  /// cannot verify a mapping — the caller must not write in that case.
  Future<Anime> _asUserProviderRecord(Anime selectedAnime, User loggedUser, {required String operation}) async {
    final Anime? userRecord = await _asUserProviderRecordOrNull(selectedAnime, loggedUser, operation: operation);
    if (userRecord == null) {
      throw MediaLinkUnresolvedException(
        "No verified ${loggedUser.settings.userService.name} entry for "
        "${selectedAnime.title.userPreferred} (${MediaProvenance.ofAnime(selectedAnime).name}:${selectedAnime.id}); "
        "skipping the list $operation instead of writing to a guessed id",
      );
    }
    return userRecord;
  }

  /// Null when the record cannot be translated to the user provider.
  Future<Anime?> _asUserProviderRecordOrNull(Anime selectedAnime, User loggedUser, {required String operation}) async {
    // Identity path: the record already is the user provider's own, so it is
    // passed through untouched (never copied, never re-addressed).
    if (MediaProvenance.ofAnime(selectedAnime) == loggedUser.settings.userService) return selectedAnime;
    final int? nativeId = await _mediaIdService.userNativeIdFor(selectedAnime, loggedUser.settings.userService);
    if (nativeId == null) {
      _logger.w(
        "Cannot resolve ${MediaProvenance.ofAnime(selectedAnime).name}:${selectedAnime.id} to "
        "${loggedUser.settings.userService.name} for list $operation",
      );
      return null;
    }
    return MediaFields.withNativeId(selectedAnime, nativeId);
  }
}

// External dependencies
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/api/mal/mal_user_rate_service.dart';
import 'package:unyo/data/models/mal/media/mal_list_status_policy.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/data/repositories/repository_mixin.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';

/// MyAnimeList tracker (userService) for anime list entries (WP #156).
///
/// Mirrors `AnimeRepositoryShikimori`'s list-entry half (subpart (c)): reads
/// and writes go through [MalUserRateService] (`GET /anime/{id}?fields=
/// my_list_status`, `PUT|DELETE /anime/{id}/my_list_status`), and the logged
/// account has to be a [MalUserModel] or the call degrades to the empty entry
/// instead of writing anonymously.
///
/// Every metadata method ([getAnimeDetails], the browse lists, search, covers)
/// is a **deliberate stub**: the factory routes those to the metadataService
/// repository (`AnimeRepositoryAnilist` / `AnimeRepositoryShikimori`), and MAL
/// is a tracker-only provider (SPEC Q2: not a metadata provider). The stubs
/// name that deferral instead of faking data — same precedent as
/// `UserRepositoryLocal`. [AnimeRepositoryFactory] never routes a metadata
/// call here; reaching one means a routing bug, which `UnimplementedError`
/// surfaces loudly.
///
/// A record passed to the list-entry methods must already carry the MAL native
/// id: [AnimeRepositoryFactory] re-addresses it through the MAL-pivot chain
/// (or passes it through on the identity path) before delegating, and
/// [MalUserRateService] rejects non-positive ids.
class AnimeRepositoryMal with RepositoryMixin implements AnimeRepository {
  /// Resolved on first use so metadata-only tests can build this repository
  /// without the rate service registered (mirror of the Shikimori repos).
  MalUserRateService get _userRateService => sl<MalUserRateService>();
  final Logger _logger = sl<Logger>();

  /// WP #156: writes go to `PUT /anime/{id}/my_list_status` (MAL upserts), and
  /// an empty-status entry is the delete — [MalUserRateService] owns that fold.
  @override
  Future<MediaListEntry> updateMediaListEntry(
    MediaListEntry newMediaListEntry,
    Anime selectedAnime,
    User loggedUser,
  ) async {
    _logger.i("Updating Media List Entry to $newMediaListEntry on MyAnimeList");
    final MalUserModel? account = _malAccount(loggedUser);
    if (account == null) return MediaListEntryModel.empty();
    return _userRateService.updateEntry(
      user: account,
      targetId: selectedAnime.id,
      target: MalListTarget.anime,
      entry: newMediaListEntry,
    );
  }

  /// The reader is `GET /anime/{id}?fields=my_list_status`: MAL has no
  /// dedicated entry endpoint, and a title the user has no status for (or a
  /// 404 media id) reads as the empty entry.
  @override
  Future<MediaListEntry> getMediaListEntry(
    Anime selectedAnime,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching User Media List Entry from MyAnimeList for ${selectedAnime.title.userPreferred}");
    final MalUserModel? account = _malAccount(loggedUser);
    if (account == null) return MediaListEntryModel.empty();
    return _userRateService.getEntry(
      user: account,
      targetId: selectedAnime.id,
      target: MalListTarget.anime,
    );
  }

  /// The logged user, when it is a MyAnimeList account. A non-MAL user has no
  /// token to send, so the caller degrades instead of writing anonymously.
  MalUserModel? _malAccount(User loggedUser) {
    if (loggedUser is MalUserModel) return loggedUser;
    _logger.w("Logged user ${loggedUser.name} is not a MyAnimeList account, skipping the list call");
    return null;
  }

  // ---------------------------------------------------------------------
  // Deliberate stubs: metadata/search capabilities MAL does not serve.
  //
  // The factory routes every method below to the metadataService repository
  // (`AnimeRepositoryAnilist` / `AnimeRepositoryShikimori`); MAL is a
  // tracker-only provider (SPEC §9 Q2). Each stub names that deferral so a
  // mis-routed call fails loudly instead of rendering fabricated data.
  // ---------------------------------------------------------------------

  static Never _metadataStub(String method) {
    throw UnimplementedError(
      "AnimeRepositoryMal.$method is deferred: MAL is a tracker-only provider, "
      "and the factory routes metadata reads to the metadataService repository "
      "(SPEC §9 Q2). Implement it only when MAL becomes a metadata provider.",
    );
  }

  @override
  Future<(bool, List<Anime>)> getRecentlyReleasedAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async =>
      _metadataStub('getRecentlyReleasedAnimes');

  @override
  Future<(bool, List<Anime>)> getTrendingAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async =>
      _metadataStub('getTrendingAnimes');

  @override
  Future<(bool, List<Anime>)> getPopularAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async =>
      _metadataStub('getPopularAnimes');

  @override
  Future<(bool, List<Anime>)> getRecentlyCompletedAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async =>
      _metadataStub('getRecentlyCompletedAnimes');

  @override
  Future<(bool, List<Anime>)> getUpcomingAnimes(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async =>
      _metadataStub('getUpcomingAnimes');

  @override
  Future<Map<String, List<Anime>>> getCalendarReleases(int page, User loggedUser) async =>
      _metadataStub('getCalendarReleases');

  @override
  Future<(bool, AnimeDetails)> getAnimeDetails(
    Anime selectedAnime,
    User loggedUser, {
    Service? service,
  }) async =>
      _metadataStub('getAnimeDetails');

  @override
  Future<Map<String, (bool, List<String>)>> getUserAnimeAdvancedSearchFilters(User loggedUser) async =>
      _metadataStub('getUserAnimeAdvancedSearchFilters');

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
  ) async =>
      _metadataStub('performAnimeAdvancedSearch');

  @override
  Future<List<String>> getMediaCoverImages(User loggedUser, {bool ignoreCache = false}) async =>
      _metadataStub('getMediaCoverImages');
}

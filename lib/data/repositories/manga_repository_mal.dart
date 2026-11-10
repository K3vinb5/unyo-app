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
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';

/// MyAnimeList tracker (userService) for manga list entries (WP #156).
///
/// Mirror of `MangaRepositoryShikimori`: the list-entry half delegates to
/// [MalUserRateService] (`GET /manga/{id}?fields=my_list_status`,
/// `PUT|DELETE /manga/{id}/my_list_status`), and every metadata method is a
/// deliberate stub (the factory routes metadata reads to the metadataService
/// repository; MAL is a tracker-only provider, SPEC §9 Q2 — same precedent as
/// `UserRepositoryLocal`).
class MangaRepositoryMal with RepositoryMixin implements MangaRepository {
  /// Resolved on first use so metadata-only tests can build this repository
  /// without the rate service registered (mirror of the Shikimori repos).
  MalUserRateService get _userRateService => sl<MalUserRateService>();
  final Logger _logger = sl<Logger>();

  /// WP #156: manga writes go to `PUT /manga/{id}/my_list_status` (chapters +
  /// volumes counters), and an empty-status entry is the delete.
  ///
  /// Deliberately **not** on [MangaRepository]: the interface has no list-entry
  /// API yet (manga entries are not editable in the v1 UI), so this stays a
  /// concrete capability the factory does not route to — exactly like
  /// `MangaRepositoryShikimori`.
  Future<MediaListEntry> updateMediaListEntry(
    MediaListEntry newMediaListEntry,
    Manga selectedManga,
    User loggedUser,
  ) async {
    _logger.i("Updating Media List Entry to $newMediaListEntry on MyAnimeList");
    final MalUserModel? account = _malAccount(loggedUser);
    if (account == null) return MediaListEntryModel.empty();
    return _userRateService.updateEntry(
      user: account,
      targetId: selectedManga.id,
      target: MalListTarget.manga,
      entry: newMediaListEntry,
    );
  }

  /// The reader is `GET /manga/{id}?fields=my_list_status`; no status (or a
  /// 404 media id) reads as the empty entry.
  Future<MediaListEntry> getMediaListEntry(
    Manga selectedManga,
    User loggedUser, {
    bool ignoreCache = false,
  }) async {
    _logger.i("Fetching User Media List Entry from MyAnimeList for ${selectedManga.title.userPreferred}");
    final MalUserModel? account = _malAccount(loggedUser);
    if (account == null) return MediaListEntryModel.empty();
    return _userRateService.getEntry(
      user: account,
      targetId: selectedManga.id,
      target: MalListTarget.manga,
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
  // (`MangaRepositoryAnilist` / `MangaRepositoryShikimori`); MAL is a
  // tracker-only provider (SPEC §9 Q2). Each stub names that deferral so a
  // mis-routed call fails loudly instead of rendering fabricated data.
  // ---------------------------------------------------------------------

  static Never _metadataStub(String method) {
    throw UnimplementedError(
      "MangaRepositoryMal.$method is deferred: MAL is a tracker-only provider, "
      "and the factory routes metadata reads to the metadataService repository "
      "(SPEC §9 Q2). Implement it only when MAL becomes a metadata provider.",
    );
  }

  @override
  Future<(bool, List<Manga>)> getTrendingMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async =>
      _metadataStub('getTrendingMangas');

  @override
  Future<(bool, List<Manga>)> getPopularMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async =>
      _metadataStub('getPopularMangas');

  @override
  Future<(bool, List<Manga>)> getRecentlyCompletedMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async =>
      _metadataStub('getRecentlyCompletedMangas');

  @override
  Future<(bool, List<Manga>)> getUpcomingMangas(
    int page,
    User loggedUser, {
    bool ignoreCache = false,
  }) async =>
      _metadataStub('getUpcomingMangas');

  @override
  Future<(bool, MangaDetails)> getMangaDetails(
    Manga selectedManga,
    User loggedUser, {
    Service? service,
  }) async =>
      _metadataStub('getMangaDetails');

  @override
  Future<Map<String, (bool, List<String>)>> getUserMangaAdvancedSearchFilters(User loggedUser) async =>
      _metadataStub('getUserMangaAdvancedSearchFilters');

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
  ) async =>
      _metadataStub('performMangaAdvancedSearch');

  @override
  Future<List<String>> getMediaCoverImages(User loggedUser, {bool ignoreCache = false}) async =>
      _metadataStub('getMediaCoverImages');
}

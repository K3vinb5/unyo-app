import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/user.dart';

abstract class AnimeRepository {
  Future<(bool, List<Anime>)> getRecentlyReleasedAnimes(int page, User loggedUser, {bool ignoreCache = false});
  Future<(bool, List<Anime>)> getTrendingAnimes(int page, User loggedUser, {bool ignoreCache = false});
  Future<(bool, List<Anime>)> getPopularAnimes(int page, User loggedUser, {bool ignoreCache = false});
  Future<(bool, List<Anime>)> getRecentlyCompletedAnimes(int page, User loggedUser, {bool ignoreCache = false});
  Future<(bool, List<Anime>)> getUpcomingAnimes(int page, User loggedUser, {bool ignoreCache = false});
  Future<Map<String, List<Anime>>> getCalendarReleases(int page, User loggedUser);
  /// [service] overrides the configured metadata provider. It exists for the
  /// unresolved-mapping fallback (WP #61 rule 5), where details must come from
  /// the record's own provider instead of the metadata provider.
  Future<(bool, AnimeDetails)> getAnimeDetails(Anime selectedAnime, User loggedUser, {Service? service});
  /// Filters are provider-specific (`genres(entryType: ...)`), so the metadata
  /// provider from [loggedUser] decides which dictionary is built.
  Future<Map<String, (bool, List<String>)>> getUserAnimeAdvancedSearchFilters(User loggedUser);
  Future<List<Anime>> performAnimeAdvancedSearch(
    String query,
    List<String> selectedGenres,
    String? selectedSeason,
    String? selectedFormat,
    int? selectedYear,
    String? selectedAiringStatus,
    String sort,
    int page,
    User loggedUser
  );
  Future<List<String>> getMediaCoverImages(User loggedUser, {bool ignoreCache = false});
  Future<MediaListEntry> updateMediaListEntry(MediaListEntry newMediaListEntry, Anime selectedAnime, User loggedUser);
  Future<MediaListEntry> getMediaListEntry(Anime selectedAnime, User loggedUser, {bool ignoreCache = false});
}

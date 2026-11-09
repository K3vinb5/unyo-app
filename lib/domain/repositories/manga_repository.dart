import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/user/user.dart';

abstract class MangaRepository {
  Future<(bool, List<Manga>)> getTrendingMangas(int page, User loggedUser, {bool ignoreCache = false});
  Future<(bool, List<Manga>)> getPopularMangas(int page, User loggedUser, {bool ignoreCache = false});
  Future<(bool, List<Manga>)> getRecentlyCompletedMangas(int page, User loggedUser, {bool ignoreCache = false});
  Future<(bool, List<Manga>)> getUpcomingMangas(int page, User loggedUser, {bool ignoreCache = false});
  /// [service] overrides the configured metadata provider. See
  /// `AnimeRepository.getAnimeDetails`.
  Future<(bool, MangaDetails)> getMangaDetails(Manga selectedManga, User loggedUser, {Service? service});
  Future<Map<String, (bool, List<String>)>> getUserMangaAdvancedSearchFilters(User loggedUser);
  Future<List<Manga>> performMangaAdvancedSearch(
    String query,
    List<String> selectedGenres,
    String? selectedFormat,
    String? selectedCountry,
    String? selectedAiringStatus,
    String sort,
    int page,
    User loggedUser
  );
  Future<List<String>> getMediaCoverImages(User loggedUser, {bool ignoreCache = false});

  /// The viewer's list entry for [selectedManga] (WP #167). Readers degrade to
  /// the empty entry; only writes ever throw for an unaddressable record.
  Future<MediaListEntry> getMediaListEntry(Manga selectedManga, User loggedUser, {bool ignoreCache = false});

  /// Writes the viewer's list entry. A draft carrying no list status
  /// (`MediaListEntryModel.noStatus`) is refused — a save never deletes
  /// (WP #167).
  Future<MediaListEntry> updateMediaListEntry(
    MediaListEntry newMediaListEntry,
    Manga selectedManga,
    User loggedUser,
  );

  /// Removes the viewer's list entry — the *only* delete route, used by the
  /// editor's trash action after its confirmation (WP #167).
  Future<MediaListEntry> deleteMediaListEntry(Manga selectedManga, User loggedUser);
}
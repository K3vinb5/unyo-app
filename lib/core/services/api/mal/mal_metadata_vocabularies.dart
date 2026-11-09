// External dependencies
import 'package:collection/collection.dart';

/// MyAnimeList static vocabularies for the advanced-search filters (WP #166).
///
/// MAL has no genre dictionary endpoint on v2 and its filter values are fixed
/// enums, so — unlike Shikimori, which fetches `genres(entryType:)` — these are
/// constants.
///
/// The filter values are **Jikan v4's**, not MAL v2's: since the amended SPEC
/// §2 the advanced search runs on the Jikan v4 API (`config.jikanBaseEndpoint`
/// — Tenrai by default, a self-hosted Jikan compatible) at `/anime|manga`,
/// because MAL's `/anime` and `/manga` accept only a required `q` plus paging
/// and silently ignore every other filter. Only the axes it actually filters
/// are exposed (`type`, `status`, `genres`, `order_by` + `sort`); a value it
/// does not define is never sent.
///
/// Sources:
/// * genre ids/names: MAL's official genre list (the ids are stable and shared
///   by the anime and manga spaces for the classic 44 entries; Jikan's
///   `genres` filter takes the same ids — spot-checked against live genre links
///   on `myanimelist.net` — Action 1, Adventure 2, Drama 8, Fantasy 10,
///   Shounen 27, Military 38).
/// * filter enums: `app/Enums/*Enum.php` of the Jikan reference implementation
///   (`AnimeStatusEnum`, `MangaStatusEnum`, `AnimeTypeEnum`, `MangaTypeEnum`,
///   `AnimeOrderByEnum`/`MangaOrderByEnum`, `SortDirection`), i.e. the exact
///   values its validator accepts.
/// * ranking types: the `ranking_type` table of `/anime/ranking` and
///   `/manga/ranking` (v2; probed live — `publishing`/`upcoming` are NOT
///   valid manga ranking types).
abstract final class MalMetadataVocabularies {
  // ---------------------------------------------------------------- genres

  /// Anime genre **name** → MAL genre id (Jikan's `genres` filter takes ids).
  static const Map<String, int> animeGenreIdsByName = <String, int>{
    'Action': 1,
    'Adventure': 2,
    'Cars': 3,
    'Comedy': 4,
    'Dementia': 5,
    'Demons': 6,
    'Mystery': 7,
    'Drama': 8,
    'Ecchi': 9,
    'Fantasy': 10,
    'Game': 11,
    'Hentai': 12,
    'Historical': 13,
    'Horror': 14,
    'Kids': 15,
    'Magic': 16,
    'Martial Arts': 17,
    'Mecha': 18,
    'Music': 19,
    'Parody': 20,
    'Samurai': 21,
    'Romance': 22,
    'School': 23,
    'Sci-Fi': 24,
    'Shoujo': 25,
    'Shoujo Ai': 26,
    'Shounen': 27,
    'Shounen Ai': 28,
    'Space': 29,
    'Sports': 30,
    'Super Power': 31,
    'Vampire': 32,
    'Yaoi': 33,
    'Yuri': 34,
    'Harem': 35,
    'Slice of Life': 36,
    'Supernatural': 37,
    'Military': 38,
    'Police': 39,
    'Psychological': 40,
    'Thriller': 41,
    'Seinen': 42,
    'Josei': 43,
    'Gender Bender': 44,
  };

  /// Manga genre **name** → MAL genre id. MAL (and therefore Jikan) reuses the
  /// anime numbering for the shared genres, so the same 44-entry table applies
  /// (a label unknown to MAL is simply not sent — see [genreIdsFor]).
  static const Map<String, int> mangaGenreIdsByName = animeGenreIdsByName;

  /// Genre labels for the dropdown, sorted by name.
  static List<String> get animeGenreNames => animeGenreIdsByName.keys.toList()..sort();

  static List<String> get mangaGenreNames => mangaGenreIdsByName.keys.toList()..sort();

  /// Labels → the comma-joined id list Jikan's `genres=` accepts, or `null` when
  /// nothing matches (an empty filter means "do not filter").
  static String? genreIdsFor(List<String> labels, {required bool manga}) {
    final Map<String, int> table = manga ? mangaGenreIdsByName : animeGenreIdsByName;
    final List<int> ids = <int>[];
    for (final String label in labels) {
      final int? id = table[label.trim()] ??
          table.entries
              .where((MapEntry<String, int> entry) => entry.key.toLowerCase() == label.trim().toLowerCase())
              .map((MapEntry<String, int> entry) => entry.value)
              .firstOrNull;
      if (id != null && !ids.contains(id)) ids.add(id);
    }
    if (ids.isEmpty) return null;
    return ids.join(',');
  }

  // ------------------------------------------------------- filters (Jikan)

  /// UI label → `type=` value on Jikan `/v4/anime`.
  ///
  /// Human labels the search UI renders → wire values. Keeping the label and the
  /// value apart means the screens never send a display string to the API.
  static const Map<String, String> animeFormatLabels = <String, String>{
    'TV': 'tv',
    'Movie': 'movie',
    'OVA': 'ova',
    'Special': 'special',
    'ONA': 'ona',
    'Music': 'music',
  };

  /// UI label → `type=` value on Jikan `/v4/manga` (`lightnovel` has no
  /// underscore; `oneshot` is not MAL's `one_shot`).
  static const Map<String, String> mangaFormatLabels = <String, String>{
    'Manga': 'manga',
    'Novel': 'novel',
    'Light Novel': 'lightnovel',
    'One Shot': 'oneshot',
    'Doujinshi': 'doujin',
    'Manhwa': 'manhwa',
    'Manhua': 'manhua',
  };

  /// UI label → `status=` value on Jikan `/v4/anime` (`airing|complete|upcoming`,
  /// not MAL's `currently_airing|finished_airing|not_yet_aired`).
  static const Map<String, String> animeStatusLabels = <String, String>{
    'Airing': 'airing',
    'Finished': 'complete',
    'Upcoming': 'upcoming',
  };

  /// UI label → `status=` value on Jikan `/v4/manga`.
  static const Map<String, String> mangaStatusLabels = <String, String>{
    'Publishing': 'publishing',
    'Finished': 'complete',
    'Upcoming': 'upcoming',
    'On Hiatus': 'hiatus',
    'Discontinued': 'discontinued',
  };

  /// UI label → `order_by=` value. Jikan names the column (`score`, `members`,
  /// `start_date`, `end_date`), not MAL's `anime_score`/`manga_score`; direction
  /// is a separate `sort=asc|desc` parameter, so there is no second list.
  static const Map<String, String> animeSortLabels = <String, String>{
    'Popularity': 'popularity',
    'Score': 'score',
    'Members': 'members',
    'Start Date': 'start_date',
    'End Date': 'end_date',
  };

  static const Map<String, String> mangaSortLabels = animeSortLabels;

  /// `SCORE_DESC` (what the shared search screen sends) → Jikan's
  /// `order_by`/`sort` pair, or `null` for an option Jikan does not define
  /// (both parameters are then dropped and Jikan's own order stands).
  static ({String orderBy, String direction})? orderFor(String sort) {
    final String normalized = sort.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
    if (normalized.isEmpty) return null;
    final bool descending = normalized.endsWith('_desc');
    final String base = normalized.replaceAll(RegExp(r'_(asc|desc)$'), '');
    if (base.isEmpty) return null;
    for (final MapEntry<String, String> entry in animeSortLabels.entries) {
      final String label = entry.key.toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
      if (label == base || entry.value == base) {
        return (orderBy: entry.value, direction: descending ? 'desc' : 'asc');
      }
    }
    return null;
  }

  // -------------------------------------------------------------- rankings

  /// `ranking_type=` of `/anime/ranking` (v2 reference; `upcoming` probed live).
  static const List<String> animeRankingTypes = <String>[
    'all',
    'airing',
    'upcoming',
    'tv',
    'ova',
    'movie',
    'special',
    'bypopularity',
    'favorite',
  ];

  /// `ranking_type=` of `/manga/ranking`. `publishing`/`upcoming` are **not**
  /// in the reference and probe as `400 invalid ranking_type`.
  static const List<String> mangaRankingTypes = <String>[
    'all',
    'manga',
    'novels',
    'oneshots',
    'doujin',
    'manhwa',
    'manhua',
    'bypopularity',
    'favorite',
  ];

  //
  // Filter dictionaries shaped exactly like `getUserAnimeAdvancedSearchFilters`
  // (Shikimori): `(isVisible, values)`. `sortOrders` stays hidden: Jikan takes
  // the direction inside the sort string the screen already sends, so there is
  // no second list to pick from. No `ratings` entry: the search cubit never
  // reads one, and Jikan's rating codes (`pg13`/`r17`) are not MAL's.
  //

  static Map<String, (bool, List<String>)> animeFilterMap() {
    return <String, (bool, List<String>)>{
      'genres': (true, animeGenreNames),
      'formats': (true, animeFormatLabels.keys.toList()),
      'airingStatuses': (true, animeStatusLabels.keys.toList()),
      'sortOptions': (true, animeSortLabels.keys.toList()),
      'sortOrders': (false, <String>[]),
    };
  }

  static Map<String, (bool, List<String>)> mangaFilterMap() {
    return <String, (bool, List<String>)>{
      'genres': (true, mangaGenreNames),
      'formats': (true, mangaFormatLabels.keys.toList()),
      'airingStatuses': (true, mangaStatusLabels.keys.toList()),
      'sortOptions': (true, mangaSortLabels.keys.toList()),
      'sortOrders': (false, <String>[]),
    };
  }
}

// External dependencies
import 'package:collection/collection.dart';

/// MyAnimeList static vocabularies for the advanced-search filters (WP #166).
///
/// MAL has no genre dictionary endpoint on v2 and its filter values are fixed
/// enums, so — unlike Shikimori, which fetches `genres(entryType:)` — these are
/// constants.
///
/// Sources:
/// * genre ids/names: MAL's official genre list (the ids are stable and shared
///   by the anime and manga spaces for the classic 44 entries; spot-checked
///   against live genre links on `myanimelist.net` — Action 1, Adventure 2,
///   Drama 8, Fantasy 10, Shounen 27, Military 38).
/// * statuses/ratings/formats/sort keys: the official v2 reference
///   (<https://myanimelist.net/apiconfig/references/api/v2>) plus the node
///   enums (`finished_airing`, `currently_airing`, `not_yet_aired`).
/// * ranking types: the `ranking_type` table of `/anime/ranking` and
///   `/manga/ranking`.
abstract final class MalMetadataVocabularies {
  // ---------------------------------------------------------------- genres

  /// Anime genre **name** → MAL genre id (the `genre=` filter takes ids only).
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

  /// Manga genre **name** → MAL genre id. MAL reuses the anime numbering for
  /// the shared genres; the manga-only ids are not needed by the v2 filter, so
  /// the same 44-entry table is exposed (a label unknown to MAL is simply not
  /// sent — see [genreIdsFor]).
  static const Map<String, int> mangaGenreIdsByName = animeGenreIdsByName;

  /// Genre labels for the dropdown, sorted by name.
  static List<String> get animeGenreNames => animeGenreIdsByName.keys.toList()..sort();

  static List<String> get mangaGenreNames => mangaGenreIdsByName.keys.toList()..sort();

  /// Labels → the comma-joined id list MAL's `genre=` accepts, or `null` when
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

  // ----------------------------------------------------------------- types

  /// `type=` of `/anime`.
  static const List<String> animeFormats = <String>['tv', 'movie', 'ova', 'special', 'ona', 'music'];

  /// `type=` of `/manga`.
  static const List<String> mangaFormats = <String>['manga', 'novel', 'one_shot', 'doujin', 'manhwa', 'manhua'];

  // -------------------------------------------------------------- statuses

  /// `status=` of `/anime` (same enum the node's `status` carries).
  static const List<String> animeStatuses = <String>['currently_airing', 'finished_airing', 'not_yet_aired'];

  /// `status=` of `/manga`.
  static const List<String> mangaStatuses = <String>['publishing', 'finished', 'not_yet_published'];

  // --------------------------------------------------------------- ratings

  /// `rating=` of `/anime`: all-ages → hentai.
  static const List<String> animeRatings = <String>['g', 'pg', 'pg_13', 'r', 'r+', 'rx'];

  // ----------------------------------------------------------------- sorts

  /// `sort=` of `/anime`; prefix `-` for descending.
  static const List<String> animeSorts = <String>[
    'anime_score',
    'anime_num_list_users',
    'anime_start_date',
    'anime_end_date',
  ];

  /// `sort=` of `/manga`; prefix `-` for descending.
  static const List<String> mangaSorts = <String>[
    'manga_score',
    'manga_num_list_users',
    'manga_start_date',
    'manga_end_date',
  ];

  // -------------------------------------------------------------- rankings

  /// `ranking_type=` of `/anime/ranking`.
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

  /// `ranking_type=` of `/manga/ranking`.
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

  // ------------------------------------------------------- UI label → value

  /// Human labels the search UI renders → wire values. Keeping the label and the
  /// value apart means the screens never send a display string to MAL.
  static const Map<String, String> animeFormatLabels = <String, String>{
    'TV': 'tv',
    'Movie': 'movie',
    'OVA': 'ova',
    'Special': 'special',
    'ONA': 'ona',
    'Music': 'music',
  };

  static const Map<String, String> mangaFormatLabels = <String, String>{
    'Manga': 'manga',
    'Novel': 'novel',
    'One Shot': 'one_shot',
    'Doujinshi': 'doujin',
    'Manhwa': 'manhwa',
    'Manhua': 'manhua',
  };

  static const Map<String, String> animeStatusLabels = <String, String>{
    'Airing': 'currently_airing',
    'Finished': 'finished_airing',
    'Not Yet Aired': 'not_yet_aired',
  };

  static const Map<String, String> mangaStatusLabels = <String, String>{
    'Publishing': 'publishing',
    'Finished': 'finished',
    'Not Yet Published': 'not_yet_published',
  };

  static const Map<String, String> ratingLabels = <String, String>{
    'G - All Ages': 'g',
    'PG - Children': 'pg',
    'PG-13 - Teens 13+': 'pg_13',
    'R - 17+': 'r',
    'R+ - Mild Nudity': 'r+',
    'Rx - Hentai': 'rx',
  };

  static const Map<String, String> animeSortLabels = <String, String>{
    'Score': 'anime_score',
    'Members': 'anime_num_list_users',
    'Start Date': 'anime_start_date',
    'End Date': 'anime_end_date',
  };

  static const Map<String, String> mangaSortLabels = <String, String>{
    'Score': 'manga_score',
    'Members': 'manga_num_list_users',
    'Start Date': 'manga_start_date',
    'End Date': 'manga_end_date',
  };

  /// `-` prefix = descending, mirroring Shikimori's two-dictionary split (sort
  /// field + direction).
  static String sortFor(String field, {required bool descending}) {
    final String normalized = field.trim().toLowerCase();
    if (normalized.isEmpty) return '';
    return descending ? '-$normalized' : normalized;
  }

  //
  // Filter dictionaries shaped exactly like `getUserAnimeAdvancedSearchFilters`
  // (Shikimori): `(isVisible, values)`. `sortOrders` stays hidden: MAL expresses
  // direction with the `-` prefix on the sort field, so there is no second list
  // to pick from.
  //

  static Map<String, (bool, List<String>)> animeFilterMap() {
    return <String, (bool, List<String>)>{
      'genres': (true, animeGenreNames),
      'formats': (true, animeFormatLabels.keys.toList()),
      'airingStatuses': (true, animeStatusLabels.keys.toList()),
      'ratings': (true, ratingLabels.keys.toList()),
      'sortOptions': (true, animeSortLabels.keys.toList()),
      'sortOrders': (false, <String>[]),
    };
  }

  static Map<String, (bool, List<String>)> mangaFilterMap() {
    return <String, (bool, List<String>)>{
      'genres': (true, mangaGenreNames),
      'formats': (true, mangaFormatLabels.keys.toList()),
      'airingStatuses': (true, mangaStatusLabels.keys.toList()),
      'ratings': (true, ratingLabels.keys.toList()),
      'sortOptions': (true, mangaSortLabels.keys.toList()),
      'sortOrders': (false, <String>[]),
    };
  }
}

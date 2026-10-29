/// Translation of the UI's advanced-search dictionaries into Shikimori
/// GraphQL variables.
///
/// Every rule here comes from a live probe on 2026-10-29 (evidence:
/// `research/unyo-64-shikimori-parity-proof/raws/api/gql-advanced-search-probes.txt`):
///
/// * `order` is an unquoted `OrderEnum` **literal** whose accepted values are
///   `id, id_desc, ranked, popularity, name, aired_on, episodes, status,
///   updated_at_desc` — `popularity_desc`, `name_desc`, `aired_on_desc` and
///   `ranked_desc` are all rejected, so the UI's `<option>_<order>` string is
///   collapsed onto that set instead of being passed through;
/// * `score` is an `Int` (0–10), not the REST `String`;
/// * `duration` is the enum `S`/`D`/`F`, not a minute count;
/// * `genre` takes genre **ids**, not names, and the id space differs between
///   `genres(entryType: Anime)` and `genres(entryType: Manga)`;
/// * multiple selected genres are joined with a comma (`genre=1,2` is accepted).
abstract final class ShikimoriSearchParameters {
  /// The `OrderEnum` values the server accepted, keyed by the option the UI
  /// shows (`ShikimoriSortOptions` / `ShikimoriMangaSortOptions`).
  static const Map<String, String> ascendingOrders = <String, String>{
    'id': 'id',
    'ranked': 'ranked',
    'popularity': 'popularity',
    'name': 'name',
    'aired_on': 'aired_on',
    'episodes': 'episodes',
    'status': 'status',
    'updated_at': 'updated_at_desc',
  };

  /// `"Popularity_Desc"` / `"AIRING_ON_ASC"` → an accepted `OrderEnum` value.
  ///
  /// Only `id` has a descending twin, so `desc` is honoured for `id` and
  /// ignored everywhere else (the server has no `*_desc` variants). Anything
  /// unknown degrades to `popularity`, the default the carousels use.
  static String orderFor(String sort) {
    final String normalized = sort.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
    final bool descending = normalized.endsWith('_desc');
    final String base = normalized.replaceAll(RegExp(r'_(asc|desc)$'), '');
    final String? order = ascendingOrders[base];
    if (order == null) return 'popularity';
    if (descending && base == 'id') return 'id_desc';
    return order;
  }

  /// `"Tv special"` → `tv_special`, but only when [allowed] contains it.
  static String? choiceFor(String? selected, Iterable<String> allowed) {
    if (selected == null) return null;
    final String normalized = selected.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
    if (normalized.isEmpty) return null;
    return allowed.contains(normalized) ? normalized : null;
  }

  /// `season` + optional `year` → the `SeasonString` (`fall` / `fall_2023`).
  ///
  /// A year without a season cannot be expressed: the schema has no year
  /// argument, only `SeasonString`.
  static String? seasonFor(String? selectedSeason, int? year, Iterable<String> allowed) {
    final String? season = choiceFor(selectedSeason, allowed);
    if (season == null) return null;
    if (year == null || year <= 0) return season;
    return '${season}_$year';
  }

  /// Selected genre labels → the comma-separated `genre` argument.
  ///
  /// Labels come from the filter dictionary (genre `name`s); an unknown label
  /// is dropped rather than guessed, and a numeric value is accepted as an id.
  static String? genreIdsFor(List<String> selectedGenres, Map<String, String> idsByName) {
    final List<String> ids = <String>[];
    for (final String selected in selectedGenres) {
      final String label = selected.trim();
      if (label.isEmpty) continue;
      final String? id = idsByName[label.toLowerCase()] ??
          (int.tryParse(label) != null ? label : null);
      if (id != null && !ids.contains(id)) ids.add(id);
    }
    if (ids.isEmpty) return null;
    return ids.join(',');
  }

  /// Display label for a dictionary value: `aired_on` → `Aired on`,
  /// `tv_special` → `Tv special`, first letter upper-case.
  static String label(String value) {
    final String words = value.replaceAll('_', ' ');
    if (words.isEmpty) return words;
    return words[0].toUpperCase() + words.substring(1);
  }
}

/// The `GenreEntryTypeEnum` wire values. The server only accepts the PascalCase
/// spellings (`Anime`, `Manga`) — `ANIME`/`anime` are both rejected (WP #64 §8).
enum ShikimoriGenreEntryType {
  anime('Anime'),
  manga('Manga');

  const ShikimoriGenreEntryType(this.graphqlValue);

  final String graphqlValue;
}

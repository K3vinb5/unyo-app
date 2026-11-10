/// MyAnimeList ↔ domain list-status policy (WP #156).
///
/// Mirrors `ShikimoriListStatusPolicy`, adapted to MAL's two status
/// vocabularies. MAL spells "current" and "planned" per media kind:
///
/// | MAL anime | MAL manga | unified status | `repeat` |
/// | --- | --- | --- | --- |
/// | `watching` | `reading` | `CURRENT` | `num_times_rewatched`/`reread` |
/// | `plan_to_watch` | `plan_to_read` | `PLANNING` | … |
/// | `completed` | `completed` | `COMPLETED` | … |
/// | `on_hold` | `on_hold` | `PAUSED` | … |
/// | `dropped` | `dropped` | `DROPPED` | … |
///
/// MAL has **no** `rewatching` status: "currently rewatching" is the
/// `is_rewatching`/`is_rereading` boolean on a `watching`/`reading` entry, and
/// the completed counter is `num_times_rewatched`/`num_times_reread`. The fold
/// is therefore the same as Shikimori's `rewatching`: it reads as `CURRENT`
/// and keeps its own repeat count (no `+1`, so a write cannot inflate the
/// user's real progress). `REPEATING` is only ever written: it maps back to
/// `watching`/`reading` **plus** `is_rewatching`/`is_rereading = true`.
///
/// The read direction is one table over both vocabularies (no conflicts); the
/// write direction needs [MalListTarget] to pick the vocabulary.
abstract final class MalListStatusPolicy {
  /// Unified (AniList-shaped) statuses, the vocabulary `MediaListEntry` carries.
  static const String current = 'CURRENT';
  static const String planning = 'PLANNING';
  static const String completed = 'COMPLETED';
  static const String dropped = 'DROPPED';
  static const String paused = 'PAUSED';
  static const String repeating = 'REPEATING';

  /// MAL's five anime statuses (the only values `PUT /anime/{id}/my_list_status`
  /// accepts).
  static const List<String> animeStatuses = <String>[
    'plan_to_watch',
    'watching',
    'completed',
    'on_hold',
    'dropped',
  ];

  /// MAL's five manga statuses (`plan_to_read`/`reading` replace the anime pair).
  static const List<String> mangaStatuses = <String>[
    'plan_to_read',
    'reading',
    'completed',
    'on_hold',
    'dropped',
  ];

  /// MAL status → unified status. Unknown values are upper-cased verbatim
  /// (`custom_status` → `CUSTOM STATUS`) instead of invented, exactly like
  /// [ShikimoriListStatusPolicy]: the UI renders the string it is given.
  static String toUnified(String malStatus) {
    switch (malStatus) {
      case 'watching':
      case 'reading':
        return current;
      case 'plan_to_watch':
      case 'plan_to_read':
        return planning;
      case 'completed':
        return completed;
      case 'dropped':
        return dropped;
      case 'on_hold':
        return paused;
      default:
        return malStatus.toUpperCase().replaceAll('_', ' ');
    }
  }

  /// Unified status → MAL status, the write path. An empty result means
  /// "no status" — the caller must not send it (that is a delete, not an
  /// update). `REPEATING` lands on the kind's current bucket; the caller also
  /// sends `is_rewatching`/`is_rereading = true` for it.
  static String toMal(String unifiedStatus, {required MalListTarget target}) {
    final String normalized = unifiedStatus.toUpperCase().replaceAll(' ', '_');
    switch (normalized) {
      case current:
      case repeating:
        return target == MalListTarget.anime ? 'watching' : 'reading';
      case planning:
        return target == MalListTarget.anime ? 'plan_to_watch' : 'plan_to_read';
      case completed:
        return 'completed';
      case dropped:
        return 'dropped';
      case paused:
        return 'on_hold';
      default:
        return '';
    }
  }

  /// The `repeat` value a stored counter represents. Negative counters clamp
  /// to zero (a MAL list cannot hold them, and `-1` is the empty-entry
  /// sentinel).
  static int repeatFor(int timesRewatchedOrReread) {
    return timesRewatchedOrReread < 0 ? 0 : timesRewatchedOrReread;
  }

  /// The `num_times_rewatched`/`num_times_reread` value to send for a unified
  /// status: every status carries its `repeat` unchanged, which is exactly the
  /// value read back.
  static int rewatchCountFor({required String unifiedStatus, required int repeat}) {
    return repeat < 0 ? 0 : repeat;
  }

  /// Whether the write must set `is_rewatching`/`is_rereading`. Only
  /// `REPEATING` owns the flag; a plain `CURRENT` write clears it.
  static bool isRewatchingFor(String unifiedStatus) {
    return unifiedStatus.toUpperCase().replaceAll(' ', '_') == repeating;
  }

  /// AniList vocabulary of the unified statuses, used as the media-list bucket
  /// names so the list screen shows the same tabs for every provider.
  static const List<String> displayOrder = <String>[
    current,
    planning,
    completed,
    repeating,
    paused,
    dropped,
  ];

  static String displayName(String unifiedStatus) {
    switch (unifiedStatus) {
      case current:
        return 'Watching';
      case planning:
        return 'Planning';
      case completed:
        return 'Completed';
      case repeating:
        return 'Repeating';
      case paused:
        return 'Paused';
      case dropped:
        return 'Dropped';
      default:
        return unifiedStatus;
    }
  }

  /// Which MAL statuses feed a unified bucket. `CURRENT` is the kind's single
  /// current status (the `is_rewatching` entries are inside it), `REPEATING` is
  /// fed by none — the flag is folded into `CURRENT`, like Shikimori's
  /// `rewatching`.
  static List<String> malStatusesFor(String unifiedStatus, {required MalListTarget target}) {
    switch (unifiedStatus) {
      case current:
        return <String>[target == MalListTarget.anime ? 'watching' : 'reading'];
      case planning:
        return <String>[target == MalListTarget.anime ? 'plan_to_watch' : 'plan_to_read'];
      case completed:
        return <String>['completed'];
      case paused:
        return <String>['on_hold'];
      case dropped:
        return <String>['dropped'];
      case repeating:
        return <String>[];
      default:
        return <String>[];
    }
  }
}

/// Which media kind a MAL list/status endpoint addresses. Carries the wire
/// path segment (`/anime/{id}/…` vs `/manga/{id}/…`) and selects the status
/// vocabulary in [MalListStatusPolicy].
enum MalListTarget {
  anime('anime'),
  manga('manga');

  const MalListTarget(this.wireValue);

  final String wireValue;

  /// The `malStatuses`/`malStatusesFor` vocabulary for this kind.
  List<String> get statuses => this == MalListTarget.anime
      ? MalListStatusPolicy.animeStatuses
      : MalListStatusPolicy.mangaStatuses;
}

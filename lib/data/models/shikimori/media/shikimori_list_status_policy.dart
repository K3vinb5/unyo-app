/// Shikimori ↔ domain list-status policy (WP #64 subpart (c), decision 5).
///
/// Shikimori's `UserRateStatusEnum` has six values and one of them,
/// `rewatching`, has no AniList equivalent: AniList reaches the same state by
/// keeping status `CURRENT` and bumping `repeat`. The app's [MediaListEntry]
/// stays AniList-shaped (decision 5), so the fold happens here, in one testable
/// table, instead of in each repository call site:
///
/// | `userRate.status` | unified status | `repeat` |
/// | --- | --- | --- |
/// | `watching` | `CURRENT` | `rewatches` |
/// | `rewatching` | `CURRENT` | `rewatches` |
/// | `planned` | `PLANNING` | `rewatches` |
/// | `completed` | `COMPLETED` | `rewatches` |
/// | `on_hold` | `PAUSED` | `rewatches` |
/// | `dropped` | `DROPPED` | `rewatches` |
///
/// `rewatching` deliberately folds to `CURRENT` **and keeps its own
/// `rewatches` count** — it does not add one, because that extra count would be
/// written back as a completed rewatch on the next update and inflate the user's
/// real progress on every round trip.
///
/// The reverse direction is the same table read upwards: `REPEATING` is the one
/// unified status that maps to `rewatching`, everything else is identity through
/// the table.
abstract final class ShikimoriListStatusPolicy {
  /// Unified (AniList-shaped) statuses, the vocabulary [MediaListEntry] carries.
  static const String current = 'CURRENT';
  static const String planning = 'PLANNING';
  static const String completed = 'COMPLETED';
  static const String dropped = 'DROPPED';
  static const String paused = 'PAUSED';
  static const String repeating = 'REPEATING';

  /// Shikimori's six statuses, in `UserRateStatusEnum` order
  /// (`raws/api/introspection-status-enums.json`).
  static const List<String> shikimoriStatuses = <String>[
    'planned',
    'watching',
    'rewatching',
    'completed',
    'on_hold',
    'dropped',
  ];

  /// Shikimori status → unified status. Unknown values are upper-cased verbatim
  /// (`custom_status` → `CUSTOM STATUS`) rather than invented: the UI renders the
  /// string it is given and the six known values are the contract.
  static String toUnified(String shikimoriStatus) {
    switch (shikimoriStatus) {
      case 'watching':
      case 'rewatching':
        return current;
      case 'planned':
        return planning;
      case 'completed':
        return completed;
      case 'dropped':
        return dropped;
      case 'on_hold':
        return paused;
      default:
        return shikimoriStatus.toUpperCase().replaceAll('_', ' ');
    }
  }

  /// Unified status → Shikimori status, the write path. An empty result means
  /// "no status" — the caller must not send it (that is a delete, not an update).
  static String toShikimori(String unifiedStatus) {
    switch (unifiedStatus.toUpperCase().replaceAll(' ', '_')) {
      case current:
        return 'watching';
      case planning:
        return 'planned';
      case completed:
        return 'completed';
      case dropped:
        return 'dropped';
      case paused:
        return 'on_hold';
      case repeating:
        return 'rewatching';
      default:
        return '';
    }
  }

  /// The `repeat` value a rate represents. `rewatching` feeds `repeat` from its
  /// own `rewatches` counter — no `+1`, see the class comment.
  static int repeatFor({required String shikimoriStatus, required int rewatches}) {
    return rewatches < 0 ? 0 : rewatches;
  }

  /// The `rewatches` value to send for a unified status. `REPEATING` is the one
  /// status that still owns the Shikimori `rewatching` bucket; every other status
  /// carries its `repeat` unchanged, which is exactly the value read back.
  /// AniList vocabulary of the unified statuses, used as the media-list bucket
  /// names so the list screen shows the same tabs for every provider.
  static const List<String> displayOrder = <String>[current, planning, completed, repeating, paused, dropped];

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

  /// Which Shikimori statuses feed a unified bucket. `CURRENT` is fed by both
  /// `watching` and `rewatching` (the fold), `REPEATING` by none.
  static List<String> shikimoriStatusesFor(String unifiedStatus) {
    switch (unifiedStatus) {
      case current:
        return <String>['watching', 'rewatching'];
      case planning:
        return <String>['planned'];
      case completed:
        return <String>['completed'];
      case paused:
        return <String>['on_hold'];
      case dropped:
        return <String>['dropped'];
      case repeating:
        return <String>[];
      default:
        return <String>[unifiedStatus.toLowerCase()];
    }
  }

  static int rewatchesFor({required String unifiedStatus, required int repeat}) {
    if (repeat < 0) return 0;
    return repeat;
  }
}

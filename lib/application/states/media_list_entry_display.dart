import 'package:unyo/domain/entities/list/media_list_entry.dart';

/// Display mapping for [MediaListEntry] values (WP #167).
///
/// A list entry doubles as a *patch*: `-1` progress and volumes and a `-1.0`
/// score mean "the user never set this", and the `ADD TO LIST` status means
/// "this title is on no list at all" (that is also the removal signal every
/// tracker write path reads, see [MediaListEntryModel.isNoStatus]).
///
/// Those sentinels are meaningful on the wire but meaningless on screen — a
/// fresh entry rendered raw shows `-1` progress, `-1` score and the literal
/// `ADD TO LIST` — so every surface that displays an entry value normalizes it
/// here instead of re-deriving the guard (the score slider used to carry its
/// own inline `!= -1` ternary).
abstract final class MediaListEntryDisplay {
  /// The six status labels the editor offers, in menu order.
  ///
  /// The dropdown and the details chip share this list so a status written by
  /// one is always readable by the other: the unified vocabulary (`CURRENT`,
  /// `PLANNING`, …) and the provider spellings (`WATCHING`) both fold onto
  /// these labels.
  static const List<String> statusOptions = <String>[
    'Current',
    'Planning',
    'Completed',
    'Repeating',
    'Paused',
    'Dropped',
  ];

  /// Progress display stays with `EpisodeCount.progressForControl`: it is the
  /// only piece that also knows the entry's range, so it owns the `-1 -> 0`
  /// mapping *and* the clamp. Nothing renders volume progress today; when it
  /// does, it belongs here next to [score].

  /// Score to show for [score]; the "never scored" sentinel renders as 0.
  static int score(double score) => score < 0 ? 0 : score.round();

  /// Whether [status] puts the title on one of the user's lists.
  static bool isOnList(String status) => !MediaListEntryModel.isNoStatus(status);

  /// Label of [status], or `null` when the title is on no list.
  ///
  /// Known statuses render with the [statusOptions] spelling, so a chip reads
  /// "Current" whether the provider answered `CURRENT` (AniList) or `WATCHING`
  /// (Shikimori, folded to `CURRENT` by the Shikimori policy). Anything the
  /// vocabulary does not know renders verbatim instead of being invented into
  /// a known bucket.
  static String? statusLabel(String status) {
    if (!isOnList(status)) return null;
    final String normalized = status.trim().toUpperCase().replaceAll('_', ' ');
    switch (normalized) {
      case 'CURRENT':
      case 'WATCHING':
      case 'REWATCHING':
        return 'Current';
      case 'PLANNING':
      case 'PLANNED':
        return 'Planning';
      case 'COMPLETED':
        return 'Completed';
      case 'REPEATING':
        return 'Repeating';
      case 'PAUSED':
      case 'ON HOLD':
        return 'Paused';
      case 'DROPPED':
        return 'Dropped';
      default:
        return normalized;
    }
  }
}

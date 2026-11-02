import 'package:unyo/domain/entities/media/airing_episode.dart';

/// How many episodes a details/video surface should render, and where the
/// progress control's range comes from.
///
/// Providers are allowed to leave the total unknown: a Shikimori record whose
/// source publishes no episode count keeps `episodes == 0`, and an AniList
/// record with a null `episodes` maps to the same zero. No single source is
/// authoritative *alone* — the provider's total, the episode metadata and the
/// extension's list each prove that some episodes exist, so the rendered count
/// is the largest of them (WP #115 / #89). A provider total therefore never
/// caps what the extension returned, and a short extension answer never hides
/// the rows the metadata already announced.
class EpisodeCount {
  const EpisodeCount._();

  /// The number of episodes to render: the largest count any known source
  /// proves, never the first non-empty one.
  ///
  /// * provider total 12 + extension 4 → 12 (rows 5-12 keep existing, marked
  ///   "Not yet released" until they air);
  /// * extension 8 + provider total unknown (0/-1) → 8 (no phantom extras);
  /// * extension 12 + provider total 12 → 12 (no duplicates).
  ///
  /// Zero means "nothing resolvable" so the caller keeps its empty state; it is
  /// never used as a cap.
  static int resolve({
    required int extensionResults,
    required int episodesInfo,
    required int metadataTotal,
  }) {
    int resolved = 0;
    for (final int candidate in <int>[extensionResults, episodesInfo, metadataTotal]) {
      if (candidate > resolved) resolved = candidate;
    }
    return resolved;
  }

  /// Progress value a control shows for [progress] within `[0, episodeCount]`.
  ///
  /// `-1` is the list entry's "no progress yet" sentinel and renders as 0; a
  /// value past the resolved count (stale entry, unknown total) is clamped so
  /// the slider never starts outside its own range.
  static int progressForControl({required int progress, required int episodeCount}) {
    final int normalized = progress < 0 ? 0 : progress;
    final int upperBound = episodeCount < 0 ? 0 : episodeCount;
    return normalized > upperBound ? upperBound : normalized;
  }

  /// Progress value to persist for an edit bounded by [episodeCount].
  ///
  /// The editor only *displays* the clamped value ([progressForControl]) and
  /// its slider never reports its initial value back, so saving the untouched
  /// entry would write a number the user never saw. This returns the value the
  /// control was showing: clamped when the resolved count is authoritative, and
  /// the untouched progress when it is not (a zero count means "unknown", and
  /// zeroing a real progress would lose data instead of fixing a display).
  static int progressForSave({required int progress, required int episodeCount}) {
    final int normalized = progress < 0 ? 0 : progress;
    if (episodeCount <= 0) return normalized;
    return normalized > episodeCount ? episodeCount : normalized;
  }

  /// The 1-based episode number each rendered row stands for — exactly [count]
  /// numbers, in ascending order.
  ///
  /// Rows built from an extension list are labelled and navigated by the
  /// numbers the extension returned — a list can start at 13 or skip numbers —
  /// so their position is never used as the episode number. When the extension
  /// proves fewer episodes than the metadata total, the remaining rows continue
  /// the numbering after the last extension number (a 4-episode answer for a
  /// 12-episode series yields 1-4 from the extension and 5-12 from the
  /// metadata). Without extension results the rows count from 1.
  static List<int> episodeNumbers({required List<int> extensionEpisodeNumbers, required int count}) {
    if (count <= 0) return const <int>[];
    final List<int> labels = <int>[];
    final Set<int> seen = <int>{};
    int highest = 0;
    for (final int number in extensionEpisodeNumbers) {
      if (labels.length >= count) break;
      if (number <= 0 || !seen.add(number)) continue;
      labels.add(number);
      if (number > highest) highest = number;
    }
    int next = highest == 0 ? 1 : highest + 1;
    while (labels.length < count) {
      if (seen.add(next)) labels.add(next);
      next++;
    }
    labels.sort();
    return labels;
  }
}

/// Release state of the rendered episode rows — one rule for every provider.
///
/// The providers express "has this episode aired?" differently (AniList sends
/// `airingSchedule.episode`, Shikimori sends `episodes_aired + 1` or nothing at
/// all) and use different airing-status strings. Both are normalized here once,
/// so no presentation widget branches on a service: [Anime.status] already
/// carries the AniList vocabulary because the Shikimori mappers translate into
/// it (`ShikimoriMediaMapper.animeStatus`), and the raw provider spellings are
/// accepted too so a mapper gap can never disable a whole list again.
class EpisodeRelease {
  const EpisodeRelease._();

  /// Canonical airing states, the AniList vocabulary the domain uses.
  static const String finished = 'FINISHED';
  static const String releasing = 'RELEASING';
  static const String notYetReleased = 'NOT_YET_RELEASED';
  static const String cancelled = 'CANCELLED';
  static const String hiatus = 'HIATUS';

  /// Normalizes a provider airing status into the canonical vocabulary.
  /// Unknown values are upper-cased verbatim rather than guessed.
  static String normalizeAiringStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'finished':
      case 'released':
        return finished;
      case 'releasing':
      case 'ongoing':
        return releasing;
      case 'not_yet_released':
      case 'anons':
        return notYetReleased;
      case 'cancelled':
      case 'discontinued':
        return cancelled;
      case 'hiatus':
      case 'paused':
        return hiatus;
      default:
        return status.trim().toUpperCase();
    }
  }

  /// The highest episode number that is out, for a list of [episodeCount] rows.
  ///
  /// A row is playable when `releasedThrough(...) >= episodeNumber`. The result
  /// is never derived arithmetically from a sentinel:
  ///
  /// * no upcoming episode — `nextAiringEpisode.episode` is `-1` (the domain's
  ///   "absent" sentinel), `0`, or missing — means the provider has nothing
  ///   scheduled, so every known episode is released (a finished series must not
  ///   end up at `-2` and mark all of its rows "Not yet released");
  /// * an upcoming episode `N` means episodes `1 … N-1` aired;
  /// * `NOT_YET_RELEASED` with nothing scheduled has aired nothing;
  /// * an unknown total claims nothing, because nothing can be shown anyway.
  static int releasedThrough({
    required AiringEpisode nextAiringEpisode,
    required String airingStatus,
    required int episodeCount,
  }) {
    final int count = episodeCount <= 0 ? 0 : episodeCount;
    final int upcoming = nextAiringEpisode.episode;
    if (upcoming > 0) {
      final int aired = upcoming - 1;
      if (aired <= 0) return 0;
      return aired > count ? count : aired;
    }
    if (normalizeAiringStatus(airingStatus) == notYetReleased) return 0;
    return count;
  }
}

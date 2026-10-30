/// How many episodes a details/video surface should render, and where the
/// progress control's range comes from.
///
/// Providers are allowed to leave the total unknown: a Shikimori record whose
/// source publishes no episode count keeps `episodes == 0`, and an AniList
/// record with a null `episodes` maps to the same zero. The metadata total is
/// therefore the *last* source to ask — whatever the extension or the episode
/// metadata service actually returned is proof that those episodes exist, no
/// matter what the provider claimed.
class EpisodeCount {
  const EpisodeCount._();

  /// Precedence: extension results, episode metadata, provider total, nothing.
  ///
  /// Zero means "nothing resolvable" so the caller keeps its empty state; it is
  /// never used as a cap.
  static int resolve({
    required int extensionResults,
    required int episodesInfo,
    required int metadataTotal,
  }) {
    if (extensionResults > 0) return extensionResults;
    if (episodesInfo > 0) return episodesInfo;
    if (metadataTotal > 0) return metadataTotal;
    return 0;
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

  /// The 1-based episode number each rendered row stands for.
  ///
  /// Rows built from an extension list must be labelled and navigated by the
  /// numbers the extension returned — a list can start at 13 or skip numbers —
  /// so their position is never used as the episode number. Without extension
  /// results the rows come from the metadata total and count from 1.
  static List<int> episodeNumbers({required List<int> extensionEpisodeNumbers, required int count}) {
    if (extensionEpisodeNumbers.isNotEmpty) {
      return extensionEpisodeNumbers.take(count).toList(growable: false);
    }
    return List<int>.generate(count, (int index) => index + 1, growable: false);
  }
}

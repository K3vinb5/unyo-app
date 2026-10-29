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
}

/// Owns the subtitle delay (`sub-delay`) state of one video session.
///
/// The value written to the player is folded from two contributions:
///
///  * **auto** — the correction for the stream's own timeline offset
///    (`VideoStreamInfo.startTime`). External subtitle files handed to the
///    player are timed from 0, while an HLS stream commonly starts at a
///    non-zero PTS, so the cue file is presented too early by exactly that
///    start offset. Embedded subtitle streams share the container timeline and
///    never need it (their correction stays [Duration.zero]).
///  * **user** — a manual nudge in ±0.1 s steps, kept for the lifetime of the
///    session only (no settings persistence).
///
/// [SubtitleOffsetController] is the single place that computes the value;
/// [onChanged] is the only writer of the player property.
class SubtitleOffsetController {
  SubtitleOffsetController({
    required this.onChanged,
    this.maxOffset = const Duration(seconds: 60),
  });

  /// Called with the effective offset whenever it changes. The service wires
  /// this to `player.setProperty('sub-delay', ...)`.
  final void Function(Duration offset) onChanged;

  /// Hard bound on the effective offset; anything beyond is clamped.
  final Duration maxOffset;

  Duration _auto = Duration.zero;
  Duration _user = Duration.zero;

  /// Correction currently applied for the stream's start offset.
  Duration get autoOffset => _auto;

  /// Part of the offset contributed by the user nudge.
  Duration get userOffset => _user;

  /// Effective delay handed to the player (auto + user, clamped).
  Duration get offset => _clamp(_auto + _user);

  /// Correction an external cue file needs for a stream whose first frame sits
  /// at [videoStartTimeMs]. A missing/0/negative start time means the cue file
  /// already shares the media timeline: no correction.
  static Duration autoCorrectionForStream(int? videoStartTimeMs) {
    if (videoStartTimeMs == null || videoStartTimeMs <= 0) return Duration.zero;
    return Duration(milliseconds: videoStartTimeMs);
  }

  /// Converts a delay to the seconds string mdk's `sub-delay` property expects.
  /// Positive values present subtitles later.
  static String toMdkSeconds(Duration delay) =>
      (delay.inMilliseconds / 1000).toStringAsFixed(3);

  Duration _clamp(Duration delay) {
    if (delay > maxOffset) return maxOffset;
    if (delay < -maxOffset) return -maxOffset;
    return delay;
  }

  /// Sets the correction for the current stream's start offset. Used when an
  /// external subtitle file is attached / an embedded track is selected.
  void setAutoOffset(Duration correction) {
    _auto = _clamp(correction.isNegative ? Duration.zero : correction);
    _emit();
  }

  /// Sets the absolute effective delay, keeping the stream correction intact.
  /// Returns the applied value so callers can tell a clamped request apart.
  Duration setOffset(Duration delay) {
    final total = _clamp(delay);
    _user = total - _auto;
    _emit();
    return total;
  }

  /// Manual ±0.1 s step on top of the stream correction.
  Duration nudge(Duration step) => setOffset(offset + step);

  /// Drops both contributions — called whenever the media or the selected
  /// track changes, so a new stream never inherits a stale delay.
  void reset() {
    _auto = Duration.zero;
    _user = Duration.zero;
    _emit();
  }

  void _emit() => onChanged(offset);
}

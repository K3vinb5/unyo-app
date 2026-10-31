/// When the end-of-episode up-next card appears (WP #113 A).
///
/// Pure Dart so the whole rule — window shape, playlist gating, per-episode
/// dismissal — is unit testable without a player or a widget.

/// The single documented trigger constant: the card appears when
/// `duration - position <= max(90s, duration * 4%)`, clamped to at most 180s so
/// a two-hour movie does not offer "up next" three minutes early.
///
/// - a 10 min episode (600s): 4% = 24s -> the 90s floor wins
/// - a 24 min episode (1440s): 4% = 57.6s -> the 90s floor wins
/// - a 45 min episode (2700s): 4% = 108s -> the fraction wins
/// - a 2 h movie (7200s): 4% = 288s -> capped at 180s
const Duration upNextWindowFloor = Duration(seconds: 90);
const Duration upNextWindowCap = Duration(seconds: 180);
const double upNextWindowFraction = 0.04;

/// The visible window length for a media [duration].
Duration upNextWindow(Duration duration) {
  if (duration <= Duration.zero) return Duration.zero;
  final byFraction = duration * upNextWindowFraction;
  final widened = byFraction > upNextWindowFloor ? byFraction : upNextWindowFloor;
  return widened > upNextWindowCap ? upNextWindowCap : widened;
}

/// Whether the playlist has an item after [playlistIndex].
bool hasNextPlaylistEpisode({required int playlistIndex, required int episodeCount}) =>
    playlistIndex >= 0 && episodeCount > 0 && playlistIndex + 1 < episodeCount;

/// Whether the up-next window is open. Unknown duration (0, i.e. the media has
/// not loaded yet) never opens it.
bool isUpNextWindowOpen({
  required Duration position,
  required Duration duration,
  required bool hasNextEpisode,
}) {
  if (!hasNextEpisode) return false;
  if (duration <= Duration.zero) return false;
  final remaining = duration - position;
  return remaining <= upNextWindow(duration);
}

/// Whether the card itself is on screen: the window is open and the user has
/// not dismissed it for *this* episode.
///
/// [dismissedPlaylistIndex] is the episode the dismiss applies to, so the card
/// re-arms by itself as soon as the playlist index moves on, and a fresh open
/// of the same episode (new cubit, no dismissal recorded) shows it again.
bool shouldShowUpNextCard({
  required Duration position,
  required Duration duration,
  required int playlistIndex,
  required int episodeCount,
  required int? dismissedPlaylistIndex,
}) {
  if (dismissedPlaylistIndex == playlistIndex) return false;
  return isUpNextWindowOpen(
    position: position,
    duration: duration,
    hasNextEpisode: hasNextPlaylistEpisode(playlistIndex: playlistIndex, episodeCount: episodeCount),
  );
}

/// `"<episode title> (S<N>E<M>)"` using whatever is actually known: the season
/// is often absent (AniZip gives none), and so is the title before the episode
/// metadata loads. Missing parts are simply left out — never rendered as a
/// dangling `S E` or an empty pair of parentheses.
String upNextEpisodeLabel({
  String? episodeTitle,
  int? seasonNumber,
  int? episodeNumber,
}) {
  final title = (episodeTitle == null || episodeTitle.trim().isEmpty) ? null : episodeTitle.trim();
  final season = (seasonNumber == null || seasonNumber <= 0) ? null : seasonNumber;
  final number = (episodeNumber == null || episodeNumber <= 0) ? null : episodeNumber;
  final tag = (season == null && number == null)
      ? ''
      : '(${season == null ? '' : 'S$season'}${number == null ? '' : 'E$number'})';
  if (title == null) return tag;
  if (tag.isEmpty) return title;
  return '$title $tag';
}

import 'package:unyo_lib/jmodels/jsepisode.dart';

/// Resolves a 1-based [episodeNumber] against the episode list returned by the
/// selected extension and returns the index of that episode inside that list.
///
/// The extension list is expected to be sorted by episode number (see
/// `AnimeDetailsCubit._getEpisodesFromSelectedExtension`), but it is not
/// guaranteed to start at 1 nor to be contiguous, so the episode number must
/// never be used as an index directly.
///
/// Resolution order:
/// 1. exact match on the episode number;
/// 2. legacy behavior (`episodeNumber - 1`) when that position exists;
/// 3. `-1` when the episode is not part of the extension list.
int resolveExtensionEpisodeIndex(List<JSEpisode> episodes, int episodeNumber) {
  return resolveEpisodeIndexFromNumbers(
    episodes.map((episode) => episode.getEpisode_number().toInt()).toList(growable: false),
    episodeNumber,
  );
}

/// Pure index resolution logic behind [resolveExtensionEpisodeIndex], kept
/// separate so it can be tested without instantiating JNI objects.
int resolveEpisodeIndexFromNumbers(List<int> episodeNumbers, int episodeNumber) {
  final int exactIndex = episodeNumbers.indexOf(episodeNumber);
  if (exactIndex != -1) return exactIndex;
  final int legacyIndex = episodeNumber - 1;
  if (legacyIndex >= 0 && legacyIndex < episodeNumbers.length) return legacyIndex;
  return -1;
}

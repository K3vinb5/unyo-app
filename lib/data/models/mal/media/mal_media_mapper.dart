// Internal dependencies
import 'package:unyo/core/services/api/dto/mal/mal_my_list_status_entity.dart';
import 'package:unyo/data/models/mal/media/mal_list_status_policy.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

/// Shared field mapping for every MyAnimeList metadata model factory (WP #166).
///
/// Kept in one place because the same conversions are needed by six factories
/// (anime/manga list nodes, their relation nodes, both details models) and by
/// the tracker's list-entry reads:
///
/// * `mean` is 0–10 (float) and the domain's `meanScore`/`averageScore` are
///   0–100 ints (AniList scale) — [scoreOutOfHundred];
/// * dates are `YYYY-MM-DD`, but MAL also answers `YYYY-MM` and `YYYY` for
///   partial records, so they are parsed by hand into the `day/month/year`
///   string the AniList/Shikimori mappers emit;
/// * `media_type`/`status` are lower-case wire enums normalized to the
///   AniList vocabulary the domain entities carry;
/// * `rating`/`nsfw` are MAL's only adult markers — [isAdult];
/// * the media id **is** the MAL id (identity addressing, SPEC §3), so `id`
///   and `idMal` both carry the node id;
/// * the list-entry fold is the tracker's own ([listEntry]), extracted from
///   `MalUserRateService` so the details models and the tracker cannot drift.
abstract final class MalMediaMapper {
  /// The `Anime`/`Manga` default country-of-origin, same as the AniList models:
  /// MAL metadata is Japanese-animation/manga catalog data.
  static const String countryOfOrigin = 'JP';

  /// Title fallback chain: canonical `title` → English → native title.
  static String preferredTitle({required String title, required String english, required String nativeTitle}) {
    for (final String candidate in <String>[title, english, nativeTitle]) {
      if (candidate.trim().isNotEmpty) return candidate;
    }
    return '';
  }

  /// MAL `mean` (0–10) → domain 0–100. `0` stays the unset sentinel.
  static int scoreOutOfHundred(double mean) {
    if (mean <= 0) return 0;
    return (mean * 10).round();
  }

  /// `YYYY-MM-DD` / `YYYY-MM` / `YYYY` → `day/month/year`, with `0` for every
  /// component the payload does not state (the AniList/Shikimori sentinel).
  static String date(String isoDate) {
    final String trimmed = isoDate.trim();
    if (trimmed.isEmpty) return '0/0/0';
    final List<String> parts = trimmed.split('-');
    final int year = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final int month = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final int day = parts.length > 2 ? int.tryParse(parts[2].split('T').first) ?? 0 : 0;
    return '$day/$month/$year';
  }

  /// `main_picture.large` when present, else `medium` (both always present on a
  /// real node; either may be empty on a relation stub).
  static String coverImage({required String large, required String medium}) {
    if (large.trim().isNotEmpty) return large.trim();
    return medium.trim();
  }

  /// AniList-style format from MAL's `media_type` (`tv`, `movie`, `ova`, `ona`,
  /// `special`, `music`).
  static String animeFormat(String mediaType) {
    switch (mediaType) {
      case 'tv':
        return 'TV';
      case 'movie':
        return 'MOVIE';
      case 'ova':
        return 'OVA';
      case 'ona':
        return 'ONA';
      case 'special':
        return 'SPECIAL';
      case 'music':
        return 'MUSIC';
      default:
        return mediaType.toUpperCase();
    }
  }

  /// AniList-style format from MAL manga's `media_type` (`manga`, `novel`,
  /// `one_shot`, `doujin`, `manhwa`, `manhua`).
  static String mangaFormat(String mediaType) {
    switch (mediaType) {
      case 'manga':
        return 'MANGA';
      case 'novel':
        return 'NOVEL';
      case 'one_shot':
        return 'ONE_SHOT';
      case 'doujin':
        return 'DOUJINSHI';
      case 'manhwa':
        return 'MANHWA';
      case 'manhua':
        return 'MANHUA';
      default:
        return mediaType.toUpperCase();
    }
  }

  /// Anime node `status` → the domain vocabulary.
  static String animeStatus(String status) {
    switch (status) {
      case 'currently_airing':
        return 'RELEASING';
      case 'finished_airing':
        return 'FINISHED';
      case 'not_yet_aired':
        return 'NOT_YET_RELEASED';
      default:
        return status.toUpperCase();
    }
  }

  /// Manga node `status` → the domain vocabulary. MAL uses `currently_publishing`
  /// on the node, while the browse `status=` filter spells it `publishing`; both
  /// fold to `RELEASING` (the filter vocabulary is what the repositories send).
  static String mangaStatus(String status) {
    switch (status) {
      case 'publishing':
      case 'currently_publishing':
        return 'RELEASING';
      case 'finished':
        return 'FINISHED';
      case 'not_yet_published':
        return 'NOT_YET_RELEASED';
      case 'on_hiatus':
        return 'HIATUS';
      case 'discontinued':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  /// Jikan spells statuses as prose (`Currently Airing`, `Finished Airing`)
  /// while the mapper reads MAL's wire enum; fold the prose back onto the wire
  /// value first. Shared by the calendar and the Jikan catalog feeds so the two
  /// cannot drift.
  static String animeStatusFromJikan(String status) {
    switch (status.trim().toLowerCase()) {
      case 'currently airing':
      case 'airing':
        return animeStatus('currently_airing');
      case 'finished airing':
      case 'finished':
      case 'complete':
        return animeStatus('finished_airing');
      case 'not yet aired':
      case 'upcoming':
        return animeStatus('not_yet_aired');
      default:
        return animeStatus(_jikanEnum(status));
    }
  }

  /// Manga counterpart of [animeStatusFromJikan].
  static String mangaStatusFromJikan(String status) {
    switch (status.trim().toLowerCase()) {
      case 'publishing':
      case 'currently publishing':
        return mangaStatus('currently_publishing');
      case 'finished':
      case 'complete':
        return mangaStatus('finished');
      case 'not yet published':
      case 'upcoming':
        return mangaStatus('not_yet_published');
      case 'on hiatus':
      case 'hiatus':
        return mangaStatus('on_hiatus');
      case 'discontinued':
        return mangaStatus('discontinued');
      default:
        return mangaStatus(_jikanEnum(status));
    }
  }

  /// Jikan ratings are prose (`Rx - Hentai`, `PG-13 - Teens 13 or older`); the
  /// adult test reads MAL's short code, so take the prefix. Jikan's codes are
  /// not MAL's (`r17`/`pg13` on Jikan, `r`/`pg_13` on MAL) but both fold to the
  /// same threshold.
  static String ratingFromJikan(String rating) {
    final String normalized = rating.trim().toLowerCase();
    if (normalized.startsWith('rx')) return 'rx';
    if (normalized.startsWith('r+')) return 'r+';
    if (normalized.startsWith('pg-13') || normalized.startsWith('pg13')) return 'pg_13';
    if (normalized.startsWith('pg')) return 'pg';
    if (normalized.startsWith('r')) return 'r';
    if (normalized.startsWith('g')) return 'g';
    return '';
  }

  /// Manga has no `rating` on Jikan; adult entries are marked by the genres
  /// Jikan moved into `explicit_genres`. Only hentai counts as adult — ecchi
  /// stays non-adult, mirroring MAL's `gray` threshold ([isAdult]).
  static String mangaRatingFromJikan(Iterable<String> explicitGenres) {
    for (final String genre in explicitGenres) {
      if (genre.trim().toLowerCase() == 'hentai') return 'rx';
    }
    return '';
  }

  /// Jikan `duration` prose (`23 min per ep`, `1 hr 52 min`) → seconds, the
  /// unit MAL's `average_episode_duration` uses. Unparseable prose stays `0`
  /// rather than inventing a runtime.
  static int durationSeconds(String prose) {
    final String normalized = prose.trim().toLowerCase();
    if (normalized.isEmpty) return 0;
    final RegExpMatch? hours = RegExp(r'(\d+)\s*hr').firstMatch(normalized);
    final RegExpMatch? minutes = RegExp(r'(\d+)\s*min').firstMatch(normalized);
    final int seconds = (hours == null ? 0 : int.parse(hours.group(1)!) * 3600) +
        (minutes == null ? 0 : int.parse(minutes.group(1)!) * 60);
    return seconds;
  }

  /// `Currently Airing` / `On Hiatus` → `currently_airing` / `on_hiatus`.
  static String _jikanEnum(String status) =>
      status.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');

  /// `start_season.season` (`winter|spring|summer|fall`) → AniList vocabulary.
  static String season(String season) {
    final String trimmed = season.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.toUpperCase();
  }

  /// Adult marker. MAL exposes two: `rating` (`g|pg|pg_13|r|r+|rx`) and the
  /// `nsfw` flag (`white|gray|black`). `rx` is hentai and `r+` is
  /// "mild nudity"; `black` is MAL's own adult flag. `gray` (ecchi-adjacent) is
  /// deliberately not adult, mirroring Shikimori's `is_censored` threshold.
  static bool isAdult({required String rating, required String nsfw}) {
    final String normalizedRating = rating.trim().toLowerCase();
    if (normalizedRating == 'rx' || normalizedRating == 'r+') return true;
    return nsfw.trim().toLowerCase() == 'black';
  }

  /// MAL `my_list_status` → the domain entry. `null` when MAL omitted the key
  /// (the user has no entry) — detected by the empty `status`, exactly like
  /// `MalUserRateService._readStatus`.
  static MediaListEntry? listEntry(MalMyListStatusEntity status, {required MalListTarget target}) {
    if (status.status.trim().isEmpty) return null;
    return MediaListEntryModel(
      progress: target == MalListTarget.manga ? status.numChaptersRead : status.numEpisodesWatched,
      progressVolumes: target == MalListTarget.manga ? status.numVolumesRead : 0,
      score: status.score.toDouble(),
      repeat: MalListStatusPolicy.repeatFor(
        target == MalListTarget.manga ? status.numTimesReread : status.numTimesRewatched,
      ),
      status: MalListStatusPolicy.toUnified(status.status),
      startedAt: TextUtils.formatISO8601DateTime(status.startDate),
      completedAt: TextUtils.formatISO8601DateTime(status.finishDate),
    );
  }
}

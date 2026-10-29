// External dependencies
import 'package:unyo/core/services/api/dto/shikimori/anime_details_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/manga_details_query_entity.dart';

// Internal dependencies
import 'package:unyo/domain/entities/media/airing_episode.dart';

/// Shared field mapping for every Shikimori model factory.
///
/// Shikimori's GraphQL payloads differ from AniList's in ways that keep biting
/// the mappers, so the rules live in one place instead of one copy per factory
/// (WP #64):
///
/// * ids are JSON **strings** (`"16498"`) and may be junk for missing relations;
/// * `malId` is a separate, nullable `ID` — never derive `idMal` from `id`
///   (WP #63: Shikimori natives sit in their own sequence, e.g. `1015xxxxx`);
/// * `nextEpisodeAt` is ISO8601 **with an offset**
///   (`2026-10-31T17:00:00+03:00`) while `AiringEpisode.airingAt` is a unix
///   timestamp in seconds everywhere else in the app (AniList); it is converted
///   here so consumers never branch on the provider;
/// * statuses are lower-case enums (`anons`, `ongoing`, `released`, manga adds
///   `paused`/`discontinued`) and kinds are `tv`/`movie`/`manga`/… — both are
///   normalized to the AniList vocabulary the domain entities use;
/// * `description` is Russian-only: the schema has no English field.
abstract final class ShikimoriMediaMapper {
  /// The `Anime`/`Manga` status sentinel for "no MAL link": `0` is what
  /// `AnimeModel.empty()` and the AniList DTOs use for an unset `idMal`.
  static const int unsetMalId = 0;

  /// `id`/`malId`/`character.id`/`genre.id` arrive as strings; the domain uses
  /// `int`. Non-numeric payloads (and legacy `"0"`) map to `0` instead of
  /// throwing.
  static int parseId(String rawId) {
    final int? parsed = int.tryParse(rawId.trim());
    if (parsed == null || parsed <= 0) return 0;
    return parsed;
  }

  /// WP #63: `idMal` comes **strictly** from the `malId` field.
  ///
  /// Present and numeric → that value; `null`/absent (the DTO default `''`) /
  /// `"0"` / junk → [unsetMalId]. It is never backfilled from the Shikimori
  /// `id`: the two id spaces hold unrelated records.
  static int parseMalId(String malId) {
    return parseId(malId);
  }

  /// Whether a `related { anime { … } }` node carries a real payload.
  ///
  /// The API returns `anime: null` for every non-anime relation (manga, novel,
  /// light novel …) and the DTOs eagerly default-construct their children
  /// (`late … anime = …Anime()`), so such a node arrives with `id == ''`.
  /// Mapping it would render a phantom `Anime(id: 0, idMal: 0, title: '')`
  /// card (the #78/#77 phantom-media family).
  static bool isRealAnime(AnimeDetailsQueryAnimesRelatedAnime anime) {
    return parseId(anime.id) > 0;
  }

  /// Mirror of [isRealAnime] for `related { manga { … } }`: an anime adaptation
  /// of a manga comes back as `manga: null`.
  static bool isRealManga(MangaDetailsQueryMangasRelatedManga manga) {
    return parseId(manga.id) > 0;
  }

  /// Display title fallback chain, in the order the Shikimori payload fills the
  /// fields: `name` (romaji) → `english` → `russian`. An entry with only a
  /// Russian title must not render an empty card.
  static String preferredTitle({required String name, required String english, required String russian}) {
    for (final String candidate in <String>[name, english, russian]) {
      if (candidate.trim().isNotEmpty) return candidate;
    }
    return '';
  }

  /// Shikimori scores are 0–10 floats; the domain's `averageScore`/`meanScore`
  /// are 0–100 ints (AniList scale).
  static int scoreOutOfHundred(double score) {
    if (score <= 0) return 0;
    return (score * 10).round();
  }

  static String animeFormat(String kind) {
    switch (kind) {
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
      case 'tv_special':
        return 'TV_SHORT';
      case 'music':
      case 'pv':
        return 'MUSIC';
      case 'cm':
        return 'SPECIAL';
      default:
        return kind.toUpperCase();
    }
  }

  static String animeStatus(String status) {
    switch (status) {
      case 'anons':
        return 'NOT_YET_RELEASED';
      case 'ongoing':
        return 'RELEASING';
      case 'released':
        return 'FINISHED';
      default:
        return status.toUpperCase();
    }
  }

  static String mangaFormat(String kind) {
    switch (kind) {
      case 'manga':
        return 'MANGA';
      case 'manhwa':
        return 'MANHWA';
      case 'manhua':
        return 'MANHUA';
      case 'light_novel':
      case 'novel':
        return 'NOVEL';
      case 'one_shot':
        return 'ONE_SHOT';
      case 'doujin':
        return 'DOUJINSHI';
      default:
        return kind.toUpperCase();
    }
  }

  /// `MangaStatusEnum` adds `paused`/`discontinued` on top of the anime set.
  static String mangaStatus(String status) {
    switch (status) {
      case 'anons':
        return 'NOT_YET_RELEASED';
      case 'ongoing':
        return 'RELEASING';
      case 'released':
        return 'FINISHED';
      case 'paused':
        return 'HIATUS';
      case 'discontinued':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  /// `fall_2023` → `FALL` (the AniList vocabulary the domain uses). The
  /// API also returns the literal `?` for unknown seasons, which maps to `''`.
  static String season(String season) {
    final String name = season.split('_').first.trim();
    if (name.isEmpty || name == '?') return '';
    return name.toUpperCase();
  }

  /// `day/month/year`, the same shape the AniList mappers produce; a missing
  /// date keeps the `0/0/0` sentinel.
  static String date(int day, int month, int year) {
    return "$day/$month/$year";
  }

  /// Converts `nextEpisodeAt` + `episodesAired` into the domain airing episode.
  ///
  /// `episode` is the number about to air (`episodesAired + 1`, `episodesAired`
  /// being the count the API reports as already aired); `airingAt` is unix
  /// **seconds** as a string, matching AniList's `airingAt`. No upcoming episode
  /// (finished/announced-without-date) keeps [AiringEpisodeModel.empty].
  static AiringEpisode nextAiringEpisode({required String nextEpisodeAt, required int episodesAired}) {
    if (nextEpisodeAt.trim().isEmpty) return AiringEpisodeModel.empty();
    final DateTime? airingAt = DateTime.tryParse(nextEpisodeAt);
    if (airingAt == null) return AiringEpisodeModel.empty();
    return AiringEpisodeModel(
      episode: episodesAired + 1,
      airingAt: (airingAt.millisecondsSinceEpoch ~/ 1000).toString(),
    );
  }
}

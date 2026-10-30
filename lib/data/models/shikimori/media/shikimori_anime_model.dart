// External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/shikimori/anime_details_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_list_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/shikimori_calendar_query_entity.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_media_mapper.dart';
import 'package:unyo/domain/entities/media/airing_episode.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/title.dart';

part 'shikimori_anime_model.freezed.dart';
part 'shikimori_anime_model.g.dart';

@freezed
abstract class ShikimoriAnimeModel with _$ShikimoriAnimeModel implements Anime {
  const ShikimoriAnimeModel._();

  factory ShikimoriAnimeModel({
    required int id,
    required int idMal,
    @TitleConverter() required Title title,
    required int averageScore,
    required String bannerImage,
    required String countryOfOrigin,
    required String coverImage,
    required String description,
    required int duration,
    required String endDate,
    required String startDate,
    required int episodes,
    required List<String> genres,
    required String format,
    required bool isAdult,
    required int popularity,
    required int meanScore,
    required String season,
    required String status,
    required bool isFavourite,
    @AiringEpisodeConverter() required AiringEpisode nextAiringEpisode,
  }) = _ShikimoriAnimeModel;

  factory ShikimoriAnimeModel.fromJson(Map<String, dynamic> json) =>
      _$ShikimoriAnimeModelFromJson(json);

  /// Shikimori's `Anime` type has no popularity/rank counter at all (the live
  /// introspection lists 46 fields, none of them popularity — WP #64 §8), and
  /// the carousel ordering happens server-side (`order: popularity`). There is
  /// therefore nothing to compute client-side and the AniList-shaped
  /// [Anime.popularity] keeps the `0` unset sentinel.
  static const int unavailablePopularity = 0;

  /// Shikimori carries no country-of-origin field (`origin` is the source
  /// material, e.g. `manga`); the anime database keeps its `JP` default.
  static const String defaultCountryOfOrigin = 'JP';

  /// What `/api/calendar` can say about adult content: nothing.
  ///
  /// The live capture
  /// (`research/unyo-64-shikimori-parity-proof/raws/api/rest-calendar.json`, 94
  /// entries) carries no `rating` and no `is_censored` — the REST calendar is
  /// smaller than both the REST anime list and GraphQL `Anime`. [isAdult] is
  /// therefore `false` for every calendar entry, deliberately, instead of being
  /// guessed from `kind` (Shikimori has no `hentai` kind — adult titles are
  /// ordinary kinds with a genre/rating flag) or from the title text. The
  /// repository still runs the AniList-shaped NSFW gate over the mapped entries
  /// (`visibleCalendarEntries`), and that gate starts filtering the day this
  /// constant gains a real signal. Residual gap: PR #156.
  static const bool calendarReportsAdult = false;

  /// One carousel entry (`shikimoriAnimeListQuery`).
  factory ShikimoriAnimeModel.fromListEntry(AnimeListQueryAnimes anime) {
    return ShikimoriAnimeModel(
      id: ShikimoriMediaMapper.parseId(anime.id),
      idMal: ShikimoriMediaMapper.parseMalId(anime.malId),
      title: TitleModel(
        romaji: anime.name,
        english: anime.english,
        nativeTitle: anime.japanese,
        userPreferred: ShikimoriMediaMapper.preferredTitle(
          name: anime.name,
          english: anime.english,
          russian: anime.russian,
        ),
        russian: anime.russian,
      ),
      averageScore: ShikimoriMediaMapper.scoreOutOfHundred(anime.score),
      bannerImage: anime.poster.mainAlt2xUrl,
      countryOfOrigin: defaultCountryOfOrigin,
      coverImage: anime.poster.originalUrl,
      description: anime.description,
      duration: anime.duration,
      endDate: ShikimoriMediaMapper.date(anime.releasedOn.day, anime.releasedOn.month, anime.releasedOn.year),
      startDate: ShikimoriMediaMapper.date(anime.airedOn.day, anime.airedOn.month, anime.airedOn.year),
      episodes: anime.episodes,
      genres: anime.genres.map((AnimeListQueryAnimesGenres genre) => genre.name).toList(),
      format: ShikimoriMediaMapper.animeFormat(anime.kind),
      isAdult: anime.isCensored,
      popularity: unavailablePopularity,
      meanScore: ShikimoriMediaMapper.scoreOutOfHundred(anime.score),
      season: ShikimoriMediaMapper.season(anime.season),
      status: ShikimoriMediaMapper.animeStatus(anime.status),
      isFavourite: false,
      nextAiringEpisode: ShikimoriMediaMapper.nextAiringEpisode(
        nextEpisodeAt: anime.nextEpisodeAt,
        episodesAired: anime.episodesAired,
      ),
    );
  }

  /// One `GET /api/calendar` entry (REST, flat array — WP #64 subpart (b)).
  ///
  /// The calendar payload is smaller than the GraphQL one: no `malId` (so
  /// [ShikimoriMediaMapper.unsetMalId] — the id is never reused as the MAL id,
  /// WP #63), no description, genres, season or `is_censored` flag, a
  /// **string** score and site-relative image paths. `next_episode` is the
  /// episode number about to air.
  factory ShikimoriAnimeModel.fromCalendarEntry(ShikimoriCalendarQueryList entry) {
    final ShikimoriCalendarQueryListAnime anime = entry.anime;
    final double score = ShikimoriMediaMapper.parseScore(anime.score);
    return ShikimoriAnimeModel(
      id: anime.id,
      idMal: ShikimoriMediaMapper.unsetMalId,
      title: TitleModel(
        romaji: anime.name,
        english: '',
        nativeTitle: '',
        userPreferred: ShikimoriMediaMapper.preferredTitle(
          name: anime.name,
          english: '',
          russian: anime.russian,
        ),
        russian: anime.russian,
      ),
      averageScore: ShikimoriMediaMapper.scoreOutOfHundred(score),
      bannerImage: '',
      countryOfOrigin: defaultCountryOfOrigin,
      coverImage: ShikimoriMediaMapper.absoluteImageUrl(anime.image.original),
      description: '',
      duration: entry.duration,
      endDate: ShikimoriMediaMapper.dateFromIso(anime.releasedOn ?? ''),
      startDate: ShikimoriMediaMapper.dateFromIso(anime.airedOn),
      episodes: anime.episodes,
      genres: const <String>[],
      format: ShikimoriMediaMapper.animeFormat(anime.kind),
      isAdult: calendarReportsAdult,
      popularity: unavailablePopularity,
      meanScore: ShikimoriMediaMapper.scoreOutOfHundred(score),
      season: '',
      status: ShikimoriMediaMapper.animeStatus(anime.status),
      isFavourite: false,
      nextAiringEpisode: ShikimoriMediaMapper.calendarAiringEpisode(
        nextEpisodeAt: entry.nextEpisodeAt,
        nextEpisode: entry.nextEpisode,
      ),
    );
  }

  /// One `related { anime { … } }` entry of `shikimoriAnimeDetailsQuery`.
  ///
  /// Callers must filter with [ShikimoriMediaMapper.isRealAnime] first: a manga
  /// relation arrives as a default-constructed node with `id == ''`.
  factory ShikimoriAnimeModel.fromRelatedEntry(AnimeDetailsQueryAnimesRelatedAnime anime) {
    return ShikimoriAnimeModel(
      id: ShikimoriMediaMapper.parseId(anime.id),
      idMal: ShikimoriMediaMapper.parseMalId(anime.malId),
      title: TitleModel(
        romaji: anime.name,
        english: anime.english,
        nativeTitle: anime.japanese,
        userPreferred: ShikimoriMediaMapper.preferredTitle(
          name: anime.name,
          english: anime.english,
          russian: anime.russian,
        ),
        russian: anime.russian,
      ),
      averageScore: ShikimoriMediaMapper.scoreOutOfHundred(anime.score),
      bannerImage: anime.poster.mainAlt2xUrl,
      countryOfOrigin: defaultCountryOfOrigin,
      coverImage: anime.poster.originalUrl,
      description: anime.description,
      duration: anime.duration,
      endDate: ShikimoriMediaMapper.date(anime.releasedOn.day, anime.releasedOn.month, anime.releasedOn.year),
      startDate: ShikimoriMediaMapper.date(anime.airedOn.day, anime.airedOn.month, anime.airedOn.year),
      episodes: anime.episodes,
      genres: anime.genres.map((AnimeDetailsQueryAnimesRelatedAnimeGenres genre) => genre.name).toList(),
      format: ShikimoriMediaMapper.animeFormat(anime.kind),
      isAdult: anime.isCensored,
      popularity: unavailablePopularity,
      meanScore: ShikimoriMediaMapper.scoreOutOfHundred(anime.score),
      season: ShikimoriMediaMapper.season(anime.season),
      status: ShikimoriMediaMapper.animeStatus(anime.status),
      isFavourite: false,
      nextAiringEpisode: ShikimoriMediaMapper.nextAiringEpisode(
        nextEpisodeAt: anime.nextEpisodeAt,
        episodesAired: anime.episodesAired,
      ),
    );
  }
}

// External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/shikimori/anime_details_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_list_query_entity.dart';
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

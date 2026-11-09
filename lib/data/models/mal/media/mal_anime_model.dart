// External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/mal/mal_anime_node.dart';
import 'package:unyo/data/models/mal/media/mal_media_mapper.dart';
import 'package:unyo/domain/entities/media/airing_episode.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/title.dart';

part 'mal_anime_model.freezed.dart';
part 'mal_anime_model.g.dart';

/// MyAnimeList anime metadata record (WP #166).
///
/// The MAL id **is** the record id: cross-service addressing rides
/// `MediaMappingRepositoryMal` (identity lookup + AniList `idMal` pivot), so
/// `id` and `idMal` both carry `MalAnimeNode.id` (SPEC §3) — unlike Shikimori,
/// whose native ids live in their own sequence.
@freezed
abstract class MalAnimeModel with _$MalAnimeModel implements Anime {
  const MalAnimeModel._();

  factory MalAnimeModel({
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
  }) = _MalAnimeModel;

  factory MalAnimeModel.fromJson(Map<String, dynamic> json) => _$MalAnimeModelFromJson(json);

  /// MAL v2 exposes `broadcast.day_of_the_week` + `start_time` (a weekly slot),
  /// never a concrete next-episode timestamp, so there is nothing to place on
  /// the calendar's `airingAt` scale.
  static AiringEpisode get noNextAiringEpisode => AiringEpisodeModel.empty();

  /// One node of `GET /anime`, `GET /anime/ranking` or `GET /anime/{id}`.
  factory MalAnimeModel.fromNode(MalAnimeNode node) {
    return MalAnimeModel.fromParts(
      id: node.id,
      title: node.title,
      english: node.alternativeTitles.en,
      nativeTitle: node.alternativeTitles.ja,
      largePicture: node.mainPicture.large,
      mediumPicture: node.mainPicture.medium,
      description: node.synopsis,
      mean: node.mean,
      startDate: node.startDate,
      endDate: node.endDate,
      episodes: node.numEpisodes,
      genres: node.genres.map((MalAnimeNodeGenres genre) => genre.name).toList(),
      mediaType: node.mediaType,
      status: node.status,
      rating: node.rating,
      nsfw: node.nsfw,
      popularity: node.popularity,
      season: node.startSeason.season,
      duration: node.averageEpisodeDuration,
    );
  }

  /// One `related_anime` node of the details payload.
  factory MalAnimeModel.fromRelatedNode(MalAnimeNodeRelatedNode node) {
    return MalAnimeModel.fromParts(
      id: node.id,
      title: node.title,
      english: '',
      nativeTitle: '',
      largePicture: node.mainPicture.large,
      mediumPicture: node.mainPicture.medium,
      description: node.synopsis,
      mean: node.mean,
      startDate: node.startDate,
      endDate: node.endDate,
      episodes: node.numEpisodes,
      genres: node.genres.map((MalAnimeNodeGenres genre) => genre.name).toList(),
      mediaType: node.mediaType,
      status: node.status,
      rating: node.rating,
      nsfw: node.nsfw,
      popularity: node.popularity,
      season: '',
      duration: 0,
    );
  }

  /// Shared assembly for both factories (the relation node has no season /
  /// duration keys).
  factory MalAnimeModel.fromParts({
    required int id,
    required String title,
    required String english,
    required String nativeTitle,
    required String largePicture,
    required String mediumPicture,
    required String description,
    required double mean,
    required String startDate,
    required String endDate,
    required int episodes,
    required List<String> genres,
    required String mediaType,
    required String status,
    required String rating,
    required String nsfw,
    required int popularity,
    required String season,
    required int duration,
  }) {
    return MalAnimeModel(
      id: id,
      idMal: id,
      title: TitleModel(
        romaji: title,
        english: english,
        nativeTitle: nativeTitle,
        userPreferred: MalMediaMapper.preferredTitle(title: title, english: english, nativeTitle: nativeTitle),
      ),
      averageScore: MalMediaMapper.scoreOutOfHundred(mean),
      // MAL has no banner: `main_picture` is the only artwork on the node.
      bannerImage: '',
      countryOfOrigin: MalMediaMapper.countryOfOrigin,
      coverImage: MalMediaMapper.coverImage(large: largePicture, medium: mediumPicture),
      description: description,
      duration: duration,
      endDate: MalMediaMapper.date(endDate),
      startDate: MalMediaMapper.date(startDate),
      episodes: episodes,
      genres: genres,
      format: MalMediaMapper.animeFormat(mediaType),
      isAdult: MalMediaMapper.isAdult(rating: rating, nsfw: nsfw),
      popularity: popularity,
      meanScore: MalMediaMapper.scoreOutOfHundred(mean),
      season: MalMediaMapper.season(season),
      status: MalMediaMapper.animeStatus(status),
      isFavourite: false,
      nextAiringEpisode: noNextAiringEpisode,
    );
  }
}

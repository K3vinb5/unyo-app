// External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_details_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_popular_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_recently_released_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_trending_query_entity.dart';

// Internal dependencies
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

  factory ShikimoriAnimeModel.fromRelatedEntry(AnimeDetailsQueryAnimesRelatedAnime anime) {
    return ShikimoriAnimeModel(
        id: _formatId(anime.id),
        idMal: _parseMalId(anime.malId),
        title: TitleModel(
          romaji: anime.russian,
          english: anime.english,
          userPreferred: anime.english,
          nativeTitle: anime.japanese,
        ),
        averageScore: anime.score.toInt() * 10,
        bannerImage: anime.poster.mainAlt2xUrl,
        countryOfOrigin: 'JP',
        coverImage: anime.poster.originalUrl,
        description: anime.description,
        duration: anime.duration,
        endDate: "${anime.releasedOn.day}/${anime.releasedOn.month}/${anime.releasedOn.year}",
        startDate: "${anime.airedOn.day}/${anime.airedOn.month}/${anime.airedOn.year}",
        episodes: anime.episodes,
        genres: anime.genres.map((animeGenre) => animeGenre.name).toList(),
        format: _formatKind(anime.kind),
        isAdult: anime.isCensored,
        popularity: 0,
        meanScore: anime.score.toInt() * 10,
        season: _formatSeason(anime.season),
        status: _formatStatus(anime.status),
        isFavourite: false,
        nextAiringEpisode: AiringEpisodeModel.empty()
    );
  }

  factory ShikimoriAnimeModel.fromAnimesPopularQuery(AnimePopularQueryAnimes anime) {
    return ShikimoriAnimeModel(
        id: _formatId(anime.id),
        idMal: _parseMalId(anime.malId),
        title: TitleModel(
          romaji: anime.russian,
          english: anime.english,
          userPreferred: anime.english,
          nativeTitle: anime.japanese,
        ),
        averageScore: anime.score.toInt() * 10,
        bannerImage: anime.poster.mainAlt2xUrl,
        countryOfOrigin: 'JP',
        coverImage: anime.poster.originalUrl,
        description: anime.description,
        duration: anime.duration,
        endDate: "${anime.releasedOn.day}/${anime.releasedOn.month}/${anime.releasedOn.year}",
        startDate: "${anime.airedOn.day}/${anime.airedOn.month}/${anime.airedOn.year}",
        episodes: anime.episodes,
        genres: anime.genres.map((animeGenre) => animeGenre.name).toList(),
        format: _formatKind(anime.kind),
        isAdult: anime.isCensored,
        popularity: 0,
        meanScore: anime.score.toInt() * 10,
        season: _formatSeason(anime.season),
        status: _formatStatus(anime.status),
        isFavourite: false,
        nextAiringEpisode: AiringEpisodeModel.empty()
    );
  }

  factory ShikimoriAnimeModel.fromAnimesTrendingQuery(AnimeTrendingQueryAnimes anime) {
    return ShikimoriAnimeModel(
        id: _formatId(anime.id),
        idMal: _parseMalId(anime.malId),
        title: TitleModel(
          romaji: anime.russian,
          english: anime.english,
          userPreferred: anime.english,
          nativeTitle: anime.japanese,
        ),
        averageScore: anime.score.toInt() * 10,
        bannerImage: anime.poster.mainAlt2xUrl,
        countryOfOrigin: 'JP',
        coverImage: anime.poster.originalUrl,
        description: anime.description,
        duration: anime.duration,
        endDate: "${anime.releasedOn.day}/${anime.releasedOn.month}/${anime.releasedOn.year}",
        startDate: "${anime.airedOn.day}/${anime.airedOn.month}/${anime.airedOn.year}",
        episodes: anime.episodes,
        genres: anime.genres.map((animeGenre) => animeGenre.name).toList(),
        format: _formatKind(anime.kind),
        isAdult: anime.isCensored,
        popularity: 0,
        meanScore: anime.score.toInt() * 10,
        season: _formatSeason(anime.season),
        status: _formatStatus(anime.status),
        isFavourite: false,
        nextAiringEpisode: AiringEpisodeModel.empty()
    );
  }

  factory ShikimoriAnimeModel.fromAnimesRecentlyReleasedQuery(AnimeRecentlyReleasedQueryAnimes anime) {
    return ShikimoriAnimeModel(
        id: _formatId(anime.id),
        idMal: _parseMalId(anime.malId),
        title: TitleModel(
          romaji: anime.russian,
          english: anime.english,
          userPreferred: anime.english,
          nativeTitle: anime.japanese,
        ),
        averageScore: anime.score.toInt() * 10,
        bannerImage: anime.poster.mainAlt2xUrl,
        countryOfOrigin: 'JP',
        coverImage: anime.poster.originalUrl,
        description: anime.description,
        duration: anime.duration,
        endDate: "${anime.releasedOn.day}/${anime.releasedOn.month}/${anime.releasedOn.year}",
        startDate: "${anime.airedOn.day}/${anime.airedOn.month}/${anime.airedOn.year}",
        episodes: anime.episodes,
        genres: anime.genres.map((animeGenre) => animeGenre.name).toList(),
        format: _formatKind(anime.kind),
        isAdult: anime.isCensored,
        popularity: 0,
        meanScore: anime.score.toInt() * 10,
        season: _formatSeason(anime.season),
        status: _formatStatus(anime.status),
        isFavourite: false,
        nextAiringEpisode: AiringEpisodeModel.empty()
    );
  }
}

/// Whether a Shikimori `related` entry carries a real anime payload.
///
/// `related { anime { ... } }` returns `anime: null` for every non-anime
/// relation (manga, novel, …) and the DTOs eagerly default-construct their
/// children, so such an entry arrives as an [AnimeDetailsQueryAnimesRelatedAnime]
/// whose `id` is `''`. Mapping it would produce a phantom
/// `Anime(id: 0, idMal: 0, title: '')` card. `'0'` is the same kind of legacy
/// empty sentinel the `malId` parser guards against.
bool isRealRelatedAnime(AnimeDetailsQueryAnimesRelatedAnime anime) {
  final String id = anime.id.trim();
  return id.isNotEmpty && id != '0';
}

String _formatKind(String kind) {
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
      return 'MUSIC';
    case 'pv':
      return 'MUSIC';
    case 'cm':
      return 'SPECIAL';
    default:
      return kind.toUpperCase();
  }
}

String _formatStatus(String status) {
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

String _formatSeason(String season) {
  return season
      .split("-")
      .firstOrNull ?? season;
}

int _formatId(String id) {
  // r'\D' is a raw string representing the regex for non-digits
  return int.tryParse(id.replaceAll(RegExp(r'\D'), '')) ?? 0;
}

/// Maps Shikimori's GraphQL `malId` to the domain `idMal`.
///
/// Shikimori native ids and MAL ids are different sequences — unlinked
/// records sit at `1015xxxxx` while MAL-linked records carry their MAL id —
/// so a missing MAL id must stay unset (`0`, the `AnimeModel.empty()`
/// sentinel) and must never be backfilled from `anime.id`. Shikimori reports
/// a missing link as JSON `null`/absent (the DTO default `''`); `"0"` is a
/// legacy sentinel that some payloads still use.
int _parseMalId(String malId) {
  final parsed = int.tryParse(malId.trim());
  if (parsed == null || parsed <= 0) return 0;
  return parsed;
}

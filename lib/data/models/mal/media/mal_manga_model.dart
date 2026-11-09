// External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/mal/mal_manga_node.dart';
import 'package:unyo/data/models/mal/media/mal_media_mapper.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/title.dart';

part 'mal_manga_model.freezed.dart';
part 'mal_manga_model.g.dart';

/// MyAnimeList manga metadata record (WP #166). Mirror of [MalAnimeModel]:
/// the MAL id is the record id, `chapters` comes from `num_chapters` and
/// `bannerImage` stays empty (MAL exposes no banner).
@freezed
abstract class MalMangaModel with _$MalMangaModel implements Manga {
  const MalMangaModel._();

  factory MalMangaModel({
    required int id,
    required int idMal,
    @TitleConverter() required Title title,
    required int averageScore,
    required String bannerImage,
    required int chapters,
    required String countryOfOrigin,
    required String coverImage,
    required String description,
    required String endDate,
    required String startDate,
    required List<String> genres,
    required String format,
    required bool isAdult,
    required int popularity,
    required int meanScore,
    required String status,
    required bool isFavourite,
  }) = _MalMangaModel;

  factory MalMangaModel.fromJson(Map<String, dynamic> json) => _$MalMangaModelFromJson(json);

  /// One node of `GET /manga`, `GET /manga/ranking` or `GET /manga/{id}`.
  factory MalMangaModel.fromNode(MalMangaNode node) {
    return MalMangaModel.fromParts(
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
      chapters: node.numChapters,
      genres: node.genres.map((MalMangaNodeGenres genre) => genre.name).toList(),
      mediaType: node.mediaType,
      status: node.status,
      rating: node.rating,
      nsfw: node.nsfw,
      popularity: node.popularity,
    );
  }

  /// One `related_manga` node of the details payload.
  factory MalMangaModel.fromRelatedNode(MalMangaNodeRelatedNode node) {
    return MalMangaModel.fromParts(
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
      chapters: node.numChapters,
      genres: node.genres.map((MalMangaNodeGenres genre) => genre.name).toList(),
      mediaType: node.mediaType,
      status: node.status,
      rating: node.rating,
      nsfw: node.nsfw,
      popularity: node.popularity,
    );
  }

  /// Shared assembly for both factories.
  factory MalMangaModel.fromParts({
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
    required int chapters,
    required List<String> genres,
    required String mediaType,
    required String status,
    required String rating,
    required String nsfw,
    required int popularity,
  }) {
    return MalMangaModel(
      id: id,
      idMal: id,
      title: TitleModel(
        romaji: title,
        english: english,
        nativeTitle: nativeTitle,
        userPreferred: MalMediaMapper.preferredTitle(title: title, english: english, nativeTitle: nativeTitle),
      ),
      averageScore: MalMediaMapper.scoreOutOfHundred(mean),
      bannerImage: '',
      chapters: chapters,
      countryOfOrigin: MalMediaMapper.countryOfOrigin,
      coverImage: MalMediaMapper.coverImage(large: largePicture, medium: mediumPicture),
      description: description,
      endDate: MalMediaMapper.date(endDate),
      startDate: MalMediaMapper.date(startDate),
      genres: genres,
      format: MalMediaMapper.mangaFormat(mediaType),
      isAdult: MalMediaMapper.isAdult(rating: rating, nsfw: nsfw),
      popularity: popularity,
      meanScore: MalMediaMapper.scoreOutOfHundred(mean),
      status: MalMediaMapper.mangaStatus(status),
      isFavourite: false,
    );
  }
}

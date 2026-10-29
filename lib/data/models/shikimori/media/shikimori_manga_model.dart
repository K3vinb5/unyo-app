// External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/shikimori/manga_details_query_entity.dart';
import 'package:unyo/core/services/api/dto/shikimori/manga_list_query_entity.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_media_mapper.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/title.dart';

part 'shikimori_manga_model.freezed.dart';
part 'shikimori_manga_model.g.dart';

@freezed
abstract class ShikimoriMangaModel with _$ShikimoriMangaModel implements Manga {
  const ShikimoriMangaModel._();

  factory ShikimoriMangaModel({
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
  }) = _ShikimoriMangaModel;

  factory ShikimoriMangaModel.fromJson(Map<String, dynamic> json) =>
      _$ShikimoriMangaModelFromJson(json);

  /// Shikimori's `Manga` type has no popularity counter (mirror of
  /// [ShikimoriAnimeModel.unavailablePopularity], WP #64 §8).
  static const int unavailablePopularity = 0;

  /// `Manga` has no country-of-origin field in the Shikimori schema; the
  /// manga database keeps its `JP` default.
  static const String defaultCountryOfOrigin = 'JP';

  /// One carousel entry (`shikimoriMangaListQuery`).
  factory ShikimoriMangaModel.fromListEntry(MangaListQueryMangas manga) {
    return ShikimoriMangaModel(
      id: ShikimoriMediaMapper.parseId(manga.id),
      idMal: ShikimoriMediaMapper.parseMalId(manga.malId),
      title: TitleModel(
        romaji: manga.name,
        english: manga.english,
        nativeTitle: manga.japanese,
        userPreferred: ShikimoriMediaMapper.preferredTitle(
          name: manga.name,
          english: manga.english,
          russian: manga.russian,
        ),
        russian: manga.russian,
      ),
      averageScore: ShikimoriMediaMapper.scoreOutOfHundred(manga.score),
      bannerImage: manga.poster.mainAlt2xUrl,
      // The domain keeps one chapter counter; Shikimori's `volumes` has no slot
      // in it (the DTO still carries both, see the details model test).
      chapters: manga.chapters,
      countryOfOrigin: defaultCountryOfOrigin,
      coverImage: manga.poster.originalUrl,
      description: manga.description,
      endDate: ShikimoriMediaMapper.date(manga.releasedOn.day, manga.releasedOn.month, manga.releasedOn.year),
      startDate: ShikimoriMediaMapper.date(manga.airedOn.day, manga.airedOn.month, manga.airedOn.year),
      genres: manga.genres.map((MangaListQueryMangasGenres genre) => genre.name).toList(),
      format: ShikimoriMediaMapper.mangaFormat(manga.kind),
      isAdult: manga.isCensored,
      popularity: unavailablePopularity,
      meanScore: ShikimoriMediaMapper.scoreOutOfHundred(manga.score),
      status: ShikimoriMediaMapper.mangaStatus(manga.status),
      isFavourite: false,
    );
  }

  /// The addressed entry of `shikimoriMangaDetailsQuery`.
  factory ShikimoriMangaModel.fromDetailsEntry(MangaDetailsQueryMangas manga) {
    return ShikimoriMangaModel(
      id: ShikimoriMediaMapper.parseId(manga.id),
      idMal: ShikimoriMediaMapper.parseMalId(manga.malId),
      title: TitleModel(
        romaji: manga.name,
        english: manga.english,
        nativeTitle: manga.japanese,
        userPreferred: ShikimoriMediaMapper.preferredTitle(
          name: manga.name,
          english: manga.english,
          russian: manga.russian,
        ),
        russian: manga.russian,
      ),
      averageScore: ShikimoriMediaMapper.scoreOutOfHundred(manga.score),
      bannerImage: manga.poster.mainAlt2xUrl,
      chapters: manga.chapters,
      countryOfOrigin: defaultCountryOfOrigin,
      coverImage: manga.poster.originalUrl,
      description: manga.description,
      endDate: ShikimoriMediaMapper.date(manga.releasedOn.day, manga.releasedOn.month, manga.releasedOn.year),
      startDate: ShikimoriMediaMapper.date(manga.airedOn.day, manga.airedOn.month, manga.airedOn.year),
      genres: manga.genres.map((MangaDetailsQueryMangasGenres genre) => genre.name).toList(),
      format: ShikimoriMediaMapper.mangaFormat(manga.kind),
      isAdult: manga.isCensored,
      popularity: unavailablePopularity,
      meanScore: ShikimoriMediaMapper.scoreOutOfHundred(manga.score),
      status: ShikimoriMediaMapper.mangaStatus(manga.status),
      isFavourite: false,
    );
  }

  /// One `related { manga { … } }` entry of `shikimoriMangaDetailsQuery`.
  ///
  /// Callers must filter with [ShikimoriMediaMapper.isRealManga] first: an anime
  /// adaptation arrives as a default-constructed node with `id == ''` (the
  /// #78/#77 phantom-media trap, mirrored on the manga side).
  factory ShikimoriMangaModel.fromRelatedEntry(MangaDetailsQueryMangasRelatedManga manga) {
    return ShikimoriMangaModel(
      id: ShikimoriMediaMapper.parseId(manga.id),
      idMal: ShikimoriMediaMapper.parseMalId(manga.malId),
      title: TitleModel(
        romaji: manga.name,
        english: manga.english,
        nativeTitle: manga.japanese,
        userPreferred: ShikimoriMediaMapper.preferredTitle(
          name: manga.name,
          english: manga.english,
          russian: manga.russian,
        ),
        russian: manga.russian,
      ),
      averageScore: ShikimoriMediaMapper.scoreOutOfHundred(manga.score),
      bannerImage: manga.poster.mainAlt2xUrl,
      chapters: manga.chapters,
      countryOfOrigin: defaultCountryOfOrigin,
      coverImage: manga.poster.originalUrl,
      description: manga.description,
      endDate: ShikimoriMediaMapper.date(manga.releasedOn.day, manga.releasedOn.month, manga.releasedOn.year),
      startDate: ShikimoriMediaMapper.date(manga.airedOn.day, manga.airedOn.month, manga.airedOn.year),
      genres: manga.genres.map((MangaDetailsQueryMangasRelatedMangaGenres genre) => genre.name).toList(),
      format: ShikimoriMediaMapper.mangaFormat(manga.kind),
      isAdult: manga.isCensored,
      popularity: unavailablePopularity,
      meanScore: ShikimoriMediaMapper.scoreOutOfHundred(manga.score),
      status: ShikimoriMediaMapper.mangaStatus(manga.status),
      isFavourite: false,
    );
  }
}

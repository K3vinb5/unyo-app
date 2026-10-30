// External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/shikimori/manga_details_query_entity.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_manga_model.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_media_character.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_media_mapper.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/media/media_character.dart';

part 'shikimori_manga_details.freezed.dart';
part 'shikimori_manga_details.g.dart';

@freezed
abstract class ShikimoriMangaDetailsModel
    with _$ShikimoriMangaDetailsModel
    implements MangaDetails {
  const factory ShikimoriMangaDetailsModel({
    @MediaListEntryConverter() required MediaListEntry mediaListEntry,
    @MangaConverter() required List<Manga> recommendedMangas,
    @MediaCharacterConverter() required List<MediaCharacter> characters,
  }) = _ShikimoriMangaDetailsModel;

  factory ShikimoriMangaDetailsModel.empty() => ShikimoriMangaDetailsModel(
    mediaListEntry: MediaListEntryModel.empty(),
    recommendedMangas: [],
    characters: [],
  );

  factory ShikimoriMangaDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$ShikimoriMangaDetailsModelFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ShikimoriMangaDetailsModelToJson(this as _ShikimoriMangaDetailsModel);

  /// Maps `shikimoriMangaDetailsQuery`.
  ///
  /// * `related { manga { … } }` is `null` for anime adaptations, so only nodes
  ///   with a real manga payload become recommendations — never a phantom card
  ///   (the #78/#77 family, mirrored here).
  /// * without an Authorization header `userRate` is `null`, which degrades to
  ///   the "add to list" sentinel.
  factory ShikimoriMangaDetailsModel.fromMangaDetailsQuery(MangaDetailsQueryEntity mangaDetailsQuery) {
    final MangaDetailsQueryMangas mangaDetails = mangaDetailsQuery.mangas.firstOrNull ?? MangaDetailsQueryMangas();
    return ShikimoriMangaDetailsModel(
      mediaListEntry: mangaDetails.userRate.status.trim().isEmpty
          ? MediaListEntryModel.empty()
          : MediaListEntryModel.fromMangaDetailsQueryMangasUserRate(mangaDetails.userRate),
      recommendedMangas: mangaDetails.related
          .where((MangaDetailsQueryMangasRelated relatedManga) => ShikimoriMediaMapper.isRealManga(relatedManga.manga))
          .map((MangaDetailsQueryMangasRelated relatedManga) =>
              ShikimoriMangaModel.fromRelatedEntry(relatedManga.manga))
          .toList(),
      characters: mangaDetails.characterRoles
          .where((MangaDetailsQueryMangasCharacterRoles role) => ShikimoriMediaMapper.parseId(role.character.id) > 0)
          .map((MangaDetailsQueryMangasCharacterRoles role) => ShikimoriMediaCharacterModel.fromRole(
                id: role.character.id,
                name: role.character.name,
                image: role.character.poster.originalUrl,
              ))
          .toList(),
    );
  }
}

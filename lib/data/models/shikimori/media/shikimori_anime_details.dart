// External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unyo/core/services/api/dto/shikimori/anime_details_query_entity.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_media_character.dart';

// Internal dependencies
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/media/media_character.dart';

part 'shikimori_anime_details.freezed.dart';

part 'shikimori_anime_details.g.dart';

@freezed
abstract class ShikimoriAnimeDetailsModel with _$ShikimoriAnimeDetailsModel implements AnimeDetails {
  const factory ShikimoriAnimeDetailsModel({
    @MediaListEntryConverter() required MediaListEntry mediaListEntry,
    @AnimeConverter() required List<Anime> recommendedAnimes,
    @MediaCharacterConverter() required List<MediaCharacter> characters,
  }) = _ShikimoriAnimeDetailsModel;

  factory ShikimoriAnimeDetailsModel.empty() => ShikimoriAnimeDetailsModel(
    mediaListEntry: MediaListEntryModel.empty(),
    recommendedAnimes: [],
    characters: [],
  );

  factory ShikimoriAnimeDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$ShikimoriAnimeDetailsModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ShikimoriAnimeDetailsModelToJson(this as _ShikimoriAnimeDetailsModel);

  factory ShikimoriAnimeDetailsModel.fromAnimeDetailsQuery(AnimeDetailsQueryEntity animeDetailsQuery) {
    AnimeDetailsQueryAnimes animeDetails = animeDetailsQuery.animes.firstOrNull ?? AnimeDetailsQueryAnimes();
    return ShikimoriAnimeDetailsModel(
      mediaListEntry: MediaListEntryModel.fromAnimeDetailsQueryAnimesUserRate(animeDetails.userRate),
      recommendedAnimes: animeDetails.related
          .where((relatedAnime) => isRealRelatedAnime(relatedAnime.anime))
          .map((relatedAnime) => ShikimoriAnimeModel.fromRelatedEntry(relatedAnime.anime))
          .toList(),
      characters: animeDetails.characterRoles
          .map((role) => ShikimoriMediaCharacterModel.fromRolesCharacter(role.character))
          .toList(),
    );
  }
}

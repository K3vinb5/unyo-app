// External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/shikimori/anime_details_query_entity.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_media_character.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_media_mapper.dart';
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

  /// Maps `shikimoriAnimeDetailsQuery`.
  ///
  /// * `related` keeps only entries carrying a real anime payload — the API
  ///   returns `anime: null` for manga/novel relations, and mapping those would
  ///   render phantom cards (see [ShikimoriMediaMapper.isRealAnime]).
  /// * `userRate` is `null` without an Authorization header (the OAuth flow is
  ///   WP #64 subpart (c)), so an empty rate degrades to the "add to list"
  ///   sentinel instead of an entry with a blank status.
  factory ShikimoriAnimeDetailsModel.fromAnimeDetailsQuery(AnimeDetailsQueryEntity animeDetailsQuery) {
    final AnimeDetailsQueryAnimes animeDetails = animeDetailsQuery.animes.firstOrNull ?? AnimeDetailsQueryAnimes();
    return ShikimoriAnimeDetailsModel(
      mediaListEntry: animeDetails.userRate.status.trim().isEmpty
          ? MediaListEntryModel.empty()
          : MediaListEntryModel.fromAnimeDetailsQueryAnimesUserRate(animeDetails.userRate),
      recommendedAnimes: animeDetails.related
          .where((AnimeDetailsQueryAnimesRelated relatedAnime) =>
              ShikimoriMediaMapper.isRealAnime(relatedAnime.anime))
          .map((AnimeDetailsQueryAnimesRelated relatedAnime) =>
              ShikimoriAnimeModel.fromRelatedEntry(relatedAnime.anime))
          .toList(),
      characters: animeDetails.characterRoles
          .where((AnimeDetailsQueryAnimesCharacterRoles role) => ShikimoriMediaMapper.parseId(role.character.id) > 0)
          .map((AnimeDetailsQueryAnimesCharacterRoles role) => ShikimoriMediaCharacterModel.fromRole(
                id: role.character.id,
                name: role.character.name,
                image: role.character.poster.originalUrl,
              ))
          .toList(),
    );
  }
}

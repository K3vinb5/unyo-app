// External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/mal/mal_anime_node.dart';
import 'package:unyo/data/models/mal/media/mal_anime_model.dart';
import 'package:unyo/data/models/mal/media/mal_list_status_policy.dart';
import 'package:unyo/data/models/mal/media/mal_media_mapper.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/media/media_character.dart';

part 'mal_anime_details_model.freezed.dart';
part 'mal_anime_details_model.g.dart';

/// The MyAnimeList extras of one `GET /anime/{id}?fields=…` answer (WP #166).
///
/// * `mediaListEntry` comes from the node's `my_list_status`; an anonymous read
///   (or a title the user has not added) leaves the key absent and maps to the
///   empty "add to list" entry, like `MalUserRateService.getEntry`.
/// * `recommendedAnimes` are the `related_anime` nodes. MAL's `related_manga`
///   cannot be rendered as an anime card, so it is not mapped here.
/// * `characters` is always empty: **MAL v2 exposes no character data** and
///   Jikan is off-limits beyond the calendar (SPEC §4).
@freezed
abstract class MalAnimeDetailsModel with _$MalAnimeDetailsModel implements AnimeDetails {
  const MalAnimeDetailsModel._();

  const factory MalAnimeDetailsModel({
    @MediaListEntryConverter() required MediaListEntry mediaListEntry,
    @AnimeConverter() required List<Anime> recommendedAnimes,
    @MediaCharacterConverter() required List<MediaCharacter> characters,
  }) = _MalAnimeDetailsModel;

  factory MalAnimeDetailsModel.empty() => MalAnimeDetailsModel(
        mediaListEntry: MediaListEntryModel.empty(),
        recommendedAnimes: <Anime>[],
        characters: <MediaCharacter>[],
      );

  factory MalAnimeDetailsModel.fromJson(Map<String, dynamic> json) => _$MalAnimeDetailsModelFromJson(json);

  factory MalAnimeDetailsModel.fromNode(MalAnimeNode node) {
    return MalAnimeDetailsModel(
      mediaListEntry:
          MalMediaMapper.listEntry(node.myListStatus, target: MalListTarget.anime) ?? MediaListEntryModel.empty(),
      recommendedAnimes: node.relatedAnime
          .where((MalAnimeNodeRelated related) => related.node.id > 0)
          .map((MalAnimeNodeRelated related) => MalAnimeModel.fromRelatedNode(related.node))
          .toList(),
      characters: <MediaCharacter>[],
    );
  }
}

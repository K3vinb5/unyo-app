// External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/mal/mal_manga_node.dart';
import 'package:unyo/data/models/mal/media/mal_list_status_policy.dart';
import 'package:unyo/data/models/mal/media/mal_manga_model.dart';
import 'package:unyo/data/models/mal/media/mal_media_mapper.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/media/media_character.dart';

part 'mal_manga_details_model.freezed.dart';
part 'mal_manga_details_model.g.dart';

/// The MyAnimeList extras of one `GET /manga/{id}?fields=…` answer (WP #166).
/// Mirror of `MalAnimeDetailsModel`: `related_manga` feeds
/// `recommendedMangas`, `my_list_status` folds onto the shared entry, and
/// `characters` stays empty (MAL v2 has no character data; Jikan is calendar
/// only — SPEC §4).
@freezed
abstract class MalMangaDetailsModel with _$MalMangaDetailsModel implements MangaDetails {
  const MalMangaDetailsModel._();

  const factory MalMangaDetailsModel({
    @MediaListEntryConverter() required MediaListEntry mediaListEntry,
    @MangaConverter() required List<Manga> recommendedMangas,
    @MediaCharacterConverter() required List<MediaCharacter> characters,
  }) = _MalMangaDetailsModel;

  factory MalMangaDetailsModel.empty() => MalMangaDetailsModel(
        mediaListEntry: MediaListEntryModel.empty(),
        recommendedMangas: <Manga>[],
        characters: <MediaCharacter>[],
      );

  factory MalMangaDetailsModel.fromJson(Map<String, dynamic> json) => _$MalMangaDetailsModelFromJson(json);

  factory MalMangaDetailsModel.fromNode(MalMangaNode node) {
    return MalMangaDetailsModel(
      mediaListEntry:
          MalMediaMapper.listEntry(node.myListStatus, target: MalListTarget.manga) ?? MediaListEntryModel.empty(),
      recommendedMangas: node.relatedManga
          .where((MalMangaNodeRelated related) => related.node.id > 0)
          .map((MalMangaNodeRelated related) => MalMangaModel.fromRelatedNode(related.node))
          .toList(),
      characters: <MediaCharacter>[],
    );
  }
}

// Internal dependencies
import 'package:unyo/core/services/api/dto/anilist/delete_media_list_entry_entity.dart';
import 'package:unyo/core/services/api/dto/anilist/media_details_media_list_entry_entity.dart';
import 'package:unyo/core/services/api/dto/anilist/save_media_list_entry_entity.dart';
import 'package:unyo/core/services/api/graphql/graphql_response.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/graphql/queries/anilist_queries.dart' as anilist_queries;
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/repositories/repository_mixin.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/user.dart';

/// AniList's list-entry read, write and remove calls (WP #167).
///
/// The anime and manga repositories hit the exact same three operations — the
/// API addresses an entry by its *media* id for reads and saves and by its own
/// *entry* id for removal, and none of that depends on the media kind — so the
/// calls live here once instead of in two copies that could drift.
class AnilistMediaListEntryRequests with RepositoryMixin {
  final GraphQLService _graphQLService;

  const AnilistMediaListEntryRequests(this._graphQLService);

  /// The viewer's entry for [mediaId], or the empty entry when there is none.
  Future<MediaListEntry> read(int mediaId, User loggedUser, {bool ignoreCache = false}) async {
    ApiGraphQLResponse<MediaDetailsMediaListEntryEntity> mediaDetailsMediaListEntry =
        await _graphQLService.query<MediaDetailsMediaListEntryEntity>(
      query: anilist_queries.mediaListEntryQuery,
      fromJson: MediaDetailsMediaListEntryEntity.fromJson,
      variables: {"mediaId": mediaId},
      headers: _headers(loggedUser),
      ignoreCache: ignoreCache,
    );
    throwIfGraphQlError(mediaDetailsMediaListEntry);
    return MediaListEntryModel.fromMediaDetailsMediaListEntryEntity(mediaDetailsMediaListEntry.data);
  }

  /// Applies [entry] to [mediaId].
  ///
  /// An entry with no list status is a **removal**: `SaveMediaListEntry` cannot
  /// delete (its `status` is an enum, and an omitted field means "leave it
  /// alone"), so it goes through the `DeleteMediaListEntry` mutation instead —
  /// the same empty-status signal Shikimori's write path reads as
  /// `DELETE /user_rates/:id`.
  Future<MediaListEntry> write(MediaListEntry entry, int mediaId, User loggedUser) async {
    if (MediaListEntryModel.isNoStatus(entry.status)) {
      return remove(mediaId, loggedUser);
    }
    ApiGraphQLResponse<SaveMediaListEntryEntity> saveMediaListEntry = await _graphQLService
        .mutation<SaveMediaListEntryEntity>(
      query: anilist_queries.updateMediaEntryQuery,
      fromJson: SaveMediaListEntryEntity.fromJson,
      variables: {
        "mediaId": mediaId,
        "status": entry.status.toUpperCase(),
        if (entry.progress != -1) "progress": entry.progress,
        if (entry.score != -1.0) "score": entry.score,
        "startedAt": {
          "day": int.tryParse(entry.startedAt[0]),
          "month": int.tryParse(entry.startedAt[1]),
          "year": int.tryParse(entry.startedAt[2]),
        },
        "completedAt": {
          "day": int.tryParse(entry.completedAt[0]),
          "month": int.tryParse(entry.completedAt[1]),
          "year": int.tryParse(entry.completedAt[2]),
        },
      },
      headers: _headers(loggedUser),
    );
    throwIfGraphQlError(saveMediaListEntry);
    return MediaListEntryModel.fromSaveMediaListEntryEntity(saveMediaListEntry.data.saveMediaListEntry);
  }

  /// Deletes the viewer's entry for [mediaId] and reports "not on any list".
  ///
  /// Reads the entry id first (fresh — a cached "still on the list" answer would
  /// delete nothing), and treats "no entry" as an already-done removal.
  Future<MediaListEntry> remove(int mediaId, User loggedUser) async {
    final ApiGraphQLResponse<MediaDetailsMediaListEntryEntity> current =
        await _graphQLService.query<MediaDetailsMediaListEntryEntity>(
      query: anilist_queries.mediaListEntryQuery,
      fromJson: MediaDetailsMediaListEntryEntity.fromJson,
      variables: {"mediaId": mediaId},
      headers: _headers(loggedUser),
      ignoreCache: true,
    );
    throwIfGraphQlError(current);
    final int entryId = current.data.media.mediaListEntry.id;
    if (entryId <= 0) return MediaListEntryModel.empty();
    final ApiGraphQLResponse<DeleteMediaListEntryEntity> deleted =
        await _graphQLService.mutation<DeleteMediaListEntryEntity>(
      query: anilist_queries.deleteMediaListEntryQuery,
      fromJson: DeleteMediaListEntryEntity.fromJson,
      variables: {"id": entryId},
      headers: _headers(loggedUser),
    );
    throwIfGraphQlError(deleted);
    return MediaListEntryModel.empty();
  }

  /// The viewer's bearer token; a non-AniList account has no token to send.
  Map<String, String>? _headers(User loggedUser) =>
      loggedUser is AnilistUserModel ? {"Authorization": "Bearer ${(loggedUser).accessToken}"} : null;
}

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/data/models/anilist/media/anilist_anime_model.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';
import 'package:unyo/data/models/shikimori/media/shikimori_manga_model.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/services/media_id_resolver.dart';

/// Which provider produced a media record.
///
/// Details routing must key on this (the record's provenance), never on the
/// `metadataService` setting: a Shikimori-sourced record rendered while AniList
/// is configured still has a Shikimori native id, and sending it as an
/// AniList id silently fetches the wrong entry.
///
/// Same style as the existing `case AnilistUserModel` switches in the cubits —
/// the provider-specific models carry the provenance, so no domain entity
/// fields are added.
Service serviceOfAnime(Anime anime) {
  switch (anime) {
    case ShikimoriAnimeModel _:
      return Service.shikimori;
    default:
      // AnilistAnimeModel and the plain domain AnimeModel (built by the AniList
      // repositories) are both AniList-sourced.
      return Service.anilist;
  }
}

Service serviceOfManga(Manga manga) {
  switch (manga) {
    case ShikimoriMangaModel _:
      return Service.shikimori;
    default:
      return Service.anilist;
  }
}

/// AniZip lookup key for a record.
///
/// The MAL pivot is preferred whenever the record publishes one; the AniList id
/// is only ever sent for AniList-sourced records.
class AniZipLookupIds {
  final int malId;
  final int anilistId;

  const AniZipLookupIds.mal(this.malId) : anilistId = -1;

  const AniZipLookupIds.anilist(this.anilistId) : malId = -1;
}

/// Null means "nothing we can address": the caller renders the data it already
/// has instead of querying AniZip with a foreign id.
AniZipLookupIds? aniZipIdsForAnime(Anime anime) {
  if (anime.idMal != 0) return AniZipLookupIds.mal(anime.idMal);
  if (serviceOfAnime(anime) == Service.anilist) return AniZipLookupIds.anilist(anime.id);
  return null;
}

/// The same record re-addressed to another provider's native id. Only the id
/// changes: the entity type (and therefore the provenance) stays, because the
/// record is still the one the user opened.
Anime withAnimeNativeId(Anime anime, int nativeId) {
  if (anime is AnimeModel) return anime.copyWith(id: nativeId);
  if (anime is ShikimoriAnimeModel) return anime.copyWith(id: nativeId);
  if (anime is AnilistAnimeModel) return anime.copyWith(id: nativeId);
  return anime;
}

/// Year out of a provider `startDate` string (`d/m/yyyy`). Returns null when the
/// date is empty or unparseable.
int? yearOfStartDate(String startDate) {
  final List<String> parts = startDate.split("/");
  if (parts.length < 3) return null;
  return int.tryParse(parts[2]);
}

/// Title-search input for the MAL-pivot chain, built from a provider record.
MediaLinkQuery mediaLinkQueryForAnime(Anime anime, {bool isAnime = true}) {
  final String preferred = anime.title.userPreferred.isNotEmpty ? anime.title.userPreferred : anime.title.romaji;
  return MediaLinkQuery(
    title: preferred,
    alternativeTitles: <String>[
      anime.title.english,
      anime.title.romaji,
      anime.title.nativeTitle,
    ].where((title) => title.isNotEmpty).toList(),
    year: yearOfStartDate(anime.startDate),
    isAnime: isAnime,
    format: anime.format,
  );
}

// Shikimori GraphQL documents (POST https://shikimori.io/api/graphql).
//
// Constraints verified live on 2026-10-29 (evidence bundle:
// `research/unyo-64-shikimori-parity-proof/raws/api/`, WP #64):
// * **max query depth 5**, the root `query` counting as level 1 — so
//   `related { anime { poster { originalUrl } } }` is as deep as a document may
//   go, and the details documents are deliberately kept at that limit;
// * every `animes`/`mangas` filter argument is nullable: `null` (or omitting the
//   variable) means "not filtered", which is what lets ONE list document serve
//   popular / trending / upcoming / recently released / recently completed;
// * `order` is an `OrderEnum` literal (`popularity`, `updated_at_desc`, …) and
//   must be passed as a variable, never as a quoted inline string;
// * `malId` is an `ID` serialized as a JSON **string** (nullable in the schema);
// * `description`/`descriptionHtml` are Russian-only — the schema has no English
//   description field;
// * `Query.anime`, `Anime.popularity` and `Manga.publishedOn` do not exist.

/// Anime list, used by every anime carousel **and** the advanced search.
///
/// | consumer | variables |
/// | --- | --- |
/// | popular | `order: popularity` |
/// | trending | `order: popularity`, `season: <current season>` |
/// | recently released | `order: updated_at_desc`, `status: ongoing` |
/// | recently completed | `order: updated_at_desc`, `status: released` |
/// | upcoming | `order: popularity`, `status: anons` |
/// | advanced search | any of `kind`/`status`/`season`/`search`/`genre`/`studio`/ `franchise`/`score`/`duration`/`rating`/`origin`/`censored`/`order` |
///
/// Omitted nullable variables mean "do not filter". Argument types are the ones
/// the live server accepts (probed 2026-10-29,
/// `raws/api/gql-advanced-search-probes.txt`): `score` is `Int`, `duration` is
/// the `S`/`D`/`F` enum, `genre`/`studio`/`franchise` are id strings.
const String shikimoriAnimeListQuery =
    '''
query Animes(\$page: PositiveInt, \$limit: PositiveInt, \$order: OrderEnum, \$kind: AnimeKindString, \$status: AnimeStatusString, \$season: SeasonString, \$search: String, \$genre: String, \$studio: String, \$franchise: String, \$score: Int, \$duration: DurationString, \$rating: RatingString, \$origin: OriginString, \$ids: String, \$censored: Boolean) {
  animes(page: \$page, limit: \$limit, order: \$order, kind: \$kind, status: \$status, season: \$season, search: \$search, genre: \$genre, studio: \$studio, franchise: \$franchise, score: \$score, duration: \$duration, rating: \$rating, origin: \$origin, ids: \$ids, censored: \$censored) {
    id
    malId
    name
    english
    japanese
    russian
    poster {
      originalUrl
      mainAlt2xUrl
    }
    description
    duration
    airedOn {
      date
      day
      month
      year
    }
    releasedOn {
      date
      day
      month
      year
    }
    episodes
    episodesAired
    nextEpisodeAt
    genres {
      id
      name
      kind
      russian
    }
    kind
    isCensored
    score
    season
    status
  }
}
''';

/// Anime details, addressed by the native Shikimori id (`ids` is a
/// comma-separated string). Includes the viewer's own rate plus the related
/// graph and the character cast.
///
/// GraphQL note: `related { anime { … } }` is `null` for every non-anime
/// relation (manga/novel adaptations) and `userRate` is `null` without an
/// Authorization header — both are handled by the model factories.
///
/// {
///   "ids": `selectedAnime.id` as a string,
///   "page": 1,
///   "limit": 20
/// }
const String shikimoriAnimeDetailsQuery =
    '''
query Animes(\$ids: String, \$page: PositiveInt, \$limit: PositiveInt) {
  animes(ids: \$ids, page: \$page, limit: \$limit) {
    id
    malId
    name
    english
    japanese
    russian
    poster {
      originalUrl
      mainAlt2xUrl
    }
    description
    duration
    airedOn {
      date
      day
      month
      year
    }
    releasedOn {
      date
      day
      month
      year
    }
    episodes
    episodesAired
    nextEpisodeAt
    genres {
      id
      name
      kind
      russian
    }
    kind
    isCensored
    score
    season
    status
    userRate {
      id
      episodes
      score
      rewatches
      status
      createdAt
      updatedAt
    }
    characterRoles {
      id
      rolesEn
      rolesRu
      character {
        id
        name
        poster {
          originalUrl
        }
      }
    }
    related {
      relationKind
      relationText
      anime {
        id
        malId
        name
        english
        japanese
        russian
        poster {
          originalUrl
          mainAlt2xUrl
        }
        description
        duration
        airedOn {
          date
          day
          month
          year
        }
        releasedOn {
          date
          day
          month
          year
        }
        episodes
        episodesAired
        nextEpisodeAt
        genres {
          id
          name
          kind
          russian
        }
        kind
        isCensored
        score
        season
        status
      }
    }
  }
}
''';

/// Manga list, used by every manga carousel **and** the advanced search.
///
/// | consumer | variables |
/// | --- | --- |
/// | popular | `order: popularity` |
/// | trending | `order: popularity`, `season: <current season>` |
/// | recently completed | `order: updated_at_desc`, `status: released` |
/// | upcoming | `order: popularity`, `status: anons` |
/// | advanced search | any of `kind`/`status`/`season`/`search`/`genre`/ `publisher`/`franchise`/`score`/`censored`/`order` |
///
/// `Manga` has no `season`/`duration` precision of its own and no
/// `publishedOn` field at all — `airedOn`/`releasedOn` carry the run dates.
/// There is no country-of-origin field either, so the manga filter dictionary
/// has no country option (`publisher` is a publisher id, not a country).
const String shikimoriMangaListQuery =
    '''
query Mangas(\$page: PositiveInt, \$limit: PositiveInt, \$order: OrderEnum, \$kind: MangaKindString, \$status: MangaStatusString, \$season: SeasonString, \$search: String, \$genre: String, \$publisher: String, \$franchise: String, \$score: Int, \$ids: String, \$censored: Boolean) {
  mangas(page: \$page, limit: \$limit, order: \$order, kind: \$kind, status: \$status, season: \$season, search: \$search, genre: \$genre, publisher: \$publisher, franchise: \$franchise, score: \$score, ids: \$ids, censored: \$censored) {
    id
    malId
    name
    english
    japanese
    russian
    poster {
      originalUrl
      mainAlt2xUrl
    }
    description
    airedOn {
      date
      day
      month
      year
    }
    releasedOn {
      date
      day
      month
      year
    }
    volumes
    chapters
    genres {
      id
      name
      kind
      russian
    }
    kind
    isCensored
    score
    status
    publishers {
      id
      name
    }
  }
}
''';

/// Manga details, addressed by the native Shikimori id (`ids` string).
///
/// GraphQL note: `related { manga { … } }` is `null` for anime adaptations
/// (the mirror image of the anime side), so the mapper must never turn such a
/// relation into a phantom manga card.
///
/// {
///   "ids": `selectedManga.id` as a string,
///   "page": 1,
///   "limit": 20
/// }
const String shikimoriMangaDetailsQuery =
    '''
query Mangas(\$ids: String, \$page: PositiveInt, \$limit: PositiveInt) {
  mangas(ids: \$ids, page: \$page, limit: \$limit) {
    id
    malId
    name
    english
    japanese
    russian
    poster {
      originalUrl
      mainAlt2xUrl
    }
    description
    airedOn {
      date
      day
      month
      year
    }
    releasedOn {
      date
      day
      month
      year
    }
    volumes
    chapters
    genres {
      id
      name
      kind
      russian
    }
    kind
    isCensored
    score
    status
    publishers {
      id
      name
    }
    userRate {
      id
      episodes
      score
      rewatches
      status
      createdAt
      updatedAt
    }
    characterRoles {
      id
      rolesEn
      rolesRu
      character {
        id
        name
        poster {
          originalUrl
        }
      }
    }
    related {
      relationKind
      relationText
      manga {
        id
        malId
        name
        english
        japanese
        russian
        poster {
          originalUrl
          mainAlt2xUrl
        }
        description
        airedOn {
          date
          day
          month
          year
        }
        releasedOn {
          date
          day
          month
          year
        }
        volumes
        chapters
        genres {
          id
          name
          kind
          russian
        }
        kind
        isCensored
        score
        status
      }
    }
  }
}
''';

// Used to translate a record between providers: by native id (the `ids` probe
// verifies the returned `malId`) or by title (`search`, a heuristic that the
// user has to confirm).
// {
//   "ids": "65261" or undefined,
//   "search": "Kusuriya no Hitorigoto" or undefined,
//   "limit": 5,
// }
const String animeMappingQuery =
    '''
query Animes(\$ids: String, \$search: String, \$limit: PositiveInt) {
  animes(ids: \$ids, search: \$search, limit: \$limit) {
    id
    malId
    name
    russian
    english
    kind
    airedOn {
      year
    }
  }
}
''';

/// Genre dictionary. `GenreEntryTypeEnum` values are PascalCase (`Anime`,
/// `Manga`) — lowercase and SCREAMING_CASE are both rejected by the server.
///
/// {
///   "entryType": "Anime" | "Manga"
/// }
const String shikimoriGenresListQuery =
    r'''
  query GenresList($entryType: GenreEntryTypeEnum!) {
    genres(entryType: $entryType) {
      id
      name
      russian
      kind
    }
  }
''';

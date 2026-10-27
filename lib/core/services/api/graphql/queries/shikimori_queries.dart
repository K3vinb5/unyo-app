//sort and type are important
// {
//   "page": 1,
//   "limit": 50,
//   "order": "aired_on" or "popularity",
// }
const animeUpcomingOrPopularQuery =
'''
query Animes(\$page: PositiveInt, \$limit: PositiveInt, \$order: OrderEnum) {
  animes(page: \$page, limit: \$limit, order: \$order) {
    malId
    id
    english
    name
    russian
    japanese
    poster {
      originalUrl
      mainAlt2xUrl
    } 
    description
    duration
    airedOn {
      day
      month
      year
    }
    releasedOn {
      day
      month
      year
    }
    episodes
    nextEpisodeAt
    genres {
      kind
      name
    }
    kind
    isCensored
    score
    season
    status
  }
}
''';
// {
//   "page": 1,
//   "limit": 50,
//   "season": "sprint_2026"
//   "order": "popularity",
// }
const animeTrendingQuery =
'''
query Animes(\$page: PositiveInt, \$limit: PositiveInt, \$order: OrderEnum, \$season: SeasonString) {
  animes(page: \$page, limit: \$limit, order: \$order, season: \$season) {
    malId
    id
    english
    name
    russian
    japanese
    poster {
      originalUrl
      mainAlt2xUrl
    } 
    description
    duration
    airedOn {
      day
      month
      year
    }
    releasedOn {
      day
      month
      year
    }
    episodes
    nextEpisodeAt
    genres {
      kind
      name
    }
    kind
    isCensored
    score
    season
    status
  }
}
''';
// {
//   "page": 1,
//   "limit": 50,
//   "season": "sprint_2026"
//   "order": "updated_at" or "popularity",
//   "status": "ongoing" or "released"
// }
const animeRecentlyReleasedOrRecentlyCompletedQuery =
'''
query Animes(\$page: PositiveInt, \$limit: PositiveInt, \$order: OrderEnum, \$season: SeasonString, \$status: AnimeStatusString) {
  animes(page: \$page, limit: \$limit, order: \$order, season: \$season, status: \$status) {
    malId
    id
    english
    name
    russian
    japanese
    poster {
      originalUrl
      mainAlt2xUrl
    } 
    description
    duration
    airedOn {
      day
      month
      year
    }
    releasedOn {
      day
      month
      year
    }
    episodes
    nextEpisodeAt
    genres {
      kind
      name
    }
    kind
    isCensored
    score
    season
    status
  }
}
''';
// {
// "ids": selectedAnime.id,
// "page" : 1,
// "limit": 20,
// }
const String shikimoriAnimeDetailsQuery = '''
 query Animes(\$ids: String, \$page: PositiveInt, \$limit: PositiveInt) {
  animes(ids: \$ids, page: \$page, limit: \$limit) {
    userRate {
      episodes
      score
      rewatches
      status
      createdAt
      updatedAt
    }
    characterRoles {
      character {
        id
        poster {
          originalUrl
        }
        name
      }
    }
    related {
      relationKind
      anime {
        malId
        id
        english
        name
        russian
        japanese
        poster {
          originalUrl
          mainAlt2xUrl
        }
        description
        duration
        airedOn {
          day
          month
          year
        }
        releasedOn {
          day
          month
          year
        }
        episodes
        nextEpisodeAt
        genres {
          kind
          name
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
// {
//   "page": 1,
//   "limit": 50,
//   "order": "aired_on" or "popularity",
// }
const mangaUpcomingOrPopularQuery =
'''
query Mangas(\$page: PositiveInt, \$limit: PositiveInt, \$order: OrderEnum) {
  mangas(page: \$page, limit: \$limit, order: \$order) {
    malId
    id
    english
    name
    russian
    japanese
    poster {
      originalUrl
      mainAlt2xUrl
    } 
    description
    airedOn {
      day
      month
      year
    }
    releasedOn {
      day
      month
      year
    }
    chapters
    genres {
      kind
      name
    }
    kind
    isCensored
    score
    status
  }
}
''';
// {
//   "page": 1,
//   "limit": 50,
//   "season": "sprint_2026"
//   "order": "popularity",
// }
const mangaTrendingQuery =
'''
query Mangas(\$page: PositiveInt, \$limit: PositiveInt, \$order: OrderEnum, \$season: SeasonString) {
  mangas(page: \$page, limit: \$limit, order: \$order, season: \$season) {
    malId
    id
    english
    name
    russian
    japanese
    poster {
      originalUrl
      mainAlt2xUrl
    } 
    description
    airedOn {
      day
      month
      year
    }
    releasedOn {
      day
      month
      year
    }
    chapters
    genres {
      kind
      name
    }
    kind
    isCensored
    score
    status
  }
}
''';
// {
//   "page": 1,
//   "limit": 50,
//   "season": "sprint_2026"
//   "order": "updated_at" or "popularity",
//   "status": "ongoing" or "released"
// }
const mangaRecentlyReleasedOrRecentlyCompletedQuery =
'''
query Mangas(\$page: PositiveInt, \$limit: PositiveInt, \$order: OrderEnum, \$season: SeasonString, \$status: MangaStatusString) {
  mangas(page: \$page, limit: \$limit, order: \$order, season: \$season, status: \$status) {
    malId
    id
    english
    name
    russian
    japanese
    poster {
      originalUrl
      mainAlt2xUrl
    } 
    description
    airedOn {
      day
      month
      year
    }
    releasedOn {
      day
      month
      year
    }
    chapters
    genres {
      kind
      name
    }
    kind
    isCensored
    score
    status
  }
}
''';
// {
// "ids": selectedManga.id,
// "page" : 1,
// "limit": 20,
// }
const String shikimoriMangaDetailsQuery =
'''
 query Mangas(\$ids: String, \$page: PositiveInt, \$limit: PositiveInt) {
  mangas(ids: \$ids, page: \$page, limit: \$limit) {
    userRate {
      episodes
      score
      rewatches
      status
      createdAt
      updatedAt
    }
    characterRoles {
      character {
        id
        poster {
          originalUrl
        }
        name
      }
    }
    related {
      relationKind
      manga {
        malId
        id
        english
        name
        russian
        japanese
        poster {
          originalUrl
          mainAlt2xUrl
        }
        description
        airedOn {
          day
          month
          year
        }
        releasedOn {
          day
          month
          year
        }
        chapters
        genres {
          kind
          name
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
// Genres list query
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

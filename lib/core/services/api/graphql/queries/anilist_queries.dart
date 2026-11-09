// { }
const viewerQuery =
'''
query Viewer {
  Viewer {
    id
    bannerImage
    avatar {
      medium
    }
    mediaListOptions {
      animeList {
        customLists
      }
      mangaList {
        customLists
      }
      scoreFormat
    }
    name
  }
}
''';
// {
//   "username" : userName,
//   "userId": 0,
//   "type" : "ANIME" or "MANGA"
// }
const mediaListCollectionQuery =
'''
query MediaListCollection(\$userName: String, \$userId: Int, \$type: MediaType) {
  MediaListCollection(userName: \$userName, userId: \$userId, type: \$type) {
    lists {
      entries {
        media {
          id
          idMal
          title {
            english
            native
            romaji
            userPreferred
          }
          averageScore
          bannerImage
          chapters
          countryOfOrigin
          coverImage {
            large
          }
          description
          duration
          endDate {
            day
            month
            year
          }
          startDate {
            day
            month
            year
          }
          episodes
          genres
          format
          isAdult
          popularity
          meanScore
          season
          isFavourite
          nextAiringEpisode {
            episode
            airingAt
          }
          status
        }
      }
      name
      isCustomList
    }
    hasNextChunk
  }
}
''';

// Media Specific

// {
//   "sort": "TIME_DESC",
//   "page": 1,
//   "perPage": 50,
// }
const animeRecentlyReleasedQuery = '''
query Page(\$sort: [AiringSort], \$page: Int, \$perPage: Int, \$notYetAired: Boolean) {
  Page(page: \$page, perPage: \$perPage) {
    airingSchedules(sort: \$sort, notYetAired: \$notYetAired) {
      media {
        nextAiringEpisode {
          episode
          airingAt
        }
        status
        isFavourite
        season
        id
        idMal
        isAdult
        meanScore
        popularity
        genres
        format
        episodes
        endDate {
          day
          month
          year
        }
        startDate {
          day
          month
          year
        }
        duration
        description
        coverImage {
          large
        }
        countryOfOrigin
        chapters
        bannerImage
        averageScore
        title {
          english
          native
          romaji
          userPreferred
        }
      }
    }
  }
}
''';
//sort and type are important
// {
//   "page": 1,
//   "perPage": 50,
//   "sort": "POPULARITY_DESC" or "TRENDING_DESC",
//   "type": "ANIME" or "MANGA"
// }
const mediaTrendingOrPopularQuery =
'''
query Page(\$page: Int, \$perPage: Int, \$sort: [MediaSort], \$type: MediaType) {
  Page(page: \$page, perPage: \$perPage) {
    media(sort: \$sort, type: \$type) {
      nextAiringEpisode {
          episode
          airingAt
        }
        status
        isFavourite
        season
        id
        idMal
        isAdult
        meanScore
        popularity
        genres
        format
        episodes
        endDate {
          day
          month
          year
        }
        startDate {
          day
          month
          year
        }
        duration
        description
        coverImage {
          large
        }
        countryOfOrigin
        chapters
        bannerImage
        averageScore
        title {
          english
          native
          romaji
          userPreferred
        }
    }
  }
}
''';
// {
// "page" : 1,
// "perPage" : 50,
// "sort": "TRENDING_DESC",
// "type": "ANIME",
// "endDateGreater": 20250612,
// "endDateLesser": 20250712
// }
const mediaRecentlyCompletedQuery =
'''
query Page(\$page: Int, \$perPage: Int, \$sort: [MediaSort], \$type: MediaType, \$endDateGreater: FuzzyDateInt, \$endDateLesser: FuzzyDateInt) {
  Page(page: \$page, perPage: \$perPage) {
    media(sort: \$sort, type: \$type, endDate_greater: \$endDateGreater, endDate_lesser: \$endDateLesser) {
      nextAiringEpisode {
          episode
          airingAt
        }
        status
        isFavourite
        season
        id
        idMal
        isAdult
        meanScore
        popularity
        genres
        format
        episodes
        endDate {
          day
          month
          year
        }
        startDate {
          day
          month
          year
        }
        duration
        description
        coverImage {
          large
        }
        countryOfOrigin
        chapters
        bannerImage
        averageScore
        title {
          english
          native
          romaji
          userPreferred
        }
    }
  }
}
''';
// {
//   "page" : 1,
//   "perPage" : 50,
//   "type": "ANIME" or "MANGA",
//   "sort": "POPULARITY_DESC" or "TRENDING_DESC",
//   "startDateGreater": 20250724
// }
const mediaUpcomingQuery =
'''
query Page(\$page: Int, \$perPage: Int, \$sort: [MediaSort], \$type: MediaType, \$startDateGreater: FuzzyDateInt) {
  Page(page: \$page, perPage: \$perPage) {
    media(sort: \$sort, type: \$type, startDate_greater: \$startDateGreater) {
      nextAiringEpisode {
          episode
          airingAt
        }
        status
        isFavourite
        season
        id
        idMal
        isAdult
        meanScore
        popularity
        genres
        format
        episodes
        endDate {
          day
          month
          year
        }
        startDate {
          day
          month
          year
        }
        duration
        description
        coverImage {
          large
        }
        countryOfOrigin
        chapters
        bannerImage
        averageScore
        title {
          english
          native
          romaji
          userPreferred
        }
    }
  }
}
''';
// {
//   "sort": "TIME_DESC",
//   "page": 1,
//   "perPage": 50,
//   "airingAtGreater": 1700000000, milliseconds since epoch
//   "airingAtLesser": 1800000000, milliseconds since epoch
// }
const calendarQuery =
'''
query Page(\$sort: [AiringSort], \$page: Int, \$perPage: Int, \$airingAtGreater: Int, \$airingAtLesser: Int) {
  Page(page: \$page, perPage: \$perPage) {
    airingSchedules(sort: \$sort, airingAt_greater: \$airingAtGreater, airingAt_lesser: \$airingAtLesser) {
      media {
        nextAiringEpisode {
          episode
          airingAt
        }
        status
        isFavourite
        season
        id
        idMal
        isAdult
        meanScore
        popularity
        genres
        format
        episodes
        endDate {
          day
          month
          year
        }
        startDate {
          day
          month
          year
        }
        duration
        description
        coverImage {
          large
        }
        countryOfOrigin
        chapters
        bannerImage
        averageScore
        title {
          english
          native
          romaji
          userPreferred
        }
      }
    }
  }
}
''';
// {
// "type": "ANIME",
// "mediaId": selectedAnime.id,
// "page" : 1,
// "perPage": 20,
// }
const mediaDetailsQuery =
'''
query Page(\$type: MediaType, \$mediaId: Int, \$page: Int, \$perPage: Int) {
  Media(id: \$mediaId, type: \$type) {
    id
    title {
      english
      romaji
      native
      userPreferred
    }
    recommendations(page: \$page, perPage: \$perPage) {
      nodes {
        mediaRecommendation {
          id
          idMal
          startDate {
            day
            month
            year
          }
          endDate {
            day
            month
            year
          }
          season
          status
          isFavourite
          isAdult
          episodes
          title {
            english
            native
            romaji
            userPreferred
          }
          bannerImage
          coverImage {
            large
          }
          averageScore
          duration
          format
          genres
          description
          meanScore
          nextAiringEpisode {
            episode
            airingAt
          }
        }
      }
    }
    characters {
      nodes {
        id
        image {
          large
        }
        name {
          userPreferred
        }
        gender
        description
        dateOfBirth {
          day
          month
          year
        }
        age
      }
    }
    mediaListEntry {
      progress
      score
      repeat
      status
      startedAt {
        day
        month
        year
      }
      completedAt {
        day
        month
        year
      }
      customLists(asArray: true)
      progressVolumes
    }
  }
}
''';
// {
//  "mediaId": selectedAnime.id
// }
const mediaListEntryQuery =
'''
query Page(\$mediaId: Int) {
  Media(id: \$mediaId) {
    mediaListEntry {
      id
      progress
      score
      repeat
      status
      startedAt {
        day
        month
        year
      }
      completedAt {
        day
        month
        year
      }
      customLists(asArray: true)
      progressVolumes
    }
  }
}
''';
/// Removes the viewer's list entry (WP #167).
///
/// `SaveMediaListEntry` cannot delete: its `status` is an enum, and omitting a
/// field means "leave it alone", so a removal is this separate mutation. It is
/// addressed by the *list entry* id — the one [mediaListEntryQuery] now selects.
const deleteMediaListEntryQuery =
'''
mutation DeleteMediaListEntry(\$id: Int) {
  DeleteMediaListEntry(id: \$id) {
    deleted
  }
}
''';

// {
//   "page": 1,
//   "perPage": 5,
//   "type": "ANIME",
//   "format": "TV",
//   "status": "FINISHED",
//   "genres": ["Action", "Fantasy"],
//   "sort": "POPULARITY_DESC"
// }
const mediaAdvancedSearchQuery =
'''
query (
  \$page: Int, \$perPage: Int, \$type: MediaType, \$season: MediaSeason, \$seasonYear: Int, \$format: MediaFormat, \$status: MediaStatus, \$genres: [String], \$sort: [MediaSort], \$search: String, \$countryOfOrigin: CountryCode
) {
  Page(page: \$page, perPage: \$perPage) {
    media(
      type: \$type, season: \$season, seasonYear: \$seasonYear, format: \$format, status: \$status, genre_in: \$genres, sort: \$sort, search: \$search, countryOfOrigin: \$countryOfOrigin
    ) {
          id
          idMal
          title {
            english
            native
            romaji
            userPreferred
          }
          averageScore
          bannerImage
          chapters
          countryOfOrigin
          coverImage {
            large
          }
          description
          duration
          endDate {
            day
            month
            year
          }
          startDate {
            day
            month
            year
          }
          episodes
          genres
          format
          isAdult
          popularity
          meanScore
          season
          isFavourite
          nextAiringEpisode {
            episode
            airingAt
          }
          status
    }
  }
}
''';
// {
//   "mediaId": selectedAnime.id,
//   "progress": 10,
//   "progressVolumes": 0,
//   "repeat": 0,
//   "score": 8.5,
//   "startedAt": {"day": 1, "month": 1, "year": 2023},
//   "completedAt": {"day": 1, "month": 2, "year": 2023},
//   "status": "COMPLETED"
// }
const updateMediaEntryQuery =
'''
mutation SaveMediaListEntry(\$mediaId: Int, \$progress: Int, \$progressVolumes: Int, \$repeat: Int, \$score: Float, \$startedAt: FuzzyDateInput, \$completedAt: FuzzyDateInput, \$status: MediaListStatus) {
  SaveMediaListEntry(mediaId: \$mediaId, progress: \$progress, progressVolumes: \$progressVolumes, repeat: \$repeat, score: \$score, startedAt: \$startedAt, completedAt: \$completedAt, status: \$status) {
    progress
    repeat
    score
    status
    startedAt {
      day
      month
      year
    }
    completedAt {
      day
      year
    }
    progressVolumes
  }
}
''';
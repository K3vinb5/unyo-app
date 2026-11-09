// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/mal/mal_anime_node.dart';
import 'package:unyo/core/services/api/dto/mal/mal_manga_node.dart';
import 'package:unyo/core/services/api/dto/mal/mal_my_list_status_entity.dart';
import 'package:unyo/data/models/mal/media/mal_anime_details_model.dart';
import 'package:unyo/data/models/mal/media/mal_anime_model.dart';
import 'package:unyo/data/models/mal/media/mal_manga_details_model.dart';
import 'package:unyo/data/models/mal/media/mal_manga_model.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';

/// Field mapping of the MAL metadata models (WP #166, SPEC §3): mean 0–10 →
/// 0–100, MAL dates → the `day/month/year` sentinel shape, MAL status/format
/// enums → the AniList vocabulary the domain entities carry.
void main() {
  MalAnimeNode animeNode({
    String title = 'Kusuriya no Hitorigoto',
    String english = '',
    String nativeTitle = '薬屋のひとりごと',
    double mean = 8.54,
    String startDate = '2023-10-22',
    String endDate = '',
    String mediaType = 'tv',
    String status = 'currently_airing',
    String rating = 'pg_13',
    String nsfw = 'white',
    int numEpisodes = 24,
    int popularity = 143,
  }) {
    return MalAnimeNode()
      ..id = 58514
      ..title = title
      ..mean = mean
      ..startDate = startDate
      ..endDate = endDate
      ..mediaType = mediaType
      ..status = status
      ..rating = rating
      ..nsfw = nsfw
      ..numEpisodes = numEpisodes
      ..popularity = popularity
      ..synopsis = 'Synopsis'
      ..averageEpisodeDuration = 1380
      ..startSeason = (MalAnimeNodeStartSeason()
        ..year = 2023
        ..season = 'fall')
      ..alternativeTitles = (MalAnimeNodeAlternativeTitles()
        ..en = english
        ..ja = nativeTitle)
      ..mainPicture = (MalAnimeNodeMainPicture()
        ..medium = 'https://cdn/medium.jpg'
        ..large = '')
      ..genres = <MalAnimeNodeGenres>[(MalAnimeNodeGenres()
        ..id = 8
        ..name = 'Drama')];
  }

  group('MalAnimeModel', () {
    test('maps a list node onto the Anime entity', () {
      final MalAnimeModel model = MalAnimeModel.fromNode(animeNode());

      expect(model.id, 58514);
      expect(model.idMal, 58514, reason: 'MAL native id is both the record id and idMal');
      expect(model.meanScore, 85);
      expect(model.averageScore, 85);
      expect(model.startDate, '22/10/2023');
      expect(model.endDate, '0/0/0');
      expect(model.status, 'RELEASING');
      expect(model.format, 'TV');
      expect(model.episodes, 24);
      expect(model.duration, 1380);
      expect(model.season, 'FALL');
      expect(model.genres, <String>['Drama']);
      expect(model.coverImage, 'https://cdn/medium.jpg', reason: 'large wins, medium is the fallback');
      expect(model.title.romaji, 'Kusuriya no Hitorigoto');
      expect(model.title.english, '');
      expect(model.title.nativeTitle, '薬屋のひとりごと');
      expect(model.title.userPreferred, 'Kusuriya no Hitorigoto');
      expect(model.isAdult, isFalse);
      expect(model.isFavourite, isFalse);
      expect(model.nextAiringEpisode.airingAt, '');
    });

    test('partial dates keep the 0 sentinel for the components MAL omits', () {
      expect(MalAnimeModel.fromNode(animeNode(startDate: '2023-10')).startDate, '0/10/2023');
      expect(MalAnimeModel.fromNode(animeNode(startDate: '2023')).startDate, '0/0/2023');
    });

    test('marks adult titles from rating and nsfw', () {
      expect(MalAnimeModel.fromNode(animeNode(rating: 'rx')).isAdult, isTrue);
      expect(MalAnimeModel.fromNode(animeNode(rating: 'r+')).isAdult, isTrue);
      expect(MalAnimeModel.fromNode(animeNode(nsfw: 'black')).isAdult, isTrue);
      expect(MalAnimeModel.fromNode(animeNode(rating: 'r')).isAdult, isFalse);
    });

    test('falls back to the English title when the canonical one is empty', () {
      final MalAnimeModel model = MalAnimeModel.fromNode(animeNode(title: '', english: 'Apothecary Diaries'));
      expect(model.title.userPreferred, 'Apothecary Diaries');
    });
  });

  group('MalMangaModel', () {
    test('maps a manga node, including chapters and the manga status vocabulary', () {
      final MalMangaNode node = MalMangaNode()
        ..id = 2
        ..title = 'Berserk'
        ..mean = 9.46
        ..startDate = '1989-08-25'
        ..mediaType = 'manga'
        ..status = 'currently_publishing'
        ..rating = 'r'
        ..nsfw = 'white'
        ..numChapters = 380
        ..popularity = 3
        ..mainPicture = (MalMangaNodeMainPicture()
          ..large = 'https://cdn/large.jpg'
          ..medium = 'https://cdn/medium.jpg');

      final MalMangaModel model = MalMangaModel.fromNode(node);

      expect(model.id, 2);
      expect(model.idMal, 2);
      expect(model.meanScore, 95);
      expect(model.chapters, 380);
      expect(model.format, 'MANGA');
      expect(model.status, 'RELEASING');
      expect(model.startDate, '25/8/1989');
      expect(model.coverImage, 'https://cdn/large.jpg');
      expect(model.isAdult, isFalse);
    });
  });

  group('MalAnimeDetailsModel', () {
    test('maps my_list_status and related nodes, and never invents characters', () {
      final MalAnimeNode node = animeNode()
        ..myListStatus = (MalMyListStatusEntity()
          ..status = 'watching'
          ..score = 8
          ..numEpisodesWatched = 7
          ..numTimesRewatched = 1)
        ..relatedAnime = <MalAnimeNodeRelated>[
          MalAnimeNodeRelated()
            ..relationType = 'sequel'
            ..node = (MalAnimeNodeRelatedNode()
              ..id = 60000
              ..title = 'Sequel'
              ..mainPicture = (MalAnimeNodeRelatedNodeMainPicture()..medium = 'https://cdn/sequel.jpg')),
          // id 0 is not a real node (defensive: MAL repeats the key with nulls)
          MalAnimeNodeRelated(),
        ];

      final MalAnimeDetailsModel details = MalAnimeDetailsModel.fromNode(node);

      expect(details.mediaListEntry.status, 'CURRENT');
      expect(details.mediaListEntry.score, 8.0);
      expect(details.mediaListEntry.progress, 7);
      expect(details.mediaListEntry.repeat, 1);
      expect(details.recommendedAnimes.single.id, 60000);
      expect(details.recommendedAnimes.single.title.romaji, 'Sequel');
      expect(details.characters, isEmpty);
    });

    test('an absent my_list_status degrades to the empty entry', () {
      final MalAnimeDetailsModel details = MalAnimeDetailsModel.fromNode(animeNode());
      expect(details.mediaListEntry, MediaListEntryModel.empty());
    });
  });

  group('MalMangaDetailsModel', () {
    test('maps related_manga and the manga list status', () {
      final MalMangaNode node = MalMangaNode()
        ..id = 2
        ..title = 'Berserk'
        ..myListStatus = (MalMyListStatusEntity()
          ..status = 'reading'
          ..score = 10
          ..numChaptersRead = 12
          ..numVolumesRead = 2)
        ..relatedManga = <MalMangaNodeRelated>[
          MalMangaNodeRelated()
            ..node = (MalMangaNodeRelatedNode()
              ..id = 3
              ..title = 'Side story'),
        ];

      final MalMangaDetailsModel details = MalMangaDetailsModel.fromNode(node);

      expect(details.mediaListEntry.status, 'CURRENT');
      expect(details.mediaListEntry.progress, 12);
      expect(details.mediaListEntry.progressVolumes, 2);
      expect(details.recommendedMangas.single.id, 3);
      expect(details.characters, isEmpty);
    });
  });
}

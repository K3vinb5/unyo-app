// External dependencies
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/api/dto/shikimori/manga_details_query_entity.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/repositories/manga_repository_shikimori.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

import 'support/fake_graphql_http_service.dart';

/// Repository-level tests for [MangaRepositoryShikimori], same setup as
/// `anime_repository_shikimori_test.dart`: captured payloads are fed through
/// the real DTO/mapper chain at the HTTP boundary.
void main() {
  late FakeGraphQlHttpService http;

  Map<String, dynamic> fixture(String name) {
    return jsonDecode(File('test/data/fixtures/shikimori/$name').readAsStringSync()) as Map<String, dynamic>;
  }

  User loggedUser({bool enableNsfwContent = false}) {
    return AnilistUserModel(
      id: '1',
      name: 'test',
      settings: SettingsModel.empty().copyWith(
        metadataService: Service.shikimori,
        enableNsfwContent: enableNsfwContent,
      ),
      avatarImage: '',
      bannerImage: '',
      accessCode: '',
      accessToken: '',
      refreshToken: '',
    );
  }

  MangaRepositoryShikimori repositoryWith(
    Map<String, dynamic> payload, {
    Map<String, Map<String, dynamic>> payloadsByQueryMarker = const <String, Map<String, dynamic>>{},
  }) {
    sl.reset();
    sl.registerSingleton<Logger>(Logger(filter: ProductionFilter()));
    http = FakeGraphQlHttpService(payload, payloadsByQueryMarker: payloadsByQueryMarker);
    sl.registerSingleton<HttpService>(http);
    sl.registerLazySingleton<GraphQLService>(
      () => GraphQLService(
        httpService: sl<HttpService>(),
        endpoint: config.shikimoriGraphQLEndpoint,
      ),
      instanceName: config.shikimoriGraphQlService,
    );
    return MangaRepositoryShikimori();
  }

  Map<String, dynamic> lastVariables() => http.lastBody!['variables'] as Map<String, dynamic>;

  group('MangaRepositoryShikimori browse lists', () {
    test('popular maps volumes/chapters/genres from the mangas document', () async {
      final MangaRepositoryShikimori repository = repositoryWith(fixture('mangas_popular.json'));

      final (bool ok, List<Manga> mangas) = await repository.getPopularMangas(1, loggedUser());

      expect(ok, isTrue);
      expect(mangas, hasLength(2));
      expect(lastVariables()['order'], 'popularity');
      expect(lastVariables()['limit'], MangaRepositoryShikimori.pageSize);
      expect(http.lastBody!['query'], contains('mangas('));

      final Manga berserk = mangas.firstWhere((Manga manga) => manga.id == 2);
      expect(berserk.idMal, 2);
      expect(berserk.title.romaji, 'Berserk');
      expect(berserk.status, 'RELEASING');
      expect(berserk.format, 'MANGA');
      expect(berserk.genres, contains('Seinen'));
      expect(berserk.chapters, 0, reason: 'the ongoing Berserk reports 0 chapters');
    });

    test('chapters are mapped for a completed series', () async {
      final MangaRepositoryShikimori repository = repositoryWith(fixture('mangas_popular.json'));

      final (bool ok, List<Manga> mangas) = await repository.getPopularMangas(1, loggedUser());

      final Manga chainsawMan = mangas.firstWhere((Manga manga) => manga.id == 116778);
      expect(ok, isTrue);
      expect(chainsawMan.chapters, 232);
      expect(chainsawMan.status, 'FINISHED');
      expect(chainsawMan.title.userPreferred, 'Chainsaw Man');
    });

    test('upcoming filters status: anons', () async {
      final MangaRepositoryShikimori repository = repositoryWith(fixture('mangas_popular.json'));

      await repository.getUpcomingMangas(1, loggedUser());

      expect(lastVariables()['status'], 'anons');
      expect(lastVariables()['season'], isNull);
      expect(lastVariables()['order'], 'popularity');
    });

    test('recently completed asks for released titles without a season filter', () async {
      final MangaRepositoryShikimori repository = repositoryWith(fixture('mangas_popular.json'));

      await repository.getRecentlyCompletedMangas(1, loggedUser());

      expect(lastVariables()['status'], 'released');
      expect(lastVariables()['order'], 'updated_at_desc');
      expect(lastVariables()['season'], isNull);
    });

    test('trending orders by popularity', () async {
      final MangaRepositoryShikimori repository = repositoryWith(fixture('mangas_popular.json'));

      await repository.getTrendingMangas(1, loggedUser());

      expect(lastVariables()['order'], 'popularity');
      expect(lastVariables()['status'], isNull);
    });

    test('the NSFW setting drives the censored filter and the UA is always sent', () async {
      final MangaRepositoryShikimori repository = repositoryWith(fixture('mangas_popular.json'));

      await repository.getPopularMangas(1, loggedUser());
      expect(lastVariables()['censored'], isFalse);
      expect(http.lastHeaders!['User-Agent'], contains('unyo'));

      await repository.getPopularMangas(1, loggedUser(enableNsfwContent: true));
      expect(lastVariables()['censored'], isNull);
    });
  });

  group('MangaRepositoryShikimori details', () {
    test('maps manga relations never phantom anime entries', () async {
      final MangaRepositoryShikimori repository = repositoryWith(fixture('manga_details.json'));

      final (bool ok, MangaDetails details) = await repository.getMangaDetails(
        MangaModel.empty().copyWith(id: 1706, idMal: 1706),
        loggedUser(),
      );

      expect(ok, isTrue);
      expect(lastVariables()['ids'], '1706');

      // The fixture has two real manga relations (prequel/sequel) and one
      // relation whose manga payload is null, i.e. an anime adaptation.
      expect(details.recommendedMangas, hasLength(2));
      expect(
        details.recommendedMangas.map((Manga manga) => manga.id).toList(),
        <int>[3009, 25515],
      );
      expect(
        details.recommendedMangas.every((Manga manga) => manga.id != 0),
        isTrue,
        reason: 'a null relation must never surface as Manga(id: 0)',
      );
      expect(details.recommendedMangas.first.title.romaji, contains('Stone Ocean'));
      expect(details.recommendedMangas.first.idMal, 3009);
      expect(details.characters, hasLength(2));
      expect(details.characters.first.name, 'Diego Brando');
      expect(details.mediaListEntry.status, MediaListEntryModel.empty().status);
    });

    test('the mangas document carries volumes and publishers', () async {
      final MangaDetailsQueryEntity query = MangaDetailsQueryEntity.fromJson(
        fixture('manga_details.json')['data'] as Map<String, dynamic>,
      );

      final MangaDetailsQueryMangas manga = query.mangas.single;
      expect(manga.volumes, 24);
      expect(manga.chapters, 96);
      expect(manga.publishers.map((MangaDetailsQueryMangasPublishers publisher) => publisher.name), <String>['Ultra Jump']);
      expect(manga.malId, '1706');
    });

    test('an unknown id degrades to an empty details model', () async {
      final MangaRepositoryShikimori repository = repositoryWith(<String, dynamic>{
        'data': <String, dynamic>{'mangas': <dynamic>[]},
      });

      final (bool ok, MangaDetails details) = await repository.getMangaDetails(
        MangaModel.empty(),
        loggedUser(),
      );

      expect(ok, isFalse);
      expect(details.recommendedMangas, isEmpty);
      expect(details.characters, isEmpty);
    });
  });

  group('MangaRepositoryShikimori covers', () {
    test('cover images come from the popular list', () async {
      final MangaRepositoryShikimori repository = repositoryWith(fixture('mangas_popular.json'));

      final List<String> covers = await repository.getMediaCoverImages(loggedUser());

      expect(covers, hasLength(2));
      expect(covers.every((String cover) => cover.isNotEmpty), isTrue);
      expect(lastVariables()['order'], 'popularity');
    });
  });

  group('MangaRepositoryShikimori advanced search', () {
    test('filters come from genres(entryType: Manga) with the PascalCase enum value', () async {
      final MangaRepositoryShikimori repository = repositoryWith(
        <String, dynamic>{},
        payloadsByQueryMarker: <String, Map<String, dynamic>>{'genres(': fixture('genres_manga.json')},
      );

      final Map<String, (bool, List<String>)> filters =
          await repository.getUserMangaAdvancedSearchFilters(loggedUser());

      expect(lastVariables()['entryType'], 'Manga');
      expect(filters['genres']!.$1, isTrue);
      expect(filters['genres']!.$2, <String>['Action', 'Seinen', 'Shounen']);
      expect(filters['formats']!.$2, contains('Light novel'));
      expect(filters['airingStatuses']!.$2, containsAll(<String>['Ongoing', 'Paused', 'Discontinued']));
      expect(filters['sortOptions']!.$2, contains('Aired on'));
      expect(filters['countries']!.$1, isFalse, reason: 'Manga has no country-of-origin field');
      expect(filters['sortOrders']!.$1, isFalse, reason: 'OrderEnum has no general _desc twin');
    });

    test('a multi-filter search maps the manga genre id space and drops the country', () async {
      final MangaRepositoryShikimori repository = repositoryWith(
        fixture('mangas_search.json'),
        payloadsByQueryMarker: <String, Map<String, dynamic>>{'genres(': fixture('genres_manga.json')},
      );

      final List<Manga> results = await repository.performMangaAdvancedSearch(
        'Berserk',
        <String>['Shounen'],
        'Manga',
        'Japan',
        'Released',
        'Popularity_Desc',
        1,
        loggedUser(),
      );

      expect(results, hasLength(2));
      expect(lastVariables()['genre'], '47', reason: 'Shounen is id 47 in the manga genre set');
      expect(lastVariables()['kind'], 'manga');
      expect(lastVariables()['status'], 'released');
      expect(lastVariables()['order'], 'popularity');
      expect(lastVariables()['search'], 'Berserk');
      expect(lastVariables()['publisher'], isNull, reason: 'a country is not a publisher id');
      expect(lastVariables()['censored'], isFalse);
      expect(results.first.id, 1706);
      expect(results.first.idMal, 1706);
      expect(results.first.title.russian, isNotEmpty);
      expect(http.lastBody!['query'], contains('publisher:'));
      expect(http.lastBody!['query'], contains('franchise:'));
    });

    test('a single search term does not trigger a genre lookup', () async {
      final MangaRepositoryShikimori repository = repositoryWith(fixture('mangas_search.json'));

      final List<Manga> results =
          await repository.performMangaAdvancedSearch('', <String>[], null, null, null, 'Name_Desc', 1, loggedUser());

      expect(results, hasLength(2));
      expect(http.calls, 1);
      expect(lastVariables()['search'], isNull);
      expect(lastVariables()['order'], 'name', reason: 'OrderEnum rejects name_desc');
    });
  });
}

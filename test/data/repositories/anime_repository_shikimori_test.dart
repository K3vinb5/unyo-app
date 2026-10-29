// External dependencies
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/api/graphql/graphql_exception.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/repositories/anime_repository_shikimori.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

import 'support/fake_graphql_http_service.dart';

/// Repository-level tests for [AnimeRepositoryShikimori].
///
/// The HTTP boundary is faked ([FakeGraphQlHttpService] feeds the captured
/// payloads in `test/data/fixtures/shikimori/`, trimmed from the live 2026-10-29
/// captures in `research/unyo-64-shikimori-parity-proof/raws/api/`), so the
/// real `GraphQLService` → fjson DTO → model chain runs for every call.
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

  AnimeRepositoryShikimori repositoryWith(Map<String, dynamic> payload) {
    sl.reset();
    sl.registerSingleton<Logger>(Logger(filter: ProductionFilter()));
    http = FakeGraphQlHttpService(payload);
    sl.registerSingleton<HttpService>(http);
    sl.registerLazySingleton<GraphQLService>(
      () => GraphQLService(
        httpService: sl<HttpService>(),
        endpoint: config.shikimoriGraphQLEndpoint,
      ),
      instanceName: config.shikimoriGraphQlService,
    );
    return AnimeRepositoryShikimori();
  }

  Map<String, dynamic> lastVariables() => http.lastBody!['variables'] as Map<String, dynamic>;

  group('AnimeRepositoryShikimori browse lists', () {
    test('upcoming filters status: anons instead of ordering by aired_on', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(fixture('animes_upcoming.json'));

      final (bool ok, List<Anime> animes) = await repository.getUpcomingAnimes(1, loggedUser());

      expect(ok, isTrue);
      expect(animes, isNotEmpty);
      expect(animes.every((Anime anime) => anime.status == 'NOT_YET_RELEASED'), isTrue);
      expect(lastVariables()['status'], 'anons');
      expect(lastVariables()['season'], isNull, reason: 'upcoming must not be limited to the current season');
      expect(lastVariables()['order'], 'popularity');
      expect(lastVariables()['page'], 1);
      expect(lastVariables()['limit'], AnimeRepositoryShikimori.pageSize);
      expect(http.lastBody!['query'], contains('animes('));
    });

    test('recently completed drops the spurious season filter', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(fixture('animes_popular.json'));

      final (bool ok, List<Anime> animes) = await repository.getRecentlyCompletedAnimes(2, loggedUser());

      expect(ok, isTrue);
      expect(animes, hasLength(2));
      expect(lastVariables()['status'], 'released');
      expect(lastVariables()['order'], 'updated_at_desc');
      expect(lastVariables()['season'], isNull, reason: 'a show that ended last season is still recently completed');
      expect(lastVariables()['page'], 2);
    });

    test('recently released keeps ongoing shows and surfaces nextEpisodeAt', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(fixture('animes_ongoing.json'));

      final (bool ok, List<Anime> animes) = await repository.getRecentlyReleasedAnimes(1, loggedUser());

      expect(ok, isTrue);
      expect(animes, hasLength(3));
      expect(lastVariables()['status'], 'ongoing');
      expect(lastVariables()['order'], 'updated_at_desc');
      expect(lastVariables()['season'], isNull);

      final Anime airing = animes.firstWhere((Anime anime) => anime.id == 61967);
      expect(airing.nextAiringEpisode.episode, 5, reason: 'episodesAired (4) + 1');
      expect(
        airing.nextAiringEpisode.airingAt,
        (DateTime.parse('2026-10-31T17:00:00+03:00').millisecondsSinceEpoch ~/ 1000).toString(),
        reason: 'airingAt is unix seconds, like AniList',
      );
      expect(airing.title.romaji, 'Black Clover 2nd Season');
      expect(airing.title.userPreferred, 'Black Clover 2nd Season', reason: 'name is the display title, not russian');
      expect(airing.popularity, 0, reason: 'Shikimori has no popularity counter');
    });

    test('trending asks for the current season and popularity order', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(fixture('animes_ongoing.json'));

      await repository.getTrendingAnimes(1, loggedUser());

      expect(lastVariables()['order'], 'popularity');
      expect(lastVariables()['status'], isNull);
      expect(
        lastVariables()['season'],
        matches(RegExp(r'^(winter|spring|summer|fall)_\d{4}$')),
      );
    });

    test('popular orders by popularity without extra filters', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(fixture('animes_popular.json'));

      final (bool ok, List<Anime> animes) = await repository.getPopularAnimes(1, loggedUser());

      expect(ok, isTrue);
      expect(animes, hasLength(2));
      expect(lastVariables()['order'], 'popularity');
      expect(lastVariables()['status'], isNull);
      expect(lastVariables()['season'], isNull);
    });

    test('the NSFW setting drives the censored filter', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(fixture('animes_popular.json'));

      await repository.getPopularAnimes(1, loggedUser());
      expect(lastVariables()['censored'], isFalse);

      await repository.getPopularAnimes(1, loggedUser(enableNsfwContent: true));
      expect(lastVariables()['censored'], isNull, reason: 'null = do not filter');
    });

    test('every request carries the mandatory Shikimori User-Agent', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(fixture('animes_popular.json'));

      await repository.getPopularAnimes(1, loggedUser());
      await repository.getTrendingAnimes(1, loggedUser());
      await repository.getUpcomingAnimes(1, loggedUser());
      await repository.getRecentlyCompletedAnimes(1, loggedUser());
      await repository.getRecentlyReleasedAnimes(1, loggedUser());

      expect(http.calls, 5);
      expect(http.lastEndpoint, config.shikimoriGraphQLEndpoint);
      expect(http.lastHeaders, isNotNull);
      expect(http.lastHeaders!['User-Agent'], contains('unyo'));
      expect(http.lastHeaders!['User-Agent'], isNot(isEmpty));
    });
  });

  group('AnimeRepositoryShikimori details', () {
    test('maps related anime, characters and the empty list entry', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(fixture('anime_details.json'));

      final (bool ok, AnimeDetails details) = await repository.getAnimeDetails(
        AnimeModel.empty().copyWith(id: 61967, idMal: 61967),
        loggedUser(),
      );

      expect(ok, isTrue);
      expect(lastVariables()['ids'], '61967');
      expect(details.characters, hasLength(2));
      expect(details.characters.first.name, 'Asta');
      expect(details.characters.first.id, 124731);
      expect(details.recommendedAnimes, hasLength(1), reason: 'the manga relation must not become a phantom anime');
      expect(details.recommendedAnimes.single.id, 34572);
      expect(details.recommendedAnimes.single.title.romaji, 'Black Clover');
      expect(details.mediaListEntry.status, MediaListEntryModel.empty().status);
    });

    test('an unknown id degrades to an empty details model', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(<String, dynamic>{
        'data': <String, dynamic>{'animes': <dynamic>[]},
      });

      final (bool ok, AnimeDetails details) = await repository.getAnimeDetails(
        AnimeModel.empty(),
        loggedUser(),
      );

      expect(ok, isFalse);
      expect(details.recommendedAnimes, isEmpty);
      expect(details.characters, isEmpty);
    });

    test('a GraphQL error envelope (HTTP 200 + errors[]) throws', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(<String, dynamic>{
        'data': <String, dynamic>{'animes': <dynamic>[]},
        'errors': <dynamic>[
          <String, dynamic>{'message': "Field 'popularity' doesn't exist on type 'Anime'"},
        ],
      });

      await expectLater(
        repository.getPopularAnimes(1, loggedUser()),
        throwsA(isA<GraphQLException>()),
      );
    });
  });

  group('AnimeRepositoryShikimori covers', () {
    test('cover images come from the popular list, empty covers dropped', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(fixture('animes_popular.json'));

      final List<String> covers = await repository.getMediaCoverImages(loggedUser());

      expect(covers, hasLength(2));
      expect(covers.every((String cover) => cover.isNotEmpty), isTrue);
      expect(lastVariables()['order'], 'popularity');
    });
  });
}

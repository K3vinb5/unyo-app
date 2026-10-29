// External dependencies
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
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
import 'package:unyo/data/models/shikimori/media/shikimori_anime_model.dart';
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

  AnimeRepositoryShikimori repositoryWith(
    Map<String, dynamic> payload, {
    Object? getPayload,
    Map<String, Map<String, dynamic>> payloadsByQueryMarker = const <String, Map<String, dynamic>>{},
  }) {
    sl.reset();
    sl.registerSingleton<Logger>(Logger(filter: ProductionFilter()));
    http = FakeGraphQlHttpService(payload, getPayload: getPayload, payloadsByQueryMarker: payloadsByQueryMarker);
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

  group('AnimeRepositoryShikimori calendar', () {
    List<dynamic> rawCalendar() =>
        jsonDecode(File('test/data/fixtures/shikimori/calendar.json').readAsStringSync()) as List<dynamic>;

    test('maps the flat REST calendar into local day buckets', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(<String, dynamic>{}, getPayload: rawCalendar());

      final Map<String, List<Anime>> calendar = await repository.getCalendarReleases(1, loggedUser());

      expect(http.lastGetEndpoint, config.shikimoriCalendarEndpoint);
      expect(http.lastGetEndpoint, isNot(config.shikimoriGraphQLEndpoint));
      expect(http.lastHeaders!['User-Agent'], contains('unyo'));

      final List<Anime> all = calendar.values.expand((List<Anime> day) => day).toList();
      expect(all, hasLength(4), reason: 'every dated entry lands in exactly one bucket');

      final Anime fx = all.firstWhere((Anime anime) => anime.id == 63337);
      expect(fx.idMal, 0, reason: 'the calendar carries no mal_id — the native id is never reused (WP #63)');
      expect(fx.title.russian, 'FX Воин Куруми');
      expect(fx.title.userPreferred, 'FX Senshi Kurumi-chan', reason: 'name wins the display slot');
      expect(
        fx.coverImage,
        'https://shikimori.io/assets/globals/missing_original.jpg',
        reason: 'REST poster paths are site-relative',
      );
      expect(fx.duration, 1380);
      expect(fx.episodes, 12);
      expect(fx.startDate, '1/10/2026');
      expect(fx.endDate, '0/0/0');
      expect(fx.status, 'RELEASING');
      expect(fx.nextAiringEpisode.episode, 5, reason: 'next_episode is explicit in the REST payload');
      expect(
        fx.nextAiringEpisode.airingAt,
        (DateTime.parse('2026-10-29T15:30:00.000+03:00').millisecondsSinceEpoch ~/ 1000).toString(),
      );

      final Anime anons = all.firstWhere((Anime anime) => anime.id == 65072);
      expect(anons.status, 'NOT_YET_RELEASED');

      final DateFormat en = DateFormat('EEEE, MMMM d, y');
      final DateTime fxLocal = DateTime.parse('2026-10-29T15:30:00.000+03:00').toLocal();
      expect(
        calendar.containsKey(en.format(DateTime(fxLocal.year, fxLocal.month, fxLocal.day))),
        isTrue,
        reason: 'day keys use the same DateFormat as the AniList calendar',
      );
      final List<DateTime> days = calendar.keys.map(en.parse).toList();
      expect(days, orderedEquals(<DateTime>[...days]..sort()), reason: 'days are chronological');
      for (final List<Anime> day in calendar.values) {
        final List<int> times = day.map((Anime anime) => int.parse(anime.nextAiringEpisode.airingAt)).toList();
        expect(times, orderedEquals(<int>[...times]..sort()), reason: 'episodes inside a day are chronological');
      }
    });

    test('page 2 is empty because /api/calendar is unpaginated', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(<String, dynamic>{}, getPayload: rawCalendar());

      expect(await repository.getCalendarReleases(2, loggedUser()), isEmpty);
      expect(http.calls, 0);
    });

    test('an entry without next_episode_at is dropped instead of becoming an undated card', () async {
      final Map<String, dynamic> undated = Map<String, dynamic>.from(rawCalendar().first as Map<String, dynamic>)
        ..['next_episode_at'] = null;
      final AnimeRepositoryShikimori repository = repositoryWith(
        <String, dynamic>{},
        getPayload: <dynamic>[undated],
      );

      expect(await repository.getCalendarReleases(1, loggedUser()), isEmpty);
    });

    test('the NSFW gate has the AniList shape, over the only signal the payload has', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(<String, dynamic>{}, getPayload: rawCalendar());

      final Map<String, List<Anime>> calendar = await repository.getCalendarReleases(1, loggedUser());
      final List<Anime> all = calendar.values.expand((List<Anime> day) => day).toList();

      // `/api/calendar` has no `rating` and no `is_censored` (raw capture), so
      // the mapper reports the only honest value and the feed cannot be
      // NSFW-filtered — the residual gap documented in PR #156. The gate still
      // runs, with the same expression the AniList calendar uses.
      expect(ShikimoriAnimeModel.calendarReportsAdult, isFalse);
      expect(all.every((Anime anime) => !anime.isAdult), isTrue);
      expect(all, hasLength(4), reason: 'nothing to drop while the payload carries no adult marker');

      final Anime adult = _AdultAnime();
      expect(visibleCalendarEntries(<Anime>[adult], loggedUser()), isEmpty, reason: 'NSFW off drops adult entries');
      expect(
        visibleCalendarEntries(<Anime>[adult], loggedUser(enableNsfwContent: true)),
        hasLength(1),
        reason: 'NSFW on keeps them, like the AniList path',
      );
    });
  });

  group('AnimeRepositoryShikimori advanced search', () {
    test('a single search term leaves every other filter unset and maps the results', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(fixture('animes_search.json'));

      final List<Anime> results = await repository.performAnimeAdvancedSearch(
        'Frieren',
        <String>[],
        null,
        null,
        null,
        null,
        'Popularity_Desc',
        1,
        loggedUser(),
      );

      expect(results, hasLength(2));
      expect(lastVariables()['search'], 'Frieren');
      expect(lastVariables()['order'], 'popularity');
      expect(lastVariables()['kind'], isNull);
      expect(lastVariables()['status'], isNull);
      expect(lastVariables()['season'], isNull);
      expect(lastVariables()['genre'], isNull);
      expect(lastVariables()['censored'], isFalse);
      expect(http.calls, 1, reason: 'no genre lookup happens when no genre is selected');
      expect(results.first.id, 52347);
      expect(results.first.idMal, 52347);
      expect(results.first.title.russian, isNotEmpty);
      expect(http.lastBody!['query'], contains('DurationString'), reason: 'the live server rejects a plain String here');
      expect(http.lastBody!['query'], contains('RatingString'));
      expect(http.lastBody!['query'], contains('OriginString'));
    });

    test('a multi-filter search translates genres to ids and collapses the order literal', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(
        fixture('animes_search.json'),
        payloadsByQueryMarker: <String, Map<String, dynamic>>{'genres(': fixture('genres_anime.json')},
      );

      final List<Anime> results = await repository.performAnimeAdvancedSearch(
        '   ',
        <String>['Shounen', 'Seinen'],
        'Fall',
        'Tv',
        2023,
        'Released',
        'Ranked_Desc',
        2,
        loggedUser(),
      );

      expect(results, hasLength(2));
      expect(lastVariables()['search'], isNull, reason: 'a blank query is not a filter');
      expect(lastVariables()['kind'], 'tv');
      expect(lastVariables()['status'], 'released');
      expect(lastVariables()['season'], 'fall_2023');
      expect(lastVariables()['genre'], '27,42', reason: 'genre names are ids on the wire');
      expect(lastVariables()['order'], 'ranked', reason: 'OrderEnum rejects ranked_desc');
      expect(lastVariables()['page'], 2);
      expect(lastVariables()['limit'], AnimeRepositoryShikimori.pageSize);
      expect(http.lastBody!['query'], contains('studio:'));
      expect(http.lastBody!['query'], contains(r'duration: $duration'));
      expect(http.lastBody!['query'], contains('franchise:'));
    });

    test('filters come from genres(entryType: Anime) with the PascalCase enum value', () async {
      final AnimeRepositoryShikimori repository = repositoryWith(
        <String, dynamic>{},
        payloadsByQueryMarker: <String, Map<String, dynamic>>{'genres(': fixture('genres_anime.json')},
      );

      final Map<String, (bool, List<String>)> filters =
          await repository.getUserAnimeAdvancedSearchFilters(loggedUser());

      expect(lastVariables()['entryType'], 'Anime');
      expect(filters['genres']!.$1, isTrue);
      expect(filters['genres']!.$2, <String>['Seinen', 'Shoujo', 'Shounen'], reason: 'sorted labels from the genre dictionary');
      expect(filters['formats']!.$2, contains('Tv special'));
      expect(filters['airingStatuses']!.$2, containsAll(<String>['Ongoing', 'Released', 'Anons']));
      expect(filters['seasons']!.$2, containsAll(<String>['Winter', 'Fall']));
      expect(filters['sortOptions']!.$2, contains('Aired on'));
      expect(
        filters['years']!.$1,
        isTrue,
        reason: 'round 1 finding 2: season+year is expressible as SeasonString (fall_2023), so the year dropdown must render',
      );
      expect(filters['years']!.$2.first, '${DateTime.now().year}', reason: 'newest year first, same as the AniList list');
      expect(filters['years']!.$2, containsAll(<String>['1940', '2023']));
      expect(
        filters['sortOrders']!.$1,
        isFalse,
        reason: 'no exposed sort option has a _desc literal in OrderEnum (only id_desc/updated_at_desc exist)',
      );
      // Sweep guard (round 1): an enabled capability must ship options, or the
      // screen renders an empty dropdown behind a visible widget.
      for (final MapEntry<String, (bool, List<String>)> entry in filters.entries) {
        if (entry.value.$1) {
          expect(entry.value.$2, isNotEmpty, reason: '${entry.key} is enabled but has no options');
        }
      }
    });
  });
}

/// Only [Anime.isAdult] matters to the calendar NSFW gate; every other member is
/// never read, so a `Fake` is enough.
class _AdultAnime extends Fake implements Anime {
  @override
  bool get isAdult => true;
}

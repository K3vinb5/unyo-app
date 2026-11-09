// External dependencies
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/services/api/mal/mal_auth_service.dart';
import 'package:unyo/core/services/api/jikan/jikan_rate_limiter.dart';
import 'package:unyo/core/services/api/mal/mal_metadata_service.dart';
import 'package:unyo/core/services/api/mal/mal_metadata_vocabularies.dart';
import 'package:unyo/core/services/api/mal/mal_rate_limiter.dart';
import 'package:unyo/core/services/api/mal/mal_user_rate_service.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/data/repositories/anime_repository_mal.dart';
import 'package:unyo/data/repositories/user_repository_mal.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/media/title.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

import '../../core/services/api/shikimori/support/fake_rate_limiter_clock.dart';
import 'support/fake_mal_wire.dart';

/// Repository-level tests for [AnimeRepositoryMal].
///
/// The real [MalUserRateService] runs under the repository (the wire is faked
/// at the `http.Client` boundary), so every assertion sees the request the
/// repository+service chain actually produced — the same layering the
/// Shikimori repository tests use.
void main() {
  late MalWireDouble wire;
  late FakeMalAuthService auth;
  late MockUserRepositoryMal userRepository;
  late AnimeRepositoryMal repository;

  setUpAll(() {
    registerFallbackValue(UserModel.empty());
    registerFallbackValue(MalUserModel(
      id: '0',
      name: 'fallback',
      settings: SettingsModel.empty(),
      avatarImage: '',
      bannerImage: '',
      accessToken: '',
      refreshToken: '',
      accessTokenExpiresAt: '',
      profileUrl: '',
    ));
  });

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));
    final FakeRateLimiterClock clock = FakeRateLimiterClock();
    sl.registerLazySingleton<MalRateLimiter>(
      () => MalRateLimiter(clock: clock.now, wait: clock.wait),
    );
    auth = FakeMalAuthService();
    sl.registerSingleton<MalAuthService>(auth);
    userRepository = MockUserRepositoryMal();
    sl.registerSingleton<UserRepositoryMal>(userRepository);
    when(() => userRepository.updateUserInfo(any())).thenAnswer((_) async {});
    // The tracker helper's live-pair contract: the metadata service asks it for
    // a usable account before every authenticated details read, and here the
    // stored pair is already live, so nothing rotates.
    when(() => userRepository.ensureFreshAccessToken(any())).thenAnswer(
      (Invocation invocation) async => invocation.positionalArguments.first as MalUserModel,
    );
    wire = MalWireDouble();
    sl.registerSingleton<MalUserRateService>(MalUserRateService(client: wire.createClient()));
    sl.registerSingleton<MalMetadataService>(MalMetadataService(
      client: wire.createClient(),
      // Jikan's pacing is proven by its own tests; here it must not spend real
      // seconds between the seven calendar calls and the feeds.
      jikanRateLimiter: JikanRateLimiter(wait: (_) async {}, logger: Logger(level: Level.off)),
    ));
    repository = AnimeRepositoryMal();
  });

  Map<String, dynamic> fixture(String name) {
    return jsonDecode(File('test/data/fixtures/mal/$name').readAsStringSync()) as Map<String, dynamic>;
  }

  MalUserModel malUser({bool enableNsfwContent = false}) {
    return MalUserModel(
      id: '56789',
      name: 'tester',
      settings: SettingsModel.empty().copyWith(enableNsfwContent: enableNsfwContent),
      avatarImage: '',
      bannerImage: '',
      accessToken: 'stored-access',
      refreshToken: 'stored-refresh',
      accessTokenExpiresAt: '2099-01-01T00:00:00.000',
      profileUrl: '',
    );
  }

  Anime anime({int id = 58514}) {
    return AnimeModel.empty().copyWith(
      id: id,
      idMal: id,
      title: const TitleModel(
        romaji: 'Kusuriya no Hitorigoto',
        english: '',
        nativeTitle: '',
        userPreferred: 'Kusuriya no Hitorigoto',
      ),
    );
  }

  MediaListEntry entry({
    int progress = 0,
    double score = 0,
    int repeat = 0,
    String status = 'CURRENT',
  }) {
    return MediaListEntryModel(
      progress: progress,
      progressVolumes: 0,
      score: score,
      repeat: repeat,
      status: status,
      startedAt: const <String>['~', '~', '~'],
      completedAt: const <String>['~', '~', '~'],
    );
  }

  group('AnimeRepositoryMal list entries', () {
    test('getMediaListEntry passes the record id and the anime kind to MAL', () async {
      wire.answers = <Object>[
        (
          200,
          jsonEncode(<String, dynamic>{
            'id': 58514,
            'my_list_status': <String, dynamic>{
              'status': 'watching',
              'score': 9,
              'num_episodes_watched': 7,
              'is_rewatching': false,
              'num_times_rewatched': 1,
            },
          }),
        ),
      ];

      final MediaListEntry read = await repository.getMediaListEntry(anime(), malUser());

      expect(read.status, 'CURRENT');
      expect(read.progress, 7);
      expect(read.score, 9);
      expect(read.repeat, 1);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.method, 'GET');
      expect(request.url.toString(), '${config.malApiBase}/anime/58514?fields=my_list_status');
      expect(request.headers['authorization'], 'Bearer stored-access');
    });

    test('updateMediaListEntry writes through the anime my_list_status upsert', () async {
      wire.answers = <Object>[
        (
          200,
          jsonEncode(<String, dynamic>{
            'status': 'watching',
            'score': 8,
            'num_episodes_watched': 3,
            'is_rewatching': false,
            'num_times_rewatched': 0,
          }),
        ),
      ];

      final MediaListEntry written = await repository.updateMediaListEntry(
        entry(progress: 3, score: 8),
        anime(),
        malUser(),
      );

      expect(written.progress, 3);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.method, 'PUT');
      expect(request.url.toString(), '${config.malApiBase}/anime/58514/my_list_status');
      expect(request.headers['authorization'], 'Bearer stored-access');
      expect(request.headers['content-type'], contains('application/x-www-form-urlencoded'));
      // The write key is num_watched_episodes; the response key is
      // num_episodes_watched (SPEC §3 quirk) — only the write key may be sent.
      expect(request.bodyFields['num_watched_episodes'], '3');
      expect(request.bodyFields.containsKey('num_episodes_watched'), isFalse);
      expect(request.bodyFields['num_chapters_read'], isNull);
      expect(request.bodyFields['status'], 'watching');
      expect(request.bodyFields['score'], '8');
    });

    test('a title with no list status reads as the empty entry', () async {
      wire.answers = <Object>[(200, jsonEncode(<String, dynamic>{'id': 58514, 'title': 'x'}))];

      final MediaListEntry read = await repository.getMediaListEntry(anime(), malUser());

      expect(read.status, MediaListEntryModel.empty().status);
    });

    test('a 404 media id reads as the empty entry', () async {
      wire.answers = <Object>[(404, '{}')];

      final MediaListEntry read = await repository.getMediaListEntry(anime(id: 1), malUser());

      expect(read.status, MediaListEntryModel.empty().status);
    });

    test('an empty-status entry is the delete and returns the empty entry', () async {
      wire.answers = <Object>[(204, '')];

      final MediaListEntry written = await repository.updateMediaListEntry(
        MediaListEntryModel.empty(),
        anime(),
        malUser(),
      );

      expect(written.status, MediaListEntryModel.empty().status);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.method, 'DELETE');
      expect(request.url.toString(), '${config.malApiBase}/anime/58514/my_list_status');
    });

    test('a non-MyAnimeList account degrades to the empty entry without any request', () async {
      final MediaListEntry read = await repository.getMediaListEntry(anime(), UserModel.empty());
      final MediaListEntry written = await repository.updateMediaListEntry(
        entry(progress: 1),
        anime(),
        UserModel.empty(),
      );

      expect(read.status, MediaListEntryModel.empty().status);
      expect(written.status, MediaListEntryModel.empty().status);
      expect(wire.requests, isEmpty);
      expect(auth.refreshes, 0);
    });
  });

  group('AnimeRepositoryMal browse lists', () {
    test('trending asks /v2/anime/ranking?ranking_type=airing and maps the node', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('anime_ranking.json')))];

      final (bool ok, List<Anime> animes) = await repository.getTrendingAnimes(1, malUser());

      expect(ok, isTrue);
      expect(animes, hasLength(1), reason: 'the adult entry is dropped while NSFW is off');
      final RecordedMalRequest request = wire.requests.single;
      expect(request.method, 'GET');
      expect(request.url.path, '/v2/anime/ranking');
      expect(request.url.queryParameters['ranking_type'], 'airing');
      expect(request.url.queryParameters['limit'], '${AnimeRepositoryMal.pageSize}');
      expect(request.url.queryParameters['offset'], '0');
      expect(request.url.queryParameters['fields'], MalMetadataService.animeListFields);
      expect(request.headers.containsKey('authorization'), isFalse, reason: 'browse reads are anonymous');
      expect(request.headers['x-mal-client-id'], config.malClientId, reason: 'v2 403s without the public client id');

      final Anime fmab = animes.single;
      expect(fmab.id, 5114);
      expect(fmab.idMal, 5114, reason: 'the MAL native id is identity addressing');
      expect(fmab.title.userPreferred, 'Fullmetal Alchemist: Brotherhood');
      expect(fmab.averageScore, 91);
      expect(fmab.meanScore, 91, reason: 'mean 9.1 × 10');
      expect(fmab.startDate, '5/4/2009');
      expect(fmab.endDate, '4/7/2010');
      expect(fmab.genres, <String>['Action', 'Fantasy']);
      expect(fmab.isAdult, isFalse, reason: 'rating=r is R-17+, not MAL adult (rx/r+)');
    });

    test('popular asks ranking_type=bypopularity and keeps adult titles when NSFW is on', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('anime_ranking.json')))];

      final (bool ok, List<Anime> animes) = await repository.getPopularAnimes(1, malUser(enableNsfwContent: true));

      expect(ok, isTrue);
      expect(animes, hasLength(2));
      expect(wire.requests.single.url.queryParameters['ranking_type'], 'bypopularity');
      final Anime adult = animes.last;
      expect(adult.isAdult, isTrue, reason: 'rating=rx / nsfw=black');
    });

    test('recently released asks Jikan for airing titles sorted by start date desc', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('jikan_anime.json')))];

      final (bool ok, List<Anime> animes) = await repository.getRecentlyReleasedAnimes(1, malUser());

      expect(ok, isTrue);
      expect(animes, hasLength(1), reason: 'the Rx entry is dropped while NSFW is off');
      final RecordedMalRequest request = wire.requests.single;
      expect(request.url.host, 'api.jikan.moe');
      expect(request.url.path, '/v4/anime');
      final Map<String, String> query = request.url.queryParameters;
      expect(query['status'], 'airing', reason: 'Jikan status vocabulary, not MAL\'s currently_airing');
      expect(query['order_by'], 'start_date');
      expect(query['sort'], 'desc');
      expect(query['page'], '1');
      expect(query['limit'], '${AnimeRepositoryMal.jikanPageSize}');
      expect(query['sfw'], 'true');
      expect(request.headers.containsKey('x-mal-client-id'), isFalse, reason: 'Jikan is not a MAL host');

      final Anime apothecary = animes.single;
      expect(apothecary.id, 58514);
      expect(apothecary.idMal, 58514, reason: 'the MAL native id is identity addressing');
      expect(apothecary.title.userPreferred, 'Kusuriya no Hitorigoto 2nd Season');
      expect(apothecary.averageScore, 88, reason: '8.75 × 10 rounds to 88');
      expect(apothecary.startDate, '10/1/2025');
      expect(apothecary.endDate, '0/0/0', reason: 'a null "to" is the unset sentinel, not today');
      expect(apothecary.duration, 1380, reason: '"23 min per ep" lands on the seconds scale');
      expect(apothecary.status, 'RELEASING', reason: 'Jikan prose "Currently Airing" folds onto MAL\'s enum');
      expect(apothecary.season, 'WINTER');
      expect(apothecary.genres, containsAll(<String>['Drama', 'Slice of Life']));
      expect(apothecary.genres, isNot(contains('Historical')), reason: 'themes are not genres');
      expect(apothecary.isAdult, isFalse);
    });

    test('recently completed asks Jikan for complete titles sorted by end date desc', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('jikan_anime.json')))];

      final (bool ok, List<Anime> animes) = await repository.getRecentlyCompletedAnimes(1, malUser());

      expect(ok, isTrue);
      final Map<String, String> query = wire.requests.single.url.queryParameters;
      expect(wire.requests.single.url.path, '/v4/anime');
      expect(query['status'], 'complete');
      expect(query['order_by'], 'end_date');
      expect(query['sort'], 'desc');
      expect(animes.single.status, 'RELEASING');
    });

    test('upcoming asks the v2 upcoming ranking (probed valid) with the client id', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('anime_ranking.json')))];

      await repository.getUpcomingAnimes(1, malUser());

      final RecordedMalRequest request = wire.requests.single;
      expect(request.url.path, '/v2/anime/ranking');
      expect(request.url.queryParameters['ranking_type'], 'upcoming');
      expect(request.url.queryParameters['limit'], '${AnimeRepositoryMal.pageSize}');
      expect(request.headers['x-mal-client-id'], config.malClientId);
      expect(request.headers.containsKey('authorization'), isFalse,
          reason: 'public ranking reads never carry the account token, even for a logged MAL user');
    });

    test('page N maps onto Jikan page/limit and the NSFW opt-in omits sfw', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('jikan_anime.json')))];

      final (bool ok, List<Anime> animes) = await repository.getRecentlyReleasedAnimes(3, malUser(enableNsfwContent: true));

      expect(ok, isTrue);
      expect(animes, hasLength(2), reason: 'the adult entry is kept when NSFW is on');
      final Map<String, String> query = wire.requests.single.url.queryParameters;
      expect(query['page'], '3');
      expect(query['limit'], '${AnimeRepositoryMal.jikanPageSize}');
      expect(query.containsKey('sfw'), isFalse, reason: 'Jikan includes adult entries unless sfw=true');
      expect(animes.last.isAdult, isTrue, reason: 'explicit_genres: Hentai');
    });

    test('a non-2xx browse answer degrades to (false, [])', () async {
      wire.answers = <Object>[(500, '{"error":"server_error"}')];

      final (bool trendingOk, List<Anime> trending) = await repository.getTrendingAnimes(1, malUser());
      wire.answers = <Object>[(503, '{}')];
      final (bool releasedOk, List<Anime> released) = await repository.getRecentlyReleasedAnimes(1, malUser());

      expect(trendingOk, isFalse);
      expect(trending, isEmpty);
      expect(releasedOk, isFalse);
      expect(released, isEmpty);
    });
  });

  group('AnimeRepositoryMal details', () {
    test('asks /v2/anime/{id} with the details fields, authenticated, and maps the extras', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('anime_details.json')))];

      final (bool ok, AnimeDetails details) = await repository.getAnimeDetails(anime(id: 58514), malUser());

      expect(ok, isTrue);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.url.path, '/v2/anime/58514');
      expect(request.url.queryParameters['fields'], MalMetadataService.animeDetailsFields);
      expect(request.headers['authorization'], 'Bearer stored-access');
      expect(details.mediaListEntry.status, 'CURRENT');
      expect(details.mediaListEntry.progress, 7);
      expect(details.mediaListEntry.score, 9);
      expect(details.recommendedAnimes, hasLength(1), reason: 'related_manga must not become a phantom anime');
      expect(details.recommendedAnimes.single.id, 61000);
      expect(details.recommendedAnimes.single.title.romaji, 'Kusuriya no Hitorigoto 2nd Season');
      expect(details.characters, isEmpty, reason: 'MAL v2 serves no characters');
    });

    test('a non-MAL account reads details anonymously and gets the empty entry', () async {
      final Map<String, dynamic> payload = fixture('anime_details.json')..remove('my_list_status');
      wire.answers = <Object>[(200, jsonEncode(payload))];

      final (bool ok, AnimeDetails details) = await repository.getAnimeDetails(anime(id: 58514), UserModel.empty());

      expect(ok, isTrue, reason: 'the public part of the page still renders');
      expect(wire.requests.single.headers.containsKey('authorization'), isFalse);
      expect(details.mediaListEntry.status, MediaListEntryModel.empty().status);
      expect(details.recommendedAnimes, hasLength(1));
    });

    test('a 404 details answer degrades to the empty details model', () async {
      wire.answers = <Object>[(404, '{"error":"not_found"}')];

      final (bool ok, AnimeDetails details) = await repository.getAnimeDetails(anime(id: 1), malUser());

      expect(ok, isFalse);
      expect(details.recommendedAnimes, isEmpty);
      expect(details.characters, isEmpty);
      expect(details.mediaListEntry.status, MediaListEntryModel.empty().status);
    });

    test('a non-positive id skips the call instead of letting the service throw', () async {
      final (bool ok, AnimeDetails details) = await repository.getAnimeDetails(anime(id: 0), malUser());

      expect(ok, isFalse);
      expect(details.recommendedAnimes, isEmpty);
      expect(details.mediaListEntry.status, MediaListEntryModel.empty().status);
      expect(wire.requests, isEmpty);
    });
  });

  group('AnimeRepositoryMal search', () {
    test('translates the search filters onto Jikan and drops season/year', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('jikan_anime.json')))];

      final List<Anime> results = await repository.performAnimeAdvancedSearch(
        '   ',
        <String>['Shounen', 'Seinen'],
        'Fall',
        'TV',
        2023,
        'Airing',
        'SCORE_DESC',
        2,
        malUser(),
      );

      expect(results, hasLength(1), reason: 'the adult entry is dropped while NSFW is off');
      expect(results.single.id, 58514);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.url.host, 'api.jikan.moe');
      expect(request.url.path, '/v4/anime');
      final Map<String, String> query = request.url.queryParameters;
      expect(query.containsKey('q'), isFalse, reason: 'a blank query is not a filter');
      expect(query['type'], 'tv');
      expect(query['status'], 'airing');
      expect(query['genres'], '27,42', reason: 'genre labels become MAL/Jikan ids');
      expect(query['order_by'], 'score');
      expect(query['sort'], 'desc');
      expect(query['sfw'], 'true');
      expect(query['page'], '2');
      expect(query['limit'], '${AnimeRepositoryMal.jikanPageSize}');
      expect(query.containsKey('season'), isFalse, reason: 'Jikan /anime has no season filter');
      expect(query.containsKey('year'), isFalse, reason: 'Jikan /anime has no year filter');
    });

    test('a query plus ascending members sort and the NSFW opt-in', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('jikan_anime.json')))];

      await repository.performAnimeAdvancedSearch(
        '  hitorigoto ',
        <String>[],
        null,
        'tv',
        null,
        'airing',
        'MEMBERS_ASC',
        1,
        malUser(enableNsfwContent: true),
      );

      final Map<String, String> query = wire.requests.single.url.queryParameters;
      expect(query['q'], 'hitorigoto');
      expect(query['type'], 'tv');
      expect(query['status'], 'airing');
      expect(query['order_by'], 'members');
      expect(query['sort'], 'asc');
      expect(query.containsKey('genres'), isFalse);
      expect(query.containsKey('sfw'), isFalse, reason: 'Jikan includes adult entries unless sfw=true');
    });

    test('the screen\'s default Popularity/Desc sort becomes order_by=popularity&sort=desc', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('jikan_anime.json')))];

      await repository.performAnimeAdvancedSearch('', <String>[], null, null, null, null, 'POPULARITY_DESC', 1, malUser());

      final Map<String, String> query = wire.requests.single.url.queryParameters;
      expect(query['order_by'], 'popularity');
      expect(query['sort'], 'desc');
    });

    test('an unknown sort field or filter value is dropped instead of sent', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('jikan_anime.json')))];

      await repository.performAnimeAdvancedSearch('x', <String>[], null, 'NOPE', null, 'chilling', 'NOPE_DESC', 1, malUser());

      final Map<String, String> query = wire.requests.single.url.queryParameters;
      expect(query.containsKey('order_by'), isFalse);
      expect(query.containsKey('sort'), isFalse);
      expect(query.containsKey('type'), isFalse);
      expect(query.containsKey('status'), isFalse);
    });

    test('a non-2xx search answer degrades to an empty list', () async {
      wire.answers = <Object>[(400, '{"message":"bad request"}')];

      final List<Anime> results = await repository.performAnimeAdvancedSearch(
        'x', <String>[], null, null, null, null, 'SCORE_DESC', 1, malUser());

      expect(results, isEmpty);
    });

    test('the filter map is Jikan\'s vocabulary, with only the axes it filters', () async {
      final Map<String, (bool, List<String>)> filters =
          await repository.getUserAnimeAdvancedSearchFilters(malUser());

      expect(wire.requests, isEmpty, reason: 'the vocabularies are static');
      expect(filters['genres']!.$2, MalMetadataVocabularies.animeGenreNames);
      expect(filters['formats']!.$2, containsAll(<String>['TV', 'Movie', 'OVA']));
      expect(filters['airingStatuses']!.$2, <String>['Airing', 'Finished', 'Upcoming']);
      expect(filters['sortOptions']!.$2, containsAll(<String>['Score', 'Members', 'Start Date', 'End Date']));
      expect(filters['sortOrders']!.$1, isFalse, reason: 'the direction rides the sort string');
      expect(filters.containsKey('ratings'), isFalse, reason: 'the search UI never reads one; Jikan codes are not MAL\'s');
      expect(filters.containsKey('seasons'), isFalse, reason: 'Jikan /anime search cannot filter by season');
      expect(filters.containsKey('years'), isFalse);
    });
  });

  group('AnimeRepositoryMal covers', () {
    test('covers come from the popular ranking and empty images are dropped', () async {
      final Map<String, dynamic> payload = fixture('anime_ranking.json');
      final List<dynamic> data = payload['data'] as List<dynamic>;
      ((data.first as Map<String, dynamic>)['node'] as Map<String, dynamic>)['main_picture'] =
          <String, dynamic>{'medium': '', 'large': ''};
      wire.answers = <Object>[(200, jsonEncode(payload))];

      final List<String> covers = await repository.getMediaCoverImages(malUser(enableNsfwContent: true));

      expect(covers, hasLength(1), reason: 'the empty cover is dropped, the adult one is kept');
      expect(covers.single, 'https://cdn.myanimelist.net/images/anime/1/1l.jpg');
      expect(wire.requests.single.url.queryParameters['ranking_type'], 'bypopularity');
    });
  });

  group('AnimeRepositoryMal calendar', () {
    List<Object> weekAnswers() => <Object>[
          for (int i = 0; i < 7; i++) (200, jsonEncode(fixture('anime_schedule.json'))),
        ];

    test('fetches the seven Jikan weekday pages and buckets them by weekday', () async {
      wire.answers = weekAnswers();

      final Map<String, List<Anime>> calendar = await repository.getCalendarReleases(1, malUser());

      expect(wire.requests, hasLength(7));
      expect(
        wire.requests.map((RecordedMalRequest request) => request.url.host).toSet(),
        <String>{'api.jikan.moe'},
      );
      expect(
        wire.requests.map((RecordedMalRequest request) => request.url.queryParameters['filter']).toList(),
        <String>['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
      );
      for (final RecordedMalRequest request in wire.requests) {
        expect(request.url.path, '/v4/schedules');
        expect(request.url.queryParameters['limit'], '25');
        expect(request.url.queryParameters['page'], '1');
        expect(request.headers.containsKey('authorization'), isFalse);
      }

      expect(calendar.keys, <String>['Monday', 'Tuesday'], reason: 'chronological weekday buckets');
      expect(calendar['Monday'], hasLength(1), reason: 'the Rx entry is dropped while NSFW is off');
      final Anime bleach = calendar['Monday']!.single;
      expect(bleach.id, 269);
      expect(bleach.idMal, 269);
      expect(bleach.title.userPreferred, 'Bleach');
      expect(bleach.meanScore, 82);
      expect(bleach.startDate, '5/10/2004');
      expect(bleach.status, 'FINISHED');
      expect(bleach.format, 'TV');
      expect(bleach.isAdult, isFalse, reason: "Jikan's R-17+ prefix maps to rating=r");
      final Anime frieren = calendar['Tuesday']!.single;
      expect(frieren.status, 'FINISHED');
      expect(frieren.isAdult, isFalse);
    });

    test('NSFW on keeps adult entries and each day is sorted by broadcast time', () async {
      wire.answers = weekAnswers();

      final Map<String, List<Anime>> calendar = await repository.getCalendarReleases(1, malUser(enableNsfwContent: true));

      expect(calendar['Monday'], hasLength(2));
      expect(calendar['Monday']!.first.id, 9999, reason: '22:00 sorts before 23:30');
      expect(calendar['Monday']!.first.isAdult, isTrue);
      expect(calendar['Monday']!.last.id, 269);
    });

    test('page 2 is empty because the Jikan week is fetched whole', () async {
      expect(await repository.getCalendarReleases(2, malUser()), isEmpty);
      expect(wire.requests, isEmpty);
    });
  });
}

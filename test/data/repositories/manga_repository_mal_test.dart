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
import 'package:unyo/core/services/api/mal/mal_rate_limiter.dart';
import 'package:unyo/core/services/api/mal/mal_user_rate_service.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/data/repositories/manga_repository_mal.dart';
import 'package:unyo/data/repositories/user_repository_mal.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/media/title.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

import '../../core/services/api/shikimori/support/fake_rate_limiter_clock.dart';
import 'support/fake_mal_wire.dart';

/// Repository-level tests for [MangaRepositoryMal].
///
/// The real [MalUserRateService] runs under the repository (wire faked at the
/// `http.Client` boundary) — mirror of the anime repository suite, on the
/// manga kind and its chapter/volume counters.
void main() {
  late MalWireDouble wire;
  late FakeMalAuthService auth;
  late MockUserRepositoryMal userRepository;
  late MangaRepositoryMal repository;

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
    repository = MangaRepositoryMal();
  });

  Map<String, dynamic> fixture(String name) {
    return jsonDecode(File('test/data/fixtures/mal/$name').readAsStringSync()) as Map<String, dynamic>;
  }

  MalUserModel malUser() {
    return MalUserModel(
      id: '56789',
      name: 'tester',
      settings: SettingsModel.empty(),
      avatarImage: '',
      bannerImage: '',
      accessToken: 'stored-access',
      refreshToken: 'stored-refresh',
      accessTokenExpiresAt: '2099-01-01T00:00:00.000',
      profileUrl: '',
    );
  }

  Manga manga({int id = 30002}) {
    return MangaModel.empty().copyWith(
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
    int progressVolumes = 0,
    double score = 0,
    int repeat = 0,
    String status = 'CURRENT',
  }) {
    return MediaListEntryModel(
      progress: progress,
      progressVolumes: progressVolumes,
      score: score,
      repeat: repeat,
      status: status,
      startedAt: const <String>['~', '~', '~'],
      completedAt: const <String>['~', '~', '~'],
    );
  }

  group('MangaRepositoryMal list entries', () {
    test('getMediaListEntry passes the record id and the manga kind to MAL', () async {
      wire.answers = <Object>[
        (
          200,
          jsonEncode(<String, dynamic>{
            'id': 30002,
            'my_list_status': <String, dynamic>{
              'status': 'reading',
              'score': 7,
              'num_chapters_read': 12,
              'num_volumes_read': 2,
              'is_rereading': false,
              'num_times_reread': 1,
            },
          }),
        ),
      ];

      final MediaListEntry read = await repository.getMediaListEntry(manga(), malUser());

      expect(read.status, 'CURRENT');
      expect(read.progress, 12);
      expect(read.progressVolumes, 2);
      expect(read.score, 7);
      expect(read.repeat, 1);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.method, 'GET');
      expect(request.url.toString(), '${config.malApiBase}/manga/30002?fields=my_list_status');
      expect(request.headers['authorization'], 'Bearer stored-access');
    });

    test('updateMediaListEntry writes the manga counters, never the anime ones', () async {
      wire.answers = <Object>[
        (
          200,
          jsonEncode(<String, dynamic>{
            'status': 'reading',
            'score': 8,
            'num_chapters_read': 5,
            'num_volumes_read': 1,
            'is_rereading': false,
            'num_times_reread': 0,
          }),
        ),
      ];

      final MediaListEntry written = await repository.updateMediaListEntry(
        entry(progress: 5, progressVolumes: 1, score: 8),
        manga(),
        malUser(),
      );

      expect(written.progress, 5);
      expect(written.progressVolumes, 1);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.method, 'PUT');
      expect(request.url.toString(), '${config.malApiBase}/manga/30002/my_list_status');
      expect(request.headers['content-type'], contains('application/x-www-form-urlencoded'));
      expect(request.bodyFields['num_chapters_read'], '5');
      expect(request.bodyFields['num_volumes_read'], '1');
      expect(request.bodyFields.containsKey('num_watched_episodes'), isFalse);
      expect(request.bodyFields['status'], 'reading');
      expect(request.bodyFields['score'], '8');
    });

    test('a title with no list status reads as the empty entry', () async {
      wire.answers = <Object>[(200, jsonEncode(<String, dynamic>{'id': 30002, 'title': 'x'}))];

      final MediaListEntry read = await repository.getMediaListEntry(manga(), malUser());

      expect(read.status, MediaListEntryModel.empty().status);
    });

    test('an empty-status entry is the delete and returns the empty entry', () async {
      wire.answers = <Object>[(204, '')];

      final MediaListEntry written = await repository.updateMediaListEntry(
        MediaListEntryModel.empty(),
        manga(),
        malUser(),
      );

      expect(written.status, MediaListEntryModel.empty().status);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.method, 'DELETE');
      expect(request.url.toString(), '${config.malApiBase}/manga/30002/my_list_status');
    });

    test('a non-MyAnimeList account degrades to the empty entry without any request', () async {
      final MediaListEntry read = await repository.getMediaListEntry(manga(), UserModel.empty());
      final MediaListEntry written = await repository.updateMediaListEntry(
        entry(progress: 1),
        manga(),
        UserModel.empty(),
      );

      expect(read.status, MediaListEntryModel.empty().status);
      expect(written.status, MediaListEntryModel.empty().status);
      expect(wire.requests, isEmpty);
    });
  });

  group('MangaRepositoryMal browse lists', () {
    test('popular asks the MAL bypopularity ranking and maps the node, dropping adult titles', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('manga_list_popular.json')))];

      final (bool ok, List<Manga> mangas) = await repository.getPopularMangas(1, malUser());

      expect(ok, isTrue);
      expect(mangas, hasLength(1), reason: 'the ranking has no nsfw param, so nsfw:black is gated client-side');
      final RecordedMalRequest request = wire.requests.single;
      expect(request.method, 'GET');
      expect(request.url.path, '/v2/manga/ranking');
      final Map<String, String> query = request.url.queryParameters;
      expect(query['ranking_type'], 'bypopularity');
      expect(query['limit'], '50');
      expect(query['offset'], '0');
      expect(query['fields'], MalMetadataService.mangaListFields);
      expect(query.containsKey('nsfw'), isFalse, reason: 'the ranking endpoint has no nsfw parameter');
      expect(request.headers.containsKey('authorization'), isFalse);
      expect(request.headers['x-mal-client-id'], config.malClientId, reason: 'v2 403s without the public client id');

      expect(mangas.any((Manga manga) => manga.id == 2), isFalse, reason: 'Berserk is nsfw:black');

      final Manga chainsawMan = mangas.single;
      expect(chainsawMan.id, 116778);
      expect(chainsawMan.idMal, 116778);
      expect(chainsawMan.title.userPreferred, 'Chainsaw Man');
      expect(chainsawMan.chapters, 97);
      expect(chainsawMan.status, 'FINISHED');
      expect(chainsawMan.averageScore, 86);
      expect(chainsawMan.isAdult, isFalse);
      expect(chainsawMan.endDate, '14/12/2020');
    });

    test('NSFW on keeps the nsfw:black ranking entry and its mapped fields', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('manga_list_popular.json')))];

      final (bool ok, List<Manga> mangas) = await repository.getPopularMangas(
        1,
        malUser().copyWith(settings: SettingsModel.empty().copyWith(enableNsfwContent: true)),
      );

      expect(ok, isTrue);
      expect(mangas, hasLength(2));
      final Manga berserk = mangas.firstWhere((Manga manga) => manga.id == 2);
      expect(berserk.idMal, 2);
      expect(berserk.title.userPreferred, 'Berserk');
      expect(berserk.averageScore, 95, reason: 'mean 9.47 rides the 0-100 scale');
      expect(berserk.meanScore, 95);
      expect(berserk.startDate, '25/8/1989');
      expect(berserk.format, 'MANGA');
      expect(berserk.status, 'RELEASING');
      expect(berserk.genres, containsAll(<String>['Action', 'Seinen']));
      expect(berserk.chapters, 0);
      expect(berserk.isAdult, isTrue, reason: 'nsfw:black is MAL adult (manga has no rating field)');
      expect(berserk.coverImage, contains('157897l.jpg'));
      expect(berserk.countryOfOrigin, 'JP');
      expect(berserk.bannerImage, '');
    });

    test('the carousel page maps onto limit/offset', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('manga_list_popular.json')))];

      await repository.getPopularMangas(3, malUser());

      final Map<String, String> query = wire.requests.single.url.queryParameters;
      expect(query['limit'], '50');
      expect(query['offset'], '100');
    });

    test('trending asks Jikan for publishing titles ordered by members', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('jikan_manga.json')))];

      final (bool ok, List<Manga> mangas) = await repository.getTrendingMangas(1, malUser());

      expect(ok, isTrue);
      expect(mangas, hasLength(1), reason: 'the hentai entry is gated out with NSFW off');
      final RecordedMalRequest request = wire.requests.single;
      expect(request.url.host, 'api.jikan.moe');
      expect(request.url.path, '/v4/manga');
      final Map<String, String> query = request.url.queryParameters;
      expect(query['status'], 'publishing', reason: 'v2 /manga/ranking rejects ranking_type=publishing (400)');
      expect(query['order_by'], 'members');
      expect(query['sort'], 'desc');
      expect(query['page'], '1');
      expect(query['limit'], '${MangaRepositoryMal.jikanPageSize}');
      expect(query['sfw'], 'true');
      expect(request.headers.containsKey('x-mal-client-id'), isFalse, reason: 'Jikan is not a MAL host');

      final Manga berserk = mangas.single;
      expect(berserk.id, 2);
      expect(berserk.idMal, 2, reason: 'the MAL native id is identity addressing');
      expect(berserk.title.userPreferred, 'Berserk');
      expect(berserk.averageScore, 95, reason: '9.47 × 10 rounds to 95');
      expect(berserk.startDate, '25/8/1989', reason: 'manga dates come from published.from');
      expect(berserk.endDate, '0/0/0');
      expect(berserk.status, 'RELEASING', reason: 'Jikan prose "Publishing" folds to RELEASING');
      expect(berserk.genres, containsAll(<String>['Action', 'Horror']));
      expect(berserk.isAdult, isFalse);
      expect(berserk.coverImage, contains('157897l.jpg'));
    });

    test('recently completed asks Jikan for complete titles sorted by end date desc', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('jikan_manga.json')))];

      final (bool ok, List<Manga> mangas) = await repository.getRecentlyCompletedMangas(1, malUser());

      expect(ok, isTrue);
      final Map<String, String> query = wire.requests.single.url.queryParameters;
      expect(wire.requests.single.url.path, '/v4/manga');
      expect(query['status'], 'complete');
      expect(query['order_by'], 'end_date');
      expect(query['sort'], 'desc');
      expect(mangas.single.id, 2);
    });

    test('upcoming asks Jikan for upcoming titles sorted by start date asc', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('jikan_manga.json')))];

      await repository.getUpcomingMangas(1, malUser());

      final Map<String, String> query = wire.requests.single.url.queryParameters;
      expect(wire.requests.single.url.path, '/v4/manga');
      expect(query['status'], 'upcoming', reason: 'v2 /manga/ranking rejects ranking_type=upcoming (400)');
      expect(query['order_by'], 'start_date');
      expect(query['sort'], 'asc');
    });

    test('the NSFW setting drives sfw on the Jikan feeds and nsfw nowhere', () async {
      wire.answers = <Object>[
        (200, jsonEncode(fixture('jikan_manga.json'))),
        (200, jsonEncode(fixture('jikan_manga.json'))),
      ];

      await repository.getTrendingMangas(1, malUser());
      expect(wire.requests.first.url.queryParameters['sfw'], 'true');

      await repository.getTrendingMangas(
        1,
        malUser().copyWith(settings: SettingsModel.empty().copyWith(enableNsfwContent: true)),
      );
      expect(wire.requests.last.url.queryParameters.containsKey('sfw'), isFalse,
          reason: 'Jikan includes adult entries unless sfw=true');
    });

    test('a Jikan page N maps onto page and keeps the 25-entry cap', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('jikan_manga.json')))];

      await repository.getTrendingMangas(3, malUser());

      final Map<String, String> query = wire.requests.single.url.queryParameters;
      expect(query['page'], '3');
      expect(query['limit'], '${MangaRepositoryMal.jikanPageSize}');
    });

    test('a non-2xx browse answer degrades to (false, [])', () async {
      wire.answers = <Object>[(500, jsonEncode(<String, dynamic>{'error': 'server_error'}))];

      final (bool ok, List<Manga> mangas) = await repository.getPopularMangas(1, malUser());

      expect(ok, isFalse);
      expect(mangas, isEmpty);
      expect(wire.requests, hasLength(1));
    });
  });

  group('MangaRepositoryMal details', () {
    test('asks /v2/manga/{id} with the details fields and the account token', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('manga_details.json')))];

      final (bool ok, MangaDetails details) = await repository.getMangaDetails(manga(id: 2), malUser());

      expect(ok, isTrue);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.url.path, '/v2/manga/2');
      final String fields = request.url.queryParameters['fields']!;
      for (final String required in <String>[
        'my_list_status',
        'related_manga',
        'num_volumes',
        'num_chapters',
        'authors',
        'serialization',
        'alternative_titles',
        'main_picture',
        'start_date',
        'end_date',
        'synopsis',
        'mean',
        'media_type',
        'status',
        'nsfw',
      ]) {
        expect(fields, contains(required), reason: 'details fields must request $required');
      }
      expect(fields, MalMetadataService.mangaDetailsFields);
      expect(request.headers['authorization'], 'Bearer stored-access');

      expect(details.mediaListEntry.status, 'CURRENT');
      expect(details.mediaListEntry.progress, 120);
      expect(details.mediaListEntry.progressVolumes, 3);
      expect(details.mediaListEntry.score, 9);
      expect(details.mediaListEntry.repeat, 1);
      expect(details.characters, isEmpty, reason: 'MAL v2 carries no character data');

      expect(
        details.recommendedMangas.map((Manga manga) => manga.id).toList(),
        <int>[3009, 25515],
      );
      expect(details.recommendedMangas.first.title.romaji, 'Berserk (2016)');
      expect(details.recommendedMangas.first.idMal, 3009);
      expect(details.recommendedMangas.last.format, 'ONE_SHOT');
    });

    test('a non-MyAnimeList user reads details anonymously and gets the empty entry', () async {
      // MAL omits `my_list_status` on an anonymous read, so the payload here
      // mirrors that: the repository must not invent an entry.
      final Map<String, dynamic> payload = fixture('manga_details.json')..remove('my_list_status');
      wire.answers = <Object>[(200, jsonEncode(payload))];

      final (bool ok, MangaDetails details) = await repository.getMangaDetails(manga(id: 2), UserModel.empty());

      expect(ok, isTrue);
      expect(wire.requests.single.headers.containsKey('authorization'), isFalse);
      expect(details.mediaListEntry.status, MediaListEntryModel.empty().status);
      expect(details.recommendedMangas, hasLength(2));
    });

    test('a 404 degrades to an empty details model', () async {
      wire.answers = <Object>[(404, jsonEncode(<String, dynamic>{'error': 'not_found'}))];

      final (bool ok, MangaDetails details) = await repository.getMangaDetails(manga(id: 2), malUser());

      expect(ok, isFalse);
      expect(details.recommendedMangas, isEmpty);
      expect(details.characters, isEmpty);
      expect(details.mediaListEntry.status, MediaListEntryModel.empty().status);
    });

    test('a non-positive id skips the call', () async {
      final (bool ok, MangaDetails details) = await repository.getMangaDetails(manga(id: 0), malUser());

      expect(ok, isFalse);
      expect(details.recommendedMangas, isEmpty);
      expect(wire.requests, isEmpty);
    });
  });

  group('MangaRepositoryMal advanced search filters', () {
    test('returns Jikan\'s vocabularies in the Shikimori map shape', () async {
      final Map<String, (bool, List<String>)> filters =
          await repository.getUserMangaAdvancedSearchFilters(malUser());

      expect(filters['genres']!.$1, isTrue);
      expect(filters['genres']!.$2, containsAll(<String>['Action', 'Seinen', 'Shounen']));
      expect(filters['formats']!.$1, isTrue);
      expect(filters['formats']!.$2, containsAll(<String>['Manga', 'One Shot', 'Doujinshi']));
      expect(filters['airingStatuses']!.$2,
          <String>['Publishing', 'Finished', 'Upcoming', 'On Hiatus', 'Discontinued']);
      expect(filters['sortOptions']!.$2, containsAll(<String>['Score', 'Start Date']));
      expect(filters['countries']!.$1, isFalse, reason: 'neither MAL nor Jikan has a manga country filter');
      expect(filters['sortOrders']!.$1, isFalse, reason: 'the direction rides the sort string');
      expect(filters.containsKey('ratings'), isFalse, reason: 'manga has no rating filter on Jikan');
      for (final MapEntry<String, (bool, List<String>)> entry in filters.entries) {
        if (entry.value.$1) {
          expect(entry.value.$2, isNotEmpty, reason: '${entry.key} is enabled but has no options');
        }
      }
      expect(wire.requests, isEmpty);
    });
  });

  group('MangaRepositoryMal advanced search', () {
    test('maps q, genre ids, format, status and sort onto Jikan, and drops the country', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('jikan_manga.json')))];

      final List<Manga> results = await repository.performMangaAdvancedSearch(
        '  Berserk  ',
        <String>['Shounen', 'Action'],
        'One Shot',
        'Japan',
        'Publishing',
        'Score_Desc',
        2,
        malUser(),
      );

      expect(results, hasLength(1), reason: 'the hentai entry is dropped while NSFW is off');
      final RecordedMalRequest request = wire.requests.single;
      expect(request.url.host, 'api.jikan.moe');
      expect(request.url.path, '/v4/manga');
      final Map<String, String> query = request.url.queryParameters;
      expect(query['q'], 'Berserk');
      expect(query['genres'], '27,1', reason: 'genre labels become MAL/Jikan ids');
      expect(query['type'], 'oneshot', reason: "Jikan spells it without the underscore");
      expect(query['status'], 'publishing');
      expect(query['order_by'], 'score');
      expect(query['sort'], 'desc');
      expect(query['page'], '2');
      expect(query['limit'], '${MangaRepositoryMal.jikanPageSize}');
      expect(query['sfw'], 'true');
      expect(query.containsKey('country'), isFalse, reason: 'a country is not a Jikan filter');
      expect(query.containsKey('offset'), isFalse, reason: 'Jikan pages by page number');

      expect(results.single.id, 2);
      expect(results.single.idMal, 2);
      expect(results.single.title.userPreferred, 'Berserk');
      expect(results.single.averageScore, 95);
      expect(results.single.status, 'RELEASING');
    });

    test('accepts wire values, keeps empty filters off the wire and honours the NSFW setting', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('jikan_manga.json')))];

      await repository.performMangaAdvancedSearch(
        '',
        <String>[],
        'manga',
        null,
        null,
        'Start_Date_Asc',
        1,
        malUser().copyWith(settings: SettingsModel.empty().copyWith(enableNsfwContent: true)),
      );

      final Map<String, String> query = wire.requests.single.url.queryParameters;
      expect(query['type'], 'manga');
      expect(query['order_by'], 'start_date');
      expect(query['sort'], 'asc');
      expect(query.containsKey('q'), isFalse);
      expect(query.containsKey('status'), isFalse);
      expect(query.containsKey('genres'), isFalse);
      expect(query.containsKey('sfw'), isFalse, reason: 'Jikan includes adult entries unless sfw=true');
    });

    test('an unknown sort or filter value is dropped instead of guessed', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('jikan_manga.json')))];

      await repository.performMangaAdvancedSearch('', <String>[], 'Unknown Kind', null, 'Unknown Status', 'Name_Desc', 1, malUser());

      final Map<String, String> query = wire.requests.single.url.queryParameters;
      expect(query.containsKey('type'), isFalse);
      expect(query.containsKey('status'), isFalse);
      expect(query.containsKey('order_by'), isFalse);
      expect(query.containsKey('sort'), isFalse);
    });

    test('advanced search drops adult results while NSFW is off', () async {
      wire.answers = <Object>[
        (200, jsonEncode(fixture('jikan_manga.json'))),
        (200, jsonEncode(fixture('jikan_manga.json'))),
      ];

      final List<Manga> off = await repository.performMangaAdvancedSearch(
          '', <String>[], null, null, null, 'Score_Desc', 1, malUser());
      final List<Manga> on = await repository.performMangaAdvancedSearch(
        '',
        <String>[],
        null,
        null,
        null,
        'Score_Desc',
        1,
        malUser().copyWith(settings: SettingsModel.empty().copyWith(enableNsfwContent: true)),
      );

      expect(off.map((Manga manga) => manga.id), <int>[2]);
      expect(on, hasLength(2));
      expect(on.any((Manga manga) => manga.isAdult), isTrue);
    });
  });

  group('MangaRepositoryMal covers', () {
    test('cover images come from the popular ranking page', () async {
      wire.answers = <Object>[(200, jsonEncode(fixture('manga_list_popular.json')))];

      final List<String> covers = await repository.getMediaCoverImages(malUser());

      expect(covers, hasLength(1), reason: 'the nsfw:black entry is gated out and covers stay non-empty');
      expect(covers.every((String cover) => cover.isNotEmpty), isTrue);
      final RecordedMalRequest request = wire.requests.single;
      expect(request.url.path, '/v2/manga/ranking');
      expect(request.url.queryParameters['ranking_type'], 'bypopularity');
    });
  });
}


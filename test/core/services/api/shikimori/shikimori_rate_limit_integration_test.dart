// External dependencies
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/anime_cubit.dart';
import 'package:unyo/application/states/anime_state.dart';
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/notification/anime_genres_notifier.dart';
import 'package:unyo/core/notification/anime_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/api/shikimori/shikimori_rate_limiter.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/anime_repository_shikimori.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

import '../../../../data/repositories/support/fake_graphql_http_service.dart';
import 'support/fake_rate_limiter_clock.dart';
import 'support/recording_logger.dart';

class MockUserNotifier extends Mock implements UserNotifier {}

class MockAnimeNotifier extends Mock implements AnimeNotifier {}

class MockAnimeGenresNotifier extends Mock implements AnimeGenresNotifier {}

class MockMediaListNotifier extends Mock implements MediaListNotifier {}

class MockReloadNotifier extends Mock implements ReloadNotifier {}

/// WP #64 subpart (d): the home screen load, end to end, against the shared
/// Shikimori budget.
///
/// The five carousels of the home/anime screen ([AnimeCubit]) and the calendar
/// are fetched from the real [AnimeRepositoryShikimori] over the real
/// [GraphQLService], with only the HTTP boundary faked, so a request can only
/// reach the fake if the production call chain acquired from
/// [ShikimoriRateLimiter] first. The limiter runs on a fake clock, so the
/// 6-request startup load is proven to be spaced 200 ms apart in fake time
/// instead of sleeping a real second.
void main() {
  late FakeRateLimiterClock clock;
  late RecordingLogger logger;
  late FakeGraphQlHttpService transport;
  late ShikimoriUserModel user;

  Map<String, dynamic> fixture(String name) {
    return jsonDecode(File('test/data/fixtures/shikimori/$name').readAsStringSync()) as Map<String, dynamic>;
  }

  Object calendarPayload() {
    return jsonDecode(File('test/data/fixtures/shikimori/calendar.json').readAsStringSync()) as Object;
  }

  setUp(() async {
    await sl.reset();
    clock = FakeRateLimiterClock();
    logger = RecordingLogger();
    user = ShikimoriUserModel(
      id: '23456789',
      name: 'shikimori-tester',
      settings: SettingsModel.empty().copyWith(metadataService: Service.shikimori),
      avatarImage: '',
      bannerImage: '',
      accessToken: 'stored-access',
      refreshToken: 'stored-refresh',
      accessTokenExpiresAt: '2099-01-01T00:00:00.000',
      profileUrl: '',
    );

    final Map<String, dynamic> animes = fixture('animes_ongoing.json');
    transport = FakeGraphQlHttpService(
      animes,
      getPayload: calendarPayload(),
      payloadsByQueryMarker: <String, Map<String, dynamic>>{'query Animes(': animes},
    );

    sl.registerSingleton<Logger>(logger);
    sl.registerSingleton<HttpService>(transport);
    sl.registerLazySingleton<ShikimoriRateLimiter>(
      () => ShikimoriRateLimiter(clock: clock.now, wait: clock.wait, logger: logger),
    );
    sl.registerLazySingleton<GraphQLService>(
      () => GraphQLService(
        httpService: sl<HttpService>(),
        endpoint: config.shikimoriGraphQLEndpoint,
        rateLimiter: sl<ShikimoriRateLimiter>(),
      ),
      instanceName: config.shikimoriGraphQlService,
    );
  });

  test('the five carousels and the calendar share one 200 ms-spaced budget', () async {
    final AnimeRepositoryShikimori repository = AnimeRepositoryShikimori();
    final MockUserNotifier userNotifier = MockUserNotifier();
    final StreamController<User> users = StreamController<User>.broadcast();
    when(() => userNotifier.userStream).thenAnswer((_) => users.stream);
    final MockReloadNotifier reloadNotifier = MockReloadNotifier();
    when(() => reloadNotifier.reloadStream).thenAnswer((_) => const Stream<ReloadType>.empty());

    final AnimeCubit cubit = AnimeCubit(
      repository,
      userNotifier,
      MockAnimeNotifier(),
      MockAnimeGenresNotifier(),
      MockMediaListNotifier(),
      reloadNotifier,
    );

    final Future<AnimeState> loaded = cubit.stream.firstWhere((AnimeState state) => state.userLoaded);
    users.add(user);
    final AnimeState state = await loaded;

    expect(state.recentlyReleased.$2, isNotEmpty);
    expect(state.trending.$2, isNotEmpty);
    expect(state.popular.$2, isNotEmpty);
    expect(state.recentlyCompleted.$2, isNotEmpty);
    expect(state.upcoming.$2, isNotEmpty);

    final Map<String, List<Anime>> calendar = await repository.getCalendarReleases(1, user);
    expect(calendar.values.expand((List<Anime> day) => day), isNotEmpty);

    final ShikimoriRateLimiter limiter = sl<ShikimoriRateLimiter>();
    expect(transport.calls, 6, reason: 'five carousels + one calendar call');
    expect(
      limiter.totalGrants,
      transport.calls,
      reason: 'every Shikimori request must take a grant from the one shared budget',
    );
    expect(
      clock.waited,
      const Duration(milliseconds: 1000),
      reason: 'five waits of 200 ms between the six grants',
    );
    // A delayed request leaves a DEBUG line a runtime drive can grep for.
    final List<String> delays = logger.debugLines
        .where((String line) => line.contains('Shikimori request delayed'))
        .toList();
    expect(delays, hasLength(5), reason: 'one delay line per queued request');
    expect(delays.every((String line) => line.contains('delayed by 200 ms')), isTrue);

    await cubit.close();
    await users.close();
  });
}

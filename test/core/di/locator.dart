import 'package:get_it/get_it.dart';
import 'package:unyo_lib/aniyomi_bridge.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unyo/application/cubits/anime_advanced_search_cubit.dart';
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/notification/anime_genres_notifier.dart';
import 'package:unyo/core/notification/anime_notifier.dart';
import 'package:unyo/core/notification/manga_genres_notifier.dart';
import 'package:unyo/core/notification/manga_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/menu_bar_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/notification/video_info_notifier.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/api/http/response_cache_scope.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/core/services/torrent/torrent_service.dart';
import 'package:unyo/core/theme/color_image_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/repositories/anime_repository_anilist.dart';
import 'package:unyo/data/repositories/episode_repository_anizip.dart';
import 'package:unyo/data/repositories/manga_repository_anilist.dart';
import 'package:unyo/data/repositories/repositories.dart';
import 'package:unyo/core/factories/anime_repository_factory.dart';
import 'package:unyo/core/factories/manga_repository_factory.dart';
import 'package:unyo/core/factories/user_repository_factory.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';
import 'package:unyo/domain/repositories/user_repository.dart';
import 'package:unyo/domain/repositories/media_id_cache.dart';
import 'package:unyo/core/services/media/media_id_service.dart';

// DartRX Notifiers
class MockUserNotifier extends Mock implements UserNotifier {}
class MockAnimeNotifier extends Mock implements AnimeNotifier {}
class MockAnimeGenresNotifier extends Mock implements AnimeGenresNotifier {}
class MockMediaListNotifier extends Mock implements MediaListNotifier {}
class MockMenuBarNotifier extends Mock implements MenuBarNotifier {}
class MockMangaNotifier extends Mock implements MangaNotifier {}
class MockMangaGenresNotifier extends Mock implements MangaGenresNotifier {}
class MockVideoInfoNotifier extends Mock implements VideoInfoNotifier {}
// Services
class MockLogger extends Mock implements Logger {}
class MockGraphQLService extends Mock implements GraphQLService {
  final HttpService httpService;
  final String endpoint;
  MockGraphQLService({required this.httpService, required this.endpoint});
}
class MockAppEffectHandler extends Mock implements AppEffectHandler {}
class MockThemeService extends Mock implements ThemeService {}
class MockColorImageService extends Mock implements ColorImageService {}
class MockAniyomiBridge extends Mock implements AniyomiBridge {}
class MockTorrentService extends Mock implements TorrentService {}
// Repositories
class MockUserRepositoryLocal extends Mock implements UserRepositoryLocal {}
class MockUserRepositoryAnilist extends Mock implements UserRepositoryAnilist {
  final UserNotifier newUserNotifier;
  final UserNotifier loggedUserNotifier;
  MockUserRepositoryAnilist(this.newUserNotifier, this.loggedUserNotifier);
}
class MockEpisodeRepositoryAnizip extends Mock implements EpisodeRepositoryAnizip {}
class MockMangaRepositoryAnilist extends Mock implements MangaRepositoryAnilist {}
class MockAnimeRepositoryAnilist extends Mock implements AnimeRepositoryAnilist {}


final sl = GetIt.instance;

Future<void> setupTestLocator() async{
  sl.reset();
  // Singletons
  sl.registerSingleton<Logger>(MockLogger());

  // Services - use real instances for non-mocked services
  sl.registerLazySingleton<ResponseCacheScope>(() => ResponseCacheScope());
  sl.registerLazySingleton<HttpService>(() => HttpService());
  sl.registerLazySingleton<GraphQLService>(
    () => MockGraphQLService(httpService: sl<HttpService>(), endpoint: config.anilistGraphQLEndpoint),
    instanceName: config.anilistGraphQlService,
  );
  sl.registerLazySingleton<AppEffectHandler>(() => MockAppEffectHandler());
  sl.registerSingleton<ThemeService>(MockThemeService());
  sl.registerLazySingleton<ColorImageService>(() => MockColorImageService());
  sl.registerSingleton<AniyomiBridge>(MockAniyomiBridge());
  sl.registerSingleton<TorrentService>(MockTorrentService());

  // Notifiers - Register mocks as singletons
  sl.registerSingleton<UserNotifier>(MockUserNotifier(), instanceName: config.loggedUserNotifier);
  sl.registerSingleton<UserNotifier>(MockUserNotifier(), instanceName: config.newUserNotifier);
  sl.registerLazySingleton<MenuBarNotifier>(() => MockMenuBarNotifier());
  sl.registerSingleton<AnimeNotifier>(MockAnimeNotifier());
  sl.registerLazySingleton<MangaNotifier>(() => MockMangaNotifier());
  sl.registerSingleton<AnimeGenresNotifier>(MockAnimeGenresNotifier());
  sl.registerLazySingleton<MangaGenresNotifier>(() => MockMangaGenresNotifier());
  sl.registerSingleton<MediaListNotifier>(MockMediaListNotifier());
  sl.registerLazySingleton<VideoInfoNotifier>(() => MockVideoInfoNotifier());

  // Repositories - Register mocks as singletons
  sl.registerLazySingleton<UserRepositoryLocal>(() => MockUserRepositoryLocal());
  sl.registerLazySingleton<UserRepositoryAnilist>(
    () => MockUserRepositoryAnilist(
      sl<UserNotifier>(instanceName: config.newUserNotifier),
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
    ),
  );
  sl.registerSingleton<AnimeRepositoryAnilist>(MockAnimeRepositoryAnilist());
  sl.registerLazySingleton<MangaRepositoryAnilist>(() => MockMangaRepositoryAnilist());
  sl.registerLazySingleton<AnimeRepository>(() => AnimeRepositoryFactory());
  sl.registerLazySingleton<MangaRepository>(() => MangaRepositoryFactory());
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryFactory());
  sl.registerLazySingleton<EpisodeRepositoryAnizip>(() => MockEpisodeRepositoryAnizip());
  sl.registerLazySingleton<MediaIdService>(() => MediaIdService(cache: InMemoryMediaIdCache()));

  // Cubits / Blocs - Register factories that create real cubits with mocked dependencies
  sl.registerFactory<AnimeAdvancedSearchCubit>(
        () => AnimeAdvancedSearchCubit(
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
      sl<MediaListNotifier>(),
      sl<AnimeNotifier>(),
      sl<AnimeGenresNotifier>(),
      sl<AnimeRepository>(),
    ),
  );
}
// External dependencies
import 'package:cast/cast.dart';
import 'package:unyo_lib/aniyomi_bridge.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/app_support_dir.dart';
import 'package:unyo/application/cubits/anime_advanced_search_cubit.dart';
import 'package:unyo/application/cubits/extensions_cubit.dart';
import 'package:unyo/application/cubits/manga_advanced_search_cubit.dart';
import 'package:unyo/application/cubits/manga_details_cubit.dart';
import 'package:unyo/application/cubits/settings_cubit.dart';
import 'package:unyo/application/cubits/video_cubit.dart';
import 'package:unyo/application/cubits/anime_cubit.dart';
import 'package:unyo/application/cubits/anime_details_cubit.dart';
import 'package:unyo/application/cubits/calendar_cubit.dart';
import 'package:unyo/application/cubits/manga_cubit.dart';
import 'package:unyo/application/cubits/media_list_cubit.dart';
import 'package:unyo/application/cubits/tabs_cubit.dart';
import 'package:unyo/application/cubits/login_cubit.dart';
import 'package:unyo/core/log/logger.dart';
import 'package:unyo/core/notification/anime_genres_notifier.dart';
import 'package:unyo/core/notification/anime_notifier.dart';
import 'package:unyo/core/notification/episode_info_notifier.dart';
import 'package:unyo/core/notification/episodes_notifier.dart';
import 'package:unyo/core/notification/extension_notifier.dart';
import 'package:unyo/core/notification/manga_genres_notifier.dart';
import 'package:unyo/core/notification/manga_notifier.dart';
import 'package:unyo/core/notification/media_list_entry_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/menu_bar_notifier.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/notification/video_info_notifier.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/api/http/response_cache_scope.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/core/services/api/shikimori/shikimori_auth_service.dart';
import 'package:unyo/core/services/api/shikimori/shikimori_rate_limiter.dart';
import 'package:unyo/core/services/api/shikimori/shikimori_user_rate_service.dart';
import 'package:unyo/core/services/settings/settings_service.dart';
import 'package:unyo/core/services/torrent/torrent_service.dart';
import 'package:unyo/core/services/update/app_version_provider.dart';
import 'package:unyo/core/services/update/update_checker_service.dart';
import 'package:unyo/core/factories/anime_repository_factory.dart';
import 'package:unyo/core/factories/episode_repository_factory.dart';
import 'package:unyo/core/factories/manga_repository_factory.dart';
import 'package:unyo/core/factories/user_repository_factory.dart';
import 'package:unyo/core/theme/color_image_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/repositories/anime_repository_anilist.dart';
import 'package:unyo/data/repositories/media_mapping_repository_anizip.dart';
import 'package:unyo/data/repositories/media_id_cache_hive.dart';
import 'package:unyo/data/repositories/media_mapping_repository_shikimori.dart';
import 'package:unyo/data/repositories/episode_repository_anizip.dart';
import 'package:unyo/data/repositories/extension_repository_aniyomi.dart';
import 'package:unyo/data/repositories/manga_repository_anilist.dart';
import 'package:unyo/data/repositories/repositories.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/domain/repositories/episode_repository.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';
import 'package:unyo/domain/repositories/user_repository.dart';
import 'package:unyo/domain/repositories/media_id_cache.dart';
import 'package:unyo/core/services/media/media_id_service.dart';
import 'package:unyo/core/services/video/video_display_mode_store.dart';
import 'package:unyo/application/cubits/home_cubit.dart';

final sl = GetIt.instance;

void setupLocator() async{
  // Singletons
  sl.registerSingletonAsync<Directory>(
    () => resolveAppSupportDir(
      environment: Platform.environment,
      fallback: getApplicationSupportDirectory,
    ),
    instanceName: config.applicationSupportDirectory,
  );
  await sl.isReady<Directory>(instanceName: config.applicationSupportDirectory);
  sl.registerSingleton<Logger>(getLogger());
  // Services
  sl.registerLazySingleton<ResponseCacheScope>(() => ResponseCacheScope());
  sl.registerLazySingleton<HttpService>(() => HttpService());
  sl.registerLazySingleton<GraphQLService>(
    () => GraphQLService(httpService: sl<HttpService>(), endpoint: config.anilistGraphQLEndpoint),
    instanceName: config.anilistGraphQlService,
  );
  sl.registerLazySingleton<ShikimoriRateLimiter>(() => ShikimoriRateLimiter());
  sl.registerLazySingleton<GraphQLService>(
    () => GraphQLService(
      httpService: sl<HttpService>(),
      endpoint: config.shikimoriGraphQLEndpoint,
      // One budget instance for every Shikimori request in the app, GraphQL
      // and REST alike (WP #64 subpart (d)).
      rateLimiter: sl<ShikimoriRateLimiter>(),
    ),
    instanceName: config.shikimoriGraphQlService,
  );
  sl.registerLazySingleton<ShikimoriAuthService>(() => ShikimoriAuthService());
  sl.registerLazySingleton<ShikimoriUserRateService>(() => ShikimoriUserRateService());
  sl.registerLazySingleton<AppEffectHandler>(() => AppEffectHandler());
  sl.registerLazySingleton<AppVersionProvider>(() => const AppVersionProvider());
  sl.registerLazySingleton<UpdateCheckerService>(
    () => UpdateCheckerService(httpService: sl<HttpService>()),
  );
  sl.registerLazySingleton<ColorImageService>(() => ColorImageService());
  sl.registerSingleton<AniyomiBridge>(AniyomiBridge());
  sl.registerSingleton<TorrentService>(TorrentService());
  sl.registerLazySingleton<CastDiscoveryService>(() => CastDiscoveryService());
  sl.registerSingleton<SettingsService>(SettingsService());
  // Notifiers
  sl.registerLazySingleton<UserNotifier>(() => UserNotifier(), instanceName: config.loggedUserNotifier);
  sl.registerLazySingleton<UserNotifier>(() => UserNotifier(), instanceName: config.newUserNotifier);
  sl.registerLazySingleton<MenuBarNotifier>(() => MenuBarNotifier());
  sl.registerLazySingleton<AnimeNotifier>(() => AnimeNotifier());
  sl.registerLazySingleton<MangaNotifier>(() => MangaNotifier());
  sl.registerLazySingleton<AnimeGenresNotifier>(() => AnimeGenresNotifier());
  sl.registerLazySingleton<MangaGenresNotifier>(() => MangaGenresNotifier());
  sl.registerLazySingleton<MediaListNotifier>(() => MediaListNotifier());
  sl.registerLazySingleton<VideoInfoNotifier>(() => VideoInfoNotifier());
  sl.registerLazySingleton<EpisodesInfoNotifier>(() => EpisodesInfoNotifier());
  sl.registerLazySingleton<MediaListEntryNotifier>(() => MediaListEntryNotifier());
  sl.registerLazySingleton<ExtensionNotifier>(() => ExtensionNotifier());
  sl.registerLazySingleton<EpisodesNotifier>(() => EpisodesNotifier());
  sl.registerLazySingleton<ReloadNotifier>(() => ReloadNotifier());
  // Repositories
  sl.registerLazySingleton<UserRepositoryLocal>(() => UserRepositoryLocal());
  sl.registerLazySingleton<UserRepositoryAnilist>(
    () => UserRepositoryAnilist(
      sl<UserNotifier>(instanceName: config.newUserNotifier),
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
    ),
  );
  sl.registerLazySingleton<UserRepositoryShikimori>(
    () => UserRepositoryShikimori(
      sl<UserNotifier>(instanceName: config.newUserNotifier),
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
    ),
  );
  sl.registerSingleton<ThemeService>(ThemeService(
    sl<UserRepositoryAnilist>(),
    sl<UserRepositoryLocal>(),
  ));
  sl.registerLazySingleton<VideoDisplayModeStore>(
    () => VideoDisplayModeStore(
      sl<UserRepositoryAnilist>(),
      sl<UserRepositoryLocal>(),
    ),
  );
  sl.registerLazySingleton<AnimeRepositoryAnilist>(() => AnimeRepositoryAnilist());
  sl.registerLazySingleton<MangaRepositoryAnilist>(() => MangaRepositoryAnilist());
  sl.registerLazySingleton<AnimeRepositoryShikimori>(() => AnimeRepositoryShikimori());
  sl.registerLazySingleton<MangaRepositoryShikimori>(() => MangaRepositoryShikimori());
  sl.registerLazySingleton<AnimeRepository>(() => AnimeRepositoryFactory());
  sl.registerLazySingleton<MangaRepository>(() => MangaRepositoryFactory());
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryFactory());
  sl.registerLazySingleton<EpisodeRepositoryAnizip>(() => EpisodeRepositoryAnizip());
  // Multi-provider mapping (WP #61): Hive-backed MAL pivot cache + provider legs.
  sl.registerLazySingleton<MediaIdCache>(() => HiveMediaIdCache());
  sl.registerLazySingleton<MediaMappingRepositoryAnizip>(() => MediaMappingRepositoryAnizip());
  sl.registerLazySingleton<MediaMappingRepositoryShikimori>(() => MediaMappingRepositoryShikimori());
  sl.registerLazySingleton<MediaIdService>(
    () => MediaIdService(
      cache: sl<MediaIdCache>(),
      aniZipLookup: sl<MediaMappingRepositoryAnizip>(),
      mappingLookup: sl<MediaMappingRepositoryShikimori>(),
    ),
  );
  sl.registerLazySingleton<EpisodeRepository>(() => EpisodeRepositoryFactory());
  registerApplicationCubits(sl);
}

/// Registers every cubit factory. Kept separate from [setupLocator] so tests can
/// build cubits against a container of overrides without editing this list.
void registerApplicationCubits(GetIt registry) {
  // Cubits / Blocs
  registry.registerFactory<LoginCubit>(
    () => LoginCubit(
      registry<UserRepositoryLocal>(),
      registry<UserNotifier>(instanceName: config.loggedUserNotifier),
      registry<UserNotifier>(instanceName: config.newUserNotifier),
      registry<UserRepositoryAnilist>(),
      registry<UserRepositoryShikimori>(),
      registry<ColorImageService>(),
      registry<ThemeService>(),
    ),
  );
  registry.registerFactory<HomeCubit>(
    () => HomeCubit(
      registry<UserNotifier>(instanceName: config.loggedUserNotifier),
      registry<AnimeNotifier>(),
      registry<MangaNotifier>(),
      registry<MediaListNotifier>(),
      registry<UserRepository>(),
      registry<AnimeRepository>(),
      registry<MenuBarNotifier>(),
      registry<ReloadNotifier>(),
    ),
  );
  registry.registerFactory<TabsCubit>(
    () => TabsCubit(
      registry<ThemeService>(),
      registry<UserNotifier>(instanceName: config.loggedUserNotifier),
      registry<MenuBarNotifier>(),
      registry<UpdateCheckerService>(),
      registry<AppVersionProvider>(),
    ),
  );
  registry.registerFactory<AnimeCubit>(
    () => AnimeCubit(
      registry<AnimeRepository>(),
      registry<UserNotifier>(instanceName: config.loggedUserNotifier),
      registry<AnimeNotifier>(),
      registry<AnimeGenresNotifier>(),
      registry<MediaListNotifier>(),
      registry<ReloadNotifier>(),
    ),
  );
  registry.registerFactory<MangaCubit>(
    () => MangaCubit(
      registry<MangaRepository>(),
      registry<UserNotifier>(instanceName: config.loggedUserNotifier),
      registry<MangaNotifier>(),
      registry<MangaGenresNotifier>(),
      registry<MediaListNotifier>(),
      registry<ReloadNotifier>(),
    ),
  );
  registry.registerFactory<ExtensionsCubit>(
    () => ExtensionsCubit(
      registry<ExtensionRepositoryAniyomi>(),
      registry<UserNotifier>(instanceName: config.loggedUserNotifier),
    ),
  );
  registry.registerFactory<MediaListCubit>(
    () => MediaListCubit(
      registry<UserNotifier>(instanceName: config.loggedUserNotifier),
      registry<UserRepository>(),
      registry<AnimeNotifier>(),
      registry<MangaNotifier>(),
      registry<MediaListNotifier>(),
    ),
  );
  registry.registerFactory<CalendarCubit>(
    () => CalendarCubit(
      registry<AnimeRepository>(),
      registry<UserNotifier>(instanceName: config.loggedUserNotifier),
      registry<AnimeNotifier>(),
      registry<MediaListNotifier>(),
    ),
  );
  registry.registerFactory<AnimeDetailsCubit>(
    () => AnimeDetailsCubit(
      registry<AnimeRepository>(),
      registry<EpisodeRepository>(),
      registry<UserNotifier>(instanceName: config.loggedUserNotifier),
      registry<AnimeNotifier>(),
      registry<AnimeGenresNotifier>(),
      registry<MediaListNotifier>(),
      registry<VideoInfoNotifier>(),
      registry<ExtensionRepositoryAniyomi>(),
      registry<UserRepository>(),
      registry<EpisodesInfoNotifier>(),
      registry<MediaListEntryNotifier>(),
      registry<ExtensionNotifier>(),
      registry<EpisodesNotifier>(),
      registry<ReloadNotifier>(),
      registry<MediaIdService>(),
    ),
  );
  registry.registerFactory<MangaDetailsCubit>(
    () => MangaDetailsCubit(
      registry<MangaRepository>(),
      registry<UserNotifier>(instanceName: config.loggedUserNotifier),
      registry<MangaNotifier>(),
      registry<MangaGenresNotifier>(),
      registry<MediaListNotifier>(),
      registry<ExtensionRepositoryAniyomi>(),
      registry<UserRepository>(),
    ),
  );
  registry.registerFactory<SettingsCubit>(
    () => SettingsCubit(
      registry<UserRepository>(),
      registry<UserRepositoryLocal>(),
      registry<UserNotifier>(instanceName: config.loggedUserNotifier),
      registry<ReloadNotifier>(),
      registry<ThemeService>(),
      registry<ColorImageService>()
    ),
  );
  registry.registerFactory<AnimeAdvancedSearchCubit>(
    () => AnimeAdvancedSearchCubit(
      registry<UserNotifier>(instanceName: config.loggedUserNotifier),
      registry<MediaListNotifier>(),
      registry<AnimeNotifier>(),
      registry<AnimeGenresNotifier>(),
      registry<AnimeRepository>(),
    ),
  );
  registry.registerFactory<MangaAdvancedSearchCubit>(
    () => MangaAdvancedSearchCubit(
      registry<UserNotifier>(instanceName: config.loggedUserNotifier),
      registry<MediaListNotifier>(),
      registry<MangaNotifier>(),
      registry<MangaGenresNotifier>(),
      registry<MangaRepository>(),
    ),
  );
  registry.registerFactory<VideoCubit>(
          () => VideoCubit(
      registry<UserNotifier>(instanceName: config.loggedUserNotifier),
      registry<VideoInfoNotifier>(),
      registry<AnimeNotifier>(),
      registry<EpisodesInfoNotifier>(),
      registry<MediaListEntryNotifier>(),
      registry<ExtensionNotifier>(),
      registry<EpisodesNotifier>(),
      registry<ExtensionRepositoryAniyomi>(),
      registry<AnimeRepository>(),
      registry<ReloadNotifier>(),
      registry<VideoDisplayModeStore>(),
      castDiscoveryService: registry<CastDiscoveryService>(),
    )
  );
}

void setupLocatorAfterHiveInit() {
  sl.registerSingleton<ExtensionRepositoryAniyomi>(
    ExtensionRepositoryAniyomi(
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
    ),
  );
}

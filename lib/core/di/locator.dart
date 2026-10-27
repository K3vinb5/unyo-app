// External dependencies
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
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/core/services/settings/settings_service.dart';
import 'package:unyo/core/services/torrent/torrent_service.dart';
import 'package:unyo/core/factories/anime_repository_factory.dart';
import 'package:unyo/core/factories/episode_repository_factory.dart';
import 'package:unyo/core/factories/manga_repository_factory.dart';
import 'package:unyo/core/factories/user_repository_factory.dart';
import 'package:unyo/core/theme/color_image_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/repositories/anime_repository_anilist.dart';
import 'package:unyo/data/repositories/episode_repository_anizip.dart';
import 'package:unyo/data/repositories/extension_repository_aniyomi.dart';
import 'package:unyo/data/repositories/manga_repository_anilist.dart';
import 'package:unyo/data/repositories/repositories.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/domain/repositories/episode_repository.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';
import 'package:unyo/domain/repositories/user_repository.dart';
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
  sl.registerLazySingleton<HttpService>(() => HttpService());
  sl.registerLazySingleton<GraphQLService>(
    () => GraphQLService(httpService: sl<HttpService>(), endpoint: config.anilistGraphQLEndpoint),
    instanceName: config.anilistGraphQlService,
  );
  sl.registerLazySingleton<GraphQLService>(
    () => GraphQLService(httpService: sl<HttpService>(), endpoint: config.shikimoriGraphQLEndpoint),
    instanceName: config.shikimoriGraphQlService,
  );
  sl.registerLazySingleton<AppEffectHandler>(() => AppEffectHandler());
  sl.registerLazySingleton<ColorImageService>(() => ColorImageService());
  sl.registerSingleton<AniyomiBridge>(AniyomiBridge());
  sl.registerSingleton<TorrentService>(TorrentService());
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
  sl.registerSingleton<ThemeService>(ThemeService(
    sl<UserRepositoryAnilist>(),
    sl<UserRepositoryLocal>(),
  ));
  sl.registerLazySingleton<AnimeRepositoryAnilist>(() => AnimeRepositoryAnilist());
  sl.registerLazySingleton<MangaRepositoryAnilist>(() => MangaRepositoryAnilist());
  sl.registerLazySingleton<AnimeRepositoryShikimori>(() => AnimeRepositoryShikimori());
  sl.registerLazySingleton<MangaRepositoryShikimori>(() => MangaRepositoryShikimori());
  sl.registerLazySingleton<AnimeRepository>(() => AnimeRepositoryFactory());
  sl.registerLazySingleton<MangaRepository>(() => MangaRepositoryFactory());
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryFactory());
  sl.registerLazySingleton<EpisodeRepositoryAnizip>(() => EpisodeRepositoryAnizip());
  sl.registerLazySingleton<EpisodeRepository>(() => EpisodeRepositoryFactory());
  // Cubits / Blocs
  sl.registerFactory<LoginCubit>(
    () => LoginCubit(
      sl<UserRepositoryLocal>(),
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
      sl<UserNotifier>(instanceName: config.newUserNotifier),
      sl<UserRepositoryAnilist>(),
      sl<ColorImageService>(),
      sl<ThemeService>(),
    ),
  );
  sl.registerFactory<HomeCubit>(
    () => HomeCubit(
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
      sl<AnimeNotifier>(),
      sl<MangaNotifier>(),
      sl<MediaListNotifier>(),
      sl<UserRepository>(),
      sl<AnimeRepository>(),
      sl<MenuBarNotifier>(),
      sl<ReloadNotifier>(),
    ),
  );
  sl.registerFactory<TabsCubit>(
    () => TabsCubit(sl<ThemeService>(), sl<UserNotifier>(instanceName: config.loggedUserNotifier), sl<MenuBarNotifier>()),
  );
  sl.registerFactory<AnimeCubit>(
    () => AnimeCubit(
      sl<AnimeRepository>(),
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
      sl<AnimeNotifier>(),
      sl<AnimeGenresNotifier>(),
      sl<MediaListNotifier>(),
      sl<ReloadNotifier>(),
    ),
  );
  sl.registerFactory<MangaCubit>(
    () => MangaCubit(
      sl<MangaRepository>(),
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
      sl<MangaNotifier>(),
      sl<MangaGenresNotifier>(),
      sl<MediaListNotifier>(),
      sl<ReloadNotifier>(),
    ),
  );
  sl.registerFactory<ExtensionsCubit>(
    () => ExtensionsCubit(
      sl<ExtensionRepositoryAniyomi>(),
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
    ),
  );
  sl.registerFactory<MediaListCubit>(
    () => MediaListCubit(
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
      sl<UserRepository>(),
      sl<AnimeNotifier>(),
      sl<MangaNotifier>(),
      sl<MediaListNotifier>(),
    ),
  );
  sl.registerFactory<CalendarCubit>(
    () => CalendarCubit(
      sl<AnimeRepository>(),
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
      sl<AnimeNotifier>(),
      sl<MediaListNotifier>(),
    ),
  );
  sl.registerFactory<AnimeDetailsCubit>(
    () => AnimeDetailsCubit(
      sl<AnimeRepository>(),
      sl<EpisodeRepository>(),
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
      sl<AnimeNotifier>(),
      sl<AnimeGenresNotifier>(),
      sl<MediaListNotifier>(),
      sl<VideoInfoNotifier>(),
      sl<ExtensionRepositoryAniyomi>(),
      sl<UserRepository>(),
      sl<EpisodesInfoNotifier>(),
      sl<MediaListEntryNotifier>(),
      sl<ExtensionNotifier>(),
      sl<EpisodesNotifier>(),
      sl<ReloadNotifier>(),
    ),
  );
  sl.registerFactory<MangaDetailsCubit>(
    () => MangaDetailsCubit(
      sl<MangaRepository>(),
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
      sl<MangaNotifier>(),
      sl<MangaGenresNotifier>(),
      sl<MediaListNotifier>(),
      sl<ExtensionRepositoryAniyomi>(),
      sl<UserRepository>(),
    ),
  );
  sl.registerFactory<SettingsCubit>(
    () => SettingsCubit(
      sl<UserRepository>(),
      sl<UserRepositoryLocal>(),
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
      sl<ReloadNotifier>(),
      sl<ThemeService>(),
      sl<ColorImageService>()
    ),
  );
  sl.registerFactory<AnimeAdvancedSearchCubit>(
    () => AnimeAdvancedSearchCubit(
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
      sl<MediaListNotifier>(),
      sl<AnimeNotifier>(),
      sl<AnimeGenresNotifier>(),
      sl<AnimeRepository>(),
    ),
  );
  sl.registerFactory<MangaAdvancedSearchCubit>(
    () => MangaAdvancedSearchCubit(
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
      sl<MediaListNotifier>(),
      sl<MangaNotifier>(),
      sl<MangaGenresNotifier>(),
      sl<MangaRepository>(),
    ),
  );
  sl.registerFactory<VideoCubit>(
          () => VideoCubit(
      sl<UserNotifier>(instanceName: config.loggedUserNotifier),
      sl<VideoInfoNotifier>(),
      sl<AnimeNotifier>(),
      sl<EpisodesInfoNotifier>(),
      sl<MediaListEntryNotifier>(),
      sl<ExtensionNotifier>(),
      sl<EpisodesNotifier>(),
      sl<ExtensionRepositoryAniyomi>(),
      sl<AnimeRepository>(),
      sl<ReloadNotifier>(),
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

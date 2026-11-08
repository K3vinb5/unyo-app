// External dependencies
import 'package:bloc/bloc.dart';
import 'package:cast/cast.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show registerApplicationCubits;
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
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/notification/video_info_notifier.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/api/http/response_cache_scope.dart';
import 'package:unyo/core/services/media/media_id_service.dart';
import 'package:unyo/core/services/update/app_version_provider.dart';
import 'package:unyo/core/services/update/update_check_result.dart';
import 'package:unyo/core/services/update/update_checker_service.dart';
import 'package:unyo/core/services/video/video_display_mode_store.dart';
import 'package:unyo/core/theme/color_image_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/repositories/extension_repository_aniyomi.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/data/repositories/user_repository_local.dart';
import 'package:unyo/data/repositories/user_repository_shikimori.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/episode_info.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/video_info.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/domain/repositories/episode_repository.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';
import 'package:unyo/domain/repositories/media_id_cache.dart';
import 'package:unyo/domain/repositories/user_repository.dart';
import 'package:unyo_lib/jmodels/jsepisode.dart';

import 'fakes.dart';

/// The one test DI entry point.
///
/// Every test starts from a clean [GetIt] container carrying only mocks (plus
/// the two genuinely pure services), then declares the overrides it needs:
///
/// ```dart
/// late TestDeps deps;
/// setUp(() async => deps = await TestDeps.setUp());
/// tearDown(TestDeps.tearDown);
///
/// final SettingsCubit cubit = deps.cubit<SettingsCubit>();
/// ```
///
/// The cubit factories come from [registerApplicationCubits], the same list
/// production uses, so **adding a cubit never requires editing test support**.
class TestDeps {
  TestDeps._(this._registry) {
    _registerDefaults();
    registerApplicationCubits(_registry);
  }

  final GetIt _registry;

  static Future<TestDeps> setUp({
    void Function(TestDeps deps)? overrides,
  }) async {
    await GetIt.instance.reset();
    final TestDeps deps = TestDeps._(GetIt.instance);
    overrides?.call(deps);
    return deps;
  }

  static Future<void> tearDown() => GetIt.instance.reset();

  /// Builds the cubit production would build, from this test's overrides.
  T cubit<T extends BlocBase<Object?>>() => _registry<T>();

  T get<T extends Object>({String? instanceName}) =>
      _registry<T>(instanceName: instanceName);

  /// Swaps a dependency for this test only.
  void replace<T extends Object>(T instance, {String? instanceName}) {
    if (_registry.isRegistered<T>(instanceName: instanceName)) {
      _registry.unregister<T>(instanceName: instanceName);
    }
    _registry.registerSingleton<T>(instance, instanceName: instanceName);
  }

  Logger get logger => get<Logger>();
  set logger(Logger value) => replace<Logger>(value);

  HttpService get httpService => get<HttpService>();
  set httpService(HttpService value) => replace<HttpService>(value);

  ResponseCacheScope get responseCacheScope => get<ResponseCacheScope>();
  set responseCacheScope(ResponseCacheScope value) =>
      replace<ResponseCacheScope>(value);

  ThemeService get themeService => get<ThemeService>();
  set themeService(ThemeService value) => replace<ThemeService>(value);

  ColorImageService get colorImageService => get<ColorImageService>();
  set colorImageService(ColorImageService value) =>
      replace<ColorImageService>(value);

  UserRepository get userRepository => get<UserRepository>();
  set userRepository(UserRepository value) => replace<UserRepository>(value);

  UserRepositoryLocal get userRepositoryLocal => get<UserRepositoryLocal>();
  set userRepositoryLocal(UserRepositoryLocal value) =>
      replace<UserRepositoryLocal>(value);

  AnimeRepository get animeRepository => get<AnimeRepository>();
  set animeRepository(AnimeRepository value) =>
      replace<AnimeRepository>(value);

  MangaRepository get mangaRepository => get<MangaRepository>();
  set mangaRepository(MangaRepository value) =>
      replace<MangaRepository>(value);

  ExtensionRepositoryAniyomi get extensionRepository =>
      get<ExtensionRepositoryAniyomi>();
  set extensionRepository(ExtensionRepositoryAniyomi value) =>
      replace<ExtensionRepositoryAniyomi>(value);

  VideoDisplayModeStore get videoDisplayModeStore =>
      get<VideoDisplayModeStore>();
  set videoDisplayModeStore(VideoDisplayModeStore value) =>
      replace<VideoDisplayModeStore>(value);

  UserNotifier get loggedUserNotifier =>
      get<UserNotifier>(instanceName: config.loggedUserNotifier);
  set loggedUserNotifier(UserNotifier value) {
    replace<UserNotifier>(value, instanceName: config.loggedUserNotifier);
    _stubUserStream(value);
  }

  UserNotifier get newUserNotifier =>
      get<UserNotifier>(instanceName: config.newUserNotifier);
  set newUserNotifier(UserNotifier value) {
    replace<UserNotifier>(value, instanceName: config.newUserNotifier);
    _stubUserStream(value);
  }

  ReloadNotifier get reloadNotifier => get<ReloadNotifier>();
  set reloadNotifier(ReloadNotifier value) {
    replace<ReloadNotifier>(value);
    _stubReloadStream(value);
  }

  AnimeNotifier get animeNotifier => get<AnimeNotifier>();
  set animeNotifier(AnimeNotifier value) {
    replace<AnimeNotifier>(value);
    when(() => value.animeStream).thenAnswer((_) => const Stream<Anime>.empty());
  }

  MangaNotifier get mangaNotifier => get<MangaNotifier>();
  set mangaNotifier(MangaNotifier value) {
    replace<MangaNotifier>(value);
    when(() => value.mangaStream).thenAnswer((_) => const Stream<Manga>.empty());
  }

  VideoInfoNotifier get videoInfoNotifier => get<VideoInfoNotifier>();
  set videoInfoNotifier(VideoInfoNotifier value) {
    replace<VideoInfoNotifier>(value);
    when(() => value.videoInfoStream).thenAnswer(
      (_) => const Stream<VideoInfo>.empty(),
    );
  }

  MediaListNotifier get mediaListNotifier => get<MediaListNotifier>();
  set mediaListNotifier(MediaListNotifier value) {
    replace<MediaListNotifier>(value);
    when(() => value.mediaListStream).thenAnswer((_) => const Stream<MediaList>.empty());
  }

  MenuBarNotifier get menuBarNotifier => get<MenuBarNotifier>();
  set menuBarNotifier(MenuBarNotifier value) {
    replace<MenuBarNotifier>(value);
    when(() => value.menuBarStream).thenAnswer(
      (_) => const Stream<bool>.empty(),
    );
  }

  AnimeGenresNotifier get animeGenresNotifier => get<AnimeGenresNotifier>();
  set animeGenresNotifier(AnimeGenresNotifier value) {
    replace<AnimeGenresNotifier>(value);
    when(() => value.animeGenreStream).thenAnswer(
      (_) => const Stream<String>.empty(),
    );
  }

  MangaGenresNotifier get mangaGenresNotifier => get<MangaGenresNotifier>();
  set mangaGenresNotifier(MangaGenresNotifier value) {
    replace<MangaGenresNotifier>(value);
    when(() => value.mangaGenreStream).thenAnswer(
      (_) => const Stream<String>.empty(),
    );
  }

  EpisodesInfoNotifier get episodesInfoNotifier =>
      get<EpisodesInfoNotifier>();
  set episodesInfoNotifier(EpisodesInfoNotifier value) {
    replace<EpisodesInfoNotifier>(value);
    when(() => value.episodeInfoStream).thenAnswer((_) => const Stream<List<EpisodeInfo>>.empty());
  }

  MediaListEntryNotifier get mediaListEntryNotifier =>
      get<MediaListEntryNotifier>();
  set mediaListEntryNotifier(MediaListEntryNotifier value) {
    replace<MediaListEntryNotifier>(value);
    when(() => value.mediaListEntryStream).thenAnswer(
      (_) => const Stream<MediaListEntry>.empty(),
    );
  }

  ExtensionNotifier get extensionNotifier => get<ExtensionNotifier>();
  set extensionNotifier(ExtensionNotifier value) {
    replace<ExtensionNotifier>(value);
    when(() => value.extensionStream).thenAnswer((_) => const Stream<Extension>.empty());
  }

  EpisodesNotifier get episodesNotifier => get<EpisodesNotifier>();
  set episodesNotifier(EpisodesNotifier value) {
    replace<EpisodesNotifier>(value);
    when(() => value.episodesStream).thenAnswer((_) => const Stream<List<JSEpisode>>.empty());
  }

  /// mDNS discovery is a boundary: the default test double finds nothing.
  MockCastDiscoveryService get castDiscovery => get<CastDiscoveryService>() as MockCastDiscoveryService;

  void _registerDefaults() {
    _registry.registerSingleton<Logger>(MockLogger());

    final MockUserNotifier loggedUser = MockUserNotifier();
    final MockUserNotifier newUser = MockUserNotifier();
    _stubUserStream(loggedUser);
    _stubUserStream(newUser);
    _registry.registerSingleton<UserNotifier>(
      loggedUser,
      instanceName: config.loggedUserNotifier,
    );
    _registry.registerSingleton<UserNotifier>(
      newUser,
      instanceName: config.newUserNotifier,
    );

    final MockReloadNotifier reload = MockReloadNotifier();
    _stubReloadStream(reload);
    _registry.registerSingleton<ReloadNotifier>(reload);

    final MockMenuBarNotifier menuBar = MockMenuBarNotifier();
    when(() => menuBar.menuBarStream).thenAnswer(
      (_) => const Stream<bool>.empty(),
    );
    _registry.registerSingleton<MenuBarNotifier>(menuBar);

    final MockAnimeNotifier anime = MockAnimeNotifier();
    when(() => anime.animeStream).thenAnswer((_) => const Stream<Anime>.empty());
    _registry.registerSingleton<AnimeNotifier>(anime);

    final MockMangaNotifier manga = MockMangaNotifier();
    when(() => manga.mangaStream).thenAnswer((_) => const Stream<Manga>.empty());
    _registry.registerSingleton<MangaNotifier>(manga);

    final MockAnimeGenresNotifier animeGenres = MockAnimeGenresNotifier();
    when(() => animeGenres.animeGenreStream).thenAnswer(
      (_) => const Stream<String>.empty(),
    );
    _registry.registerSingleton<AnimeGenresNotifier>(animeGenres);

    final MockMangaGenresNotifier mangaGenres = MockMangaGenresNotifier();
    when(() => mangaGenres.mangaGenreStream).thenAnswer(
      (_) => const Stream<String>.empty(),
    );
    _registry.registerSingleton<MangaGenresNotifier>(mangaGenres);

    final MockMediaListNotifier mediaList = MockMediaListNotifier();
    when(() => mediaList.mediaListStream).thenAnswer((_) => const Stream<MediaList>.empty());
    _registry.registerSingleton<MediaListNotifier>(mediaList);

    final MockVideoInfoNotifier videoInfo = MockVideoInfoNotifier();
    when(() => videoInfo.videoInfoStream).thenAnswer(
      (_) => const Stream<VideoInfo>.empty(),
    );
    _registry.registerSingleton<VideoInfoNotifier>(videoInfo);

    final MockEpisodesInfoNotifier episodesInfo = MockEpisodesInfoNotifier();
    when(() => episodesInfo.episodeInfoStream).thenAnswer(
      (_) => const Stream<List<EpisodeInfo>>.empty(),
    );
    _registry.registerSingleton<EpisodesInfoNotifier>(episodesInfo);

    final MockMediaListEntryNotifier mediaListEntry =
        MockMediaListEntryNotifier();
    when(() => mediaListEntry.mediaListEntryStream).thenAnswer(
      (_) => const Stream<MediaListEntry>.empty(),
    );
    _registry.registerSingleton<MediaListEntryNotifier>(mediaListEntry);

    final MockExtensionNotifier extension = MockExtensionNotifier();
    when(() => extension.extensionStream).thenAnswer((_) => const Stream<Extension>.empty());
    _registry.registerSingleton<ExtensionNotifier>(extension);

    final MockEpisodesNotifier episodes = MockEpisodesNotifier();
    when(() => episodes.episodesStream).thenAnswer((_) => const Stream<List<JSEpisode>>.empty());
    _registry.registerSingleton<EpisodesNotifier>(episodes);

    final MockUpdateCheckerService updateChecker = MockUpdateCheckerService();
    when(() => updateChecker.checkForUpdate(any())).thenAnswer(
      (_) async => const UpToDate(),
    );
    _registry.registerSingleton<UpdateCheckerService>(updateChecker);

    final MockAppVersionProvider versionProvider = MockAppVersionProvider();
    when(() => versionProvider.currentVersion()).thenAnswer((_) async => null);
    _registry.registerSingleton<AppVersionProvider>(versionProvider);

    _registry.registerSingleton<ResponseCacheScope>(ResponseCacheScope());
    _registry.registerSingleton<HttpService>(MockHttpService());
    _registry.registerSingleton<ThemeService>(MockThemeService());
    _registry.registerSingleton<ColorImageService>(MockColorImageService());
    _registry.registerSingleton<VideoDisplayModeStore>(MockVideoDisplayModeStore());
    _registry.registerSingleton<CastDiscoveryService>(_noCastDevices());

    _registry.registerSingleton<UserRepositoryLocal>(MockUserRepositoryLocal());
    _registry.registerSingleton<UserRepositoryAnilist>(
      MockUserRepositoryAnilist(),
    );
    _registry.registerSingleton<UserRepositoryShikimori>(
      MockUserRepositoryShikimori(),
    );
    _registry.registerSingleton<UserRepository>(MockUserRepository());
    _registry.registerSingleton<AnimeRepository>(MockAnimeRepository());
    _registry.registerSingleton<MangaRepository>(MockMangaRepository());
    _registry.registerSingleton<EpisodeRepository>(MockEpisodeRepository());
    _registry.registerSingleton<ExtensionRepositoryAniyomi>(
      MockExtensionRepositoryAniyomi(),
    );
    _registry.registerSingleton<MediaIdService>(
      MediaIdService(cache: InMemoryMediaIdCache()),
    );
  }

  static MockCastDiscoveryService _noCastDevices() {
    final MockCastDiscoveryService discovery = MockCastDiscoveryService();
    when(() => discovery.search()).thenAnswer((_) async => <CastDevice>[]);
    return discovery;
  }

  static void _stubUserStream(UserNotifier notifier) {
    when(() => notifier.userStream).thenAnswer(
      (_) => const Stream<User>.empty(),
    );
  }

  static void _stubReloadStream(ReloadNotifier notifier) {
    when(() => notifier.reloadStream).thenAnswer(
      (_) => const Stream<ReloadType>.empty(),
    );
  }
}

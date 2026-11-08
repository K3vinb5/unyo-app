// External dependencies
import 'package:cast/cast.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
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
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/update/app_version_provider.dart';
import 'package:unyo/core/services/update/update_checker_service.dart';
import 'package:unyo/core/services/video/video_display_mode_store.dart';
import 'package:unyo/core/theme/color_image_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/repositories/extension_repository_aniyomi.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/data/repositories/user_repository_local.dart';
import 'package:unyo/data/repositories/user_repository_shikimori.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/domain/repositories/episode_repository.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';
import 'package:unyo/domain/repositories/user_repository.dart';

/// Mock surface shared by the cubit/service tests. Defining them once here is
/// what keeps a new test from editing the production locator.
class MockLogger extends Mock implements Logger {}

class MockUserNotifier extends Mock implements UserNotifier {}

class MockAnimeNotifier extends Mock implements AnimeNotifier {}

class MockMangaNotifier extends Mock implements MangaNotifier {}

class MockAnimeGenresNotifier extends Mock implements AnimeGenresNotifier {}

class MockMangaGenresNotifier extends Mock implements MangaGenresNotifier {}

class MockMediaListNotifier extends Mock implements MediaListNotifier {}

class MockMenuBarNotifier extends Mock implements MenuBarNotifier {}

class MockVideoInfoNotifier extends Mock implements VideoInfoNotifier {}

class MockEpisodesInfoNotifier extends Mock implements EpisodesInfoNotifier {}

class MockMediaListEntryNotifier extends Mock implements MediaListEntryNotifier {}

class MockExtensionNotifier extends Mock implements ExtensionNotifier {}

class MockEpisodesNotifier extends Mock implements EpisodesNotifier {}

class MockReloadNotifier extends Mock implements ReloadNotifier {}

class MockHttpService extends Mock implements HttpService {}

class MockThemeService extends Mock implements ThemeService {}

class MockColorImageService extends Mock implements ColorImageService {}

class MockUpdateCheckerService extends Mock implements UpdateCheckerService {}

class MockAppVersionProvider extends Mock implements AppVersionProvider {}

class MockVideoDisplayModeStore extends Mock implements VideoDisplayModeStore {}

class MockUserRepository extends Mock implements UserRepository {}

class MockUserRepositoryLocal extends Mock implements UserRepositoryLocal {}

class MockUserRepositoryAnilist extends Mock implements UserRepositoryAnilist {}

class MockUserRepositoryShikimori extends Mock implements UserRepositoryShikimori {}

class MockAnimeRepository extends Mock implements AnimeRepository {}

class MockMangaRepository extends Mock implements MangaRepository {}

class MockEpisodeRepository extends Mock implements EpisodeRepository {}

class MockExtensionRepositoryAniyomi extends Mock
    implements ExtensionRepositoryAniyomi {}

class MockCastDiscoveryService extends Mock implements CastDiscoveryService {}

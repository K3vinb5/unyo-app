// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
// Internal dependencies
import 'package:unyo/application/cubits/anime_details_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/anime_details_state.dart';
import 'package:unyo/core/notification/anime_genres_notifier.dart';
import 'package:unyo/core/notification/anime_notifier.dart';
import 'package:unyo/core/notification/episode_info_notifier.dart';
import 'package:unyo/core/notification/episodes_notifier.dart';
import 'package:unyo/core/notification/extension_notifier.dart';
import 'package:unyo/core/notification/media_list_entry_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/notification/video_info_notifier.dart';
import 'package:unyo/data/repositories/extension_repository_aniyomi.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/domain/repositories/episode_repository.dart';
import '../../core/di/locator.dart' show setupTestLocator;

class MockBuildContext extends Mock implements BuildContext {}

class MockAnimeRepository extends Mock implements AnimeRepository {}
class MockEpisodeRepository extends Mock implements EpisodeRepository {}
class MockExtensionRepositoryAniyomi extends Mock implements ExtensionRepositoryAniyomi {}
class MockUserRepositoryAnilist extends Mock implements UserRepositoryAnilist {}

class MockUserNotifier extends Mock implements UserNotifier {}
class MockAnimeNotifier extends Mock implements AnimeNotifier {}
class MockAnimeGenresNotifier extends Mock implements AnimeGenresNotifier {}
class MockMediaListNotifier extends Mock implements MediaListNotifier {}
class MockVideoInfoNotifier extends Mock implements VideoInfoNotifier {}
class MockEpisodesInfoNotifier extends Mock implements EpisodesInfoNotifier {}
class MockMediaListEntryNotifier extends Mock implements MediaListEntryNotifier {}
class MockExtensionNotifier extends Mock implements ExtensionNotifier {}
class MockEpisodesNotifier extends Mock implements EpisodesNotifier {}
class MockReloadNotifier extends Mock implements ReloadNotifier {}

void main() {
  late AnimeDetailsCubit cubit;
  late MockAnimeRepository animeRepository;
  late MockEpisodeRepository episodeRepository;
  late MockExtensionRepositoryAniyomi extensionRepository;
  late MockUserRepositoryAnilist userRepository;
  late MockUserNotifier userNotifier;
  late MockAnimeNotifier animeNotifier;
  late MockAnimeGenresNotifier animeGenresNotifier;
  late MockMediaListNotifier mediaListNotifier;
  late MockVideoInfoNotifier videoInfoNotifier;
  late MockEpisodesInfoNotifier episodesInfoNotifier;
  late MockMediaListEntryNotifier mediaListEntryNotifier;
  late MockExtensionNotifier extensionNotifier;
  late MockEpisodesNotifier episodesNotifier;
  late MockReloadNotifier reloadNotifier;

  final ExtensionModel testExtension = const ExtensionModel(
    name: 'TestExtension',
    pkg: 'com.test.extension',
    apk: 'test.apk',
    icon: 'icon.png',
    lang: 'en',
    version: '1.0.0',
    nsfw: 0,
    type: 'aniyomi',
    repositoryUrl: '',
  );

  List<ShowSnackbarEffect> snackbarsOf(AnimeDetailsState state) =>
      state.effects.whereType<ShowSnackbarEffect>().toList();

  AnimeDetailsCubit buildCubit() {
    return AnimeDetailsCubit(
      animeRepository,
      episodeRepository,
      userNotifier,
      animeNotifier,
      animeGenresNotifier,
      mediaListNotifier,
      videoInfoNotifier,
      extensionRepository,
      userRepository,
      episodesInfoNotifier,
      mediaListEntryNotifier,
      extensionNotifier,
      episodesNotifier,
      reloadNotifier,
    );
  }

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(UserModel.empty());
    registerFallbackValue(ExtensionModel.empty());
  });

  setUp(() async {
    await setupTestLocator();

    animeRepository = MockAnimeRepository();
    episodeRepository = MockEpisodeRepository();
    extensionRepository = MockExtensionRepositoryAniyomi();
    userRepository = MockUserRepositoryAnilist();
    userNotifier = MockUserNotifier();
    animeNotifier = MockAnimeNotifier();
    animeGenresNotifier = MockAnimeGenresNotifier();
    mediaListNotifier = MockMediaListNotifier();
    videoInfoNotifier = MockVideoInfoNotifier();
    episodesInfoNotifier = MockEpisodesInfoNotifier();
    mediaListEntryNotifier = MockMediaListEntryNotifier();
    extensionNotifier = MockExtensionNotifier();
    episodesNotifier = MockEpisodesNotifier();
    reloadNotifier = MockReloadNotifier();

    when(() => userNotifier.userStream).thenAnswer((_) => const Stream.empty());
    when(() => animeNotifier.animeStream).thenAnswer((_) => const Stream.empty());
    when(() => mediaListNotifier.mediaListStream).thenAnswer((_) => const Stream.empty());
    when(() => reloadNotifier.reloadStream).thenAnswer((_) => const Stream.empty());
    when(() => extensionRepository.getInstalledAnimeExtensions(any())).thenAnswer((_) async => <Extension>{});
  });

  tearDown(() async {
    await cubit.close();
  });

  group('AnimeDetailsCubit.openAnimeServerSelectionDrawer', () {
    test('warns about a missing extension instead of a "null Error" and clears the loading flag', () async {
      cubit = buildCubit();
      await Future<void>.delayed(Duration.zero);

      await cubit.openAnimeServerSelectionDrawer(MockBuildContext(), 0);

      final List<ShowSnackbarEffect> snackbars = snackbarsOf(cubit.state);
      expect(cubit.state.selectedExtension, isNull);
      expect(cubit.state.animeServerDialogLoading, isFalse);
      expect(
        snackbars.any(
          (effect) =>
              effect.title == 'No Extension Selected' && effect.message == 'Select an extension to fetch episodes.',
        ),
        isTrue,
      );
      expect(snackbars.any((effect) => effect.title.contains('null')), isFalse);
      expect(snackbars.any((effect) => effect.message.contains('No results from the extension')), isFalse);
      expect(cubit.state.effects.whereType<ShowDrawerDialogEffect>(), isEmpty);
    });

    test('warns with the extension name (never "null") when the extension found no anime results', () async {
      when(() => extensionRepository.getInstalledAnimeExtensions(any())).thenAnswer(
        (_) async => <Extension>{testExtension},
      );
      when(() => extensionRepository.getAnimeSearchResults(any(), any())).thenAnswer((_) async => []);

      cubit = buildCubit();
      await Future<void>.delayed(Duration.zero);
      await cubit.selectAnimeExtension(testExtension.name);

      expect(cubit.state.selectedExtension, same(testExtension));
      expect(cubit.state.extensionAnimeResults, isEmpty);

      await cubit.openAnimeServerSelectionDrawer(MockBuildContext(), 0);

      final List<ShowSnackbarEffect> snackbars = snackbarsOf(cubit.state);
      expect(cubit.state.animeServerDialogLoading, isFalse);
      expect(
        snackbars.any(
          (effect) => effect.title == '${testExtension.name} Error' && effect.message == 'No results from the extension. Try again.',
        ),
        isTrue,
      );
      expect(snackbars.any((effect) => effect.title.contains('null')), isFalse);
    });
  });
}

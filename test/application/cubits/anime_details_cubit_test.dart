// External dependencies
import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jni/jni.dart' show JString;
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unyo_lib/jmodels/jsanime.dart';
// Internal dependencies
import 'package:unyo/application/cubits/anime_details_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/anime_details_state.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/episode_info.dart';
import 'package:unyo/domain/entities/media/title.dart';
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

class MockJSAnime extends Mock implements JSAnime {}
class MockJString extends Mock implements JString {}

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
    registerFallbackValue(AnimeModel.empty());
    registerFallbackValue(MediaListEntryModel.empty());
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

  group('AnimeDetailsCubit.selectAnimeExtension', () {
    const String userPreferredTitle = 'Kusuriya no Hitorigoto 3rd Season';
    const String englishTitle = 'The Apothecary Diaries Season 3';
    const String nativeTitle = '薬屋のひとりごと 第3期';
    const String romajiTitle = 'Kusuriya no Hitorigoto 3rd Season';

    final AnimeModel testAnime = AnimeModel.empty().copyWith(
      id: 170942,
      idMal: 58514,
      title: const TitleModel(
        romaji: romajiTitle,
        english: englishTitle,
        nativeTitle: nativeTitle,
        userPreferred: userPreferredTitle,
      ),
    );

    late StreamController<Anime> animeStreamController;

    MockJSAnime mockAnimeWithTitle(String title) {
      final MockJSAnime anime = MockJSAnime();
      final MockJString jTitle = MockJString();
      when(() => jTitle.toDartString()).thenReturn(title);
      when(() => anime.getTitle()).thenReturn(jTitle);
      return anime;
    }

    /// Puts a real anime into the cubit state the way the details page does, and
    /// stubs every repository/notifier call the stream listener fans out to, so
    /// no unrelated path can leak a MissingStubError into the effects.
    Future<void> emitAnimeIntoState() async {
      animeStreamController = StreamController<Anime>.broadcast();
      addTearDown(animeStreamController.close);
      when(() => animeNotifier.animeStream).thenAnswer((_) => animeStreamController.stream);
      when(() => animeRepository.getAnimeDetails(any(), any()))
          .thenAnswer((_) async => (true, AnimeDetailsModel.empty()));
      when(() => animeRepository.getTrendingAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) async => (false, <Anime>[]));
      when(() => animeRepository.getMediaCoverImages(any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) async => <String>[]);
      when(() => episodeRepository.getEpisodeInfo(malId: any(named: 'malId'), anilistId: any(named: 'anilistId')))
          .thenAnswer((_) async => <EpisodeInfo>[]);
      when(() => episodeRepository.getAlternativeImage(malId: any(named: 'malId'), anilistId: any(named: 'anilistId')))
          .thenAnswer((_) async => '');
      when(() => episodesInfoNotifier.updateSelectedEpisodeInfo(any())).thenReturn(null);
      when(() => mediaListEntryNotifier.updateSelectedMediaListEntry(any())).thenReturn(null);
      when(() => extensionNotifier.updateSelectedExtension(any())).thenReturn(null);
      when(() => episodesNotifier.updateSelectedJSEpisodes(any())).thenReturn(null);
      when(() => extensionRepository.getInstalledAnimeExtensions(any()))
          .thenAnswer((_) async => <Extension>{testExtension});

      cubit = buildCubit();
      await pumpEventQueue();
      animeStreamController.add(testAnime);
      await pumpEventQueue();
      expect(cubit.state.selectedAnime.title.userPreferred, userPreferredTitle);
    }

    test('warns with the extension name when the extension has no results after all title fallbacks (no leaked Bad state)', () async {
      when(() => extensionRepository.getAnimeSearchResults(any(), any())).thenAnswer((_) async => []);
      await emitAnimeIntoState();

      await cubit.selectAnimeExtension(testExtension.name);
      await pumpEventQueue();

      final List<ShowSnackbarEffect> snackbars = snackbarsOf(cubit.state);
      final List<String> rendered = snackbars.map((effect) => '${effect.title} / ${effect.message}').toList();
      expect(
        snackbars.any(
          (effect) =>
              effect.title == testExtension.name &&
              effect.message == 'No results found in ${testExtension.name} for $userPreferredTitle' &&
              effect.contentType == ContentType.warning,
        ),
        isTrue,
        reason: 'expected the designed no-results warning, got: $rendered',
      );
      expect(
        snackbars.any((effect) => effect.title == 'Something went wrong'),
        isFalse,
        reason: 'no failure snackbar should be raised for an empty result set, got: $rendered',
      );
      expect(
        snackbars.any((effect) => effect.message.contains('Bad state')),
        isFalse,
        reason: 'the empty result set must not leak StateError: Bad state, got: $rendered',
      );
      expect(
        snackbars.any((effect) => effect.message.contains('Error fetching Anime Info')),
        isFalse,
        reason: 'no error path should be taken for an empty result set, got: $rendered',
      );

      expect(cubit.state.extensionAnimeResults, isEmpty);
      expect(cubit.state.selectedAnimeResultIndex, 0);

      final List<String> queries = verify(
        () => extensionRepository.getAnimeSearchResults(captureAny(), any()),
      ).captured.cast<String>();
      expect(queries, hasLength(4));
      expect(queries, containsAll(<String>[userPreferredTitle, englishTitle, nativeTitle, romajiTitle]));
    });

    test('selects the best fuzzy match and shows Found: when results exist', () async {
      final MockJSAnime unrelated = mockAnimeWithTitle('Unrelated Show');
      final MockJSAnime match = mockAnimeWithTitle(userPreferredTitle);
      when(() => extensionRepository.getAnimeSearchResults(any(), any()))
          .thenAnswer((_) async => <JSAnime>[unrelated, match]);
      await emitAnimeIntoState();

      await cubit.selectAnimeExtension(testExtension.name);
      await pumpEventQueue();

      final List<ShowSnackbarEffect> snackbars = snackbarsOf(cubit.state);
      final List<String> rendered = snackbars.map((effect) => '${effect.title} / ${effect.message}').toList();
      expect(
        snackbars.any(
          (effect) =>
              effect.title == testExtension.name &&
              effect.message.startsWith('Found: ') &&
              effect.contentType == ContentType.success,
        ),
        isTrue,
        reason: 'expected a Found: success snackbar, got: $rendered',
      );
      expect(cubit.state.extensionAnimeResults, hasLength(2));
      expect(cubit.state.selectedAnimeResultIndex, 1);
      expect(snackbars.any((effect) => effect.title == 'Something went wrong'), isFalse, reason: rendered.join('; '));
    });
  });
}

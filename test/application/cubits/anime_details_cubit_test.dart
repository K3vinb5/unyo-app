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
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/notification/video_info_notifier.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/repositories/extension_repository_aniyomi.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/domain/repositories/episode_repository.dart';
import 'package:unyo/core/services/media/media_id_service.dart';
import 'package:unyo/core/services/media/media_link_exception.dart';
import 'package:unyo/domain/repositories/media_id_cache.dart';

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
      MediaIdService(cache: InMemoryMediaIdCache()),
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
      when(() => animeRepository.getAnimeDetails(any(), any(), service: any(named: 'service')))
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

  group('AnimeDetailsCubit.updateMediaListEntry', () {
    test('surfaces an unresolved mapping as a warning and writes nothing', () async {
      when(
        () => animeRepository.updateMediaListEntry(any(), any(), any()),
      ).thenThrow(const MediaLinkUnresolvedException('no verified user-provider entry'));
      cubit = buildCubit();
      await Future<void>.delayed(Duration.zero);

      await cubit.updateMediaListEntry(MockBuildContext());

      final List<ShowSnackbarEffect> snackbars = snackbarsOf(cubit.state);
      final List<String> rendered = snackbars.map((effect) => '${effect.title} / ${effect.message}').toList();
      expect(
        snackbars.any(
          (effect) => effect.title == 'List not updated' && effect.contentType == ContentType.warning,
        ),
        isTrue,
        reason: 'the user must learn the entry is unmatched, got: $rendered',
      );
      expect(
        snackbars.any((effect) => effect.title == 'Something went wrong'),
        isFalse,
        reason: 'an unmatched entry is an expected state, not an app error, got: $rendered',
      );
      verify(() => animeRepository.updateMediaListEntry(any(), any(), any())).called(1);
      verifyNever(() => reloadNotifier.emitReload(ReloadType.animeMediaListEntryUpdated));
      verifyNever(() => reloadNotifier.emitReload(ReloadType.homeMediaListEntryUpdated));
    });
  });

  group('AnimeDetailsCubit switching to another anime', () {
    const TitleModel firstTitle = TitleModel(
      romaji: 'Kusuriya no Hitorigoto',
      english: 'The Apothecary Diaries',
      nativeTitle: '薬屋のひとりごと',
      userPreferred: 'Kusuriya no Hitorigoto',
    );
    const TitleModel secondTitle = TitleModel(
      romaji: 'Sousou no Frieren',
      english: 'Frieren: Beyond Journey\'s End',
      nativeTitle: '葬送のフリーレン',
      userPreferred: 'Sousou no Frieren',
    );

    final AnimeModel firstAnime = AnimeModel.empty().copyWith(id: 170942, idMal: 58514, title: firstTitle);
    final AnimeModel secondAnime = AnimeModel.empty().copyWith(id: 154587, idMal: 52991, title: secondTitle);

    late StreamController<Anime> animeStreamController;
    late StreamController<User> userStreamController;
    late List<String> searchQueries;

    MockJSAnime jsAnimeWithTitle(String title) {
      final MockJSAnime anime = MockJSAnime();
      final MockJString jTitle = MockJString();
      when(() => jTitle.toDartString()).thenReturn(title);
      when(() => anime.getTitle()).thenReturn(jTitle);
      return anime;
    }

    AnilistUserModel anilistUserWith(Map<String, Extension> mediaExtensionConfigs) {
      return AnilistUserModel(
        id: '1',
        name: 'Test User',
        settings: SettingsModel(mediaExtensionConfigs: mediaExtensionConfigs),
        avatarImage: 'avatar.png',
        bannerImage: 'banner.png',
        accessCode: '',
        accessToken: '',
        refreshToken: '',
      );
    }

    /// Wires the streams/repository stubs and pushes [savedMappings] as the
    /// logged user, leaving the page without a selected title. Pass
    /// [pendingExtensions] to hold the installed-extension load open.
    Future<void> startDetailsPage(
      Map<String, Extension> savedMappings, {
      Completer<Set<Extension>>? pendingExtensions,
    }) async {
      animeStreamController = StreamController<Anime>.broadcast();
      addTearDown(animeStreamController.close);
      userStreamController = StreamController<User>.broadcast();
      addTearDown(userStreamController.close);
      searchQueries = <String>[];
      when(() => animeNotifier.animeStream).thenAnswer((_) => animeStreamController.stream);
      when(() => userNotifier.userStream).thenAnswer((_) => userStreamController.stream);
      when(() => animeRepository.getAnimeDetails(any(), any(), service: any(named: 'service')))
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
      when(() => userRepository.updateUserInfo(any())).thenAnswer((_) async {});
      when(() => extensionRepository.getInstalledAnimeExtensions(any())).thenAnswer(
        (_) => pendingExtensions?.future ?? Future.value(<Extension>{testExtension}),
      );
      when(() => extensionRepository.getAnimeSearchResults(any(), any())).thenAnswer((invocation) async {
        final String query = invocation.positionalArguments.first as String;
        searchQueries.add(query);
        return <JSAnime>[jsAnimeWithTitle(query)];
      });

      cubit = buildCubit();
      await pumpEventQueue();
      userStreamController.add(anilistUserWith(savedMappings));
      await pumpEventQueue();
    }

    /// Opens the details page on [firstAnime] with [testExtension] selected, so a
    /// test starts from a page that already holds the first title's extension
    /// results — exactly the state the switch has to invalidate.
    Future<void> openDetailsPageWithFirstAnime(
      Map<String, Extension> savedMappings,
    ) async {
      await startDetailsPage(savedMappings);
      animeStreamController.add(firstAnime);
      await pumpEventQueue();
      await cubit.selectAnimeExtension(testExtension.name);
      await pumpEventQueue();

      expect(cubit.state.selectedAnime.id, firstAnime.id);
      expect(cubit.state.extensionAnimeResults, isNotEmpty);
    }

    int noExtensionPrompts() => snackbarsOf(cubit.state)
        .where((effect) => effect.title == 'No Extension Selected')
        .length;

    test('a saved mapping for the new title re-resolves the extension on the cleared state', () async {
      await openDetailsPageWithFirstAnime(<String, Extension>{secondAnime.id.toString(): testExtension});

      AnimeDetailsState? stateDuringSwitchFetch;
      bool switchedToSecondAnime = false;
      final List<AnimeDetailsState> emittedStates = <AnimeDetailsState>[];
      final StreamSubscription<AnimeDetailsState> stateSubscription = cubit.stream.listen(emittedStates.add);
      addTearDown(stateSubscription.cancel);
      when(() => extensionRepository.getAnimeSearchResults(any(), any())).thenAnswer((invocation) async {
        final String query = invocation.positionalArguments.first as String;
        if (switchedToSecondAnime) stateDuringSwitchFetch ??= cubit.state;
        searchQueries.add(query);
        return <JSAnime>[jsAnimeWithTitle(query)];
      });

      switchedToSecondAnime = true;
      animeStreamController.add(secondAnime);
      await pumpEventQueue();

      expect(cubit.state.selectedAnime.id, secondAnime.id);
      expect(
        stateDuringSwitchFetch,
        isNotNull,
        reason: 'the saved mapping of the new title must trigger an extension search',
      );
      // (b) the first title's per-title extension state must be gone before the fetch runs.
      expect(stateDuringSwitchFetch!.selectedAnime.id, secondAnime.id);
      expect(stateDuringSwitchFetch!.extensionAnimeResults, isEmpty);
      expect(stateDuringSwitchFetch!.selectedAnimeResultIndex, 0);
      expect(stateDuringSwitchFetch!.extensionEpisodeResults, isEmpty);
      expect(stateDuringSwitchFetch!.extensionVideoResults, isEmpty);
      final AnimeDetailsState resetState =
          emittedStates.firstWhere((state) => state.selectedAnime.id == secondAnime.id);
      expect(resetState.selectedExtension, isNull, reason: 'the previous title extension is dropped on the switch');
      expect(resetState.animeServerDialogReady, isFalse);
      // (a) the fetch itself targets the new title.
      expect(searchQueries.last, secondTitle.userPreferred);
      expect(cubit.state.selectedExtension, same(testExtension));
      expect(
        cubit.state.extensionAnimeResults.map((result) => result.getTitle().toDartString()),
        <String>[secondTitle.userPreferred],
        reason: 'the new title must end up with its own extension results, not the old ones',
      );
      final List<int> episodeFetchIds = verify(
        () => episodeRepository.getEpisodeInfo(malId: captureAny(named: 'malId'), anilistId: any(named: 'anilistId')),
      ).captured.cast<int>();
      expect(
        episodeFetchIds,
        contains(secondAnime.idMal),
        reason: 'the episode metadata fetch must run for the new title too',
      );
    });

    test('carries the selected extension over to the new title when the new title has no saved mapping', () async {
      await openDetailsPageWithFirstAnime(<String, Extension>{});
      final int promptsBeforeSwitch = noExtensionPrompts();

      animeStreamController.add(secondAnime);
      await pumpEventQueue();

      expect(cubit.state.selectedAnime.id, secondAnime.id);
      expect(cubit.state.selectedExtension, same(testExtension), reason: 'the open page was already in that extension');
      expect(searchQueries.last, secondTitle.userPreferred);
      expect(cubit.state.extensionAnimeResults, isNotEmpty);
      expect(
        noExtensionPrompts(),
        promptsBeforeSwitch,
        reason: 'a switch must not prompt for an extension (WP #87 keeps the open path quiet)',
      );
    });

    test('re-emitting the same anime id does not resolve the extension again', () async {
      await openDetailsPageWithFirstAnime(<String, Extension>{secondAnime.id.toString(): testExtension});
      animeStreamController.add(secondAnime);
      await pumpEventQueue();
      final List<String> queriesAfterSwitch = List<String>.of(searchQueries);

      animeStreamController.add(secondAnime);
      await pumpEventQueue();

      expect(searchQueries, queriesAfterSwitch, reason: 'a same-id echo must not re-fetch from the extension');
      expect(cubit.state.extensionAnimeResults, isNotEmpty, reason: 'the echo must not clear the resolved results');
    });

    test('a switch landing before the extensions load stays silent when they arrive', () async {
      final Completer<Set<Extension>> pendingExtensions = Completer<Set<Extension>>();
      await startDetailsPage(<String, Extension>{}, pendingExtensions: pendingExtensions);
      animeStreamController.add(firstAnime);
      await pumpEventQueue();
      expect(cubit.state.installedExtensions, isEmpty, reason: 'the load is still pending');

      animeStreamController.add(secondAnime);
      await pumpEventQueue();
      expect(cubit.state.selectedAnime.id, secondAnime.id);

      pendingExtensions.complete(<Extension>{testExtension});
      await pumpEventQueue();

      expect(cubit.state.installedExtensions, isNotEmpty);
      expect(cubit.state.selectedAnime.id, secondAnime.id);
      expect(
        noExtensionPrompts(),
        0,
        reason: 'the deferred switch must resolve like an immediate one, not like the initial page load',
      );
      expect(cubit.state.selectedExtension, isNull, reason: 'no saved mapping and nothing carried over to resolve with');
      expect(searchQueries, isEmpty);
    });

    test('a switch landing before the extensions load resolves the saved mapping once they arrive', () async {
      final Completer<Set<Extension>> pendingExtensions = Completer<Set<Extension>>();
      await startDetailsPage(
        <String, Extension>{secondAnime.id.toString(): testExtension},
        pendingExtensions: pendingExtensions,
      );
      animeStreamController.add(firstAnime);
      await pumpEventQueue();

      animeStreamController.add(secondAnime);
      await pumpEventQueue();

      pendingExtensions.complete(<Extension>{testExtension});
      await pumpEventQueue();

      expect(
        searchQueries.last,
        secondTitle.userPreferred,
        reason: 'the deferred switch must search the extension for the title that is open now',
      );
      expect(cubit.state.selectedExtension, same(testExtension));
      expect(cubit.state.extensionAnimeResults, isNotEmpty);
      expect(noExtensionPrompts(), 0);
    });

    test('a late search for the previous title does not overwrite the new title results', () async {
      await openDetailsPageWithFirstAnime(<String, Extension>{secondAnime.id.toString(): testExtension});
      final Completer<List<JSAnime>> firstTitleSearch = Completer<List<JSAnime>>();
      when(() => extensionRepository.getAnimeSearchResults(any(), any())).thenAnswer((invocation) {
        final String query = invocation.positionalArguments.first as String;
        searchQueries.add(query);
        if (query == firstTitle.userPreferred) return firstTitleSearch.future;
        return Future.value(<JSAnime>[jsAnimeWithTitle(query)]);
      });

      final Future<void> firstTitleFetch = cubit.selectAnimeExtension(testExtension.name);
      await pumpEventQueue();

      animeStreamController.add(secondAnime);
      await pumpEventQueue();
      expect(cubit.state.extensionAnimeResults.map((result) => result.getTitle().toDartString()), <String>[
        secondTitle.userPreferred,
      ]);

      firstTitleSearch.complete(<JSAnime>[jsAnimeWithTitle('Stale result from the previous title')]);
      await firstTitleFetch;
      await pumpEventQueue();

      expect(
        cubit.state.extensionAnimeResults.map((result) => result.getTitle().toDartString()),
        <String>[secondTitle.userPreferred],
        reason: 'results fetched for the previous title must be discarded, not emitted onto the new one',
      );
      expect(
        snackbarsOf(cubit.state).where((effect) => effect.message.contains('Stale result')),
        isEmpty,
        reason: 'a discarded fetch must not snackbar a result the page does not show',
      );
    });
  });

  group('logTitleFor', () {
    setUp(() {
      // The outer tearDown closes the cubit, so give it one to close.
      cubit = buildCubit();
    });

    test('prefers userPreferred over every other title field', () {
      const TitleModel title = TitleModel(
        romaji: 'Romaji Title',
        english: 'English Title',
        nativeTitle: 'Native Title',
        userPreferred: 'Preferred Title',
      );

      expect(logTitleFor(title), 'Preferred Title');
    });

    test('falls back through english, romaji and nativeTitle when earlier fields are empty', () {
      expect(
        logTitleFor(const TitleModel(romaji: 'Romaji Title', english: 'English Title', nativeTitle: 'Native Title', userPreferred: '')),
        'English Title',
        reason: 'userPreferred empty -> english',
      );
      expect(
        logTitleFor(const TitleModel(romaji: 'Romaji Title', english: '', nativeTitle: 'Native Title', userPreferred: '')),
        'Romaji Title',
        reason: 'userPreferred and english empty -> romaji',
      );
      expect(
        logTitleFor(const TitleModel(romaji: '', english: '', nativeTitle: 'Native Title', userPreferred: '')),
        'Native Title',
        reason: 'only nativeTitle left',
      );
    });

    test('returns an empty string when every title field is empty', () {
      expect(logTitleFor(TitleModel.empty()), '');
    });
  });
}

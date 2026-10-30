// External dependencies
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unyo_lib/jmodels/jsmanga.dart';
// Internal dependencies
import 'package:unyo/application/cubits/manga_details_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/manga_details_state.dart';
import 'package:unyo/core/notification/manga_genres_notifier.dart';
import 'package:unyo/core/notification/manga_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/repositories/extension_repository_aniyomi.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/manga_details.dart';
import 'package:unyo/domain/entities/media/title.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';
import '../../core/di/locator.dart' show setupTestLocator;

class MockBuildContext extends Mock implements BuildContext {}

class MockJSManga extends Mock implements JSManga {}

class MockMangaRepository extends Mock implements MangaRepository {}
class MockExtensionRepositoryAniyomi extends Mock implements ExtensionRepositoryAniyomi {}
class MockUserRepositoryAnilist extends Mock implements UserRepositoryAnilist {}

class MockUserNotifier extends Mock implements UserNotifier {}
class MockMangaNotifier extends Mock implements MangaNotifier {}
class MockMangaGenresNotifier extends Mock implements MangaGenresNotifier {}
class MockMediaListNotifier extends Mock implements MediaListNotifier {}

void main() {
  late MangaDetailsCubit cubit;
  late MockMangaRepository mangaRepository;
  late MockUserRepositoryAnilist userRepository;
  late MockExtensionRepositoryAniyomi extensionRepository;
  late MockUserNotifier userNotifier;
  late MockMangaNotifier mangaNotifier;
  late MockMangaGenresNotifier mangaGenresNotifier;
  late MockMediaListNotifier mediaListNotifier;
  late StreamController<User> userStreamController;

  const ExtensionModel testExtension = ExtensionModel(
    name: 'TestExtension',
    pkg: 'com.test.extension',
    apk: 'test.apk',
    icon: 'icon.png',
    lang: 'en',
    version: '1.0.0',
    nsfw: 0,
    type: 'tachiyomi',
    repositoryUrl: '',
  );

  const AnilistUserModel anilistUser = AnilistUserModel(
    id: '1',
    name: 'Test User',
    settings: SettingsModel(),
    avatarImage: 'avatar.png',
    bannerImage: 'banner.png',
    accessCode: '',
    accessToken: '',
    refreshToken: '',
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(UserModel.empty());
    registerFallbackValue(ExtensionModel.empty());
    registerFallbackValue(MangaModel.empty());
  });

  setUp(() async {
    await setupTestLocator();

    mangaRepository = MockMangaRepository();
    userRepository = MockUserRepositoryAnilist();
    extensionRepository = MockExtensionRepositoryAniyomi();
    userNotifier = MockUserNotifier();
    mangaNotifier = MockMangaNotifier();
    mangaGenresNotifier = MockMangaGenresNotifier();
    mediaListNotifier = MockMediaListNotifier();
    userStreamController = StreamController<User>.broadcast();

    when(() => userNotifier.userStream).thenAnswer((_) => userStreamController.stream);
    when(() => mangaNotifier.mangaStream).thenAnswer((_) => const Stream.empty());
    when(() => mediaListNotifier.mediaListStream).thenAnswer((_) => const Stream.empty());
    when(() => extensionRepository.getInstalledMangaExtensions(any())).thenAnswer(
      (_) async => <Extension>{testExtension},
    );
    when(() => mangaRepository.getMediaCoverImages(any())).thenAnswer((_) async => []);

    cubit = MangaDetailsCubit(
      mangaRepository,
      userNotifier,
      mangaNotifier,
      mangaGenresNotifier,
      mediaListNotifier,
      extensionRepository,
      userRepository,
    );
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    await cubit.close();
    await userStreamController.close();
  });

  group('MangaDetailsCubit.selectMangaExtension', () {
    test('emits the selected extension so the dropdown reflects the choice', () async {
      when(() => userRepository.updateUserInfo(any())).thenAnswer((_) async {});
      when(() => extensionRepository.getMangaSearchResults(any(), any())).thenAnswer((_) async => []);

      userStreamController.add(anilistUser);
      await Future<void>.delayed(Duration.zero);

      await cubit.selectMangaExtension(testExtension.name);

      expect(cubit.state.selectedExtension, same(testExtension));
      expect(cubit.state.installedExtensions, contains(testExtension));
      verify(() => extensionRepository.getMangaSearchResults(any(), any())).called(1);
    });

    test('still fetches from the extension when persisting the selection fails', () async {
      when(() => userRepository.updateUserInfo(any())).thenThrow(Exception('persistence down'));
      when(() => extensionRepository.getMangaSearchResults(any(), any())).thenAnswer((_) async => []);

      userStreamController.add(anilistUser);
      await Future<void>.delayed(Duration.zero);

      await cubit.selectMangaExtension(testExtension.name);

      verify(() => userRepository.updateUserInfo(any())).called(1);
      verify(() => extensionRepository.getMangaSearchResults(any(), any())).called(1);
      expect(cubit.state.selectedExtension, same(testExtension));
    });
  });

  group('MangaDetailsCubit.openMangaServerSelectionDrawer', () {
    test('warns that a chapter needs an extension when none is selected', () {
      cubit.openMangaServerSelectionDrawer(MockBuildContext(), 0);

      final List<ShowSnackbarEffect> snackbars = cubit.state.effects.whereType<ShowSnackbarEffect>().toList();
      expect(
        snackbars.any(
          (effect) =>
              effect.title == 'No Extension Selected' && effect.message == 'Select an extension to fetch chapters.',
        ),
        isTrue,
      );
    });

    test('explains that the manga reader is not available with an extension selected', () async {
      when(() => userRepository.updateUserInfo(any())).thenAnswer((_) async {});
      when(() => extensionRepository.getMangaSearchResults(any(), any())).thenAnswer((_) async => []);
      await cubit.selectMangaExtension(testExtension.name);

      cubit.openMangaServerSelectionDrawer(MockBuildContext(), 0);

      final List<ShowSnackbarEffect> snackbars = cubit.state.effects.whereType<ShowSnackbarEffect>().toList();
      expect(
        snackbars.any(
          (effect) =>
              effect.title == 'Manga Reader' && effect.message == 'The manga reader is not available yet.',
        ),
        isTrue,
      );
    });
  });

  group('MangaDetailsCubit extension prompt on open', () {
    test('prompts once on open when extensions are installed but none is selected', () async {
      await Future<void>.delayed(Duration.zero);

      final List<ShowSnackbarEffect> snackbars = cubit.state.effects.whereType<ShowSnackbarEffect>().toList();
      expect(
        snackbars.any(
          (effect) =>
              effect.title == 'No Extension Selected' && effect.message == 'Select an extension to fetch chapters.',
        ),
        isTrue,
      );
    });
  });

  group('MangaDetailsCubit switching to another manga', () {
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

    final MangaModel firstManga = MangaModel.empty().copyWith(id: 170942, title: firstTitle);
    final MangaModel secondManga = MangaModel.empty().copyWith(id: 154587, title: secondTitle);

    late StreamController<Manga> mangaStreamController;
    late StreamController<User> userStreamController;
    late List<String> searchQueries;

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
      await cubit.close();
      mangaStreamController = StreamController<Manga>.broadcast();
      addTearDown(mangaStreamController.close);
      userStreamController = StreamController<User>.broadcast();
      addTearDown(userStreamController.close);
      searchQueries = <String>[];
      when(() => mangaNotifier.mangaStream).thenAnswer((_) => mangaStreamController.stream);
      when(() => userNotifier.userStream).thenAnswer((_) => userStreamController.stream);
      when(() => mangaRepository.getMangaDetails(any(), any(), service: any(named: 'service')))
          .thenAnswer((_) async => (true, MangaDetailsModel.empty()));
      when(() => mangaRepository.getTrendingMangas(any(), any(), ignoreCache: any(named: 'ignoreCache')))
          .thenAnswer((_) async => (false, <Manga>[]));
      when(() => mangaRepository.getMediaCoverImages(any())).thenAnswer((_) async => <String>[]);
      when(() => userRepository.updateUserInfo(any())).thenAnswer((_) async {});
      when(() => extensionRepository.getInstalledMangaExtensions(any())).thenAnswer(
        (_) => pendingExtensions?.future ?? Future.value(<Extension>{testExtension}),
      );
      when(() => extensionRepository.getMangaSearchResults(any(), any())).thenAnswer((invocation) async {
        final String query = invocation.positionalArguments.first as String;
        searchQueries.add(query);
        return <JSManga>[MockJSManga()];
      });

      cubit = MangaDetailsCubit(
        mangaRepository,
        userNotifier,
        mangaNotifier,
        mangaGenresNotifier,
        mediaListNotifier,
        extensionRepository,
        userRepository,
      );
      await pumpEventQueue();
      userStreamController.add(anilistUserWith(savedMappings));
      await pumpEventQueue();
    }

    /// Opens the details page on [firstManga] with [testMangaExtension] selected,
    /// so the switch starts from a page that already holds the first title's
    /// extension results.
    Future<void> openDetailsPageWithFirstManga(Map<String, Extension> savedMappings) async {
      await startDetailsPage(savedMappings);
      mangaStreamController.add(firstManga);
      await pumpEventQueue();
      await cubit.selectMangaExtension(testExtension.name);
      await pumpEventQueue();

      expect(cubit.state.selectedManga.id, firstManga.id);
      expect(cubit.state.extensionMangaResults, isNotEmpty);
    }

    int noExtensionPrompts() => cubit.state.effects
        .whereType<ShowSnackbarEffect>()
        .where((effect) => effect.title == 'No Extension Selected')
        .length;

    test('a saved mapping for the new title re-resolves the extension on the cleared state', () async {
      await openDetailsPageWithFirstManga(<String, Extension>{secondManga.id.toString(): testExtension});

      MangaDetailsState? stateDuringSwitchFetch;
      bool switchedToSecondManga = false;
      final List<MangaDetailsState> emittedStates = <MangaDetailsState>[];
      final StreamSubscription<MangaDetailsState> stateSubscription = cubit.stream.listen(emittedStates.add);
      addTearDown(stateSubscription.cancel);
      when(() => extensionRepository.getMangaSearchResults(any(), any())).thenAnswer((invocation) async {
        final String query = invocation.positionalArguments.first as String;
        if (switchedToSecondManga) stateDuringSwitchFetch ??= cubit.state;
        searchQueries.add(query);
        return <JSManga>[MockJSManga()];
      });

      switchedToSecondManga = true;
      mangaStreamController.add(secondManga);
      await pumpEventQueue();

      expect(cubit.state.selectedManga.id, secondManga.id);
      expect(
        stateDuringSwitchFetch,
        isNotNull,
        reason: 'the saved mapping of the new title must trigger an extension search',
      );
      expect(stateDuringSwitchFetch!.selectedManga.id, secondManga.id);
      expect(stateDuringSwitchFetch!.extensionMangaResults, isEmpty);
      expect(stateDuringSwitchFetch!.extensionEpisodeResults, isEmpty);
      expect(stateDuringSwitchFetch!.extensionVideoResults, isEmpty);
      final MangaDetailsState resetState =
          emittedStates.firstWhere((state) => state.selectedManga.id == secondManga.id);
      expect(resetState.selectedExtension, isNull, reason: 'the previous title extension is dropped on the switch');
      expect(searchQueries.last, secondTitle.userPreferred);
      expect(cubit.state.selectedExtension, same(testExtension));
      expect(cubit.state.extensionMangaResults, hasLength(1));
    });

    test('carries the selected extension over to the new title when the new title has no saved mapping', () async {
      await openDetailsPageWithFirstManga(<String, Extension>{});
      final int promptsBeforeSwitch = noExtensionPrompts();

      mangaStreamController.add(secondManga);
      await pumpEventQueue();

      expect(cubit.state.selectedManga.id, secondManga.id);
      expect(cubit.state.selectedExtension, same(testExtension), reason: 'the open page was already in that extension');
      expect(searchQueries.last, secondTitle.userPreferred);
      expect(cubit.state.extensionMangaResults, isNotEmpty);
      expect(
        noExtensionPrompts(),
        promptsBeforeSwitch,
        reason: 'a switch must not prompt for an extension (WP #87 keeps the open path quiet)',
      );
    });

    test('re-emitting the same manga id does not resolve the extension again', () async {
      await openDetailsPageWithFirstManga(<String, Extension>{secondManga.id.toString(): testExtension});
      mangaStreamController.add(secondManga);
      await pumpEventQueue();
      final List<String> queriesAfterSwitch = List<String>.of(searchQueries);

      mangaStreamController.add(secondManga);
      await pumpEventQueue();

      expect(searchQueries, queriesAfterSwitch, reason: 'a same-id echo must not re-fetch from the extension');
      expect(cubit.state.extensionMangaResults, isNotEmpty, reason: 'the echo must not clear the resolved results');
    });

    test('a switch landing before the extensions load stays silent when they arrive', () async {
      final Completer<Set<Extension>> pendingExtensions = Completer<Set<Extension>>();
      await startDetailsPage(<String, Extension>{}, pendingExtensions: pendingExtensions);
      mangaStreamController.add(firstManga);
      await pumpEventQueue();
      expect(cubit.state.installedExtensions, isEmpty, reason: 'the load is still pending');

      mangaStreamController.add(secondManga);
      await pumpEventQueue();
      expect(cubit.state.selectedManga.id, secondManga.id);

      pendingExtensions.complete(<Extension>{testExtension});
      await pumpEventQueue();

      expect(cubit.state.installedExtensions, isNotEmpty);
      expect(cubit.state.selectedManga.id, secondManga.id);
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
        <String, Extension>{secondManga.id.toString(): testExtension},
        pendingExtensions: pendingExtensions,
      );
      mangaStreamController.add(firstManga);
      await pumpEventQueue();

      mangaStreamController.add(secondManga);
      await pumpEventQueue();

      pendingExtensions.complete(<Extension>{testExtension});
      await pumpEventQueue();

      expect(
        searchQueries.last,
        secondTitle.userPreferred,
        reason: 'the deferred switch must search the extension for the title that is open now',
      );
      expect(cubit.state.selectedExtension, same(testExtension));
      expect(cubit.state.extensionMangaResults, isNotEmpty);
      expect(noExtensionPrompts(), 0);
    });

    test('a late search for the previous title does not overwrite the new title results', () async {
      await openDetailsPageWithFirstManga(<String, Extension>{secondManga.id.toString(): testExtension});
      final Completer<List<JSManga>> firstTitleSearch = Completer<List<JSManga>>();
      final JSManga secondTitleResult = MockJSManga();
      when(() => extensionRepository.getMangaSearchResults(any(), any())).thenAnswer((invocation) {
        final String query = invocation.positionalArguments.first as String;
        searchQueries.add(query);
        if (query == firstTitle.userPreferred) return firstTitleSearch.future;
        return Future.value(<JSManga>[secondTitleResult]);
      });

      final Future<void> firstTitleFetch = cubit.selectMangaExtension(testExtension.name);
      await pumpEventQueue();

      mangaStreamController.add(secondManga);
      await pumpEventQueue();
      expect(cubit.state.extensionMangaResults, <JSManga>[secondTitleResult]);

      firstTitleSearch.complete(<JSManga>[MockJSManga()]);
      await firstTitleFetch;
      await pumpEventQueue();

      expect(
        cubit.state.extensionMangaResults,
        <JSManga>[secondTitleResult],
        reason: 'results fetched for the previous title must be discarded, not emitted onto the new one',
      );
    });
  });
}

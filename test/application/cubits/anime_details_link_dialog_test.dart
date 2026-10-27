// External dependencies
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/anime_details_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/anime_details_state.dart';
import 'package:unyo/core/enums/service.dart';
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
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/repositories/extension_repository_aniyomi.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/anime_details.dart';
import 'package:unyo/domain/entities/media/episode_info.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/domain/repositories/episode_repository.dart';
import 'package:unyo/domain/services/id_mapping.dart';
import 'package:unyo/domain/services/media_id_cache.dart';
import 'package:unyo/domain/services/media_id_resolver.dart';
import '../../core/di/locator.dart' show setupTestLocator;

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

class FakeMediaMappingLookup implements MediaMappingLookup {
  List<MediaLinkCandidate> searchResults = <MediaLinkCandidate>[];
  MediaLinkCandidate? probeResult;
  int searchCalls = 0;
  int probeCalls = 0;

  @override
  Future<MediaLinkCandidate?> lookupByMalId(Service target, int malId) async {
    probeCalls++;
    return probeResult;
  }

  @override
  Future<List<MediaLinkCandidate>> searchCandidates(Service target, MediaLinkQuery query) async {
    searchCalls++;
    return searchResults;
  }
}

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
  late FakeMediaMappingLookup mappingLookup;
  late InMemoryMediaIdCache cache;
  late StreamController<Anime> animeStreamController;
  late StreamController<User> userStreamController;

  final AnimeModel testAnime = AnimeModel.empty().copyWith(id: 4242, idMal: 0);
  final AnilistUserModel testUser = AnilistUserModel(
    id: '1',
    name: 'test',
    settings: SettingsModel.empty().copyWith(userService: Service.anilist, metadataService: Service.shikimori),
    avatarImage: '',
    bannerImage: '',
    accessCode: '',
    accessToken: '',
    refreshToken: '',
  );

  List<ShowWidgetDialogEffect> dialogsOf(AnimeDetailsState state) =>
      state.effects.whereType<ShowWidgetDialogEffect>().toList();

  Future<void> openDetails({Anime? anime}) async {
    userStreamController.add(testUser);
    await pumpEventQueue();
    animeStreamController.add(anime ?? testAnime);
    await pumpEventQueue();
  }

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(AnimeModel.empty());
    registerFallbackValue(MediaListEntryModel.empty());
    registerFallbackValue(UserModel.empty());
    registerFallbackValue(ExtensionModel.empty());
  });

  setUp(() async {
    AnimeDetailsCubit.resetPromptedMediaLinks();
    await setupTestLocator();
    cache = InMemoryMediaIdCache();
    mappingLookup = FakeMediaMappingLookup();

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

    animeStreamController = StreamController<Anime>.broadcast();
    userStreamController = StreamController<User>.broadcast();
    addTearDown(animeStreamController.close);
    addTearDown(userStreamController.close);

    when(() => userNotifier.userStream).thenAnswer((_) => userStreamController.stream);
    when(() => animeNotifier.animeStream).thenAnswer((_) => animeStreamController.stream);
    when(() => mediaListNotifier.mediaListStream).thenAnswer((_) => const Stream.empty());
    when(() => reloadNotifier.reloadStream).thenAnswer((_) => const Stream.empty());
    when(() => extensionRepository.getInstalledAnimeExtensions(any())).thenAnswer((_) async => <Extension>{});
    when(() => animeRepository.getAnimeDetails(any(), any(), service: any(named: 'service')))
        .thenAnswer((_) async => (true, AnimeDetailsModel.empty()));
    when(() => animeRepository.getTrendingAnimes(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => (false, <Anime>[]));
    when(() => animeRepository.getMediaListEntry(any(), any(), ignoreCache: any(named: 'ignoreCache')))
        .thenAnswer((_) async => MediaListEntryModel.empty().copyWith(progress: 3, status: 'Current'));
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

    cubit = AnimeDetailsCubit(
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
      mediaIdResolver: MediaIdResolver(cache: cache, mappingLookup: mappingLookup),
    );
    await pumpEventQueue();
  });

  tearDown(() async {
    await cubit.close();
  });

  List<MediaLinkCandidate> candidates() => <MediaLinkCandidate>[
        const MediaLinkCandidate(
          service: Service.shikimori,
          nativeId: '55555',
          malId: 58514,
          title: 'Kusuriya no Hitorigoto',
          year: 2023,
          format: 'tv',
        ),
        const MediaLinkCandidate(
          service: Service.shikimori,
          nativeId: '66666',
          title: 'Kusuriya no Hitorigoto OVA',
          year: 2024,
          format: 'ova',
        ),
      ];

  group('link confirmation dialog gating', () {
    test('a heuristic hit is proposed once, with the reason and up to 5 ranked candidates', () async {
      mappingLookup.searchResults = candidates();

      await openDetails();

      final AnimeDetailsState state = cubit.state;
      expect(state.mediaLinkProposal, isNotNull);
      expect(state.mediaLinkProposal!.userService, Service.anilist);
      expect(state.mediaLinkProposal!.metadataService, Service.shikimori);
      expect(state.mediaLinkProposal!.sourceNativeId, '4242');
      expect(state.mediaLinkProposal!.candidates, hasLength(2));
      expect(state.mediaLinkProposal!.candidates.first.nativeId, '55555', reason: 'best-first order preserved');
      expect(state.mediaLinkUnresolved, isTrue);
      expect(dialogsOf(state), hasLength(1), reason: 'the dialog must be raised exactly once for this entry');
      expect(mappingLookup.searchCalls, 1);
      expect(cache.entries, isEmpty, reason: 'nothing is cached before the user confirms');
    });

    test('confirming caches the link and renders the metadata provider entry', () async {
      mappingLookup.searchResults = candidates();
      await openDetails();

      await cubit.confirmMediaLink(cubit.state.mediaLinkProposal!.candidates.first);
      await pumpEventQueue();

      final IdMapping? link = await cache.getByNativeId(Service.shikimori, '55555');
      expect(link, isNotNull);
      expect(link!.state, IdMappingState.confirmed);
      expect(link.malId, 58514);
      expect(cubit.state.mediaLinkProposal, isNull);
      expect(cubit.state.mediaLinkUnresolved, isFalse);
      expect(mappingLookup.searchCalls, 1, reason: 'the confirmed link is reused by the refetch');
      final List<Service?> services = verify(
        () => animeRepository.getAnimeDetails(any(), any(), service: captureAny(named: 'service')),
      ).captured.cast<Service?>();
      expect(services, contains(Service.shikimori));
    });

    test('declining leaves the entry unresolved and never asks again', () async {
      mappingLookup.searchResults = candidates();
      await openDetails();

      await cubit.declineMediaLink();
      await pumpEventQueue();

      expect(cubit.state.mediaLinkProposal, isNull);
      expect(cubit.state.mediaLinkUnresolved, isTrue);
      final IdMapping? row = await cache.getByNativeId(Service.anilist, '4242');
      expect(row!.state, IdMappingState.unresolved);

      await openDetails();

      expect(cubit.state.mediaLinkProposal, isNull);
      expect(dialogsOf(cubit.state), hasLength(1), reason: 'one prompt per entry per session');
      expect(mappingLookup.searchCalls, 1, reason: 'the in-session unresolved row short-circuits the chain');
    });

    test('dismiss keeps the user-provider fallback and is not a nag', () async {
      mappingLookup.searchResults = candidates();
      await openDetails();

      cubit.dismissMediaLink();
      await pumpEventQueue();

      expect(cubit.state.mediaLinkProposal, isNull);
      expect(cubit.state.mediaLinkUnresolved, isTrue);
      expect(await cache.getByNativeId(Service.anilist, '4242'), isNull, reason: 'dismiss caches nothing');

      await openDetails();

      expect(cubit.state.mediaLinkProposal, isNull);
      expect(dialogsOf(cubit.state), hasLength(1));
      final List<Service?> services = verify(
        () => animeRepository.getAnimeDetails(any(), any(), service: captureAny(named: 'service')),
      ).captured.cast<Service?>();
      expect(services.every((service) => service == Service.anilist), isTrue,
          reason: 'unresolved entries render the record\'s own provider details');
    });

    test('the manual relink action re-runs the chain after a decline', () async {
      mappingLookup.searchResults = candidates();
      await openDetails();
      await cubit.declineMediaLink();
      await pumpEventQueue();

      mappingLookup.searchResults = candidates();
      await cubit.requestMediaLink();
      await pumpEventQueue();

      expect(cubit.state.mediaLinkProposal, isNotNull);
      expect(dialogsOf(cubit.state), hasLength(2), reason: 'the manual action reopens the dialog');
    });
  });

  group('list state ownership', () {
    test('the list editor never adopts the metadata provider\'s entry', () async {
      // An AniList record (idMal set) whose details come from Shikimori: the
      // Shikimori payload carries Shikimori's own userRate, which is not the
      // AniList account's list state.
      mappingLookup.probeResult = const MediaLinkCandidate(
        service: Service.shikimori,
        nativeId: '55555',
        malId: 58514,
        title: 'Kusuriya no Hitorigoto',
        year: 2023,
        format: 'tv',
      );
      when(() => animeRepository.getAnimeDetails(any(), any(), service: any(named: 'service'))).thenAnswer(
        (_) async => (
          true,
          AnimeDetailsModel.empty().copyWith(
            mediaListEntry: MediaListEntryModel.empty().copyWith(progress: 99, status: 'Foreign'),
          ),
        ),
      );

      await openDetails(anime: testAnime.copyWith(idMal: 58514));

      expect(cubit.state.mediaListEntry.progress, 3,
          reason: 'the entry must come from the user provider, not the metadata payload');
      expect(cubit.state.mediaListEntry.status, 'Current');
      verify(
        () => animeRepository.getMediaListEntry(any(), any(), ignoreCache: any(named: 'ignoreCache')),
      ).called(greaterThanOrEqualTo(1));
      final List<Service?> services = verify(
        () => animeRepository.getAnimeDetails(any(), any(), service: captureAny(named: 'service')),
      ).captured.cast<Service?>();
      expect(services, contains(Service.shikimori), reason: 'details themselves still come from the metadata provider');
    });
  });
}

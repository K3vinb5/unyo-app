// External dependencies
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
// Internal dependencies
import 'package:unyo/application/cubits/manga_details_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/core/notification/manga_genres_notifier.dart';
import 'package:unyo/core/notification/manga_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/repositories/extension_repository_aniyomi.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/manga_repository.dart';
import '../../core/di/locator.dart' show setupTestLocator;

class MockBuildContext extends Mock implements BuildContext {}

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

  group('MangaDetailsCubit.onMangaChapterPressed', () {
    test('warns that a chapter needs an extension when none is selected', () {
      cubit.onMangaChapterPressed(MockBuildContext(), 0);

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

      cubit.onMangaChapterPressed(MockBuildContext(), 0);

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
}

// External dependencies
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/settings_cubit.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/theme/color_image_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/user_repository_local.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockUserRepositoryLocal extends Mock implements UserRepositoryLocal {}

class MockUserNotifier extends Mock implements UserNotifier {}

class MockReloadNotifier extends Mock implements ReloadNotifier {}

class MockThemeService extends Mock implements ThemeService {}

class MockColorImageService extends Mock implements ColorImageService {}

/// `SettingsCubit` theme guards (WP #158) and setting persistence per account
/// type (WP #156, MyAnimeList).
void main() {
  late SettingsCubit cubit;
  late MockUserRepository userRepository;
  late MockUserRepositoryLocal userRepositoryLocal;
  late MockUserNotifier loggedUserNotifier;
  late MockReloadNotifier reloadNotifier;
  late MockThemeService themeService;
  late MockColorImageService colorImageService;
  late StreamController<User> users;

  ShikimoriUserModel shikimoriUser() => ShikimoriUserModel(
    id: '123',
    name: 'shiki',
    settings: SettingsModel.empty().copyWith(useWallpaperAsThemeColor: false),
    avatarImage: '',
    bannerImage: '',
    accessToken: 'access',
    refreshToken: 'refresh',
    accessTokenExpiresAt: '',
    profileUrl: '',
  );

  MalUserModel malUser() => MalUserModel(
    id: '56789',
    name: 'tester',
    settings: SettingsModel.empty().copyWith(userService: Service.mal),
    avatarImage: '',
    bannerImage: '',
    accessToken: 'access-token',
    refreshToken: 'stored-refresh',
    accessTokenExpiresAt: '2099-01-01T00:00:00.000',
    profileUrl: '',
  );

  LocalUserModel localUser() => LocalUserModel(
    id: '',
    name: 'alice',
    settings: SettingsModel.empty(),
    avatarImage: '',
    bannerImage: '',
  );

  setUpAll(() {
    registerFallbackValue(const NetworkImage('https://example.test/fallback.png'));
    registerFallbackValue(UserModel.empty());
  });

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));

    userRepository = MockUserRepository();
    userRepositoryLocal = MockUserRepositoryLocal();
    loggedUserNotifier = MockUserNotifier();
    reloadNotifier = MockReloadNotifier();
    themeService = MockThemeService();
    colorImageService = MockColorImageService();
    when(() => userRepository.updateUserInfo(any())).thenAnswer((_) async {});
    when(() => userRepositoryLocal.updateUserInfo(any())).thenAnswer((_) async {});

    users = StreamController<User>.broadcast();
    addTearDown(users.close);
    when(() => loggedUserNotifier.userStream).thenAnswer((_) => users.stream);

    cubit = SettingsCubit(
      userRepository,
      userRepositoryLocal,
      loggedUserNotifier,
      reloadNotifier,
      themeService,
      colorImageService,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('SettingsCubit.enableUseWallpaperAsThemeColor', () {
    test(
      'keeps the toggle and falls back to the account colour when there is no '
      'wallpaper to sample',
      () async {
        final ShikimoriUserModel user = shikimoriUser();
        users.add(user);
        await pumpEventQueue();

        await cubit.enableUseWallpaperAsThemeColor(true);

        verify(
          () => themeService.updateThemeFromColors(
            loggedUser: user,
            useWallpaperAsThemeColor: true,
            primary: user.settings.themeColor,
          ),
        ).called(1);
        verifyNever(() => colorImageService.getColorsFromPalleteGenerator(any()));
        // The old code threw a RangeError here and swallowed it as an error effect.
        expect(cubit.state.effects, isEmpty);
      },
    );

    test(
      'keeps the toggle for a MyAnimeList account, which carries no banner',
      () async {
        final MalUserModel user = malUser();
        users.add(user);
        await pumpEventQueue();

        await cubit.enableUseWallpaperAsThemeColor(true);

        verify(
          () => themeService.updateThemeFromColors(
            loggedUser: user,
            useWallpaperAsThemeColor: true,
            primary: user.settings.themeColor,
          ),
        ).called(1);
        verifyNever(() => colorImageService.getColorsFromPalleteGenerator(any()));
        expect(cubit.state.effects, isEmpty);
      },
    );
  });

  group('SettingsCubit settings persistence', () {
    test('a MalUserModel setting change is saved through the user repository', () async {
      users.add(malUser());
      await pumpEventQueue();

      await cubit.enableOpenSubtitlesIntegration(true);
      await pumpEventQueue();

      final User saved = verify(() => userRepository.updateUserInfo(captureAny())).captured.single as User;
      expect(saved, isA<MalUserModel>());
      expect(saved.settings.enableOpenSubtitlesIntegration, isTrue);
      verifyNever(() => userRepositoryLocal.updateUserInfo(any()));
    });

    test('a LocalUserModel setting change still goes to the local repository', () async {
      users.add(localUser());
      await pumpEventQueue();

      await cubit.enableOpenSubtitlesIntegration(true);
      await pumpEventQueue();

      final User saved = verify(() => userRepositoryLocal.updateUserInfo(captureAny())).captured.single as User;
      expect(saved, isA<LocalUserModel>());
      expect(saved.settings.enableOpenSubtitlesIntegration, isTrue);
      verifyNever(() => userRepository.updateUserInfo(any()));
    });
  });
}

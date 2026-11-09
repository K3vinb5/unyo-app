// External dependencies
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/settings_cubit.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/theme/color_image_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/user_repository_local.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/user_repository.dart';

class MockThemeService extends Mock implements ThemeService {}

class MockColorImageService extends Mock implements ColorImageService {}

class MockUserNotifier extends Mock implements UserNotifier {}

class MockReloadNotifier extends Mock implements ReloadNotifier {}

class MockUserRepository extends Mock implements UserRepository {}

class MockUserRepositoryLocal extends Mock implements UserRepositoryLocal {}

void main() {
  late MockUserRepository userRepository;
  late MockUserRepositoryLocal userRepositoryLocal;
  late MockUserNotifier loggedUserNotifier;
  late MockReloadNotifier reloadNotifier;
  late MockThemeService themeService;
  late MockColorImageService colorImageService;

  setUpAll(() {
    if (!sl.isRegistered<Logger>()) {
      sl.registerSingleton<Logger>(Logger(level: Level.off));
    }
    registerFallbackValue(const NetworkImage('https://example.test/fallback.png'));
  });

  setUp(() {
    userRepository = MockUserRepository();
    userRepositoryLocal = MockUserRepositoryLocal();
    loggedUserNotifier = MockUserNotifier();
    reloadNotifier = MockReloadNotifier();
    themeService = MockThemeService();
    colorImageService = MockColorImageService();
  });

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

  test(
    'enableUseWallpaperAsThemeColor keeps the toggle and falls back to the '
    'account colour when there is no wallpaper to sample',
    () async {
      final StreamController<User> users = StreamController<User>.broadcast();
      addTearDown(users.close);
      when(() => loggedUserNotifier.userStream).thenAnswer((_) => users.stream);

      final SettingsCubit cubit = SettingsCubit(
        userRepository,
        userRepositoryLocal,
        loggedUserNotifier,
        reloadNotifier,
        themeService,
        colorImageService,
      );
      addTearDown(cubit.close);

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
}

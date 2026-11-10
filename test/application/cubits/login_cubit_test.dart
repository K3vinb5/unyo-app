// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/login_cubit.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/theme/color_image_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/data/repositories/user_repository_local.dart';
import 'package:unyo/data/repositories/user_repository_mal.dart';
import 'package:unyo/data/repositories/user_repository_shikimori.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

class MockThemeService extends Mock implements ThemeService {}

class MockColorImageService extends Mock implements ColorImageService {}

class MockUserNotifier extends Mock implements UserNotifier {}

class MockUserRepositoryLocal extends Mock implements UserRepositoryLocal {}

class MockUserRepositoryAnilist extends Mock implements UserRepositoryAnilist {}

class MockUserRepositoryShikimori extends Mock implements UserRepositoryShikimori {}

class MockUserRepositoryMal extends Mock implements UserRepositoryMal {}

/// The three wallpaper colours used by the happy path (distinct on purpose so
/// a swapped primary/secondary/tertiary shows up as a mismatch).
const Color _wallpaperPrimary = Color(0xFF112233);
const Color _wallpaperSecondary = Color(0xFF445566);
const Color _wallpaperTertiary = Color(0xFF778899);

ShikimoriUserModel shikimoriUser({required bool useWallpaperAsThemeColor}) {
  return ShikimoriUserModel(
    id: '123',
    name: 'shiki',
    settings: SettingsModel.empty().copyWith(
      useWallpaperAsThemeColor: useWallpaperAsThemeColor,
    ),
    avatarImage: 'https://example.test/avatar.png',
    // Shikimori's `currentUser` carries no banner at all (WP #64).
    bannerImage: '',
    accessToken: 'access',
    refreshToken: 'refresh',
    accessTokenExpiresAt: '',
    profileUrl: 'https://shikimori.test/shiki',
  );
}

AnilistUserModel anilistUser({
  required String bannerImage,
  required bool useWallpaperAsThemeColor,
}) {
  return AnilistUserModel(
    id: '456',
    name: 'ani',
    settings: SettingsModel.empty().copyWith(
      useWallpaperAsThemeColor: useWallpaperAsThemeColor,
    ),
    avatarImage: 'https://example.test/avatar.png',
    bannerImage: bannerImage,
    accessCode: '',
    accessToken: 'access',
    refreshToken: 'refresh',
  );
}

void main() {
  late MockUserRepositoryLocal userRepositoryLocal;
  late MockUserRepositoryAnilist userRepositoryAnilist;
  late MockUserRepositoryShikimori userRepositoryShikimori;
  late MockUserRepositoryMal userRepositoryMal;
  late MockUserNotifier loggedUserNotifier;
  late MockUserNotifier newUserNotifier;
  late MockColorImageService colorImageService;
  late MockThemeService themeService;

  setUpAll(() {
    if (!sl.isRegistered<Logger>()) {
      sl.registerSingleton<Logger>(Logger(level: Level.off));
    }
    registerFallbackValue(const NetworkImage('https://example.test/fallback.png'));
  });

  setUp(() {
    userRepositoryLocal = MockUserRepositoryLocal();
    userRepositoryAnilist = MockUserRepositoryAnilist();
    userRepositoryShikimori = MockUserRepositoryShikimori();
    userRepositoryMal = MockUserRepositoryMal();
    loggedUserNotifier = MockUserNotifier();
    newUserNotifier = MockUserNotifier();
    colorImageService = MockColorImageService();
    themeService = MockThemeService();

    // LoginCubit's constructor body calls `_init()`, which subscribes to the
    // new-user notifier; an empty stream keeps it inert.
    when(() => newUserNotifier.userStream).thenAnswer(
      (_) => const Stream<User>.empty(),
    );
  });

  LoginCubit createCubit() => LoginCubit(
    userRepositoryLocal,
    loggedUserNotifier,
    newUserNotifier,
    userRepositoryAnilist,
    userRepositoryShikimori,
    userRepositoryMal,
    colorImageService,
    themeService,
  );

  group('LoginCubit.setUsersTheme', () {
    test(
      'falls back to the stored colour for a Shikimori account with no banner',
      () async {
        final ShikimoriUserModel user = shikimoriUser(
          useWallpaperAsThemeColor: true,
        );
        final LoginCubit cubit = createCubit();
        addTearDown(cubit.close);

        expect(() => cubit.setUsersTheme(user), returnsNormally);
        await pumpEventQueue();

        verify(
          () => themeService.updateThemeFromColors(
            loggedUser: user,
            useWallpaperAsThemeColor: true,
            primary: user.settings.themeColor,
          ),
        ).called(1);
        verifyNever(
          () => colorImageService.getColorsFromPalleteGenerator(any()),
        );
      },
    );

    test('applies all three wallpaper colours when the banner samples fine', () async {
      final AnilistUserModel user = anilistUser(
        bannerImage: 'https://example.test/banner.png',
        useWallpaperAsThemeColor: true,
      );
      when(() => colorImageService.getColorsFromPalleteGenerator(any()))
          .thenAnswer(
        (_) async => const <Color>[
          _wallpaperPrimary,
          _wallpaperSecondary,
          _wallpaperTertiary,
        ],
      );
      final LoginCubit cubit = createCubit();
      addTearDown(cubit.close);

      cubit.setUsersTheme(user);
      await pumpEventQueue();

      verify(
        () => themeService.updateThemeFromColors(
          loggedUser: user,
          useWallpaperAsThemeColor: true,
          primary: _wallpaperPrimary,
          secondary: _wallpaperSecondary,
          tertiary: _wallpaperTertiary,
        ),
      ).called(1);
    });

    test(
      'falls back to the stored colour when the Anilist banner fails to load',
      () async {
        final AnilistUserModel user = anilistUser(
          bannerImage: 'https://example.test/broken.png',
          useWallpaperAsThemeColor: true,
        );
        // A failed/unusable banner: the colour service returns nothing.
        when(() => colorImageService.getColorsFromPalleteGenerator(any()))
            .thenAnswer((_) async => const <Color>[]);
        final LoginCubit cubit = createCubit();
        addTearDown(cubit.close);

        expect(() => cubit.setUsersTheme(user), returnsNormally);
        await pumpEventQueue();

        verify(
          () => themeService.updateThemeFromColors(
            loggedUser: user,
            useWallpaperAsThemeColor: true,
            primary: user.settings.themeColor,
          ),
        ).called(1);
      },
    );

    test('keeps a stored non-wallpaper preference and applies it', () async {
      final ShikimoriUserModel user = shikimoriUser(
        useWallpaperAsThemeColor: false,
      );
      final LoginCubit cubit = createCubit();
      addTearDown(cubit.close);

      cubit.setUsersTheme(user);
      await pumpEventQueue();

      verify(
        () => themeService.updateThemeFromColors(
          loggedUser: user,
          useWallpaperAsThemeColor: false,
          primary: user.settings.themeColor,
        ),
      ).called(1);
      verifyNever(() => colorImageService.getColorsFromPalleteGenerator(any()));
    });
  });
}

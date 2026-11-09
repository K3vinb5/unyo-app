// External dependencies
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/login_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/enums/login_card_type.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/theme/color_image_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/data/repositories/repositories.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:logger/logger.dart';

class MockLogger extends Mock implements Logger {}

class MockBuildContext extends Mock implements BuildContext {}

class MockUserRepositoryLocal extends Mock implements UserRepositoryLocal {}

class MockUserRepositoryAnilist extends Mock implements UserRepositoryAnilist {}

class MockUserRepositoryShikimori extends Mock implements UserRepositoryShikimori {}

class MockUserRepositoryMal extends Mock implements UserRepositoryMal {}

class MockThemeService extends Mock implements ThemeService {}

class MockColorImageService extends Mock implements ColorImageService {}

/// WP #156: the `LoginCubit` wiring for the MyAnimeList account — the
/// `LoginCardType.mal` branch, the `MalUserModel` case of the login switch, and
/// the `malUsers` box joining `fetchAllUsers` (degrading when the MAL repository
/// is unavailable so the login screen cannot die on one repository).
void main() {
  late MockUserRepositoryLocal localRepo;
  late MockUserRepositoryAnilist anilistRepo;
  late MockUserRepositoryShikimori shikimoriRepo;
  late MockUserRepositoryMal malRepo;
  late UserNotifier loggedUser;
  late UserNotifier newUser;
  late MockColorImageService colorImageService;
  late MockThemeService themeService;
  late LoginCubit cubit;

  MalUserModel malUser({
    String accessToken = 'stored-access',
    bool useWallpaperAsThemeColor = false,
  }) {
    return MalUserModel(
      id: '56789',
      name: 'tester',
      settings: SettingsModel.empty().copyWith(
        userService: Service.mal,
        useWallpaperAsThemeColor: useWallpaperAsThemeColor,
      ),
      avatarImage: '',
      bannerImage: '',
      accessToken: accessToken,
      refreshToken: 'stored-refresh',
      accessTokenExpiresAt: '2099-01-01T00:00:00.000',
      profileUrl: '',
    );
  }

  setUpAll(() {
    registerFallbackValue(malUser());
    registerFallbackValue(const NetworkImage('https://example.test/fallback.png'));
  });

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(MockLogger());
    localRepo = MockUserRepositoryLocal();
    anilistRepo = MockUserRepositoryAnilist();
    shikimoriRepo = MockUserRepositoryShikimori();
    malRepo = MockUserRepositoryMal();
    loggedUser = UserNotifier();
    newUser = UserNotifier();
    colorImageService = MockColorImageService();
    themeService = MockThemeService();
    cubit = LoginCubit(
      localRepo,
      loggedUser,
      newUser,
      anilistRepo,
      shikimoriRepo,
      colorImageService,
      themeService,
      userRepositoryMal: malRepo,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test('LoginCardType.mal dispatches to the MyAnimeList repository', () async {
    when(() => malRepo.attemptCreateUser()).thenAnswer((_) async {});
    final BuildContext context = MockBuildContext();
    when(() => context.mounted).thenReturn(true);

    cubit.selectLoginType(LoginCardType.mal);
    await cubit.attemptToCreateUser(context);

    verify(() => malRepo.attemptCreateUser()).called(1);
  });

  test('loginUser takes the MalUserModel case, refreshes the token and routes on', () async {
    final MalUserModel user = malUser();
    final MalUserModel fresh = user.copyWith(accessToken: 'fresh-access');
    when(() => malRepo.ensureFreshAccessToken(any())).thenAnswer((_) async => fresh);

    await cubit.loginUser(user, MockBuildContext());

    verify(() => malRepo.ensureFreshAccessToken(any())).called(1);
    expect(loggedUser.currentUser.name, 'tester');
    expect((loggedUser.currentUser as MalUserModel).accessToken, 'fresh-access');
    expect(
      cubit.state.effects.whereType<ReplaceRouteEffect>().map((ReplaceRouteEffect e) => e.routeName),
      <String>['/tabs'],
      reason: 'a MyAnimeList account lands on the tabs route like every other account',
    );
  });

  test('fetchAllUsers joins the malUsers box into the picker', () async {
    final User localUser = UserModel.empty().copyWith(name: 'local');
    when(() => localRepo.fetchAllLoggedInUsers()).thenAnswer((_) async => <User>[localUser]);
    when(() => anilistRepo.fetchAllLoggedInUsers()).thenAnswer((_) async => <User>[]);
    when(() => shikimoriRepo.fetchAllLoggedInUsers()).thenAnswer((_) async => <User>[]);
    when(() => malRepo.fetchAllLoggedInUsers()).thenAnswer((_) async => <User>[malUser()]);

    await cubit.fetchAllUsers();

    expect(
      cubit.state.availableUsers.map((User user) => user.name).toList(),
      <String>['tester', 'local'],
      reason: 'MyAnimeList accounts sort with the other providers, before the local stubs',
    );
    expect(cubit.state.isLoading, isFalse);
  });

  test('setUsersTheme keeps the stored preference for a MAL account with no banner', () async {
    final MalUserModel user = malUser(useWallpaperAsThemeColor: true);

    cubit.setUsersTheme(user);
    await pumpEventQueue();

    verify(
      () => themeService.updateThemeFromColors(
        loggedUser: user,
        useWallpaperAsThemeColor: true,
        primary: user.settings.themeColor,
      ),
    ).called(1);
    verifyNever(() => colorImageService.getColorsFromPalleteGenerator(any()));
  });

  test('a dead MAL repository degrades to the other accounts instead of failing the screen', () async {
    final User localUser = UserModel.empty().copyWith(name: 'local');
    when(() => localRepo.fetchAllLoggedInUsers()).thenAnswer((_) async => <User>[localUser]);
    when(() => anilistRepo.fetchAllLoggedInUsers()).thenAnswer((_) async => <User>[]);
    when(() => shikimoriRepo.fetchAllLoggedInUsers()).thenAnswer((_) async => <User>[]);
    when(() => malRepo.fetchAllLoggedInUsers()).thenThrow(StateError('UserRepositoryMal is not registered'));

    await cubit.fetchAllUsers();

    expect(cubit.state.availableUsers.map((User user) => user.name).toList(), <String>['local']);
    expect(cubit.state.isLoading, isFalse);
  });
}

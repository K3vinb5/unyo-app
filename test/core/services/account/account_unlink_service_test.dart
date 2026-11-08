// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/account/account_unlink_service.dart';
import 'package:unyo/core/services/api/http/response_cache_scope.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/data/repositories/user_repository_local.dart';
import 'package:unyo/data/repositories/user_repository_shikimori.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

class MockUserRepositoryAnilist extends Mock implements UserRepositoryAnilist {}

class MockUserRepositoryShikimori extends Mock implements UserRepositoryShikimori {}

class MockUserRepositoryLocal extends Mock implements UserRepositoryLocal {}

class MockUserNotifier extends Mock implements UserNotifier {}

class MockThemeService extends Mock implements ThemeService {}

class _FakeUser extends Fake implements User {}

AnilistUserModel anilistUser(String name) => AnilistUserModel(
  id: '1',
  name: name,
  settings: SettingsModel.empty().copyWith(userService: Service.anilist),
  avatarImage: '',
  bannerImage: '',
  accessCode: 'code',
  accessToken: 'token',
  refreshToken: 'refresh',
);

ShikimoriUserModel shikimoriUser(String name) => ShikimoriUserModel(
  id: '2',
  name: name,
  settings: SettingsModel.empty().copyWith(userService: Service.shikimori),
  avatarImage: '',
  bannerImage: '',
  accessToken: 'token',
  refreshToken: 'refresh',
  accessTokenExpiresAt: '',
  profileUrl: '',
);

LocalUserModel localUser(String name) => LocalUserModel(
  id: '3',
  name: name,
  settings: SettingsModel.empty(),
  avatarImage: '',
  bannerImage: '',
);

/// The removal checklist of WP #151, asserted step by step: the stored row, both
/// notifiers, the theme fallback, the response-cache revision and the routing
/// verdict.
void main() {
  late MockUserRepositoryAnilist anilist;
  late MockUserRepositoryShikimori shikimori;
  late MockUserRepositoryLocal local;
  late MockUserNotifier loggedUserNotifier;
  late MockUserNotifier newUserNotifier;
  late MockThemeService themeService;
  late ResponseCacheScope cacheScope;

  setUpAll(() {
    registerFallbackValue(_FakeUser());
    registerFallbackValue(Colors.black);
  });

  setUp(() {
    if (!sl.isRegistered<Logger>()) {
      sl.registerSingleton<Logger>(Logger(level: Level.off));
    }
    anilist = MockUserRepositoryAnilist();
    shikimori = MockUserRepositoryShikimori();
    local = MockUserRepositoryLocal();
    loggedUserNotifier = MockUserNotifier();
    newUserNotifier = MockUserNotifier();
    themeService = MockThemeService();
    cacheScope = ResponseCacheScope();

    when(() => anilist.fetchAllLoggedInUsers()).thenAnswer((_) async => <User>[]);
    when(() => shikimori.fetchAllLoggedInUsers()).thenAnswer((_) async => <User>[]);
    when(() => local.fetchAllLoggedInUsers()).thenAnswer((_) async => <User>[]);
    when(() => anilist.removeUser(any())).thenAnswer((_) async {});
    when(() => shikimori.removeUser(any())).thenAnswer((_) async {});
    when(() => local.removeUser(any())).thenAnswer((_) async {});
    when(() => themeService.defaultPrimaryColor).thenReturn(Colors.purple);
    when(() => themeService.defaultSecondaryColor).thenReturn(Colors.deepPurple);
    when(() => themeService.defaultTertiaryColor).thenReturn(Colors.purpleAccent);
  });

  AccountUnlinkService service() => AccountUnlinkService(
    anilist,
    shikimori,
    local,
    loggedUserNotifier,
    newUserNotifier,
    themeService,
    cacheScope,
  );

  void verifyCleanup() {
    verify(() => loggedUserNotifier.clear()).called(1);
    verify(() => newUserNotifier.clear()).called(1);
    verify(
      () => themeService.updateThemeFromColors(
        loggedUser: null,
        useWallpaperAsThemeColor: null,
        primary: any(named: 'primary'),
        secondary: any(named: 'secondary'),
        tertiary: any(named: 'tertiary'),
      ),
    ).called(1);
  }

  test('removes an AniList account through its own provider box', () async {
    final AccountUnlinkResult result = await service().unlink(anilistUser('alice'));

    verify(() => anilist.removeUser(any())).called(1);
    verifyNever(() => shikimori.removeUser(any()));
    verifyNever(() => local.removeUser(any()));
    verifyCleanup();
    expect(cacheScope.revision, 1, reason: 'cached payloads of the account must not survive');
    expect(result.destination, UnlinkDestination.login);
    expect(result.remainingUsers, isEmpty);
  });

  test('removes a Shikimori account through its own provider box', () async {
    await service().unlink(shikimoriUser('alice'));

    verify(() => shikimori.removeUser(any())).called(1);
    verifyNever(() => anilist.removeUser(any()));
    verifyCleanup();
  });

  test('a local account is dispatched to the local repository', () async {
    await service().unlink(localUser('offline'));

    verify(() => local.removeUser(any())).called(1);
    verifyNever(() => anilist.removeUser(any()));
    verifyNever(() => shikimori.removeUser(any()));
  });

  test('lands on the picker while other accounts remain', () async {
    final AnilistUserModel survivor = anilistUser('bob');
    when(() => anilist.fetchAllLoggedInUsers()).thenAnswer((_) async => <User>[survivor]);

    final AccountUnlinkResult result = await service().unlink(anilistUser('alice'));

    expect(result.remainingUsers.map((User user) => user.name), <String>['bob']);
    expect(result.destination, UnlinkDestination.picker);
    expect(UnlinkDestination.picker.route, '/login');
  });

  test('a failing removal still clears every derived state, then rethrows', () async {
    when(() => anilist.removeUser(any())).thenAnswer(
      (_) => Future<void>.error(StateError('box is locked')),
    );

    await expectLater(
      service().unlink(anilistUser('alice')),
      throwsA(isA<StateError>()),
    );

    verifyCleanup();
    expect(cacheScope.revision, 1);
  });

  test('a failing theme reset still clears the rest, then rethrows', () async {
    when(
      () => themeService.updateThemeFromColors(
        loggedUser: null,
        useWallpaperAsThemeColor: null,
        primary: any(named: 'primary'),
        secondary: any(named: 'secondary'),
        tertiary: any(named: 'tertiary'),
      ),
    ).thenThrow(StateError('no preferences store'));

    await expectLater(
      service().unlink(anilistUser('alice')),
      throwsA(isA<StateError>()),
    );

    verify(() => anilist.removeUser(any())).called(1);
    verify(() => loggedUserNotifier.clear()).called(1);
    verify(() => newUserNotifier.clear()).called(1);
    expect(cacheScope.revision, 1, reason: 'the cache is invalidated even after a failed step');
  });

  test('an unreadable account list degrades to the login card', () async {
    when(() => anilist.fetchAllLoggedInUsers()).thenThrow(StateError('box is locked'));

    final AccountUnlinkResult result = await service().unlink(anilistUser('alice'));

    expect(result.remainingUsers, isEmpty);
    expect(result.destination, UnlinkDestination.login);
  });

  test('the routing verdict is the documented rule', () {
    expect(UnlinkDestination.destinationFor(0), UnlinkDestination.login);
    expect(UnlinkDestination.destinationFor(1), UnlinkDestination.picker);
    expect(UnlinkDestination.destinationFor(4), UnlinkDestination.picker);
  });
}

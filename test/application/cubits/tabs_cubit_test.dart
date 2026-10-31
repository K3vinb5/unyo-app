// External dependencies
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/tabs_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/notification/menu_bar_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/api/dto/github/github_release_entity.dart';
import 'package:unyo/core/services/update/app_version_provider.dart';
import 'package:unyo/core/services/update/update_check_result.dart';
import 'package:unyo/core/services/update/update_checker_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/dialogs/update_available_dialog.dart';
import 'package:unyo/presentation/dialogs/user_profile_dialog.dart';

class MockThemeService extends Mock implements ThemeService {}

class MockUserNotifier extends Mock implements UserNotifier {}

class MockMenuBarNotifier extends Mock implements MenuBarNotifier {}

class MockUpdateCheckerService extends Mock implements UpdateCheckerService {}

class MockAppVersionProvider extends Mock implements AppVersionProvider {}

/// A newer published release, shaped the way the checker's bean arrives.
GithubReleaseEntity newerRelease({
  String body = '- something changed',
  List<GithubReleaseAssets> assets = const [],
}) => GithubReleaseEntity()
  ..tagName = 'v0.9.0'
  ..htmlUrl = 'https://github.com/K3vinb5/Unyo/releases/tag/v0.9.0'
  ..body = body
  ..assets = assets;

void main() {
  late MockThemeService themeService;
  late MockUserNotifier loggedUserNotifier;
  late MockMenuBarNotifier menuBarNotifier;
  late MockUpdateCheckerService updateCheckerService;
  late MockAppVersionProvider versionProvider;

  setUpAll(() {
    if (!sl.isRegistered<Logger>()) {
      sl.registerSingleton<Logger>(Logger(level: Level.off));
    }
  });

  setUp(() {
    themeService = MockThemeService();
    loggedUserNotifier = MockUserNotifier();
    menuBarNotifier = MockMenuBarNotifier();
    updateCheckerService = MockUpdateCheckerService();
    versionProvider = MockAppVersionProvider();

    when(
      () => loggedUserNotifier.userStream,
    ).thenAnswer((_) => const Stream<User>.empty());
    when(
      () => menuBarNotifier.menuBarStream,
    ).thenAnswer((_) => const Stream<bool>.empty());
    when(
      () => versionProvider.currentVersion(),
    ).thenAnswer((_) async => '0.8.0');
    when(
      () => updateCheckerService.checkForUpdate(any()),
    ).thenAnswer((_) async => const UpToDate());
  });

  TabsCubit createCubit() => TabsCubit(
    themeService,
    loggedUserNotifier,
    menuBarNotifier,
    updateCheckerService,
    versionProvider,
  );

  group('TabsCubit startup update check', () {
    test(
      'opens the release-notes dialog when a newer release exists',
      () async {
        when(() => updateCheckerService.checkForUpdate('0.8.0')).thenAnswer(
          (_) async => UpdateAvailable(
            release: newerRelease(
              body:
                  "## What's changed\n\n- Release notes now open in a dialog.",
              assets: [
                GithubReleaseAssets()
                  ..name = 'Unyo-v0.9.0-linux.AppImage'
                  ..browserDownloadUrl =
                      'https://github.com/K3vinb5/Unyo/releases/download/v0.9.0/Unyo-v0.9.0-linux.AppImage',
              ],
            ),
            latestVersion: '0.9.0',
          ),
        );
        final TabsCubit cubit = createCubit();
        addTearDown(cubit.close);

        await pumpEventQueue();

        final ShowWidgetDialogEffect effect = cubit.state.effects.single as ShowWidgetDialogEffect;
        final UpdateAvailableDialog dialog = effect.dialog as UpdateAvailableDialog;
        expect(dialog.latestVersion, '0.9.0');
        expect(
          dialog.release.body,
          contains('Release notes now open in a dialog.'),
        );
        expect(dialog.release.assets.single.name, 'Unyo-v0.9.0-linux.AppImage');
        expect(dialog.onOpenReleasePage, isNotNull);
      },
    );

    test(
      'shows the dialog again on the next launch (dismissing only silences the run)',
      () async {
        when(() => updateCheckerService.checkForUpdate('0.8.0')).thenAnswer(
          (_) async => UpdateAvailable(
            release: newerRelease(),
            latestVersion: '0.9.0',
          ),
        );

        final TabsCubit firstLaunch = createCubit();
        await pumpEventQueue();
        final ShowWidgetDialogEffect firstEffect =
            firstLaunch.state.effects.single as ShowWidgetDialogEffect;
        expect(firstEffect.dialog, isA<UpdateAvailableDialog>());
        await firstLaunch.close();

        // Nothing acknowledged is persisted: the next launch nudges again.
        final TabsCubit secondLaunch = createCubit();
        addTearDown(secondLaunch.close);
        await pumpEventQueue();
        final ShowWidgetDialogEffect secondEffect =
            secondLaunch.state.effects.single as ShowWidgetDialogEffect;
        expect(secondEffect.dialog, isA<UpdateAvailableDialog>());
        verify(() => updateCheckerService.checkForUpdate('0.8.0')).called(2);
      },
    );

    test('shows nothing when the app is up to date', () async {
      final TabsCubit cubit = createCubit();
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state.effects, isEmpty);
    });

    test('stays silent when the check fails', () async {
      when(() => updateCheckerService.checkForUpdate(any())).thenAnswer(
        (_) async =>
            const UpdateCheckFailed('GitHub responded with status 500'),
      );
      final TabsCubit cubit = createCubit();
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state.effects, isEmpty);
    });

    test('stays silent when the running version cannot be read', () async {
      when(
        () => versionProvider.currentVersion(),
      ).thenAnswer((_) async => null);
      final TabsCubit cubit = createCubit();
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state.effects, isEmpty);
      verifyNever(() => updateCheckerService.checkForUpdate(any()));
    });

    test('checks once per launch even when it is kicked again', () async {
      final TabsCubit cubit = createCubit();
      addTearDown(cubit.close);

      await pumpEventQueue();
      await cubit.checkForUpdate();

      verify(() => versionProvider.currentVersion()).called(1);
      verify(() => updateCheckerService.checkForUpdate('0.8.0')).called(1);
    });
  });

  group('TabsCubit profile dialog', () {
    /// Signs a user in through the notifier the shell listens to.
    Future<TabsCubit> withLoggedUser(StreamController<User> users, User user) async {
      when(() => loggedUserNotifier.userStream).thenAnswer((_) => users.stream);
      final TabsCubit cubit = createCubit();
      addTearDown(cubit.close);
      users.add(user);
      await pumpEventQueue();
      return cubit;
    }

    test('opens the profile card of the signed-in account', () async {
      final StreamController<User> users = StreamController<User>.broadcast();
      addTearDown(users.close);
      final User user = UserModel(
        id: '12345',
        name: 'alice',
        settings: SettingsModel.empty().copyWith(userService: Service.anilist),
        avatarImage: 'https://example.test/avatar.png',
        bannerImage: '',
      );
      final TabsCubit cubit = await withLoggedUser(users, user);

      cubit.openUserProfileDialog();

      final ShowWidgetDialogEffect effect = cubit.state.effects.single as ShowWidgetDialogEffect;
      final UserProfileDialog dialog = effect.dialog as UserProfileDialog;
      expect(dialog.user.name, 'alice');
      expect(dialog.user.id, '12345');
    });
  });
}

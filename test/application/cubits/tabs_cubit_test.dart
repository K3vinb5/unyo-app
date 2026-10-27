// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/tabs_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/notification/menu_bar_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/update/app_version_provider.dart';
import 'package:unyo/core/services/update/update_check_result.dart';
import 'package:unyo/core/services/update/update_checker_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/dialogs/update_available_dialog.dart';

class MockThemeService extends Mock implements ThemeService {}

class MockUserNotifier extends Mock implements UserNotifier {}

class MockMenuBarNotifier extends Mock implements MenuBarNotifier {}

class MockUpdateCheckerService extends Mock implements UpdateCheckerService {}

class MockAppVersionProvider extends Mock implements AppVersionProvider {}

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
          (_) async => const UpdateAvailable(
            latestVersion: '0.9.0',
            releaseUrl: 'https://github.com/K3vinb5/Unyo/releases/tag/v0.9.0',
            releaseNotes:
                "## What's changed\n\n- Release notes now open in a dialog.",
          ),
        );
        final cubit = createCubit();
        addTearDown(cubit.close);

        await pumpEventQueue();

        final effect = cubit.state.effects.single as ShowWidgetDialogEffect;
        final dialog = effect.dialog as UpdateAvailableDialog;
        expect(dialog.latestVersion, '0.9.0');
        expect(
          dialog.releaseNotes,
          contains('Release notes now open in a dialog.'),
        );
        expect(dialog.onOpenReleasePage, isNotNull);
      },
    );

    test('shows nothing when the app is up to date', () async {
      final cubit = createCubit();
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state.effects, isEmpty);
    });

    test('stays silent when the check fails', () async {
      when(() => updateCheckerService.checkForUpdate(any())).thenAnswer(
        (_) async =>
            const UpdateCheckFailed('GitHub responded with status 500'),
      );
      final cubit = createCubit();
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state.effects, isEmpty);
    });

    test('stays silent when the running version cannot be read', () async {
      when(
        () => versionProvider.currentVersion(),
      ).thenAnswer((_) async => null);
      final cubit = createCubit();
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state.effects, isEmpty);
      verifyNever(() => updateCheckerService.checkForUpdate(any()));
    });

    test('checks once per launch even when it is kicked again', () async {
      final cubit = createCubit();
      addTearDown(cubit.close);

      await pumpEventQueue();
      await cubit.checkForUpdate();

      verify(() => versionProvider.currentVersion()).called(1);
      verify(() => updateCheckerService.checkForUpdate('0.8.0')).called(1);
    });
  });
}

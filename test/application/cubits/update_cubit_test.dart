// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/update_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/update_state.dart';
import 'package:unyo/core/services/update/app_version_provider.dart';
import 'package:unyo/core/services/update/update_check_result.dart';
import 'package:unyo/core/services/update/update_checker_service.dart';

class MockUpdateCheckerService extends Mock implements UpdateCheckerService {}

class MockAppVersionProvider extends Mock implements AppVersionProvider {}

void main() {
  late UpdateCubit cubit;
  late MockUpdateCheckerService updateCheckerService;
  late MockAppVersionProvider versionProvider;

  setUp(() {
    updateCheckerService = MockUpdateCheckerService();
    versionProvider = MockAppVersionProvider();
    when(() => versionProvider.currentVersion()).thenAnswer((_) async => '1.0.0');
    cubit = UpdateCubit(
      updateCheckerService,
      versionProvider,
      logger: Logger(level: Level.off),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('UpdateCubit.checkForUpdate', () {
    test('starts in the initial state', () {
      expect(cubit.state.status, UpdateStatus.initial);
      expect(cubit.state.currentVersion, isNull);
      expect(cubit.state.effects, isEmpty);
    });

    test('goes initial -> checking -> upToDate when the service reports no update', () async {
      when(() => updateCheckerService.checkForUpdate('1.0.0')).thenAnswer((_) async => const UpToDate());

      final statuses = <UpdateStatus>[];
      final subscription = cubit.stream.listen((state) => statuses.add(state.status));
      await cubit.checkForUpdate();
      // The stream delivers asynchronously; let the final emit land.
      await pumpEventQueue();
      await subscription.cancel();

      expect(statuses, [UpdateStatus.checking, UpdateStatus.upToDate]);
      expect(cubit.state.currentVersion, '1.0.0');
      expect(cubit.state.effects, isEmpty);
    });

    test('goes initial -> checking -> updateAvailable and queues one snackbar with an action', () async {
      when(() => updateCheckerService.checkForUpdate('1.0.0')).thenAnswer(
        (_) async => const UpdateAvailable(
          latestVersion: '1.2.3',
          releaseUrl: 'https://github.com/K3vinb5/Unyo/releases/tag/v1.2.3',
        ),
      );

      final statuses = <UpdateStatus>[];
      final subscription = cubit.stream.listen((state) => statuses.add(state.status));
      await cubit.checkForUpdate();
      // The stream delivers asynchronously; let the final emit land.
      await pumpEventQueue();
      await subscription.cancel();

      expect(statuses, [UpdateStatus.checking, UpdateStatus.updateAvailable]);
      expect(cubit.state.currentVersion, '1.0.0');
      expect(cubit.state.latestVersion, '1.2.3');
      expect(cubit.state.releaseUrl, 'https://github.com/K3vinb5/Unyo/releases/tag/v1.2.3');
      expect(cubit.state.effects, hasLength(1));
      final effect = cubit.state.effects.single as ShowSnackbarEffect;
      expect(effect.title, "Update available");
      expect(effect.message, contains('1.2.3'));
      expect(effect.actionLabel, "Open releases page");
      expect(effect.onAction, isNotNull);
    });

    test('goes initial -> checking -> checkFailed when the service fails, without throwing', () async {
      when(() => updateCheckerService.checkForUpdate('1.0.0'))
          .thenAnswer((_) async => const UpdateCheckFailed('GitHub responded with status 500'));

      final statuses = <UpdateStatus>[];
      final subscription = cubit.stream.listen((state) => statuses.add(state.status));
      await cubit.checkForUpdate();
      // The stream delivers asynchronously; let the final emit land.
      await pumpEventQueue();
      await subscription.cancel();

      expect(statuses, [UpdateStatus.checking, UpdateStatus.checkFailed]);
      expect(cubit.state.failureReason, 'GitHub responded with status 500');
      expect(cubit.state.currentVersion, '1.0.0');
      expect(cubit.state.effects, isEmpty);
    });

    test('fails silently when the current version cannot be read', () async {
      when(() => versionProvider.currentVersion()).thenAnswer((_) async => null);

      await cubit.checkForUpdate();

      expect(cubit.state.status, UpdateStatus.checkFailed);
      verifyNever(() => updateCheckerService.checkForUpdate(any()));
    });

    test('runs the check only once per process launch', () async {
      when(() => updateCheckerService.checkForUpdate('1.0.0')).thenAnswer((_) async => const UpToDate());

      await cubit.checkForUpdate();
      await cubit.checkForUpdate();

      verify(() => versionProvider.currentVersion()).called(1);
      verify(() => updateCheckerService.checkForUpdate('1.0.0')).called(1);
    });
  });
}

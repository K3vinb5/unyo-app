// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/settings_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/theme/color_image_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/repositories/repositories.dart';
import 'package:unyo/domain/repositories/user_repository.dart';
import 'package:unyo/presentation/dialogs/coming_soon_dialog.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockUserRepositoryLocal extends Mock implements UserRepositoryLocal {}

class MockUserNotifier extends Mock implements UserNotifier {}

class MockReloadNotifier extends Mock implements ReloadNotifier {}

class MockThemeService extends Mock implements ThemeService {}

class MockColorImageService extends Mock implements ColorImageService {}

void main() {
  late SettingsCubit cubit;

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));

    final MockUserNotifier loggedUserNotifier = MockUserNotifier();
    when(() => loggedUserNotifier.userStream).thenAnswer((_) => const Stream.empty());
    final MockReloadNotifier reloadNotifier = MockReloadNotifier();
    when(() => reloadNotifier.reloadStream).thenAnswer((_) => const Stream.empty());

    cubit = SettingsCubit(
      MockUserRepository(),
      MockUserRepositoryLocal(),
      loggedUserNotifier,
      reloadNotifier,
      MockThemeService(),
      MockColorImageService(),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test('the Reader row opens the shared coming-soon notice for reader settings', () {
    cubit.openReaderSettingsDialog();

    final List<ShowWidgetDialogEffect> dialogs = cubit.state.effects.whereType<ShowWidgetDialogEffect>().toList();
    expect(dialogs, hasLength(1));

    final ShowWidgetDialogEffect effect = dialogs.single;
    expect(effect.dialog, isA<ComingSoonDialog>());
    expect((effect.dialog as ComingSoonDialog).feature, ComingSoonFeature.mangaReaderSettings);
  });
}

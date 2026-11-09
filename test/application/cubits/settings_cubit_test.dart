// External dependencies
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
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
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/user_repository.dart';
import 'package:unyo/data/repositories/user_repository_local.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockUserRepositoryLocal extends Mock implements UserRepositoryLocal {}

class MockUserNotifier extends Mock implements UserNotifier {}

class MockReloadNotifier extends Mock implements ReloadNotifier {}

class MockThemeService extends Mock implements ThemeService {}

class MockColorImageService extends Mock implements ColorImageService {}

void main() {
  late SettingsCubit cubit;
  late MockUserRepository userRepository;
  late MockUserRepositoryLocal userRepositoryLocal;
  late MockUserNotifier userNotifier;
  late StreamController<User> userStreamController;

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
    registerFallbackValue(UserModel.empty());
  });

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));

    userRepository = MockUserRepository();
    userRepositoryLocal = MockUserRepositoryLocal();
    userNotifier = MockUserNotifier();
    when(() => userRepository.updateUserInfo(any())).thenAnswer((_) async {});
    when(() => userRepositoryLocal.updateUserInfo(any())).thenAnswer((_) async {});

    userStreamController = StreamController<User>.broadcast();
    addTearDown(userStreamController.close);
    when(() => userNotifier.userStream).thenAnswer((_) => userStreamController.stream);

    cubit = SettingsCubit(
      userRepository,
      userRepositoryLocal,
      userNotifier,
      MockReloadNotifier(),
      MockThemeService(),
      MockColorImageService(),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('SettingsCubit settings persistence', () {
    test('a MalUserModel setting change is saved through the user repository', () async {
      userStreamController.add(malUser());
      await pumpEventQueue();

      await cubit.enableOpenSubtitlesIntegration(true);
      await pumpEventQueue();

      final User saved = verify(() => userRepository.updateUserInfo(captureAny())).captured.single as User;
      expect(saved, isA<MalUserModel>());
      expect(saved.settings.enableOpenSubtitlesIntegration, isTrue);
      verifyNever(() => userRepositoryLocal.updateUserInfo(any()));
    });

    test('a LocalUserModel setting change still goes to the local repository', () async {
      userStreamController.add(localUser());
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

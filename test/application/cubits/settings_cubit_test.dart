// External dependencies
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/settings_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/settings_state.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/domain/entities/user/user.dart';

import '../../support/fakes.dart';
import '../../support/fixtures.dart';
import '../../support/test_deps.dart';

void main() {
  late TestDeps deps;
  late MockUserRepository userRepository;
  late MockUserRepositoryLocal userRepositoryLocal;
  late MockThemeService themeService;
  late MockColorImageService colorImageService;
  late MockReloadNotifier reloadNotifier;
  late StreamController<User> loggedUsers;

  setUp(() async {
    loggedUsers = StreamController<User>.broadcast();
    deps = await TestDeps.setUp();
    userRepository = MockUserRepository();
    userRepositoryLocal = MockUserRepositoryLocal();
    themeService = MockThemeService();
    colorImageService = MockColorImageService();
    reloadNotifier = MockReloadNotifier();
    deps
      ..userRepository = userRepository
      ..userRepositoryLocal = userRepositoryLocal
      ..themeService = themeService
      ..colorImageService = colorImageService
      ..reloadNotifier = reloadNotifier;
    when(() => deps.loggedUserNotifier.userStream).thenAnswer(
      (_) => loggedUsers.stream,
    );
  });

  tearDown(() async {
    await loggedUsers.close();
    await TestDeps.tearDown();
  });

  setUpAll(() => registerFallbackValue(Fixtures.emptyUser()));

  Future<void> signIn(SettingsCubit cubit, User user) async {
    loggedUsers.add(user);
    await pumpEventQueue();
  }

  blocTest<SettingsCubit, SettingsState>(
    'follows the user the notifier publishes',
    build: () => deps.cubit<SettingsCubit>(),
    act: (SettingsCubit cubit) async {
      await signIn(cubit, Fixtures.localUser(id: '7', name: 'carol'));
    },
    expect: () => <Matcher>[isA<SettingsState>()],
    verify: (SettingsCubit cubit) {
      expect(cubit.state.loggedUser.id, '7');
      expect(cubit.state.loggedUser.name, 'carol');
    },
  );

  blocTest<SettingsCubit, SettingsState>(
    'persists a metadata-service switch and scopes the response cache out',
    build: () => deps.cubit<SettingsCubit>(),
    act: (SettingsCubit cubit) async {
      await signIn(cubit, Fixtures.anilistUser());
      await cubit.updateMediaMetadataService('shikimori');
    },
    verify: (SettingsCubit cubit) {
      final User saved =
          verify(() => userRepository.updateUserInfo(captureAny())).captured.single as User;
      expect(saved.settings.metadataService, Service.shikimori);
      expect(deps.responseCacheScope.revision, 1);
      verify(
        () => reloadNotifier.emitReload(ReloadType.newMetadataService),
      ).called(1);
    },
  );

  blocTest<SettingsCubit, SettingsState>(
    'normalizes the persisted UI language',
    build: () => deps.cubit<SettingsCubit>(),
    act: (SettingsCubit cubit) async {
      await signIn(cubit, Fixtures.localUser());
      await cubit.updateLanguage('en');
    },
    verify: (SettingsCubit cubit) {
      final LocalUserModel saved =
          verify(() => userRepositoryLocal.updateUserInfo(captureAny())).captured.single
              as LocalUserModel;
      expect(saved.settings.language, 'en_GB');
    },
  );

  blocTest<SettingsCubit, SettingsState>(
    'reports a failure instead of throwing when the wallpaper has no colours',
    build: () => deps.cubit<SettingsCubit>(),
    act: (SettingsCubit cubit) async {
      await signIn(cubit, Fixtures.localUser());
      await cubit.enableUseWallpaperAsThemeColor(true);
    },
    verify: (SettingsCubit cubit) {
      expect(cubit.state.effects.whereType<ShowSnackbarEffect>(), isNotEmpty);
    },
  );

  blocTest<SettingsCubit, SettingsState>(
    'opens the colour picker as an effect instead of a route',
    build: () => deps.cubit<SettingsCubit>(),
    act: (SettingsCubit cubit) async {
      await signIn(cubit, Fixtures.localUser());
      cubit.openColorPickerDialog(_FakeBuildContext());
    },
    verify: (SettingsCubit cubit) {
      expect(cubit.state.effects.whereType<ShowWidgetDialogEffect>(), hasLength(1));
    },
  );
}

/// The colour-picker entry point takes a context but nothing in this path
/// reads it, so a plain object is enough here.
class _FakeBuildContext extends Mock implements BuildContext {}

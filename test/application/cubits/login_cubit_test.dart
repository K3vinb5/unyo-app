// External dependencies
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/login_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/login_state.dart';
import 'package:unyo/core/enums/login_card_type.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/data/repositories/user_repository_local.dart';
import 'package:unyo/data/repositories/user_repository_shikimori.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

import '../../support/fakes.dart';
import '../../support/fixtures.dart';
import '../../support/test_deps.dart';

class _FakeBuildContext extends Mock implements BuildContext {}

void main() {
  late TestDeps deps;
  late MockUserRepositoryLocal localRepository;
  late MockUserRepositoryAnilist anilistRepository;
  late MockUserRepositoryShikimori shikimoriRepository;
  late MockColorImageService colorImageService;
  late MockThemeService themeService;
  late MockBuildContextHolder context;

  setUp(() async {
    deps = await TestDeps.setUp();
    localRepository = MockUserRepositoryLocal();
    anilistRepository = MockUserRepositoryAnilist();
    shikimoriRepository = MockUserRepositoryShikimori();
    colorImageService = MockColorImageService();
    themeService = MockThemeService();
    deps
      ..replace<UserRepositoryLocal>(localRepository)
      ..replace<UserRepositoryAnilist>(anilistRepository)
      ..replace<UserRepositoryShikimori>(shikimoriRepository)
      ..colorImageService = colorImageService
      ..themeService = themeService;
    context = MockBuildContextHolder(_FakeBuildContext());
  });

  tearDown(TestDeps.tearDown);

  setUpAll(() {
    registerFallbackValue(Fixtures.emptyUser());
    registerFallbackValue(const Color(0xFF000000));
  });

  test('fetchAllUsers merges local and remote account lists', () async {
    when(localRepository.fetchAllLoggedInUsers).thenAnswer(
      (_) async => <User>[Fixtures.localUser(id: '1')],
    );
    when(anilistRepository.fetchAllLoggedInUsers).thenAnswer(
      (_) async => <User>[Fixtures.anilistUser(id: '2')],
    );
    when(shikimoriRepository.fetchAllLoggedInUsers).thenAnswer(
      (_) async => <User>[],
    );
    final LoginCubit cubit = deps.cubit<LoginCubit>();
    addTearDown(cubit.close);

    await cubit.fetchAllUsers();

    expect(cubit.state.availableUsers.map((User user) => user.id), <String>['2', '1']);
    expect(cubit.state.isLoading, isFalse);
  });

  test('fetchAllUsers still settles the loading flag when a repository fails', () async {
    when(localRepository.fetchAllLoggedInUsers).thenThrow(Exception('offline'));
    when(anilistRepository.fetchAllLoggedInUsers).thenAnswer(
      (_) async => <User>[],
    );
    when(shikimoriRepository.fetchAllLoggedInUsers).thenAnswer(
      (_) async => <User>[],
    );
    final LoginCubit cubit = deps.cubit<LoginCubit>();
    addTearDown(cubit.close);

    await expectLater(cubit.fetchAllUsers(), throwsException);

    expect(cubit.state.isLoading, isFalse);
  });

  blocTest<LoginCubit, LoginState>(
    'selectLoginType only emits when the card actually changes',
    build: () => deps.cubit<LoginCubit>(),
    act: (LoginCubit cubit) {
      cubit.selectLoginType(LoginCardType.anilist);
      cubit.selectLoginType(LoginCardType.shikimori);
    },
    expect: () => <Matcher>[
      isA<LoginState>().having(
        (LoginState state) => state.selectedLoginCard,
        'selectedLoginCard',
        LoginCardType.shikimori,
      ),
    ],
  );

  test('logging in a local user applies the theme and replaces the route', () async {
    final LocalUserModel user = Fixtures.localUser(
      settings: SettingsModel.empty().copyWith(useWallpaperAsThemeColor: false),
    );
    final LoginCubit cubit = deps.cubit<LoginCubit>();
    addTearDown(cubit.close);

    await cubit.loginUser(user, context.value);

    verify(
      () => themeService.updateThemeFromColors(
        loggedUser: user,
        useWallpaperAsThemeColor: false,
        primary: user.settings.themeColor,
      ),
    ).called(1);
    expect(
      cubit.state.effects.whereType<ReplaceRouteEffect>().single.routeName,
      '/tabs',
    );
  });

  test('a failed account creation is reported instead of thrown', () async {
    when(
      () => anilistRepository.attemptCreateUser(),
    ).thenThrow(Exception('oauth denied'));
    when(() => context.value.mounted).thenReturn(false);
    final LoginCubit cubit = deps.cubit<LoginCubit>();
    addTearDown(cubit.close);

    await cubit.attemptToCreateUser(context.value);

    expect(cubit.state.effects.whereType<ShowSnackbarEffect>(), isNotEmpty);
  });

  test('creating the selected account type delegates to its repository', () async {
    when(() => anilistRepository.attemptCreateUser()).thenAnswer((_) async {});
    when(() => context.value.mounted).thenReturn(false);
    final LoginCubit cubit = deps.cubit<LoginCubit>();
    addTearDown(cubit.close);

    await cubit.attemptToCreateUser(context.value);

    verify(() => anilistRepository.attemptCreateUser()).called(1);
  });
}

/// Looks like a `BuildContext` to the cubit without a widget tree.
class MockBuildContextHolder {
  MockBuildContextHolder(this.value);

  final BuildContext value;
}

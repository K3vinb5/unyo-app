// External dependencies
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/extensions_cubit.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/extensions_state.dart';
import 'package:unyo/core/enums/extension_type.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

import '../../support/fakes.dart';
import '../../support/fixtures.dart';
import '../../support/test_deps.dart';

void main() {
  late TestDeps deps;
  late MockExtensionRepositoryAniyomi extensionRepository;
  late StreamController<User> loggedUsers;

  final Extension animeExtension = const ExtensionModel(
    name: 'Anime Extension',
    pkg: 'com.test.anime',
    apk: 'anime.apk',
    icon: 'icon.png',
    lang: 'en',
    version: '1.0.0',
    nsfw: 0,
    type: ExtensionType.ANIYOMI,
  );
  final Extension updatedAnimeExtension = const ExtensionModel(
    name: 'Anime Extension',
    pkg: 'com.test.anime',
    apk: 'anime.apk',
    icon: 'icon.png',
    lang: 'en',
    version: '2.0.0',
    nsfw: 0,
    type: ExtensionType.ANIYOMI,
  );

  setUp(() async {
    loggedUsers = StreamController<User>.broadcast();
    deps = await TestDeps.setUp();
    extensionRepository = MockExtensionRepositoryAniyomi();
    deps.extensionRepository = extensionRepository;
    when(() => deps.loggedUserNotifier.userStream).thenAnswer(
      (_) => loggedUsers.stream,
    );
    when(
      () => extensionRepository.getAvailableAnimeExtensions(any()),
    ).thenAnswer((_) async => <Extension>{animeExtension});
    when(
      () => extensionRepository.getAvailableMangaExtensions(any()),
    ).thenAnswer((_) async => <Extension>{});
    when(
      () => extensionRepository.getInstalledAnimeExtensions(any()),
    ).thenAnswer((_) async => <Extension>{});
    when(
      () => extensionRepository.getInstalledMangaExtensions(any()),
    ).thenAnswer((_) async => <Extension>{});
    when(
      () => extensionRepository.getAnimeExtensionUpdates(any()),
    ).thenAnswer((_) async => <String, Extension>{});
    when(
      () => extensionRepository.getMangaExtensionUpdates(any()),
    ).thenAnswer((_) async => <String, Extension>{});
  });

  tearDown(() async {
    await loggedUsers.close();
    await TestDeps.tearDown();
  });

  setUpAll(() {
    registerFallbackValue(Fixtures.emptyUser());
    registerFallbackValue(ExtensionModel.empty());
  });

  Future<void> signIn(ExtensionsCubit cubit) async {
    loggedUsers.add(Fixtures.anilistUser());
    await pumpEventQueue();
  }

  blocTest<ExtensionsCubit, ExtensionsState>(
    'loads every extension list once the user is known',
    build: () => deps.cubit<ExtensionsCubit>(),
    act: signIn,
    verify: (ExtensionsCubit cubit) {
      expect(cubit.state.availableAnimeExtensions, hasLength(1));
      expect(cubit.state.extensionsLoaded, isTrue);
      expect(cubit.state.userLoaded, isTrue);
    },
  );

  blocTest<ExtensionsCubit, ExtensionsState>(
    'a failing endpoint still settles the loaded flag',
    build: () => deps.cubit<ExtensionsCubit>(),
    setUp: () {
      when(
        () => extensionRepository.getAvailableAnimeExtensions(any()),
      ).thenThrow(Exception('offline'));
    },
    act: signIn,
    verify: (ExtensionsCubit cubit) {
      expect(cubit.state.extensionsLoaded, isTrue);
      expect(cubit.state.effects.whereType<ShowSnackbarEffect>(), isNotEmpty);
    },
  );

  test('downloading an extension installs it and confirms', () async {
    when(
      () => extensionRepository.addExtension(animeExtension),
    ).thenAnswer((_) async {});
    final ExtensionsCubit cubit = deps.cubit<ExtensionsCubit>();
    addTearDown(cubit.close);
    await signIn(cubit);

    await cubit.downloadExtension(animeExtension);

    verify(() => extensionRepository.addExtension(animeExtension)).called(1);
    expect(
      cubit.state.effects
          .whereType<ShowSnackbarEffect>()
          .map((ShowSnackbarEffect effect) => effect.titleKey),
      contains('ext_installed_title'),
    );
  });

  test('downloading an already installed version is rejected locally', () async {
    when(
      () => extensionRepository.getInstalledAnimeExtensions(any()),
    ).thenAnswer((_) async => <Extension>{animeExtension});
    final ExtensionsCubit cubit = deps.cubit<ExtensionsCubit>();
    addTearDown(cubit.close);
    await signIn(cubit);

    await cubit.downloadExtension(animeExtension);

    verifyNever(() => extensionRepository.addExtension(any()));
    expect(
      cubit.state.effects
          .whereType<ShowSnackbarEffect>()
          .any((ShowSnackbarEffect effect) => effect.messageKey == 'ext_already_installed'),
      isTrue,
    );
  });

  test('removing a version that is not installed is rejected locally', () async {
    final ExtensionsCubit cubit = deps.cubit<ExtensionsCubit>();
    addTearDown(cubit.close);
    await signIn(cubit);

    await cubit.removeExtension(animeExtension);

    verifyNever(() => extensionRepository.removeExtension(any()));
  });

  test('updating without a published update is rejected locally', () async {
    final ExtensionsCubit cubit = deps.cubit<ExtensionsCubit>();
    addTearDown(cubit.close);
    await signIn(cubit);

    await cubit.updateExtension(animeExtension);

    verifyNever(() => extensionRepository.updateExtension(any(), any()));
    expect(
      cubit.state.effects
          .whereType<ShowSnackbarEffect>()
          .any((ShowSnackbarEffect effect) => effect.messageKey == 'ext_no_update_available'),
      isTrue,
    );
  });

  test('updating a published extension installs the new version', () async {
    when(
      () => extensionRepository.getAnimeExtensionUpdates(any()),
    ).thenAnswer(
      (_) async => <String, Extension>{
        animeExtension.pkg: updatedAnimeExtension,
      },
    );
    when(
      () => extensionRepository.updateExtension(any(), any()),
    ).thenAnswer((_) async {});
    final ExtensionsCubit cubit = deps.cubit<ExtensionsCubit>();
    addTearDown(cubit.close);
    await signIn(cubit);

    await cubit.updateExtension(animeExtension);

    verify(
      () => extensionRepository.updateExtension(
        animeExtension,
        updatedAnimeExtension,
      ),
    ).called(1);
  });

  test('repository names are derived from both settings lists', () async {
    final Settings settings = SettingsModel.empty().copyWith(
      aniyomiExtensionsRepositories: <String>[
        'https://raw.githubusercontent.com/foo/repo/main/index.min.json',
      ],
      tachiyomiExtensionsRepositories: <String>[
        'https://example.com/repo.json',
      ],
    );
    final ExtensionsCubit cubit = deps.cubit<ExtensionsCubit>();
    addTearDown(cubit.close);
    loggedUsers.add(Fixtures.anilistUser(settings: settings));
    await pumpEventQueue();

    expect(cubit.getAvailableRepositories(), <String>{'Foo', 'Example'});
  });
}

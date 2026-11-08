// External dependencies
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/video_cubit.dart';
import 'package:unyo/core/enums/video_display_mode.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

import '../../support/fakes.dart';
import '../../support/fixtures.dart';
import '../../support/test_deps.dart';

void main() {
  late TestDeps deps;
  late MockVideoDisplayModeStore displayModeStore;
  late StreamController<User> loggedUsers;

  setUp(() async {
    loggedUsers = StreamController<User>.broadcast();
    deps = await TestDeps.setUp();
    displayModeStore = MockVideoDisplayModeStore();
    deps.videoDisplayModeStore = displayModeStore;
    when(() => deps.loggedUserNotifier.userStream).thenAnswer(
      (_) => loggedUsers.stream,
    );
    when(
      () => displayModeStore.save(any(), any()),
    ).thenAnswer((_) async {});
  });

  tearDown(() async {
    await loggedUsers.close();
    await TestDeps.tearDown();
  });

  setUpAll(() {
    registerFallbackValue(Fixtures.emptyUser());
    registerFallbackValue(VideoDisplayMode.fit);
  });

  test('seeds the display mode from the signed-in user settings', () async {
    final VideoCubit cubit = deps.cubit<VideoCubit>();
    addTearDown(cubit.close);
    final Settings settings = SettingsModel.empty().copyWith(
      videoDisplayMode: VideoDisplayMode.crop,
    );

    loggedUsers.add(Fixtures.anilistUser(settings: settings));
    await pumpEventQueue();

    expect(cubit.state.videoDisplayMode, VideoDisplayMode.crop);
  });

  test('cycles the display mode and persists it for the user', () async {
    final VideoCubit cubit = deps.cubit<VideoCubit>();
    addTearDown(cubit.close);

    await cubit.cycleVideoDisplayMode();

    expect(cubit.state.videoDisplayMode, VideoDisplayMode.crop);
    verify(
      () => displayModeStore.save(cubit.state.loggedUser, VideoDisplayMode.crop),
    ).called(1);
  });

  test('a failed persistence never blocks the mode change', () async {
    when(() => displayModeStore.save(any(), any())).thenThrow(Exception('disk'));
    final VideoCubit cubit = deps.cubit<VideoCubit>();
    addTearDown(cubit.close);

    await cubit.cycleVideoDisplayMode();

    expect(cubit.state.videoDisplayMode, VideoDisplayMode.crop);
  });

  test('the up-next card dismissal is scoped to the playing episode', () async {
    final VideoCubit cubit = deps.cubit<VideoCubit>();
    addTearDown(cubit.close);

    expect(cubit.isUpNextDismissed, isFalse);
    cubit.dismissUpNextCard();
    expect(cubit.isUpNextDismissed, isTrue);
  });

  test('there is no next episode when the playlist is empty', () async {
    final VideoCubit cubit = deps.cubit<VideoCubit>();
    addTearDown(cubit.close);

    expect(cubit.hasNextEpisode, isFalse);
    await cubit.skipToNextEpisode();
    await cubit.skipToPreviousEpisode();
    await cubit.navigateToEpisode(-1);

    expect(cubit.state.effects, isEmpty);
  });
}

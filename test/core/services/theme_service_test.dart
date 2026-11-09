// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/data/repositories/user_repository_local.dart';
import 'package:unyo/data/repositories/user_repository_mal.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

class _MockUserRepositoryAnilist extends Mock implements UserRepositoryAnilist {}

class _MockUserRepositoryLocal extends Mock implements UserRepositoryLocal {}

class _MockUserRepositoryMal extends Mock implements UserRepositoryMal {}

MalUserModel _malUser() => MalUserModel(
      id: '56789',
      name: 'tester',
      settings: SettingsModel.empty(),
      avatarImage: '',
      bannerImage: '',
      accessToken: '',
      refreshToken: '',
      accessTokenExpiresAt: '',
      profileUrl: '',
    );

void main() {
  setUpAll(() {
    registerFallbackValue(UserModel.empty());
  });

  group('ThemeService persistence', () {
    test('a MyAnimeList user theme change is persisted through its repository', () async {
      await sl.reset();
      final mal = _MockUserRepositoryMal();
      sl.registerSingleton<UserRepositoryMal>(mal);
      when(() => mal.updateUserInfo(any())).thenAnswer((_) async {});

      final service = ThemeService(_MockUserRepositoryAnilist(), _MockUserRepositoryLocal());
      final user = _malUser();

      service.updateThemeFromColors(
        loggedUser: user,
        primary: const Color(0xFF123456),
        useWallpaperAsThemeColor: false,
      );
      await pumpEventQueue();

      final saved = verify(() => mal.updateUserInfo(captureAny())).captured.single as MalUserModel;
      expect(saved.id, user.id);
      expect(saved.settings.themeColor, const Color(0xFF123456));
      expect(saved.settings.useWallpaperAsThemeColor, isFalse);
    });
  });
}

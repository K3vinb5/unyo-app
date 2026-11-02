// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/enums/video_display_mode.dart';
import 'package:unyo/core/services/video/video_display_geometry.dart';
import 'package:unyo/core/services/video/video_display_mode_store.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/data/repositories/user_repository_local.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/widgets/styled/unyo_video_controls.dart';

class _MockUserRepositoryAnilist extends Mock implements UserRepositoryAnilist {}

class _MockUserRepositoryLocal extends Mock implements UserRepositoryLocal {}

AnilistUserModel _userWith(Settings settings) => AnilistUserModel(
      id: '1',
      name: 'kevin',
      settings: settings,
      avatarImage: '',
      bannerImage: '',
      accessCode: '',
      accessToken: '',
      refreshToken: '',
    );

void main() {
  setUpAll(() {
    registerFallbackValue(UserModel.empty());
  });

  group('cycling', () {
    test('Fit -> Crop -> Stretch -> Fit', () {
      expect(nextVideoDisplayMode(VideoDisplayMode.fit), VideoDisplayMode.crop);
      expect(nextVideoDisplayMode(VideoDisplayMode.crop), VideoDisplayMode.stretch);
      expect(nextVideoDisplayMode(VideoDisplayMode.stretch), VideoDisplayMode.fit);
    });

    test('wraps after three steps back to the starting mode', () {
      var mode = VideoDisplayMode.fit;
      for (var i = 0; i < 3; i++) {
        mode = nextVideoDisplayMode(mode);
      }
      expect(mode, VideoDisplayMode.fit);
    });
  });

  group('button affordances', () {
    test('each mode has its own glyph', () {
      final icons = VideoDisplayMode.values.map(UnyoVideoControls.videoDisplayModeIcon).toSet();
      expect(icons, hasLength(3));
    });

    test('icon follows the current mode', () {
      expect(
        UnyoVideoControls.videoDisplayModeIcon(VideoDisplayMode.crop),
        Icons.crop_rounded,
      );
    });

    test('tooltip names the current and the next mode', () {
      expect(UnyoVideoControls.videoDisplayModeTooltip(VideoDisplayMode.fit), contains('Fit'));
      expect(UnyoVideoControls.videoDisplayModeTooltip(VideoDisplayMode.fit), contains('Crop'));
      expect(UnyoVideoControls.videoDisplayModeTooltip(VideoDisplayMode.stretch), contains('Stretch'));
      expect(UnyoVideoControls.videoDisplayModeTooltip(VideoDisplayMode.stretch), contains('Fit'));
    });
  });

  group('geometry', () {
    const Size wide = Size(1920, 1080); // 16:9 viewport
    const Size portraitish = Size(1000, 1000); // 1:1 viewport

    test('16:9 stream in a 16:9 viewport fills exactly in every mode', () {
      for (final mode in VideoDisplayMode.values) {
        final size = videoSurfaceSize(mode: mode, viewport: wide, streamAspectRatio: 16 / 9);
        expect(size.width, closeTo(1920, 0.01), reason: '$mode');
        expect(size.height, closeTo(1080, 0.01), reason: '$mode');
      }
    });

    test('4:3 stream, Fit letterboxes (pillarboxes) the frame', () {
      final size = videoSurfaceSize(mode: VideoDisplayMode.fit, viewport: wide, streamAspectRatio: 4 / 3);
      expect(size.height, closeTo(1080, 0.01));
      expect(size.width, closeTo(1440, 0.01));
      expect(size.width, lessThan(wide.width));
    });

    test('4:3 stream, Crop covers and overflows vertically', () {
      final size = videoSurfaceSize(mode: VideoDisplayMode.crop, viewport: wide, streamAspectRatio: 4 / 3);
      expect(size.width, closeTo(1920, 0.01));
      expect(size.height, closeTo(1440, 0.01));
      expect(size.height, greaterThan(wide.height));
      expect(
        videoSurfaceOverflows(mode: VideoDisplayMode.crop, viewport: wide, streamAspectRatio: 4 / 3),
        isTrue,
      );
    });

    test('4:3 stream, Stretch fills the viewport without preserving the ratio', () {
      final size = videoSurfaceSize(mode: VideoDisplayMode.stretch, viewport: wide, streamAspectRatio: 4 / 3);
      expect(size, wide);
    });

    test('Fit never overflows, in any viewport/ratio combination', () {
      for (final viewport in [wide, portraitish, const Size(1280, 720), const Size(800, 1200)]) {
        for (final ratio in [16 / 9, 4 / 3, 2.35, 1.0]) {
          final size = videoSurfaceSize(mode: VideoDisplayMode.fit, viewport: viewport, streamAspectRatio: ratio);
          expect(size.width, lessThanOrEqualTo(viewport.width + 0.01));
          expect(size.height, lessThanOrEqualTo(viewport.height + 0.01));
          expect(videoSurfaceOverflows(mode: VideoDisplayMode.fit, viewport: viewport, streamAspectRatio: ratio), isFalse);
        }
      }
    });

    test('an unknown ratio falls back to 16:9, so a late ratio is a resize, not a jump', () {
      final unknown = videoSurfaceSize(mode: VideoDisplayMode.fit, viewport: wide, streamAspectRatio: -1);
      final fallback = videoSurfaceSize(
        mode: VideoDisplayMode.fit,
        viewport: wide,
        streamAspectRatio: fallbackVideoAspectRatio,
      );
      final known = videoSurfaceSize(mode: VideoDisplayMode.fit, viewport: wide, streamAspectRatio: 16 / 9);
      expect(unknown, fallback);
      expect(unknown.width, closeTo(known.width, 0.01));
    });

    test('a zero viewport yields no surface instead of NaN', () {
      expect(
        videoSurfaceSize(mode: VideoDisplayMode.crop, viewport: Size.zero, streamAspectRatio: 16 / 9),
        Size.zero,
      );
    });
  });

  group('persistence', () {
    test('defaults to Fit for a new user', () {
      expect(SettingsModel.empty().videoDisplayMode, VideoDisplayMode.fit);
    });

    test('survives a JSON round-trip (Hive payloads and toJson use the same map)', () {
      final original = SettingsModel.empty().copyWith(videoDisplayMode: VideoDisplayMode.crop);
      final json = original.toJson();
      expect(json['videoDisplayMode'], 'crop');
      expect(SettingsModel.fromJson(json).videoDisplayMode, VideoDisplayMode.crop);
    });

    test('unknown or missing value falls back to Fit', () {
      expect(SettingsModel.fromJson(const {}).videoDisplayMode, VideoDisplayMode.fit);
    });

    test('save() writes the mode onto the logged-in user through its repository', () async {
      final anilist = _MockUserRepositoryAnilist();
      final local = _MockUserRepositoryLocal();
      final store = VideoDisplayModeStore(anilist, local);
      final user = _userWith(SettingsModel.empty());

      when(() => anilist.updateUserInfo(any())).thenAnswer((_) async {});

      await store.save(user, VideoDisplayMode.stretch);

      final saved = verify(() => anilist.updateUserInfo(captureAny())).captured.single as User;
      expect(saved.settings.videoDisplayMode, VideoDisplayMode.stretch);
      verifyNever(() => local.updateUserInfo(any()));
    });
  });
}

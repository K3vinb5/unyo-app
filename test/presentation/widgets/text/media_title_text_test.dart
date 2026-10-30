// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/domain/entities/media/title.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/presentation/widgets/text/media_title_text.dart';

/// Production-path tests for the display-title seam every card, carousel and
/// detail header calls: [displayMediaTitle] resolves the [Title] slot from the
/// **logged user's** `settings.mediaTitleLanguage` (read off the real
/// `UserNotifier` the app registers), not from a constant.
///
/// That is the wiring critique of WP #64(b) round 1: `MediaTitleLanguage.resolve`
/// only had its own unit test, so `Title.russian` never reached a widget.
void main() {
  const Title shikimoriTitle = TitleModel(
    romaji: 'Shingeki no Kyojin',
    english: 'Attack on Titan',
    nativeTitle: '進撃の巨人',
    userPreferred: 'Shingeki no Kyojin',
    russian: 'Атака титанов',
  );

  setUp(() {
    sl.reset();
    sl.registerSingleton<Logger>(Logger(filter: ProductionFilter()));
    sl.registerSingleton<UserNotifier>(UserNotifier(), instanceName: config.loggedUserNotifier);
  });

  tearDown(() => sl.reset());

  void signInWithTitleLanguage(String language) {
    sl<UserNotifier>(instanceName: config.loggedUserNotifier).updateUser(
      AnilistUserModel(
        id: '1',
        name: 'test',
        settings: SettingsModel.empty().copyWith(mediaTitleLanguage: language),
        avatarImage: '',
        bannerImage: '',
        accessCode: '',
        accessToken: '',
        refreshToken: '',
      ),
    );
  }

  group('displayMediaTitle (the widget-facing seam)', () {
    test('renders the Russian slot a Shikimori entry carries', () {
      signInWithTitleLanguage('Russian');

      expect(displayMediaTitle(shikimoriTitle), 'Атака титанов');
    });

    test('renders English when the setting says English', () {
      signInWithTitleLanguage('English');

      expect(displayMediaTitle(shikimoriTitle), 'Attack on Titan');
    });

    test('the Hive default userPreferred keeps today\'s behaviour', () {
      // No sign-in at all: the seeded notifier holds UserModel.empty(), whose
      // default preference is the slot the cards already showed.
      expect(displayMediaTitle(shikimoriTitle), 'Shingeki no Kyojin');
    });

    test('an empty requested slot falls back to userPreferred, never to a blank card', () {
      signInWithTitleLanguage('Russian');
      const Title noRussian = TitleModel(
        romaji: 'Berserk',
        english: '',
        nativeTitle: '',
        userPreferred: 'Berserk',
      );

      expect(displayMediaTitle(noRussian), 'Berserk');
    });
  });
}

// External dependencies
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/widgets/styled/mal_account_settings.dart';

import '../../../support/localized_app.dart';

/// WP #156: the settings account pane mirrors `ShikimoriAccountSettings`
/// (WP #64 subpart (c)) — say whether a MyAnimeList account is connected, show
/// who it is, and log out.
void main() {
  Future<void> pumpPane(WidgetTester tester, {required User loggedUser, required VoidCallback onLogout}) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        // Wrapped in `localizedApp`: the pane's copy comes from `context.tr`,
        // which needs EasyLocalization above the MaterialApp.
        child: localizedApp(
          home: Scaffold(
            body: MalAccountSettings(loggedUser: loggedUser, onLogout: onLogout),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a non-MAL session shows the disconnected state and no logout', (WidgetTester tester) async {
    bool loggedOut = false;
    await pumpPane(tester, loggedUser: UserModel.empty(), onLogout: () => loggedOut = true);

    expect(find.text("No MyAnimeList account is connected"), findsOneWidget);
    expect(find.text("Logout"), findsNothing);

    await tester.tap(find.text("No MyAnimeList account is connected"));
    expect(loggedOut, isFalse);
  });

  testWidgets('a MAL session shows the account and logs out through the callback', (WidgetTester tester) async {
    bool loggedOut = false;
    final MalUserModel account = MalUserModel(
      id: '23456789',
      name: 'mal-tester',
      settings: SettingsModel.empty(),
      avatarImage: '',
      bannerImage: '',
      accessToken: 'access',
      refreshToken: 'refresh',
      accessTokenExpiresAt: '2099-01-01T00:00:00.000',
      profileUrl: 'https://myanimelist.net/profile/mal-tester',
    );

    await pumpPane(tester, loggedUser: account, onLogout: () => loggedOut = true);

    expect(find.text('mal-tester'), findsOneWidget);
    expect(find.text('https://myanimelist.net/profile/mal-tester'), findsOneWidget);
    expect(find.text("No MyAnimeList account is connected"), findsNothing);

    await tester.tap(find.text("Logout"));
    await tester.pump();

    expect(loggedOut, isTrue);
  });

  testWidgets('an account without a profile url falls back to a neutral label', (WidgetTester tester) async {
    final MalUserModel account = MalUserModel(
      id: '1',
      name: 'nameless',
      settings: SettingsModel.empty(),
      avatarImage: '',
      bannerImage: '',
      accessToken: 'access',
      refreshToken: 'refresh',
      accessTokenExpiresAt: '2099-01-01T00:00:00.000',
      profileUrl: '',
    );

    await pumpPane(tester, loggedUser: account, onLogout: () {});

    expect(find.text("MyAnimeList account"), findsOneWidget);
  });
}

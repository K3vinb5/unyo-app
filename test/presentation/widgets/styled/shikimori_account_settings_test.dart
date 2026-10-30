// External dependencies
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/widgets/styled/shikimori_account_settings.dart';

/// WP #64 subpart (c): the settings account pane has three jobs — say whether a
/// Shikimori account is connected, show who it is, and log out.
void main() {
  Future<void> pumpPane(WidgetTester tester, {required User loggedUser, required VoidCallback onLogout}) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        child: MaterialApp(
          home: Scaffold(
            body: ShikimoriAccountSettings(loggedUser: loggedUser, onLogout: onLogout),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a non-Shikimori session shows the disconnected state and no logout', (WidgetTester tester) async {
    bool loggedOut = false;
    await pumpPane(tester, loggedUser: UserModel.empty(), onLogout: () => loggedOut = true);

    expect(find.text("No Shikimori account is connected"), findsOneWidget);
    expect(find.text("Logout"), findsNothing);

    await tester.tap(find.text("No Shikimori account is connected"));
    expect(loggedOut, isFalse);
  });

  testWidgets('a Shikimori session shows the account and logs out through the callback',
      (WidgetTester tester) async {
    bool loggedOut = false;
    final ShikimoriUserModel account = ShikimoriUserModel(
      id: '23456789',
      name: 'morr',
      settings: SettingsModel.empty(),
      avatarImage: '',
      bannerImage: '',
      accessToken: 'access',
      refreshToken: 'refresh',
      accessTokenExpiresAt: '2099-01-01T00:00:00.000',
      profileUrl: 'https://shikimori.io/morr',
    );

    await pumpPane(tester, loggedUser: account, onLogout: () => loggedOut = true);

    expect(find.text('morr'), findsOneWidget);
    expect(find.text('https://shikimori.io/morr'), findsOneWidget);
    expect(find.text("No Shikimori account is connected"), findsNothing);

    await tester.tap(find.text("Logout"));
    await tester.pump();

    expect(loggedOut, isTrue);
  });

  testWidgets('an account without a profile url falls back to a neutral label', (WidgetTester tester) async {
    final ShikimoriUserModel account = ShikimoriUserModel(
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

    expect(find.text("Shikimori account"), findsOneWidget);
  });
}

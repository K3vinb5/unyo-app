// External dependencies
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/dialogs/user_profile_dialog.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';

import '../widgets/skeleton/support/fake_image_http.dart';

UserModel anilistUser({
  String id = '12345',
  String name = 'alice',
  String bannerImage = 'https://example.test/banner.png',
}) => UserModel(
  id: id,
  name: name,
  settings: SettingsModel.empty().copyWith(userService: Service.anilist),
  avatarImage: 'https://example.test/avatar.png',
  bannerImage: bannerImage,
);

/// The profile card reads nothing but the user it is handed, so the tree only
/// has to supply a theme and a navigator.
Future<void> openDialog(WidgetTester tester, User user) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => UserProfileDialog(user: user),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the display name, provider label and avatar of an AniList account', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      await openDialog(tester, anilistUser());

      expect(find.text('alice'), findsOneWidget);
      expect(find.text('Anilist account'), findsOneWidget);

      final UnyoNetworkImage avatar = tester.widget<UnyoNetworkImage>(
        find.byKey(UserProfileDialog.avatarKey),
      );
      expect(avatar.url, 'https://example.test/avatar.png');
      expect(avatar.borderRadius, greaterThan(0), reason: 'the avatar is rounded, not a square');
    });
  });

  testWidgets('shows the account id row for a provider account', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      await openDialog(tester, anilistUser(id: '12345'));

      expect(find.text('Account ID'), findsOneWidget);
      expect(find.text('12345'), findsOneWidget);
    });
  });

  testWidgets('hides the account id row when the account has no remote id (local account)', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      await openDialog(tester, anilistUser(id: '', bannerImage: ''));

      expect(find.text('Account ID'), findsNothing, reason: 'an empty slot renders no row at all');
      expect(find.text('12345'), findsNothing);
      expect(find.text('alice'), findsOneWidget, reason: 'the rest of the card still renders');
    });
  });

  testWidgets('paints the banner backdrop when the account has one', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      await openDialog(tester, anilistUser(bannerImage: 'https://example.test/banner.png'));

      final UnyoNetworkImage banner = tester.widget<UnyoNetworkImage>(
        find.byKey(UserProfileDialog.bannerKey),
      );
      expect(banner.url, 'https://example.test/banner.png');
    });
  });

  testWidgets('hides the banner when the account has none', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      await openDialog(tester, anilistUser(bannerImage: ''));

      expect(find.byKey(UserProfileDialog.bannerKey), findsNothing);
      expect(find.text('alice'), findsOneWidget);
    });
  });

  testWidgets('closes from its own close button', (WidgetTester tester) async {
    await withFakeImages(() async {
      await openDialog(tester, anilistUser());

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(UserProfileDialog), findsNothing);
    });
  });
}

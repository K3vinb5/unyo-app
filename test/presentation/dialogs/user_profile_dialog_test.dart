// External dependencies
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/dialogs/unyo_dialog_theme.dart';
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

/// A local (offline) account: no provider and no remote id behind it.
LocalUserModel localUser({String name = 'alice'}) => LocalUserModel(
  id: '',
  name: name,
  settings: SettingsModel.empty(),
  avatarImage: 'https://example.test/avatar.png',
  bannerImage: '',
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
      expect(avatar.width, UserProfileDialog.avatarSize, reason: 'the monogram avatar is 80px');
      expect(avatar.borderRadius, greaterThan(0), reason: 'the avatar is rounded, not a square');
    });
  });

  testWidgets('centres the identity stack and keeps the primary pill full-width', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      await openDialog(tester, anilistUser());

      final Text name = tester.widget<Text>(find.text('alice'));
      expect(name.textAlign, TextAlign.center);

      final Size pillSize = tester.getSize(find.byKey(UserProfileDialog.closeKey));
      expect(pillSize.height, 44, reason: 'the family CTA is a 44px pill');
      expect(pillSize.width, userProfileDialogWidth - 56, reason: 'the pill spans the card minus its 28px padding');

      final Container pill = tester.widget<Container>(
        find.descendant(
          of: find.byKey(UserProfileDialog.closeKey),
          matching: find.byType(Container),
        ),
      );
      final BoxDecoration decoration = pill.decoration! as BoxDecoration;
      expect(decoration.color, unyoDialogAccent);
      expect((decoration.borderRadius! as BorderRadius).topLeft.x, 22);
    });
  });

  testWidgets('shows the ACCOUNT block with the account id for a provider account', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      await openDialog(tester, anilistUser(id: '12345'));

      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('Account ID'), findsOneWidget);
      expect(find.text('12345'), findsOneWidget);
    });
  });

  testWidgets('hides the whole ACCOUNT block when the account has no remote id', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      await openDialog(tester, anilistUser(id: '', bannerImage: ''));

      expect(find.text('Account ID'), findsNothing, reason: 'an empty slot renders no row at all');
      expect(find.text('ACCOUNT'), findsNothing, reason: 'the eyebrow goes with its block');
      expect(find.text('12345'), findsNothing);
      expect(find.text('alice'), findsOneWidget, reason: 'the rest of the card still renders');
    });
  });

  testWidgets('labels a local account "Local account" with no id row', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      await openDialog(tester, localUser());

      expect(find.text('Local account'), findsOneWidget);
      expect(find.text('Account ID'), findsNothing);
      expect(find.text('alice'), findsOneWidget);
    });
  });

  testWidgets('wraps a long display name over two lines at most', (WidgetTester tester) async {
    await withFakeImages(() async {
      await openDialog(tester, anilistUser(name: 'Alexandria Pendragon Alter Lily'));

      final Text name = tester.widget<Text>(find.text('Alexandria Pendragon Alter Lily'));
      expect(name.maxLines, 2);
      final Size nameSize = tester.getSize(find.text('Alexandria Pendragon Alter Lily'));
      expect(nameSize.height, greaterThan(26 * 1.18), reason: 'the 26px name wrapped');
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

  testWidgets('closes from its own close pill', (WidgetTester tester) async {
    await withFakeImages(() async {
      await openDialog(tester, anilistUser());

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(UserProfileDialog), findsNothing);
    });
  });
}

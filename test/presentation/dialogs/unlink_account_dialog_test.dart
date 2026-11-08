// External dependencies
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/dialogs/unlink_account_dialog.dart';

import '../../support/localized_app.dart';

/// The confirmation between the drawer item and the removal (WP #151): it must
/// name the account, and only the explicit destructive action may remove it.
void main() {
  final User account = UserModel(
    id: '12345',
    name: 'Kiwib5',
    settings: SettingsModel.empty().copyWith(userService: Service.anilist),
    avatarImage: '',
    bannerImage: '',
  );

  Future<void> openDialog(
    WidgetTester tester, {
    required VoidCallback onConfirm,
  }) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        child: localizedApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => UnlinkAccountDialog(
                    user: account,
                    onConfirm: onConfirm,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('names the account and its provider', (WidgetTester tester) async {
    await openDialog(tester, onConfirm: () {});

    expect(find.text('Unlink this account?'), findsOneWidget);
    expect(
      find.text('This removes Kiwib5 from this device. You can sign in again at any time.'),
      findsOneWidget,
    );
    expect(find.text('Anilist account'), findsOneWidget);
  });

  testWidgets('cancel closes without removing anything', (WidgetTester tester) async {
    int confirmations = 0;
    await openDialog(tester, onConfirm: () => confirmations++);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(confirmations, 0);
    expect(find.byType(UnlinkAccountDialog), findsNothing);
  });

  testWidgets('the destructive action confirms once and closes', (WidgetTester tester) async {
    int confirmations = 0;
    await openDialog(tester, onConfirm: () => confirmations++);

    await tester.tap(find.text('Unlink account'));
    await tester.pumpAndSettle();

    expect(confirmations, 1);
    expect(find.byType(UnlinkAccountDialog), findsNothing);
  });
}

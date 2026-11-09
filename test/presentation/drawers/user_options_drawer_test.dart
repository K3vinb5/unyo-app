// External dependencies
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/tabs_cubit.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/drawers/user_options_drawer.dart';

import '../../support/localized_app.dart';

class MockTabsCubit extends Mock implements TabsCubit {}

/// "Unlink account…" moved out of Settings into the user drawer (WP #151): the
/// drawer owns the entry point and hands the confirmation to the shell cubit.
void main() {
  final User account = UserModel(
    id: '12345',
    name: 'Kiwib5',
    settings: SettingsModel.empty().copyWith(userService: Service.anilist),
    avatarImage: '',
    bannerImage: '',
  );

  testWidgets('offers the unlink entry and closes before confirming', (
    WidgetTester tester,
  ) async {
    final MockTabsCubit cubit = MockTabsCubit();
    // The real window is 1920x1080; the drawer is sized in ScreenUtil units.
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        child: localizedApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => ElevatedButton(
                onPressed: () => showGeneralDialog<void>(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: 'drawer',
                  barrierColor: Colors.black54,
                  pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => UserOptionsDrawer(
                    cubit: cubit,
                    loggedUser: account,
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

    expect(find.text('View Profile'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Unlink account…'), findsOneWidget);

    await tester.tap(find.text('Unlink account…'));
    await tester.pumpAndSettle();

    verify(() => cubit.confirmUnlinkUser()).called(1);
    expect(find.byType(UserOptionsDrawer), findsNothing);
  });
}

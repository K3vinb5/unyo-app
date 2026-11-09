// External dependencies
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/application/cubits/login_cubit.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/login_card_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/theme/color_image_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/repositories/repositories.dart';
import 'package:unyo/presentation/dialogs/account_creation_dialog.dart';
import 'package:unyo/presentation/dialogs/coming_soon_dialog.dart';

import '../../support/localized_app.dart';

class MockUserRepositoryLocal extends Mock implements UserRepositoryLocal {}

class MockUserRepositoryAnilist extends Mock implements UserRepositoryAnilist {}

class MockUserRepositoryShikimori extends Mock implements UserRepositoryShikimori {}

class MockUserNotifier extends Mock implements UserNotifier {}

class MockColorImageService extends Mock implements ColorImageService {}

class MockThemeService extends Mock implements ThemeService {}

/// WP #148: MAL and local accounts are not implemented yet. Confirming either
/// used to log and pop the Add-account dialog, leaving the user on the login
/// screen with no explanation. The notice must open above the still-open
/// account dialog, and dismissing it must return to that dialog.
void main() {
  late LoginCubit cubit;

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));

    final MockUserNotifier loggedUserNotifier = MockUserNotifier();
    final MockUserNotifier newUserNotifier = MockUserNotifier();
    when(() => loggedUserNotifier.userStream).thenAnswer((_) => const Stream.empty());
    when(() => newUserNotifier.userStream).thenAnswer((_) => const Stream.empty());

    cubit = LoginCubit(
      MockUserRepositoryLocal(),
      loggedUserNotifier,
      newUserNotifier,
      MockUserRepositoryAnilist(),
      MockUserRepositoryShikimori(),
      MockColorImageService(),
      MockThemeService(),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  Future<void> openAccountDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1280, 720),
        minTextAdapt: true,
        splitScreenMode: true,
        child: localizedApp(
          home: BlocProvider<LoginCubit>.value(
            value: cubit,
            child: Scaffold(
              body: Builder(
                builder: (BuildContext context) => ElevatedButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (BuildContext dialogContext) => BlocProvider<LoginCubit>.value(
                      value: cubit,
                      child: AccountCreationDialog(
                        selectedType: cubit.state.selectedLoginCard,
                        onSelect: cubit.selectLoginType,
                        onCancel: () => Navigator.of(dialogContext).pop(),
                        onConfirm: () => cubit.attemptToCreateUser(dialogContext),
                      ),
                    ),
                  ),
                  child: const Text('add account'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('add account'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountCreationDialog), findsOneWidget);
  }

  for (final (LoginCardType type, ComingSoonFeature feature) in <(LoginCardType, ComingSoonFeature)>[
    (LoginCardType.mal, ComingSoonFeature.malAccounts),
    (LoginCardType.local, ComingSoonFeature.localAccounts),
  ]) {
    testWidgets('${type.name} confirm shows the coming-soon notice and keeps the account dialog open', (
      WidgetTester tester,
    ) async {
      await openAccountDialog(tester);

      cubit.selectLoginType(type);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(AccountCreationDialog.confirmKey));
      await tester.pumpAndSettle();

      expect(find.byKey(ComingSoonDialog.dialogKey(feature)), findsOneWidget);
      expect(
        find.byType(AccountCreationDialog),
        findsOneWidget,
        reason: 'the account dialog must stay open behind the notice',
      );
      expect(cubit.state.effects, isEmpty, reason: 'the notice is shown directly, not queued as a dialog effect');

      await tester.tap(find.byKey(ComingSoonDialog.dismissKey));
      await tester.pumpAndSettle();

      expect(find.byType(ComingSoonDialog), findsNothing);
      expect(
        find.byType(AccountCreationDialog),
        findsOneWidget,
        reason: 'dismissing the notice returns the user to the account dialog',
      );
    });
  }
}

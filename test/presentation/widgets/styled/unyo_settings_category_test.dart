// External dependencies
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/presentation/widgets/styled/unyo_settings_category.dart';

import '../../../support/localized_app.dart';

void main() {
  Future<void> pumpCategory(
    WidgetTester tester, {
    required bool activating,
    required VoidCallback onActivate,
  }) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        child: localizedApp(
          home: Scaffold(
            body: UnyoSettingsCategory(
              title: 'Row title',
              description: 'Row description',
              icon: Icons.info_rounded,
              alignment: '',
              childAlignment: '',
              onActivate: activating ? onActivate : null,
              settingsOptions: const <Widget>[Text('child option')],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an activating row opens its target instead of expanding', (
    WidgetTester tester,
  ) async {
    int activations = 0;
    await pumpCategory(
      tester,
      activating: true,
      onActivate: () => activations++,
    );

    final Size collapsed = tester.getSize(find.byType(UnyoSettingsCategory));
    await tester.tap(find.text('Row title'));
    await tester.pumpAndSettle();

    expect(activations, 1);
    // The collapsible body never opens: About is not a container any more.
    expect(tester.getSize(find.byType(UnyoSettingsCategory)), collapsed);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
  });

  testWidgets('a plain category still expands and collapses', (
    WidgetTester tester,
  ) async {
    await pumpCategory(tester, activating: false, onActivate: () {});

    await tester.tap(find.text('Row title'));
    await tester.pumpAndSettle();
    expect(find.text('child option'), findsOneWidget);
  });
}

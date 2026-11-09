// External dependencies
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/presentation/widgets/media_list_status_chip.dart';

import '../../support/localized_app.dart';

/// WP #167: the chip is the list editor's entry point on both details pages
/// (anime and manga), and it renders the entry status without leaking the
/// `ADD TO LIST` sentinel.
void main() {
  Future<void> pumpChip(WidgetTester tester, {required String status, void Function()? onTap}) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        child: localizedApp(
          home: Scaffold(
            body: MediaListStatusChip(status: status, onTap: onTap ?? () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an entry on no list reads "Not on list" instead of ADD TO LIST', (tester) async {
    await pumpChip(tester, status: 'ADD TO LIST');

    expect(find.text('Not on list'), findsOneWidget);
    expect(find.text('ADD TO LIST'), findsNothing);
  });

  testWidgets('a stored status renders the editor vocabulary', (tester) async {
    await pumpChip(tester, status: 'CURRENT');

    expect(find.text('Current'), findsOneWidget);
  });

  testWidgets('tapping the chip opens the editor', (tester) async {
    int taps = 0;
    await pumpChip(tester, status: 'Planning', onTap: () => taps++);

    await tester.tap(find.byKey(MediaListStatusChip.chipKey));
    await tester.pumpAndSettle();

    expect(taps, 1);
  });
}

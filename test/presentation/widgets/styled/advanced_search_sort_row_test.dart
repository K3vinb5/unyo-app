// External dependencies
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/presentation/widgets/styled/advanced_search_sort_row.dart';
import 'package:unyo/presentation/widgets/styled/unyo_sort_widget.dart';

/// WP #64(b) round 1 finding 1: the sort strip used to be gated on
/// `sortOptions.$1 && sortOrders.$1`, so a provider that implements sort fields
/// but no direction control (Shikimori — `OrderEnum` has no `_desc` twin for any
/// exposed option) rendered **no** sort control at all and always ran the
/// default order.
void main() {
  Future<void> pumpRow(WidgetTester tester, AdvancedSearchSortRow row) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        child: MaterialApp(home: Scaffold(body: row)),
      ),
    );
    await tester.pump();
  }

  testWidgets('fields without directions still render the field picker', (WidgetTester tester) async {
    await pumpRow(
      tester,
      const AdvancedSearchSortRow(
        sortOptions: (true, <String>['Popularity', 'Name']),
        sortOrders: (false, <String>[]),
        selectedSortOption: 'Popularity',
      ),
    );

    expect(find.byType(UnyoSortWidget), findsOneWidget);
    expect(find.text('Popularity'), findsOneWidget);
  });

  testWidgets('no capability at all renders nothing', (WidgetTester tester) async {
    await pumpRow(
      tester,
      const AdvancedSearchSortRow(
        sortOptions: (false, <String>[]),
        sortOrders: (false, <String>[]),
      ),
    );

    expect(find.byType(UnyoSortWidget), findsNothing);
  });

  testWidgets('both capabilities render both pickers', (WidgetTester tester) async {
    await pumpRow(
      tester,
      const AdvancedSearchSortRow(
        sortOptions: (true, <String>['Popularity']),
        sortOrders: (true, <String>['Asc', 'Desc']),
        selectedSortOption: 'Popularity',
        selectedSortOrder: 'Desc',
      ),
    );

    expect(find.byType(UnyoSortWidget), findsNWidgets(2));
    expect(find.text('Popularity'), findsOneWidget);
    expect(find.text('Desc'), findsOneWidget);
  });
}

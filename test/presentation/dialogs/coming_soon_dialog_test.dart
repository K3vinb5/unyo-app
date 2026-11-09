// External dependencies
import 'dart:convert';
import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/presentation/dialogs/coming_soon_dialog.dart';

import '../../support/localized_app.dart';

/// WP #148: one dismiss-only dialog for every unfinished feature, with the copy
/// coming from the registry instead of a call site. These tests pin that each
/// registry entry renders real translated copy (never a raw key) and that the
/// single action closes the dialog.
void main() {
  final Map<String, dynamic> english =
      json.decode(File('assets/i18n/en_GB.json').readAsStringSync()) as Map<String, dynamic>;

  Future<void> open(WidgetTester tester, ComingSoonFeature feature) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1280, 720),
        minTextAdapt: true,
        splitScreenMode: true,
        child: localizedApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) =>
                  TextButton(onPressed: () => ComingSoonDialog.show(context, feature), child: const Text('open')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('every feature renders its registered title and body', (WidgetTester tester) async {
    for (final ComingSoonFeature feature in ComingSoonFeature.values) {
      await open(tester, feature);

      expect(
        find.byKey(ComingSoonDialog.dialogKey(feature)),
        findsOneWidget,
        reason: '${feature.name} must open its own dialog',
      );
      for (final String key in <String>[feature.titleKey, feature.bodyKey, 'coming_soon_dismiss']) {
        expect(english[key], isA<String>(), reason: '${feature.name}: "$key" must exist in en_GB.json');
        expect(
          find.text(english[key] as String),
          findsOneWidget,
          reason: '${feature.name}: "$key" must be rendered from the registry copy',
        );
        expect(find.text(key), findsNothing, reason: '${feature.name}: "$key" rendered as a raw key');
      }

      await tester.tap(find.byKey(ComingSoonDialog.dismissKey));
      await tester.pumpAndSettle();
      expect(
        find.byType(ComingSoonDialog),
        findsNothing,
        reason: '${feature.name}: the single action dismisses the dialog',
      );
    }
  });

  test('the registry points each feature at distinct copy keys', () {
    final Set<String> titles = <String>{};
    final Set<String> bodies = <String>{};
    for (final ComingSoonFeature feature in ComingSoonFeature.values) {
      expect(feature.titleKey, isNotEmpty);
      expect(feature.bodyKey, isNotEmpty);
      expect(feature.titleKey, isNot(feature.bodyKey));
      titles.add(feature.titleKey);
      bodies.add(feature.bodyKey);
    }
    expect(
      titles,
      hasLength(ComingSoonFeature.values.length),
      reason: 'a feature that reuses another feature\'s title is not honest copy',
    );
    expect(
      bodies,
      hasLength(ComingSoonFeature.values.length),
      reason: 'a feature that reuses another feature\'s body is not honest copy',
    );
  });
}

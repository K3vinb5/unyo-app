// External dependencies
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/presentation/dialogs/update_available_dialog.dart';

void main() {
  Future<void> openDialog(
    WidgetTester tester, {
    required String releaseNotes,
    required VoidCallback onOpenReleasePage,
  }) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => UpdateAvailableDialog(
                    latestVersion: '0.9.0',
                    releaseNotes: releaseNotes,
                    onOpenReleasePage: onOpenReleasePage,
                  ),
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

  testWidgets('renders the published release notes as markdown', (
    tester,
  ) async {
    await openDialog(
      tester,
      releaseNotes:
          "## What's changed\n\n- Release notes now open in a dialog.",
      onOpenReleasePage: () {},
    );

    expect(find.text(UpdateAvailableDialog.title), findsOneWidget);
    expect(find.textContaining('Unyo v0.9.0'), findsOneWidget);
    final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    expect(markdown.data, contains('Release notes now open in a dialog.'));
  });

  testWidgets('explains itself when the release was published without notes', (
    tester,
  ) async {
    await openDialog(tester, releaseNotes: '  ', onOpenReleasePage: () {});

    expect(find.byType(MarkdownBody), findsNothing);
    expect(find.textContaining('published without notes'), findsOneWidget);
  });

  testWidgets('opens the release page and dismisses itself', (tester) async {
    var opened = 0;
    await openDialog(
      tester,
      releaseNotes: '- something changed',
      onOpenReleasePage: () => opened++,
    );

    await tester.tap(find.text('Open release page'));
    await tester.pumpAndSettle();

    expect(opened, 1);
    expect(find.byType(UpdateAvailableDialog), findsNothing);
  });
}

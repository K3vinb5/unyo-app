// External dependencies
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/presentation/dialogs/confirm_dialog.dart';
import 'package:unyo/presentation/dialogs/media_entry_editor.dart';

import '../../support/localized_app.dart';

/// WP #167: the shared list editor (anime + manga) and its removal step.
void main() {
  Future<void> pumpEditor(
    WidgetTester tester, {
    required MediaListEntry entry,
    required int progressMax,
    String progressLabel = 'Progress',
    void Function()? onDelete,
    void Function()? onConfirm,
    void Function(int)? onProgressChanged,
  }) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        child: localizedApp(
          home: Scaffold(
            body: MediaEntryEditor(
              entry: entry,
              progressMax: progressMax,
              progressLabel: progressLabel,
              onStatusChanged: (_) {},
              onProgressChanged: onProgressChanged ?? (_) {},
              onScoreChanged: (_) {},
              onStartedAtPressed: () {},
              onCompletedAtPressed: () {},
              onCancel: () {},
              onConfirm: onConfirm ?? () {},
              onDelete: onDelete ?? () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder inConfirmCard(Finder matching) =>
      find.descendant(of: find.byKey(ConfirmDialog.dialogKey), matching: matching);

  group('MediaEntryEditor sentinel display', () {
    testWidgets('a fresh entry shows 0 progress and 0 score, never -1', (tester) async {
      await pumpEditor(tester, entry: MediaListEntryModel.empty(), progressMax: 12);

      expect(find.text('-1'), findsNothing, reason: 'the patch sentinel must not reach the editor');
      expect(find.text('Not on list'), findsOneWidget, reason: 'ADD TO LIST is the "no status" state');
      // Progress value 0 plus the slider's 12 maximum, score 0 plus its 10 maximum.
      expect(find.text('0'), findsNWidgets(2));
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('a stored entry shows its own progress, score and status', (tester) async {
      await pumpEditor(
        tester,
        entry: MediaListEntryModel.empty().copyWith(status: 'CURRENT', progress: 3, score: 7),
        progressMax: 12,
      );

      expect(find.text('Current'), findsWidgets, reason: 'the dropdown shows the current status');
      expect(find.text('3'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('the manga editor labels its progress as chapters', (tester) async {
      await pumpEditor(
        tester,
        entry: MediaListEntryModel.empty().copyWith(status: 'CURRENT', progress: 4),
        progressMax: 24,
        progressLabel: 'Chapters',
      );

      expect(find.text('Chapters'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('dragging the progress slider reports the new value', (tester) async {
      int? reported;
      await pumpEditor(
        tester,
        entry: MediaListEntryModel.empty().copyWith(status: 'CURRENT'),
        progressMax: 10,
        onProgressChanged: (value) => reported = value,
      );

      await tester.drag(find.byType(Slider).first, const Offset(80, 0));
      await tester.pumpAndSettle();

      expect(reported, isNotNull);
      expect(reported, greaterThan(0));
    });
  });

  group('MediaEntryEditor removal', () {
    testWidgets('the trash icon asks for confirmation before deleting', (tester) async {
      int deletions = 0;
      await pumpEditor(
        tester,
        entry: MediaListEntryModel.empty().copyWith(status: 'CURRENT', progress: 2),
        progressMax: 12,
        onDelete: () => deletions++,
      );

      await tester.tap(find.byKey(MediaEntryEditor.deleteButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(ConfirmDialog.dialogKey), findsOneWidget);
      expect(inConfirmCard(find.text('Remove from list')), findsOneWidget);
      expect(inConfirmCard(find.text('Remove this entry from your list?')), findsOneWidget);
      expect(deletions, 0, reason: 'nothing is deleted until the user confirms');

      await tester.tap(inConfirmCard(find.text('Confirm')));
      await tester.pumpAndSettle();

      expect(deletions, 1);
      expect(find.byKey(ConfirmDialog.dialogKey), findsNothing);
    });

    testWidgets('cancelling the confirmation keeps the entry', (tester) async {
      int deletions = 0;
      await pumpEditor(
        tester,
        entry: MediaListEntryModel.empty().copyWith(status: 'CURRENT'),
        progressMax: 12,
        onDelete: () => deletions++,
      );

      await tester.tap(find.byKey(MediaEntryEditor.deleteButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(inConfirmCard(find.text('Cancel')));
      await tester.pumpAndSettle();

      expect(deletions, 0);
      expect(find.byKey(ConfirmDialog.dialogKey), findsNothing);
      expect(find.byKey(MediaEntryEditor.dialogKey), findsOneWidget, reason: 'the editor stays open');
    });
  });
}

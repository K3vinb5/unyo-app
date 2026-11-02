// External dependencies
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';
import 'package:unyo/presentation/widgets/styled/unyo_video_centre_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_video_controls.dart';

/// WP #119 follow-up: the paused screen must not advertise a click that does
/// nothing, and the centre pause/resume button must not look selected.
void main() {
  group('surface cursor', () {
    test('advertises the pause click only while playing', () {
      // Playing + bar up: a click on the picture pauses, so the hand is honest.
      expect(
        UnyoVideoControls.surfaceCursor(controlsVisible: true, playing: true),
        SystemMouseCursors.click,
      );
      // Paused + bar up: the surface click is inert, so no click cursor.
      expect(
        UnyoVideoControls.surfaceCursor(controlsVisible: true, playing: false),
        SystemMouseCursors.basic,
      );
    });

    test('hides the pointer with the bar', () {
      expect(
        UnyoVideoControls.surfaceCursor(controlsVisible: false, playing: true),
        SystemMouseCursors.none,
      );
      expect(
        UnyoVideoControls.surfaceCursor(controlsVisible: false, playing: false),
        SystemMouseCursors.none,
      );
    });
  });

  group('centre play button', () {
    Future<void> pumpButton(
      WidgetTester tester, {
      required VoidCallback onPressed,
      double progress = 0,
    }) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1920, 1080),
          minTextAdapt: true,
          child: MaterialApp(
            home: Material(
              child: Center(
                child: UnyoVideoCentreButton(
                  onPressed: onPressed,
                  progress: AlwaysStoppedAnimation<double>(progress),
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('paints no focus highlight and cannot take focus', (tester) async {
      await pumpButton(tester, onPressed: () {});

      final UnyoInkWell ink = tester.widget<UnyoInkWell>(find.byType(UnyoInkWell));
      expect(
        ink.canRequestFocus,
        isFalse,
        reason: 'a focusable InkWell keeps its focusColor painted while paused',
      );
      expect(ink.focusColor, Colors.transparent);
    });

    testWidgets('a click resumes without leaving the keyboard on the button', (tester) async {
      var taps = 0;
      await pumpButton(tester, onPressed: () => taps++);
      final FocusNode shortcutScope = FocusNode(debugLabel: 'video shortcut scope');
      addTearDown(shortcutScope.dispose);
      // Stand-in for `VideoShortcutScope`: it owns the keyboard when the player
      // opens, and it must still own it after a pointer click (WP #119).
      shortcutScope.requestFocus();
      await tester.pump();

      await tester.tap(find.byType(UnyoVideoCentreButton));
      await tester.pumpAndSettle();

      expect(taps, 1, reason: 'the centre glyph still resumes the frame');
      final BuildContext? focused = FocusManager.instance.primaryFocus?.context;
      expect(
        focused?.findAncestorWidgetOfExactType<UnyoVideoCentreButton>(),
        isNull,
        reason: 'the button must not become the keyboard focus (no ring, no stolen Space/K)',
      );
    });
  });
}

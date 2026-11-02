// External dependencies
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/services/video/skip_window.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';
import 'package:unyo/presentation/widgets/styled/unyo_video_bottom_status.dart';

/// WP #113: the skip pill owns its visibility (an active skip window keeps it on
/// screen while the bar is hidden) and the up-next card/content rules.
void main() {
  Future<void> pumpStatus(
    WidgetTester tester, {
    bool controlsVisible = true,
    SkipWindowKind skipKind = SkipWindowKind.none,
    bool upNextVisible = false,
    String thumbnailUrl = '',
    VoidCallback? onSkip,
    VoidCallback? onWatchNow,
    VoidCallback? onDismiss,
  }) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        child: MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: Align(
              alignment: Alignment.bottomRight,
              child: UnyoVideoBottomStatus(
                controlsVisible: controlsVisible,
                skipKind: skipKind,
                skipLabel: switch (skipKind) {
                  SkipWindowKind.opening => 'Skip Opening',
                  SkipWindowKind.ending => 'Skip Ending',
                  SkipWindowKind.none => '+ 85s',
                },
                upNextVisible: upNextVisible,
                seriesTitle: 'Frieren',
                episodeLabel: 'A Storm (E4)',
                thumbnailUrl: thumbnailUrl,
                onSkip: onSkip ?? () {},
                onWatchNow: onWatchNow ?? () {},
                onDismiss: onDismiss ?? () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double pillOpacity(WidgetTester tester) => tester
      .widget<AnimatedOpacity>(
        find.descendant(
          of: find.byType(UnyoVideoBottomStatus),
          matching: find.byType(AnimatedOpacity),
        ),
      )
      .opacity;

  group('slot precedence', () {
    test('an active skip window keeps the slot over the card', () {
      expect(
        UnyoVideoBottomStatus.resolveSlot(skipKind: SkipWindowKind.ending, upNextVisible: true),
        VideoBottomSlot.skipWindow,
      );
    });

    test('the card takes over once the skip window closes', () {
      expect(
        UnyoVideoBottomStatus.resolveSlot(skipKind: SkipWindowKind.none, upNextVisible: true),
        VideoBottomSlot.upNext,
      );
    });

    test('manual skip otherwise', () {
      expect(
        UnyoVideoBottomStatus.resolveSlot(skipKind: SkipWindowKind.none, upNextVisible: false),
        VideoBottomSlot.manualSkip,
      );
    });
  });

  group('skip pill independence from the controls bar', () {
    testWidgets('visible while the controls are hidden, if a skip window is active', (tester) async {
      await pumpStatus(
        tester,
        controlsVisible: false,
        skipKind: SkipWindowKind.ending,
      );

      expect(find.text('Skip Ending'), findsOneWidget);
      expect(pillOpacity(tester), 1);
    });

    testWidgets('manual skip button fades away with the controls', (tester) async {
      await pumpStatus(tester, controlsVisible: false);

      expect(find.text('+ 85s'), findsOneWidget);
      expect(pillOpacity(tester), 0);
    });

    testWidgets('manual skip button is faded in with the controls', (tester) async {
      await pumpStatus(tester, controlsVisible: true);

      expect(pillOpacity(tester), 1);
    });

    testWidgets('the pill is tappable exactly when it is visible', (tester) async {
      var skips = 0;
      await pumpStatus(
        tester,
        controlsVisible: false,
        skipKind: SkipWindowKind.opening,
        onSkip: () => skips++,
      );

      await tester.tap(find.text('Skip Opening'));
      await tester.pumpAndSettle();
      expect(skips, 1);

      // Hidden manual skip (no window, controls hidden) must not take taps
      // meant for the video surface behind it.
      await pumpStatus(tester, controlsVisible: false, onSkip: () => skips++);
      expect(
        tester
            .widget<IgnorePointer>(
              find.descendant(
                of: find.byType(UnyoVideoBottomStatus),
                matching: find.byType(IgnorePointer),
              ),
            )
            .ignoring,
        isTrue,
      );
    });
  });

  group('up-next card', () {
    testWidgets('renders both actions and the episode label', (tester) async {
      await pumpStatus(tester, upNextVisible: true);

      expect(find.text('Next: Frieren'), findsOneWidget);
      expect(find.text('A Storm (E4)'), findsOneWidget);
      expect(find.text('Watch now'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('Watch now and Dismiss call their callbacks', (tester) async {
      var watched = 0;
      var dismissed = 0;
      await pumpStatus(
        tester,
        upNextVisible: true,
        onWatchNow: () => watched++,
        onDismiss: () => dismissed++,
      );

      await tester.tap(find.text('Watch now'));
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      expect(watched, 1);
      expect(dismissed, 1);
    });

    testWidgets('no thumbnail data renders no image box at all', (tester) async {
      await pumpStatus(tester, upNextVisible: true);

      expect(find.byType(UnyoNetworkImage), findsNothing);
    });

    testWidgets('a thumbnail is rendered when the data has one', (tester) async {
      await pumpStatus(
        tester,
        upNextVisible: true,
        thumbnailUrl: 'https://example.com/next.jpg',
      );

      expect(find.byType(UnyoNetworkImage), findsOneWidget);
    });
  });
}

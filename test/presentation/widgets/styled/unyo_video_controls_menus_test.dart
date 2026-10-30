// External dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/domain/entities/extension/track.dart';
import 'package:unyo/presentation/widgets/styled/unyo_video_controls.dart';

const Track _embeddedEnglish = Track(url: '', lang: 'English', embedded: true, embeddedIndex: 0);
const Track _embeddedFrench = Track(url: '', lang: 'French', embedded: true, embeddedIndex: 1);
const Track _externalSpanish =
    Track(url: 'https://example.com/sub.vtt', lang: 'Spanish', embedded: false, embeddedIndex: -1);

void main() {
  /// Pumps a real [PopupMenuButton] wired to the production menu builder and
  /// opens it, so the assertions see the entries a user actually gets.
  Future<void> openMenu(
    WidgetTester tester,
    List<PopupMenuEntry<int>> Function() itemBuilder,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (BuildContext context) => itemBuilder(),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
  }

  Finder checkIn(String label) => find.descendant(
    of: find.widgetWithText(PopupMenuItem<int>, label),
    matching: find.byIcon(Icons.check_rounded),
  );

  group('subtitle menu', () {
    testWidgets('offers "No subtitles" even with no subtitle tracks', (tester) async {
      await openMenu(
        tester,
        () => UnyoVideoControls.buildSubtitleMenuItems(subtitles: const [], activeIndex: -1),
      );

      expect(find.text('No subtitles'), findsOneWidget);
      expect(find.byType(PopupMenuItem<int>), findsOneWidget);
      expect(checkIn('No subtitles'), findsOneWidget);
    });

    testWidgets('marks "No subtitles" when subtitles are off', (tester) async {
      await openMenu(
        tester,
        () => UnyoVideoControls.buildSubtitleMenuItems(
          subtitles: const [_embeddedEnglish, _externalSpanish],
          activeIndex: -1,
        ),
      );

      expect(find.text('No subtitles'), findsOneWidget);
      expect(find.text('English - Embedded'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);
      expect(checkIn('No subtitles'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('checks the active track and not "No subtitles"', (tester) async {
      await openMenu(
        tester,
        () => UnyoVideoControls.buildSubtitleMenuItems(
          subtitles: const [_embeddedEnglish, _embeddedFrench],
          activeIndex: 1,
        ),
      );

      expect(checkIn('French - Embedded'), findsOneWidget);
      expect(checkIn('No subtitles'), findsNothing);
      expect(checkIn('English - Embedded'), findsNothing);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });

  group('audio menu', () {
    testWidgets('a single source shows "Default audio" and no track entries', (tester) async {
      await openMenu(
        tester,
        () => UnyoVideoControls.buildAudioMenuItems(audios: const [_embeddedEnglish], activeIndex: -1),
      );

      expect(find.text('Default audio'), findsOneWidget);
      expect(find.byType(PopupMenuItem<int>), findsOneWidget);
      expect(checkIn('Default audio'), findsOneWidget);
    });

    testWidgets('no audio at all still offers "Default audio"', (tester) async {
      await openMenu(
        tester,
        () => UnyoVideoControls.buildAudioMenuItems(audios: const [], activeIndex: -1),
      );

      expect(find.text('Default audio'), findsOneWidget);
      expect(checkIn('Default audio'), findsOneWidget);
    });

    testWidgets('a single source with its default track active stays checked', (tester) async {
      // Initialization activates the only track (index 0), which is the default.
      await openMenu(
        tester,
        () => UnyoVideoControls.buildAudioMenuItems(audios: const [_embeddedEnglish], activeIndex: 0),
      );

      expect(find.text('Default audio'), findsOneWidget);
      expect(checkIn('Default audio'), findsOneWidget);
    });

    testWidgets('with no explicit override the default (first) track is checked', (tester) async {
      await openMenu(
        tester,
        () => UnyoVideoControls.buildAudioMenuItems(
          audios: const [_embeddedEnglish, _embeddedFrench],
          activeIndex: -1,
        ),
      );

      expect(find.text('Default audio'), findsNothing);
      expect(checkIn('English - Embedded'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('2+ tracks show only the real tracks, no "Default audio"', (tester) async {
      await openMenu(
        tester,
        () => UnyoVideoControls.buildAudioMenuItems(
          audios: const [_embeddedEnglish, _embeddedFrench],
          activeIndex: 1,
        ),
      );

      expect(find.text('Default audio'), findsNothing);
      expect(find.text('English - Embedded'), findsOneWidget);
      expect(find.text('French - Embedded'), findsOneWidget);
      expect(checkIn('French - Embedded'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });
}

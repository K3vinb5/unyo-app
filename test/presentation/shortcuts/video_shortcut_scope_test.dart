import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/core/services/video/video_playback_commands.dart';
import 'package:unyo/presentation/shortcuts/video_shortcut_handler.dart';
import 'package:unyo/presentation/shortcuts/video_shortcut_scope.dart';

/// WP #98 Phase B focus discipline: the key table must not fire while a dialog,
/// the episode drawer, or a text field owns focus, nor on other screens.
void main() {
  late _RecordingCommands commands;
  late VideoShortcutHandler handler;

  setUp(() {
    commands = _RecordingCommands();
    handler = VideoShortcutHandler(
      commands: commands,
      onNextEpisode: () => commands.episodeSteps.add(1),
      onPreviousEpisode: () => commands.episodeSteps.add(-1),
    );
  });

  tearDown(() => handler.dispose());

  Future<void> pumpScope(WidgetTester tester, Widget child, {bool enabled = true}) {
    return tester.pumpWidget(
      MaterialApp(
        home: VideoShortcutScope(handler: handler, enabled: enabled, child: child),
      ),
    );
  }

  testWidgets('keys reach the handler while the video screen owns focus', (tester) async {
    await pumpScope(tester, const SizedBox.expand());

    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(commands.togglePlayCalls, 2);
  });

  testWidgets('keys do nothing while a dialog is open', (tester) async {
    await pumpScope(
      tester,
      Builder(
        builder: (context) => GestureDetector(
          key: const ValueKey('open-dialog'),
          behavior: HitTestBehavior.opaque,
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) => const AlertDialog(title: Text('blocking dialog')),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('open-dialog')));
    await tester.pumpAndSettle();
    expect(find.text('blocking dialog'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(commands.togglePlayCalls, 0);
  });

  testWidgets('keys do nothing while a text field has focus', (tester) async {
    await pumpScope(
      tester,
      const Material(
        child: Center(child: SizedBox(width: 200, child: TextField(autofocus: true))),
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.pump();

    expect(commands.togglePlayCalls, 0);
  });

  testWidgets('keys do nothing while the video screen is disabled (loading overlay)', (tester) async {
    await pumpScope(tester, const SizedBox.expand(), enabled: false);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.pump();

    expect(commands.togglePlayCalls, 0);
  });

  testWidgets('the handler is not consulted outside the scope', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.expand())),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.pump();

    expect(commands.togglePlayCalls, 0);
  });
}

class _RecordingCommands implements VideoPlaybackCommands {
  int togglePlayCalls = 0;
  final List<int> episodeSteps = <int>[];

  @override
  Duration get duration => const Duration(seconds: 100);

  @override
  bool get isFullscreen => false;

  @override
  bool get isPlaying => true;

  @override
  double get playbackSpeed => 1.0;

  @override
  Duration get position => const Duration(seconds: 30);

  @override
  bool get subtitlesEnabled => true;

  @override
  double get volume => 0.5;

  @override
  void pause() {}

  @override
  void play() {}

  @override
  void seekTo(Duration position) {}

  @override
  void setFullscreen(bool fullscreen) {}

  @override
  void setPlaybackSpeed(double speed) {}

  @override
  void setVolume(double volume) {}

  @override
  void togglePlay() => togglePlayCalls++;

  @override
  bool toggleSubtitles() => true;
}

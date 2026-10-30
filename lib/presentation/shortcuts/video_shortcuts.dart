// External dependencies
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Intents the video screen understands. One intent per YouTube-standard
/// command; the key table below maps activators onto them, and
/// `VideoShortcutHandler` maps intents onto `VideoPlaybackCommands`.
sealed class VideoIntent extends Intent {
  const VideoIntent();
}

class TogglePlayIntent extends VideoIntent {
  const TogglePlayIntent();
}

/// Relative seek, e.g. -10s for `J`.
class SeekByIntent extends VideoIntent {
  const SeekByIntent(this.offset);
  final Duration offset;
}

/// Absolute seek to [percent] of the episode, e.g. 0.9 for `9`.
class SeekToPercentIntent extends VideoIntent {
  const SeekToPercentIntent(this.percent);
  final double percent;
}

/// Volume delta as a fraction of full scale, e.g. +0.05 for `↑`.
class AdjustVolumeIntent extends VideoIntent {
  const AdjustVolumeIntent(this.delta);
  final double delta;
}

class ToggleMuteIntent extends VideoIntent {
  const ToggleMuteIntent();
}

class ToggleFullscreenIntent extends VideoIntent {
  const ToggleFullscreenIntent();
}

class ExitFullscreenIntent extends VideoIntent {
  const ExitFullscreenIntent();
}

class ToggleCaptionsIntent extends VideoIntent {
  const ToggleCaptionsIntent();
}

/// Playback-speed delta in multiples, e.g. -0.25 for `Shift+,`.
class AdjustSpeedIntent extends VideoIntent {
  const AdjustSpeedIntent(this.delta);
  final double delta;
}

class NextEpisodeIntent extends VideoIntent {
  const NextEpisodeIntent();
}

class PreviousEpisodeIntent extends VideoIntent {
  const PreviousEpisodeIntent();
}

/// One row of the key table: a [SingleActivator] (or [CharacterActivator]),
/// the intent it produces, and the documented name for tests/docs.
class VideoShortcutBinding {
  const VideoShortcutBinding({
    required this.keys,
    required this.intent,
    required this.label,
  });

  final ShortcutActivator keys;
  final VideoIntent intent;

  /// Human-readable key name, as documented in WP #98 / YouTube's shortcut list.
  final String label;
}

const LogicalKeyboardKey _space = LogicalKeyboardKey.space;
const LogicalKeyboardKey _escape = LogicalKeyboardKey.escape;

/// The single declarative key table for the video screen (YouTube's standard
/// shortcut set).
///
/// `Shift+,` / `Shift+.` are listed twice on purpose: XKB reports the shifted
/// *symbol* (`<`, `>`) as the logical key instead of the comma/period, so both
/// spellings are accepted and neither layout breaks the speed shortcut.
const List<VideoShortcutBinding> videoShortcutBindings = <VideoShortcutBinding>[
  // Play / pause
  VideoShortcutBinding(keys: SingleActivator(_space), intent: TogglePlayIntent(), label: 'Space'),
  VideoShortcutBinding(keys: SingleActivator(LogicalKeyboardKey.keyK), intent: TogglePlayIntent(), label: 'K'),

  // Seek -10s / +10s
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.keyJ),
    intent: SeekByIntent(Duration(seconds: -10)),
    label: 'J',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.keyL),
    intent: SeekByIntent(Duration(seconds: 10)),
    label: 'L',
  ),

  // Seek -5s / +5s
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.arrowLeft),
    intent: SeekByIntent(Duration(seconds: -5)),
    label: 'ArrowLeft',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.arrowRight),
    intent: SeekByIntent(Duration(seconds: 5)),
    label: 'ArrowRight',
  ),

  // Volume +/-5%, mute
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.arrowUp),
    intent: AdjustVolumeIntent(0.05),
    label: 'ArrowUp',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.arrowDown),
    intent: AdjustVolumeIntent(-0.05),
    label: 'ArrowDown',
  ),
  VideoShortcutBinding(keys: SingleActivator(LogicalKeyboardKey.keyM), intent: ToggleMuteIntent(), label: 'M'),

  // Fullscreen / captions
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.keyF),
    intent: ToggleFullscreenIntent(),
    label: 'F',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.keyC),
    intent: ToggleCaptionsIntent(),
    label: 'C',
  ),

  // 0-9: jump to 0%-90%
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.digit0),
    intent: SeekToPercentIntent(0),
    label: '0',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.digit1),
    intent: SeekToPercentIntent(0.1),
    label: '1',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.digit2),
    intent: SeekToPercentIntent(0.2),
    label: '2',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.digit3),
    intent: SeekToPercentIntent(0.3),
    label: '3',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.digit4),
    intent: SeekToPercentIntent(0.4),
    label: '4',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.digit5),
    intent: SeekToPercentIntent(0.5),
    label: '5',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.digit6),
    intent: SeekToPercentIntent(0.6),
    label: '6',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.digit7),
    intent: SeekToPercentIntent(0.7),
    label: '7',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.digit8),
    intent: SeekToPercentIntent(0.8),
    label: '8',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.digit9),
    intent: SeekToPercentIntent(0.9),
    label: '9',
  ),

  // Speed -0.25 / +0.25, clamped to 0.25-2.0 by the handler
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.comma, shift: true),
    intent: AdjustSpeedIntent(-0.25),
    label: 'Shift+,',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.less),
    intent: AdjustSpeedIntent(-0.25),
    label: 'Shift+,',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.period, shift: true),
    intent: AdjustSpeedIntent(0.25),
    label: 'Shift+.',
  ),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.greater),
    intent: AdjustSpeedIntent(0.25),
    label: 'Shift+.',
  ),

  // Episodes
  VideoShortcutBinding(keys: SingleActivator(LogicalKeyboardKey.keyN), intent: NextEpisodeIntent(), label: 'N'),
  VideoShortcutBinding(
    keys: SingleActivator(LogicalKeyboardKey.keyN, shift: true),
    intent: PreviousEpisodeIntent(),
    label: 'Shift+N',
  ),

  // Exit fullscreen (and nothing else)
  VideoShortcutBinding(keys: SingleActivator(_escape), intent: ExitFullscreenIntent(), label: 'Esc'),
];

/// `Shortcuts` wants activator -> intent.
Map<ShortcutActivator, Intent> videoShortcutMap() {
  return <ShortcutActivator, Intent>{
    for (final binding in videoShortcutBindings) binding.keys: binding.intent,
  };
}

/// Builds one [CallbackAction] per distinct intent in the table, so every
/// documented key is dispatchable by construction.
Map<Type, Action<Intent>> videoShortcutActions(bool Function(VideoIntent intent) onIntent) {
  final actions = <Type, Action<Intent>>{};
  for (final binding in videoShortcutBindings) {
    actions.putIfAbsent(
      binding.intent.runtimeType,
      () => CallbackAction<VideoIntent>(
        onInvoke: (intent) {
          onIntent(intent);
          return null;
        },
      ),
    );
  }
  return actions;
}

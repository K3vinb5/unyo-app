import 'package:hive_ce/hive.dart';
import 'package:unyo/data/adapters/adapters_names.dart' as names;
import 'package:unyo/data/adapters/adapters_types.dart' as types;

part 'video_display_mode.g.dart';

/// How the video surface fills the player area (WP #114).
///
/// - [fit]: today's behaviour — the whole frame, letterboxed, aspect preserved.
/// - [crop]: fills the area, aspect preserved, the overflow is clipped
///   (cover semantics).
/// - [stretch]: fills the area ignoring the aspect ratio (fill semantics).
@HiveType(typeId: types.videoDisplayModeAdapterType, adapterName: names.videoDisplayModeEnumAdapterName)
enum VideoDisplayMode {
  @HiveField(0) fit,
  @HiveField(1) crop,
  @HiveField(2) stretch;

  /// Cycle order is Fit -> Crop -> Stretch -> Fit.
  VideoDisplayMode get next => nextVideoDisplayMode(this);
}

/// The mode after [mode] in the button's cycle.
VideoDisplayMode nextVideoDisplayMode(VideoDisplayMode mode) => switch (mode) {
      VideoDisplayMode.fit => VideoDisplayMode.crop,
      VideoDisplayMode.crop => VideoDisplayMode.stretch,
      VideoDisplayMode.stretch => VideoDisplayMode.fit,
    };

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// A single camera pose for the banner Ken-Burns move.
///
/// [scale] is an absolute zoom factor (always >= 1 so the image keeps covering
/// the banner) and [pan] is the image's travel in normalised banner units:
/// `-1` is the full left/top edge of the available slack, `+1` the full
/// right/bottom edge. Normalised pan is independent of the live zoom, so one
/// unit of progress always moves the camera the same distance.
@immutable
class BannerPose {
  const BannerPose({required this.scale, required this.pan});

  final double scale;
  final Offset pan;

  /// Conversion of the normalised [pan] into logical pixels for a banner of
  /// [size], using the slack left over by [minScale] — the tightest zoom the
  /// camera ever uses — so the pan can never reveal the background.
  Offset panInPixels(Size size, double minScale) {
    final double slackX = size.width * (minScale - 1) / 2;
    final double slackY = size.height * (minScale - 1) / 2;
    return Offset(pan.dx * slackX, pan.dy * slackY);
  }

  @override
  bool operator ==(Object other) =>
      other is BannerPose && other.scale == scale && other.pan == pan;

  @override
  int get hashCode => Object.hash(scale, pan);

  @override
  String toString() => 'BannerPose(scale: $scale, pan: $pan)';
}

/// Segment-based camera for [UnyoAnimatedImageBanner].
///
/// Every segment is a forward-only move from [begin] to [end]. When a segment
/// completes the caller calls [advanceSegment]: the old end becomes the new
/// begin, so [frameAt] is continuous across joints — there is no reverse pass
/// and no pose is ever re-picked mid-move.
class BannerCamera {
  BannerCamera({
    math.Random? random,
    this.minScale = 1.2,
    this.maxScale = 1.55,
  }) : _random = random ?? math.Random();

  final math.Random _random;
  final double minScale;
  final double maxScale;

  late BannerPose _begin;
  late BannerPose _end;
  bool _zoomingIn = true;
  bool _started = false;

  /// Zoom at the start of the move (the tightest allowed zoom).
  BannerPose get begin => _begin;

  /// Zoom at the end of the move (the widest allowed zoom).
  BannerPose get end => _end;

  /// Captures the first segment: zoom in from [minScale] to [maxScale] while
  /// drifting from one random point to another. The first frame is a real
  /// pose, never the top-left corner.
  void start() {
    if (_started) {
      return;
    }
    _started = true;
    _begin = _randomPose(minScale);
    _end = _randomPose(maxScale);
    _zoomingIn = true;
  }

  /// The pose at [progress] (`0` = [begin], `1` = [end]) of the current
  /// segment. Progress is monotonic per segment because the controller only
  /// ever runs forward.
  BannerPose frameAt(double progress) {
    final double t = Curves.easeInOut.transform(progress.clamp(0.0, 1.0));
    return BannerPose(
      scale: _begin.scale + (_end.scale - _begin.scale) * t,
      pan: Offset(
        _begin.pan.dx + (_end.pan.dx - _begin.pan.dx) * t,
        _begin.pan.dy + (_end.pan.dy - _begin.pan.dy) * t,
      ),
    );
  }

  /// Closes the current segment and opens the next one: the pose the camera
  /// ended on becomes its next starting pose (continuity), and the zoom target
  /// alternates so the move breathes instead of bouncing off the same zoom.
  BannerPose advanceSegment() {
    _begin = _end;
    _zoomingIn = !_zoomingIn;
    _end = _randomPose(_zoomingIn ? maxScale : minScale);
    return _end;
  }

  BannerPose _randomPose(double scale) {
    return BannerPose(
      scale: scale,
      pan: Offset(
        _random.nextDouble() * 2 - 1,
        _random.nextDouble() * 2 - 1,
      ),
    );
  }
}

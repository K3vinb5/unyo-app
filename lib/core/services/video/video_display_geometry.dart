// External dependencies
import 'dart:math' as math;
import 'dart:ui' show Size;

// Internal dependencies
import 'package:unyo/core/enums/video_display_mode.dart';

/// Aspect ratio used while the stream's real one is still unknown. Same 16:9
/// fallback the texture's 200 ms poll starts from.
const double fallbackVideoAspectRatio = 16 / 9;

/// The size the video surface is drawn at for [mode] (WP #114).
///
/// The surface is then centred in [viewport]; anything larger than the viewport
/// is clipped by the caller (Crop only).
///
/// - [VideoDisplayMode.fit]     -> letterbox: `min(width, height * ratio)`
/// - [VideoDisplayMode.crop]    -> cover: `max(width, height * ratio)`
/// - [VideoDisplayMode.stretch] -> the viewport exactly, ratio ignored
Size videoSurfaceSize({
  required VideoDisplayMode mode,
  required Size viewport,
  required double streamAspectRatio,
}) {
  final double width = viewport.width;
  final double height = viewport.height;
  if (width <= 0 || height <= 0) return Size.zero;

  switch (mode) {
    case VideoDisplayMode.stretch:
      return Size(width, height);
    case VideoDisplayMode.fit:
    case VideoDisplayMode.crop:
      final double ratio = (streamAspectRatio.isFinite && streamAspectRatio > 0)
          ? streamAspectRatio
          : fallbackVideoAspectRatio;
      final double byHeight = height * ratio;
      // fit: whichever of the two candidate widths is smaller keeps the frame
      // inside the viewport; crop takes the larger one and overflows.
      final double surfaceWidth =
          mode == VideoDisplayMode.fit ? math.min(width, byHeight) : math.max(width, byHeight);
      final double surfaceHeight = surfaceWidth / ratio;
      return Size(surfaceWidth, surfaceHeight);
  }
}

/// Whether the surface overflows the viewport and has to be clipped. Only Crop
/// can, and it must be clipped to the video area — never over the controls.
bool videoSurfaceOverflows({required VideoDisplayMode mode, required Size viewport, required double streamAspectRatio}) {
  if (mode != VideoDisplayMode.crop) return false;
  final Size surface = videoSurfaceSize(
    mode: mode,
    viewport: viewport,
    streamAspectRatio: streamAspectRatio,
  );
  return surface.width > viewport.width + 0.5 || surface.height > viewport.height + 0.5;
}

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:unyo/core/enums/video_display_mode.dart';
import 'package:unyo/core/services/video/video_display_geometry.dart';
import 'package:unyo/core/services/video/video_service.dart';

/// The video surface.
///
/// [mode] (WP #114) decides how the frame fills the player area:
/// Fit letterboxes it at the stream's ratio, Crop covers the area and clips the
/// overflow to the video area, Stretch fills the area and distorts. In every
/// mode the geometry comes from [videoSurfaceSize], so a late-arriving aspect
/// ratio only changes the computed size — there is no second layout pass and no
/// flicker.
class UnyoVideoTexture extends StatefulWidget {
  final VideoService videoService;
  final VideoDisplayMode mode;

  const UnyoVideoTexture({
    super.key,
    required this.videoService,
    this.mode = VideoDisplayMode.fit,
  });

  @override
  State<UnyoVideoTexture> createState() => _UnyoVideoTextureState();
}

class _UnyoVideoTextureState extends State<UnyoVideoTexture> {
  late VideoService _videoService;
  late double aspectRatio;
  Timer? _aspectRatioTimer;

  @override
  void initState() {
    super.initState();
    _videoService = widget.videoService;
    aspectRatio = _videoService.aspectRatio;
    if (aspectRatio <= 0) {
      aspectRatio = fallbackVideoAspectRatio; // Default aspect ratio
      _aspectRatioTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        final newAspectRatio = _videoService.aspectRatio;
        if (newAspectRatio > 0) {
          setState(() {
            aspectRatio = newAspectRatio;
          });
          timer.cancel();
        }
      });
    }
    _videoService.updateTexture();
  }

  @override
  void dispose() {
    _aspectRatioTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: _videoService.textureId,
      builder: (context, id, _) {
        if (id == null) return const SizedBox.shrink();
        return LayoutBuilder(
          builder: (context, constraints) {
            final Size viewport = constraints.biggest;
            final Size surface = videoSurfaceSize(
              mode: widget.mode,
              viewport: viewport,
              streamAspectRatio: aspectRatio,
            );
            final Widget frame = SizedBox(
              width: surface.width,
              height: surface.height,
              child: Texture(textureId: id),
            );
            final Widget centred = Center(child: frame);
            // Only Crop can overflow; clipping is bound to the video area, so
            // the oversized frame never paints over the controls on top of it.
            return videoSurfaceOverflows(
              mode: widget.mode,
              viewport: viewport,
              streamAspectRatio: aspectRatio,
            )
                ? ClipRect(child: centred)
                : centred;
          },
        );
      },
    );
  }
}

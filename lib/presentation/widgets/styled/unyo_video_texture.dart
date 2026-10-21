import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:unyo/core/services/video/video_service.dart';

class UnyoVideoTexture extends StatefulWidget {
  final VideoService videoService;

  const UnyoVideoTexture({super.key, required this.videoService});

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
      aspectRatio = 16 / 9; // Default aspect ratio
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
    return Center(
      child: ValueListenableBuilder<int?>(
        valueListenable: _videoService.textureId,
        builder: (context, id, _) => id == null
            ? const SizedBox.shrink()
            : AspectRatio(
                aspectRatio: aspectRatio,
                child: Texture(textureId: id),
              ),
      ),
    );
  }
}

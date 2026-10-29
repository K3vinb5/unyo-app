import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/styled/banner_camera.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';

/// Ken-Burns banner: a slow zoom plus a drift across a random point of the
/// image, on a per-segment camera ([BannerCamera]) instead of a reversing
/// animation.
///
/// The old implementation ran `repeat(reverse: true)` and tried to re-pick the
/// focal point when the controller "completed" — which never happens while
/// reversing, so the camera ping-ponged along the same path from the top-left
/// corner. Here every segment runs forward only and the next one starts
/// exactly where the previous one stopped, so joins never jump.
///
/// Cost: the animated layer is a plain scaled/translated image inside a
/// [RepaintBoundary] — no per-frame [ImageFilter] blur — and the image subtree
/// is built once and passed through [AnimatedBuilder.child].
class UnyoAnimatedImageBanner extends StatefulWidget {
  static const Duration defaultSegmentDuration = Duration(seconds: 15);

  final String imageUrl;

  /// Test seams; production only ever uses the 15 s default.
  @visibleForTesting
  final Duration segmentDuration;
  @visibleForTesting
  final math.Random? random;

  const UnyoAnimatedImageBanner({
    super.key,
    required this.imageUrl,
    this.segmentDuration = defaultSegmentDuration,
    this.random,
  });

  @override
  State<UnyoAnimatedImageBanner> createState() =>
      _UnyoAnimatedImageBannerState();
}

class _UnyoAnimatedImageBannerState extends State<UnyoAnimatedImageBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final BannerCamera _camera;

  @override
  void initState() {
    super.initState();
    _camera = BannerCamera(random: widget.random)..start();
    _animationController = AnimationController(
      duration: widget.segmentDuration,
      vsync: this,
    )..addStatusListener(_handleSegmentCompleted);
    _animationController.forward();
  }

  /// Segment boundary: the current end pose becomes the next begin pose and the
  /// controller restarts at 0 in the same callback, so the first frame of the
  /// new segment is pixel-identical to the last frame of the old one.
  void _handleSegmentCompleted(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    _camera.advanceSegment();
    _animationController.forward(from: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
    } else if (!_animationController.isAnimating) {
      // Resuming from the accessibility setting: if the last segment had
      // already ended, open a new one instead of sitting on a completed value.
      if (_animationController.isCompleted) {
        _camera.advanceSegment();
        _animationController.forward(from: 0);
      } else {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Size size = constraints.biggest;
            return AnimatedBuilder(
              animation: _animationController,
              // Built once: the image subtree is reused every frame.
              child: UnyoNetworkImage(
                url: widget.imageUrl,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              ),
              builder: (BuildContext context, Widget? child) {
                final BannerPose pose =
                    _camera.frameAt(_animationController.value);
                return _posed(pose, size, child!);
              },
            );
          },
        ),
      ),
    );
  }

  /// Pan is applied outside the zoom, in logical pixels taken from the pose's
  /// normalised travel — the drift speed no longer depends on the live zoom.
  Widget _posed(BannerPose pose, Size size, Widget child) {
    return Transform.translate(
      offset: pose.panInPixels(size, _camera.minScale),
      child: Transform.scale(scale: pose.scale, child: child),
    );
  }
}
